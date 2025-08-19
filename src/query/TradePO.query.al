query 50014 "GXL TradePO"
{
    QueryType = Normal;

    elements
    {
        dataitem(Purchase_Line; "Purchase Line")
        {
            DataItemTableFilter = Type = const(Item);
            column(Document_No_; "Document No.") { }

            dataitem(Item; Item)
            {
                DataItemLink = "No." = Purchase_Line."No.";
                DataItemTableFilter = Type = const(Inventory);
                column(Count_)
                {
                    Method = Count;
                }
            }
        }
    }

    var
        myInt: Integer;

    trigger OnBeforeOpen()
    begin

    end;
}