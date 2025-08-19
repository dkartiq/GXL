table 50154 "GXL ECS Data Template Line"
{
    Caption = 'ECS Data Template Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "ECS Data Template Code"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Data Template Code';
            TableRelation = "GXL ECS Data Template Header";
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(4; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" where("Object Type" = const(Table));

            trigger OnValidate()
            begin
                if "Table ID" <> xRec."Table ID" then begin
                    Validate("Field No.", 0);
                end;
            end;
        }
        field(5; "Table Name"; Text[250])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
            Editable = false;
        }
        field(6; "Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Field No.';
            TableRelation = Field."No." where(TableNo = field("Table ID"));

            trigger OnValidate()
            begin
                if "Field No." = 0 then begin
                    "Field Name" := '';
                    exit;
                end;

                TestField("Table ID");
                FieldRec.Get("Table ID", "Field No.");
                "Field Name" := FieldRec.FieldName;
            end;

            trigger OnLookup()
            begin
                if "Table ID" = 0 then
                    exit;

                Clear(FieldList);
                FieldRec.SetRange(TableNo, "Table ID");
                FieldList.SetTableView(FieldRec);
                FieldList.LookupMode := true;
                if FieldList.RunModal() = Action::LookupOK then begin
                    FieldList.GetRecord(FieldRec);
                    Validate("Field No.", FieldRec."No.");
                end;
            end;
        }
        field(7; "Field Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Field Name';
            Editable = false;

            trigger OnValidate()
            begin
                TemplateLine.SetRange("ECS Data Template Code", "ECS Data Template Code");
                TemplateLine.SetRange("Table ID", "Table ID");
                TemplateLine.SetRange("Field Name", "Field Name");
                if not TemplateLine.IsEmpty() then
                    Error(FieldNameSpecifiedErr, "Field Name");
            end;

            trigger OnLookup()
            begin
                if "Table ID" = 0 then
                    exit;

                Clear(FieldList);
                FieldRec.SetRange(TableNo, "Table ID");
                FieldList.SetTableView(FieldRec);
                FieldList.LookupMode := true;
                if FieldList.RunModal() = Action::LookupOK then begin
                    FieldList.GetRecord(FieldRec);
                    Validate("Field No.", FieldRec."No.");
                end;
            end;

        }
        field(15; "Send to ECS"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Send to ECS';
            InitValue = true;
        }
        field(16; "Mandatory Unique ID"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Mandatory Unique ID';
        }
        field(17; "ECS Field Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Field Name';
        }
        field(20; "Trigger Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Trigger Field No.';
            TableRelation = Field."No." where(TableNo = field("Table ID"));
        }
        field(30; "Creation Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Creation Date Time';
            Editable = false;
        }

    }

    keys
    {
        key(PK; "ECS Data Template Code", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "ECS Data Template Code", "Send to ECS")
        {

        }
    }

    var
        TemplateLine: Record "GXL ECS Data Template Line";
        FieldRec: Record Field;
        FieldList: Page "GXL Field List";
        FieldNameSpecifiedErr: Label 'Field Name %1 has already been specified on the template';

    trigger OnInsert()
    begin
        "Creation Date Time" := CurrentDateTime();
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}