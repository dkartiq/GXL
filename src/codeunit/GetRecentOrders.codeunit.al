codeunit 50265 "GXL Get Recent Orders"
{
    trigger OnRun()
    begin
        GetRecentOrders('204', '132985', '');    // just for testing
    end;

    var
        GlobalDocType: Option " ",PO,PI,STO,"STO-SHIP","STO-REC";

    procedure GetRecentOrders(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[10]): Text
    var
        IntegrationSetup: Record "GXL Integration Setup";
        TempBuffer: Record "Purch. Inv. Header" temporary;
        DateFilter: Text;
        RecentOrderDays: Integer;
    begin
        IntegrationSetup.Get();
        IntegrationSetup.TestField("Recent Order Days");
        RecentOrderDays := IntegrationSetup."Recent Order Days";
        DateFilter := GetDateFilter(RecentOrderDays);

        TempBuffer.Reset();
        TempBuffer.DeleteAll();

        if SourceOfSupplyIsWareHouse(LocationCode, ItemNo, VariantCode) then
            GetTransfers(DateFilter, LocationCode, ItemNo, TempBuffer)
        ELSE
            GetPurchases(DateFilter, LocationCode, ItemNo, TempBuffer);

        if not TempBuffer.IsEmpty() then
            exit(CreateRecentOrdersXML(TempBuffer))
        else
            exit('');
    end;

    local procedure GetPurchases(DateFilter: Text; LocationCode: Code[10]; ItemNo: Code[20]; var TempBuffer: Record "Purch. Inv. Header" temporary)
    begin
        // Get purchase orders / invoices received in the last x days
        GetOpenPurchases(DateFilter, LocationCode, ItemNo, TempBuffer);
        GetClosedPurchases(DateFilter, LocationCode, ItemNo, TempBuffer);
        GetInvoicedPurchases(DateFilter, LocationCode, ItemNo, TempBuffer);
    end;

    local procedure GetOpenPurchases(DateFilter: Text; LocationCode: Code[10]; ItemNo: Code[20]; var TempBuffer: Record "Purch. Inv. Header" temporary)
    var
        PurchaseLine: Record "Purchase Line";
        AdjustedQty: Decimal; // >> LCB-262 <<
        EntryTypeP: Option ,Purchase,Transfer;  // >> LCB-120 <<
    begin
        PurchaseLine.SetCurrentKey(Type, "No.", "Variant Code", "Drop Shipment", "Location Code", "Document Type", "Expected Receipt Date");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetFilter("No.", ItemNo);
        PurchaseLine.SetFilter("Location Code", LocationCode);
        //TODO: Order Status on purchase
        PurchaseLine.SetFilter("GXL Order Status", '%1|%2', PurchaseLine."GXL Order Status"::Placed, PurchaseLine."GXL Order Status"::Confirmed); // >> HP2-Spriny2 <<
        PurchaseLine.SetFilter("Expected Receipt Date", DateFilter);
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetAutoCalcFields("GXL Order Status");
        if PurchaseLine.FindSet() then
            repeat
                //TODO: Order Status
                if PurchaseLine."GXL Order Status" <= PurchaseLine."GXL Order Status"::Confirmed then begin
                    // ,PO,PI,STO,STO-SHIP,STO-REC
                    // >> LCB-120
                    //UpdateBuffer(TempBuffer, PurchaseLine."Document No.", PurchaseLine."Expected Receipt Date", GlobalDocType::PO);
                    AdjustedQty := GetRemQty(EntryTypeP::Purchase, PurchaseLine."Document No.", PurchaseLine."No.", PurchaseLine."Location Code");
                    UpdateBuffer(TempBuffer, PurchaseLine."Document No.", PurchaseLine."Expected Receipt Date", GlobalDocType::PO, PurchaseLine."Qty. Received (Base)" - AdjustedQty);
                end;
            // << LCB-120
            until PurchaseLine.Next() = 0;
    end;

    local procedure GetClosedPurchases(DateFilter: Text; LocationCode: Code[10]; ItemNo: Code[20]; VAR TempBuffer: Record "Purch. Inv. Header" temporary)
    var
        PurchaseHeader: Record "Purchase Header";
        // >> LCB-120
        PurchLine: Record "Purchase Line";
        AdjustedQty: Decimal;
        EntryTypeP: Option ,Purchase,Transfer;  // >> LCB-120 <<
    // << LCB-120
    begin
        //TODO: Order Status - PDA get recent order for Closed status
        PurchaseHeader.SetCurrentKey("GXL Order Status");
        PurchaseHeader.SetFilter("Posting Date", DateFilter);
        PurchaseHeader.SetRange("GXL Order Status", PurchaseHeader."GXL Order Status"::Closed);
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetFilter("Location Code", LocationCode);
        if PurchaseHeader.FindSet() then
            repeat
                // >> LCB-120
                //if PurchaseOrderHasItem(PurchaseHeader."No.", ItemNo) then
                //UpdateBuffer(TempBuffer, PurchaseHeader."No.", PurchaseHeader."Posting Date", GlobalDocType::PO);
                if PurchaseOrderHasItem(PurchaseHeader."No.", ItemNo) then begin
                    PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
                    PurchLine.SetRange("Document No.", PurchaseHeader."No.");
                    PurchLine.SetRange("Location Code", LocationCode);
                    PurchLine.SetRange(Type, PurchLine.Type::Item);
                    PurchLine.SetRange("No.", ItemNo);
                    PurchLine.CalcSums("Qty. Received (Base)");
                    AdjustedQty := GetRemQty(EntryTypeP::Purchase, PurchaseHeader."No.", ItemNo, LocationCode);
                    UpdateBuffer(TempBuffer, PurchaseHeader."No.", PurchaseHeader."Posting Date", GlobalDocType::PO, PurchLine."Qty. Received (Base)" - AdjustedQty);
                end;
            // << LCB-120
            until PurchaseHeader.Next() = 0;
    end;

    local procedure GetInvoicedPurchases(DateFilter: Text; LocationCode: Code[10]; ItemNo: Code[20]; VAR TempBuffer: Record "Purch. Inv. Header" temporary)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        // >> 120
        PurchInvLine: Record "Purch. Inv. Line";
        AdjustedQty: Decimal;
        EntryTypeP: Option ,Purchase,Transfer;
    // << 120
    begin
        PurchInvHeader.SetCurrentKey("Posting Date");
        PurchInvHeader.SetFilter("Posting Date", DateFilter);
        PurchInvHeader.SetFilter("Location Code", LocationCode);
        if PurchInvHeader.FindSet() then
            repeat
                // >> LCB-120
                //if PurchaseInvoiceHasItem(PurchInvHeader."No.", ItemNo) then  
                //UpdateBuffer(TempBuffer, PurchInvHeader."Order No.", PurchInvHeader."Posting Date", GlobalDocType::PI);
                if PurchaseInvoiceHasItem(PurchInvHeader."No.", ItemNo) then begin
                    PurchInvLine.SetRange("Document No.", PurchInvHeader."No.");
                    PurchInvLine.SetRange("Location Code", LocationCode);
                    PurchInvLine.SetRange(Type, PurchInvLine.Type::Item);
                    PurchInvLine.SetRange("No.", ItemNo);
                    PurchInvLine.CalcSums(Quantity);
                    AdjustedQty := GetRemQty(EntryTypeP::Purchase, PurchInvHeader."Order No.", ItemNo, LocationCode);
                    UpdateBuffer(TempBuffer, PurchInvHeader."Order No.", PurchInvHeader."Posting Date", GlobalDocType::PI, PurchInvLine.Quantity - AdjustedQty);
                end;
            // << LCB-120
            until PurchInvHeader.Next() = 0;
    end;

    local procedure GetTransfers(DateFilter: Text; LocationCode: Code[10]; ItemNo: Code[20]; VAR TempBuffer: Record "Purch. Inv. Header" temporary)
    begin
        GetTransferReceipts(DateFilter, LocationCode, ItemNo, TempBuffer);
        //GetTransferShipments(DateFilter, LocationCode, ItemNo, TempBuffer);   // >> LCB-120 <<
    end;

    local procedure GetTransferShipments(DateFilter: Text; LocationCode: Code[10]; ItemNo: Code[20]; VAR TempBuffer: Record "Purch. Inv. Header" temporary)
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
        AdjustedQty: Decimal;   // >> LCB-262 <<
        EntryTypeP: Option ,Purchase,Transfer;  // >> LCB-120 <<
    begin
        TransferShipmentLine.SetCurrentKey("Transfer Order No.", "Item No.", "Shipment Date");
        TransferShipmentLine.SetFilter("Shipment Date", DateFilter);
        TransferShipmentLine.SetFilter("Item No.", ItemNo);
        TransferShipmentLine.SetFilter("Transfer-to Code", LocationCode);
        if TransferShipmentLine.FindSet() then
            repeat
                // ,PO,PI,STO,STO-SHIP,STO-REC
                // >> LCB-120
                //UpdateBuffer(TempBuffer, TransferShipmentLine."Transfer Order No.", TransferShipmentLine."Shipment Date", GlobalDocType::"STO-SHIP");
                AdjustedQty := GetRemQty(EntryTypeP::Transfer, TransferShipmentLine."Transfer Order No.", ItemNo, LocationCode);
                UpdateBuffer(TempBuffer, TransferShipmentLine."Transfer Order No.", TransferShipmentLine."Shipment Date", GlobalDocType::"STO-SHIP", TransferShipmentLine.Quantity - AdjustedQty);
            // << LCB-120
            until TransferShipmentLine.Next() = 0;
    end;

    local procedure GetTransferReceipts(DateFilter: Text; LocationCode: Code[10]; ItemNo: Code[20]; VAR TempBuffer: Record "Purch. Inv. Header" temporary)
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
        AdjustedQty: Decimal;   // >> LCB-262 <<
        EntryTypeP: Option ,Purchase,Transfer;  // >> LCB-120 <<
    begin
        TransferReceiptLine.SetCurrentKey("Transfer Order No.", "Item No.", "Receipt Date");
        TransferReceiptLine.SetFilter("Receipt Date", DateFilter);
        TransferReceiptLine.SetFilter("Item No.", ItemNo);
        TransferReceiptLine.SetFilter("Transfer-to Code", LocationCode);
        if TransferReceiptLine.FindSet() then
            repeat
                // >> LCB-120
                //UpdateBuffer(TempBuffer, TransferReceiptLine."Transfer Order No.", TransferReceiptLine."Receipt Date", GlobalDocType::"STO-REC");
                AdjustedQty := GetRemQty(EntryTypeP::Transfer, TransferReceiptLine."Transfer Order No.", ItemNo, LocationCode);
                UpdateBuffer(TempBuffer, TransferReceiptLine."Transfer Order No.", TransferReceiptLine."Receipt Date", GlobalDocType::"STO-REC", TransferReceiptLine.Quantity - AdjustedQty);
            // << LCB-120
            until TransferReceiptLine.Next() = 0;
    end;

    local procedure UpdateBuffer(VAR TempBuffer: Record "Purch. Inv. Header" temporary; DocumentNo: Code[20]; SortDate: Date; DocumentType: Integer)
    begin
        if (DocumentNo = '') or (SortDate = 0D) then
            exit;

        if not TempBuffer.Get(DocumentNo) then begin
            TempBuffer.init();
            TempBuffer."No." := DocumentNo;
            TempBuffer."Posting Date" := SortDate;
            TempBuffer."No. Printed" := DocumentType;  // piggyback
            TempBuffer.insert();
        end;
    end;

    // >> LCB-120
    local procedure GetRemQty(EntryTypeP: Option ,Purchase,Transfer; DocNoP: Code[20]; ItemNoP: Code[20]; StoreCodeP: code[20]): Decimal
    var
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        PDAStockAdjBuffer: Record "GXL PDA-Stock Adj. Buffer";
        PDAReceivingBuffer: Record "GXL PDA-PL Receive Buffer";
        PDAPurchaseLine: Record "GXL PDA-Purchase Lines";
        RemQtyL: Decimal;
    begin
        PDAStockAdjProcessingBuffer.SetRange("Claim-to Order No.", DocNoP);
        PDAStockAdjProcessingBuffer.SetRange("Item No.", ItemNoP);
        PDAStockAdjProcessingBuffer.SetRange("Store Code", StoreCodeP);
        PDAStockAdjProcessingBuffer.SetRange(Type, PDAStockAdjProcessingBuffer.Type::ADJ);

        PDAStockAdjBuffer.SetRange("Claim Document No.", DocNoP);
        PDAStockAdjBuffer.SetRange("Item No.", ItemNoP);
        PDAStockAdjBuffer.SetRange("Store Code", StoreCodeP);
        PDAStockAdjBuffer.SetRange(Type, PDAStockAdjBuffer.Type::ADJ);

        PDAReceivingBuffer.SetRange("Document No.", DocNoP);
        PDAReceivingBuffer.SetRange("No.", ItemNoP);

        PDAPurchaseLine.SetRange("Document No.", DocNoP);
        PDAPurchaseLine.SetRange("Item No.", ItemNoP);

        case EntryTypeP of
            EntryTypeP::Purchase:
                begin
                    PDAStockAdjProcessingBuffer.SetFilter("Claim-to Document Type", '%1|%2', PDAStockAdjProcessingBuffer."Claim-to Document Type"::PO, PDAStockAdjProcessingBuffer."Claim-to Document Type"::PI);
                    PDAStockAdjBuffer.SetFilter("Claim Document Type", '%1|%2', PDAStockAdjBuffer."Claim Document Type"::PO, PDAStockAdjBuffer."Claim Document Type"::PI);
                    PDAReceivingBuffer.SetRange("Entry Type", PDAReceivingBuffer."Entry Type"::Purchase);
                    PDAPurchaseLine.SetRange("Entry Type", PDAPurchaseLine."Entry Type"::Purchase);
                end;
            EntryTypeP::Transfer:
                begin
                    PDAStockAdjProcessingBuffer.SetFilter("Claim-to Document Type", '%1|%2', PDAStockAdjProcessingBuffer."Claim-to Document Type"::STO, PDAStockAdjProcessingBuffer."Claim-to Document Type"::"STO-REC");
                    PDAStockAdjBuffer.SetFilter("Claim Document Type", '%1|%2', PDAStockAdjProcessingBuffer."Claim-to Document Type"::STO, PDAStockAdjProcessingBuffer."Claim-to Document Type"::"STO-REC");
                    PDAReceivingBuffer.SetRange("Entry Type", PDAReceivingBuffer."Entry Type"::Transfer);
                    PDAPurchaseLine.SetRange("Entry Type", PDAPurchaseLine."Entry Type"::Transfer);
                end;
        end;

        PDAStockAdjBuffer.CalcSums("Stock on Hand");
        PDAStockAdjProcessingBuffer.CalcSums("Stock on Hand");
        PDAPurchaseLine.CalcSums(QtyToReceive, InvoiceQuantity);
        PDAReceivingBuffer.CalcSums(QtyToReceive, InvoiceQuantity);

        RemQtyL := PDAStockAdjBuffer."Stock on Hand" +
                   PDAStockAdjProcessingBuffer."Stock on Hand" +
                   PDAPurchaseLine.InvoiceQuantity - PDAPurchaseLine.QtyToReceive +
                   PDAReceivingBuffer.InvoiceQuantity - PDAReceivingBuffer.QtyToReceive;
        exit(RemQtyL);

    end;
    // << LCB-120

    // >> LCB-120
    //local procedure UpdateBuffer(VAR TempBuffer: Record "Purch. Inv. Header" temporary; DocumentNo: Code[20]; SortDate: Date; DocumentType: Integer)
    local procedure UpdateBuffer(VAR TempBuffer: Record "Purch. Inv. Header" temporary; DocumentNo: Code[20]; SortDate: Date; DocumentType: Integer; RemQty: Decimal)
    // << LCB-120
    begin
        // >> LCB-120
        //if (DocumentNo = '') or (SortDate = 0D) then
        //    exit
        if (DocumentNo = '') or (SortDate = 0D) or (RemQty = 0) then
            exit;
        // << LCB-120
        if not TempBuffer.Get(DocumentNo) then begin
            TempBuffer.init();
            TempBuffer."No." := DocumentNo;
            TempBuffer."Posting Date" := SortDate;
            TempBuffer."No. Printed" := DocumentType;  // piggyback
            TempBuffer."Currency Factor" := RemQty; // >> LCB-120 <<
            TempBuffer.insert();
        end;
    end;

    local procedure GetDateFilter(RecentOrderDays: Integer): Text
    var
        Dates: Record Date;
        DateExpression: Text;
    begin

        DateExpression := StrSubstNo('-%1D', RecentOrderDays);

        Dates.SetRange("Period Type", Dates."Period Type"::Date);
        Dates.SetRange("Period Start", CalcDate(DateExpression, Today()), Today());
        exit(Dates.GetFilter("Period Start"));
    end;

    local procedure PurchaseOrderHasItem(DocumentNo: Code[20]; ItemNo: Code[20]): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetRange("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange("Document No.", DocumentNo);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        PurchaseLine.SetRange("No.", ItemNo);
        exit(not PurchaseLine.IsEmpty());
    end;

    local procedure PurchaseInvoiceHasItem(DocumentNo: Code[20]; ItemNo: Code[20]): Boolean
    var
        PurchaseInvoiceLine: Record "Purch. Inv. Line";
    begin
        PurchaseInvoiceLine.SetRange("Document No.", DocumentNo);
        PurchaseInvoiceLine.SetRange(Type, PurchaseInvoiceLine.Type::Item);
        PurchaseInvoiceLine.SetRange("No.", ItemNo);
        exit(not PurchaseInvoiceLine.IsEmpty());
    end;

    local procedure SourceOfSupplyIsWarehouse(LocationCode: Code[10]; ItemNo: Code[20]; VariantCode: Code[20]): Boolean
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        StockkeepingUnit.Get(LocationCode, ItemNo, VariantCode);
        exit(StockkeepingUnit."GXL Source of Supply" = StockkeepingUnit."GXL Source of Supply"::WH);
    end;

    procedure CreateRecentOrdersXML(var TempPurchInvHeader: Record "Purch. Inv. Header" temporary) OuterXML: Text
    var
        XmlDomMgt: Codeunit "GXL XML DOM Mgt.";
        xmlDoc: XmlDocument;
        xmlNodeRecentOrders: XmlNode;
        xmlNodeOrder: XmlNode;
    begin
        OuterXML := '';
        TempPurchInvHeader.Reset();
        TempPurchInvHeader.SetCurrentKey("Posting Date");
        if TempPurchInvHeader.FindSet() then begin
            xmlDoc := XmlDocument.Create();
            XmlDomMgt.LoadXMLDocumentFromText('<RecentOrders></RecentOrders>', xmlDoc);
            XmlDomMgt.GetRootNode(xmlDoc, xmlNodeRecentOrders);
            XmlDomMgt.SetUTF88Declaration(xmlDoc, '');
            repeat
                XmlDomMgt.AddElement(xmlNodeRecentOrders, 'Order', '', '', xmlNodeOrder);
                XmlDomMgt.AddNode(xmlNodeOrder, 'OrderNo', TempPurchInvHeader."No.");
                XmlDomMgt.AddNode(xmlNodeOrder, 'ReceivedDate', Format(TempPurchInvHeader."Posting Date", 0, 9));
                XmlDomMgt.AddNode(xmlNodeOrder, 'DocumentType', Format(TempPurchInvHeader."No. Printed"));
                XmlDomMgt.AddNode(xmlNodeOrder, 'RemainingQuantity', Format(TempPurchInvHeader."Currency Factor")); // >> LCB-120 <<
            until TempPurchInvHeader.Next() = 0;
            xmlDoc.WriteTo(OuterXML);
        end;
    end;

}