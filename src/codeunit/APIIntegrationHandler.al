// 001 22.07.2025 KDU https://petbarnjira.atlassian.net/browse/HAR2-576
codeunit 50070 "GXL API Integration Handler"
{
    [ServiceEnabled]
    procedure upSert(partnerCode: Code[20]; system: Code[20]; interfaceContract: Code[20]; interfaceContractVersion: Code[20]; type: Code[20]; payloadType: Code[20]; payload: Text): Integer
    var
        APILog: Record "GXL API Log";
        RequestLogEntryNo: Integer;
        RequestEntryNo: Integer;
        RespEntryNo: Integer;
        ErrorHandler: Codeunit "GXL Error Handler";
        Base64: Codeunit "Base64 Convert";
        IntVariant: Variant;
        JsonText: Text;
    begin
        jsonText := Base64.FromBase64(payload);

        RequestLogEntryNo := InsertApiLog(RequestEntryNo, "GXL API Log Type"::Request, '', 0, "GXL API Action"::Upsert, partnerCode, system, interfaceContract, interfaceContractVersion, type, payloadType);
        InsertEncrptAttachment(RequestLogEntryNo, payload);
        InsertApiAttachment(RequestLogEntryNo, jsonText);
        Commit();
        IntVariant := RequestLogEntryNo;
        ErrorHandler.SetDef('ProcessRequest', IntVariant, jsonText);
        if not ErrorHandler.Run() then begin

            APILog.Get(RequestLogEntryNo);
            APILog."GXL Status" := APILog."GXL Status"::Error;
            APILog.Modify();

            RespEntryNo := InsertApiLog(RequestLogEntryNo, "GXL API Log Type"::Response, APILog."GXL Function", 0, "GXL API Action"::Upsert, partnerCode, system, interfaceContract, interfaceContractVersion, type, payloadType);
            InsertApiAttachment(RespEntryNo, GetLastErrorText + '\Call Stack : \' + GetLastErrorCallStack);
            Commit();

            Error(GetLastErrorText);

        end else begin
            APILog.Get(RequestLogEntryNo);
            APILog."GXL Status" := APILog."GXL Status"::Created;
            APILog.Modify();
            RespEntryNo := InsertApiLog(RequestLogEntryNo, "GXL API Log Type"::Response, APILog."GXL Function", 0, "GXL API Action"::Upsert, partnerCode, system, interfaceContract, interfaceContractVersion, type, payloadType);
        end;
        exit(RequestLogEntryNo);
    end;



    procedure BuildRecordID(TableID: Integer; FieldMap: Dictionary of [Integer, Text]): RecordID
    var
        RecRef: RecordRef;
        FldRef: FieldRef;
        KeyFields: List of [Integer];
        i: Integer;
        FieldValue: Text;
    begin
        RecRef.Open(TableID);

        KeyFields := GetPrimaryKeyFieldNos(TableID);

        foreach i in KeyFields do begin
            if FieldMap.Get(i, FieldValue) then begin
                FldRef := RecRef.Field(i);
                SetFieldValueFromText(FldRef, FieldValue);
            end;
        end;

        exit(RecRef.RecordId());
    end;

    procedure SetFieldValueFromText(var FieldRef: FieldRef; FieldValueText: Text)
    var
        IntValue: Integer;
        CodeValue: Code[100];
        TextValue: Text;
        DateValue: Date;
        DecimalValue: Decimal;
        BooleanValue: Boolean;
        Optionvalue: Option;
        TimeValue: Time;
        DateTimeValue: DateTime;
        DurationValue: Duration;
        DateformulaValue: DateFormula;
    begin
        case FieldRef.Type of
            FieldType::Integer:
                begin
                    Evaluate(IntValue, FieldValueText);
                    FieldRef.Value := IntValue;
                end;
            FieldType::Code:
                begin
                    Evaluate(CodeValue, FieldValueText);
                    FieldRef.Value := CodeValue;
                end;
            FieldType::Text:
                begin
                    FieldRef.Value := FieldValueText;
                end;
            FieldType::Date:
                begin
                    Evaluate(DateValue, FieldValueText);
                    FieldRef.Value := DateValue;
                end;
            FieldType::Decimal:
                begin
                    Evaluate(DecimalValue, FieldValueText);
                    FieldRef.Value := DecimalValue;
                end;
            FieldType::Boolean:
                begin
                    Evaluate(BooleanValue, FieldValueText);
                    FieldRef.Value := BooleanValue;
                end;
            FieldType::Option:
                begin
                    // Evaluate(Optionvalue, FieldValueText);
                    FieldRef.Value := GetOptionIndexFromText(FieldRef, FieldValueText);
                end;
            FieldType::Time:
                begin
                    Evaluate(TimeValue, FieldValueText);
                    FieldRef.Value := TimeValue;
                end;
            FieldType::DateTime:
                begin
                    Evaluate(DateTimeValue, FieldValueText);
                    FieldRef.Value := DateTimeValue;
                end;
            FieldType::Duration:
                begin
                    Evaluate(DurationValue, FieldValueText);
                    FieldRef.Value := DurationValue;
                end;
            FieldType::DateFormula:
                begin
                    Evaluate(DateformulaValue, FieldValueText);
                    FieldRef.Value := DateformulaValue;
                end;

            else
                Error('Field type %1 not supported.', Format(FieldRef.Type));
        end;
    end;

    procedure GetOptionIndexFromText(FieldRef: FieldRef; OptionText: Text): Integer
    var
        Captions: List of [Text];
        CaptionStr: Text;
        Index: Integer;
    begin
        CaptionStr := FieldRef.OptionCaption;
        if CaptionStr = '' then
            Error('No option captions found for field %1.', FieldRef.Number);

        Captions := CaptionStr.Split(',');
        for Index := 1 to Captions.Count do begin
            if Captions.Get(Index) = OptionText then
                exit(Index - 1); // Option values are 0-based
        end;

        Error('Invalid option value "%1" for field %2. Valid options: %3', OptionText, FieldRef.Number, CaptionStr);
    end;


    local procedure GetPrimaryKeyFieldNos(TableID: Integer): List of [Integer]
    var
        RecRef: RecordRef;
        i: Integer;
        FieldNo: Integer;
        FldRef: FieldRef;
        KRef: KeyRef;
        FieldList: List of [Integer];
    begin
        RecRef.Open(TableID);
        KRef := RecRef.KeyIndex(1);
        for i := 1 to KRef.FieldCount do begin
            FldRef := KRef.FieldIndex(i);
            FieldList.Add(FldRef.Number);
        end;
        exit(FieldList);
    end;

    procedure GetFieldValue(FieldToken: JsonToken; JKey: text): JsonToken
    var
        JsonField: JsonObject;
        ValueToken: JsonToken;
    begin
        if FieldToken.IsObject() then begin
            JsonField := FieldToken.AsObject();
            if JsonField.Get(JKey, ValueToken) then
                exit(ValueToken);
        end;
    end;

    procedure GetTableNo(TableName: Text): Integer
    var
        APITableSetup: Record "GXL API Table Setup";
        NoTableSetup: Label 'The function %1 is not allowed';
    begin
        if not APITableSetup.Get(TableName) then
            Error(StrSubstNo(NoTableSetup, TableName));
        exit(APITableSetup."Table ID");
    end;



    local procedure InsertApiLog(var RequestEntryNo: Integer; LogType: Enum "GXL API Log Type"; FunctionName: Text; TableNo: Integer; Action: Enum "GXL API Action"; PartnerCode: Code[20]; System: Code[20]; InterfaceContract: Code[20]; InterfaceContractVersion: Code[20];
        Type: Code[20];
        PayloadType: Code[20]): Integer
    var
        ApiLog: Record "GXL API Log";
    begin
        ApiLog.Init();
        ApiLog."GXL Request Entry No." := RequestEntryNo;
        ApiLog."GXL Type" := LogType;
        ApiLog."GXL Date" := Today;
        ApiLog."GXL Time" := Time;
        ApiLog."GXL User" := UserId;
        ApiLog."GXL Action" := Action;
        ApiLog."GXL Function" := FunctionName;
        ApiLog."GXL Table No." := TableNo;
        ApiLog."GXL Status" := ApiLog."GXL Status"::Created;
        ApiLog."GXL Partner Code" := PartnerCode;
        ApiLog."GXL System" := System;
        ApiLog."GXL Interface Contract" := InterfaceContract;
        ApiLog."GXL Interface Contract Version" := InterfaceContractVersion;
        ApiLog."GXL API Type" := Type;
        ApiLog."GXL Payload Type" := PayloadType;
        ApiLog.Insert(true);
        RequestEntryNo += 1;
        exit(ApiLog."Entry No.");
    end;

    local procedure InsertApiAttachment(ApiLogEntryNo: Integer; JsonText: Text)
    var
        ApiAttachment: Record "GXL API Attachment Log";
        InStr: InStream;
        OutStr: OutStream;
        TempBlob: Codeunit "Temp Blob";
        IsInsert: Boolean;
    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(JsonText);
        TempBlob.CreateInStream(InStr);
        if not ApiAttachment.Get(ApiLogEntryNo) then begin
            ApiAttachment.Init();
            IsInsert := true;
        end;
        ApiAttachment."GXL API Log Entry No." := ApiLogEntryNo;
        ApiAttachment."GXL Attachment".ImportStream(InStr, 'application/json');
        if IsInsert then
            ApiAttachment.Insert()
        else
            ApiAttachment.Modify();
    end;

    local procedure InsertEncrptAttachment(ApiLogEntryNo: Integer; JsonText: Text)
    var
        ApiAttachment: Record "GXL API Attachment Log";
        InStr: InStream;
        OutStr: OutStream;
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(JsonText);
        TempBlob.CreateInStream(InStr);
        ApiAttachment.Init();
        ApiAttachment."GXL API Log Entry No." := ApiLogEntryNo;
        ApiAttachment."GXL Payload Attachment".ImportStream(InStr, 'application/json');
        ApiAttachment.Insert();
    end;

    procedure InsertPayloadRequestRecord(ApiLogEntryNo: Integer; RecordId: RecordID; Status: Enum "GXL API Record Status"; ErrorDesc: Text): Integer
    var
        PayloadRecord: Record "GXL Payload Request Records";
    begin
        PayloadRecord.Init();
        PayloadRecord."GXL API Log Entry No." := ApiLogEntryNo;
        PayloadRecord."GXL RecordID" := RecordId;
        PayloadRecord."GXL Status" := Status;
        PayloadRecord."GXL Error Desc" := ErrorDesc;
        PayloadRecord.Insert(true);
        exit(PayloadRecord."Entry No.");
    end;

    procedure InsertApiData(var ApiData: Record "GXL API Data"; APIEntryNo: Integer; ApiLogEntryNo: Integer; PayloadEntryNo: Integer; FieldNo: Integer; FieldName: Text; FieldValue: Text; Sequence: Integer; ErrorDesc: Text)
    begin
        ApiData.Init();
        ApiData."GXL API Log Entry No." := ApiLogEntryNo;
        ApiData."GXL API PayloadRequestEntryNo." := PayloadEntryNo;
        ApiData."GXL Field No." := FieldNo;
        ApiData."GXL Field Name" := FieldName;
        ApiData."GXL Field Value" := FieldValue;
        ApiData."GXL Error Desc" := ErrorDesc;
        ApiData."Entry No." := APIEntryNo;
        ApiData."GXL Sequence" := Sequence;
        ApiData.Insert(true);
    end;

    procedure ProcessAPIRecords()
    var
        APILog: Record "GXL API Log";
        PayloadRec: Record "GXL Payload Request Records";
        APITablesetup: Record "GXL API Table Setup";
    begin
        APITablesetup.SetCurrentKey("GXL Priority Level");
        APITablesetup.SetRange("GXL Disable", false);
        if APITablesetup.FindSet() then
            repeat
                APILog.SetRange("GXL Function", APITablesetup."API Name");
                APILog.SetFilter("GXL Status", '%1|%2', APILog."GXL Status"::Created, APILog."GXL Status"::PartiallyProcessed);
                APILog.SetRange("GXL Type", APILog."GXL Type"::Request);
                if APILog.FindSet() then
                    repeat
                        UpsertUnprocessedRec(APILog."Entry No.");
                        UpdateAPILogStatus(APILog."Entry No.");
                    until APILog.Next() = 0;
            Until APITablesetup.Next() = 0;
    end;

    local procedure UpdateAPILogStatus(APILogEntryNo: Integer)
    var
        PayloadRec: Record "GXL Payload Request Records";
        APILog: Record "GXL API Log";
        Errored: Boolean;
        Processed: Boolean;
    begin
        APILog.Get(APILogEntryNo);
        PayloadRec.SetRange("GXL API Log Entry No.", APILogEntryNo);
        PayloadRec.SetRange("GXL Status", PayloadRec."GXL Status"::Error);
        Errored := not PayloadRec.IsEmpty;
        PayloadRec.SetRange("GXL Status", PayloadRec."GXL Status"::Processed);
        Processed := not PayloadRec.IsEmpty;
        PayloadRec.SetRange("GXL Status", PayloadRec."GXL Status"::Error);
        case true of
            Errored and Processed:
                APILog."GXL Status" := APILog."GXL Status"::PartiallyProcessed;
            Errored and not Processed:
                APILog."GXL Status" := APILog."GXL Status"::Error;
            not Errored and Processed:
                APILog."GXL Status" := APILog."GXL Status"::Processed;
        end;
        APILog.Modify();
        Commit();
    end;

    local procedure UpsertUnprocessedRec(APILogEntryNo: Integer): Boolean
    var
        PayloadRec: Record "GXL Payload Request Records";
    begin
        PayloadRec.SetRange("GXL API Log Entry No.", APILogEntryNo);
        PayloadRec.SetRange("GXL Status", PayloadRec."GXL Status"::" ");
        if PayloadRec.FindSet() then
            repeat
                UpsertDataFromPayload(PayloadRec."Entry No.")
            until PayloadRec.Next() = 0;
    end;

    procedure UpsertDataFromPayload(PayloadEntryNo: Integer)
    var
        PayloadRec: Record "GXL Payload Request Records";
        ErrorHandler: Codeunit "GXL Error Handler";
        RecVariant: Variant;
    begin
        PayloadRec.SetRange("Entry No.", PayloadEntryNo);
        RecVariant := PayloadRec;
        ErrorHandler.SetDef('UpsertRecord', RecVariant);
        PayloadRec.Reset();
        PayloadRec.Get(PayloadEntryNo);
        if not ErrorHandler.Run() then begin
            PayloadRec."GXL Status" := PayloadRec."GXL Status"::Error;
            PayloadRec."GXL Error Desc" := CopyStr(GetLastErrorText, 1, MaxStrLen(PayloadRec."GXL Error Desc"));
        end else
            PayloadRec."GXL Status" := PayloadRec."GXL Status"::Processed;
        PayloadRec.Modify();
        Commit();
    end;

    procedure FieldExistsInTable(APIName: Text; FieldNo: Integer; var Skip: Boolean; var Validate: Boolean) Exists: Boolean
    var
        FieldMetadata: Record "GXL API Table Fields";
    begin
        Exists := FieldMetadata.Get(APIName, FieldNo);
        Skip := not FieldMetadata."Enable Field";
        Validate := FieldMetadata.Validate;
    end;

    procedure GenerateSampleJSON(APIName: Code[50]; TableID: Integer): Text
    var
        FieldRec: Record "GXL API Table Fields";
        RecordArray: JsonArray;
        RootObj: JsonObject;
        RecordObj: JsonObject;
        RecObj: JsonObject;
        FieldsArray: JsonArray;
        FieldObj: JsonObject;
        i, NumRecords : Integer;
        ValueText: Text;
        JsonText: Text;
    begin
        NumRecords := 2; // you can adjust this
        for i := 1 to NumRecords do begin
            // Reset for each record
            Clear(FieldsArray);
            FieldRec.SetRange("API Name", APIName);
            FieldRec.SetRange("Enable Field", true);
            FieldRec.SetCurrentKey("Sequence");
            if FieldRec.FindSet() then
                repeat
                    Clear(FieldObj);
                    FieldObj.Add('Field No.', FieldRec."Field No.");
                    FieldObj.Add('Field Name', FieldRec."Field Name");
                    ValueText := GetDefaultValue(TableID, FieldRec."Field No.");
                    FieldObj.Add('Value', ValueText);
                    FieldsArray.Add(FieldObj);
                until FieldRec.Next() = 0;

            Clear(RecordObj);
            RecordObj.Add('Fields', FieldsArray);
            Clear(RecObj);
            RecObj.Add('Record', RecordObj);
            RecordArray.Add(RecObj);
        end;

        RootObj.Add(APIName, RecordArray);
        RootObj.WriteTo(JsonText);
        exit(JsonText);
    end;

    procedure GenerateJSON(APIName: Code[50]; TableID: Integer): Text
    var
        FieldRec: Record "GXL API Table Fields";
        RecordArray: JsonArray;
        RootObj: JsonObject;
        RecordObj: JsonObject;
        RecObj: JsonObject;
        FieldsArray: JsonArray;
        FieldObj: JsonObject;
        ValueText: Text;
        JsonText: Text;
    begin
        // Reset for each record
        Clear(FieldsArray);
        FieldRec.SetRange("API Name", APIName);
        FieldRec.SetRange("Enable Field", true);
        FieldRec.SetCurrentKey("Sequence");
        if FieldRec.FindSet() then
            repeat
                Clear(FieldObj);
                FieldObj.Add('Field No.', FieldRec."Field No.");
                FieldObj.Add('Field Name', FieldRec."Field Name");
                FieldsArray.Add(FieldObj);
            until FieldRec.Next() = 0;

        Clear(RecordObj);
        RecordObj.Add('Fields', FieldsArray);
        Clear(RecObj);
        RecObj.Add('Record', RecordObj);
        RecordArray.Add(RecObj);

        RootObj.Add(APIName, RecordArray);
        RootObj.WriteTo(JsonText);
        exit(JsonText);
    end;

    procedure GenerateJSONFile(APIName: Code[50]; TableID: Integer; var RecRef: RecordRef): Text
    var
        FieldRec: Record "GXL API Table Fields";
        RecordArray: JsonArray;
        RootObj: JsonObject;
        RecordObj: JsonObject;
        RecObj: JsonObject;
        FieldsArray: JsonArray;
        FieldObj: JsonObject;
        i, NumRecords : Integer;
        ValueText: Text;
        JsonText: Text;
        FieldRef: FieldRef;
    begin
        if RecRef.FindSet() then
            repeat
                // Reset for each record
                Clear(FieldsArray);
                FieldRec.SetRange("API Name", APIName);
                FieldRec.SetRange("Enable Field", true);
                FieldRec.SetCurrentKey("Sequence");
                if FieldRec.FindSet() then
                    repeat
                        Clear(FieldObj);
                        // FieldObj.Add('Field No.', FieldRec."Field No.");
                        FieldObj.Add('Field Name', FieldRec."Field Name");
                        FieldRef := RecRef.Field(FieldRec."Field No.");
                        ValueText := FieldRef.Value;
                        FieldObj.Add('Value', ValueText);
                        FieldsArray.Add(FieldObj);
                    until FieldRec.Next() = 0;
                Clear(RecordObj);
                RecordObj.Add('Fields', FieldsArray);
                Clear(RecObj);
                RecObj.Add('Record', RecordObj);
                RecordArray.Add(RecObj);
            Until RecRef.Next() = 0;

        RootObj.Add(APIName, RecordArray);
        RootObj.WriteTo(JsonText);
        exit(JsonText);
    end;

    procedure GetDefaultValue(TableID: Integer; FieldNo: Integer) ValueText: Text
    var
        FieldMeta: Record Field;
    begin
        // Get default value based on datatype
        FieldMeta.Reset();
        FieldMeta.SetRange("TableNo", TableID);
        FieldMeta.SetRange("No.", FieldNo);
        if FieldMeta.FindFirst() then begin
            case FieldMeta.Type of
                FieldMeta.Type::Code:
                    ValueText := 'Capital text of length ' + Format(FieldMeta.Len);
                FieldMeta.Type::Text:
                    ValueText := 'Text of length ' + Format(FieldMeta.Len);
                FieldMeta.Type::Integer:
                    ValueText := '100';
                FieldMeta.Type::Decimal:
                    ValueText := '99.99';
                FieldMeta.Type::Date:
                    ValueText := Format(Today);
                FieldMeta.Type::DateTime:
                    ValueText := Format(CreateDateTime(Today, Time));
                FieldMeta.Type::Time:
                    ValueText := Format(Time);
                FieldMeta.Type::Boolean:
                    ValueText := 'Allowed option are true or false';
                FieldMeta.Type::Option:
                    ValueText := 'Allowed options are : ' + FieldMeta.OptionString;
                else
                    ValueText := '';
            end;
        end;
    end;

    procedure DownloadJson(JsonText: Text; FileName: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        OutStr: OutStream;
        Instr: InStream;
    begin
        // Initialize a new temp blob
        TempBlob.CreateOutStream(OutStr);

        // Write JSON string into stream
        OutStr.WriteText(JsonText);
        TempBlob.CreateInStream(Instr);
        // Download the file to the user
        DownloadFromStream(Instr, '', '', '', FileName);
    end;

    procedure UnescapeJson(EscapedJsonText: Text): Text
    var
        CleanedJson: Text;
    begin
        // Replace common escape sequences
        CleanedJson := EscapedJsonText;
        CleanedJson := CleanedJson.Replace('\"', '"');
        CleanedJson := CleanedJson.Replace('\\', '\');
        CleanedJson := CleanedJson.Replace('\n', '');
        CleanedJson := CleanedJson.Replace('\r', '');
        CleanedJson := CleanedJson.Replace('\t', '');

        // Optional: remove leading/trailing quotes if entire JSON is quoted
        if CopyStr(CleanedJson, 1, 1) = '"' then
            CleanedJson := CopyStr(CleanedJson, 2, StrLen(CleanedJson) - 2);

        exit(CleanedJson);
    end;

    procedure getRecordValue(partnerCode: Code[20]; system: Code[20]; interfaceContract: Code[20]; interfaceContractVersion: Code[20]; type: Code[20]; payloadType: Code[20]; payload: Text): Text
    var
        ErrorHandler: Codeunit "GXL Error Handler";
        Base64: Codeunit "Base64 Convert";
        APILog: Record "GXL API Log";
        RequestLogEntryNo: Integer;
        RequestEntryNo: Integer;
        RespEntryNo: Integer;
        IntVariant: Variant;
        jsonText: Text;
    begin

        jsonText := Base64.FromBase64(payload);

        RequestLogEntryNo := InsertApiLog(RequestEntryNo, "GXL API Log Type"::Request, '', 0, "GXL API Action"::Get, partnerCode, system, interfaceContract, interfaceContractVersion, type, payloadType);
        InsertEncrptAttachment(RequestLogEntryNo, payload);
        InsertApiAttachment(RequestLogEntryNo, jsonText);
        Commit();
        IntVariant := RequestLogEntryNo;
        ErrorHandler.SetDef('GetRequestRecord', IntVariant, jsonText);
        if not ErrorHandler.Run() then begin
            APILog.Get(RequestLogEntryNo);
            APILog."GXL Status" := APILog."GXL Status"::Error;
            APILog.Modify();
            RespEntryNo := InsertApiLog(RequestLogEntryNo, "GXL API Log Type"::Response, APILog."GXL Function", 0, "GXL API Action"::Get, partnerCode, system, interfaceContract, interfaceContractVersion, type, payloadType);
            exit(GetLastErrorText)
        end else begin
            APILog.Get(RequestLogEntryNo);
            APILog."GXL Status" := APILog."GXL Status"::Processed;
            APILog.Modify();
            RespEntryNo := InsertApiLog(RequestLogEntryNo, "GXL API Log Type"::Response, APILog."GXL Function", 0, "GXL API Action"::Get, partnerCode, system, interfaceContract, interfaceContractVersion, type, payloadType);
            InsertApiAttachment(RespEntryNo, ErrorHandler.GetResposeJson());
            exit(ErrorHandler.GetResposeJson());
        end;
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeSetFieldValue(TableNo: Integer; FieldNo: Integer; var FieldValue: Text; var SkipField: Boolean; var Validate: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterSetFieldValue(TableNo: Integer; FieldNo: Integer; FieldValue: Text)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnBeforeRecordUpsert(var RecRef: RecordRef; IsInsert: Boolean; var IsHandled: Boolean; var InsertTrigger: Boolean; var ModifyTrigger: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterRecordUpsert(var RecRef: RecordRef; IsInsert: Boolean)
    begin
    end;

}
