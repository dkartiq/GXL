pageextension 50028 "GXL PhysInventoryLedgerEntries" extends "Phys. Inventory Ledger Entries"
{
    layout
    {
        //PS-2393+
        modify(Quantity)
        {
            Visible = false;
        }
        modify(Amount)
        {
            Visible = false;
        }
        addafter(Quantity)
        {
            field("GXL Item Ledger Quantity"; Rec."GXL Item Ledger Quantity")
            {
                ApplicationArea = All;
            }
        }
        addafter(Amount)
        {
            field("GXL Item Ledger Amount"; Rec."GXL Item Ledger Amount")
            {
                ApplicationArea = All;
            }
        }
        addlast(Control1)
        {
            field("GXL Standard Cost Amount"; Rec."GXL Standard Cost Amount")
            {
                ApplicationArea = All;
            }
            field("GXL Stocktake Name"; Rec."GXL Stocktake Name")
            {
                ApplicationArea = All;
            }
            field("GXL MIM User ID"; Rec."GXL MIM User ID")
            {
                ApplicationArea = All;
            }
        }
        //PS-2393-
    }

}