table 50382 "GXL UOM Category"
{
    Caption = 'UOM Category';
    DrillDownPageID = "GXL UOM Category List";
    LookupPageID = "GXL UOM Category List";

    fields
    {
        field(1; "Category Code"; Code[10])
        {
            Caption = 'Category Code';
            NotBlank = true;
        }
        field(2; Description; Text[50])
        {
            Caption = 'Description';
            NotBlank = true;
        }
        field(3; "Standard UOM Code"; Code[10])
        {
            Caption = 'Standard UOM Code';
            TableRelation = "GXL JDA UOM Setup";
        }
        field(4; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Category Code")
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
}

