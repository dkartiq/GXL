table 50251 "GXL PDA-Facing Update by Store"
{
    Caption = 'PDA-Facing Update by Store';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Store Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Code';
        }
        field(2; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
        }
        field(3; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
        }
        field(8; "Store Facing"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Store Facing';
        }
        field(9; "Cashier Number"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Cashier Number';
        }
        field(11; "Date Modified"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Date Modified';
        }
        field(20; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var

    trigger OnInsert()
    begin
        "Date Modified" := Today();
    end;

    trigger OnModify()
    begin
        "Date Modified" := Today();
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}