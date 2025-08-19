/// <summary>
/// PS-2393: Committed Stocktake Summary
/// </summary>
query 50010 "GXL Stocktake Summary"
{
    Caption = 'Stocktake Summary';
    QueryType = Normal;

    elements
    {
        dataitem(PhysInventoryLedgerEntry; "Phys. Inventory Ledger Entry")
        {
            column(DocumentNo; "Document No.")
            {
            }
            column(PostingDate; "Posting Date")
            {
            }
            column(LocationCode; "Location Code")
            {
            }
            column(StocktakeName; "GXL Stocktake Name")
            {
            }
            column(ItemLedgerQuantity; "GXL Item Ledger Quantity")
            {
                Method = Sum;
            }
            column(ItemLedgerAmount; "GXL Item Ledger Amount")
            {
                Method = Sum;
            }
            column(StandardCostAmount; "GXL Standard Cost Amount")
            {
                Method = Sum;
            }
            filter(DocumentNoFilter; "Document No.")
            { }
            filter(PostingDateFilter; "Posting Date")
            { }
            filter(LocationFilter; "Location Code")
            { }
            filter(StocktakeNameFilter; "GXL Stocktake Name")
            { }
        }
    }

    var

    trigger OnBeforeOpen()
    begin

    end;
}