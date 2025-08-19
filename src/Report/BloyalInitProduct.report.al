report 50171 "GXL Bloyal Init Product"
{
    Caption = 'Bloyal - Initialise Product';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("GXL Bloyal Date Time Modified") order(ascending);
            RequestFilterFields = "No.", "GXL Bloyal Date Time Modified";

            trigger OnAfterGetRecord()
            begin
                if GuiAllowed() then
                    Windows.Update(1, "No.");
                BloyalProduct.ProcessProduct(Item, false, true);
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

        actions
        {
            area(processing)
            {
            }
        }
    }

    var
        BloyalProduct: Codeunit "GXL Bloyal Product";
        Windows: Dialog;

    trigger OnPreReport()
    begin
        if GuiAllowed() then
            Windows.Open(
                'Initialising/Sending Products to Bloyal \\' +
                'Item No.      #1###########'
                );
    end;

    trigger OnPostReport()
    begin
        if GuiAllowed() then
            Windows.Close();
    end;
}