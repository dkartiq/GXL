report 50040 "Re-Submit Bloyal Sales"
{
    ApplicationArea = All;
    Caption = 'Re-Submit Bloyal Sales';
    UsageCategory = Administration;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Integer; Integer)
        {
            DataItemTableView = SORTING(Number) WHERE(Number = CONST(1));

            trigger OnPreDataItem()
            var
                BloyalSalesPayment: codeunit "GXL Bloyal Sales & Payment";
            begin
                BloyalSalesPayment.ReSendTransaction(true);
                Commit();
                CurrReport.Break();
            end;
        }
    }
}
