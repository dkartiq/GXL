codeunit 50270 "GXL Stock Adj. Validate"
{
    /*Change Log
        PS-2304 30-09-20 LP
            Removed VendorClaimClassification as it is removed from NAV13
            Use Ullaged Supplier from Vendor table
        ERP-340 06-08-21 LP
            Pre ERP and exflow - claim for non-ullaged vendors was done when invoice created
            Post ERP and exflow - due to deplay on processing invoice, 
                inventory is required to be updated, created a return order instead of credit note

    */

    TableNo = "GXL PDA-StAdjProcessing Buffer";

    trigger OnRun()
    var
        Vendor: Record Vendor;
        PostedDocumentNo: Code[20];
    begin
        ValidateSKUExists(Rec);
        ValidateClaimToVendorAndOrderNo(Rec, Vendor, PostedDocumentNo);
        Rec."Claim-to Vendor No." := Vendor."No.";
        //PS-2304+
        //"Vendor Ullaged Status" := VendorUllageClaimClassification(Vendor, "Reason Code");
        Rec."Vendor Ullaged Status" := Vendor."GXL Ullaged Supplier";
        //PS-2304-
        Rec."Claim-to Document No." := PostedDocumentNo;
    end;

    var
        DoesNotExistMsg: Label '%1 does not exist.';
        NotValidClaimTypeMsg: Label 'Not a valid claim type.';
        PurchOrderNotExistMsg: Label 'Purchase Order No. %1 not found.';
        TransOrderNotExistMsg: Label 'Transfer Order No. %1 not found.';


    local procedure ValidateSKUExists(PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        StockkeepingUnit.SetCurrentKey("Location Code", "Item No.");
        StockkeepingUnit.SetFilter("Location Code", PDAStockAdjProcessingBuffer."Store Code");
        StockkeepingUnit.SetFilter("Item No.", PDAStockAdjProcessingBuffer."Item No.");
        if StockkeepingUnit.IsEmpty() then
            Error(StrSubstNo(DoesNotExistMsg, StockkeepingUnit.TableCaption()));
    end;

    local procedure ValidateClaimToVendorAndOrderNo(PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer"; var Vendor: Record Vendor; var DocumentNo: Code[20])
    var
        StockAdjProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
        VendorNo: Code[20];
    begin
        CASE PDAStockAdjProcessingBuffer."Claim-to Document Type" OF
            PDAStockAdjProcessingBuffer."Claim-to Document Type"::PO:
                ValidatePO(PDAStockAdjProcessingBuffer."Claim-to Order No.", VendorNo, DocumentNo);
            PDAStockAdjProcessingBuffer."Claim-to Document Type"::PI:
                // ValidatePI(PDAStockAdjProcessingBuffer."Claim-to Order No.", VendorNo, DocumentNo); //ERP-340 -
                ValidatePI_PO(PDAStockAdjProcessingBuffer."Claim-to Order No.", VendorNo, DocumentNo); //ERP-340 +
            PDAStockAdjProcessingBuffer."Claim-to Document Type"::"STO-SHIP":
                ValidateSTOShipment(PDAStockAdjProcessingBuffer."Claim-to Order No.", DocumentNo);
            PDAStockAdjProcessingBuffer."Claim-to Document Type"::"STO-REC":
                ValidateSTOReceipt(PDAStockAdjProcessingBuffer."Claim-to Order No.", DocumentNo);
            else
                Error(NotValidClaimTypeMsg);
        end;

        if StockAdjProcessMgt.ClaimAppliesToPurchase(PDAStockAdjProcessingBuffer."Claim-to Document Type") then
            Vendor.Get(VendorNo)
        else
            Vendor.Init();
    end;

    local procedure ValidatePO(OrderNo: Code[20]; var VendorNo: Code[20]; var DocumentNo: Code[20])
    var
        PurchHeader: Record "Purchase Header";
    begin
        if PurchHeader.Get(PurchHeader."Document Type"::Order, OrderNo) then begin
            VendorNo := PurchHeader."Buy-from Vendor No.";
            // DocumentNo := '';  // Do not return if not an actual
        end else
            ValidatePI(OrderNo, VendorNo, DocumentNo);
    end;

    local procedure ValidatePI(OrderNo: Code[20]; var VendorNo: Code[20]; var DocumentNo: Code[20])
    var
        PurchInvoiceHeader: Record "Purch. Inv. Header";
    begin
        PurchInvoiceHeader.SetCurrentKey("Order No.");
        PurchInvoiceHeader.SetFilter("Order No.", OrderNo);
        if PurchInvoiceHeader.FindFirst() then begin
            VendorNo := PurchInvoiceHeader."Buy-from Vendor No.";
            DocumentNo := PurchInvoiceHeader."No.";
        end else
            ThrowDocumentNotFoundError(1, DocumentNo)
    end;

    //ERP-340 +
    local procedure ValidatePI_PO(OrderNo: Code[20]; var VendorNo: Code[20]; var DocumentNo: Code[20])
    var
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchInvoiceHeader.SetCurrentKey("Order No.");
        PurchInvoiceHeader.SetFilter("Order No.", OrderNo);
        if PurchInvoiceHeader.FindFirst() then begin
            VendorNo := PurchInvoiceHeader."Buy-from Vendor No.";
            DocumentNo := PurchInvoiceHeader."No.";
        end else begin
            if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, OrderNo) then begin
                VendorNo := PurchaseHeader."Buy-from Vendor No.";
            end else
                ThrowDocumentNotFoundError(1, DocumentNo)
        end;
    end;
    //ERP-340 -

    local procedure ValidateSTOShipment(OrderNo: Code[20]; var DocumentNo: Code[20])
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        //using line instead of header as line does have the key Transfer Order No.
        TransferShipmentLine.SetCurrentKey("Transfer Order No.");
        TransferShipmentLine.SetRange("Transfer Order No.", OrderNo);
        if TransferShipmentLine.FindFirst() then
            DocumentNo := TransferShipmentLine."Document No."
        else
            ThrowDocumentNotFoundError(3, DocumentNo);
    end;

    local procedure ValidateSTOReceipt(OrderNo: Code[20]; var DocumentNo: Code[20])
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        //using line instead of header as line does have the key Transfer Order No.
        TransferReceiptLine.SetCurrentKey("Transfer Order No.");
        TransferReceiptLine.SetRange("Transfer Order No.", OrderNo);
        if TransferReceiptLine.FindFirst() then
            DocumentNo := TransferReceiptLine."Document No."
        else
            ThrowDocumentNotFoundError(3, DocumentNo)
    end;

    local procedure ThrowDocumentNotFoundError(DocumentType: Option " ",PO,PI,STO,"STO-SHIP","STO-REC"; DocumentNo: Code[20])
    begin
        if DocumentType = DocumentType::PO then
            Error(StrSubstNo(PurchOrderNotExistMsg, DocumentNo))
        else
            Error(StrSubstNo(TransOrderNotExistMsg, DocumentNo))
    end;

    //PS-2304
    //Removed
    /*
    procedure VendorUllageClaimClassification(Vendor: Record Vendor; ClaimReasonCode: Code[10]): Integer
    var
        VendorClaimClassification: Record "GXL Vend. Claim Classification";
    begin
        if (VendorClaimClassification.Get(Vendor."No.", ClaimReasonCode)) AND
           (VendorClaimClassification."Ullage Claim Classification" <> 0)
        then
            exit(VendorClaimClassification."Ullage Claim Classification")
        else begin
            Vendor.TestField("GXL Ullaged Supplier");
            exit(Vendor."GXL Ullaged Supplier");
        end;
    end;
    */
    //PS-2304-
}