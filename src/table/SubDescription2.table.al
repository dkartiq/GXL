table 50017 "GXL Sub-Description 2"
{
    Caption = 'Sub-Description 2 List';
    DrillDownPageID = "GXL Sub-Description 2 List";
    LookupPageID = "GXL Sub-Description 2 List";
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
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
        fieldgroup(Dropdown; Code, Description)
        { }
    }
}

