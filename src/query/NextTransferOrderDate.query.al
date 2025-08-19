query 50007 "GXL Next Transfer Order Date"
{
    Caption = 'Next Transfer Order Date';
    QueryType = Normal;
    OrderBy = ascending(OrderDate);

    elements
    {
        dataitem(Transfer_Line; "Transfer Line")
        {
            DataItemTableFilter = Quantity = filter('>0'), "Derived From Line No." = filter('=0');
            ;
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
                DataItemLink = "No." = Transfer_Line."Document No.";
                //TODO: Order Status
                //DataItemTableFilter = "GXL Order Status" = const(Confirmed);
                DataItemTableFilter = Status = filter(Released);
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