/// <summary>
/// ERP-NAV Master Data Management
/// </summary>
query 50012 "GXL Purchase Order by SKU"
{
    Caption = 'Purchase Order by SKU';
    QueryType = Normal;

    elements
    {
        dataitem(Purchase_Line; "Purchase Line")
        {
            DataItemTableFilter = "Document Type" = const(Order), Type = const(Item), "Outstanding Quantity" = filter('<>0');
            column(Item_No; "No.")
            {
            }
            column(Location_Code; "Location Code")
            {
            }
            column(Outstanding_Quantity; "Outstanding Quantity")
            {
                Method = Sum;
            }
        }
    }

    var

    trigger OnBeforeOpen()
    begin

    end;
}