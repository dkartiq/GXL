table 50364 "GXL PO INV Line"
{
    Caption = 'PO INV Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "INV No."; Code[20])
        {
            Caption = 'Vendor Invoice Number';
            TableRelation = "GXL PO INV Header"."No.";
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line Number';
            DataClassification = CustomerContent;
        }
        field(3; "PO Line No."; Integer)
        {
            Caption = 'Line Reference';
            DataClassification = CustomerContent;
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            TableRelation = Item;
            DataClassification = CustomerContent;
        }
        field(5; "Primary EAN"; Code[50])
        {
            Caption = 'GTIN';
            DataClassification = CustomerContent;
        }
        field(6; "Vendor Reorder No."; Code[20])
        {
            Caption = 'Supplier No.';
            DataClassification = CustomerContent;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(8; OMQTY; Decimal)
        {
            Caption = 'OMQTY';
            DataClassification = CustomerContent;
        }
        field(9; OPQTY; Decimal)
        {
            Caption = 'OPQTY';
            DataClassification = CustomerContent;
        }
        field(10; "Qty. to Invoice"; Decimal)
        {
            Caption = 'Qty. to Invoice';
            DataClassification = CustomerContent;
        }
        field(11; "Direct Unit Cost"; Decimal)
        {
            Caption = 'Item Price';
            DataClassification = CustomerContent;
        }
        field(12; Amount; Decimal)
        {
            Caption = 'Line Amount Excl. VAT';
            DataClassification = CustomerContent;
        }
        field(13; "Amount Incl. VAT"; Decimal)
        {
            Caption = 'Line Amount Incl. VAT';
            DataClassification = CustomerContent;
        }
        field(14; "Unit of Measure Code"; Code[10])
        {
            Caption = 'UOM';
            TableRelation = "Unit of Measure";
            DataClassification = CustomerContent;
        }
        field(15; "Item GST Amount"; Decimal)
        {
            Caption = 'Item VAT Amount';
            DataClassification = CustomerContent;
        }
        field(16; "VAT %"; Decimal)
        {
            Caption = 'Item VAT Percentage';
            DataClassification = CustomerContent;
        }
        field(17; "Unit QTY To Invoice"; Decimal)
        {
            Caption = 'Unit QTY To Invoice';
            DataClassification = CustomerContent;
        }
        field(20; ILC; Code[20])
        {
            Caption = 'ILC';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "INV No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

