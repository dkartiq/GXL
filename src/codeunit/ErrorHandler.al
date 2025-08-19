codeunit 50071 "GXL Error Handler"
{
    trigger OnRun()
    begin
        case MethodG of
            'UpsertRecord':
                UpsertRecord();
            'ProcessRequest':
                ProcessRequest();
            'GetRequestRecord':
                GetRequestRecord();
        end;

    end;

    procedure SetDef(Method: Text; var RecVariant: Variant)
    begin
        MethodG := Method;
        RecVariantG := RecVariant;
    end;

    procedure SetDef(Method: Text; APILogEntry: Integer; var JsonText: Text)
    begin
        MethodG := Method;
        APILogEntryG := APILogEntry;
        JsonTextG := JsonText;
    end;

    local procedure ProcessRequest()
    var

        APITableFields: Record "GXL API Table Fields";
        APILog: Record "GXL API Log";
        APIHandler: Codeunit "GXL API Integration Handler";
        JsonText: Text;
        JsonObj: JsonObject;
        JsonItemArray: JsonArray;
        JsonRecord: JsonObject;

        FieldArray: JsonArray;
        FieldToken: JsonToken;
        JToken: JsonToken;
        FunctionName: Text;
        ItemObj: JsonToken;
        ItemElement: JsonToken;
        TableNo: Integer;
        RequestEntryNo: Integer;
        RequestLogEntryNo: Integer;
        PayloadEntryNo: Integer;
        FldNo: Integer;
        RespEntryNo: Integer;
        FldName: Text;
        FldValue: Text;
        RecRef: RecordRef;
        RecID: RecordID;
        FieldMap: Dictionary of [Integer, Text];
        TempApiData: Record "GXL API Data" temporary;
        ApiData: Record "GXL API Data";
        APIEntryNo: Integer;
        FieldIsNotallowed: Label 'The field %1 is not allowed in API %2';
    begin
        JsonText := JsonTextG;

        JsonObj.ReadFrom(JsonText);
        if JsonObj.Keys.Count() = 0 then
            Error('Invalid JSON payload.');

        // Use the first property name dynamically
        FunctionName := JsonObj.Keys.Get(1);
        JsonObj.Get(FunctionName, ItemObj);

        if not ItemObj.IsArray then
            Error('Invalid structure. Expected an array under "%1"', FunctionName);

        JsonItemArray := ItemObj.AsArray();

        TableNo := APIHandler.GetTableNo(FunctionName);
        RequestLogEntryNo := APILogEntryG;
        APILog.Get(RequestLogEntryNo);
        APILog."GXL Table No." := TableNo;
        APILog."GXL Function" := FunctionName;
        APILog.Modify();
        Commit();

        foreach ItemElement in JsonItemArray do begin
            Clear(FieldMap);
            if ItemElement.IsObject() then begin
                JsonObj := ItemElement.AsObject();

                if JsonObj.Get('Record', JToken) then
                    if JToken.IsObject() then begin
                        JsonRecord := JToken.AsObject();

                        if JsonRecord.Get('Fields', JToken) then
                            if JToken.IsArray() then
                                FieldArray := JToken.AsArray();
                    end;
            end;

            foreach FieldToken in FieldArray do begin

                FldNo := APIHandler.GetFieldValue(FieldToken, 'Field No.').AsValue().AsInteger();
                FldValue := APIHandler.GetFieldValue(FieldToken, 'Value').AsValue().AsText();
                FldName := APIHandler.GetFieldValue(FieldToken, 'Field Name').AsValue().AsText();
                FieldMap.Add(FldNo, FldValue);

                if not APITableFields.Get(FunctionName, FldNo) then
                    Error(StrSubstNo(FieldIsNotallowed, FldNo, FunctionName));

                APIEntryNo += 1;

                APIHandler.InsertApiData(TempApiData, APIEntryNo,
                    RequestLogEntryNo,
                    PayloadEntryNo,
                    FldNo,
                    FldName,
                    FldValue, APITableFields.Sequence,
                    ''
                );
            end;
            RecID := APIHandler.BuildRecordID(TableNo, FieldMap);
            PayloadEntryNo := APIHandler.InsertPayloadRequestRecord(RequestLogEntryNo, RecID, "GXL API Record Status"::" ", '');

            if TempApiData.FindSet() then
                repeat
                    ApiData.Init();
                    ApiData.TransferFields(TempApiData);
                    ApiData."GXL API PayloadRequestEntryNo." := PayloadEntryNo;
                    ApiData."Entry No." := 0;
                    ApiData.Insert(true);
                until TempApiData.Next() = 0;
            TempApiData.DeleteAll();
            PayloadEntryNo := 0;
        end;
    end;

    procedure UpsertRecord()
    var
        PayloadRec: Record "GXL Payload Request Records";
        ApiDataRec: Record "GXL API Data";
        APILog: Record "GXL API Log";
        APITable: Record "GXL API Table Setup";
        APIHandler: Codeunit "GXL API Integration Handler";
        RecRef: RecordRef;
        FieldRef: FieldRef;
        FieldDict: Dictionary of [Integer, Text];
        KeyFields: List of [Integer];
        FieldNo: Integer;
        TableNo: Integer;
        FieldValue: Text;
        RecExists: Boolean;
        SkipField: Boolean;
        IsHandled: Boolean;
        IsInsert: Boolean;
        Validate: Boolean;
        InsertTrigger: Boolean;
        ModifyTrigger: Boolean;
        FieldIsNotallowed: Label 'The field %1 is not allowed in API %2';
    begin
        PayloadRec.Copy(RecVariantG);
        if not PayloadRec.FindFirst() then
            Error('API Payload Record %1 not found.', PayloadRec.GetFilter("Entry No."));
        APILog.Get(PayloadRec."GXL API Log Entry No.");
        // Read related API Data lines
        ApiDataRec.Reset();
        ApiDataRec.SetRange("GXL API PayloadRequestEntryNo.", PayloadRec."Entry No.");
        if ApiDataRec.IsEmpty then
            exit;

        // Build dictionary of Field No. => Value
        Clear(FieldDict);
        ApiDataRec.SetCurrentKey("GXL Sequence");
        if ApiDataRec.FindSet() then
            repeat
                FieldDict.Add(ApiDataRec."GXL Field No.", ApiDataRec."GXL Field Value");
            until ApiDataRec.Next() = 0;

        // Open target record using RecordID
        TableNo := PayloadRec."GXL RecordID".TableNo;
        RecRef.Open(TableNo);
        RecExists := RecRef.Get(PayloadRec."GXL RecordID");
        if not RecExists then
            RecRef.Init();
        // Set values for all fields from dictionary
        foreach FieldNo in FieldDict.Keys do begin

            if APIHandler.FieldExistsInTable(APILog."GXL Function", FieldNo, SkipField, Validate) then begin

                FieldValue := FieldDict.Get(FieldNo);
                APIHandler.OnBeforeSetFieldValue(TableNo, FieldNo, FieldValue, SkipField, Validate);
                if not SkipField then begin
                    FieldRef := RecRef.Field(FieldNo);
                    APIHandler.SetFieldValueFromText(FieldRef, FieldValue);
                    if Validate then
                        FieldRef.Validate();
                    APIHandler.OnAfterSetFieldValue(TableNo, FieldNo, FieldValue);
                end;

            end else
                Error(StrSubstNo(FieldIsNotallowed, FieldNo, APILog."GXL Function"));

        end;

        // Modify or insert the record
        APITable.Get(APILog."GXL Function");
        IsHandled := false;
        IsInsert := not RecExists;
        InsertTrigger := APITable."Enable Insert Trigger";
        ModifyTrigger := APITable."Enable Modify Trigger";
        APIHandler.OnBeforeRecordUpsert(RecRef, IsInsert, IsHandled, InsertTrigger, ModifyTrigger);
        if IsHandled then
            exit;
        if not RecExists then
            RecRef.Insert(InsertTrigger)
        else
            RecRef.Modify(ModifyTrigger);

        APIHandler.OnAfterRecordUpsert(RecRef, not RecExists);
    end;

    local procedure GetRequestRecord()
    var
        APILog: Record "GXL API Log";
        APIHandler: Codeunit "GXL API Integration Handler";
        APITableFields: Record "GXL API Table Fields";
        RequestLogEntryNo: Integer;
        JsonText: Text;
        JsonObj: JsonObject;
        JsonRecord: JsonObject;
        JsonItemArray: JsonArray;

        ItemObj: JsonToken;
        ItemElement: JsonToken;
        FieldArray: JsonArray;
        FieldToken: JsonToken;
        JToken: JsonToken;

        TableNo: Integer;
        FldNo: Integer;
        FldName: Text;
        FldValue: Text;
        FunctionName: Text;
        FieldMap: Dictionary of [Integer, Text];
        FieldIsNotallowed: Label 'The field %1 is not allowed in API %2';
        RecRef: RecordRef;
        FieldRef: FieldRef;
        DateformulaValue: DateFormula;
        DurationValue: Duration;
        IntValue: Integer;
        CodeValue: Code[20];
        DateValue: Date;
        DecimalValue: Decimal;
        BooleanValue: Boolean;
        TimeValue: Time;
        DateTimeValue: DateTime;
    begin
        JsonText := JsonTextG;

        JsonObj.ReadFrom(JsonText);
        if JsonObj.Keys.Count() = 0 then
            Error('Invalid JSON payload.');
        // Use the first property name dynamically
        FunctionName := JsonObj.Keys.Get(1);
        JsonObj.Get(FunctionName, ItemObj);

        if not ItemObj.IsArray then
            Error('Invalid structure. Expected an array under "%1"', FunctionName);

        JsonItemArray := ItemObj.AsArray();

        TableNo := APIHandler.GetTableNo(FunctionName);
        RequestLogEntryNo := APILogEntryG;
        APILog.Get(RequestLogEntryNo);
        APILog."GXL Table No." := TableNo;
        APILog."GXL Function" := FunctionName;
        APILog.Modify();
        Commit();
        RecRef.Open(TableNo);
        foreach ItemElement in JsonItemArray do begin
            Clear(FieldMap);
            if ItemElement.IsObject() then begin
                JsonObj := ItemElement.AsObject();

                if JsonObj.Get('Record', JToken) then
                    if JToken.IsObject() then begin
                        JsonRecord := JToken.AsObject();

                        if JsonRecord.Get('Fields', JToken) then
                            if JToken.IsArray() then
                                FieldArray := JToken.AsArray();
                    end;
            end;

            foreach FieldToken in FieldArray do begin

                FldNo := APIHandler.GetFieldValue(FieldToken, 'Field No.').AsValue().AsInteger();
                FldValue := APIHandler.GetFieldValue(FieldToken, 'Value').AsValue().AsText();

                FieldRef := RecRef.Field(FldNo);
                case FieldRef.Type of
                    FieldType::Integer:
                        begin
                            Evaluate(IntValue, FldValue);
                            FieldRef.SetRange(IntValue);
                        end;
                    FieldType::Code:
                        begin
                            Evaluate(CodeValue, FldValue);
                            FieldRef.SetRange(CodeValue);
                        end;
                    FieldType::Text:
                        begin
                            FieldRef.SetRange(FldValue);
                        end;
                    FieldType::Date:
                        begin
                            Evaluate(DateValue, FldValue);
                            FieldRef.SetRange(DateValue);
                        end;
                    FieldType::Decimal:
                        begin
                            Evaluate(DecimalValue, FldValue);
                            FieldRef.SetRange(DecimalValue);
                        end;
                    FieldType::Boolean:
                        begin
                            Evaluate(BooleanValue, FldValue);
                            FieldRef.SetRange(BooleanValue);
                        end;
                    FieldType::Option:
                        begin
                            // Evaluate(Optionvalue, FieldValueText);
                            FieldRef.SetRange(APIHandler.GetOptionIndexFromText(FieldRef, FldValue));
                        end;
                    FieldType::Time:
                        begin
                            Evaluate(TimeValue, FldValue);
                            FieldRef.SetRange(TimeValue);
                        end;
                    FieldType::DateTime:
                        begin
                            Evaluate(DateTimeValue, FldValue);
                            FieldRef.SetRange(DateTimeValue);
                        end;
                    FieldType::Duration:
                        begin
                            Evaluate(DurationValue, FldValue);
                            FieldRef.SetRange(DurationValue);
                        end;
                    FieldType::DateFormula:
                        begin
                            Evaluate(DateformulaValue, FldValue);
                            FieldRef.SetRange(DateformulaValue);
                        end;

                    else
                        Error('Field type %1 not supported.', Format(FieldRef.Type));
                end;

            end;
            ResponseJSON := APIHandler.GenerateJSONFile(FunctionName,
              TableNo,
              RecRef);
        end;
    end;

    procedure GetResposeJson(): Text
    begin
        exit(ResponseJSON);
    end;

    var
        MethodG: Text;
        RecVariantG: Variant;
        APILogEntryG: Integer;
        JsonTextG: Text;
        ResponseJSON: Text;
}