report 50003 "GXL Update Items"
{
    Caption = 'Update Items';
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";
            trigger OnPreDataItem()
            begin
                Clear(UpdateItems);
                UpdateItems.Run(Item);
                Commit();
                CurrReport.Break();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
            }
        }

    }

    var
        UpdateItems: Codeunit "GXL Update Items";
}