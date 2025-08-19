codeunit 50286 "GXL Non-EDI Post Receipt"
{
    trigger OnRun()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
    begin

        PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, DocumentNo);
        PurchaseHeader.Receive := true;
        PurchaseHeader.Invoice := false;
        IF PurchaseHeader."GXL 3PL File Sent" THEN
            PurchaseHeader."GXL 3PL File Receive" := true;
        PurchaseHeader.Validate("Posting Date", PostingDate);
        //PS-2046+
        PurchaseHeader."GXL MIM User ID" := MIMUserID;
        //PS-2046-
        PurchaseHeader.Modify(true);

        PurchPost.Run(PurchaseHeader);

        PostedReceiptNo := PurchaseHeader."Last Receiving No.";
        PostedInvoiceNo := PurchaseHeader."Last Posting No.";
    end;

    var
        DocumentNo: Code[20];
        PostingDate: Date;
        PostedReceiptNo: Code[20];
        PostedInvoiceNo: Code[20];
        MIMUserID: Code[50];

    procedure SetOptions(InputDocumentNo: Code[20]; InputPostingDate: Date)
    begin
        DocumentNo := InputDocumentNo;
        PostingDate := InputPostingDate;
    end;

    procedure GetPostedDocumentNos(VAR ReturnPostedReceiptNo: Code[20]; VAR ReturnPostedInvoiceNo: Code[20])
    begin
        ReturnPostedReceiptNo := PostedReceiptNo;
        ReturnPostedInvoiceNo := PostedInvoiceNo;
    end;

    //PS-2046+
    procedure SetMIMUserID(NewMIMUserID: Code[50])
    begin
        MIMUserID := NewMIMUserID;
    end;
    //PS-2046
}