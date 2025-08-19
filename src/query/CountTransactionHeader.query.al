query 50009 "GXL Count Transaction Header"
{
    Caption = 'Count Transaction Header';
    QueryType = Normal;

    elements
    {
        dataitem(Transaction_Header; "LSC Transaction Header")
        {
            column(NoOfTransactions)
            {
                Method = Count;
            }
            filter(Date; Date)
            {
            }
            filter(Store_No_; "Store No.")
            {
            }
            dataitem(Trans__Infocode_Entry; "LSC Trans. Infocode Entry")
            {
                SqlJoinType = InnerJoin;
                DataItemLink = "Store No." = Transaction_Header."Store No.", "POS Terminal No." = Transaction_Header."POS Terminal No.", "Transaction No." = Transaction_Header."Transaction No.";

                filter(Infocode; Infocode)
                { }
            }
        }
    }

    var
    //NoOfTransactions: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}