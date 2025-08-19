table 50254 "GXL PDA-Purchase Lines"
{
    DataClassification = CustomerContent;
    Caption = 'PDA-Purchase Lines';

    fields
    {
        field(3; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(2; "Entry Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry Type';
            OptionMembers = Purchase,Transfer,Adjustment;
            OptionCaption = 'Purchase,Transfer,Adjustment';
        }
        field(4; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(6; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
        }
        field(7; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(8; QtyOrdered; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'QtyOrdered';
            DecimalPlaces = 0 : 5;
        }
        field(9; QtyToReceive; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'QtyToReceive';
            DecimalPlaces = 0 : 5;
        }
        field(10; ReasonCode; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'ReasonCode';
        }
        field(11; InvoiceQuantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'InvoiceQuantity';
            DecimalPlaces = 0 : 5;
        }
        field(12; "Entry Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry Date Time';
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
        }
        field(14; "Store Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Code';
        }
        //PS-2046+
        field(200; "MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    var


    trigger OnInsert()
    begin
        "Entry Date Time" := CurrentDateTime();
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