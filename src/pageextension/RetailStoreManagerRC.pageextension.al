pageextension 50011 "GXL Retail Store Manager RC" extends "LSC Rtl Store Mgr Role Cent"
{
    layout
    {
    }

    actions
    {
        modify(Items)
        {
            Visible = false;
        }
        addafter(Items)
        {
            action("GXL GXLRetailItem")
            {
                Caption = 'Items';
                ApplicationArea = All;
                Image = Document;
                RunObject = page "LSC Retail Item List";
            }
            //PS-2493+
            action("GXL GXLRetailItemSOHPriceList")
            {
                Caption = 'Items (Incld SOH and Price)';
                ApplicationArea = All;
                Image = Document;
                RunObject = page "GXL Retail Item List-SOHPrice";
            }
            //PS-2493-
            //ERP-295 +
            action("GXL GXLPurchaseTransferOrders")
            {
                Caption = 'Open Purchase/Transfer Orders';
                ApplicationArea = All;
                Image = Documents;
                RunObject = page "GXL Purchase/Transfer Orders";
            }
            //ERP-295 -
        }

        addafter("<Action1100409005>")
        {
            action("GXL GXLItemList")
            {
                Caption = 'Negative Stock Report';
                ApplicationArea = All;
                Image = Item;
                RunObject = page "GXL Negative Stock";
            }
            action("GXL GXLTopList")
            {
                Caption = 'Top List';
                ApplicationArea = All;
                Image = Sales;
                RunObject = page "GXL Toplist Card";
            }
            action("GXL GXLHourlySalesReport")
            {
                Caption = 'Hourly Sales Report';
                ApplicationArea = All;
                Image = Sales;
                RunObject = page "GXL Hourly Store Sales";
            }
            action("GXL GXLAverageBasketSize")
            {
                Caption = 'Average Basket size';
                ApplicationArea = All;
                Image = Sales;
                RunObject = report "GXL Average Basket size";
            }
            action("GXL GXLItemLedgerEntries")
            {
                Caption = 'Item Ledger Entries';
                ApplicationArea = All;
                Image = ItemLedger;
                RunObject = page "GXL Item Ledger Entries";
            }
            //PS-2393+
            action("GXL GXLStocktakeSummary")
            {
                Caption = 'Committed Stocktake';
                ApplicationArea = All;
                Image = PhysicalInventory;
                RunObject = page "GXL Stocktake Summary";
            }
            //PS-2393-
            //PS-2400+
            action("GXL GXLDetailedSales")
            {
                Caption = 'Detailed Sales Report';
                ApplicationArea = All;
                Image = PhysicalInventory;
                RunObject = page "GXL Detailed Sales Report";
            }
            action("GXL GXLInventoryAdjmtShringae")
            {
                Caption = 'Inventory Adjustment Report/Shrink';
                ApplicationArea = All;
                Image = PhysicalInventory;
                RunObject = page "GXL InventoryAdj Report/Shrink";
            }
            //PS-2400-
        }
    }

}