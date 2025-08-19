pageextension 50271 "GXL StoreInv. Worksheet Buffer" extends "LSC Store Inv. Wrksh. Buffer"
{
    layout
    {
        addafter(EntryNo)
        {
            field("GXL StockTake Description"; Rec."GXL StockTake Description")
            { ApplicationArea = All; }
            field("GXL No. of Stock Take Lines"; Rec."GXL No. of Stock Take Lines")
            { ApplicationArea = All; }
            field("GXL Date Opened"; Rec."GXL Date Opened")
            { ApplicationArea = All; }
            field("GXL User ID"; Rec."GXL User ID")
            { ApplicationArea = All; }
        }
    }

    actions
    {
        addafter(ProcessGrp)
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
                        StoreInvWorksheet: Record "LSC Store Inventory Worksheet";
                        ClearStockTakeConfirmQst: Label 'Do you want to Clear the StockTake Data?';
                    begin
                        IF Confirm(ClearStockTakeConfirmQst) then begin
                            PDAStockTakeLines.Reset();
                            PDAStockTakeLines.SetRange("Stock-Take ID", Rec.WorksheetSeqNo);
                            PDAStockTakeLines.DeleteAll();
                            if StoreInvWorksheet.Get(rec.WorksheetSeqNo) then begin
                                StoreInvWorksheet."GXL Date Opened" := 0D;
                                StoreInvWorksheet."GXL StockTake Description" := '';
                                StoreInvWorksheet."GXL User ID" := '';
                                StoreInvWorksheet.Modify();
                            end;
                            Rec."GXL Date Opened" := 0D;
                            Rec."GXL StockTake Description" := '';
                            Rec."GXL User ID" := '';
                            Rec.Modify();
                        end;
                    end;
                }
            }
        }
    }

    var

}