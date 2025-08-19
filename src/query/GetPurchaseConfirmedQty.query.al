query 50002 "GXL Get Purchase Confirmed Qty"
{
    Caption = 'Get Purchase Confirmed Qty.';
    QueryType = Normal;

    elements
    {
        dataitem(Purchase_Line; "Purchase Line")
        {
            DataItemTableFilter = "Document Type" = const(Order), Type = const(Item);

            //TODO: Order Status
            //column(ConfirmedQty; "GXL Confirmed Quantity")
            column(ConfirmedQty; "Outstanding Quantity")
            {
                Method = Sum;
            }
            column(ConfirmedQtyBase; "Outstanding Qty. (Base)")
            {
                Method = Sum;
            }
            filter(LocationCode; "Location Code")
            { }
            filter(ItemNo; "No.")
            { }
            filter(UnitofMeasureCode; "Unit of Measure Code")
            { }

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

    var

    trigger OnBeforeOpen()
    begin

    end;
}