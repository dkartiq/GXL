query 50000 "GXL Last Purchase Order Date"
{
    Caption = 'Last Purchase Order Date';
    QueryType = Normal;
    OrderBy = descending(OrderDate);

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