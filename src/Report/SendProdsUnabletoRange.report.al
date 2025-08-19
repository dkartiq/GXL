report 50005 "GXL Send Prods Unable to Range"
{
    Caption = 'Send Products Unable to Range';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Illegal Product Range Log"; "GXL Illegal Product Range Log")
        {
            trigger OnPreDataItem()
            begin

                Clear(IllegalProdRangeNotif);
                IllegalProdRangeNotif.SendUnableToRange("Illegal Product Range Log");
                CurrReport.Break();
            end;
        }
    }

    var
        IllegalProdRangeNotif: Codeunit "GXL Illegal Prod Range Notif.";

}