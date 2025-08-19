codeunit 50152 "GXL Data Template Management"
{
    trigger OnRun()
    begin

    end;

    var
        DataTemplateHeader: Record "GXL ECS Data Template Header";
        DataTemplateLine: Record "GXL ECS Data Template Line";

    procedure IsDataChanged(TemplateCode: Code[30]; Rec: Variant; xRec: Variant; UpdateType: Option "Insert","Modify","Delete") FoundEditedField: Boolean
    var
        RecRef: RecordRef;
        xRecRef: RecordRef;
        FldRef: FieldRef;
        xFldRef: FieldRef;
    begin
        FoundEditedField := false;
        DataTemplateHeader.SetRange(Code, TemplateCode);
        if not DataTemplateHeader.FindFirst() then
            exit(false);

        RecRef.GetTable(Rec);
        xRecRef.GetTable(xRec);

        DataTemplateLine.Reset();
        DataTemplateLine.SetRange("ECS Data Template Code", TemplateCode);
        DataTemplateLine.SetRange("Table ID", RecRef.Number());
        DataTemplateLine.SetRange("Send to ECS", true);
        if not DataTemplateLine.FindSet() then
            exit(false);

        if UpdateType = UpdateType::Modify then begin
            FoundEditedField := false;
            repeat
                FldRef := RecRef.Field(DataTemplateLine."Field No.");
                xFldRef := xRecRef.Field(DataTemplateLine."Field No.");

                if FldRef.Value() <> xFldRef.Value() then
                    FoundEditedField := true;

            until (DataTemplateLine.Next() = 0) or FoundEditedField;

            if not FoundEditedField then begin
                DataTemplateLine.SetFilter("Trigger Field No.", '<>0');
                if DataTemplateLine.FindSet() then
                    repeat
                        FldRef := RecRef.Field(DataTemplateLine."Trigger Field No.");
                        xFldRef := xRecRef.Field(DataTemplateLine."Trigger Field No.");

                        if FldRef.Value() <> xFldRef.Value() then
                            FoundEditedField := true;
                    until (DataTemplateLine.Next() = 0) or FoundEditedField;
            end;

            //Rec = xRec: data is updated through configuration package or via code, could not determine Rec, xRec
            if not FoundEditedField then begin
                if Format(Rec) = Format(xRec) then
                    FoundEditedField := true;
            end;
        end else
            FoundEditedField := true;

    end;

    procedure GetBloyalTemplateFields(TemplateCode: Code[30]; TableId: Integer; var NameValueBuff: Record "Name/Value Buffer" temporary)
    var
        BloyalIntegrationHelpers: Codeunit "GXL Bloyal Integration Helpers";
    begin
        if TemplateCode = '' then
            exit;

        NameValueBuff.Reset();
        NameValueBuff.DeleteAll();

        DataTemplateLine.Reset();
        DataTemplateLine.SetRange("ECS Data Template Code", TemplateCode);
        DataTemplateLine.SetRange("Table ID", TableId);
        //DataTemplateLine.SetRange("Send to ECS", true);
        if DataTemplateLine.FindSet() then
            repeat
                NameValueBuff.ID := DataTemplateLine."Field No.";
                if DataTemplateLine."ECS Field Name" = '' then
                    NameValueBuff.Name := DataTemplateLine."Field Name"
                else
                    NameValueBuff.Name := DataTemplateLine."ECS Field Name";
                BloyalIntegrationHelpers.ConvertFieldCaptionToJsonFormat(NameValueBuff.Name, NameValueBuff.Value);
                if NameValueBuff.Insert() then;
            until DataTemplateLine.Next() = 0;

    end;

    //WRP-397+
    //Release 2
    procedure IsDataChangedBeforeModifyEvent(TemplateCode: Code[30]; Rec: Variant; xRec: Variant; UpdateType: Option "Insert","Modify","Delete") FoundEditedField: Boolean
    var
        RecRef: RecordRef;
        xRecRef: RecordRef;
        FldRef: FieldRef;
        xFldRef: FieldRef;
    begin
        FoundEditedField := false;
        DataTemplateHeader.SetRange(Code, TemplateCode);
        if not DataTemplateHeader.FindFirst() then
            exit(false);

        RecRef.GetTable(Rec);
        xRecRef.GetTable(xRec);

        DataTemplateLine.Reset();
        DataTemplateLine.SetRange("ECS Data Template Code", TemplateCode);
        DataTemplateLine.SetRange("Table ID", RecRef.Number());
        DataTemplateLine.SetRange("Send to ECS", true);
        if not DataTemplateLine.FindSet() then
            exit(false);

        if UpdateType = UpdateType::Modify then begin
            FoundEditedField := false;
            repeat
                FldRef := RecRef.Field(DataTemplateLine."Field No.");
                xFldRef := xRecRef.Field(DataTemplateLine."Field No.");

                if FldRef.Value() <> xFldRef.Value() then
                    FoundEditedField := true;

            until (DataTemplateLine.Next() = 0) or FoundEditedField;

            if not FoundEditedField then begin
                DataTemplateLine.SetFilter("Trigger Field No.", '<>0');
                if DataTemplateLine.FindSet() then
                    repeat
                        FldRef := RecRef.Field(DataTemplateLine."Trigger Field No.");
                        xFldRef := xRecRef.Field(DataTemplateLine."Trigger Field No.");

                        if FldRef.Value() <> xFldRef.Value() then
                            FoundEditedField := true;
                    until (DataTemplateLine.Next() = 0) or FoundEditedField;
            end;

        end else
            FoundEditedField := true;

    end;
    //WRP-397-
}