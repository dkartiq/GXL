codeunit 50382 "GXL P2P-Proc Purch. Ord. Resp."
{
    //TODO: Order Status - P2P process purchase order response, only Placed status is accepted
    TableNo = "GXL EDI-Purchase Messages";

    trigger OnRun()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchOrderStatusMgt: Codeunit "GXL SC-Purch. Order Status Mgt";
        EDIProcessManagement: Codeunit "GXL EDI Process Mngt";
    begin
        PurchaseHeader.RESET();

        IF NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec.DocumentNumber) THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Txt, Rec.DocumentNumber));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseHeader."GXL Order Status" < PurchaseHeader."GXL Order Status"::Placed THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text003Txt, Rec.DocumentNumber));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::Confirmed THEN BEGIN
            IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Cancelled THEN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text005Txt, Rec.DocumentNumber, PurchaseHeader."No."))
            ELSE
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text002Txt, Rec.DocumentNumber));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF NOT PurchaseHeader."GXL Vendor File Sent" THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text004Txt, Rec.DocumentNumber));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        UpdateP2PPORLines(Rec.DocumentNumber);

        CLEAR(PurchOrderStatusMgt);
        PurchOrderStatusMgt.SetEDIOptions(FALSE, TRUE);
        PurchOrderStatusMgt.ConfirmPurchHeader(PurchaseHeader);
        EDIProcessManagement.UpdateEDIPurchaseMessageStatus(Rec.ImportDoc, Rec.DocumentNumber, Rec.Status::Processed);
        COMMIT();
    end;

    var
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        Text001Txt: Label 'Purchase Order for PO Response %1 doesn''t exist.';
        Text002Txt: Label 'Purchase Order has already been confirmed for PO Response %1';
        Text003Txt: Label 'Order has not been placed for PO Response %1';
        Text004Txt: Label 'Vendor File has not been sent yet for PO Response %1';
        Text005Txt: Label 'The Purchase Order Response %1 was not accepted because the Purchase Order %2 has been cancelled.';

    local procedure UpdateP2PPORLines(InputDocumentNumber: Code[20])
    var
        EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
        PurchaseLine: Record "Purchase Line";
    begin
        EDIPurchaseMessages.SETCURRENTKEY(ImportDoc, DocumentNumber, LineReference);
        EDIPurchaseMessages.SETRANGE(ImportDoc, EDIPurchaseMessages.ImportDoc::"1");
        EDIPurchaseMessages.SETRANGE(DocumentNumber, InputDocumentNumber);
        IF EDIPurchaseMessages.FINDSET() THEN BEGIN
            REPEAT
                PurchaseLine.GET(PurchaseLine."Document Type"::Order, InputDocumentNumber, EDIPurchaseMessages.LineReference);
                PurchaseLine.SuspendStatusCheck(TRUE);
                PurchaseLine.SuspendOrderStatusCheck(TRUE);
                PurchaseLine.VALIDATE("GXL Confirmed Quantity", EDIPurchaseMessages.ConfirmedOrderQtyOM);
                PurchaseLine.MODIFY(TRUE);
            UNTIL EDIPurchaseMessages.NEXT() = 0;
        END;
    end;
}

