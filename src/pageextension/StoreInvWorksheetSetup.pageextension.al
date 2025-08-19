pageextension 50270 "GXL Store Inv. Worksheet Setup" extends "LSC Store Inv. Worksheet Setup"
{
    layout
    {
        addafter(Description)
        {
            field("GXL StockTake Description"; REC."GXL StockTake Description")
            { ApplicationArea = All; }
            field("GXL No. of Stock Take Lines"; REC."GXL No. of Stock Take Lines")
            { ApplicationArea = All; }
            field("GXL Date Opened"; REC."GXL Date Opened")
            { ApplicationArea = All; }
            field("GXL User ID"; REC."GXL User ID")
            { ApplicationArea = All; }
        }
        addafter("Default UoM")
        {
            field("GXL Change UoM Allowed"; REC."Change UoM Allowed")
            { ApplicationArea = All; }
        }
    }

    actions
    {
        addafter(Counting)
        {
            group("GXL PDAStockTake")
            {
                Caption = 'PDA Stocktake';
                action("GXL ClearStocktake")
                {
                    ApplicationArea = All;
                    Caption = 'Clear Stock Take';
                    Image = ClearLog;
                    trigger OnAction()
                    var
                        PDAStockTakeLines: Record "GXL PDA StockTake Line";
                        ClearStockTakeConfirmQst: Label 'Do you want to Clear the StockTake Data?';
                    begin
                        IF Confirm(ClearStockTakeConfirmQst) then begin
                            PDAStockTakeLines.Reset();
                            PDAStockTakeLines.SetRange("Stock-Take ID", REC.WorksheetSeqNo);
                            PDAStockTakeLines.DeleteAll();
                            REC."GXL Date Opened" := 0D;
                            REC."GXL StockTake Description" := '';
                            REC."GXL User ID" := '';
                            REC.Modify();
                        end;
                    end;
                }
            }
        }
    }

    var

}