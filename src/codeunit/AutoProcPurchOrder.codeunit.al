codeunit 50011 "GXL Auto Proc. Purch. Order"
{
    TableNo = "Purchase Header";

    trigger OnRun()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        GetPurchSetup();
        GetGLSetup(); //PS-2560-Cannot Post Claimed Purchase +
        PurchaseHeader := Rec;

        case ProcessWhat of
            ProcessWhat::"Post Invoice":
                ProcessPurchaseOrder(PurchaseHeader);
            ProcessWhat::"Complete PO":
                ClosePurchaseOrder(PurchaseHeader);
        end;

        Rec := PurchaseHeader;
    end;

    procedure ProcessPurchaseOrder(var PH: Record "Purchase Header")
    var
        PH2: Record "Purchase Header";
        //001
        PurchPost: Codeunit 90;
        OrigPaymentMethodCode: Code[10];
        HasClaimedDoc: Boolean;
    begin
        IF NOT HasReceiptInTimeframe(PH) then
            exit;
        IF NOT UpdatePurchaseLines(PH) then
            exit;

        //ERP-293 +
        //No auto payment
        if NoPaymentPosting then begin
            PH.Receive := false;
            PH.Invoice := true;
            IF PH."Vendor Invoice No." = '' then
                PH.Validate("Vendor Invoice No.", PH."No.");
            PH.Validate("Posting Date", ReturnPostingDate(PH."Posting Date"));
            PH.Modify(true);
            Commit();
            PurchPost.Run(PH);
            exit;
        end;
        //ERP-293 -

        //PS-2560-Cannot Post Claimed Purchase +
        TempClaimPurchHead.Reset();
        TempClaimPurchHead.DeleteAll();
        //PS-2560-Cannot Post Claimed Purchase -

        PH.Receive := false;
        PH.Invoice := true;
        PH."Posting No. Series" := PurchSetup."GXL BP Trans. Posted Inv. Nos.";
        IF PH."Vendor Invoice No." = '' then
            PH.Validate("Vendor Invoice No.", PH."No.");
        PH.Validate("Posting Date", ReturnPostingDate(PH."Posting Date"));
        OrigPaymentMethodCode := PH."Payment Method Code";

        //PS-2560-Cannot Post Claimed Purchase +
        // PH.Validate("Payment Method Code", PurchSetup."GXL BP Payment Method Code");
        HasClaimedDoc := CheckClaimable(PH);
        if HasClaimedDoc then begin
            if PH."Payment Method Code" <> '' then
                PH.Validate("Payment Method Code", '');
        end else begin
            PH.Validate("Payment Method Code", PurchSetup."GXL BP Payment Method Code");
        end;
        //PS-2560-Cannot Post Claimed Purchase -
        PH.Modify(true);
        Commit();
        //PS-2560-Cannot Post Claimed Purchase +
        // IF NOT PurchPost.Run(PH) then
        //     exit;
        if PurchPost.Run(PH) then begin
            if HasClaimedDoc then begin
                Commit();
                CreatePayment(PH);
            end;
        end;
        //PS-2560-Cannot Post Claimed Purchase -
        //ERP-207 >>
        //Need to return old payment method back even if error as commit has been forced above
        //IF NOT PurchPost.Run(PH) then 
        //    exit;
        //ERP-207 <<
        IF PH2.Get(PH."Document Type", PH."No.") then begin
            PH2.Validate("Payment Method Code", OrigPaymentMethodCode);
            PH2.Modify(true);
        end;

    end;

    local procedure HasReceiptInTimeframe(PH: Record "Purchase Header"): Boolean
    var
        PR: Record "Purch. Rcpt. Header";
    begin
        PR.SetCurrentKey("Order No.");
        PR.SetRange("Order No.", PH."No.");
        PR.SetFilter("Posting Date", '>=%1', WorkDate() - PurchSetup."GXL BP Receipt Age Days");
        exit(NOT PR.IsEmpty());
    end;

    local procedure UpdatePurchaseLines(PH: Record "Purchase Header") HasSomethingToInvoice: Boolean
    var
        PL: Record "Purchase Line";
        Item: Record Item;
    begin
        PL.SetRange("Document No.", PH."No.");
        PL.SetRange("Document Type", PH."Document Type");
        //ERP-293 +
        // PL.SetRange(Type, PL.Type::Item);
        PL.SetFilter("Qty. Rcd. Not Invoiced", '<>0');
        //ERP-293 -
        HasSomethingToInvoice := false;
        IF PL.FindSet(true, false) then
            repeat
                //ERP-293 +
                if (PL.Type = PL.Type::Item) and (PL."No." <> '') then begin
                    Item.Get(PL."No.");
                    if not Item.IsInventoriableType() then
                        exit(false);
                end;
                //ERP-293 -
                IF PL."Qty. to Invoice" <> PL."Qty. Rcd. Not Invoiced" then begin
                    PL.Validate("Qty. to Invoice", PL."Qty. Rcd. Not Invoiced");
                    PL.Modify(true);
                end;
                IF Pl."Qty. to Invoice" <> 0 then
                    HasSomethingToInvoice := true;
            until PL.Next() = 0;
    end;

    local procedure GetPurchSetup()
    begin
        if PurchSetupGot then
            exit;
        PurchSetup.Get();
        PurchSetupGot := true;
        //ERP-293 +
        if NoPaymentPosting then
            exit;
        //ERP-293 -

        //PS-2560-Cannot Post Claimed Purchase +
        if PurchSetup."GXL BP Payment Method Code" <> '' then begin
            PmtMethod.Get(PurchSetup."GXL BP Payment Method Code");
        end else
            Clear(PmtMethod);
        //PS-2560-Cannot Post Claimed Purchase -
    end;

    procedure SetPurchSetup(NewPurchSetup: Record "Purchases & Payables Setup")
    begin
        PurchSetup := NewPurchSetup;
        PurchSetupGot := true;
        //ERP-293 +
        if NoPaymentPosting then
            exit;
        //ERP-293 -

        //PS-2560-Cannot Post Claimed Purchase +
        if PurchSetup."GXL BP Payment Method Code" <> '' then begin
            PmtMethod.Get(PurchSetup."GXL BP Payment Method Code");
        end else
            Clear(PmtMethod);
        //PS-2560-Cannot Post Claimed Purchase -
    end;

    local procedure ReturnPostingDate(ReceiptDate: Date) PostingDate: Date
    var
        InvPeriod: Record "Inventory Period";
    begin
        if InvPeriod.IsEmpty() then
            exit(ReceiptDate);
        PostingDate := ReceiptDate;
        IF NOT InvPeriod.IsValidDate(PostingDate) then
            PostingDate := PostingDate + 1;
    end;

    local procedure ClosePurchaseOrder(var PH: Record "Purchase Header")
    begin
        if PH.GXL_PurchaseOrderCanBeCompleted(PH) then begin
            PH.SetHideValidationDialog(true);
            PH.SuspendStatusCheck(true);
            PH."Receiving No." := '';
            PH."Posting No." := '';
            PH.Delete(true);
        end;
    end;

    procedure SetProcessOption(NewProcessWhat: Option "Post Invoice","Complete PO")
    begin
        ProcessWhat := NewProcessWhat;
    end;

    //PS-2560-Cannot Post Claimed Purchase +
    local procedure CheckClaimable(PurchHead: Record "Purchase Header"): Boolean
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        ClaimDocType: Option " ",Transfer,Credit,Return;
        ClaimDocNo: Code[20];
        FoundClaim: Boolean;
    begin
        TotalClaimAmt := 0;
        ClaimDocType := ClaimDocType::" ";
        ClaimDocNo := '';

        PDAStockAdjProcessingBuffer.SetCurrentKey(Status);
        PDAStockAdjProcessingBuffer.SetFilter(Status, '%1|%2', PDAStockAdjProcessingBuffer.Status::"Credit Created", PDAStockAdjProcessingBuffer.Status::"Return Order Created");
        PDAStockAdjProcessingBuffer.SetRange("Claim-to Order No.", PurchHead."No.");
        PDAStockAdjProcessingBuffer.SetRange("Claim-to Vendor No.", PurchHead."Buy-from Vendor No.");
        if PDAStockAdjProcessingBuffer.FindSet() then begin
            repeat
                if PDAStockAdjProcessingBuffer."Vendor Ullaged Status" <> PDAStockAdjProcessingBuffer."Vendor Ullaged Status"::Ullaged then begin
                    ClaimDocType := PDAStockAdjProcessingBuffer."Claim Document Type";
                    ClaimDocNo := PDAStockAdjProcessingBuffer."Claim Document No.";
                    if ClaimedDocExist(ClaimDocType, ClaimDocNo) then
                        FoundClaim := true;
                end;
            until PDAStockAdjProcessingBuffer.Next() = 0;
            if FoundClaim then
                exit(true);
        end;

        PDAPLReceiveBuffer.SetCurrentKey(Status, "Document No.");
        PDAPLReceiveBuffer.SetFilter(Status, '%1|%2', PDAPLReceiveBuffer.Status::"Credit Created", PDAPLReceiveBuffer.Status::"Return Order Created");
        PDAPLReceiveBuffer.SetRange("Document No.", PurchHead."No.");
        if PDAPLReceiveBuffer.FindSet() then begin
            repeat
                if PDAPLReceiveBuffer."Vendor Ullaged Status" <> PDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged then begin
                    ClaimDocType := PDAPLReceiveBuffer."Claim Document Type";
                    ClaimDocNo := PDAPLReceiveBuffer."Claim Document No.";
                    if ClaimedDocExist(ClaimDocType, ClaimDocNo) then
                        FoundClaim := true;
                end;
            until PDAPLReceiveBuffer.Next() = 0;
            if FoundClaim then
                exit(true);
        end;

        exit(false);
    end;

    local procedure ClaimedDocExist(var ClaimDocType: Option " ",Transfer,Credit,Return; ClaimDocNo: Code[20]): Boolean
    var
        ClaimPurchHead: Record "Purchase Header";
    begin
        case ClaimDocType of
            ClaimDocType::Credit:
                if not TempClaimPurchHead.Get(TempClaimPurchHead."Document Type"::"Credit Memo", ClaimDocNo) then begin
                    if ClaimPurchHead.Get(ClaimPurchHead."Document Type"::"Credit Memo", ClaimDocNo) then
                        if ClaimPurchHead."Bal. Account No." = '' then begin
                            ClaimPurchHead.CalcFields("Amount Including VAT");
                            TotalClaimAmt += ClaimPurchHead."Amount Including VAT";
                            TempClaimPurchHead := ClaimPurchHead;
                            TempClaimPurchHead.Insert();
                            exit(true);
                        end;
                end else
                    exit(true);
            ClaimDocType::Return:
                if not TempClaimPurchHead.Get(TempClaimPurchHead."Document Type"::"Credit Memo", ClaimDocNo) then begin
                    if ClaimPurchHead.Get(ClaimPurchHead."Document Type"::"Return Order", ClaimDocNo) then
                        if ClaimPurchHead."Bal. Account No." = '' then begin
                            ClaimPurchHead.CalcFields("Amount Including VAT");
                            TotalClaimAmt += ClaimPurchHead."Amount Including VAT";
                            TempClaimPurchHead := ClaimPurchHead;
                            TempClaimPurchHead.Insert();
                            exit(true);
                        end;
                end else
                    exit(true);
        end;
        exit(false);
    end;

    local procedure GetLastVendorLedger(DocNo: Code[20]; var VendLedgerEntry: Record "Vendor Ledger Entry")
    begin
        VendLedgerEntry.SetRange("Document No.", DocNo);
        VendLedgerEntry.SetRange("Document Type", VendLedgerEntry."Document Type"::Invoice);
        VendLedgerEntry.FindLast();
    end;

    local procedure CreatePayment(PurchHead: Record "Purchase Header")
    var
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        CurrExchRate: Record "Currency Exchange Rate";
        VendLedgEntry: Record "Vendor Ledger Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GenJnlLineDocNo: Code[20];
        PmtAmt: Decimal;
        PmtAmtLCY: Decimal;
        qwe: Codeunit 80;
    begin
        if PmtMethod."Bal. Account No." = '' then
            exit;

        GenJnlLineDocNo := PurchHead."Last Posting No.";
        GetLastVendorLedger(GenJnlLineDocNo, VendLedgEntry);
        VendLedgEntry.CalcFields(Amount);
        PmtAmt := -VendLedgEntry.Amount - TotalClaimAmt;
        if PmtAmt > 0 then begin

            GenJnlLine.InitNewLine(
                // >> Upgrade
                //PurchHead."Posting Date", PurchHead."Document Date", PurchHead."Posting Description",
                PurchHead."Posting Date", PurchHead."Document Date", PurchHead."VAT Reporting Date", PurchHead."Posting Description",
                // << Upgrade
                PurchHead."Shortcut Dimension 1 Code", PurchHead."Shortcut Dimension 2 Code", PurchHead."Dimension Set ID",
                PurchHead."Reason Code");
            GenJnlTemplate.SetRange(Type, GenJnlTemplate.Type::Purchases);
            if GenJnlTemplate.FindFirst() then begin
                GenJnlLine.Validate("Journal Template Name", GenJnlTemplate.Name);
                GenJnlBatch.SetRange("Journal Template Name", GenJnlTemplate.Name);
                if GenJnlBatch.FindFirst() then
                    GenJnlLine.Validate("Journal Batch Name", GenJnlBatch.Name);
            end;
            GenJnlLine.CopyDocumentFields(0, GenJnlLineDocNo, PurchHead."Vendor Invoice No.", SourceCodeSetup.Purchases, '');
            GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
            GenJnlLine."Account No." := PurchHead."Pay-to Vendor No.";
            GenJnlLine.CopyFromPurchHeader(PurchHead);
            GenJnlLine.SetCurrencyFactor(PurchHead."Currency Code", PurchHead."Currency Factor");

            GenJnlLine."Document Type" := GenJnlLine."Document Type"::Payment;

            if PmtMethod."Bal. Account Type" = PmtMethod."Bal. Account Type"::"Bank Account" then
                GenJnlLine."Bal. Account Type" := GenJnlLine."Account Type"::"Bank Account"
            else
                GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"G/L Account";
            GenJnlLine."Bal. Account No." := PmtMethod."Bal. Account No.";

            GenJnlLine."Applies-to Doc. Type" := GenJnlLine."Applies-to Doc. Type"::Invoice;
            GenJnlLine."Applies-to Doc. No." := GenJnlLineDocNo;

            GenJnlLine.Amount := PmtAmt;
            GenJnlLine."Source Currency Amount" := GenJnlLine.Amount;
            if GenJnlLine."Currency Code" <> '' then begin
                PmtAmtLCY := Round(
                    CurrExchRate.ExchangeAmtFCYToLCY(
                        GenJnlLine."Posting Date", GenJnlLine."Currency Code", GenJnlLine.Amount, GenJnlLine."Currency Factor"));
                GenJnlLine."Amount (LCY)" := PmtAmtLCY;
            end else begin
                GenJnlLine."Amount (LCY)" := GenJnlLine.Amount;
            end;
            GenJnlPostLine.RunWithCheck(GenJnlLine);

        end;
    end;

    procedure SetGLSetup(NewGLSetup: Record "General Ledger Setup"; NewSourceCodeSetup: Record "Source Code Setup")
    begin
        GLSetup := NewGLSetup;
        SourceCodeSetup := NewSourceCodeSetup;
        GLSetupRead := true;
    end;

    local procedure GetGLSetup()
    begin
        if not GLSetupRead then begin
            GLSetup.Get();
            SourceCodeSetup.Get();
            GLSetupRead := true;
        end;
    end;
    //PS-2560-Cannot Post Claimed Purchase -

    //ERP-293 +
    procedure IsNonEDIPurchaseOrder(PurchHead: Record "Purchase Header"): Boolean
    begin
        if PurchHead."GXL EDI Order" then
            exit(false);
        if PurchHead."GXL EDI Vendor Type" = PurchHead."GXL EDI Vendor Type"::"Point 2 Point Contingency" then
            exit(false);
        exit(true);
    end;

    procedure IsAutoInvoiceDisabled(PurchHead: Record "Purchase Header"): Boolean
    var
        Vend: Record Vendor;
    begin
        Vend.Get(PurchHead."Buy-from Vendor No.");
        exit(Vend."GXL Disable Auto Invoice");
    end;

    procedure SetNoPaymentPosting(NewNoPaymentPosting: Boolean)
    begin
        NoPaymentPosting := NewNoPaymentPosting;
    end;
    //ERP-293 -

    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        PurchSetup: Record "Purchases & Payables Setup";
        PmtMethod: Record "Payment Method";
        TempClaimPurchHead: Record "Purchase Header" temporary;
        PurchSetupGot: Boolean;
        ProcessWhat: Option "Post Invoice","Complete PO";
        GLSetupRead: Boolean;
        TotalClaimAmt: Decimal;
        NoPaymentPosting: Boolean;
}
