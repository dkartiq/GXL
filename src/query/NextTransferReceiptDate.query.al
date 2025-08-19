query 50005 "GXL Next Transfer Receipt Date"
{
    Caption = 'Next Transfer Receipt Date';
    QueryType = Normal;
    OrderBy = ascending(ExpectedReceiptDate);

    elements
    {
        dataitem(Transfer_Line; "Transfer Line")
        {
            DataItemTableFilter = "Derived From Line No." = const(0), "Qty. to Receive" = filter('>0');

            column(ItemNo; "Item No.")
            {
            }
            column(TransfertoCode; "Transfer-to Code")
            {
            }
            column(ExpectedReceiptDate; "Receipt Date")
            {
            }
            dataitem(Transfer_Header; "Transfer Header")
            {
                //TODO: Order Status
                //DataItemTableFilter = "GXL Order Status" = filter(Confirmed);
                DataItemTableFilter = Status = filter(Released);
                DataItemLink = "No." = Transfer_Line."Document No.";
                SqlJoinType = InnerJoin;
            }
        }
    }


    trigger OnBeforeOpen()
    begin

    end;
}