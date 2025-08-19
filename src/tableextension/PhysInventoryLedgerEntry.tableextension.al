tableextension 50020 "GXL PhysInventoryLedgerEntry" extends "Phys. Inventory Ledger Entry"
{
    fields
    {
        //PS-2393+
        field(50253; "GXL MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        field(50270; "GXL Standard Cost Amount"; Decimal)
        {
            Caption = 'Standard Cost Amount';
            Description = 'It is a GXL Standard Cost amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(50271; "GXL Stocktake Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Stocktake Name';
        }
        field(50272; "GXL Item Ledger Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Item Ledger Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(50273; "GXL Item Ledger Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Item Ledger Amount';
            AutoFormatType = 1;
        }
        //PS-2393-
    }

    keys
    {
        key(GXLStocktakeName; "GXL Stocktake Name") { }
    }
}