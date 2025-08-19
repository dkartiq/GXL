query 50003 "GXL Get Transfer Confirmed Qty"
{
    Caption = 'Get Transfer Confirmed Qty.';
    QueryType = Normal;

    elements
    {
        dataitem(Transfer_Line; "Transfer Line")
        {
            DataItemTableFilter = "Derived From Line No." = const(0);

            //PS-2404+
            //column(QtyToReceiveBase; "Qty. to Receive (Base)") 
            column(QtyToReceiveBase; "Outstanding Qty. (Base)")
            //PS-2404-
            {
                Method = Sum;
            }
            //PS-2404+
            //column(QtyToReceive; "Qty. to Receive")
            column(QtyToReceive; "Outstanding Quantity")
            //PS-2404-
            {
                Method = Sum;
            }
            filter(TransfertoCode; "Transfer-to Code")
            { }
            filter(ItemNo; "Item No.")
            { }
            filter(UnitofMeasureCode; "Unit of Measure Code")
            { }

            dataitem(Transfer_Header; "Transfer Header")
            {
                //TODO: Order Status
                //DataItemTableFilter = "GXL Order Status" = const(Confirmed);
                //PS-2404+
                //DataItemTableFilter = Status = filter(Released);
                DataItemTableFilter = Status = filter(Released), "Last Shipment No." = filter('<>''''');
                //PS-2404-
                DataItemLink = "No." = Transfer_Line."Document No.";
                SqlJoinType = InnerJoin;
            }
        }
    }

    var

    trigger OnBeforeOpen()
    begin

    end;
}