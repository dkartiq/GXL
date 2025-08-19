/// <summary>
/// CR100-BatchAdjustCostItems
/// </summary>
table 50040 "GXL Adjust Cost Item Log"
{
    Caption = 'Adjust Cost Item Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(3; "Message"; Text[250])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }
        field(4; Errored; Boolean)
        {
            Caption = 'Errored';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Start Date Time"; DateTime)
        {
            Caption = 'Start Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "End Date Time"; DateTime)
        {
            Caption = 'End Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        //ERP-278-Duplicate average cost change log +
        field(20; "Item No. Filter"; Text[250])
        {
            Caption = 'Item No. Filter';
            DataClassification = CustomerContent;
        }
        //ERP-278-Duplicate average cost change log -

    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
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