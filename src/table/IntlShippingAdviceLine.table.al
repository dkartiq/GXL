table 50359 "GXL Intl. Shipping Advice Line"
{
    fields
    {
        field(1; "Shipping Advice No."; Code[20])
        {
            NotBlank = true;
        }
        field(2; "Line No."; Integer)
        {
        }
        field(3; "Order Line No."; Integer)
        {
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Legacy Item No.';
            //TableRelation = Item; //ERP-NAV Master Data Management +
        }
        field(5; "Quantity Shipped"; Decimal)
        {
            Caption = 'Quantity Shipped';
            DecimalPlaces = 0 : 5;
        }
        field(6; "Carton-Quantity Shipped"; Decimal)
        {
            Caption = 'Carton-Quantity Shipped';
            DecimalPlaces = 0 : 5;
        }
        field(7; "Unit of Measure Code"; Code[10])
        {
            TableRelation = "Unit of Measure";
        }
    }

    keys
    {
        key(Key1; "Shipping Advice No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

