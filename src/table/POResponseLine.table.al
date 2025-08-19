table 50361 "GXL PO Response Line"
{
    fields
    {
        field(1; "Line No."; Integer)
        {
        }
        field(2; "PO Line No."; Integer)
        {
        }
        field(3; "Item Response Indicator"; Text[30])
        {
        }
        field(4; "Item No."; Code[20])
        {
            TableRelation = Item;
        }
        field(5; "Primary EAN"; Code[50])
        {
        }
        field(6; "Vendor Reorder No."; Code[20])
        {
        }
        field(7; Description; Text[100])
        {
        }
        field(8; OMQTY; Integer)
        {
        }
        field(9; OPQTY; Integer)
        {
        }
        field(10; Quantity; Decimal)
        {
        }
        field(11; "Carton-Qty"; Decimal)
        {
        }
        field(12; "Direct Unit Cost"; Decimal)
        {
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
        field(14; "PO Response Number"; Code[35])
        {
        }
    }

    keys
    {
        key(Key1; "PO Response Number", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

