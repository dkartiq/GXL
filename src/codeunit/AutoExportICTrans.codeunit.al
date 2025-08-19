/// <summary>
/// ERP-NAV Master Data Management: Automate IC Transctions
/// </summary>
codeunit 50031 "GXL Auto Export IC Trans"
{

    trigger OnRun()
    begin
    end;

    var
        ICOutboxTransaction: Record "IC Outbox Transaction";
        ICOutboxExport: Codeunit "IC Outbox Export";
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        IsICTransaction: Boolean;


    procedure ProcessSalesDocument(DocNo: Code[20])
    var
        SalesInvHdr: Record "Sales Invoice Header";
        SalesCrMemoHdr: Record "Sales Cr.Memo Header";
    begin
        GLSetup.Get();
        IsICTransaction := FALSE;
        if not GLSetup."GXL Automate IC Transactions" then
            exit;
        SalesInvHdr.Reset();
        if not SalesInvHdr.Get(DocNo) then
            if not SalesCrMemoHdr.Get(DocNo) then
                Message('No IC Outbox Transaction is found for Sales Document %1. Therefore no IC transactions have been processed.', DocNo);

        ICOutboxTransaction.Reset();
        ICOutboxTransaction.SetCurrentKey("Source Type", "Document Type", "Document No.");
        ICOutboxTransaction.SetRange("Source Type", ICOutboxTransaction."Source Type"::"Sales Document");
        ICOutboxTransaction.SetRange("Document No.", DocNo);
        if ICOutboxTransaction.FindSet() then begin
            repeat
                ICOutboxTransaction.Validate("Line Action", ICOutboxTransaction."Line Action"::"Send to IC Partner");
                ICOutboxTransaction.Modify();
            until ICOutboxTransaction.Next() = 0;
            IsICTransaction := TRUE;
        end;
        if IsICTransaction then begin
            ICOutboxExport.RunOutboxTransactions(ICOutboxTransaction);
            Message('IC transactions for Sales Document %1 is exported.', DocNo);
        end;
    end;

    procedure ProcessGenJnl(DocNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLSetup.Get();
        if not GLSetup."GXL Automate IC Transactions" then
            exit;

        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("IC General Journal");
        GLEntry.Reset();
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Document No.", DocNo);
        GLEntry.SetRange("Source Code", SourceCodeSetup."IC General Journal");
        if GLEntry.IsEmpty() then
            Message('No IC Outbox Transaction is found for IC General Journal %1. Therefore no IC transactions have been processed.', DocNo);

        ICOutboxTransaction.Reset();
        ICOutboxTransaction.SetCurrentKey("Source Type", "Document Type", "Document No.");
        ICOutboxTransaction.SetRange("Source Type", ICOutboxTransaction."Source Type"::"Journal Line");
        ICOutboxTransaction.SetRange("Document No.", DocNo);
        if ICOutboxTransaction.FindSet() then begin
            repeat
                ICOutboxTransaction.Validate("Line Action", ICOutboxTransaction."Line Action"::"Send to IC Partner");
                ICOutboxTransaction.Modify();
            until ICOutboxTransaction.Next() = 0;
            IsICTransaction := TRUE;
        end;
        if IsICTransaction then begin
            ICOutboxExport.RunOutboxTransactions(ICOutboxTransaction);
            Message('IC transactions for IC General Journal %1 is exported.', DocNo);
        end;
    end;

    procedure ProcessPurchDocument(PIDocNo: Code[20]; PODocNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLSetup.Get();
        IsICTransaction := FALSE;
        if not GLSetup."GXL Automate IC Transactions" then
            exit;

        SourceCodeSetup.Get();
        SourceCodeSetup.TestField(Purchases);
        GLEntry.Reset();
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Document No.", PIDocNo);
        GLEntry.SetRange("Source Code", SourceCodeSetup.Purchases);
        if GLEntry.IsEmpty() then
            Message('No IC Outbox Transaction is found for Purchase Document %1. Therefore no IC transactions have been processed.', PIDocNo);

        ICOutboxTransaction.Reset();
        ICOutboxTransaction.SetCurrentKey("Source Type", "Document Type", "Document No.");
        if PODocNo = '' then begin
            ICOutboxTransaction.SetRange("Source Type", ICOutboxTransaction."Source Type"::"Journal Line");
            ICOutboxTransaction.SetRange("Document No.", PIDocNo);
        end ELSE begin
            ICOutboxTransaction.SetRange("Source Type", ICOutboxTransaction."Source Type"::"Purchase Document");
            ICOutboxTransaction.SetRange("Document No.", PODocNo);
        end;
        if ICOutboxTransaction.FindSet() then begin
            repeat
                ICOutboxTransaction.Validate("Line Action", ICOutboxTransaction."Line Action"::"Send to IC Partner");
                ICOutboxTransaction.Modify();
            until ICOutboxTransaction.Next() = 0;
            IsICTransaction := TRUE;
        end;

        if IsICTransaction then begin
            ICOutboxExport.RunOutboxTransactions(ICOutboxTransaction);
            Message('IC transactions for Purchase Document %1 is exported.', PIDocNo);
        end;
    end;
}

