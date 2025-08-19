codeunit 50380 "GXL P2P-Export+Val. Pur. Order"
{
    TableNo = "Purchase Header";

    trigger OnRun()
    var
        Vendor: Record Vendor;
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        SCPurchaseOrderStatusMgt: Codeunit "GXL SC-Purch. Order Status Mgt";
        EmailMgt: Codeunit "GXL Email Management";
        EmailSent: Boolean;
    begin
        PurchaseHeader := Rec;

        IF NonEDI AND NOT Manual AND AlreadyLogged THEN
            ERROR(STRSUBSTNO(Text000Txt, PurchaseHeader."No."));

        IF NOT CalledFromPage THEN BEGIN

            IF PurchaseHeader.Status <> PurchaseHeader.Status::Released THEN
                ReleasePurchaseDocument.RUN(PurchaseHeader);

        END;

        IF CalledFromPage THEN BEGIN

            //TODO: Order Status - P2P export and Validate PO for non EDI purchase order and status is New or Created
            IF (PurchaseHeader."GXL Order Status" < PurchaseHeader."GXL Order Status"::Placed) AND (NOT PurchaseHeader."GXL EDI Order") THEN
                SCPurchaseOrderStatusMgt.Place(PurchaseHeader);

        END ELSE
            SCPurchaseOrderStatusMgt.Place(PurchaseHeader);

        EmailSent := TRUE;

        IF CalledFromPage THEN BEGIN

            EmailSent := EmailMgt.SendPOEmail(PurchaseHeader, GUIALLOWED(), GUIALLOWED());

        END ELSE BEGIN

            IF NonEDI THEN BEGIN

                IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Placed THEN
                    EmailSent := EmailMgt.SendPOEmail(PurchaseHeader, GUIALLOWED(), GUIALLOWED());

            END;

        END;

        IF NOT EmailSent THEN
            ERROR(STRSUBSTNO(Text001Txt, PurchaseHeader."No.") + ' ' + GETLASTERRORTEXT());

        PurchaseHeader.VALIDATE("GXL EDI PO File Log Entry No.", EDIFileLogEntryNo);//success is logged
        Vendor.GET(Rec."Buy-from Vendor No.");
        IF Vendor."GXL EDI Vendor Type" = Vendor."GXL EDI Vendor Type"::"Point 2 Point" THEN
            PurchaseHeader.VALIDATE("GXL Last EDI Document Status", PurchaseHeader."GXL Last EDI Document Status"::PO);
        PurchaseHeader.MODIFY(TRUE);

        Rec := PurchaseHeader;

    end;

    var
        PurchaseHeader: Record "Purchase Header";
        NonEDI: Boolean;
        Manual: Boolean;
        AlreadyLogged: Boolean;
        CalledFromPage: Boolean;
        EDIFileLogEntryNo: Integer;
        Text000Txt: Label 'Purchase Order %1 has already been sent to the supplier. ';
        Text001Txt: Label 'Purchase Order %1 couldn''t be sent to the supplier.';

    [Scope('OnPrem')]
    procedure SetOptions(NonEDINew: Boolean; EDIFileLogEntryNoNew: Integer; ManualNew: Boolean; AlreadyLoggedNew: Boolean; CalledFromPageNew: Boolean)
    begin
        NonEDI := NonEDINew;
        EDIFileLogEntryNo := EDIFileLogEntryNoNew;
        Manual := ManualNew;
        AlreadyLogged := AlreadyLoggedNew;
        CalledFromPage := CalledFromPageNew;
    end;
}

