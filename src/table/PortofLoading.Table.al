table 50384 "GXL Port of Loading"
{
    Caption = 'Port of Loading';
    DrillDownPageID = "GXL Port of Loading List";
    LookupPageID = "GXL Port of Loading List";

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
        }
        field(3; "Port Type"; Option)
        {
            Caption = 'Port Type';
            OptionCaption = 'Arrival,Departure';
            OptionMembers = Arrival,Departure;
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
}

