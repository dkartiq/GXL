tableextension 50013 "GXL Item Journal Line" extends "Item Journal Line"
{
    fields
    {
        //PS-2046+
        field(50253; "GXL MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
        //PS-2393+
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
        //PS-2393-
        field(50350; "GXL User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
        }
        field(50400; "GXL POS Adjustment"; Boolean)
        {
            Caption = 'POS Adjustment';
            DataClassification = CustomerContent;
        }
        // HP-2885+
        field(50450; "GXL Discrepancy Entry No."; Integer)
        {
            Editable = false;
            Caption = 'Discrepancy Entry No.';
            DataClassification = CustomerContent;
        }
        // HP-2885-
    }

    //PS-2393+
    procedure GXLUpdateCostAmount()
    var
        Item: Record Item;
    begin
        if "Item No." <> '' then
            if Item.Get("Item No.") then
                "GXL Standard Cost Amount" := Round(Item."GXL Standard Cost" * Quantity);
    end;
    //PS-2393-
}