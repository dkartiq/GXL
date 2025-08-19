table 50018 "GXL Private Label Type"
{
    Caption = 'Private Label Type';
    DrillDownPageID = "GXL Private Label Code";
    LookupPageID = "GXL Private Label Code";
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
        field(3; "Private Label Finance Specific"; Boolean)
        {
            Caption = 'Private Label Finance Specific';
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

