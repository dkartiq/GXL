report 50250 "GXL PDA-Convert Staging TOs"
{
    Caption = 'PDA-Convert Staging TOs';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("GXL PDA-Staging Trans. Header"; "GXL PDA-Staging Trans. Header")
        {
            DataItemTableView = sorting("Order Status") where("Order Status" = filter(Approved));

            trigger OnPreDataItem()
            begin
                NoTransNotCreated := 0;
            end;

            trigger OnAfterGetRecord()
            begin
                ClearLastError();
                Clear(PDAStagingTransToTrans);
                if not PDAStagingTransToTrans.Run("GXL PDA-Staging Trans. Header") then begin
                    NoTransNotCreated += 1;
                    "Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen("Error Message"));
                    Modify();
                end;
                Commit();
            end;

            trigger OnPostDataItem()
            begin
                if GuiAllowed() then
                    if NoTransNotCreated > 0 then
                        Message(OrdersNotCreatedMsg, NoTransNotCreated);
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
        PDAStagingTransToTrans: Codeunit "GXL PDA-Staging TO-to-TO";
        NoTransNotCreated: Integer;
        OrdersNotCreatedMsg: Label 'There are %1 transfer orders could not be created.';
}