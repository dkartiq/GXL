// 002 12.11.2024 KDU LCB-304 https://petbarnjira.atlassian.net/browse/LCB-304
codeunit 50376 "GXL P2P-Process Invoice"
{
    //TODO: Order Status - P2P process invoice, only Closed status is accepted
    TableNo = "GXL PO INV Header";

    trigger OnRun()
    var
        PurchaseHeader: Record "Purchase Header";
        ASNHeader: Record "GXL ASN Header";
    begin
        POINVHeader := Rec;
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
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text006Txt, USERID()));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        IF PurchaseHeader."GXL Order Status" <> PurchaseHeader."GXL Order Status"::Closed THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text003Txt, Rec."No."));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        //TODO: PO was created from NAV13 - temporarily set the Vendor File Sent to TRUE
        PurchaseHeader."GXL Vendor File Sent" := true;
        IF NOT PurchaseHeader."GXL Vendor File Sent" THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text004Txt, Rec."No."));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        PurchaseHeader."Vendor Invoice No." := Rec."Vendor Invoice No.";
        PurchaseHeader."GXL Invoice Received Date" := Rec."Invoice Received Date";
        PurchaseHeader."GXL Invoice Received" := TRUE;
        PurchaseHeader."GXL Last EDI Document Status" := PurchaseHeader."GXL Last EDI Document Status"::INV;
        PurchaseHeader.Modify();
        UpdateP2PPORLines();

        PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec."Purchase Order No."); // >> 002 <<
        //Post
        PurchaseHeader.Invoice := TRUE;
        PurchaseHeader.Receive := FALSE;
        // >> 002
        PurchaseHeader.Modify();
        Commit();
        // << 002
        CODEUNIT.RUN(CODEUNIT::"Purch.-Post", PurchaseHeader);


        PurchaseHeader.CALCFIELDS("GXL ASN Created", "GXL ASN Number");

        IF PurchaseHeader."GXL ASN Number" <> '' THEN BEGIN
            ASNHeader.SETRANGE("Document Type", ASNHeader."Document Type"::Purchase);
            ASNHeader.SETRANGE("No.", PurchaseHeader."GXL ASN Number");
            IF ASNHeader.FindFirst() THEN BEGIN
                POINVHeader."No Claim" := ASNHeader."No Claim";
                POINVHeader."ASN Number" := ASNHeader."No.";
            END;
        END;

        POINVHeader.Status := POINVHeader.Status::Processed;
        POINVHeader.Modify();

        Rec := POINVHeader;
    end;

    var
        POINVHeader: Record "GXL PO INV Header";
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        // IsCallFromASN: Boolean;
        ManualProcess: Boolean;
        HideConfirmationDialog: Boolean;
        Text002Txt: Label 'Purchase Order has already been Closed for PO %1';
        Text004Txt: Label 'Vendor File has not been sent yet for PO Response %1';
        Text001Txt: Label 'Purchase Order for PO Invoice %1 doesn''t exist.';
        Text003Txt: Label 'Order has not been placed for PO Invoice %1';
        Text005Txt: Label 'Are you sure you want to manually accept Invoice: %1';
        Text006Txt: Label 'Processing Cancelled by User %1';

    local procedure UpdateP2PPORLines()
    var
        POInvLine: Record "GXL PO INV Line";
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        POInvLine.SETCURRENTKEY("INV No.");
        POInvLine.SETRANGE(POInvLine."INV No.", POINVHeader."No.");
        IF POInvLine.FINDSET() THEN BEGIN
            REPEAT
                PurchaseLine.GET(PurchaseLine."Document Type"::Order, POINVHeader."Purchase Order No.", POInvLine."PO Line No.");
                PurchaseLine."GXL Confirmed Invoice Qty" := POInvLine."Qty. to Invoice";
                PurchaseLine."GXL Confirmed Direct Unit Cost" := POInvLine."Direct Unit Cost";
                Vendor.GET(PurchaseLine."Pay-to Vendor No.");
                IF Vendor."GXL Acc. Lower Cost Purch. Inv" AND (POInvLine."Direct Unit Cost" < PurchaseLine."Direct Unit Cost") THEN BEGIN
                    PurchaseLine.SuspendStatusCheck(TRUE);
                    PurchaseLine.VALIDATE("Direct Unit Cost", POInvLine."Direct Unit Cost");
                    PurchaseLine.MODIFY(TRUE);
                END;
            UNTIL POInvLine.NEXT() = 0;
        END;
    end;

    procedure SetManualProcessOptions(ManualProcessNew: Boolean; HideConfirmationDialogNew: Boolean)
    begin
        ManualProcess := ManualProcessNew;
        HideConfirmationDialog := HideConfirmationDialogNew;
    end;
}

