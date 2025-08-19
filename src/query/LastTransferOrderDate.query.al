query 50001 "GXL Last Transfer Order Date"
{
    Caption = 'Last Transfer Order Date';
    QueryType = Normal;
    OrderBy = descending(OrderDate);

    elements
    {
        dataitem(Transfer_Line; "Transfer Line")
        {
            DataItemTableFilter = Quantity = filter('>0'), "Derived From Line No." = filter('=0');
            column(ItemNo; "Item No.")
            {
            }
            column(TransfertoCode; "Transfer-to Code")
            {
            }
            column(ReceiptDate; "Receipt Date")
            {
            }
            dataitem(Transfer_Header; "Transfer Header")
            {
                //TODO: Order Status
                //DataItemTableFilter = "GXL Order Status" = const(Confirmed);
                DataItemTableFilter = Status = filter(Released);
                DataItemLink = "No." = Transfer_Line."Document No.";
                SqlJoinType = InnerJoin;

                column(OrderDate; "GXL Order Date")
                {
                }
            }
        }
    }


    trigger OnBeforeOpen()
    begin

    end;
}