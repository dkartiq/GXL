query 50006 "GXL Next Purchase Order Date"
{
    Caption = 'Next Purchase Order Date';
    QueryType = Normal;
    OrderBy = ascending(OrderDate);

    elements
    {
        dataitem(Purchase_Line; "Purchase Line")
        {
            DataItemTableFilter = "Document Type" = const(Order), Type = const(Item), Quantity = filter('>0');

            column(ItemNo; "No.")
            {
            }
            column(LocationCode; "Location Code")
            {
            }
            column(OrderDate; "Order Date")
            {
            }
            dataitem(Purchase_Header; "Purchase Header")
            {
                //TODO: Order Status
                //DataItemTableFilter = "GXL Order Status" = filter(Confirmed);
                DataItemTableFilter = Status = filter(Released);
                DataItemLink = "Document Type" = Purchase_Line."Document Type", "No." = Purchase_Line."Document No.";
                SqlJoinType = InnerJoin;
            }
        }
    }


    trigger OnBeforeOpen()
    begin

    end;
}