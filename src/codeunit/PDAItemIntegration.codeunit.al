codeunit 50261 "GXL PDA-Item Integration"
{
    Permissions = tabledata "Stockkeeping Unit" = rm,
        tabledata "GXL PDA-Facing Update by Store" = i,
        tabledata "GXL PDA-Stock Adj. Buffer" = i,
        tabledata "Item Ledger Entry" = r,
        tabledata "LSC Trans. Sales Entry Status" = r,
        tabledata "Purchase Line" = r,
        tabledata "Transfer Line" = r,
        tabledata "Sales Line" = r;

    trigger OnRun()
    begin

    end;

    var
        SupplyChainSetup: Record "GXL Supply Chain Setup";
        SetupRead: Boolean;

    procedure UpdateFacing(StoreCode: Code[10]; ItemCode: Code[20]; UOM: Code[10]; IntFacing: Integer; CashierNumber: Code[50]): Text
    var
        SKU: Record "Stockkeeping Unit";
        Facing: Record "GXL PDA-Facing Update by Store";
    begin
        SKU.SetRange("Location Code", StoreCode);
        SKU.SetRange("Item No.", ItemCode);
        if SKU.FindFirst() then begin
            if SKU."GXL Facing" <> IntFacing then begin
                SKU.Validate("GXL Facing", IntFacing);
                SKU.Modify(true);
            end;

            Facing.Init();
            Facing."Entry No." := 0;
            Facing."Store Code" := StoreCode;
            Facing."Item No." := ItemCode;
            Facing."Unit of Measure Code" := UOM;
            Facing."Store Facing" := IntFacing;
            if CashierNumber <> '' then
                Facing."Cashier Number" := CashierNumber
            else
                Facing."Cashier Number" := UserId();

            Facing.Insert(true);
        end;

    end;

    procedure FindSOHReasonCode(): Code[10]
    var
        ReasonCode: Record "Reason Code";
    begin
        ReasonCode.SetRange("GXL PDA-SOH Update", true);
        if ReasonCode.FindFirst() then
            exit(ReasonCode.Code)
        else
            exit('');
    end;

    procedure InsertPDAStockAdjBuffer(InputType: Option ADJ,SOH,ALL; InputStoreCode: Code[10]; InputItemCode: Code[20]; InputUOM: Code[10]; InputSOH: Decimal;
        InputReasonCode: Code[10]; ClaimDocumentType: Option " ",PO,PI,STO,"STO-SHIP","STO-REC"; ClaimDocumentNo: Code[20])
    var
        PDAStockAdjBuffer: Record "GXL PDA-Stock Adj. Buffer";
    begin
        PDAStockAdjBuffer.Init();
        PDAStockAdjBuffer."Entry No." := 0;
        PDAStockAdjBuffer.Type := InputType;
        PDAStockAdjBuffer."Store Code" := InputStoreCode;
        PDAStockAdjBuffer."Item No." := InputItemCode;
        PDAStockAdjBuffer."Unit of Measure Code" := InputUOM;
        PDAStockAdjBuffer."Stock on Hand" := InputSOH;
        PDAStockAdjBuffer."Reason Code" := InputReasonCode;
        PDAStockAdjBuffer."Claim Document Type" := ClaimDocumentType;
        PDAStockAdjBuffer."Claim Document No." := ClaimDocumentNo;
        //PS-2046+
        PDAStockAdjBuffer."MIM User ID" := UserId();
        //PS-2046-
        PDAStockAdjBuffer.Insert(true);
    end;

    ///<Summary>
    ///Get the last purchase/transfer receipt date into stock
    ///</Summary>
    procedure FindLastReceipLedgerEntry(SKU: Record "Stockkeeping Unit"; var ItemLedgEntry: Record "Item Ledger Entry"): Boolean
    begin
        ItemLedgEntry.SetCurrentKey("Item No.", "Location Code", "Posting Date");
        ItemLedgEntry.SetRange("Item No.", SKU."Item No.");
        ItemLedgEntry.SetRange("Location Code", SKU."Location Code");
        ItemLedgEntry.SetFilter("Entry Type", '%1|%2', ItemLedgEntry."Entry Type"::Purchase, ItemLedgEntry."Entry Type"::Transfer);
        ItemLedgEntry.SetFilter("Document Type", '%1|%2', ItemLedgEntry."Document Type"::"Purchase Receipt", ItemLedgEntry."Document Type"::"Transfer Receipt");
        if ItemLedgEntry.FindLast() then
            exit(true)
        else
            exit(false);
    end;

    ///<Summary>
    ///Get quantity on order
    ///</Summary>
    procedure FindStockOnOrderQty(var SKU: Record "Stockkeeping Unit"): Decimal
    var
        GetPurchQtyQry: Query "GXL Get Purchase Confirmed Qty";
        GetTransQtyQry: Query "GXL Get Transfer Confirmed Qty";
        SOOQuantity: Decimal;
    begin
        //SOO: stock on order
        SOOQuantity := 0;
        GetPurchQtyQry.SetRange(LocationCode, SKU."Location Code");
        GetPurchQtyQry.SetRange(ItemNo, SKU."Item No.");
        if GetPurchQtyQry.Open() then begin
            if GetPurchQtyQry.Read() then
                SOOQuantity := GetPurchQtyQry.ConfirmedQtyBase;
            GetPurchQtyQry.Close();
        end;

        SKU.CalcFields("Qty. in Transit");
        SOOQuantity += SKU."Qty. in Transit";

        GetTransQtyQry.SetRange(ItemNo, SKU."Item No.");
        GetTransQtyQry.SetRange(TransfertoCode, SKU."Location Code");
        if GetTransQtyQry.Open() then begin
            if GetTransQtyQry.Read() then
                SOOQuantity += GetTransQtyQry.QtyToReceiveBase;
            GetTransQtyQry.Close();
        end;

        exit(SOOQuantity);
    end;

    ///<Summary>
    ///Get quantity has been committed which includes sales order, transfer shipments (still in transit), Trans. Sales Entry not posted (POS)
    ///</Summary>
    procedure GetCommittedQty(var SKU: Record "Stockkeeping Unit"): Decimal
    begin
        exit(GetCommittedQty(SKU, false));
    end;

    procedure GetCommittedQty(var SKU: Record "Stockkeeping Unit"; ExcludePOS: Boolean): Decimal
    var
        Qty: Decimal;
        QtyPOSNotPosted: Decimal;
        QtyMagentoOrder: Decimal;
    begin
        SKU.CalcFields("Qty. on Sales Order", "Trans. Ord. Shipment (Qty.)");

        QtyPOSNotPosted := 0;
        if not ExcludePOS then //PS-1772
            GetUnpostedPOSQty(SKU);

        //Magento suspended trans
        QtyMagentoOrder := GetMagentoSuspendedQty(SkU);

        Qty := SKU."Qty. on Sales Order" + SKU."Trans. Ord. Shipment (Qty.)" + QtyPOSNotPosted + QtyMagentoOrder;
        exit(Qty);

    end;

    procedure GetCommittedQtyItemCheck(var SKU: Record "Stockkeeping Unit"): Decimal
    var
        QtyMagentoOrder: Decimal;
    begin
        //Magento suspended trans
        QtyMagentoOrder := GetMagentoSuspendedQty(SkU);

        exit(QtyMagentoOrder);

    end;

    procedure IsProductRanged(var SKU: Record "Stockkeeping Unit"): Boolean
    begin
        //ERP-NAV Master Data Management +
        GetSupplyChainSetup();
        if SupplyChainSetup."Ranging Is Active" then begin
            SKU.CalcFields("GXL Ranged");
            exit(SKU."GXL Ranged");
        end;
        //ERP-NAV Master Data Management -
        exit(true);
    end;

    ///<Summary>
    ///Find the earliest expected receipt date
    ///</Summary>
    procedure FindNextDeliveryDate(var SKU: Record "Stockkeeping Unit"): Date
    var
        NextPurchRcptDateQry: query "GXL Next Purch Receipt Date";
        NextTransRcptDateQry: query "GXL Next Transfer Receipt Date";
        RcptDate: Date;
        RcptDate2: Date;
        NextOverdueDate: Date;
    begin
        RcptDate := 0D;
        NextPurchRcptDateQry.SetRange(ItemNo, SKU."Item No.");
        NextPurchRcptDateQry.SetRange(LocationCode, SKU."Location Code");
        if NextPurchRcptDateQry.Open() then begin
            if NextPurchRcptDateQry.Read() then
                RcptDate := NextPurchRcptDateQry.ExpectedReceiptDate;
            NextPurchRcptDateQry.Close();
        end;

        NextTransRcptDateQry.SetRange(ItemNo, SKU."Item No.");
        NextTransRcptDateQry.SetRange(TransfertoCode, SKU."Location Code");
        if NextTransRcptDateQry.Open() then begin
            if NextTransRcptDateQry.Read() then
                RcptDate2 := NextTransRcptDateQry.ExpectedReceiptDate;
            NextTransRcptDateQry.Close();
        end;

        if (RcptDate2 <> 0D) and (RcptDate > RcptDate2) then
            NextOverdueDate := RcptDate2
        else
            NextOverdueDate := RcptDate;
        exit(NextOverdueDate);
    end;

    ///<Summary>
    ///Get the last purchase order date
    ///</Summary>
    procedure FindLastOrderDate(var SKU: Record "Stockkeeping Unit"; CompareDate: Date): Date
    var
        LastPurchOrdDateQry: Query "GXL Last Purchase Order Date";
        LastTransOrdDateQry: Query "GXL Last Transfer Order Date";
        LastDate: Date;
        LastDate2: Date;
    begin
        LastDate := 0D;
        LastPurchOrdDateQry.SetRange(ItemNo, SKU."Item No.");
        LastPurchOrdDateQry.SetRange(LocationCode, SKU."Location Code");
        LastPurchOrdDateQry.SetFilter(OrderDate, '<%1', CompareDate);
        LastPurchOrdDateQry.TopNumberOfRows(1);
        if LastPurchOrdDateQry.Open() then begin
            if LastPurchOrdDateQry.Read() then
                LastDate := LastPurchOrdDateQry.OrderDate;
            LastPurchOrdDateQry.Close();
        end;

        LastTransOrdDateQry.SetRange(ItemNo, SKU."Item No.");
        LastTransOrdDateQry.SetRange(TransfertoCode, SKU."Location Code");
        LastTransOrdDateQry.SetFilter(OrderDate, '<%1', CompareDate);
        LastTransOrdDateQry.TopNumberOfRows(1);
        if LastTransOrdDateQry.Open() then begin
            if LastTransOrdDateQry.Read() then
                LastDate2 := LastTransOrdDateQry.OrderDate;
            LastTransOrdDateQry.Close();
        end;

        if (LastDate <> 0D) and (LastDate2 > LastDate) then
            LastDate := LastDate2;
        exit(LastDate);
    end;

    ///<Summary>
    ///Get the earliest purchase order date
    ///</Summary>
    procedure FindNextOrderDate(var SKU: Record "Stockkeeping Unit"; CompareDate: Date): Date
    var
        NextPurchOrdDateQry: Query "GXL Next Purchase Order Date";
        NextTransOrdDateQry: Query "GXL Next Transfer Order Date";
        NextDate: Date;
        NextDate2: Date;
    begin
        NextDate := 0D;
        NextPurchOrdDateQry.SetRange(ItemNo, SKU."Item No.");
        NextPurchOrdDateQry.SetRange(LocationCode, SKU."Location Code");
        NextPurchOrdDateQry.SetFilter(OrderDate, '>=%1', CompareDate);
        NextPurchOrdDateQry.TopNumberOfRows(1);
        if NextPurchOrdDateQry.Open() then begin
            if NextPurchOrdDateQry.Read() then
                NextDate := NextPurchOrdDateQry.OrderDate;
            NextPurchOrdDateQry.Close();
        end;

        NextTransOrdDateQry.SetRange(ItemNo, SKU."Item No.");
        NextTransOrdDateQry.SetRange(TransfertoCode, SKU."Location Code");
        NextTransOrdDateQry.SetFilter(OrderDate, '>=%1', CompareDate);
        NextTransOrdDateQry.TopNumberOfRows(1);
        if NextTransOrdDateQry.Open() then begin
            if NextTransOrdDateQry.Read() then
                NextDate2 := NextTransOrdDateQry.OrderDate;
            NextTransOrdDateQry.Close();
        end;

        if (NextDate2 <> 0D) and (NextDate > NextDate2) then
            NextDate := NextDate2;
        exit(NextDate);
    end;

    ///<Summary>
    ///Get the total sales by store, by item
    ///</Summary>
    procedure FindLastSalesQty(var SKU: Record "Stockkeeping Unit"; DatePeriod: DateFormula; EndDate: Date): Decimal
    var
        LastSalesByStoreQry: Query "GXL Last Sales By Store";
        StartDate: Date;
        Last12WeeksSales: Decimal;
    begin
        Last12WeeksSales := 0;
        if EndDate = 0D then
            EndDate := WorkDate();
        StartDate := CalcDate(DatePeriod, EndDate);
        LastSalesByStoreQry.SetRange(StoreCode, SKU."Location Code");
        LastSalesByStoreQry.SetRange(ItemNo, SKU."Item No.");
        LastSalesByStoreQry.SetRange(TransDate, StartDate, EndDate);
        if LastSalesByStoreQry.Open() then begin
            if LastSalesByStoreQry.Read() then
                Last12WeeksSales := LastSalesByStoreQry.Quantity;
            LastSalesByStoreQry.Close();
        end;
        exit(Last12WeeksSales)
    end;

    procedure FindItemBarcode(ItemNo: Code[20]; UOMCode: Code[10]): Text
    var
        Barcodes: Record "LSC Barcodes";
        NewBarcode: Text;
    begin
        NewBarcode := '';
        Barcodes.SetRange("Item No.", ItemNo);
        Barcodes.SetRange("Unit of Measure Code", UOMCode);
        Barcodes.SetRange("Show for Item", true);
        if Barcodes.FindFirst() then
            NewBarcode := Barcodes."Barcode No."
        else begin
            Barcodes.SetRange("Show for Item");
            if Barcodes.FindFirst() then
                NewBarcode := Barcodes."Barcode No.";
        end;
        exit(NewBarcode);
    end;

    procedure GetRetailPrice(Item: Record Item; StoreCode: Code[10]): Decimal
    var
        //StorePriceGrp: Record "Store Price Group";
        //SalesPrice: Record "Sales Price";
        RetailPriceUtils: Codeunit "LSC Retail Price Utils";
        UnitPrice: Decimal;
    begin
        //PS-2243+
        // UnitPrice := 0;
        // StorePriceGrp.SetCurrentKey(Store, Priority);
        // StorePriceGrp.SetRange(Store, StoreCode);
        // StorePriceGrp.Ascending(false); //descending order
        // if StorePriceGrp.FindSet() then
        //     repeat
        //         if RetailPriceUtils.GetItemPrice(
        //             StorePriceGrp."Price Group Code", Item."No.", '', Today(), '', SalesPrice, Item."Base Unit of Measure")
        //         then begin
        //             UnitPrice := SalesPrice."Unit Price Including VAT";
        //             exit(UnitPrice);
        //         end;
        //     until StorePriceGrp.Next() = 0;

        UnitPrice := RetailPriceUtils.GetValidRetailPrice2(
            StoreCode, Item."No.", Today(), 0T, Item."Base Unit of Measure", '', '', '', '', '', '');
        //PS-2243-
        exit(UnitPrice);
    end;

    procedure GetItemCostPrice(Item: Record Item): Decimal
    begin
        if Item."Costing Method" = Item."Costing Method"::Standard then
            exit(Item."Standard Cost")
        else
            exit(Item."Unit Cost");
    end;

    procedure GetSKUCostPrice(Item: Record Item; SKU: Record "Stockkeeping Unit"): Decimal
    begin
        if Item."Costing Method" = Item."Costing Method"::Standard then
            exit(SKU."Standard Cost")
        else
            exit(SKU."Unit Cost");
    end;

    procedure GetItemGXLCostPrice(Item: Record Item): Decimal
    begin
        exit(Item."GXL Standard Cost");
    end;

    //PS-2089+
    //Moved from GetCommittedQty
    procedure GetUnpostedPOSQty(var SKU: Record "Stockkeeping Unit"): Decimal
    var
        TransSalesEntryStatus: Record "LSC Trans. Sales Entry Status";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        QtyPOSNotPosted: Decimal;
    begin
        //Posted entries
        TransSalesEntryStatus.SetCurrentKey("Item No.", "Variant Code", Status, "Store No.", Date);
        TransSalesEntryStatus.SetRange("Item No.", SKU."Item No.");
        TransSalesEntryStatus.SetRange("Store No.", SKU."Location Code");
        TransSalesEntryStatus.SetFilter(Status, '<>%1', TransSalesEntryStatus.Status::" ");
        TransSalesEntryStatus.CalcSums(Quantity);

        //All entries
        TransSalesEntry.SetCurrentKey("Item No.", "Variant Code", Date, "Store No.", "Serial No.", "Lot No.");
        TransSalesEntry.SetRange("Item No.", SKU."Item No.");
        TransSalesEntry.SetRange("Store No.", SKU."Location Code");
        TransSalesEntry.CalcSums(Quantity);

        QtyPOSNotPosted := -(TransSalesEntry.Quantity - TransSalesEntryStatus.Quantity);

        exit(QtyPOSNotPosted);

    end;

    //Moved from GetCommittedQty
    procedure GetMagentoSuspendedQty(var SKU: Record "Stockkeeping Unit"): Decimal
    var
        POSTransaction: Record "LSC POS Transaction";
        POSTransLine: Record "LSC POS Trans. Line";
        ItemUOM: Record "Item Unit of Measure";
        QtyMagentoOrder: Decimal;
        QtyPer: Decimal;
    begin
        //Magento suspended trans
        QtyMagentoOrder := 0;
        POSTransaction.SetCurrentKey("GXL Magento Web Order");
        POSTransaction.SetRange("GXL Magento Web Order", true);
        POSTransaction.SetRange("Transaction Type", POSTransaction."Transaction Type"::Sales);
        POSTransaction.SetFilter("Trans. Status", '<>%1', POSTransaction."Trans. Status"::Voided);
        POSTransaction.SetRange("Store No.", SKU."Location Code");
        if POSTransaction.FindSet() then
            repeat
                POSTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
                POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
                POSTransLine.SetRange(Number, SKU."Item No.");
                if POSTransLine.FindSet() then
                    repeat
                        //PS-1799 +
                        //QtyMagentoOrder += POSTransLine.Quantity;
                        if ItemUOM.Get(POSTransLine.Number, POSTransLine."Unit of Measure") then
                            QtyPer := ItemUOM."Qty. per Unit of Measure"
                        else
                            QtyPer := 1;
                        QtyMagentoOrder := QtyMagentoOrder + Round(QtyPer * POSTransLine.Quantity, 0.00001);
                    //PS-1799 -
                    until POSTransLine.Next() = 0;
            until POSTransaction.Next() = 0;

        exit(QtyMagentoOrder);

    end;
    //PS-2089+

    //ERP-NAV Master Data Management +
    local procedure GetSupplyChainSetup()
    begin
        if not SetupRead then begin
            SupplyChainSetup.Get();
            SetupRead := true;
        end;
    end;
    //ERP-NAV Master Data Management -
}