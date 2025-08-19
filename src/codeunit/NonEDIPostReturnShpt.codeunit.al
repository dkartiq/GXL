codeunit 50285 "GXL Non-EDI Post Return Shpt"
{
    trigger OnRun()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin

        PurchaseHeader.GET(PurchaseHeader."Document Type"::"Return Order", DocumentNo);
        PurchaseHeader.Ship := TRUE;
        PurchaseHeader.Invoice := false; //ERP-340 +
        //PS-2046+
        PurchaseHeader."GXL MIM User ID" := MIMUserID;
        //PS-2046-

        //PS-2634 +
        //Has already been shipped manually
        if PurchaseHeader."Last Return Shipment No." <> '' then begin
            PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchLine.SetFilter("Outstanding Quantity", '<>0');
            if PurchLine.IsEmpty then begin
                PostedShipmentNo := PurchaseHeader."Last Return Shipment No.";
                exit;
            end;
        end;
        //PS-2634 -

        CODEUNIT.RUN(CODEUNIT::"Purch.-Post", PurchaseHeader);

        PostedShipmentNo := PurchaseHeader."Last Return Shipment No.";
    end;

    var
        DocumentNo: Code[20];
        PostingDate: Date;
        PostedShipmentNo: Code[20];
        MIMUserID: Code[50];

    procedure SetOptions(InputDocumentNo: Code[20]; InputPostingDate: Date)
    begin
        DocumentNo := InputDocumentNo;
        PostingDate := InputPostingDate;
    end;

    procedure GetPostedDocumentNo(VAR ReturnPostedShipmentNo: Code[20])
    begin
        ReturnPostedShipmentNo := PostedShipmentNo;
    end;

    //PS-2046+
    procedure SetMIMUserID(NewMIMUserID: Code[50])
    begin
        MIMUserID := NewMIMUserID;
    end;
    //PS-2046

}