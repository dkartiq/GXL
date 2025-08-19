table 50369 "GXL 3Pl File Setup"
{
    Caption = '3Pl File Setup';
    LookupPageID = "GXL 3PL File Setup";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
        }
        field(2; "Table ID"; Integer)
        {
            Caption = 'Table ID';
            NotBlank = true;
            TableRelation = AllObj."Object ID" where("Object Type" = const(Table));

            trigger OnLookup()
            begin
                ConfigValidateMgt.LookupTable("Table ID");
                IF "Table ID" <> 0 THEN
                    VALIDATE("Table ID");
            end;

            trigger OnValidate()
            begin
                IF ConfigMgt.IsSystemTable("Table ID") THEN
                    ERROR(Text001Txt, "Table ID");
            end;
        }
        field(3; "Table Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Name" WHERE("Object Type" = CONST(Table), "Object ID" = FIELD("Table ID")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(7; "Imported Date and Time"; DateTime)
        {
            Caption = 'Imported Date and Time';
            Editable = false;
        }
        field(8; "Exported Date and Time"; DateTime)
        {
            Caption = 'Exported Date and Time';
            Editable = false;
        }
        field(9; Comments; Text[250])
        {
            Caption = 'Comments';
        }
        field(10; "Created Date and Time"; DateTime)
        {
            Caption = 'Created Date and Time';
        }
        field(11; "Company Filter (Source Table)"; Text[30])
        {
            Caption = 'Company Filter (Source Table)';
            FieldClass = FlowFilter;
            TableRelation = Company;
        }
        field(12; "Table Caption"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table), "Object ID" = FIELD("Table ID")));
            Caption = 'Table Caption';
            Editable = false;
            FieldClass = FlowField;
        }
        field(13; "XML Port"; Integer)
        {
            Caption = 'XML Port';
            DataClassification = CustomerContent;
            TableRelation = AllObj."Object ID" where("Object Type" = const(XMLport));
        }
        field(14; Direction; Option)
        {
            OptionCaption = 'Inbound,Outbound';
            OptionMembers = Inbound,Outbound;
        }
        field(15; Type; Option)
        {
            OptionCaption = ',SD,WH,XD,FT,Confirmation,Invoice,3pl,ASN,PO';
            OptionMembers = ,SD,WH,XD,FT,Confirmation,Invoice,"3pl",ASN,PO;
        }
        field(16; "File Format"; Option)
        {
            OptionMembers = XML,CSV;
        }
        field(17; Frequency; Option)
        {
            OptionMembers = Immediate,Periodic;
        }
        field(18; "3PL Types"; Option)
        {
            OptionCaption = ',ALL,SD,WH,XD,FT,Cancel,ASN,International';
            OptionMembers = ,ALL,SD,WH,XD,FT,Cancel,ASN,International;
        }
    }

    keys
    {
        key(Key1; "Code", "XML Port", Direction, Type)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        ConfigValidateMgt: Codeunit "Config. Validate Management";
        ConfigMgt: Codeunit "Config. Management";
        Text001Txt: Label 'You cannot use system table %1 in the package.';
}

