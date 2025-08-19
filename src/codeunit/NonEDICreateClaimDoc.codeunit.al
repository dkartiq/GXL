// LCB-3   24-09-2022  PREM    Update Vendor Invoice No
codeunit 50283 "GXL Non-EDI Create Claim Doc"
{
    trigger OnRun()
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        PurchaseHeader: Record "Purchase Header";
        PO: Record "Purchase Header"; // >> LCB-3 <<
        VendInvNo: Code[35]; // >> LCB-3 <<
        PurchaseLine: Record "Purchase Line";
        ClaimMgt: Codeunit "GXL Claim Management";
        LineNo: Integer;
    begin

        IntegrationSetup.Get();

        PDAPLReceiveBuffer.SetCurrentKey("Document No.");
        PDAPLReceiveBuffer.SetRange("Document No.", DocumentNo);
        PDAPLReceiveBuffer.SetFilter("Claim Quantity", '>0');
        if PDAPLReceiveBuffer.FindSet(TRUE) then begin
            ClaimMgt.SetMIMUserID(PDAPLReceiveBuffer."MIM User ID"); //PS-2565 Missing MIM User ID +
            if PDAPLReceiveBuffer."Vendor Ullaged Status" = PDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged then begin
                ClaimMgt.CreatePurchaseHeader(
                  PurchaseHeader,
                  PurchaseHeader."Document Type"::"Return Order",
                  IntegrationSetup."EDI Return Order No. Series",
                  IntegrationSetup."EDI Return Order Vendor No.",
                  GetLocationCode(PDAPLReceiveBuffer."Purchase Invoice No.", DocumentNo),
                  DT2DATE(PDAPLReceiveBuffer."Entry Date Time"),  //posting date,
                  PDAPLReceiveBuffer."Purchase Invoice No.",
                  IntegrationSetup."EDI Ret. Order Bal. Acc. Type",
                  IntegrationSetup."EDI Ret. Order Bal. Acc. No.",
                  IntegrationSetup."EDI Return Order Reason Code", PDAPLReceiveBuffer."Document No.") //IntegrationSetup."EDI Return Order Reason Code") // >> LCB-3 <<
            end
            ELSE begin
                // >> LCB-3
                VendInvNo := PDAPLReceiveBuffer."Purchase Invoice No.";
                IF VendInvNo = '' then begin
                    IF PO.Get(PO."Document Type"::Order, PDAPLReceiveBuffer."Document No.") then
                        VendInvNo := PO."Vendor Invoice No.";
                end;
                // << LCB-3
                ClaimMgt.CreatePurchaseHeader(
                  PurchaseHeader,
                  //PurchaseHeader."Document Type"::"Credit Memo", //ERP-340 -
                  //IntegrationSetup."EDI Credit Memo No. Series", //ERP-340 -
                  PurchaseHeader."Document Type"::"Credit Memo", //ERP-340 +
                  IntegrationSetup."EDI Credit Memo No. Series", //IntegrationSetup."EDI Return Order No. Series", //ERP-340 + // >> LCB-3 <<
                  PDAPLReceiveBuffer."Vendor No.",
                  GetLocationCode(PDAPLReceiveBuffer."Purchase Invoice No.", DocumentNo),
                  DT2DATE(PDAPLReceiveBuffer."Entry Date Time"),  //posting date,
                  VendInvNo,  //PDAPLReceiveBuffer."Purchase Invoice No.",  // >> LCB-3 <<
                  0,  // Bal Acc type, leave as default zero
                  '', // Bal Acc no, leave as default blank
                  PDAPLReceiveBuffer."Reason Code", PDAPLReceiveBuffer."Document No."); //PDAPLReceiveBuffer."Reason Code"); // >> LCB-3 <<
            end;

            repeat
                LineNo += 10000;
                ClaimMgt.CreatePurchaseLine(
                  PurchaseLine,
                  PurchaseHeader,
                  LineNo,
                  PDAPLReceiveBuffer."No.",
                  PDAPLReceiveBuffer."Unit of Measure Code",
                  ABS(PDAPLReceiveBuffer."Claim Quantity"),
                  PDAPLReceiveBuffer."Claim Document Type",       // >> lvar
                  PDAPLReceiveBuffer."Claim Document No.",        // >> lvar
                  PDAPLReceiveBuffer."Claim Document Line No.");  // >> lvar

                PDAPLReceiveBuffer.Modify();

            until PDAPLReceiveBuffer.Next() = 0;

        end;
    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        DocumentNo: Code[20];

    procedure SetDocument(InputDocumentNo: Code[20])
    begin
        DocumentNo := InputDocumentNo;
    end;

    local procedure GetLocationCode(InvoiceNo: Code[20]; OrderNo: Code[20]) LocationCode: Code[10]
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
    begin
        if InvoiceNo <> '' then begin
            PurchInvHeader.Get(InvoiceNo);
            LocationCode := PurchInvHeader."Location Code";
        end ELSE begin
            PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, OrderNo);
            LocationCode := PurchaseHeader."Location Code";
        end;
    end;

    local procedure GetNextVendorCreditMemoNo(PDAPurchInvoiceNo: Code[35]; VendorNo: Code[20]): Code[35]
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchHeader.Reset();
        PurchHeader.SetCurrentKey("Vendor Cr. Memo No.");
        PurchHeader.SetRange("Buy-from Vendor No.", VendorNo);
        PurchHeader.SetRange("Vendor Cr. Memo No.", PDAPurchInvoiceNo);
        if PurchHeader.IsEmpty() then
            exit(PDAPurchInvoiceNo)
        ELSE
            exit(GetNextVendorCreditMemoNo(INCSTR(PDAPurchInvoiceNo), VendorNo));
    end;

    local procedure CheckVendorLedgerEntry(InvoiceNo: Code[35]; VendorNo: Code[20]): Code[35]
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgerEntry.Reset();
        VendLedgerEntry.SetCurrentKey("External Document No.");
        VendLedgerEntry.SetRange("Vendor No.", VendorNo);
        VendLedgerEntry.SetRange("External Document No.", InvoiceNo);
        if VendLedgerEntry.IsEmpty() then
            exit(InvoiceNo)
        ELSE
            exit(CheckVendorLedgerEntry(INCSTR(InvoiceNo), VendorNo));
    end;
}