codeunit 50280 "GXL Non-EDI Process Management"
{
    // 001 09.04.2025 KDU https://petbarnjira.atlassian.net/browse/LCB-797
    ///<Summary>
    /// Process the PDA-PL Receive Buffer
    /// Only process purchase orders which EDI Vendor Type is blank (i.e. non-EDI purchase orders)
    ///</Summary>

    trigger OnRun()
    begin

        CASE ProcessWhat OF
            ProcessWhat::"Clear Buffer":
                ClearBuffer();

            ProcessWhat::"Move To Processing Buffer":
                MoveToProcessingBuffer();

            ProcessWhat::Validate:
                ValidateDocument();

            ProcessWhat::Receive:
                PostPurchaseOrder();

            ProcessWhat::"Create Return Order":
                CreateClaimDocument();

            ProcessWhat::"Apply Return Order":
                ApplyClaimDocument();

            ProcessWhat::"Post Return Shipment":
                PostReturnShipment();

            ProcessWhat::"Post Return Credit":
                PostReturnCredit();

            ProcessWhat::"Clear PDA Receiving Buffer Errors":
                ClearPDAReceivingBufferErrors();

            else
                exit;
        end;
    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        SetupRead: Boolean;
        ProcessWhat: Enum "GXL Non-EDI Process Step";
        PostingErrorTxt: Label 'Posting Error: %1';
        NoOfDocResetConfirmMsg: Label 'No. of documents that will be reset: %1\OK to continue?';
        NothingToResetMsg: Label 'Nothing to reset.';
        InvalidDocTyeMsg: Label 'Invalid Document Type';
        NoOfDocClearConfirmMsg: Label 'No. of documents that will be cleared: %1\OK to continue?';
        NothingToClearMsg: Label 'Nothing to clear.';

    procedure SetOptions(NewProcessWhat: Enum "GXL Non-EDI Process Step")
    begin

        //  0 Validate and Export
        //  1 Import
        //  2 Validate
        //  3 Process
        //  4 Scan,
        //  5 Receive
        //  6 Create Return Order
        //  7 Apply Return Order
        //  8 Post Return Shipment
        //  9 Post Return Credit
        // 10 Complete without Posting Return Credit
        // 11 Clear Buffer
        // 12 Move To Processing Buffer
        // 13 Clear PDA Receiving Buffer Errors
        ProcessWhat := NewProcessWhat;
    end;

    //Clear all old posted/closed entries
    local procedure ClearBuffer()
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        EDILib: Codeunit "GXL EDI Functions Library";
        EmptyDateFormula: DateFormula;
        DeletionDateFormula: DateFormula;
        OK: Boolean;
    begin
        GetSetup();
        if IntegrationSetup."Staging Table Age for Deletion" <> EmptyDateFormula then begin

            DeletionDateFormula := IntegrationSetup."Staging Table Age for Deletion";
            EDILib.NegateDateFormula(DeletionDateFormula);  // var

            PDAPLReceiveBuffer.SetCurrentKey(Status, "Entry Date Time");
            PDAPLReceiveBuffer.SetFilter(Status, '%1|%2', PDAPLReceiveBuffer.Status::"Credit Posted", PDAPLReceiveBuffer.Status::Closed);
            PDAPLReceiveBuffer.SetRange("Entry Date Time", 0DT, CREATEDATETIME(CALCDATE(DeletionDateFormula, Today()), 0T));
            if PDAPLReceiveBuffer.FindSet() then
                repeat
                    OK := PDAPLReceiveBuffer.Delete();
                until PDAPLReceiveBuffer.Next() = 0;

        end;
    end;

    //move all records in table PDA-Purchase Lines to PDA-PL Receive Buffer, clear PDA-Purchase Lines
    local procedure MoveToProcessingBuffer()
    var
        NonEDIProcessScannedQtys: Codeunit "GXL Non-EDI Process Scan Qtys";
        ProcessWasSuccess: Boolean;
    begin
        // Process options
        //0 PurchaseLine (Use QtyToReceive)
        //1 TransferLine
        //2 CopyBuffer
        //3 PurchaseLine (Use InvoiceQuantity)

        Clear(NonEDIProcessScannedQtys);
        Commit();
        NonEDIProcessScannedQtys.SetOptions(2); //Copy Buffer
        ProcessWasSuccess := NonEDIProcessScannedQtys.Run();
        // Note: Move buffer entries ends in Commit();
    end;

    //Validate all the Scanned records, update status=Processed
    local procedure ValidateDocument()
    var
        PurchaseHeader: Record "Purchase Header";
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        NonEDIReceivePurchaseOrder: Codeunit "GXL Non-EDI Receive PurchOrder";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        DocumentNo: Code[20];
        NewStatus: Enum "GXL PDA-PL Receive Status";
    begin
        DocumentNo := '';
        FilterBuffer(PDAPLReceiveBuffer, PDAPLReceiveBuffer.Status::Scanned, false);
        // >> 001
        SelectLatestVersion();
        //if PDAPLReceiveBuffer.FindSet(true, true) then
        if PDAPLReceiveBuffer.FindSet() then
            // << 001
            repeat
                //Is Non-EDI purchase order
                if IsNewDocument(PDAPLReceiveBuffer."Document No.", DocumentNo) then begin
                    ClearLastError();
                    DocumentNo := PDAPLReceiveBuffer."Document No.";
                    if PrerequisitesMet(DocumentNo) then begin

                        Clear(NonEDIReceivePurchaseOrder);
                        NonEDIReceivePurchaseOrder.SetDocument(DocumentNo);

                        Commit();
                        ProcessWasSuccess := NonEDIReceivePurchaseOrder.Run();

                        // the buffer lines' status is updated in the codeunit.RUN, except for the below scenario:
                        // if not success and no errors then an error occurred before lines were validated, so we know no line errors will be overwritten and
                        // so it's safe to write to the buffer lines (all lines are updated)
                        if not ProcessWasSuccess then
                            if not DocumentHasError(DocumentNo) then
                                UpdateBuffer(DocumentNo, ProcessWasSuccess, GetLastErrorText(), NewStatus::"Processing Error", '', '', '', '', GetLastErrorCode());

                        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DocumentNo);
                        if PurchaseHeader."GXL EDI PO File Log Entry No." <> 0 then
                            InsertEDIDocumentLog(PurchaseHeader."GXL EDI PO File Log Entry No.", 3, 4, ProcessWasSuccess);
                        Commit();

                        if IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                            EDIEmailMgt.SendPOScanPocessFailureEmail(DocumentNo, GetLastErrorText());
                    end;
                end;
            until PDAPLReceiveBuffer.Next() = 0;
    end;

    //Receive (post) scanned (processed) quantities, update status=Received
    local procedure PostPurchaseOrder()
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        NonEDIPostReceipt: Codeunit "GXL Non-EDI Post Receipt";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        DocumentNo: Code[20];
        NewStatus: Enum "GXL PDA-PL Receive Status";
        ErrorText: Text;
        PostedReceiptNo: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        DocumentNo := '';
        FilterBuffer(PDAPLReceiveBuffer, PDAPLReceiveBuffer.Status::Processed, false);
        if PDAPLReceiveBuffer.FindSet(true, true) then
            repeat

                if IsNewDocument(PDAPLReceiveBuffer."Document No.", DocumentNo) then begin

                    ClearLastError();
                    DocumentNo := PDAPLReceiveBuffer."Document No.";

                    if AllLinesHaveStatus(DocumentNo, PDAPLReceiveBuffer.Status::Processed) then begin

                        Clear(NonEDIPostReceipt);
                        if DT2DATE(PDAPLReceiveBuffer."Entry Date Time") = 0D then
                            NonEDIPostReceipt.SetOptions(PDAPLReceiveBuffer."Document No.", DT2DATE(PDAPLReceiveBuffer."Received from PDA"))
                        else
                            NonEDIPostReceipt.SetOptions(PDAPLReceiveBuffer."Document No.", DT2DATE(PDAPLReceiveBuffer."Entry Date Time"));

                        Commit();
                        //PS-2046+
                        NonEDIPostReceipt.SetMIMUserID(PDAPLReceiveBuffer."MIM User ID");
                        //PS-2046-
                        ProcessWasSuccess := NonEDIPostReceipt.Run();

                        NonEDIPostReceipt.GetPostedDocumentNos(PostedReceiptNo, PostedInvoiceNo);

                        if not ProcessWasSuccess then
                            // there is a commit between posting & emailing, so if emailing fails then posting was successful but an error will be returned.
                            ProcessWasSuccess := ReceiptWasPosted(PostedReceiptNo);

                        if ProcessWasSuccess then begin
                            NewStatus := ReceiveOrClose(DocumentNo);
                            UpdateBuffer(DocumentNo, ProcessWasSuccess, '', NewStatus, PostedReceiptNo, PostedInvoiceNo, '', '', '');
                        end else
                            if not IsLockingError(GetLastErrorCode()) then begin
                                NewStatus := NewStatus::"Receiving Error";
                                ErrorText := STRSUBSTNO(PostingErrorTxt, GetLastErrorText());
                                UpdateBuffer(DocumentNo, ProcessWasSuccess, ErrorText, NewStatus::"Receiving Error", '', '', '', '', GetLastErrorCode());
                            end;

                        if PDAPLReceiveBuffer."EDI File Log Entry No." <> 0 then
                            InsertEDIDocumentLog(PDAPLReceiveBuffer."EDI File Log Entry No.", 3, 5, ProcessWasSuccess);

                        if ProcessWasSuccess then
                            EDIEmailMgt.SendPOReceivingDiscrepancyEmail(PDAPLReceiveBuffer)
                        else begin
                            if not IsLockingError(GetLastErrorCode()) then
                                EDIEmailMgt.SendPOReceivingFailureEmail(PDAPLReceiveBuffer, GetLastErrorText());
                        end;

                    end;

                end;

            until PDAPLReceiveBuffer.Next() = 0;
    end;

    //Create purchase credit or purchase return (based on Vendor ullaged) for the claim quantity (over supply)
    local procedure CreateClaimDocument()
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        NonEDICreateClaimDocument: Codeunit "GXL Non-EDI Create Claim Doc";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        DocumentNo: Code[20];
        NewStatus: Enum "GXL PDA-PL Receive Status";
    begin
        DocumentNo := '';
        FilterBuffer(PDAPLReceiveBuffer, PDAPLReceiveBuffer.Status::Received, true);
        if PDAPLReceiveBuffer.FindSet(true, true) then
            repeat
                if IsNewDocument(PDAPLReceiveBuffer."Document No.", DocumentNo) then begin
                    ClearLastError();
                    DocumentNo := PDAPLReceiveBuffer."Document No.";
                    if AllLinesHaveStatus(DocumentNo, PDAPLReceiveBuffer.Status::Received) then
                        if CreateClaimPrerequisitesMet(PDAPLReceiveBuffer) then begin

                            Clear(NonEDICreateClaimDocument);
                            NonEDICreateClaimDocument.SetDocument(DocumentNo);

                            Commit();
                            ProcessWasSuccess := NonEDICreateClaimDocument.Run();

                            //ERP-340 +
                            // NewStatus :=
                            //   GetNextStatus(
                            //     PDAPLReceiveBuffer.Status,
                            //     PDAPLReceiveBuffer."Vendor Ullaged Status" = PDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged,
                            //     ProcessWasSuccess);
                            NewStatus :=
                              GetNextStatus(
                                PDAPLReceiveBuffer.Status,
                                PDAPLReceiveBuffer."Vendor Ullaged Status" = PDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged,
                                ProcessWasSuccess,
                                PDAPLReceiveBuffer);
                            //ERP-340 -

                            // Update status if Process was success or Process was not successful due to a non-locking error
                            if ProcessWasSuccess or (not IsLockingError(GetLastErrorCode())) then
                                UpdateBuffer(DocumentNo, ProcessWasSuccess, GetLastErrorText(), NewStatus, '', '', '', '', GetLastErrorCode());

                            if PDAPLReceiveBuffer."EDI File Log Entry No." <> 0 then
                                InsertEDIDocumentLog(PDAPLReceiveBuffer."EDI File Log Entry No.", 0, ProcessWhat, ProcessWasSuccess);

                            Commit();

                            if ProcessWasSuccess then begin
                                if not PostSendClaims(PDAPLReceiveBuffer."Vendor No.") then
                                    EDIEmailMgt.SendPOCreditCreationNotificationEmail(PDAPLReceiveBuffer);
                            end else
                                if IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                                    EDIEmailMgt.SendPOClaimCreationFailureEmail(PDAPLReceiveBuffer, GetLastErrorText());

                        end;

                end;
            until PDAPLReceiveBuffer.Next() = 0;
    end;

    //Apply the claim documents created/posted
    local procedure ApplyClaimDocument()
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        NonEDIApplyClaimDocument: Codeunit "GXL Non-EDI Apply Claim Doc";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        DocumentNo: Code[20];
        NewStatus: Enum "GXL PDA-PL Receive Status";
    begin
        // For ullaged suppliers, apply return order straight away to the posted receipt, which we know exists because a return order was created.
        // For non-ullaged suppliers, apply credit note after invoice is posted
        DocumentNo := '';
        PDAPLReceiveBuffer.SetCurrentKey(Status, "Document No.");
        PDAPLReceiveBuffer.SetFilter(Status, '%1|%2', PDAPLReceiveBuffer.Status::"Return Order Created", PDAPLReceiveBuffer.Status::"Credit Created");
        PDAPLReceiveBuffer.SetFilter("Claim Document No.", '<>%1', ''); // >> LCB-3 <<
        if PDAPLReceiveBuffer.FindSet(true, true) then
            repeat
                if IsNewDocument(PDAPLReceiveBuffer."Document No.", DocumentNo) then begin
                    ClearLastError();
                    DocumentNo := PDAPLReceiveBuffer."Document No.";
                    if AllLinesHaveStatus(DocumentNo, PDAPLReceiveBuffer.Status) then
                        if ApplyClaimDocumentPrerequisitesMet(PDAPLReceiveBuffer) then begin

                            Clear(NonEDIApplyClaimDocument);

                            //,Create Return Order,Apply Return Order,Post Return Shipment,Post Return Credit
                            NonEDIApplyClaimDocument.SetDocument(PDAPLReceiveBuffer."Document No.", PDAPLReceiveBuffer."Vendor Ullaged Status");

                            //ERP-340 +
                            NonEDIApplyClaimDocument.SetClaimDocType(PDAPLReceiveBuffer."Claim Document Type");
                            //ERP-340 -

                            Commit();
                            ProcessWasSuccess := NonEDIApplyClaimDocument.Run();

                            //ERP-340 +
                            // NewStatus :=
                            //   GetNextStatus(
                            //     PDAPLReceiveBuffer.Status,
                            //     PDAPLReceiveBuffer."Vendor Ullaged Status" = PDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged,
                            //     ProcessWasSuccess);
                            NewStatus :=
                              GetNextStatus(
                                PDAPLReceiveBuffer.Status,
                                PDAPLReceiveBuffer."Vendor Ullaged Status" = PDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged,
                                ProcessWasSuccess,
                                PDAPLReceiveBuffer);
                            //ERP-340 -

                            // Update status if Process was success or Process was not successful due to a non-locking error
                            if ProcessWasSuccess or (not IsLockingError(GetLastErrorCode())) then
                                UpdateBuffer(DocumentNo, ProcessWasSuccess, GetLastErrorText(), NewStatus, '', '', '', '', GetLastErrorCode());

                            //PO,POX,POR,ASN,INV,STKADJ
                            if PDAPLReceiveBuffer."EDI File Log Entry No." <> 0 then
                                InsertEDIDocumentLog(PDAPLReceiveBuffer."EDI File Log Entry No.", 0, ProcessWhat, ProcessWasSuccess);

                            Commit();
                            if IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                                EDIEmailMgt.SendPOClaimApplicationFailureEmail(PDAPLReceiveBuffer, GetLastErrorText());
                        end;
                end;
            until PDAPLReceiveBuffer.Next() = 0;
    end;

    //Post return shipment for claim documents have been applied
    local procedure PostReturnShipment()
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        TempPDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer" temporary;
        NonEDIPostReturnShipment: Codeunit "GXL Non-EDI Post Return Shpt";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        DocumentNo: Code[20];
        NewStatus: Enum "GXL PDA-PL Receive Status";
        ReturnShipmentNo: Code[20];
    begin
        // afntodo User may post the return shipment manually, this has not been catered for

        // Loop buffer records where "Status" = Return Order Created and "Manual Application" = true
        PDAPLReceiveBuffer.SetCurrentKey(Status);
        PDAPLReceiveBuffer.SetRange(Status, PDAPLReceiveBuffer.Status::"Return Order Application Error");
        PDAPLReceiveBuffer.SetFilter("Claim Document No.", '<>%1', '');
        PDAPLReceiveBuffer.SetRange("Manual Application", true);
        if PDAPLReceiveBuffer.FindSet() then
            repeat
                TempPDAPLReceiveBuffer.Reset();
                TempPDAPLReceiveBuffer.TransferFields(PDAPLReceiveBuffer);
                TempPDAPLReceiveBuffer.Insert();
            until PDAPLReceiveBuffer.Next() = 0;

        // Loop records where "Status" = Return Order Applied
        PDAPLReceiveBuffer.Reset();
        PDAPLReceiveBuffer.SetCurrentKey(Status);
        PDAPLReceiveBuffer.SetRange(Status, PDAPLReceiveBuffer.Status::"Return Order Applied");
        PDAPLReceiveBuffer.SetFilter("Claim Document No.", '<>%1', '');
        if PDAPLReceiveBuffer.FindSet() then
            repeat
                TempPDAPLReceiveBuffer.Reset();
                TempPDAPLReceiveBuffer.TransferFields(PDAPLReceiveBuffer);
                TempPDAPLReceiveBuffer.Insert();
            until PDAPLReceiveBuffer.Next() = 0;

        DocumentNo := '';
        TempPDAPLReceiveBuffer.Reset();
        TempPDAPLReceiveBuffer.SetCurrentKey("Document No.");
        if TempPDAPLReceiveBuffer.FindSet() then
            repeat

                if IsNewDocument(TempPDAPLReceiveBuffer."Document No.", DocumentNo) then begin
                    DocumentNo := TempPDAPLReceiveBuffer."Document No.";

                    if AllLinesHaveStatus(DocumentNo, TempPDAPLReceiveBuffer.Status) then begin
                        ClearLastError();
                        Clear(NonEDIPostReturnShipment);

                        Commit();
                        NonEDIPostReturnShipment.SetOptions(TempPDAPLReceiveBuffer."Claim Document No.", DT2DATE(TempPDAPLReceiveBuffer."Received from PDA"));
                        //PS-2046+
                        NonEDIPostReturnShipment.SetMIMUserID(TempPDAPLReceiveBuffer."MIM User ID");
                        //PS-2046-
                        ProcessWasSuccess := NonEDIPostReturnShipment.Run();

                        NonEDIPostReturnShipment.GetPostedDocumentNo(ReturnShipmentNo);

                        if not ProcessWasSuccess then
                            // there is a commit between posting & emailing, so if emailing fails then posting was successful but an error will be returned.
                            ProcessWasSuccess := ReturnShipmentWasPosted(ReturnShipmentNo);

                        //ERP-340 +
                        // NewStatus :=
                        //   GetNextStatus(
                        //     TempPDAPLReceiveBuffer.Status::"Return Order Applied",
                        //     TempPDAPLReceiveBuffer."Vendor Ullaged Status" = TempPDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged,
                        //     ProcessWasSuccess);
                        NewStatus :=
                          GetNextStatus(
                            TempPDAPLReceiveBuffer.Status::"Return Order Applied",
                            TempPDAPLReceiveBuffer."Vendor Ullaged Status" = TempPDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged,
                            ProcessWasSuccess,
                            TempPDAPLReceiveBuffer);
                        //ERP-340 -


                        // Update status if Process was success or Process was not successful due to a non-locking error
                        if ProcessWasSuccess or (not IsLockingError(GetLastErrorCode())) then
                            UpdateBuffer(DocumentNo, ProcessWasSuccess, GetLastErrorText(), NewStatus, '', '', ReturnShipmentNo, '', GetLastErrorCode());

                        //PO,POX,POR,ASN,INV,STKADJ
                        if TempPDAPLReceiveBuffer."EDI File Log Entry No." <> 0 then
                            InsertEDIDocumentLog(TempPDAPLReceiveBuffer."EDI File Log Entry No.", 0, ProcessWhat, ProcessWasSuccess);

                        Commit();
                        if IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                            EDIEmailMgt.SendPOReturnOrderReturnShipmentFailureEmail(TempPDAPLReceiveBuffer, GetLastErrorText());
                    end;

                end;

            until TempPDAPLReceiveBuffer.Next() = 0;
    end;

    //Post purchase credits that have been posted/applied 
    local procedure PostReturnCredit()
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        NonEDIPostPurchaseCredit: Codeunit "GXL Non-EDI Post Purch Credit";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        DocumentNo: Code[20];
        NewStatus: Enum "GXL PDA-PL Receive Status";
        PostedCreditNo: Code[20];
    begin
        DocumentNo := '';
        PDAPLReceiveBuffer.SetCurrentKey(Status, "Document No.");
        PDAPLReceiveBuffer.SetFilter(Status, '%1|%2', PDAPLReceiveBuffer.Status::"Return Shipment Posted", PDAPLReceiveBuffer.Status::"Credit Applied");
        PDAPLReceiveBuffer.SetFilter("Claim Document No.", '<>%1', '');
        if PDAPLReceiveBuffer.FindSet(true, true) then
            repeat
                if IsNewDocument(PDAPLReceiveBuffer."Document No.", DocumentNo) then begin
                    ClearLastError();
                    DocumentNo := PDAPLReceiveBuffer."Document No.";
                    if PostSendClaims(PDAPLReceiveBuffer."Vendor No.") then begin

                        if AllLinesHaveStatus(DocumentNo, PDAPLReceiveBuffer.Status) then
                            if PostReturnCreditPrerequisitesMet(PDAPLReceiveBuffer) then begin //Note: Purchase Invoice No. is returned
                                Clear(NonEDIPostPurchaseCredit);
                                NonEDIPostPurchaseCredit.SetOptions(
                                  MapBufferDocumentType(PDAPLReceiveBuffer."Claim Document Type"),
                                  PDAPLReceiveBuffer."Claim Document No.",
                                  DT2DATE(PDAPLReceiveBuffer."Received from PDA"),
                                  PDAPLReceiveBuffer."Purchase Invoice No.");
                                //PS-2046+
                                NonEDIPostPurchaseCredit.SetMIMUserID(PDAPLReceiveBuffer."MIM User ID");
                                //PS-2046-
                                Commit();
                                ProcessWasSuccess := NonEDIPostPurchaseCredit.Run();
                                NonEDIPostPurchaseCredit.GetPostedDocumentNo(PostedCreditNo);

                                if not ProcessWasSuccess then
                                    // there is a commit between posting & emailing, so if emailing fails then posting was successful but an error will be returned.
                                    ProcessWasSuccess := CreditMemoWasPosted(PostedCreditNo);

                                //ERP-340 +
                                // NewStatus :=
                                //   GetNextStatus(
                                //     PDAPLReceiveBuffer.Status,
                                //     PDAPLReceiveBuffer."Vendor Ullaged Status" = PDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged,
                                //     ProcessWasSuccess);
                                NewStatus :=
                                  GetNextStatus(
                                    PDAPLReceiveBuffer.Status,
                                    PDAPLReceiveBuffer."Vendor Ullaged Status" = PDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged,
                                    ProcessWasSuccess,
                                    PDAPLReceiveBuffer);
                                //ERP-340 -

                                // Update status if Process was success or Process was not successful due to a non-locking error
                                if ProcessWasSuccess or (not IsLockingError(GetLastErrorCode())) then
                                    UpdateBuffer(DocumentNo, ProcessWasSuccess, GetLastErrorText(), NewStatus, '', PDAPLReceiveBuffer."Purchase Invoice No.", '', PostedCreditNo, GetLastErrorCode());

                                //PO,POX,POR,ASN,INV,STKADJ
                                if PDAPLReceiveBuffer."EDI File Log Entry No." <> 0 then
                                    InsertEDIDocumentLog(PDAPLReceiveBuffer."EDI File Log Entry No.", 0, ProcessWhat, ProcessWasSuccess);

                                Commit();
                                if ProcessWasSuccess then begin
                                    EDIEmailMgt.SendPOCreditPostingNotificationEmail(PDAPLReceiveBuffer)
                                end else
                                    if IsErrorEmailRequired(ProcessWasSuccess, GetLastErrorCode()) then
                                        EDIEmailMgt.SendPOReturnCreditPostingFailureEmail(PDAPLReceiveBuffer, GetLastErrorText());
                            end;

                    end else begin
                        //PS-2560 +
                        ProcessWasSuccess := true;
                        //PS-2560 -
                        UpdateBuffer(DocumentNo, ProcessWasSuccess, '', NewStatus::Closed, '', '', '', '', '');

                        //PO,POX,POR,ASN,INV,STKADJ
                        if PDAPLReceiveBuffer."EDI File Log Entry No." <> 0 then
                            InsertEDIDocumentLog(PDAPLReceiveBuffer."EDI File Log Entry No.", 0, ProcessWhat::"Complete without Posting Return Credit", true);

                        Commit();

                    end;

                end;
            until PDAPLReceiveBuffer.Next() = 0;
    end;

    local procedure InsertEDIFileLog(FullFileName: Text; Which: Option PO,POX,POR,ASN,INV,STKADJ): Integer
    var
        EDIProcessManagement: Codeunit "GXL EDI Process Mngt";
    begin
        exit(EDIProcessManagement.InsertEDIFileLog2(FullFileName, Which, 0, '', 0));
    end;

    local procedure UpdateEDIFileLog(EDILogEntryNo: Integer; ProcessWasSuccess: Boolean)
    var
        EDIProcessManagement: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessManagement.UpdateEDIFileLog(EDILogEntryNo, ProcessWasSuccess);
    end;

    local procedure InsertEDIDocumentLog(EDIFileLogEntryNo: Integer; InputProcessWhich: Option PO,POX,POR,ASN,INV,STKADJ;
        InputProcessWhat: Option;
        ImportExportWasSuccess: Boolean)
    var
        EDIProcessManagement: Codeunit "GXL EDI Process Mngt";
    begin
        // InputProcessWhat
        // 0 Validate and Export
        // 1 Import
        // 2 Validate
        // 3 Process
        // 4 Scan
        // 5 Receive
        // 6 Create Return Order
        // 7 Apply Return Order
        // 8 Post Return Shipment
        // 9 Post Return Credit
        // 10 Complete without Posting Return Credit

        EDIProcessManagement.InsertEDIDocumentLog2(EDIFileLogEntryNo, InputProcessWhich, InputProcessWhat, ImportExportWasSuccess, 1);
    end;

    procedure IsLockingError(LockStr: Text): Boolean
    var
        MiscUtils: Codeunit "GXL Misc. Utilities";
    begin
        exit(MiscUtils.IsLockingError(LockStr));
    end;

    local procedure FilterBuffer(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; StatusFilter: Enum "GXL PDA-PL Receive Status"; FilterClaimable: Boolean)
    begin
        PDAPLReceiveBuffer.SetCurrentKey(Status, "Document No.");
        PDAPLReceiveBuffer.SetRange(Status, StatusFilter);
        if FilterClaimable then
            PDAPLReceiveBuffer.SetFilter("Claim Quantity", '>0');
        PDAPLReceiveBuffer.SetRange(Processed, false);
    end;


    local procedure UpdateBuffer(DocumentNo: Code[20]; ProcessWasSuccess: Boolean; ErrorText: Text; NewStatus: Enum "GXL PDA-PL Receive Status";
        PurchRcptNo: Code[20]; PurchInvNo: Code[20]; ReturnShipNo: Code[20]; PurchCrNo: Code[20]; ErrorCode: Text)
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        ClaimMgt: Codeunit "GXL Claim Management";
        PostSendClaim: Boolean;
        VendorNo: Code[20];
    begin
        PDAPLReceiveBuffer.Reset();
        PDAPLReceiveBuffer.SetCurrentKey("Document No.", "Line No.");
        PDAPLReceiveBuffer.SetRange("Document No.", DocumentNo);
        if PDAPLReceiveBuffer.FindSet(true) then begin
            VendorNo := GetVendorNo(PDAPLReceiveBuffer."Vendor No.", 1, PDAPLReceiveBuffer."Document No.");
            PostSendClaim := ClaimMgt.PostSendClaims(VendorNo);
            repeat

                PDAPLReceiveBuffer.Errored := not ProcessWasSuccess;
                PDAPLReceiveBuffer."Error Code" := COPYSTR(ErrorCode, 1, MAXSTRLEN(PDAPLReceiveBuffer."Error Code"));
                PDAPLReceiveBuffer."Error Message" := COPYSTR(ErrorText, 1, MAXSTRLEN(PDAPLReceiveBuffer."Error Message"));
                PDAPLReceiveBuffer.Status := NewStatus;
                PDAPLReceiveBuffer."Post / Send Claim" := PostSendClaim;

                if PurchRcptNo <> '' then
                    PDAPLReceiveBuffer."Purchase Receipt No." := PurchRcptNo;

                if PurchInvNo <> '' then
                    PDAPLReceiveBuffer."Purchase Invoice No." := PurchInvNo;

                if ReturnShipNo <> '' then
                    PDAPLReceiveBuffer."Return Shipment No." := ReturnShipNo;

                if PurchCrNo <> '' then
                    PDAPLReceiveBuffer."Purchase Credit Memo No." := PurchCrNo;

                //PS-2634 +
                //Set as Processed
                //For Status = Return Order Applied and Return Shipment Posted, usually it should be proceed to the next status until Credit Posted
                //But if the return order has been manually posted, then status cannot be determined
                if PDAPLReceiveBuffer.Status in [
                    PDAPLReceiveBuffer.Status::"Return Order Applied",
                    PDAPLReceiveBuffer.Status::"Return Shipment Posted",
                    PDAPLReceiveBuffer.Status::"Credit Posted",
                    PDAPLReceiveBuffer.Status::Closed] then begin
                    PDAPLReceiveBuffer.Processed := true;
                    PDAPLReceiveBuffer."Processing Date Time" := CurrentDateTime();
                end;
                //PS-2634 -

                PDAPLReceiveBuffer.Modify();

            until PDAPLReceiveBuffer.Next() = 0;

        end;
    end;

    local procedure GetSetup()
    begin
        if not SetupRead then begin
            IntegrationSetup.Get();
            SetupRead := true;
        end;
    end;

    procedure PrerequisitesMet(DocumentNo: Code[20]): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        IsPurchaseRelated: Boolean;
        NoLineErrorsFound: Boolean;
        IsNonEDI: Boolean;
    begin
        IsPurchaseRelated := PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DocumentNo);

        if IsPurchaseRelated then  // iso Transfer Related
            NoLineErrorsFound := not DocumentHasError(DocumentNo);

        if IsPurchaseRelated then begin
            IsNonEDI := (PurchaseHeader."GXL EDI Vendor Type" = PurchaseHeader."GXL EDI Vendor Type"::" ") and
                        (PurchaseHeader."GXL Vendor File Exchange" = false)
        end;
        exit(IsPurchaseRelated and NoLineErrorsFound and IsNonEDI);
    end;

    local procedure DocumentHasError(DocumentNo: Code[20]): Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        PDAPLReceiveBuffer.SetCurrentKey("Document No.");
        PDAPLReceiveBuffer.SetRange("Document No.", DocumentNo);
        PDAPLReceiveBuffer.SetRange(Errored, true);
        exit(not PDAPLReceiveBuffer.IsEMpty());
    end;

    local procedure IsShortSupplied(DocumentNo: Code[20]): Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        PDAPLReceiveBuffer.SetCurrentKey("Document No.");
        PDAPLReceiveBuffer.SetRange("Document No.", DocumentNo);
        PDAPLReceiveBuffer.SetFilter("Claim Quantity", '>0');
        exit(not PDAPLReceiveBuffer.IsEMpty());
    end;

    local procedure IsNewDocument(ThisDocumentNo: Code[20]; PreviousDocumentNo: Code[20]): Boolean
    begin
        exit(ThisDocumentNo <> PreviousDocumentNo);
    end;

    local procedure AllLinesHaveStatus(DocumentNo: Code[20]; StatusToCheck: Enum "GXL PDA-PL Receive Status"): Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        SelectLatestVersion();

        PDAPLReceiveBuffer.SetCurrentKey("Document No.");
        PDAPLReceiveBuffer.SetRange("Document No.", DocumentNo);
        PDAPLReceiveBuffer.SetFilter(Status, '<>%1', StatusToCheck);
        exit(PDAPLReceiveBuffer.IsEMpty());
    end;

    local procedure CreateClaimPrerequisitesMet(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer") PrerequisitesMet: Boolean
    var
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        PDAPLReceiveBuffer3: Record "GXL PDA-PL Receive Buffer";
        ClaimMgt: Codeunit "GXL Claim Management";
    begin
        PrerequisitesMet :=
          ClaimMgt.CreatePOClaimPrerequisitesMet(
            PDAPLReceiveBuffer."Vendor Ullaged Status",
            PDAPLReceiveBuffer."Purchase Receipt No.",  // << passed as var
            PDAPLReceiveBuffer."Document No.",
            PDAPLReceiveBuffer."Vendor No.");

        //ERP-340 +
        if PDAPLReceiveBuffer."Purchase Receipt No." = '' then
            exit;
        //ERP-340 -

        PDAPLReceiveBuffer2.SetCurrentKey("Document No.", "Line No.");
        PDAPLReceiveBuffer2.SetRange("Document No.", PDAPLReceiveBuffer."Document No.");
        PDAPLReceiveBuffer2.SetRange("Purchase Receipt No.", '');
        PDAPLReceiveBuffer2.SetFilter("Claim Quantity", '>0');
        if PDAPLReceiveBuffer2.FindSet(true) then
            repeat
                PDAPLReceiveBuffer3.Get(PDAPLReceiveBuffer2."Entry No.");
                PDAPLReceiveBuffer3."Purchase Receipt No." := PDAPLReceiveBuffer."Purchase Receipt No.";
                PDAPLReceiveBuffer3.Modify();
            until PDAPLReceiveBuffer2.Next() = 0;
    end;

    local procedure ApplyClaimDocumentPrerequisitesMet(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer") PreRequisitesMet: Boolean
    var
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        PDAPLReceiveBuffer3: Record "GXL PDA-PL Receive Buffer";
        ClaimMgt: Codeunit "GXL Claim Management";
    begin
        //ERP-340 +
        // PreRequisitesMet :=
        //   ClaimMgt.ApplyClaimPrerequisitesMet(
        //     PDAPLReceiveBuffer."Vendor Ullaged Status",
        //     PDAPLReceiveBuffer."Purchase Invoice No.",  // << passed as var
        //     PDAPLReceiveBuffer."Document No.",
        //     PDAPLReceiveBuffer."Vendor No.");
        PreRequisitesMet :=
          ClaimMgt.ApplyClaimPrerequisitesMet(
            PDAPLReceiveBuffer."Claim Document Type",
            PDAPLReceiveBuffer."Purchase Invoice No.",  // << passed as var
            PDAPLReceiveBuffer."Document No.",
            PDAPLReceiveBuffer."Vendor No.");

        if PDAPLReceiveBuffer."Purchase Invoice No." = '' then
            exit;
        //ERP-340 -

        PDAPLReceiveBuffer2.SetCurrentKey("Document No.", "Line No.");
        PDAPLReceiveBuffer2.SetRange("Document No.", PDAPLReceiveBuffer."Document No.");
        PDAPLReceiveBuffer2.SetRange("Purchase Invoice No.", '');
        PDAPLReceiveBuffer2.SetFilter("Claim Quantity", '>0');
        if PDAPLReceiveBuffer2.FindSet(true) then
            repeat
                PDAPLReceiveBuffer3.Get(PDAPLReceiveBuffer2."Entry No.");
                PDAPLReceiveBuffer3."Purchase Invoice No." := PDAPLReceiveBuffer."Purchase Invoice No.";
                PDAPLReceiveBuffer3.Modify();
            until PDAPLReceiveBuffer2.Next() = 0;
    end;

    local procedure PostReturnCreditPrerequisitesMet(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer") PreRequisitesMet: Boolean
    var
        ClaimMgt: Codeunit "GXL Claim Management";
    begin
        //ERP-340 +
        // PreRequisitesMet :=
        //   ClaimMgt.PostReturnCreditPrerequisitesMet(
        //     PDAPLReceiveBuffer."Vendor Ullaged Status",
        //     PDAPLReceiveBuffer."Purchase Invoice No.",  // << passed as var
        //     PDAPLReceiveBuffer."Document No.",
        //     PDAPLReceiveBuffer."Vendor No.");
        PreRequisitesMet :=
          ClaimMgt.PostReturnCreditPrerequisitesMet(
            PDAPLReceiveBuffer."Claim Document Type",
            PDAPLReceiveBuffer."Purchase Invoice No.",  // << passed as var
            PDAPLReceiveBuffer."Document No.",
            PDAPLReceiveBuffer."Vendor No.");
        //ERP-340 -
    end;

    local procedure GetNextStatus(CurrentStatus: Enum "GXL PDA-PL Receive Status"; VendorIsUllaged: Boolean; ProcessWasSuccess: Boolean) NextStatus: Enum "GXL PDA-PL Receive Status"
    var
        NewStatus: Enum "GXL PDA-PL Receive Status";
    begin
        if ProcessWasSuccess then begin

            if VendorIsUllaged then begin
                CASE CurrentStatus OF
                    CurrentStatus::Received:
                        NextStatus := NewStatus::"Return Order Created";
                    CurrentStatus::"Return Order Created":
                        NextStatus := NewStatus::"Return Order Applied";
                    CurrentStatus::"Return Order Applied":
                        NextStatus := NewStatus::"Return Shipment Posted";
                    CurrentStatus::"Return Shipment Posted":
                        NextStatus := NewStatus::"Credit Posted";
                end;
            end else
                CASE CurrentStatus OF
                    CurrentStatus::Received:
                        NextStatus := NewStatus::"Credit Created";
                    CurrentStatus::"Credit Created":
                        NextStatus := NewStatus::"Credit Applied";
                    CurrentStatus::"Credit Applied":
                        NextStatus := NewStatus::"Credit Posted";
                end;

        end else

            if VendorIsUllaged then begin
                CASE CurrentStatus OF
                    CurrentStatus::Received:
                        NextStatus := NewStatus::"Return Order Creation Error";
                    CurrentStatus::"Return Order Created":
                        NextStatus := NewStatus::"Return Order Application Error";
                    CurrentStatus::"Return Order Applied":
                        NextStatus := NewStatus::"Return Shipment Posting Error";
                    CurrentStatus::"Return Shipment Posted":
                        NextStatus := NewStatus::"Credit Posting Error";
                end;
            end else
                CASE CurrentStatus OF
                    CurrentStatus::Received:
                        NextStatus := NewStatus::"Credit Creation Error";
                    CurrentStatus::"Credit Created":
                        NextStatus := NewStatus::"Credit Application Error";
                    CurrentStatus::"Credit Applied":
                        NextStatus := NewStatus::"Credit Posting Error";
                end;
    end;

    //ERP-340 +
    local procedure GetNextStatus(CurrentStatus: Enum "GXL PDA-PL Receive Status"; VendorIsUllaged: Boolean; ProcessWasSuccess: Boolean;
        PDAPLReceiveBuff: Record "GXL PDA-PL Receive Buffer") NextStatus: Enum "GXL PDA-PL Receive Status"
    var
        NewStatus: Enum "GXL PDA-PL Receive Status";
        NewVendorIsUllaged: Boolean;
    begin
        NewVendorIsUllaged := VendorIsUllaged;
        if PDAPLReceiveBuff."Claim Document Type" = PDAPLReceiveBuff."Claim Document Type"::"Return Order" then
            NewVendorIsUllaged := true;
        if ProcessWasSuccess then begin

            if NewVendorIsUllaged then begin
                CASE CurrentStatus OF
                    CurrentStatus::Received:
                        NextStatus := NewStatus::"Return Order Created";
                    CurrentStatus::"Return Order Created":
                        NextStatus := NewStatus::"Return Order Applied";
                    CurrentStatus::"Return Order Applied":
                        NextStatus := NewStatus::"Return Shipment Posted";
                    CurrentStatus::"Return Shipment Posted":
                        NextStatus := NewStatus::"Credit Posted";
                end;
            end else
                CASE CurrentStatus OF
                    CurrentStatus::Received:
                        NextStatus := NewStatus::"Credit Created";
                    CurrentStatus::"Credit Created":
                        NextStatus := NewStatus::"Credit Applied";
                    CurrentStatus::"Credit Applied":
                        NextStatus := NewStatus::"Credit Posted";
                end;

        end else

            if NewVendorIsUllaged then begin
                CASE CurrentStatus OF
                    CurrentStatus::Received:
                        NextStatus := NewStatus::"Return Order Creation Error";
                    CurrentStatus::"Return Order Created":
                        NextStatus := NewStatus::"Return Order Application Error";
                    CurrentStatus::"Return Order Applied":
                        NextStatus := NewStatus::"Return Shipment Posting Error";
                    CurrentStatus::"Return Shipment Posted":
                        NextStatus := NewStatus::"Credit Posting Error";
                end;
            end else
                CASE CurrentStatus OF
                    CurrentStatus::Received:
                        NextStatus := NewStatus::"Credit Creation Error";
                    CurrentStatus::"Credit Created":
                        NextStatus := NewStatus::"Credit Application Error";
                    CurrentStatus::"Credit Applied":
                        NextStatus := NewStatus::"Credit Posting Error";
                end;
    end;
    //ERP-340 -

    local procedure ReceiptWasPosted(DocumentNo: Code[20]): Boolean
    var
        PurchRcptHeader: Record "Purch. Rcpt. Header";
    begin
        SelectLatestVersion();
        PurchRcptHeader.SetRange("No.", DocumentNo);
        exit(not PurchRcptHeader.IsEMpty());
    end;

    local procedure ReturnShipmentWasPosted(DocumentNo: Code[20]): Boolean
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
    begin
        SelectLatestVersion();
        ReturnShipmentHeader.SetRange("No.", DocumentNo);
        exit(not ReturnShipmentHeader.IsEMpty());
    end;

    local procedure CreditMemoWasPosted(DocumentNo: Code[20]): Boolean
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        SelectLatestVersion();
        PurchCrMemoHdr.SetRange("No.", DocumentNo);
        exit(not PurchCrMemoHdr.IsEMpty());
    end;

    local procedure ReceiveOrClose(DocumentNo: Code[20]): Enum "GXL PDA-PL Receive Status"
    var
        NewStatus: Enum "GXL PDA-PL Receive Status";
    begin
        if IsShortSupplied(DocumentNo) then
            NewStatus := NewStatus::Received  // more stuff to do after this
        else
            NewStatus := NewStatus::Closed;  // end of the line

        exit(NewStatus);
    end;

    procedure ResetError(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; ShowConfirmationMessage: Boolean)
    var
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        PDAPLReceiveBuffer3: Record "GXL PDA-PL Receive Buffer";
        TempDocumentSearchResult: Record "Document Search Result" temporary;
        Confirmed: Boolean;
    begin
        PDAPLReceiveBuffer.SetRange(Errored, true);
        if PDAPLReceiveBuffer.FindSet(true) then begin

            GetUniqueDocumentNos(PDAPLReceiveBuffer, TempDocumentSearchResult);

            if ShowConfirmationMessage then
                Confirmed := CONFIRM(STRSUBSTNO(NoOfDocResetConfirmMsg, TempDocumentSearchResult.Count()))
            else
                Confirmed := true;

            if Confirmed then begin
                TempDocumentSearchResult.FindSet();
                repeat
                    PDAPLReceiveBuffer2.SetCurrentKey("Document No.");
                    PDAPLReceiveBuffer2.SetRange("Document No.", TempDocumentSearchResult."Doc. No.");
                    if PDAPLReceiveBuffer2.FindSet(true) then
                        repeat
                            if PDAPLReceiveBuffer2.Status IN [
                              PDAPLReceiveBuffer2.Status::"Processing Error",
                              PDAPLReceiveBuffer2.Status::"Receiving Error",
                              PDAPLReceiveBuffer2.Status::"Return Order Creation Error",
                              PDAPLReceiveBuffer2.Status::"Return Order Application Error",
                              PDAPLReceiveBuffer2.Status::"Return Shipment Posting Error",
                              PDAPLReceiveBuffer2.Status::"Credit Creation Error",
                              PDAPLReceiveBuffer2.Status::"Credit Application Error",
                              PDAPLReceiveBuffer2.Status::"Credit Posting Error"] then begin
                                PDAPLReceiveBuffer3.Get(PDAPLReceiveBuffer2."Entry No.");
                                PDAPLReceiveBuffer3.ResetError();
                                PDAPLReceiveBuffer3.Modify();
                            end;

                        until PDAPLReceiveBuffer2.Next() = 0;
                until TempDocumentSearchResult.Next() = 0;
            end;

        end else
            if ShowConfirmationMessage then
                MESSAGE(NothingToResetMsg);
    end;

    local procedure GetUniqueDocumentNos(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; var TempDocumentSearchResult: Record "Document Search Result" temporary)
    begin
        if PDAPLReceiveBuffer.FindSet() then
            repeat
                if not TempDocumentSearchResult.Get(0, PDAPLReceiveBuffer."Document No.", 0) then begin
                    TempDocumentSearchResult.Init();
                    TempDocumentSearchResult."Doc. No." := PDAPLReceiveBuffer."Document No.";
                    TempDocumentSearchResult.Insert();
                end;
            until PDAPLReceiveBuffer.Next() = 0;
    end;

    local procedure PostSendClaims(VendorNo: Code[20]): Boolean
    var
        ClaimMgt: Codeunit "GXL Claim Management";
    begin
        exit(ClaimMgt.PostSendClaims(VendorNo));
    end;

    local procedure MapBufferDocumentType(InputType: Option " ","Transfer Order","Credit Memo","Return Order"): Integer
    var
        PurchHead: Record "Purchase Header";
    begin
        CASE InputType OF
            InputType::"Credit Memo":
                exit(PurchHead."Document Type"::"Credit Memo");
            InputType::"Return Order":
                exit(PurchHead."Document Type"::"Return Order");
            else
                ERROR(InvalidDocTyeMsg);
        end;
    end;

    local procedure IsErrorEmailRequired(InputProcessWasSuccess: Boolean; InputLastErrorCode: Text): Boolean
    begin
        if (not InputProcessWasSuccess) and (not IsLockingError(InputLastErrorCode)) then
            exit(true)
        else
            exit(false);
    end;

    local procedure GetVendorNo(VendorNo: Code[20]; DocumentType: Option; DocumentNo: Code[20]): Code[20]
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        if VendorNo <> '' then
            exit(VendorNo)
        else begin
            if PurchaseHeader.Get(DocumentType, DocumentNo) then
                exit(PurchaseHeader."Buy-from Vendor No.");
        end;
    end;

    local procedure ClearPDAReceivingBufferErrors()
    var
        ClearPDARecBufferError: Codeunit "GXL Clear PDA Rec Buffer Error";
        EDIEmailManagement: Codeunit "GXL EDI Email Management";
        ValueRetention: Codeunit "GXL Value Retention";
        ClearingBuffersWasSuccess: Boolean;
    begin
        Commit();

        ClearLastError();
        ClearingBuffersWasSuccess := ClearPDARecBufferError.Run();

        if not ClearingBuffersWasSuccess then begin

            if IsErrorEmailRequired(ClearingBuffersWasSuccess, GetLastErrorCode()) then
                EDIEmailManagement.SendNonEDIPDAReceivingBufferClearingEmail(ValueRetention.GetText(), GetLastErrorText());

        end;
    end;

    procedure ManualClearPDAReceivingBufferErrors(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; ShowMessage: Boolean)
    var
        TempDocumentSearchResult: Record "Document Search Result" temporary;
        ClearPDARecBufferError: Codeunit "GXL Clear PDA Rec Buffer Error";
        Confirmed: Boolean;
    begin
        PDAPLReceiveBuffer.SetRange(Errored, true);
        if PDAPLReceiveBuffer.FindSet() then begin

            GetUniqueDocumentNos(PDAPLReceiveBuffer, TempDocumentSearchResult);

            if ShowMessage then
                Confirmed := Confirm(StrSubstNo(NoOfDocClearConfirmMsg, TempDocumentSearchResult.Count()))
            else
                Confirmed := true;

            if Confirmed then begin
                TempDocumentSearchResult.FindSet();
                repeat
                    ClearPDARecBufferError.SetOptions(TempDocumentSearchResult."Doc. No.", ShowMessage);
                    ClearPDARecBufferError.Run();
                until TempDocumentSearchResult.Next() = 0;

            end;
            TempDocumentSearchResult.DeleteAll();
        end else
            if ShowMessage then
                Message(NothingToClearMsg);
    end;


}