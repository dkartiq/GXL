codeunit 50266 "GXL PDA StockAdj Job Queue Mgt"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ClearBuffer();
        MoveBuffer();
        ProcessNonClaimable();
        ProcessClaimable();
    end;

    var
        ProcessWhat: Enum "GXL Stock Adj. Process Step";


    local procedure ClearBuffer()
    var
        StockAdjustmentProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
    begin
        ProcessWhat := ProcessWhat::"Clear Buffer";
        StockAdjustmentProcessMgt.SetOptions(ProcessWhat);
        StockAdjustmentProcessMgt.Run();
    end;

    local procedure MoveBuffer()
    var
        StockAdjustmentProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
    begin
        ProcessWhat := ProcessWhat::"Move To Processing Buffer";
        StockAdjustmentProcessMgt.SetOptions(ProcessWhat);
        StockAdjustmentProcessMgt.Run();
    end;

    ///<Summary>
    ///Process claimable PDA Stock Adjustment Processing Buffer
    ///</Summary>
    local procedure ProcessClaimable()
    begin
        ValidateClaim();
        CreateClaim();
        ApplyReturnOrder();
        PostReturnShipment();
        PostReturnCredit();
        ShipTransfer();
        ReceiveTransfer();
        PostJournal();
    end;

    local procedure ValidateClaim()
    var
        StockAdjustmentProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
    begin
        ProcessWhat := ProcessWhat::Validate;
        StockAdjustmentProcessMgt.SetOptions(ProcessWhat);
        StockAdjustmentProcessMgt.Run();
    end;

    local procedure CreateClaim()
    var
        StockAdjustmentProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
    begin
        // Creates Return Order, Credit Memo or Transfer Order
        ProcessWhat := ProcessWhat::"Create Claim Document";
        StockAdjustmentProcessMgt.SetOptions(ProcessWhat);
        StockAdjustmentProcessMgt.Run();
    end;

    local procedure ApplyReturnOrder()
    var
        StockAdjustmentProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
    begin
        ProcessWhat := ProcessWhat::"Apply Return Order";
        StockAdjustmentProcessMgt.SetOptions(ProcessWhat);
        StockAdjustmentProcessMgt.Run();
    end;

    local procedure PostReturnShipment()
    var
        StockAdjustmentProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
    begin
        ProcessWhat := ProcessWhat::"Post Return Shipment";
        StockAdjustmentProcessMgt.SetOptions(ProcessWhat);
        StockAdjustmentProcessMgt.Run();
    end;

    local procedure PostReturnCredit()
    var
        StockAdjustmentProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
    begin
        ProcessWhat := ProcessWhat::"Post Return Credit";
        StockAdjustmentProcessMgt.SetOptions(ProcessWhat);
        StockAdjustmentProcessMgt.Run();
    end;

    procedure ShipTransfer()
    var
        StockAdjustmentProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
    begin
        ProcessWhat := ProcessWhat::"Ship Transfer";
        StockAdjustmentProcessMgt.SetOptions(ProcessWhat);
        StockAdjustmentProcessMgt.Run();
    end;

    procedure ReceiveTransfer()
    var
        StockAdjustmentProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
    begin
        ProcessWhat := ProcessWhat::"Receive Transfer";
        StockAdjustmentProcessMgt.SetOptions(ProcessWhat);
        StockAdjustmentProcessMgt.Run();
    end;

    procedure PostJournal()
    var
        StockAdjustmentProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
    begin
        ProcessWhat := ProcessWhat::"Post Journal";
        StockAdjustmentProcessMgt.SetOptions(ProcessWhat);
        StockAdjustmentProcessMgt.Run();
    end;

    ///<Summary>
    ///Process all the non-claimable PDA Stock Adjustment Processing Buffer
    /// to create inventory adjustment
    ///</Summary>
    local procedure ProcessNonClaimable()
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer";
        PDAStockAdjBufferProcessMgt: Codeunit "GXL PDA Stock Adj Buff Process";
        MiscUltilities: Codeunit "GXL Misc. Utilities";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
    begin
        PDAStockAdjProcessingBuffer.SetCurrentKey(Errored, Processed);
        PDAStockAdjProcessingBuffer.SetRange(Errored, false);
        PDAStockAdjProcessingBuffer.SetRange(Processed, false);
        PDAStockAdjProcessingBuffer.SetRange(Status, PDAStockAdjProcessingBuffer.Status::" ");
        PDAStockAdjProcessingBuffer.SetRange("Claim-to Document Type", PDAStockAdjProcessingBuffer."Claim-to Document Type"::" ");
        PDAStockAdjProcessingBuffer.SetFilter("Claim-to Order No.", '%1', '');
        if PDAStockAdjProcessingBuffer.FindSet() then
            repeat

                ClearLastError();

                Commit();

                if not PDAStockAdjBufferProcessMgt.Run(PDAStockAdjProcessingBuffer) then begin
                    //if locking error or item ledger entry already exists error then allow it to be processed in the next run
                    //if not MiscUltilities.IsLockingError(GetLastErrorCode()) then begin //PS-2640 -
                    if not MiscUltilities.IsLockingError(GetLastErrorCode(), GetLastErrorText()) then begin //PS-2640 +

                        PDAStockAdjProcessingBuffer2.Get(PDAStockAdjProcessingBuffer."Entry No.");
                        PDAStockAdjProcessingBuffer2.Errored := true;
                        PDAStockAdjProcessingBuffer2."Error Code" := COPYSTR(GetLastErrorCode(), 1, MAXSTRLEN(PDAStockAdjProcessingBuffer2."Error Code"));
                        PDAStockAdjProcessingBuffer2."Error Message" := COPYSTR(GetLastErrorText(), 1, MAXSTRLEN(PDAStockAdjProcessingBuffer2."Error Message"));
                        PDAStockAdjProcessingBuffer2.Narration := PDAStockAdjProcessingBuffer2."Error Message"; // >> LCB-239 <<
                        PDAStockAdjProcessingBuffer2.Modify();

                        Commit();

                        //PS-2210+
                        //Error(GetLastErrorCode() + ' - ' + GetLastErrorText()); //this triggers emailing of Job Queue Entry
                        if MiscUltilities.IsErrorEmailRequired(false, GetLastErrorCode()) then
                            EDIEmailMgt.SendStockAdjustmentFailureEmail(16, PDAStockAdjProcessingBuffer2, GetLastErrorText());
                        //PS-2210-

                    end;

                end else begin

                    PDAStockAdjProcessingBuffer2.Get(PDAStockAdjProcessingBuffer."Entry No.");
                    if not PDAStockAdjProcessingBuffer2.Errored then begin
                        PDAStockAdjProcessingBuffer2.Processed := true;
                        PDAStockAdjProcessingBuffer2.Modify();
                        Commit();
                    end;
                end;

            until PDAStockAdjProcessingBuffer.Next() = 0;

    end;

    /*
    local procedure ImportMissingOfflineTransactions()
    begin
    ImportMissingOfflineTransactions.Run();
    end;
    */
}