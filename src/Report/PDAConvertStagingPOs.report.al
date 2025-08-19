report 50251 "GXL PDA-Convert Staging POs"
{
    Caption = 'PDA-Convert Staging POs';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("GXL PDA-Staging Purch. Header"; "GXL PDA-Staging Purch. Header")
        {
            DataItemTableView = sorting("Order Status") where("Order Status" = filter(Approved));

            trigger OnPreDataItem()
            begin
                NoPurchNotCreated := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                Clear(PDAStagingPurchToPurch);
                if not PDAStagingPurchToPurch.Run("GXL PDA-Staging Purch. Header") then
                    NoPurchNotCreated += 1;
                Commit();
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed() then
                    if NoPurchNotCreated > 0 then
                        Message(OrdersNotCreatedMsg, NoPurchNotCreated);
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
        PDAStagingPurchToPurch: Codeunit "GXL PDA-Staging PO-to-PO";
        NoPurchNotCreated: Integer;
        OrdersNotCreatedMsg: Label 'There are %1 purchase orders could not be created.';
}