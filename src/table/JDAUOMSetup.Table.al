table 50381 "GXL JDA UOM Setup"
{
    Caption = 'JDA UOM Setup';
    DrillDownPageID = "GXL JDA UOM Setup List";
    LookupPageID = "GXL JDA UOM Setup List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(50200; "Category Code"; Code[20])
        {
            Caption = 'Category Code';
            NotBlank = true;
            TableRelation = "GXL UOM Category";
        }
        field(50201; "Singular Name"; Text[30])
        {
            Caption = 'Singular Name';
            NotBlank = true;
        }
        field(50202; "Plural Name"; Text[30])
        {
            Caption = 'Plural Name';
            NotBlank = true;
        }
        field(50203; Ratio; Decimal)
        {
            Caption = 'Ratio';
        }
        field(50224; "Last Date Modified"; Date)
        {
            Caption = 'Last Date Modified';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Code")
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

