table 50022 "GXL Bloyal Product Change Log"
{
    Caption = 'Bloyal Product Change Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(3; "Log Date Time"; DateTime)
        {
            Caption = 'Log Date Time';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ItemNo; "Item No.")
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

    procedure IsProcessed(): Boolean
    var
        BloyalAzureLog: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog.SetCurrentKey("End Entry No.");
        BloyalAzureLog.SetFilter("End Entry No.", '>=%1', "Entry No.");
        BloyalAzureLog.SetRange("Web Service Name", BloyalAzureLog."Web Service Name"::Product);
        if BloyalAzureLog.IsEmpty() then
            exit(false)
        else
            exit(true);
        exit(not BloyalAzureLog.IsEmpty());
    end;
}