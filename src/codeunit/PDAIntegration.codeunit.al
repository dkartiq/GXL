codeunit 50250 "GXL PDA-Integration"
{
    //This codeunit is used to publish the MIM integration

    Permissions = tabledata "GXL PDA-Store User" = r;

    var
        ErrorText: Text;
        CannotBeBlankErr: Label '%1 cannot be blank.';
        CannotBeBlankOrZeroErr: Label '%1 cannot be blank or zero.';
        MustBeNagativeErr: Label '%1 must be a negative number.';

    procedure GetStoreUserList(UserCode: Code[50]; var xmlFile: XmlPort "GXL PDA-Store User"): Text
    begin
        ErrorText := '';
        ClearLastError();
        xmlFile.SetXMLFilters(UserCode, '');
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure CheckStoreUser(UserCode: Code[50]; StoreCode: Code[10]; var StoreUserOk: Boolean): Text
    var
        StoreUser: Record "GXL PDA-Store User";
    begin
        ErrorText := '';
        StoreUserOk := false;
        if StoreUser.Get(UserCode, StoreCode) then
            StoreUserOk := true
        else
            ErrorText := StrSubstNo('User %1 does not have access to store %2', UserCode, StoreCode);
    end;

    //#region "Item Check"
    procedure GetUOMs(ItemCodes: Text; var xmlFile: XmlPort "GXL PDA-Unit Of Measure"): Text
    begin
        ErrorText := '';
        ClearLastError();
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure GetItem(Input: Code[20]; UOM: Code[10]; var xmlFile: XmlPort "GXL PDA-Items"): Text
    begin
        ErrorText := '';
        ClearLastError();
        xmlFile.SetXMLFilter(Input, UOM);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure ItemCheck(StoreCode: Code[10]; ItemCode: Code[20]; var xmlFile: XmlPort "GXL PDA-Item Check"): Text
    begin
        ErrorText := '';
        ClearLastError();
        xmlFile.SetXMLFilters(StoreCode, ItemCode);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure ItemCheckSimple(StoreCode: Code[10]; ItemCode: Code[20]; UOM: Code[10]; var xmlFile: XmlPort "GXL PDA-Item Check Simple"): Text
    begin
        ErrorText := '';
        ClearLastError();
        xmlFile.SetXMLFilters(StoreCode, ItemCode, UOM);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;
    //#end region "Item Check"

    //#region "Edit Item"
    procedure GetReasonCodesMR(VendorNo: Code[20]; var ReasonCodes: XmlPort "GXL PDA-Reason Code"): Text
    var
        Vendor: Record Vendor;
    begin
        ErrorText := '';
        ClearLastError();

        if not Vendor.Get(VendorNo) then
            ReasonCodes.SetXMLFilterMR('0', true)
        else
            case Vendor."GXL Ullaged Supplier" of
                Vendor."GXL Ullaged Supplier"::" ":
                    ReasonCodes.SetXMLFilterMR('0', true);
                Vendor."GXL Ullaged Supplier"::Ullaged:
                    ReasonCodes.SetXMLFilterMR('0|1', true);
                Vendor."GXL Ullaged Supplier"::"Non-Ullaged":
                    ReasonCodes.SetXMLFilterMR('0|2', true);
            end;

        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    // >> LCB-120
    procedure GetReasonCodesMRILC(VendorNo: Code[20]; ILC: code[20]; var ReasonCodes: XmlPort "GXL PDA-Reason Code"): Text
    var
        Vendor: Record Vendor;
        Item: Record Item;
    begin
        ErrorText := '';
        ClearLastError();

        if not Vendor.Get(VendorNo) then
            ReasonCodes.SetXMLFilterMR('0', true)
        else
            case Vendor."GXL Ullaged Supplier" of
                Vendor."GXL Ullaged Supplier"::" ":
                    ReasonCodes.SetXMLFilterMR('0', true);
                Vendor."GXL Ullaged Supplier"::Ullaged:
                    ReasonCodes.SetXMLFilterMR('0|1', true);
                Vendor."GXL Ullaged Supplier"::"Non-Ullaged":
                    ReasonCodes.SetXMLFilterMR('0|2', true);
            end;

        if Item.GET(ILC) then
            ReasonCodes.SetXMLFilterMRILC(Item."GXL Source of Supply")
        else
            ReasonCodes.SetXMLFilterMRILC(Item."GXL Source of Supply"::XD);

        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;
    // << LCB-120

    procedure GetRecentOrdersMR(StoreCode: Code[10]; ItemCode: Code[20]): Text
    var
        GetRecentOrders: Codeunit "GXL Get Recent Orders";
    begin
        exit(GetRecentOrders.GetRecentOrders(StoreCode, ItemCode, ''));
    end;

    procedure InvAdjMR(StoreCode: Code[10]; ItemCode: Code[20]; UOM: Code[10]; decSOH: Decimal; ReasonCode: Code[10]; POType: Integer; PONumber: Code[20]): Text
    var
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
    begin
        //Manual Receipt for invenotry adjustment
        if StoreCode = '' then
            Error(StrSubstNo(CannotBeBlankErr, 'Store Code'));
        if ItemCode = '' then
            Error(StrSubstNo(CannotBeBlankErr, 'Item Code'));
        if UOM = '' then
            Error(StrSubstNo(CannotBeBlankErr, 'UOM'));
        if ReasonCode = '' then
            Error(StrSubstNo(CannotBeBlankErr, 'Reason Code'));

        if decSOH = 0 then
            Error(StrSubstNo(CannotBeBlankOrZeroErr, 'Quantity'));

        if (POType > 0) or (PONumber <> '') then begin
            if POType = 0 then
                Error(StrSubstNo(CannotBeBlankOrZeroErr, 'PO Type'));
            if PONumber = '' then
                Error(StrSubstNo(CannotBeBlankErr, 'Order Number'));
            if decSOH > 0 then
                Error(StrSubstNo(MustBeNagativeErr, 'Quantity'));
            decSOH := ABS(decSOH);
        end;

        //InputType=0 (ADJ)
        ClearLastError();
        PDAItemIntegration.InsertPDAStockAdjBuffer(0, StoreCode, ItemCode, UOM, decSOH, ReasonCode, POType, PONumber);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure UpdateFacing(StoreCode: Code[10]; ItemCode: Code[20]; UOM: Code[10]; IntFacing: Integer; CashierNumber: Code[50]): Text
    var
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
    begin
        ClearLastError();
        PDAItemIntegration.UpdateFacing(StoreCode, ItemCode, UOM, IntFacing, CashierNumber);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure UpdateSOH(StoreCode: Code[10]; ItemCode: Code[20]; UOM: Code[10]; decSOH: Decimal): Text
    var
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
        decNewSOH: Decimal;
        ReasonCode: Code[10];
    begin
        ClearLastError();
        decNewSOH := decSOH;

        //InputType=1 (SOH)
        //ClaimDocumentType=0
        ReasonCode := PDAItemIntegration.FindSOHReasonCode();
        PDAItemIntegration.InsertPDAStockAdjBuffer(1, StoreCode, ItemCode, UOM, decNewSOH, ReasonCode, 0, '');

        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    //#end region "Edit Item"

    //#region Transfer
    procedure GetStores(var xmlFile: XmlPort "GXL PDA-Store List"): Text
    begin
        ErrorText := '';
        ClearLastError();
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    //PS-2523 VET Clinic transfer order +
    procedure GetVETStores(var xmlFile: XmlPort "GXL PDA-VET Stores"): Text
    begin
        ErrorText := '';
        ClearLastError();
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;
    //PS-2523 VET Clinic transfer order -

    //PS-2523 VET Clinic transfer order: Added param VETStoreCode
    procedure CreateTransfer(StoreCode: Code[10]; ToStoreCode: Code[10]; VETStoreCode: Code[20]; BatchID: Integer; xmlInput: BigText; var OutboundXml: XmlPort "GXL PDA-Transfer Order"): Text
    var
        PDAStagingTOInt: Codeunit "GXL PDA-Staging TO Mgt.";
    begin
        ErrorText := '';
        ClearLastError();
        PDAStagingTOInt.CreateTransfer(StoreCode, ToStoreCode, VETStoreCode, BatchID, xmlInput, OutboundXml);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    ///Schema only, publish so that MIM can see the schema
    procedure CreateTransferXmlInputSchema(var xmlInput: XmlPort "GXL PDA-Rec Purchase Lines"): Text
    begin
        Error('It is a schema only');
    end;

    procedure GetAllTransToShip(StoreCode: Code[10]; var OutboundXml: XmlPort "GXL PDA-Transfer Order"): Text
    begin
        ErrorText := '';
        ClearLastError();
        OutboundXml.ShowFromTransfers(StoreCode);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure GetTransfer(DocumentNumber: Code[20]; var OutboundXml: XmlPort "GXL PDA-Transfer Order"): Text
    begin
        ErrorText := '';
        ClearLastError();
        OutboundXml.ShowTransferOrder(DocumentNumber);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure ShipTransfer(DocumentNumber: Code[20]): Text
    var
        PDATransShptInt: Codeunit "GXL PDA-Transfer Shipment Int.";
    begin
        ErrorText := '';
        ClearLastError();
        PDATransShptInt.ShipTransfer(DocumentNumber);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure ShipTransferLines(DocumentNumber: Code[20]; xmlInput: BigText): Text
    var
        PDATransShptInt: Codeunit "GXL PDA-Transfer Shipment Int.";
    begin
        ErrorText := '';
        ClearLastError();
        PDATransShptInt.ShipTransferLines(DocumentNumber, xmlInput);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    //PS-2411+
    procedure ShipTransferV2(DocumentNumber: Code[20]; var output: XmlPort "GXL PDA-TransferShptResult"): Text
    var
        PDATransShptInt: Codeunit "GXL PDA-Transfer Shipment Int.";
    begin
        ErrorText := '';
        ClearLastError();
        PDATransShptInt.ShipTransfer(DocumentNumber, output);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure ShipTransferLinesV2(DocumentNumber: Code[20]; xmlInput: BigText; var output: XmlPort "GXL PDA-TransferShptResult"): Text
    var
        PDATransShptInt: Codeunit "GXL PDA-Transfer Shipment Int.";
    begin
        ErrorText := '';
        ClearLastError();
        PDATransShptInt.ShipTransferLines(DocumentNumber, xmlInput, output);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;
    //PS-2411-

    ///Schema only, publish so that MIM can see the schema
    procedure ShipTransferLinesXmlInputSchema(var xmlInput: XmlPort "GXL PDA-Transfer Shpt. Line"): Text
    begin
        Error('It is a schema only');
    end;

    procedure GetAllTransToReceive(StoreCode: Code[10]; var OutboundXml: XmlPort "GXL PDA-Transfer Order"): Text
    begin
        ErrorText := '';
        ClearLastError();
        OutboundXml.ShowToTransfers(StoreCode);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;


    procedure ReceiveTransfer(DocumentNumber: Code[20]): Text
    var
        PDATransRcptInt: Codeunit "GXL PDA-Transfer Receipt Int.";
    begin
        ErrorText := '';
        ClearLastError();
        PDATransRcptInt.ReceiveTransfer(DocumentNumber);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure ReceiveTransferLines(DocumentNumber: Code[20]; xmlInput: BigText): Text
    var
        PDATransRcptInt: Codeunit "GXL PDA-Transfer Receipt Int.";
    begin
        ErrorText := '';
        ClearLastError();
        PDATransRcptInt.ReceiveTransferLines(DocumentNumber, xmlInput);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    ///Schema only, publish so that MIM can see the schema
    procedure ReceiveTransferLinesXmlInputSchema(xmlInput: XmlPort "GXL PDA-Transfer Rcpt. Line")
    begin
        Error('It is a schema only');
    end;
    //#end region Transfer

    //#region Purchase
    procedure GetActiveVendors(StoreCode: Code[10]; var OutbountXml: XmlPort "GXL PDA-Active Vendors"): Text
    begin
        ClearLastError();
        ErrorText := GetLastErrorText();
        OutbountXml.SetXmlFilter(StoreCode);
        exit(ErrorText);
    end;

    procedure CheckItemRange(StoreCode: Code[10]; ItemCode: Code[20]): Boolean
    var
        ProdRangingMgt: Codeunit "GXL Product Ranging Management";
    begin
        exit(ProdRangingMgt.IsRangedInProdStoreRanging(ItemCode, StoreCode));
    end;

    procedure CheckItemStoreDirect(StoreCode: Code[10]; ItemCode: Code[20]): Boolean
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.SetRange("Location Code", StoreCode);
        SKU.SetRange("Item No.", ItemCode);
        if SKU.FindFirst() then begin
            if SKU."GXL Source of Supply" = SKU."GXL Source of Supply"::SD then
                exit(true);
            exit(false);
        end;
    end;

    procedure CreatePO(StoreCode: Code[10]; BatchId: Integer; xmlInput: BigText; var OutboundXml: XmlPort "GXL PDA-Purchase Order"): Text
    var
    //PDAStagingPOMgt: Codeunit "GXL PDA-Staging PO Mgt.";
    begin
        //Not in this phase
        Error('This function should be called from NAV2013 endpoint');
        /*
        ClearLastError();
        PDAStagingPOMgt.CreatePO(StoreCode, BatchId, xmlInput, OutboundXml);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
        */
    end;


    procedure ShowNotSentPO(StoreCode: Code[10]; var OutboundXml: XmlPort "GXL PDA-Purchase Order"): Text
    begin
        ClearLastError();
        OutboundXml.ShowNewPOs((StoreCode));
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure CancelPO(PONumber: Code[20]): Text
    var
        PDAStagingPOMgt: Codeunit "GXL PDA-Staging PO Mgt.";
    begin
        ClearLastError();
        ErrorText := PDAStagingPOMgt.CancelPO(PONumber);
        if ErrorText = '' then
            ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure SendPOToSupplier(PONumber: Code[20]): Text
    var
        PDAStagingPOMgt: Codeunit "GXL PDA-Staging PO Mgt.";
    begin
        ClearLastError();
        PDAStagingPOMgt.SendPOToSupplier(PONumber);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure UpdatePOLine(PONumber: Code[20]; LineNumber: Integer; OrderQty: Decimal; ReasonCode: Code[10]): Text
    var
        PDAStagingPOMgt: Codeunit "GXL PDA-Staging PO Mgt.";
    begin
        ClearLastError();
        PDAStagingPOMgt.UpdatePOLine(PONumber, LineNumber, OrderQty, ReasonCode);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure AddNewPOLine(PONumber: Code[20]; ItemNo: Code[20]; UOM: Code[10]; Description: Text[100]; OrderQty: Decimal): Text
    var
        PDAStagingPOMgt: Codeunit "GXL PDA-Staging PO Mgt.";
    begin
        ClearLastError();
        PDAStagingPOMgt.AddNewPOLine(PONumber, ItemNo, UOM, Description, OrderQty);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure DeletePOLine(PONumber: Code[20]; LineNo: Integer): Text
    var
        PDAStagingPOMgt: Codeunit "GXL PDA-Staging PO Mgt.";
    begin
        ClearLastError();
        PDAStagingPOMgt.DeletePOLine(PONumber, LineNo);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure GetPurchaseOrder(PONumber: Code[20]; StoreCode: Code[10]; var OutboundXml: XmlPort "GXL PDA-Purchase Lines"): Text
    begin
        //PS-1974 - Added StoreCode
        ClearLastError();
        OutboundXMl.SetXmlFilter(PONumber, StoreCode);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;
    //#end region Purchase

    //#region "Receive PO AR"
    procedure GetDocumentType(Barcode: Text): Text
    var
        PDAPurchRcptInt: Codeunit "GXL PDA-Purchase Receipt Int.";
    begin
        exit(PDAPurchRcptInt.GetDocumentTypeOrNumber(Barcode, 1));
    end;

    procedure CheckASNForPO(PONumber: Code[20])
    var
        PurchHead: Record "Purchase Header";
    begin
        if PurchHead.Get(PurchHead."Document Type"::Order, PONumber) then begin
            if not PurchHead."GXL ASN File Received" then
                if PurchHead."GXL Vendor File Exchange" or PurchHead."GXL EDI Order" then
                    Error('ASN file has not been received in the system!');
        end;
    end;

    procedure GetPOByOrderNumber(PONumber: Code[20]; var OutboundXml: XmlPort "GXL PDA-Purchase Order"): Text
    begin
        ClearLastError();
        OutboundXml.ShowDocument(PONumber);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure GetSupplierUllagedType(VendorNo: Code[20]): Text
    var
        Vendor: Record Vendor;
    begin
        if Vendor.Get(VendorNo) then
            exit(Format(Vendor."GXL Ullaged Supplier"));
        exit(' ');
    end;

    procedure ReceiveAll(PONumber: Code[20]): Text
    var
        PDAPurchRcptInt: Codeunit "GXL PDA-Purchase Receipt Int.";
    begin
        ClearLastError();
        PDAPurchRcptInt.ReceiveAll(PONumber);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure ReceiveAllLines(xmlInput: BigText): Text
    var
        PDAPurchRcptInt: Codeunit "GXL PDA-Purchase Receipt Int.";
    begin
        ClearLastError();
        PDAPurchRcptInt.ReceiveAllLines(xmlInput);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    ///Schema only, publish so that MIM can see the schema
    procedure ReceiveAllLinesXmlInputSchema(xmlInput: XmlPort "GXL PDA-Rec Purchase Lines")
    begin
        Error('It is a schema only');
    end;
    //#end region "Receive PO AR"

    //#region "Receive PO MR"
    procedure GetPurchaseOrderMR(PONumber: Code[20]; StoreCode: Code[10]; var xmlFile: XmlPort "GXL PDA-Purchase Lines"): Text
    begin
        //PS-1974 - Added StoreCode
        ClearLastError();
        xmlFile.SetXmlFilter(PONumber, StoreCode);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure GetPOByOrderNumberMR(PONumber: Code[20]; var OutboundXml: XmlPort "GXL PDA-Purchase Order"): Text
    begin
        ClearLastError();
        OutboundXml.ShowDocument(PONumber);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure UpdateInvoiceMR(PONumber: Code[20]; InvoiceNumber: Code[35]; InvoiceTotal: Decimal; InvoiceDate: Date): Text
    var
        PDAPurchRcptInt: Codeunit "GXL PDA-Purchase Receipt Int.";
    begin
        ClearLastError();
        PDAPurchRcptInt.UpdateInvoiceMR(PONumber, InvoiceNumber, InvoiceTotal, InvoiceDate);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure ReceiveAllLinesMR(xmlInput: BigText): Text
    var
        PDAPurchRcptInt: Codeunit "GXL PDA-Purchase Receipt Int.";
    begin
        ClearLastError();
        PDAPurchRcptInt.ReceiveAllLinesMR(xmlInput);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    ///Schema only, publish so that MIM can see the schema
    procedure ReceiveAllLinesMRXmlInputSchema(xmlInput: XmlPort "GXL PDA-Rec Purchase Lines MR")
    begin
        Error('It is a schema only');
    end;
    //#end region "Receive PO MR"

    //#region "ASN"

    procedure EDIGetASN(Barcode: Code[50]; StoreCode: Code[10]; var ASN: XmlPort "GXL PDA-EDI ASN Export"): Text
    var
        PDAPurchRcptInt: Codeunit "GXL PDA-Purchase Receipt Int.";
    begin
        //PS-1974: Added StoreCode
        ClearLastError();
        ErrorText := PDAPurchRcptInt.EDIGetASN(Barcode, StoreCode, ASN);
        if ErrorText = '' then
            ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;


    procedure ImportASNQuantitesReceived(PDAReceivedASN: BigText): Text
    var
        PDAPurchRcptInt: Codeunit "GXL PDA-Purchase Receipt Int.";
    begin
        ClearLastError();
        PDAPurchRcptInt.ImportASNQuantitesReceived(PDAReceivedASN);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    ///Schema only, publish so that MIM can see the schema
    procedure ImportASNQuantitiesReceivedXmlInputSchema(var xmlInput: XmlPort "GXL PDA-EDI ASN Import")
    begin
        Error('It is a schema only');
    end;
    //#end region "ASN"

    //#region "Stock take"
    procedure GetDivisionList(var xmlFile: xmlport "GXL PDA Division List"): Text
    begin
        ErrorText := '';
        ClearLastError();
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure GetItemCategoryList(DivisionCode: Code[20]; var xmlFile: xmlport "GXL PDA ItemCategory"): Text
    begin
        xmlFile.SetDivisionCode(DivisionCode);
        ErrorText := '';
        ClearLastError();
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure GetProductGroupList(ItemCategoryCode: Code[20]; var xmlFile: xmlport "GXL PDA ProductGroup"): Text
    begin
        xmlFile.SetItemCategory(ItemCategoryCode);
        ErrorText := '';
        ClearLastError();
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure GetOpenStockTake(StoreCode: Code[20]; var OpenStockTakeList: XmlPort "GXL PDA Open StockTake List"): Text
    begin
        OpenStockTakeList.SetPDAStockStore(StoreCode);
        ErrorText := '';
        ClearLastError();
        ErrorText := GetLastErrorText();
        exit(ErrorText);

    end;

    procedure CreateNewStockTake(Store: Code[20]; User: Text[100]; StockTakeDescription: Text[250]; DateOpened: Date; ReasonCode: Code[20]; DivisionCode: Code[20]; ItemCategoryCode: Code[20]; ProductGroupCode: Code[20]; Var Created: Boolean; var StockTakeList: XmlPort "GXL PDA StockTake Lines"): Text
    var
        PDAStocktakeInt: Codeunit "GXL PDA-Stocktake Int.";
    begin
        exit(PDAStocktakeInt.CreateNewStockTake(
            Store, User, StockTakeDescription, DateOpened, ReasonCode, DivisionCode, ItemCategoryCode, ProductGroupCode, Created,
            StockTakeList
        ));
    end;

    procedure ReCallStockTake(StockTakeID: Integer; LineNo: Integer; Store: Code[20]; var StockTakeList: XmlPort "GXL PDA StockTake Lines"): Text
    begin
        ClearLastError();
        StockTakeList.SetPDAStockID(StockTakeID, LineNo);
        ErrorText := '';
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure UpdateStockTakeQuantity(StoreCode: Code[10]; UserID: Text[50]; StockTakeID: Code[20]; xmlInput: BigText): Text
    var
        PDAStocktakeInt: Codeunit "GXL PDA-Stocktake Int.";
    begin
        ClearLastError();
        PDAStocktakeInt.UpdateStockTakeQuantity(
            StoreCode, UserID, StockTakeID, xmlInput);
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure CommitStockTake(StoreCode: Code[10]; StockTakeID: Integer): Text
    var
        PDAStocktakeInt: Codeunit "GXL PDA-Stocktake Int.";
        ReturnMsg: Text;
    begin
        ClearLastError();
        ReturnMsg := PDAStocktakeInt.CommitStockTake(StoreCode, StockTakeID);
        ErrorText := GetLastErrorText();
        if ErrorText <> '' then
            exit(ErrorText);
    end;
    //#end region "Stock take"

}