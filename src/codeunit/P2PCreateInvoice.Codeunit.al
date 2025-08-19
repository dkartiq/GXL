codeunit 50383 "GXL P2P-Create Invoice"
{
    TableNo = "GXL EDI-Purchase Messages";

    trigger OnRun()
    var
        POINVHeader: Record "GXL PO INV Header";
        Vendor: Record Vendor;
        NoSeriesMgt: Codeunit NoSeriesManagement;
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
    begin
        //Create P2P Invoice
        EDISetup.GET();
        POINVHeader.INIT();
        POINVHeader."No." := NoSeriesMgt.GetNextNo(EDISetup."P2P Invoice No. Series", 0D, TRUE);
        POINVHeader."EDI Vendor Type" := EDIFunctionsLibrary.GetPOEDIVendorType(Rec.DocumentNumber);
        POINVHeader."Vendor Invoice No." := Rec.VendorInvoiceNumber;
        POINVHeader."Invoice Received Date" := Rec.InvoiceDate;
        POINVHeader."Supplier Name" := Rec."Supplier Name";
        POINVHeader."P2P Supplier ABN" := Rec."Supplier ABN";
        POINVHeader."Purchase Order No." := Rec.DocumentNumber;
        POINVHeader."EDI File Log Entry No." := EDIFileLogEntryNo;
        POINVHeader."Buy-from Vendor No." := Rec."Vendor No.";
        POINVHeader.INSERT();
        Vendor.GET(Rec."Vendor No.");
        IF Vendor."GXL EDI Vendor Type" = Vendor."GXL EDI Vendor Type"::"Point 2 Point Contingency" THEN
            InsertPOInvLine_P2PContingency(Rec.DocumentNumber, POINVHeader."No.")
        ELSE
            InsertPOInvLine(Rec.DocumentNumber, POINVHeader."No.");
        DeleteEDIPurchaseMessage(Rec.DocumentNumber);
    end;

    var
        EDISetup: Record "GXL Integration Setup";
        EDIFileLogEntryNo: Integer;

    [Scope('OnPrem')]
    procedure InsertPOInvLine(InputDocumentNo: Code[20]; P2PInvoiceNo: Code[20])
    var
        EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
        POInvLine: Record "GXL PO INV Line";
    begin
        EDIPurchaseMessages.SETCURRENTKEY(ImportDoc, DocumentNumber);
        EDIPurchaseMessages.SETRANGE(ImportDoc, EDIPurchaseMessages.ImportDoc::"2"); //Invoice
        EDIPurchaseMessages.SETRANGE(DocumentNumber, InputDocumentNo);
        IF EDIPurchaseMessages.FINDSET(TRUE) THEN
            REPEAT
                POInvLine.INIT();
                POInvLine."INV No." := P2PInvoiceNo;
                POInvLine."Line No." := EDIPurchaseMessages.LineReference;
                POInvLine."PO Line No." := EDIPurchaseMessages.LineReference;
                POInvLine."Vendor Reorder No." := EDIPurchaseMessages.Items;
                POInvLine.Description := EDIPurchaseMessages.Description;
                POInvLine."Qty. to Invoice" := EDIPurchaseMessages.QtyToInvoice;
                POInvLine."Primary EAN" := EDIPurchaseMessages.GTIN;
                POInvLine."Direct Unit Cost" := EDIPurchaseMessages.UnitCostExcl;
                POInvLine.Amount := EDIPurchaseMessages.LineAmountExcl;
                POInvLine."Amount Incl. VAT" := EDIPurchaseMessages.LineAmountIncl;
                POInvLine.INSERT();
            UNTIL EDIPurchaseMessages.NEXT() = 0;
    end;

    [Scope('OnPrem')]
    procedure InsertPOInvLine_P2PContingency(InputDocumentNo: Code[20]; P2PInvoiceNo: Code[20])
    var
        EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
        POInvLine: Record "GXL PO INV Line";
    begin
        EDIPurchaseMessages.SETCURRENTKEY(ImportDoc, DocumentNumber);
        EDIPurchaseMessages.SETRANGE(ImportDoc, EDIPurchaseMessages.ImportDoc::"2"); //Invoice
        EDIPurchaseMessages.SETRANGE(DocumentNumber, InputDocumentNo);
        IF EDIPurchaseMessages.FINDSET(TRUE) THEN
            REPEAT
                POInvLine.INIT();
                POInvLine."INV No." := P2PInvoiceNo;
                POInvLine."Line No." := EDIPurchaseMessages.LineReference;
                POInvLine."PO Line No." := EDIPurchaseMessages.LineReference;
                POInvLine."Vendor Reorder No." := EDIPurchaseMessages.SupplierNo;
                POInvLine."Item No." := EDIPurchaseMessages.Items;
                POInvLine.Description := EDIPurchaseMessages.Description;
                POInvLine."Qty. to Invoice" := EDIPurchaseMessages.QtyToInvoice;
                POInvLine."Primary EAN" := EDIPurchaseMessages.GTIN;
                POInvLine."Direct Unit Cost" := EDIPurchaseMessages.UnitCostExcl;
                POInvLine.Amount := EDIPurchaseMessages.LineAmountExcl;
                POInvLine."Amount Incl. VAT" := EDIPurchaseMessages.LineAmountIncl;
                POInvLine."Unit of Measure Code" := EDIPurchaseMessages."Unit of Measure Code";
                POInvLine.ILC := EDIPurchaseMessages.ILC;
                POInvLine.INSERT();
            UNTIL EDIPurchaseMessages.NEXT() = 0;
    end;

    [Scope('OnPrem')]
    procedure DeleteEDIPurchaseMessage(InputDocumentNo: Code[20])
    var
        EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
    begin
        EDIPurchaseMessages.SETCURRENTKEY(ImportDoc, DocumentNumber);
        EDIPurchaseMessages.SETRANGE(ImportDoc, EDIPurchaseMessages.ImportDoc::"2");
        EDIPurchaseMessages.SETRANGE(DocumentNumber, InputDocumentNo);
        IF EDIPurchaseMessages.FINDSET(TRUE) THEN
            REPEAT
                EDIPurchaseMessages.DELETE();
            UNTIL EDIPurchaseMessages.NEXT() = 0;
    end;

    [Scope('OnPrem')]
    procedure SetOption(InputEDILogEntryNo: Integer)
    begin
        EDIFileLogEntryNo := InputEDILogEntryNo;
    end;
}

