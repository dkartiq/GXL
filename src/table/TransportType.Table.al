table 50380 "GXL Transport Type"
{
    Caption = 'Transport Type';
    DrillDownPageID = "GXL Transport Type";
    LookupPageID = "GXL Transport Type";

    fields
    {
        field(1; "Code"; Code[30])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            NotBlank = true;
        }
        field(3; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            NotBlank = true;
            TableRelation = "Unit of Measure";

            trigger OnValidate()
            begin
                IF "Unit of Measure Code" <> '' THEN BEGIN
                    "JDA UOM Code" := '';
                    "JDA UOM Code" := GetUOMCode("Unit of Measure Code", '');
                END ELSE
                    "JDA UOM Code" := '';
            end;
        }
        field(4; "Maximum Capacity"; Decimal)
        {
            Caption = 'Maximum Capacity';
            NotBlank = true;
        }
        field(5; "Minimum Capacity"; Decimal)
        {
            Caption = 'Minimum Capacity';
        }
        field(6; "Check Capacity"; Boolean)
        {
            Caption = 'Check Capacity';
        }
        field(7; "JDA UOM Code"; Code[10])
        {
            Caption = 'JDA UOM Code';
            Editable = true;
            NotBlank = true;
            TableRelation = "GXL JDA UOM Setup";

            trigger OnValidate()
            begin
                IF "JDA UOM Code" <> '' THEN BEGIN
                    "Unit of Measure Code" := '';
                    "Unit of Measure Code" := GetUOMCode('', "JDA UOM Code");
                END ELSE
                    "Unit of Measure Code" := '';
            end;
        }
        field(8; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Code", "Unit of Measure Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Last Date Modified" := TODAY();
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := TODAY();
    end;

    [Scope('OnPrem')]
    procedure GetUOMCode(UomCode: Code[10]; JDAUom: Code[10]): Code[10]
    var
        UnitofMeasure: Record "Unit of Measure";
    begin
        EXIT(UnitofMeasure.GetUOMCode(UomCode, JDAUom));
    end;
}

