//UAT Jira issues/tasks
//PS-1386 20-05-2020 LP
// Fixed error on sync table "PDA-St Adj. Prosessing Buffer" to NAV13 ad RMS ID is mandatory and uniique
codeunit 50268 "GXL Stock Adj. Process Mgt."
{
    //"Validate and Export",Import,Validate,Process,Scan,Receive,"Create Claim Document","Apply Return Order","Post Return Shipment","Post Return Credit",
    //"Complete without Posting Return Credit","Clear Buffer","Move To Processing Buffer","Create Transfer","Ship Transfer","Receive Transfer","Post Journal";

    trigger OnRun()
    begin

        case ProcessWhat of
            ProcessWhat::"Clear Buffer":
                ClearBuffer();

            ProcessWhat::"Move To Processing Buffer":
                begin
                    //from PDA stock adjustments
                    MoveToProcessingBuffer();
                    //from WH stock adjustments for EDI 3PL 
                    MoveClaimableADJToProcessingBuffer();
                end;

            ProcessWhat::Validate:
                ValidateClaim();

            ProcessWhat::"Create Claim Document":
                CreateClaimDocument();

            ProcessWhat::"Apply Return Order":
                ApplyClaimDocument();

            ProcessWhat::"Post Return Shipment":
                PostReturnShipment();

            ProcessWhat::"Post Return Credit":
                PostReturnCredit();

            ProcessWhat::"Ship Transfer":
                ShipTransfer();

            ProcessWhat::"Receive Transfer":
                ReceiveTransfer();

            ProcessWhat::"Post Journal":
                PostJournal();
            else
                exit;
        end;
    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        ProcessWhat: Enum "GXL Stock Adj. Process Step";
        ProcessWhich: Option " ","Create Claim Document","Apply Return Order","Post Return Shipment","Post Return Credit","Ship Transfer","Receive Transfer","Post Journal";
        SetupRead: Boolean;


    procedure SetOptions(NewProcessWhat: Enum "GXL Stock Adj. Process Step")
    begin

        // 00 Validate and Export
        // 01 Import
        // 02 Validate
        // 03 Process
        // 04 Scan
        // 05 Receive
        // 06 Create Return Order (or Create Claim Document)
        // 07 Apply Return Order
        // 08 Post Return Shipment
        // 09 Post Return Credit
        // 10 Complete without Posting Return Credit
        // 11 Clear Buffer
        // 12 Move To Processing Buffer
        // 13 Create Transfer
        // 14 Ship Transfer
        // 15 Receive Transfer
        // 16 Post Journal

        ProcessWhat := NewProcessWhat;
    end;


    ///<Summary>
    ///Move from PDA-Stock Adj. Buffer to to PDA-StAdjProcessing Buffer
    ///Status is set to Blank
    ///Delete the PDA-Stock Adj. Buffer
    ///</Summary>
    local procedure MoveToProcessingBuffer()
    var
        FromBuffer: Record "GXL PDA-Stock Adj. Buffer";
        ToBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        //LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        PDAStockAdjBufferMove: Codeunit "GXL PDA Stock Adj Buffer-Move";
        LastRMSID: Integer;
    begin
        if FromBuffer.FindSet() then begin
            GetSetup();
            LastRMSID := ToBuffer.GetLastRMSID();
            if LastRMSID < IntegrationSetup."Last RMS ID" then
                LastRMSID := IntegrationSetup."Last RMS ID";
            repeat
                //PS-2210+
                //Restructured to handle deadlock
                /*
                LastRMSID += 1;
                ToBuffer.Init();
                ToBuffer.TransferFields(FromBuffer);
                ToBuffer."Entry No." := 0;
                ToBuffer.Status := ToBuffer.Status::" ";
                if ToBuffer."Legacy Item No." = '' then
                    LegacyItemHelpers.GetLegacyItemNo(ToBuffer."Item No.", ToBuffer."Unit of Measure Code", ToBuffer."Legacy Item No.");
                ToBuffer."RMS ID" := LastRMSID; //<< PS-1386
                ToBuffer.Insert(true);

                FromBuffer.Delete();
                Commit();
                */

                Commit();
                Clear(PDAStockAdjBufferMove);
                PDAStockAdjBufferMove.SetMoveFromTable(Database::"GXL PDA-Stock Adj. Buffer");
                PDAStockAdjBufferMove.SetPDAStockAdjBuffer(FromBuffer);
                PDAStockAdjBufferMove.SetLastRMSID(LastRMSID);
                if PDAStockAdjBufferMove.Run() then
                    PDAStockAdjBufferMove.GetLastRMSID(LastRMSID);
            //PS-2210-

            until FromBuffer.Next() = 0;
        end;
    end;

    ///<Summary>
    ///Process PDA Stock Adj. Processing Buffer for claimable adjusments
    ///Status is updated to Validated
    ///</Summary>
    local procedure ValidateClaim()
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer";
        StockAdjustmentValidate: Codeunit "GXL Stock Adj. Validate";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        EDIFileLogEntryNo: Integer;

    begin
        //Only for claimable stock adjustment
        PDAStockAdjProcessingBuffer.SetCurrentKey(Status);
        PDAStockAdjProcessingBuffer.SetFilter("Claim-to Order No.", '<>%1', '');
        PDAStockAdjProcessingBuffer.SetRange(Status, PDAStockAdjProcessingBuffer.Status::" ");
        if PDAStockAdjProcessingBuffer.FindSet(true, true) then
            repeat

                ClearLastError();
                CLEAR(StockAdjustmentValidate);

                //PO,POX,POR,ASN,INV,STKADJ
                EDIFileLogEntryNo := InsertEDIFileLog('', 5, PDAStockAdjProcessingBuffer."Claim-to Document Type", PDAStockAdjProcessingBuffer."Claim-to Order No.", 0);

                Commit();

                PDAStockAdjProcessingBuffer2.Get(PDAStockAdjProcessingBuffer."Entry No.");

                ProcessWasSuccess := StockAdjustmentValidate.Run(PDAStockAdjProcessingBuffer2);
                UpdateNarration(ProcessWasSuccess, PDAStockAdjProcessingBuffer2); // LCB-239 <<

                PDAStockAdjProcessingBuffer2."EDI File Log Entry No." := EDIFileLogEntryNo;

                if ProcessWasSuccess then
                    PDAStockAdjProcessingBuffer2.Validate(Status, PDAStockAdjProcessingBuffer2.Status::Validated)

                else begin

                    if NOT IsLockingError(GetLastErrorCode()) then begin
                        PDAStockAdjProcessingBuffer2.Validate(Status, PDAStockAdjProcessingBuffer2.Status::"Validation Error");
                        WriteBufferError(PDAStockAdjProcessingBuffer2, ProcessWasSuccess);
                    end;

                end;

                // Table lock was placed so this cannot fail
                PDAStockAdjProcessingBuffer2.Modify(true);

                UpdateEDIFileLog(EDIFileLogEntryNo, ProcessWasSuccess);

                //PO,POX,POR,ASN,INV,STKADJ
                InsertEDIDocumentLog(EDIFileLogEntryNo, 5, ProcessWhat, ProcessWasSuccess, PDAStockAdjProcessingBuffer2."Claim Document Type");

                Commit();

                if MiscUtilities.IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                    EDIEmailMgt.SendStockAdjustmentFailureEmail(ProcessWhat, PDAStockAdjProcessingBuffer2, GetLastErrorText());

            until PDAStockAdjProcessingBuffer.Next() = 0;
    end;


    ///<Summary>
    ///Process PDA Stock Adj. Processing Buffer for Status=Validated 
    ///If the entry is related to purchase then create either purchase return order (Ullaged) or purchase credit note (Non-Ullaged)
    ///Status is updated to Return Order Created or Credit Created (for Purchase claim)
    ///Else Status is updated to Transfer Order Created (Note: transfer order is not actually created)
    ///</Summary>
    local procedure CreateClaimDocument()
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer";
        StockAdjProcessHandler: Codeunit "GXL Stock Adj. Process Handler";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        PurchaseClaim: Boolean;
        NewStatus: Enum "GXL PDA-Stock Adj Buf. Status";
    begin
        // Claims against PO:
        //   For ullaged suppliers, only create return order if receipt was posted
        //   For non-ullaged suppliers, create credit straight away
        // Claims against STO:
        //   Only stock adjustments
        PDAStockAdjProcessingBuffer.SetCurrentKey(Status);
        PDAStockAdjProcessingBuffer.SetRange(Status, PDAStockAdjProcessingBuffer.Status::Validated);
        if PDAStockAdjProcessingBuffer.FindSet(true, true) then
            repeat

                ClearLastError();
                PDAStockAdjProcessingBuffer2.Get(PDAStockAdjProcessingBuffer."Entry No.");

                PurchaseClaim := ClaimAppliesToPurchase(PDAStockAdjProcessingBuffer2."Claim-to Document Type");

                if StAdjCreateClaimPrerequisitesMet(PDAStockAdjProcessingBuffer2, PurchaseClaim) then begin

                    Commit();

                    //,Create Return Order,Apply Return Order,Post Return Shipment,Post Return Credit
                    StockAdjProcessHandler.SetOptions(ProcessWhich::"Create Claim Document");
                    ProcessWasSuccess := StockAdjProcessHandler.Run(PDAStockAdjProcessingBuffer2);
                    UpdateNarration(ProcessWasSuccess, PDAStockAdjProcessingBuffer2); // LCB-239 <<

                    //ERP-340 +
                    // NewStatus :=
                    //   GetNextStatus(
                    //     PDAStockAdjProcessingBuffer2.Status,
                    //     PDAStockAdjProcessingBuffer2."Vendor Ullaged Status" = PDAStockAdjProcessingBuffer2."Vendor Ullaged Status"::Ullaged,
                    //     ProcessWasSuccess,
                    //     PurchaseClaim);
                    NewStatus :=
                      GetNextStatus(
                        PDAStockAdjProcessingBuffer2.Status,
                        PDAStockAdjProcessingBuffer2."Vendor Ullaged Status" = PDAStockAdjProcessingBuffer2."Vendor Ullaged Status"::Ullaged,
                        ProcessWasSuccess,
                        PurchaseClaim,
                        PDAStockAdjProcessingBuffer2);
                    //ERP-340 -

                    // Update status if Process was success OR Process was not successful due to a non-locking error
                    if ProcessWasSuccess OR (NOT IsLockingError(GetLastErrorCode())) then begin
                        WriteBufferError(PDAStockAdjProcessingBuffer2, ProcessWasSuccess);
                        PDAStockAdjProcessingBuffer2.Validate(Status, NewStatus);
                        PDAStockAdjProcessingBuffer2.Modify(true);
                    end;

                    //PO,POX,POR,ASN,INV,STKADJ
                    InsertEDIDocumentLog(PDAStockAdjProcessingBuffer."EDI File Log Entry No.", 5,
                      MapProcess(ProcessWhat, PurchaseClaim),
                      ProcessWasSuccess,
                      PDAStockAdjProcessingBuffer."Claim-to Document Type");

                    Commit();

                    if MiscUtilities.IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                        EDIEmailMgt.SendStockAdjustmentFailureEmail(ProcessWhat, PDAStockAdjProcessingBuffer2, GetLastErrorText());

                end;

            until PDAStockAdjProcessingBuffer.Next() = 0;
    end;

    ///<Summary>
    ///Process PDA Stock Adj. Processing Buffer for Status=Return Order Created or Credit Created
    ///Apply the created return order or credit note 
    ///Status is updated to Return Order Applied or Credit Applied for purchase claim
    ///</Summary>
    local procedure ApplyClaimDocument()
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer";
        StockAdjProcessHandler: Codeunit "GXL Stock Adj. Process Handler";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        NewStatus: Enum "GXL PDA-Stock Adj Buf. Status";
    begin
        // For ullaged suppliers, apply return order straight away to the posted receipt, which we know exists because a return order was created.
        // For non-ullaged suppliers, apply credit note after invoice is posted
        PDAStockAdjProcessingBuffer.SetCurrentKey(Status);
        PDAStockAdjProcessingBuffer.SetFilter(Status, '%1|%2', PDAStockAdjProcessingBuffer.Status::"Return Order Created", PDAStockAdjProcessingBuffer.Status::"Credit Created");
        if PDAStockAdjProcessingBuffer.FindSet(true, true) then
            repeat

                ClearLastError();
                PDAStockAdjProcessingBuffer2.Get(PDAStockAdjProcessingBuffer."Entry No.");

                if ClaimAppliesToPurchase(PDAStockAdjProcessingBuffer."Claim-to Document Type") then begin

                    if StAdjApplyClaimDocumentPrerequisitesMet(PDAStockAdjProcessingBuffer2) then begin

                        Commit();

                        //,Create Return Order,Apply Return Order,Post Return Shipment,Post Return Credit
                        StockAdjProcessHandler.SetOptions(ProcessWhich::"Apply Return Order");
                        ProcessWasSuccess := StockAdjProcessHandler.Run(PDAStockAdjProcessingBuffer2);
                        UpdateNarration(ProcessWasSuccess, PDAStockAdjProcessingBuffer2); // LCB-239 <<

                        //ERP-340 +
                        // NewStatus :=
                        //   GetNextStatus(
                        //     PDAStockAdjProcessingBuffer2.Status,
                        //     PDAStockAdjProcessingBuffer2."Vendor Ullaged Status" = PDAStockAdjProcessingBuffer2."Vendor Ullaged Status"::Ullaged,
                        //     ProcessWasSuccess, true);
                        NewStatus :=
                          GetNextStatus(
                            PDAStockAdjProcessingBuffer2.Status,
                            PDAStockAdjProcessingBuffer2."Vendor Ullaged Status" = PDAStockAdjProcessingBuffer2."Vendor Ullaged Status"::Ullaged,
                            ProcessWasSuccess, true,
                            PDAStockAdjProcessingBuffer2);
                        //ERP-340 -

                        // Update status if Process was success OR Process was not successful due to a non-locking error
                        if ProcessWasSuccess OR (NOT IsLockingError(GetLastErrorCode())) then begin
                            WriteBufferError(PDAStockAdjProcessingBuffer2, ProcessWasSuccess);
                            PDAStockAdjProcessingBuffer2.Validate(Status, NewStatus);
                            PDAStockAdjProcessingBuffer2.Modify(true);
                        end;

                        //PO,POX,POR,ASN,INV,STKADJ
                        InsertEDIDocumentLog(PDAStockAdjProcessingBuffer."EDI File Log Entry No.", 5, ProcessWhat, ProcessWasSuccess, PDAStockAdjProcessingBuffer."Claim-to Document Type");

                        Commit();

                        if MiscUtilities.IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                            EDIEmailMgt.SendStockAdjustmentFailureEmail(ProcessWhat, PDAStockAdjProcessingBuffer2, GetLastErrorText());

                    end;

                end else begin

                    // afntodo: handle STO's

                end;

            until PDAStockAdjProcessingBuffer.Next() = 0;
    end;

    ///<Summary>
    ///Process PDA Stock Adj. Processing Buffer for Status=Return Order Applied
    ///Post the created purchase return order as ship
    ///Status is updated to Return Shipment Posted
    ///</Summary>
    local procedure PostReturnShipment()
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        TempPDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer" temporary;
        StockAdjProcessHandler: Codeunit "GXL Stock Adj. Process Handler";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        NewStatus: Enum "GXL PDA-Stock Adj Buf. Status";
    begin
        // User may post the return shipment manually, this has not been catered for

        // Loop buffer records where "Status" = Return Order Created AND "Manual Application" = true
        PDAStockAdjProcessingBuffer.SetCurrentKey(Status);
        PDAStockAdjProcessingBuffer.SetRange(Status, PDAStockAdjProcessingBuffer.Status::"Return Order Application Error");
        PDAStockAdjProcessingBuffer.SetRange("Manual Application", true);
        if PDAStockAdjProcessingBuffer.FindSet() then
            repeat
                TempPDAStockAdjProcessingBuffer.Reset();
                TempPDAStockAdjProcessingBuffer.TRANSFERFIELDS(PDAStockAdjProcessingBuffer);
                TempPDAStockAdjProcessingBuffer.Insert();
            until PDAStockAdjProcessingBuffer.Next() = 0;

        // Loop records where "Status" = Return Order Applied
        PDAStockAdjProcessingBuffer.Reset();
        PDAStockAdjProcessingBuffer.SetCurrentKey(Status);
        PDAStockAdjProcessingBuffer.SetRange(Status, PDAStockAdjProcessingBuffer.Status::"Return Order Applied");
        if PDAStockAdjProcessingBuffer.FindSet() then
            repeat
                TempPDAStockAdjProcessingBuffer.Reset();
                TempPDAStockAdjProcessingBuffer.TRANSFERFIELDS(PDAStockAdjProcessingBuffer);
                TempPDAStockAdjProcessingBuffer.Insert();
            until PDAStockAdjProcessingBuffer.Next() = 0;


        TempPDAStockAdjProcessingBuffer.Reset();
        if TempPDAStockAdjProcessingBuffer.FindSet() then
            repeat

                ClearLastError();

                PDAStockAdjProcessingBuffer.Reset();
                PDAStockAdjProcessingBuffer.Get(TempPDAStockAdjProcessingBuffer."Entry No.");

                Commit();

                //,Create Return Order,Apply Return Order,Post Return Shipment,Post Return Credit
                StockAdjProcessHandler.SetOptions(ProcessWhich::"Post Return Shipment");
                ProcessWasSuccess := StockAdjProcessHandler.Run(PDAStockAdjProcessingBuffer);
                UpdateNarration(ProcessWasSuccess, PDAStockAdjProcessingBuffer); // LCB-239 <<

                //ERP-340 +
                // NewStatus :=
                //   GetNextStatus(
                //     //PDAStockAdjProcessingBuffer, //PS-2638 -
                //     PDAStockAdjProcessingBuffer.Status::"Return Order Applied", //PS-2638 +
                //     PDAStockAdjProcessingBuffer."Vendor Ullaged Status" = PDAStockAdjProcessingBuffer."Vendor Ullaged Status"::Ullaged,
                //     ProcessWasSuccess, true);
                NewStatus :=
                  GetNextStatus(
                    PDAStockAdjProcessingBuffer.Status::"Return Order Applied",
                    PDAStockAdjProcessingBuffer."Vendor Ullaged Status" = PDAStockAdjProcessingBuffer."Vendor Ullaged Status"::Ullaged,
                    ProcessWasSuccess, true,
                    PDAStockAdjProcessingBuffer);
                //ERP-340 -

                // Update status if Process was success OR Process was not successful due to a non-locking error
                if ProcessWasSuccess OR (NOT IsLockingError(GetLastErrorCode())) then begin
                    WriteBufferError(PDAStockAdjProcessingBuffer, ProcessWasSuccess);
                    PDAStockAdjProcessingBuffer.Validate(Status, NewStatus);
                    if ProcessWasSuccess then
                        PDAStockAdjProcessingBuffer.Validate(Processed, true);
                    PDAStockAdjProcessingBuffer.Modify(true);
                end;

                //PO,POX,POR,ASN,INV,STKADJ
                InsertEDIDocumentLog(PDAStockAdjProcessingBuffer."EDI File Log Entry No.", 5, ProcessWhat, ProcessWasSuccess, PDAStockAdjProcessingBuffer."Claim-to Document Type");

                Commit();

                if MiscUtilities.IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                    EDIEmailMgt.SendStockAdjustmentFailureEmail(ProcessWhat, PDAStockAdjProcessingBuffer, GetLastErrorText());

            until TempPDAStockAdjProcessingBuffer.Next() = 0;
    end;

    ///<Summary>
    ///Process PDA Stock Adj. Processing Buffer for Status=Return Shipment Posted or Credit Applied
    ///Post the purchase return or credit
    ///Status is updated to Credit Posted or Closed (if Vendor Post/Claim is disabled)
    ///</Summary>
    local procedure PostReturnCredit()
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer";
        StockAdjProcessHandler: Codeunit "GXL Stock Adj. Process Handler";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        NewStatus: Enum "GXL PDA-Stock Adj Buf. Status";
    begin
        PDAStockAdjProcessingBuffer.SetCurrentKey(Status);
        PDAStockAdjProcessingBuffer.SetFilter(Status, '%1|%2', PDAStockAdjProcessingBuffer.Status::"Return Shipment Posted", PDAStockAdjProcessingBuffer.Status::"Credit Applied");
        if PDAStockAdjProcessingBuffer.FindSet(true, true) then
            repeat

                ClearLastError();
                PDAStockAdjProcessingBuffer2.Get(PDAStockAdjProcessingBuffer."Entry No.");

                if ClaimAppliesToPurchase(PDAStockAdjProcessingBuffer."Claim-to Document Type") then begin

                    if PostSendClaims(PDAStockAdjProcessingBuffer2."Claim-to Vendor No.") then begin

                        if PostReturnCreditPrerequisitesMet(PDAStockAdjProcessingBuffer2) then begin

                            Commit();

                            //,Create Return Order,Apply Return Order,Post Return Shipment,Post Return Credit
                            StockAdjProcessHandler.SetOptions(ProcessWhich::"Post Return Credit");
                            ProcessWasSuccess := StockAdjProcessHandler.Run(PDAStockAdjProcessingBuffer2);
                            UpdateNarration(ProcessWasSuccess, PDAStockAdjProcessingBuffer2); // LCB-239 <<                            

                            //ERP-340 +
                            // NewStatus :=
                            //   GetNextStatus(
                            //     PDAStockAdjProcessingBuffer2.Status,
                            //     PDAStockAdjProcessingBuffer2."Vendor Ullaged Status" = PDAStockAdjProcessingBuffer2."Vendor Ullaged Status"::Ullaged,
                            //     ProcessWasSuccess, true);
                            NewStatus :=
                              GetNextStatus(
                                PDAStockAdjProcessingBuffer2.Status,
                                PDAStockAdjProcessingBuffer2."Vendor Ullaged Status" = PDAStockAdjProcessingBuffer2."Vendor Ullaged Status"::Ullaged,
                                ProcessWasSuccess, true,
                                PDAStockAdjProcessingBuffer2);
                            //ERP-340 -

                            // Update status if Process was success OR Process was not successful due to a non-locking error
                            if ProcessWasSuccess OR (NOT IsLockingError(GetLastErrorCode())) then begin
                                WriteBufferError(PDAStockAdjProcessingBuffer2, ProcessWasSuccess);
                                PDAStockAdjProcessingBuffer2.Validate(Status, NewStatus);
                                if ProcessWasSuccess then //PS-2638 +
                                    PDAStockAdjProcessingBuffer2.Validate(Processed, true);
                                PDAStockAdjProcessingBuffer2.Validate("Post / Send Claim", true);
                                PDAStockAdjProcessingBuffer2.Modify(true);
                            end;

                            //PO,POX,POR,ASN,INV,STKADJ
                            InsertEDIDocumentLog(PDAStockAdjProcessingBuffer."EDI File Log Entry No.", 5, ProcessWhat, ProcessWasSuccess, PDAStockAdjProcessingBuffer."Claim-to Document Type");

                            Commit();

                            if MiscUtilities.IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                                EDIEmailMgt.SendStockAdjustmentFailureEmail(ProcessWhat, PDAStockAdjProcessingBuffer, GetLastErrorText());
                            if ProcessWasSuccess AND (NewStatus = NewStatus::"Credit Posted") then
                                EDIEmailMgt.SendStockAdjustmentCreditNotificationEmail(PDAStockAdjProcessingBuffer);

                        end;

                    end else begin
                        PDAStockAdjProcessingBuffer2.Validate(Status, PDAStockAdjProcessingBuffer.Status::Closed);
                        PDAStockAdjProcessingBuffer2.Validate(Processed, true);
                        PDAStockAdjProcessingBuffer2.Validate("Post / Send Claim", false);
                        PDAStockAdjProcessingBuffer2.Modify(true);

                        //PO,POX,POR,ASN,INV,STKADJ
                        InsertEDIDocumentLog(PDAStockAdjProcessingBuffer."EDI File Log Entry No.", 5, ProcessWhat::"Complete without Posting Return Credit", true, PDAStockAdjProcessingBuffer."Claim-to Document Type");

                        Commit();

                    end;

                end;

            until PDAStockAdjProcessingBuffer.Next() = 0;
    end;

    ///<Summary>
    ///Process PDA Stock Adj. Processing Buffer for Status=Transfer Created
    ///  Note: as transfer is not actually created, post transfer will not occur
    ///Status is updated to Transfer Shipped
    ///</Summary>
    local procedure ShipTransfer()
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer";
        StockAdjProcessHandler: Codeunit "GXL Stock Adj. Process Handler";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        NewStatus: Enum "GXL PDA-Stock Adj Buf. Status";
    begin
        PDAStockAdjProcessingBuffer.SetCurrentKey(Status);
        PDAStockAdjProcessingBuffer.SetRange(Status, PDAStockAdjProcessingBuffer.Status::"Transfer Created");
        if PDAStockAdjProcessingBuffer.FindSet(true, true) then
            repeat

                ClearLastError();
                PDAStockAdjProcessingBuffer2.Get(PDAStockAdjProcessingBuffer."Entry No.");

                Commit();

                StockAdjProcessHandler.SetOptions(ProcessWhich::"Ship Transfer");
                ProcessWasSuccess := StockAdjProcessHandler.Run(PDAStockAdjProcessingBuffer2);
                UpdateNarration(ProcessWasSuccess, PDAStockAdjProcessingBuffer2); // LCB-239 <<

                NewStatus :=
                  GetNextStatus(
                    PDAStockAdjProcessingBuffer2.Status,
                    PDAStockAdjProcessingBuffer2."Vendor Ullaged Status" = PDAStockAdjProcessingBuffer2."Vendor Ullaged Status"::Ullaged,  // Irrelevant for STO's
                    ProcessWasSuccess, false);

                // Update status if Process was success OR Process was not successful due to a non-locking error
                if ProcessWasSuccess OR (NOT IsLockingError(GetLastErrorCode())) then begin
                    WriteBufferError(PDAStockAdjProcessingBuffer2, ProcessWasSuccess);
                    PDAStockAdjProcessingBuffer2.Validate(Status, NewStatus);
                    PDAStockAdjProcessingBuffer2.Modify(true);
                end;

                //PO,POX,POR,ASN,INV,STKADJ
                InsertEDIDocumentLog(PDAStockAdjProcessingBuffer."EDI File Log Entry No.", 5, ProcessWhat, ProcessWasSuccess, PDAStockAdjProcessingBuffer."Claim-to Document Type");

                Commit();

                if MiscUtilities.IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                    EDIEmailMgt.SendStockAdjustmentFailureEmail(ProcessWhat, PDAStockAdjProcessingBuffer, GetLastErrorText());

            until PDAStockAdjProcessingBuffer.Next() = 0;
    end;

    ///<Summary>
    ///Process PDA Stock Adj. Processing Buffer with Status=Transfer Shipped
    ///  Note: Transfer order is not actually created, post transfer order will not occur
    ///Status is updated to Transfer Received
    ///</Summary>
    local procedure ReceiveTransfer()
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer";
        StockAdjProcessHandler: Codeunit "GXL Stock Adj. Process Handler";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        NewStatus: Enum "GXL PDA-Stock Adj Buf. Status";
    begin
        PDAStockAdjProcessingBuffer.SetCurrentKey(Status);
        PDAStockAdjProcessingBuffer.SetRange(Status, PDAStockAdjProcessingBuffer.Status::"Transfer Shipped");
        if PDAStockAdjProcessingBuffer.FindSet(true, true) then
            repeat

                ClearLastError();
                PDAStockAdjProcessingBuffer2.Get(PDAStockAdjProcessingBuffer."Entry No.");

                Commit();

                StockAdjProcessHandler.SetOptions(ProcessWhich::"Receive Transfer");
                ProcessWasSuccess := StockAdjProcessHandler.Run(PDAStockAdjProcessingBuffer2);
                UpdateNarration(ProcessWasSuccess, PDAStockAdjProcessingBuffer2); // LCB-239 <<

                NewStatus :=
                  GetNextStatus(
                    PDAStockAdjProcessingBuffer2.Status,
                    PDAStockAdjProcessingBuffer2."Vendor Ullaged Status" = PDAStockAdjProcessingBuffer2."Vendor Ullaged Status"::Ullaged,  // Irrelevant for STO's
                    ProcessWasSuccess, false);

                // Update status if Process was success OR Process was not successful due to a non-locking error
                if ProcessWasSuccess OR (NOT IsLockingError(GetLastErrorCode())) then begin
                    WriteBufferError(PDAStockAdjProcessingBuffer2, ProcessWasSuccess);
                    PDAStockAdjProcessingBuffer2.Validate(Status, NewStatus);
                    PDAStockAdjProcessingBuffer2.Modify(true);
                end;

                //PO,POX,POR,ASN,INV,STKADJ
                InsertEDIDocumentLog(PDAStockAdjProcessingBuffer."EDI File Log Entry No.", 5, ProcessWhat, ProcessWasSuccess, PDAStockAdjProcessingBuffer."Claim-to Document Type");

                Commit();

                if MiscUtilities.IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                    EDIEmailMgt.SendStockAdjustmentFailureEmail(ProcessWhat, PDAStockAdjProcessingBuffer, GetLastErrorText());

            until PDAStockAdjProcessingBuffer.Next() = 0;
    end;

    ///<Summary>
    ///Process PDA Stock Adj. Processing Buffer for Status=Transfer Received
    ///Create a negative adjustment of stock has been damaged during transfer
    ///Status is updated to Journal Posted
    ///</Summary>
    local procedure PostJournal()
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer";
        StockAdjProcessHandler: Codeunit "GXL Stock Adj. Process Handler";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        NewStatus: Enum "GXL PDA-Stock Adj Buf. Status";

    begin
        PDAStockAdjProcessingBuffer.SetCurrentKey(Status);
        PDAStockAdjProcessingBuffer.SetRange(Status, PDAStockAdjProcessingBuffer.Status::"Transfer Received");
        if PDAStockAdjProcessingBuffer.FindSet(true, true) then
            repeat

                ClearLastError();
                PDAStockAdjProcessingBuffer2.Get(PDAStockAdjProcessingBuffer."Entry No.");

                Commit();

                StockAdjProcessHandler.SetOptions(ProcessWhich::"Post Journal");
                ProcessWasSuccess := StockAdjProcessHandler.Run(PDAStockAdjProcessingBuffer2);
                UpdateNarration(ProcessWasSuccess, PDAStockAdjProcessingBuffer2); // LCB-239 <<

                NewStatus :=
                  GetNextStatus(
                    PDAStockAdjProcessingBuffer2.Status,
                    PDAStockAdjProcessingBuffer2."Vendor Ullaged Status" = PDAStockAdjProcessingBuffer2."Vendor Ullaged Status"::Ullaged,  // Irrelevant for STO's
                    ProcessWasSuccess, false);

                // Update status if Process was success OR Process was not successful due to a non-locking error
                //if ProcessWasSuccess OR (NOT IsLockingError(GetLastErrorCode())) then begin //PS-2640 -
                if ProcessWasSuccess or (not IsLockingError(GetLastErrorCode(), GetLastErrorText())) then begin //PS-2640 +
                    WriteBufferError(PDAStockAdjProcessingBuffer2, ProcessWasSuccess);
                    //PS-2638 +
                    if ProcessWasSuccess then
                        PDAStockAdjProcessingBuffer2.Processed := true;
                    //PS-2638 -
                    PDAStockAdjProcessingBuffer2.Validate(Status, NewStatus);
                    PDAStockAdjProcessingBuffer2.Modify(true);
                end;

                //PO,POX,POR,ASN,INV,STKADJ
                InsertEDIDocumentLog(PDAStockAdjProcessingBuffer."EDI File Log Entry No.", 5, ProcessWhat, ProcessWasSuccess, PDAStockAdjProcessingBuffer."Claim-to Document Type");

                Commit();

                if MiscUtilities.IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                    EDIEmailMgt.SendStockAdjustmentFailureEmail(ProcessWhat, PDAStockAdjProcessingBuffer, GetLastErrorText());

            until PDAStockAdjProcessingBuffer.Next() = 0;
    end;

    local procedure InsertEDIFileLog(FullFileName: Text; Which: Option PO,POX,POR,ASN,INV,STKADJ; DocumentType: Option " ",PO,PI,STO,"STO-SHIP","STO-REC"; DocumentNo: Code[20]; VendorEDIType: Option " ","Point 2 Point",VAN,"3PL Supplier"): Integer
    var
        EDIProcessManagement: Codeunit "GXL EDI Process Mngt";
    begin
        exit(EDIProcessManagement.InsertEDIFileLog2(FullFileName, Which, DocumentType, DocumentNo, VendorEDIType));
    end;

    local procedure UpdateEDIFileLog(EDILogEntryNo: Integer; ProcessWasSuccess: Boolean)
    var
        EDIProcessManagement: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessManagement.UpdateEDIFileLog(EDILogEntryNo, ProcessWasSuccess);
    end;

    local procedure InsertEDIDocumentLog(EDIFileLogEntryNo: Integer; InputProcessWhich: Option PO,POX,POR,ASN,INV,STKADJ; InputProcessWhat: Integer; ImportExportWasSuccess: Boolean; OrderType: Integer)
    var
        EDIProcessManagement: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessManagement.InsertEDIDocumentLog2(EDIFileLogEntryNo, InputProcessWhich, InputProcessWhat, ImportExportWasSuccess, OrderType);
    end;

    local procedure IsLockingError(LockStr: Text): Boolean
    begin
        exit(MiscUtilities.IsLockingError(LockStr));
    end;

    //PS-2640 +
    local procedure IsLockingError(LockStr: Text; ErrorText: Text): Boolean
    begin
        exit(MiscUtilities.IsLockingError(LockStr, ErrorText));
    end;
    //PS-2640 -

    local procedure ClearBuffer()
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        EDILib: Codeunit "GXL EDI Functions Library";
        EmptyDateFormula: DateFormula;
        DeletionDateFormula: DateFormula;
        OK: Boolean;
    begin
        GetSetup();
        if IntegrationSetup."Staging Table Age for Deletion" <> EmptyDateFormula then begin

            DeletionDateFormula := IntegrationSetup."Staging Table Age for Deletion";
            EDILib.NegateDateFormula(DeletionDateFormula);  // var

            PDAStockAdjProcessingBuffer.SetCurrentKey(Status, "Created Date Time");
            PDAStockAdjProcessingBuffer.SetFilter(Status, '%1|%2|%3',
              PDAStockAdjProcessingBuffer.Status::"Credit Posted",
              PDAStockAdjProcessingBuffer.Status::"Journal Posting Error",
              PDAStockAdjProcessingBuffer.Status::Closed);
            PDAStockAdjProcessingBuffer.SetRange("Created Date Time", 0DT, CreateDateTime(CALCDATE(DeletionDateFormula, Today()), 0T));
            if PDAStockAdjProcessingBuffer.FindSet() then
                repeat
                    OK := PDAStockAdjProcessingBuffer.Delete();
                until PDAStockAdjProcessingBuffer.Next() = 0;

        end;
    end;

    local procedure GetSetup()
    begin
        if NOT SetupRead then
            IntegrationSetup.Get();
        SetupRead := true;
    end;

    ///<Summary>
    ///Set the next status of PDA Stock Adj. Processing Buffer basing on if the process was success or not and the vendor ullaged status
    ///</Summary>
    local procedure GetNextStatus(CurrentStatus: Enum "GXL PDA-Stock Adj Buf. Status"; VendorIsUllaged: Boolean; ProcessWasSuccess: Boolean; PurchaseClaim: Boolean) NextStatus: Integer
    var
        NewStatus: Enum "GXL PDA-Stock Adj Buf. Status";
    begin

        if PurchaseClaim then begin

            if ProcessWasSuccess then begin

                if VendorIsUllaged then begin
                    case CurrentStatus of
                        CurrentStatus::Validated:
                            NextStatus := NewStatus::"Return Order Created";
                        CurrentStatus::"Return Order Created":
                            NextStatus := NewStatus::"Return Order Applied";
                        CurrentStatus::"Return Order Applied":
                            NextStatus := NewStatus::"Return Shipment Posted";
                        CurrentStatus::"Return Shipment Posted":
                            NextStatus := NewStatus::"Credit Posted";
                    end;
                end else
                    case CurrentStatus of
                        CurrentStatus::Validated:
                            NextStatus := NewStatus::"Credit Created";
                        CurrentStatus::"Credit Created":
                            NextStatus := NewStatus::"Credit Applied";
                        CurrentStatus::"Credit Applied":
                            NextStatus := NewStatus::"Credit Posted";
                    end;

            end else

                if VendorIsUllaged then begin
                    case CurrentStatus of
                        CurrentStatus::Validated:
                            NextStatus := NewStatus::"Return Order Creation Error";
                        CurrentStatus::"Return Order Created":
                            NextStatus := NewStatus::"Return Order Application Error";
                        CurrentStatus::"Return Order Applied":
                            NextStatus := NewStatus::"Return Shipment Posting Error";
                        CurrentStatus::"Return Shipment Posted":
                            NextStatus := NewStatus::"Credit Posting Error";
                    end;
                end else
                    case CurrentStatus of
                        CurrentStatus::Validated:
                            NextStatus := NewStatus::"Credit Creation Error";  // afntodo: line errors on this case: rewrite function. //NextStatus := NewStatus::"Credit Creation Error";
                        CurrentStatus::"Credit Created":
                            NextStatus := NewStatus::"Credit Application Error";
                        CurrentStatus::"Credit Applied":
                            NextStatus := NewStatus::"Credit Posting Error";
                    end;

        end else

            if ProcessWasSuccess then begin
                case CurrentStatus of
                    CurrentStatus::Validated:
                        NextStatus := NewStatus::"Transfer Created";
                    CurrentStatus::"Transfer Created":
                        NextStatus := NewStatus::"Transfer Shipped";
                    CurrentStatus::"Transfer Shipped":
                        NextStatus := NewStatus::"Transfer Received";
                    CurrentStatus::"Transfer Received":
                        NextStatus := NewStatus::"Journal Posted";
                end;
            end else
                case CurrentStatus of
                    CurrentStatus::Validated:
                        NextStatus := NewStatus::"Transfer Creation Error";
                    CurrentStatus::"Transfer Created":
                        NextStatus := NewStatus::"Transfer Shipping Error";
                    CurrentStatus::"Transfer Shipped":
                        NextStatus := NewStatus::"Transfer Receiving Error";
                    CurrentStatus::"Transfer Received":
                        NextStatus := NewStatus::"Journal Posting Error";
                end;
    end;

    //ERP-340 +
    local procedure GetNextStatus(CurrentStatus: Enum "GXL PDA-Stock Adj Buf. Status"; VendorIsUllaged: Boolean;
        ProcessWasSuccess: Boolean; PurchaseClaim: Boolean;
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer") NextStatus: Integer
    var
        NewStatus: Enum "GXL PDA-Stock Adj Buf. Status";
        NewVendorIsUllaged: Boolean;
    begin
        NewVendorIsUllaged := VendorIsUllaged;
        if PDAStockAdjProcessingBuffer."Claim Document Type" = PDAStockAdjProcessingBuffer."Claim Document Type"::"Return Order" then
            NewVendorIsUllaged := true;

        if PurchaseClaim then begin

            if ProcessWasSuccess then begin

                if NewVendorIsUllaged then begin
                    case CurrentStatus of
                        CurrentStatus::Validated:
                            NextStatus := NewStatus::"Return Order Created";
                        CurrentStatus::"Return Order Created":
                            NextStatus := NewStatus::"Return Order Applied";
                        CurrentStatus::"Return Order Applied":
                            NextStatus := NewStatus::"Return Shipment Posted";
                        CurrentStatus::"Return Shipment Posted":
                            NextStatus := NewStatus::"Credit Posted";
                    end;
                end else
                    case CurrentStatus of
                        CurrentStatus::Validated:
                            NextStatus := NewStatus::"Credit Created";
                        CurrentStatus::"Credit Created":
                            NextStatus := NewStatus::"Credit Applied";
                        CurrentStatus::"Credit Applied":
                            NextStatus := NewStatus::"Credit Posted";
                    end;

            end else

                if NewVendorIsUllaged then begin
                    case CurrentStatus of
                        CurrentStatus::Validated:
                            NextStatus := NewStatus::"Return Order Creation Error";
                        CurrentStatus::"Return Order Created":
                            NextStatus := NewStatus::"Return Order Application Error";
                        CurrentStatus::"Return Order Applied":
                            NextStatus := NewStatus::"Return Shipment Posting Error";
                        CurrentStatus::"Return Shipment Posted":
                            NextStatus := NewStatus::"Credit Posting Error";
                    end;
                end else
                    case CurrentStatus of
                        CurrentStatus::Validated:
                            NextStatus := NewStatus::"Credit Creation Error";  // afntodo: line errors on this case: rewrite function. //NextStatus := NewStatus::"Credit Creation Error";
                        CurrentStatus::"Credit Created":
                            NextStatus := NewStatus::"Credit Application Error";
                        CurrentStatus::"Credit Applied":
                            NextStatus := NewStatus::"Credit Posting Error";
                    end;

        end else

            if ProcessWasSuccess then begin
                case CurrentStatus of
                    CurrentStatus::Validated:
                        NextStatus := NewStatus::"Transfer Created";
                    CurrentStatus::"Transfer Created":
                        NextStatus := NewStatus::"Transfer Shipped";
                    CurrentStatus::"Transfer Shipped":
                        NextStatus := NewStatus::"Transfer Received";
                    CurrentStatus::"Transfer Received":
                        NextStatus := NewStatus::"Journal Posted";
                end;
            end else
                case CurrentStatus of
                    CurrentStatus::Validated:
                        NextStatus := NewStatus::"Transfer Creation Error";
                    CurrentStatus::"Transfer Created":
                        NextStatus := NewStatus::"Transfer Shipping Error";
                    CurrentStatus::"Transfer Shipped":
                        NextStatus := NewStatus::"Transfer Receiving Error";
                    CurrentStatus::"Transfer Received":
                        NextStatus := NewStatus::"Journal Posting Error";
                end;
    end;
    //ERP-340 -

    local procedure StAdjCreateClaimPrerequisitesMet(var PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer"; PurchaseRelatedClaim: Boolean) PrerequisitesMet: Boolean
    var
        ClaimMgt: Codeunit "GXL Claim Management";
    begin
        if PurchaseRelatedClaim then
            PrerequisitesMet :=
              ClaimMgt.CreatePOClaimPrerequisitesMet(
                PDAStockAdjProcessingBuffer."Vendor Ullaged Status",
                PDAStockAdjProcessingBuffer."Claim-to Receipt No.",  // var
                PDAStockAdjProcessingBuffer."Claim-to Order No.",
                PDAStockAdjProcessingBuffer."Claim-to Vendor No.")

        else  // Check Transfer related claim prerequisites

            PrerequisitesMet :=
                ClaimMgt.CreateSTOClaimPrerequisitesMet(
                PDAStockAdjProcessingBuffer."Claim-to Receipt No.",
                PDAStockAdjProcessingBuffer."Claim-to Order No.",
                PDAStockAdjProcessingBuffer."Store Code");
    end;

    local procedure StAdjApplyClaimDocumentPrerequisitesMet(var PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer") PrerequisitesMet: Boolean
    var
        ClaimMgt: Codeunit "GXL Claim Management";
    begin
        //ERP-340 +
        // PrerequisitesMet := ClaimMgt.ApplyClaimPrerequisitesMet(
        //   PDAStockAdjProcessingBuffer."Vendor Ullaged Status",
        //   PDAStockAdjProcessingBuffer."Claim-to Document No.",  // << passed as var, Caller must MODIFY
        //   PDAStockAdjProcessingBuffer."Claim-to Order No.",
        //   PDAStockAdjProcessingBuffer."Claim-to Vendor No.");
        PrerequisitesMet := ClaimMgt.ApplyClaimPrerequisitesMet(
          PDAStockAdjProcessingBuffer."Claim Document Type",
          PDAStockAdjProcessingBuffer."Claim-to Document No.",  // << passed as var, Caller must MODIFY
          PDAStockAdjProcessingBuffer."Claim-to Order No.",
          PDAStockAdjProcessingBuffer."Claim-to Vendor No.");
        //ERP-340 -
    end;

    local procedure PostReturnCreditPrerequisitesMet(var PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer") PreRequisitesMet: Boolean
    var
        ClaimMgt: Codeunit "GXL Claim Management";
    begin
        //ERP-340 +
        // PreRequisitesMet :=
        //   ClaimMgt.PostReturnCreditPrerequisitesMet(
        //     PDAStockAdjProcessingBuffer."Vendor Ullaged Status",
        //     PDAStockAdjProcessingBuffer."Claim-to Document No.",  // var
        //     PDAStockAdjProcessingBuffer."Claim-to Order No.",
        //     PDAStockAdjProcessingBuffer."Claim-to Vendor No.");
        PreRequisitesMet :=
          ClaimMgt.PostReturnCreditPrerequisitesMet(
            PDAStockAdjProcessingBuffer."Claim Document Type",
            PDAStockAdjProcessingBuffer."Claim-to Document No.",  // var
            PDAStockAdjProcessingBuffer."Claim-to Order No.",
            PDAStockAdjProcessingBuffer."Claim-to Vendor No.");
        //ERP-340 -
    end;

    local procedure PostSendClaims(VendorNo: Code[20]): Boolean
    var
        ClaimMgt: Codeunit "GXL Claim Management";
    begin
        exit(ClaimMgt.PostSendClaims(VendorNo));
    end;

    procedure ClaimAppliesToPurchase(ClaimToDocumentType: Option " ",PO,PI,STO,"STO-SHIP","STO-REC"): Boolean
    begin
        exit(ClaimToDocumentType IN [ClaimToDocumentType::PO, ClaimToDocumentType::PI]);
    end;

    local procedure WriteBufferError(var PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer"; Success: Boolean)
    begin
        PDAStockAdjProcessingBuffer.Errored := NOT Success;
        if Success then begin
            PDAStockAdjProcessingBuffer."Error Code" := '';
            PDAStockAdjProcessingBuffer."Error Message" := '';
        end else begin
            PDAStockAdjProcessingBuffer."Error Code" := COPYSTR(GetLastErrorCode(), 1, MAXSTRLEN(PDAStockAdjProcessingBuffer."Error Code"));
            PDAStockAdjProcessingBuffer."Error Message" := COPYSTR(GetLastErrorText(), 1, MAXSTRLEN(PDAStockAdjProcessingBuffer."Error Message"));
            PDAStockAdjProcessingBuffer.Narration := PDAStockAdjProcessingBuffer."Error Message"; // >> LCB-239 <<
        end;
        // Caller must MODIFY
    end;

    local procedure MapProcess(FromProcess: Enum "GXL Stock Adj. Process Step"; PurchaseClaim: Boolean): Integer
    var
        ToProcess: Enum "GXL EDI Process Step";
    begin
        // Map To
        // 00 Validate and Export
        // 01 Import
        // 02 Validate
        // 03 Process
        // 04 Scan
        // 05 Receive
        // 06 Create Return Order
        // 07 Apply Return Order
        // 08 Post Return Shipment
        // 09 Post Return Credit
        // 10 Complete without Posting Return Credit
        // 11
        // 12 Create Transfer
        // 13 Ship Transfer
        // 14 Receive Transfer
        // 15 Post Journal

        if PurchaseClaim then begin

            case FromProcess of
                FromProcess::"Create Claim Document":
                    exit(ToProcess::"Create Return Order");

            end;

        end else // transfer related

            case FromProcess of
                FromProcess::"Create Claim Document":
                    exit(ToProcess::"Create Transfer");
            end;
    end;


    ///<Summary>
    ///Move the WH item adjustment (3PL EDI) to PDA Stock Adjustment Processing Buffer
    ///</Summary>
    local procedure MoveClaimableADJToProcessingBuffer()
    var
        WHMessageLines: Record "GXL WH Message Lines";
        //ToBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        //LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        PDAStockAdjBufferMove: Codeunit "GXL PDA Stock Adj Buffer-Move";
        ProcessWasSuccess: Boolean;
    begin
        //PS-2210+
        //Restrucure to handle deadlock
        // WHMessageLines.SetCurrentKey("Document No.", "Line No.", "Import Type", "EDI Type");
        // WHMessageLines.SetRange("Import Type", WHMessageLines."Import Type"::"Item Adj.");
        // WHMessageLines.SetRange("EDI Type", WHMessageLines."EDI Type"::"3PL EDI");
        // WHMessageLines.SetRange("EDI Claimable", true);
        // WHMessageLines.SetRange(Processed, false);
        // WHMessageLines.SetRange("Error Found", false);
        // if WHMessageLines.FindSet(true, true) then
        //     repeat
        //         ToBuffer.Init();
        //         ToBuffer."Entry No." := 0;
        //         ToBuffer.Type := ToBuffer.Type::ADJ;
        //         ToBuffer."Store Code" := WHMessageLines."Location Code";
        //         ToBuffer."Document No." := WHMessageLines."Document No.";
        //         //Legacy Item
        //         //From WH, the item sent is legacy item number
        //         //ToBuffer."Item No." := WHMessageLines."Item No.";
        //         ToBuffer."Legacy Item No." := WHMessageLines."Item No.";
        //         LegacyItemHelpers.GetItemNo(ToBuffer."Legacy Item No.", ToBuffer."Item No.", ToBuffer."Unit of Measure Code");
        //         ToBuffer."Stock on Hand" := ABS(WHMessageLines."Qty. To Receive");
        //         ToBuffer."Reason Code" := WHMessageLines."Reason Code";
        //         ToBuffer."Created Date Time" := CreateDateTime(WHMessageLines."Date Imported", WHMessageLines."Time Imported");
        //         ToBuffer.Status := ToBuffer.Status::" ";
        //         if WHMessageLines.Description <> '' then begin
        //             ToBuffer."Claim-to Document Type" := ToBuffer."Claim-to Document Type"::PO;
        //             ToBuffer."Claim-to Order No." := WHMessageLines.Description;
        //         end;
        //         ToBuffer.Insert(true);

        //         WHMessageLines.Processed := true;
        //         WHMessageLines.Modify();

        //         Commit();  // Slower but less chance of locking
        //     until WHMessageLines.Next() = 0;

        WHMessageLines.SetCurrentKey(Processed, "EDI Claimable");
        WHMessageLines.SetRange(Processed, false);
        WHMessageLines.SetRange("EDI Claimable", true);
        WHMessageLines.SetRange("Import Type", WHMessageLines."Import Type"::"Item Adj.");
        WHMessageLines.SetRange("EDI Type", WHMessageLines."EDI Type"::"3PL EDI");
        WHMessageLines.SetRange("Error Found", false);
        if WHMessageLines.IsEmpty() then
            exit;

        if WHMessageLines.FindSet() then
            repeat
                Commit();
                Clear(PDAStockAdjBufferMove);
                PDAStockAdjBufferMove.SetMoveFromTable(Database::"GXL WH Message Lines");
                PDAStockAdjBufferMove.SetWHMessageLine(WHMessageLines);
                ProcessWasSuccess := PDAStockAdjBufferMove.Run();
            until WHMessageLines.Next() = 0;

        //PS-2210-
    end;
    // >> LCB-239
    local procedure UpdateNarration(ProcessWasSuccess: Boolean; var PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    begin
        if ProcessWasSuccess then
            exit;

        PDAStockAdjProcessingBuffer.Narration := CopyStr(GetLastErrorText(), 1, MaxStrLen(PDAStockAdjProcessingBuffer.Narration));
        PDAStockAdjProcessingBuffer.Modify();
    end;
    // << LCB-239
}