enum 50251 "GXL PDA-Order Status"
{
    Extensible = true;

    value(0; NotApproved)
    {
        Caption = 'Not Approved';
    }
    value(1; Approved)
    {
        Caption = 'Approved';
    }
    value(2; Cancelled)
    {
        Caption = 'Cancelled';
    }
}