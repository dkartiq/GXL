table 50258 "GXL PDA-Trans Shipment Line"
{
    DataClassification = CustomerContent;
    Caption = 'PDA-Transfer Shipment Line';

    fields
    {
        field(2; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer Order No.';
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
        }
        field(6; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(7; "Shipment Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Shipment Date';
        }
        field(10; "Created by User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Created by User ID';
        }
        field(11; "Created Date-Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date-Time';
        }
        //PS-2046+
        field(200; "MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
        //PS-2411+
        field(201; Comment; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Comment';
        }
        //PS-2411-
    }

    keys
    {
        key(PK; "No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var


    trigger OnInsert()
    begin
        "Created Date-Time" := CurrentDateTime();
        "Created by User ID" := UserId();
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