table 50142 "GXL NAV Confirmed Order Line"
{
    /*Change Log
        ERP-NAV Master Data Management: Added fields
    */

    DataClassification = CustomerContent;
    Caption = 'NAV Confirmed Order Line';

    fields
    {
        field(1; "Document Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';
            OptionMembers = "Purchase","Transfer";
            OptionCaption = 'Purchase,Transfer';
        }
        field(3; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(4; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(5; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            OptionMembers = " ","G/L Account",Item,,"Fixed Asset","Charge (Item)";
            OptionCaption = ' ,G/L Account,Item,,Fixed Asset,Charge (Item)';
        }
        field(6; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(10; "Expected Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Receipt Date';
        }
        field(11; Description; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(15; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(22; "Direct Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Direct Unit Cost';
            AutoFormatType = 2;
            AutoFormatExpression = "Currency Code";
        }
        field(27; "Line Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Discount %';
            DecimalPlaces = 0 : 5;
        }
        field(28; "Line Discount Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Discount Amount';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
        }
        field(29; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
        }
        field(30; "Amount Including VAT"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount Including GST';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
        }
        //ERP-NAV Master Data Management +
        field(34; "Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(37; Cubage; Decimal)
        {
            Caption = 'Cubage';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        //ERP-NAV Master Data Management -
        field(91; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
        }
        field(103; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Amount';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
        }
        field(50209; "Confirmed Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Confirmed Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(50214; "Carton-Qty"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Carton-Qty';
            DecimalPlaces = 0 : 5;
        }
        field(50291; ConfirmedQtyVar; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'ConfirmedQtyVar';
        }
        field(50293; "Vendor Reorder No"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Reorder No';
        }
        field(50294; "Primary EAN"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary EAN';
        }
        field(50353; "Confirmed Direct Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Confirmed Direct Unit Cost';
            AutoFormatType = 2;
            AutoFormatExpression = "Currency Code";
        }
        field(50400; "OP Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'OP Unit of Measure Code';
        }
        field(50401; "Vendor OP Reorder No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor OP Reorder No.';
        }
        // >> HP2-Sprint2

        field(50295; "GXL OM GTIN"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'OM GTIN';
        }

        field(50296; "GXL OP GTIN"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'OP GTIN';
        }

        field(50297; "GXL Pallet GTIN"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Pallet GTIN';
        }
        // << HP2-Sprint2
        field(70000; "Replication Counter"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Replication Counter';
        }
        field(70001; "Real Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
        }
        field(70002; "Real Item UOM"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Item UOM Code';
        }
        //ERP-328 +
        field(70003; "Version No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Version No.';
        }
        //ERP-328 -
    }

    keys
    {
        key(PK; "Document Type", "Document No.", "Version No.", "Line No.")
        {
            //ERP-328 + Added Version No. to key
            Clustered = true;
        }
        key(ReplicationCounter; "Replication Counter")
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