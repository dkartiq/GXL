/// <summary>
/// PS-2523 VET Clinic transfer order
/// </summary>
table 50033 "GXL VET Store"
{
    Caption = 'VET Store';
    DataClassification = CustomerContent;
    LookupPageId = "GXL VET Stores";
    DrillDownPageId = "GXL VET Stores";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Name; Text[100])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(DropDown; Code, Name)
        { }
        fieldgroup(Brick; Code, Name)
        { }
    }

    var

    trigger OnInsert()
    begin

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