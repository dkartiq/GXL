enum 50003 "API Message Status"
{
    Extensible = true;

    value(0; " ")
    {
        Caption = ' ';
    }
    value(1; Processing)
    {
        Caption = 'Processing';
    }
    value(2; Completed)
    {
        Caption = 'Completed';
    }
    value(3; Errored)
    {
        Caption = 'Errored';
    }
}
