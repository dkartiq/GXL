enum 50004 "API Message Type Selection"
{
    Extensible = true;
    
    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; all)
    {
        Caption = 'All';
    }
    value(2; stockadjustment)
    {
        Caption = 'Stock Adjustment';
    }
    value(3; stockonhand)
    {
        Caption = 'Stock On Hand';
    }
    value(4; poreceiptquantity)
    {
        Caption = 'PO Receipt Quantity';
    }
    value(5; transfershipmentquantity)
    {
        Caption = 'Transfer Shipment Quantity';
    }
    value(6; ediasnreceipt)
    {
        Caption = 'ASN Receipt';
    }
    value(7; salesorder)
    {
        Caption = 'Sales Order';
    }
}
