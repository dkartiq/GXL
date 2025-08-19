/* Change Log
    PS-2400 New reports
*/
table 50026 "GXL Sales/Invt Report Buffer"
{
    Caption = 'Sales/Invt Report Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Date"; Date)
        {
            Caption = 'Date';
            DataClassification = CustomerContent;
        }
        field(3; "Staff ID"; Code[50])
        {
            Caption = 'Staff ID';
            DataClassification = CustomerContent;
        }
        field(4; "Division Code"; Code[10])
        {
            Caption = 'Division Code';
            DataClassification = CustomerContent;
        }
        field(5; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
        }
        field(6; "Reason Code"; Code[20])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
        }
        field(7; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(8; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(9; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
        }
        field(10; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            DataClassification = CustomerContent;
        }
        field(11; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            DataClassification = CustomerContent;
        }
        field(12; Infocode; Code[20])
        {
            Caption = 'Infocode';
            DataClassification = CustomerContent;
        }
        field(13; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Transaction,Division,Category,Item,Staff,"Reason Code";
            OptionCaption = ' ,Transaction,Division,Category,Item,Staff,Reason Code';
        }
        field(14; "Code"; Code[50])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(15; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(16; "Staff Name"; Text[50])
        {
            Caption = 'Staff Name';
            DataClassification = CustomerContent;
        }
        field(17; Division; Text[50])
        {
            Caption = 'Division';
            DataClassification = CustomerContent;
        }
        field(18; "Item Category"; Text[100])
        {
            Caption = 'Item Category';
            DataClassification = CustomerContent;
        }
        field(19; "Subcode Description"; Text[100])
        {
            Caption = 'Subcode Description';
            DataClassification = CustomerContent;
        }
        field(20; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(21; "Net Amount"; Decimal)
        {
            Caption = 'Net Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(22; Price; Decimal)
        {
            Caption = 'Price';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
        }
        field(23; "Discount Amount"; Decimal)
        {
            Caption = 'Discount Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(24; "GST Amount"; Decimal)
        {
            Caption = 'GST Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(25; "Cost Amount"; Decimal)
        {
            Caption = 'Cost Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(30; "Date Filter"; Date)
        {
            Caption = 'Date Filter';
            FieldClass = FlowFilter;
        }
        field(31; "Store Filter"; Code[10])
        {
            Caption = 'Store Filter';
            FieldClass = FlowFilter;
            TableRelation = "LSC Store";
        }
        field(32; "Item Category Filter"; Code[20])
        {
            Caption = 'Item Category Filter';
            FieldClass = FlowFilter;
            TableRelation = "Item Category";
        }
        field(33; "Item Filter"; Code[20])
        {
            Caption = 'Item Filter';
            FieldClass = FlowFilter;
            TableRelation = Item;
        }
        field(40; "Total Net Amount"; Decimal)
        {
            Caption = 'Total Net Amount';
            FieldClass = FlowField;
            CalcFormula = - Sum("LSC Trans. Sales Entry"."Net Amount" where(
                Date = field("Date Filter"),
                "Store No." = field("Store Filter"),
                "Item Category Code" = field(filter("Item Category Filter")),
                "Item No." = field("Item Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
        field(41; "Total Discount Amount"; Decimal)
        {
            Caption = 'Total Discount Amount';
            FieldClass = FlowField;
            CalcFormula = - Sum("LSC Trans. Sales Entry"."Discount Amount" where(
                Date = field("Date Filter"),
                "Store No." = field("Store Filter"),
                "Item Category Code" = field(filter("Item Category Filter")),
                "Item No." = field("Item Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
        field(42; "Total GST Amount"; Decimal)
        {
            Caption = 'Total GST Amount';
            FieldClass = FlowField;
            CalcFormula = - Sum("LSC Trans. Sales Entry"."VAT Amount" where(
                Date = field("Date Filter"),
                "Store No." = field("Store Filter"),
                "Item Category Code" = field(filter("Item Category Filter")),
                "Item No." = field("Item Filter")));
            Editable = false;
            AutoFormatType = 1;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Type; Type, Code) { }
        key(Division; "Division Code") { }
        key(ItemCat; "Item Category Code") { }
        key(ItemNo; "Item No.") { }
        key(StaffID; "Staff ID") { }
        key(NetAmount; "Net Amount") { }
        key(DiscAmount; "Discount Amount") { }
        key(Quantity; Quantity) { }
        key(CostAmount; "Cost Amount") { }
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