codeunit 50287 "GXL Non-EDI Post Purch Credit"
{
    trigger OnRun()
    var
        PurchaseHeader: Record "Purchase Header";
        VendLedgEntry: Record "Vendor Ledger Entry";
        PurchPost: Codeunit "Purch.-Post";
        ClaimMgt: Codeunit "GXL Claim Management";
        ModifyHeader: Boolean;
    begin

        PurchaseHeader.GET(DocumentType, DocumentNo);
        PurchaseHeader.Receive := FALSE;
        //ERP-340 +
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo" then
            PurchaseHeader.Ship := true
        else
            PurchaseHeader.Ship := false;
        //ERP-340 -
        PurchaseHeader.Invoice := TRUE;
        PurchaseHeader.VALIDATE("Posting Date", PostingDate);
        //ERP-340 +
        // PurchaseHeader.VALIDATE("Vendor Cr. Memo No.", VendorCrMemoNo);
        ClaimMgt.UpdatePurchaseCrMemoNo(PurchaseHeader, VendorCrMemoNo, '', ModifyHeader);

        //Apply to invoice
        if PurchaseHeader."Bal. Account No." = '' then begin
            VendLedgEntry.SetCurrentKey("Document No.", "Document Type", "Vendor No.");
            VendLedgEntry.SetRange("Document No.", VendorCrMemoNo);
            VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::Invoice);
            VendLedgEntry.SetRange("Vendor No.", PurchaseHeader."Pay-to Vendor No.");
            if VendLedgEntry.FindFirst() then
                if VendLedgEntry.Open then begin
                    PurchaseHeader."Applies-to Doc. Type" := PurchaseHeader."Applies-to Doc. Type"::Invoice;
                    PurchaseHeader.Validate("Applies-to Doc. No.", VendorCrMemoNo);
                end;
        end;
        //ERP-340 -

        //PS-2046+
        PurchaseHeader."GXL MIM User ID" := MIMUserID;
        //PS-2046-
        PurchaseHeader.MODIFY(TRUE);

        PurchPost.RUN(PurchaseHeader);

        PostedCrMemoNo := PurchaseHeader."Last Posting No.";

        IF PostedCrMemoNo = '' THEN
            PostedCrMemoNo := DocumentNo;
    end;

    var
        DocumentNo: Code[20];
        DocumentType: Option Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order";
        PostingDate: Date;
        VendorCrMemoNo: Code[35];
        PostedCrMemoNo: Code[20];
        MIMUserID: Code[50];

    procedure SetOptions(InputDocumentType: Option Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order"; InputDocumentNo: Code[20]; InputPostingDate: Date; InputVendorCrMemoNo: Code[35])
    begin
        DocumentType := InputDocumentType;
        DocumentNo := InputDocumentNo;
        PostingDate := InputPostingDate;
        VendorCrMemoNo := InputVendorCrMemoNo;
    end;

    procedure GetPostedDocumentNo(VAR ReturnPostedCrMemoNo: Code[20])
    begin
        ReturnPostedCrMemoNo := PostedCrMemoNo;
    end;

    //PS-2046+
    procedure SetMIMUserID(NewMIMUserID: Code[50])
    begin
        MIMUserID := NewMIMUserID;
    end;
    //PS-2046

}