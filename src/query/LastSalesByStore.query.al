query 50008 "GXL Last Sales By Store"
{
    QueryType = Normal;
    Caption = 'Last Sales By Store';

    elements
    {
        dataitem(TransSalesEntry; "LSC Trans. Sales Entry")
        {
            column(StoreCode; "Store No.")
            {
            }
            column(ItemNo; "Item No.")
            {
            }
            column(Quantity; Quantity)
            {
                Method = Sum;
                ReverseSign = true;
            }
            filter(TransDate; Date)
            {
            }
        }
    }

    var

    trigger OnBeforeOpen()
    begin

    end;
}