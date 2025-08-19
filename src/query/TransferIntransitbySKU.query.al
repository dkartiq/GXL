/// <summary>
/// ERP-NAV Master Data Management
/// </summary>
query 50013 "GXL Transfer In-transit by SKU"
{
    Caption = 'Transfer In-transit by SKU';
    QueryType = Normal;

    elements
    {
        dataitem(Transfer_Line; "Transfer Line")
        {
            DataItemTableFilter = "Derived From Line No." = const(0), "Qty. in Transit" = filter('<>0');
            column(Item_No; "Item No.")
            {
            }
            column(Transfer_to_Code; "Transfer-to Code")
            {
            }
            column(Qty__in_Transit; "Qty. in Transit")
            {
                Method = Sum;
            }
        }
    }



    trigger OnBeforeOpen()
    begin

    end;
}