codeunit 50264 "GXL Clear PDA Rec Buffer Error"
{
    Permissions = tabledata "GXL PDA-PL Receive Buffer" = m;

    trigger OnRun()
    begin
        ClearPDARecBufferEntriesProcessingError(DocumentNoFilter);
        ClearPDARecBufferEntriesReceivingError(DocumentNoFilter);
        ClearPDARecBufferEntriesReturnShipmentPostingError(DocumentNoFilter);
        ClearPDARecBufferEntriesCreditPostingError(DocumentNoFilter);
        ClearPDARecBufferEntriesUntrappedLockingError(DocumentNoFilter);
    end;

    var
        DocumentNoFilter: Code[20];
        ManualClearing: Boolean;

        OrderStatusNotBeClosedMsg: Label 'Posting Error: Order Status must not be Closed in Purchase Header Document Type=Order,No.=%1.';
        CannotReceiveMoreThanMsg: Label 'You cannot receive more than %1 units for item %2 on order %3';
        NothingToPostMsg: Label 'Posting Error: There is nothing to post.';
        NothingToPostTxt: Label 'There is nothing to post.';
        OrderStatusMustBeCancelledMsg: Label 'Order Status must not be Cancelled in Purchase Header Document Type=Order,No.=%1.';
        OrderStatusMustBeConfirmed_CreatedMsg: Label 'Posting Error: Order Status must be equal to Confirmed in Purchase Header: Document Type=Order, No.=%1. Current value is Created.';
        OrderStatusMustBeConfirmed_NewMsg: Label 'Posting Error: Order Status must be equal to Confirmed in Purchase Header: Document Type=Order, No.=%1. Current value is New.';
        OrderDoesNotExistMsg: Label 'Posting Error: The Purchase Header does not exist. Identification fields and values: Document Type=Order,No.=%1';

    procedure SetOptions(DocumentNoFilterNew: Code[20]; ManualClearingNew: Boolean)
    begin
        DocumentNoFilter := DocumentNoFilterNew;
        ManualClearing := ManualClearingNew;
    end;

    local procedure ClearPDARecBufferEntriesProcessingError(InputDocumentNo: Code[20])
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        ValueRetention: Codeunit "GXL Value Retention";
        BufferUpdated: Boolean;
        DocumentNo: Code[20];
        ExpectedErrorText: Text;
        ExpectedErrorText2: Text;
    begin
        DocumentNo := '';
        PDAPLReceiveBuffer.SetCurrentKey(Status, "Document No.");
        PDAPLReceiveBuffer.SetRange(Status, PDAPLReceiveBuffer.Status::"Processing Error");
        if InputDocumentNo <> '' then
            PDAPLReceiveBuffer.SetRange("Document No.", InputDocumentNo);
        if PDAPLReceiveBuffer.FindSet(true, true) then
            repeat
                if EDIFunctionsLibrary.IsNewDocumentNo(PDAPLReceiveBuffer."Document No.", DocumentNo) then begin
                    DocumentNo := PDAPLReceiveBuffer."Document No.";

                    ValueRetention.ClearText();
                    ValueRetention.SetText(DocumentNo);

                    ExpectedErrorText := StrSubstNo(CannotReceiveMoreThanMsg, PDAPLReceiveBuffer.QtyOrdered, PDAPLReceiveBuffer."No.", PDAPLReceiveBuffer."Document No.");
                    ExpectedErrorText2 := StrSubstNo(OrderStatusMustBeCancelledMsg, PDAPLReceiveBuffer."Document No.");

                    case true of

                        EDIFunctionsLibrary.TextMatches(ExpectedErrorText, PDAPLReceiveBuffer."Error Message", true):
                            begin
                                BufferUpdated := ClearQuantityToReceiveProcessingError(DocumentNo);
                            end;

                        EDIFunctionsLibrary.TextMatches(ExpectedErrorText2, PDAPLReceiveBuffer."Error Message", true):
                            begin
                                if EDIFunctionsLibrary.AllLinesHaveSameStatus(DocumentNo, PDAPLReceiveBuffer.Status) then
                                    BufferUpdated := ClearOrderMustNotBeCancelledProcessingError(DocumentNo);
                            end;

                    end;

                    if BufferUpdated then
                        Commit();

                end;

            until PDAPLReceiveBuffer.Next() = 0;
    end;

    local procedure ClearPDARecBufferEntriesReceivingError(InputDocumentNo: Code[20])
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        ValueRetention: Codeunit "GXL Value Retention";
        BufferUpdated: Boolean;
        DocumentNo: Code[20];
        ExpectedErrorText: Text;
        ExpectedErrorText2: Text;
        ExpectedErrorText3: Text;
        ExpectedErrorText4: Text;
    begin
        DocumentNo := '';
        PDAPLReceiveBuffer.SetCurrentKey(Status, "Document No.");
        PDAPLReceiveBuffer.SetRange(Status, PDAPLReceiveBuffer.Status::"Receiving Error");
        if InputDocumentNo <> '' then
            PDAPLReceiveBuffer.SetFilter("Document No.", InputDocumentNo);
        if PDAPLReceiveBuffer.FindSet(true, true) then
            repeat
                if EDIFunctionsLibrary.IsNewDocumentNo(PDAPLReceiveBuffer."Document No.", DocumentNo) then begin
                    DocumentNo := PDAPLReceiveBuffer."Document No.";

                    ValueRetention.ClearText();
                    ValueRetention.SetText(DocumentNo);

                    if EDIFunctionsLibrary.AllLinesHaveSameStatus(DocumentNo, PDAPLReceiveBuffer.Status) then begin
                        ExpectedErrorText := StrSubstNo(OrderStatusNotBeClosedMsg, PDAPLReceiveBuffer."Document No.");
                        ExpectedErrorText2 := StrSubstNo(OrderStatusMustBeConfirmed_CreatedMsg, PDAPLReceiveBuffer."Document No.");
                        ExpectedErrorText3 := StrSubstNo(OrderStatusMustBeConfirmed_NewMsg, PDAPLReceiveBuffer."Document No.");
                        ExpectedErrorText4 := StrSubstNo(OrderDoesNotExistMsg, PDAPLReceiveBuffer."Document No.");

                        case true of
                            EDIFunctionsLibrary.TextMatches(ExpectedErrorText, PDAPLReceiveBuffer."Error Message", true):
                                begin
                                    BufferUpdated := ClearErrorOrderStatusMustNotBeClosedError(DocumentNo, PDAPLReceiveBuffer."Vendor No.");
                                end;

                            EDIFunctionsLibrary.TextMatches(NothingToPostMsg, PDAPLReceiveBuffer."Error Message", true):
                                begin
                                    BufferUpdated := ClearPostingErrorThereIsNothingToPostError(DocumentNo, PDAPLReceiveBuffer."Vendor No.");
                                end;

                            EDIFunctionsLibrary.TextMatches(ExpectedErrorText2, PDAPLReceiveBuffer."Error Message", true):
                                begin
                                    BufferUpdated := ClearPDARecBufferEntriesOrderStatusMustBeConfirmedError(DocumentNo);
                                end;

                            EDIFunctionsLibrary.TextMatches(ExpectedErrorText3, PDAPLReceiveBuffer."Error Message", true):
                                begin
                                    BufferUpdated := ClearPDARecBufferEntriesOrderStatusMustBeConfirmedError(DocumentNo);
                                end;

                            EDIFunctionsLibrary.TextMatches(ExpectedErrorText4, PDAPLReceiveBuffer."Error Message", true):
                                begin
                                    BufferUpdated := ClearPostingErrorThePurchaseHeaderDoesNotExistsError(DocumentNo, PDAPLReceiveBuffer."Vendor No.");
                                end;
                        end;
                    end;

                    if BufferUpdated then
                        Commit();

                end;
            until PDAPLReceiveBuffer.Next() = 0;
    end;

    local procedure ClearPDARecBufferEntriesReturnShipmentPostingError(InputDocumentNo: Code[20])
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        ValueRetention: Codeunit "GXL Value Retention";
        BufferUpdated: Boolean;
        DocumentNo: Code[20];
    begin
        DocumentNo := '';
        PDAPLReceiveBuffer.SetCurrentKey(Status, "Document No.");
        PDAPLReceiveBuffer.SetRange(Status, PDAPLReceiveBuffer.Status::"Return Shipment Posting Error");
        if InputDocumentNo <> '' then
            PDAPLReceiveBuffer.SetFilter("Document No.", InputDocumentNo);
        if PDAPLReceiveBuffer.FindSet(true, true) then
            repeat
                if EDIFunctionsLibrary.IsNewDocumentNo(PDAPLReceiveBuffer."Document No.", DocumentNo) then begin
                    DocumentNo := PDAPLReceiveBuffer."Document No.";

                    ValueRetention.ClearText();
                    ValueRetention.SetText(DocumentNo);

                    if EDIFunctionsLibrary.AllLinesHaveSameStatus(DocumentNo, PDAPLReceiveBuffer.Status) then begin
                        if EDIFunctionsLibrary.TextMatches(NothingToPostTxt, PDAPLReceiveBuffer."Error Message", true) then begin
                            BufferUpdated := ClearThereIsNothingToPostError(DocumentNo, PDAPLReceiveBuffer."Vendor No.");
                        end;
                    end;

                    if BufferUpdated then
                        Commit();
                end;
            until PDAPLReceiveBuffer.Next() = 0;
    end;

    local procedure ClearPDARecBufferEntriesCreditPostingError(InputDocumentNo: Code[20])
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        ValueRetention: Codeunit "GXL Value Retention";
        BufferUpdated: Boolean;
        DocumentNo: Code[20];
    begin
        DocumentNo := '';
        PDAPLReceiveBuffer.SetCurrentKey(Status, "Document No.");
        PDAPLReceiveBuffer.SetRange(Status, PDAPLReceiveBuffer.Status::"Credit Posting Error");
        if InputDocumentNo <> '' then
            PDAPLReceiveBuffer.SetFilter("Document No.", InputDocumentNo);
        if PDAPLReceiveBuffer.FindSet(true, true) then
            repeat
                if EDIFunctionsLibrary.IsNewDocumentNo(PDAPLReceiveBuffer."Document No.", DocumentNo) then begin
                    DocumentNo := PDAPLReceiveBuffer."Document No.";

                    ValueRetention.ClearText();
                    ValueRetention.SetText(DocumentNo);

                    if EDIFunctionsLibrary.AllLinesHaveSameStatus(DocumentNo, PDAPLReceiveBuffer.Status) then begin
                        if EDIFunctionsLibrary.TextMatches(NothingToPostTxt, PDAPLReceiveBuffer."Error Message", true) then begin
                            BufferUpdated := ClearThereIsNothingToPostError(DocumentNo, PDAPLReceiveBuffer."Vendor No.");
                        end;
                    end;

                    if BufferUpdated then
                        Commit();
                end;
            until PDAPLReceiveBuffer.Next() = 0;

    end;

    local procedure ClearPDARecBufferEntriesUntrappedLockingError(InputDocumentNo: Code[20])
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        DocumentNo: Code[20];
    begin
        DocumentNo := '';
        //PS-2634 +
        //PDAPLReceiveBuffer.SetCurrentKey(Processed, Errored);
        // PDAPLReceiveBuffer.SetRange(Processed, false);
        // PDAPLReceiveBuffer.SetRange(Errored, true);
        PDAPLReceiveBuffer.SetCurrentKey(Errored, Processed);
        PDAPLReceiveBuffer.SetRange(Errored, true);
        PDAPLReceiveBuffer.SetRange(Processed, false);
        //PS-2634 -
        if InputDocumentNo <> '' then
            PDAPLReceiveBuffer.SetRange("Document No.", InputDocumentNo);
        if PDAPLReceiveBuffer.FindSet(true, true) then
            repeat
                if EDIFunctionsLibrary.IsNewDocumentNo(PDAPLReceiveBuffer."Document No.", DocumentNo) then begin
                    DocumentNo := PDAPLReceiveBuffer."Document No.";
                    if EDIFunctionsLibrary.AllLinesHaveSameStatus(DocumentNo, PDAPLReceiveBuffer.Status) then begin
                        if EDIFunctionsLibrary.IsUntrappedLockingError(PDAPLReceiveBuffer."Error Message") then begin
                            EDIFunctionsLibrary.ResetPDAReceivingBufferError(DocumentNo);
                            Commit();
                        end;
                    end;
                end;
            until PDAPLReceiveBuffer.Next() = 0;
    end;

    local procedure ClearQuantityToReceiveProcessingError(InputDocumentNo: Code[20]) BufferUpdated: Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
    begin
        PDAPLReceiveBuffer.SetCurrentKey(Status, "Document No.");
        PDAPLReceiveBuffer.SetRange(Status, PDAPLReceiveBuffer.Status::"Processing Error");
        PDAPLReceiveBuffer.SetRange("Document No.", InputDocumentNo);
        if PDAPLReceiveBuffer.FindSet() then
            repeat
                PDAPLReceiveBuffer2.Get(PDAPLReceiveBuffer."Entry No.");
                PDAPLReceiveBuffer2.QtyToReceive := PDAPLReceiveBuffer2.QtyOrdered;
                PDAPLReceiveBuffer2.InvoiceQuantity := PDAPLReceiveBuffer2.QtyOrdered;
                PDAPLReceiveBuffer2.Errored := false;
                PDAPLReceiveBuffer2."Error Code" := '';
                PDAPLReceiveBuffer2."Error Message" := '';
                PDAPLReceiveBuffer2.Status := PDAPLReceiveBuffer2.Status::Processed;
                PDAPLReceiveBuffer2."Entry Closed" := EDIFunctionsLibrary.GetPDARecBufferClosedEntryStatus(ManualClearing);
                PDAPLReceiveBuffer2.Modify();

                if not BufferUpdated then
                    BufferUpdated := true;

            until PDAPLReceiveBuffer.Next() = 0;
    end;

    local procedure ClearErrorOrderStatusMustNotBeClosedError(DocumentNo: Code[20]; VendorNo: Code[20]) BufferUpdated: Boolean
    begin
        BufferUpdated := ReceivePDAReceivingBuffer(DocumentNo, VendorNo);
    end;

    local procedure ClearPostingErrorThereIsNothingToPostError(DocumentNo: Code[20]; VendorNo: Code[20]) BufferUpdated: Boolean
    var
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
    begin
        if ReceivePDAReceivingBuffer(DocumentNo, VendorNo) then begin
            BufferUpdated := true;
        end else begin
            if EDIFunctionsLibrary.PDANothingReceived(DocumentNo) then begin
                if not EDIFunctionsLibrary.PurchaseOrderIsCancelled(DocumentNo) then
                    EDIFunctionsLibrary.CancelPurchaseOrder(DocumentNo);

                UpdatePDAReceivingBuffer(DocumentNo, true, true, 20, '', '', '', '');  // 20=Closed
                BufferUpdated := true;
            end;
        end;
    end;

    procedure ClearThereIsNothingToPostError(DocumentNo: Code[20]; VendorNo: Code[20]) BufferUpdated: Boolean
    var
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        ClaimDocumentType: Option " ","Transfer Order","Credit Memo","Return Order";
        ClaimDocumentNo: Code[20];
        ReturnShipmentNo: Code[20];
        NewStatus: Enum "GXL PDA-PL Receive Status";
    begin
        if EDIFunctionsLibrary.OrderHasClaims(DocumentNo, ClaimDocumentType, ClaimDocumentNo) then begin
            if ClaimDocumentNo <> '' then begin
                case ClaimDocumentType of // ,Transfer Order,Credit Memo,Return Order
                    ClaimDocumentType::"Credit Memo":
                        begin
                            //commented until can be tested
                            /*
                            if EDIFunctionsLibrary.CreditMemoIsPosted(DocumentNo, VendorNo, CreditMemoNo) then begin
                                UpdatePDAReceivingBuffer(DocumentNo, true, false, 19, '', '', CreditMemoNo, ''); // 11 = Credit Posted

                                BufferUpdated := true;
                            end
                            else begin
                                EDIFunctionsLibrary.ResetPDAReceivingBufferError(DocumentNo);

                                BufferUpdated := true;
                            end;

                            */
                        end;

                    ClaimDocumentType::"Return Order":
                        begin
                            if EDIFunctionsLibrary.ReturnOrderIsShipped(DocumentNo, VendorNo, ReturnShipmentNo) then begin
                                UpdatePDAReceivingBuffer(DocumentNo, true, false, NewStatus::"Return Shipment Posted", '', '', ReturnShipmentNo, '');
                                BufferUpdated := true;
                            end else begin
                                EDIFunctionsLibrary.ResetPDAReceivingBufferError(DocumentNo);
                                BufferUpdated := true;
                            end;
                        end;
                end;
            end;
        end;
    end;

    procedure ClearOrderMustNotBeCancelledProcessingError(DocumentNo: Code[20]) BufferUpdated: Boolean
    var
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        NewStatus: Enum "GXL PDA-PL Receive Status";
    begin
        if EDIFunctionsLibrary.PurchaseOrderIsCancelled(DocumentNo) then begin
            if EDIFunctionsLibrary.PDANothingReceived(DocumentNo) then begin
                UpdatePDAReceivingBuffer(DocumentNo, true, true, NewStatus::Closed, '', '', '', '');
                BufferUpdated := true;
            end;

        end;
    end;

    local procedure ReceivePDAReceivingBuffer(DocumentNo: Code[20]; VendorNo: Code[20]) BufferUpdated: Boolean
    var
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        InvoiceNo: Code[20];
        ReceiptNo: Code[20];
        NewStatus: Enum "GXL PDA-PL Receive Status";
    begin
        if EDIFunctionsLibrary.PurchaseOrderIsReceived(DocumentNo, VendorNo, ReceiptNo) then begin
            InvoiceNo := EDIFunctionsLibrary.GetPostedPurchaseInvoiceNo(DocumentNo, VendorNo);
            UpdatePDAReceivingBuffer(DocumentNo, true, false, NewStatus::Received, ReceiptNo, InvoiceNo, '', '');
            BufferUpdated := true;
        end;
    end;

    local procedure UpdatePDAReceivingBuffer(DocumentNo: Code[20]; ClearError: Boolean; NewProcessed: Boolean;
        NewStatus: Enum "GXL PDA-PL Receive Status"; ReceiptNo: Code[20]; InvoiceNo: Code[20]; ReturnShipmentNo: Code[20]; PostedCreditNo: Code[20])
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
    begin
        PDAPLReceiveBuffer.SetCurrentKey("Document No.");
        PDAPLReceiveBuffer.SetRange("Document No.", DocumentNo);
        if PDAPLReceiveBuffer.FindSet() then
            repeat
                PDAPLReceiveBuffer2.Get(PDAPLReceiveBuffer."Entry No.");

                if ClearError then begin
                    PDAPLReceiveBuffer2.Errored := false;
                    PDAPLReceiveBuffer2."Error Code" := '';
                    PDAPLReceiveBuffer2."Error Message" := '';
                end;

                PDAPLReceiveBuffer2.Processed := NewProcessed;
                PDAPLReceiveBuffer2.Status := NewStatus;

                PDAPLReceiveBuffer2."Entry Closed" := EDIFunctionsLibrary.GetPDARecBufferClosedEntryStatus(ManualClearing);

                if PDAPLReceiveBuffer2."Purchase Receipt No." = '' then
                    PDAPLReceiveBuffer2."Purchase Receipt No." := ReceiptNo;

                if PDAPLReceiveBuffer2."Purchase Invoice No." = '' then
                    PDAPLReceiveBuffer2."Purchase Invoice No." := InvoiceNo;

                if PDAPLReceiveBuffer2."Return Shipment No." = '' then
                    PDAPLReceiveBuffer2."Return Shipment No." := ReturnShipmentNo;

                if PDAPLReceiveBuffer2."Purchase Credit Memo No." = '' then
                    PDAPLReceiveBuffer2."Purchase Credit Memo No." := PostedCreditNo;

                PDAPLReceiveBuffer2.Modify();

            until PDAPLReceiveBuffer.Next() = 0;
    end;

    local procedure ClearPDARecBufferEntriesOrderStatusMustBeConfirmedError(InputDocumentNo: Code[20]) BufferUpdated: Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        SCPurchaseOrderStatusMgt: Codeunit "GXL SC-Purch. Order Status Mgt";
    begin
        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, InputDocumentNo) then
            exit;

        if SCPurchaseOrderStatusMgt.PlainConfirmPurchaseOrder(PurchaseHeader) then begin
            EDIFunctionsLibrary.ResetPDAReceivingBufferError(InputDocumentNo);
            BufferUpdated := true;
        end;
    end;

    local procedure ClearPostingErrorThePurchaseHeaderDoesNotExistsError(InputDocumentNo: Code[20]; InputVendorNo: Code[20]) BufferUpdated: Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        InvoiceNo: Code[20];
        ReceiptNo: Code[20];
        NewStatus: Enum "GXL PDA-PL Receive Status";
    begin
        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, InputDocumentNo) then begin
            if EDIFunctionsLibrary.PurchaseOrderIsReceived(InputDocumentNo, InputVendorNo, ReceiptNo) then
                InvoiceNo := EDIFunctionsLibrary.GetPostedPurchaseInvoiceNo(InputDocumentNo, InputVendorNo);

            UpdatePDAReceivingBuffer(InputDocumentNo, true, true, NewStatus::Closed, ReceiptNo, InvoiceNo, '', '');
            BufferUpdated := true;
        end;
    end;

}