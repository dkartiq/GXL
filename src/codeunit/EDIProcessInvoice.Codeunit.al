codeunit 50374 "GXL EDI-Process Invoice"
{
    TableNo = "GXL PO INV Header";

    trigger OnRun()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLines: Record "Purchase Line";
        POINVLines: Record "GXL PO INV Line";
        POINVHeader: Record "GXL PO INV Header";
        ASNHeader: Record "GXL ASN Header";
    begin
        PurchaseHeader.RESET();
        PurchaseLines.RESET();

        IF NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec."Purchase Order No.") THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Txt, Rec."No."));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF ManualProcess THEN BEGIN
            IF PurchaseHeader."GXL Last EDI Document Status" <> PurchaseHeader."GXL Last EDI Document Status"::ASN THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text002Txt, Rec."No."));
                EDIErrorMgt.ThrowErrorMessage();
            END;
        END ELSE BEGIN
            IF PurchaseHeader."GXL Last EDI Document Status" <> PurchaseHeader."GXL Last EDI Document Status"::INV THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text002Txt, Rec."No."));
                EDIErrorMgt.ThrowErrorMessage();
            END;
        END;

        IF ManualProcess AND NOT HideConfirmationDialog THEN
            IF NOT DIALOG.CONFIRM(STRSUBSTNO(Text005Txt, Rec."No.")) THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text006Txt, UserId()));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        //TODO: Order Status - EDI Process INV, only Closed status is accepted
        IF PurchaseHeader."GXL Order Status" <> PurchaseHeader."GXL Order Status"::Closed THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text003Txt, Rec."No."));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        //TODO: Vendor File Sent flag is not applicable for now as PO was created from NAV13        
        IF NOT PurchaseHeader."GXL Vendor File Sent" THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text004Txt, Rec."No."));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        PurchaseHeader."Vendor Invoice No." := Rec."Original EDI Document No.";
        IF ManualProcess THEN BEGIN
            PurchaseHeader."GXL EDI Ord. Manually Invoiced" := TRUE;

            POINVLines.SETRANGE("INV No.", Rec."No.");
            IF POINVLines.FindSet() THEN
                REPEAT
                    PurchaseLines.SETRANGE("Document Type", PurchaseLines."Document Type"::Order);
                    PurchaseLines.SETRANGE("Document No.", PurchaseHeader."No.");
                    PurchaseLines.SETRANGE("Line No.", POINVLines."PO Line No.");
                    IF PurchaseLines.FindFirst() THEN
                        PurchaseLines.VALIDATE("Direct Unit Cost", POINVLines."Direct Unit Cost");
                UNTIL POINVLines.Next() = 0;
        END;

        //Post
        PurchaseHeader.Invoice := TRUE;
        PurchaseHeader.Receive := FALSE;
        CODEUNIT.RUN(CODEUNIT::"Purch.-Post", PurchaseHeader);

        POINVHeader := Rec;
        ASNHeader.SETRANGE("Document Type", ASNHeader."Document Type"::Purchase);
        ASNHeader.SETRANGE("No.", Rec."ASN Number");
        IF ASNHeader.FindFirst() THEN
            POINVHeader."No Claim" := ASNHeader."No Claim";

        POINVHeader.Status := POINVHeader.Status::Processed;
        POINVHeader.MODIFY();
        Rec := POINVHeader;
    end;

    var
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        ManualProcess: Boolean;
        HideConfirmationDialog: Boolean;
        Text001Txt: Label 'Purchase Order for PO Invoice %1 doesn''t exist.';
        Text002Txt: Label 'Purchase Order has already been confirmed for PO Invoice %1';
        Text003Txt: Label 'Order has not been placed for PO Invoice %1';
        Text004Txt: Label 'Vendor File has not been sent yet for PO Invoice %1';
        Text005Txt: Label 'Are you sure you want to manually accept Invoice: %1';
        Text006Txt: Label 'Processing Cancelled by User %1';


    procedure SetManualProcessOptions(ManualProcessNew: Boolean; HideConfirmationDialogNew: Boolean)
    begin
        ManualProcess := ManualProcessNew;
        HideConfirmationDialog := HideConfirmationDialogNew;
    end;
}

