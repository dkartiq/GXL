table 50014 "GXL Sub-Category 4"
{
    Caption = 'Sub-Category 4';
    DrillDownPageID = "GXL Sub-Category 4 List";
    LookupPageID = "GXL Sub-Category 4 List";
    DataClassification = CustomerContent;
    fields
    {
        field(1; "Code"; Code[40])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[30])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "MPL Factor"; Integer)
        {
            Caption = 'MPL Factor';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                UpdateMPLFac: Report "GXL Update MPL Factor";
            begin
                CLEAR(UpdateMPLFac);
                UpdateMPLFac.USEREQUESTPAGE(FALSE);
                UpdateMPLFac.SetCallFrom(5, xRec."MPL Factor", Rec."MPL Factor", Code);
                UpdateMPLFac.RUNMODAL();
            end;
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

    trigger OnModify()
    begin
    end;

}

