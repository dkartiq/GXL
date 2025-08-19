table 50379 "GXL EDI Claim Entry"
{
    Caption = 'EDI Claim Entry';

    fields
    {
        field(1; "ASN Document Type"; Option)
        {
            Caption = 'ASN Document Type';
            OptionCaption = 'Purchase,Transfer';
            OptionMembers = Purchase,Transfer;
        }
        field(2; "ASN Document No."; Code[20])
        {
            Caption = 'ASN Document No.';
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'ILC';
            TableRelation = Item;
        }
        field(5; GTIN; Code[50])
        {
            Caption = 'GTIN';
        }
        field(6; "Confirmed Quantity"; Decimal)
        {
            Caption = 'Confirmed Quantity';
        }
        field(7; "Scanned Quantity"; Decimal)
        {
            Caption = 'Scanned Quantity';
        }
        field(8; "Claim Document No."; Code[20])
        {
            Caption = 'Claim Document No.';
        }
        field(9; "Claim Document Line No."; Integer)
        {
            Caption = 'Claim Document Line No.';
        }
        field(10; "Posted Return Shipment No."; Code[20])
        {
            TableRelation = "Return Shipment Header"."No.";
        }
        field(11; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = ' ,Open,Closed';
            OptionMembers = " ",Open,Closed;
        }
        field(12; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            TableRelation = "Purchase Header"."No.";
        }
        field(13; "Purchase Order Line No."; Integer)
        {
            Caption = 'Purchase Order Line No.';
        }
        field(14; "Receipt Item Ledger Entry No."; Integer)
        {
            TableRelation = "Item Ledger Entry"."Entry No.";
        }
        field(15; "Posted Return Credit No."; Code[20])
        {
            TableRelation = "Purch. Cr. Memo Hdr."."No.";
        }
    }

    keys
    {
        key(Key1; "ASN Document No.", "ASN Document Type", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "ASN Document No.", "Item No.", "ASN Document Type")
        {
        }
        key(Key3; "Claim Document No.", "Claim Document Line No.")
        {
        }
        key(Key4; "ASN Document No.", "Purchase Order No.", "Purchase Order Line No.", "ASN Document Type", Status)
        {
        }
        key(Key5; "Purchase Order No.", "Purchase Order Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

