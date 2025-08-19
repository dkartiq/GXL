/// <summary>
/// ERP-NAV Master Data Management
/// </summary>
query 50011 "GXL Inventory by SKU"
{
    Caption = 'Inventory by SKU';
    QueryType = Normal;

    elements
    {
        dataitem(Item_Ledger_Entry; "Item Ledger Entry")
        {
            column(Item_No; "Item No.")
            {
            }
            column(Location_Code; "Location Code")
            {
            }
            column(Quantity; Quantity)
            {
                Method = Sum;
            }
            filter(Entry_No_Filter; "Entry No.")
            {
            }
        }
    }


    trigger OnBeforeOpen()
    begin

    end;
}