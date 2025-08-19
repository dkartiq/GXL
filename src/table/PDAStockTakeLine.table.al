// 001  19.12.2024 KDU https://petbarnjira.atlassian.net/browse/HP-2914
table 50265 "GXL PDA StockTake Line"
{
    DataClassification = CustomerContent;
    Caption = 'PDA StockTake';

    fields
    {
        field(1; "Stock-Take ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Stock-Take ID';
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(3; "Store Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Code';
            TableRelation = "LSC Store";
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(5; UOM; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'UOM';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
        field(6; "Physical Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Physical Quantity';
        }
        field(7; "Reson Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Reson Code';
        }
        field(8; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(9; SOH; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'SOH';
        }
        field(10; "Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Unit Cost';
        }
        field(11; "Item Description"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Item Description';
        }
        field(12; Barcode; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Barcode';
        }
        field(13; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor No.';
        }
        field(14; "Vendor Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Name';
        }
        field(15; Overwrite; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Overwrite';
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
        key(PK; "Stock-Take ID", "Line No.")
        {
            Clustered = true;
        }
        // >> 001
        key(key01; SystemModifiedAt)
        {

        }
        // << 001
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