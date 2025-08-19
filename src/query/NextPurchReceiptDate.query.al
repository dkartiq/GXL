query 50004 "GXL Next Purch Receipt Date"
{
    Caption = 'Next Purchase Receipt Date';
    QueryType = Normal;
    OrderBy = ascending(ExpectedReceiptDate);

    elements
    {
        dataitem(Purchase_Line; "Purchase Line")
        {
            //TODO: Order Status
            //DataItemTableFilter = "Document Type" = const(Order), Type = const(Item), "GXL Confirmed Quantity" = filter('>0');
            DataItemTableFilter = "Document Type" = const(Order), Type = const(Item), Quantity = filter('>0');

            column(ItemNo; "No.")
            {
            }
            column(LocationCode; "Location Code")
            {
            }
            column(ExpectedReceiptDate; "Expected Receipt Date")
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