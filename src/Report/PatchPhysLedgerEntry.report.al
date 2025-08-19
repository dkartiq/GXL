//PS-2393-Patch to update new fields
report 50011 "GXL Patch PhysLedgerEntry"
{
    UsageCategory = Administration;
    ApplicationArea = All;
    Permissions = tabledata "Phys. Inventory Ledger Entry" = m;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Phys. Inventory Ledger Entry"; "Phys. Inventory Ledger Entry")
        {
            trigger OnPreDataItem()
            begin
            end;

            trigger OnAfterGetRecord()
            var
                Item: Record Item;
            begin
                if "Entry Type" = "Entry Type"::"Negative Adjmt." then begin
                    "GXL Item Ledger Quantity" := -Quantity;
                    "GXL Item Ledger Amount" := -Amount;
                end else begin
                    "GXL Item Ledger Quantity" := Quantity;
                    "GXL Item Ledger Amount" := Amount;
                end;
                if Item.Get("Item No.") then begin
                    "GXL Standard Cost Amount" := Round("GXL Item Ledger Quantity" * Item."GXL Standard Cost", 0.01);
                end;
                Modify();

            end;
        }
    }


}