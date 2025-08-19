// 001 28.04.2025  STH  LCB-834 https://petbarnjira.atlassian.net/browse/LCB-834
codeunit 50363 "GXL EDI Functions Library"
{
    trigger OnRun()
    begin
    end;

    var
        ItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary;
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        GXLMiscUtilities: Codeunit "GXL Misc. Utilities";
        NeworEditedGTIN: Boolean;
        Text001Msg: Label 'GTIN: %1 for Item No: %2, Cannot be used, it is already in use for Item No: %3';
        Text002Msg: Label 'Response Type Cannot be %1, it must be 4:Accepted, 27:Rejected, 29:AcceptedwithChanges';
        //Text003Msg: Label 'Response Type Cannot send back blank';
        Text004Msg: Label 'Posting Error: The Item Ledger Entry already exists. Identification fields and values: Entry No.=';
    //Text005Msg: Label 'Another user has modified the record for this Item Register after you retrieved it from the database.';
    //Text006Msg: Label 'The operation could not complete because a record in the Item Journal Line table was locked by another user. Please retry the activity.';
    //Text007Msg: Label 'The operation could not complete because a record in the Stockkeeping Unit table was locked by another user. Please retry the activity.';
    //Text008Mag: Label 'The operation could not complete because a record in the Value Entry table was locked by another user. Please retry the activity.';

    [Scope('OnPrem')]
    procedure ValidateGTIN(ItemNo: Code[20]; VendorNo: Code[20]; GTIN: Code[50]): Code[50]
    var
        EDIItemSupplier: Record "GXL EDI Item Supplier";
        EDIItemSupplier2: Record "GXL EDI Item Supplier";
        ExitGTIN: Code[50];
    begin
        ExitGTIN := '';
        NeworEditedGTIN := FALSE;
        IF (ItemNo = '') OR (VendorNo = '') OR (GTIN = '') THEN
            EXIT(ExitGTIN);

        EDIItemSupplier.Reset();
        EDIItemSupplier2.Reset();

        //check for already used gtins
        //EDIItemSupplier.SETRANGE(Supplier,VendorNo);
        EDIItemSupplier.SETRANGE(GTIN, GTIN);
        EDIItemSupplier.SETFILTER(ILC, '<>%1', ItemNo);
        IF EDIItemSupplier.FindFirst() THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, EDIItemSupplier.GTIN, ItemNo, EDIItemSupplier.ILC));
            EDIErrorMgt.ThrowErrorMessage();
        END;


        EDIItemSupplier.Reset();
        EDIItemSupplier.SETRANGE(Supplier, VendorNo);
        EDIItemSupplier.SETRANGE(ILC, ItemNo);
        IF NOT EDIItemSupplier.FindFirst() THEN BEGIN
            EDIItemSupplier2.Init();
            EDIItemSupplier2.VALIDATE(Supplier, VendorNo);
            EDIItemSupplier2.VALIDATE(ILC, ItemNo);
            EDIItemSupplier2.VALIDATE(GTIN, GTIN);
            EDIItemSupplier2.Insert();
            NeworEditedGTIN := TRUE;
        END ELSE
            IF EDIItemSupplier.GTIN <> GTIN THEN BEGIN
                ExitGTIN := EDIItemSupplier.GTIN;
                EDIItemSupplier.VALIDATE(GTIN, GTIN);
                EDIItemSupplier.Modify();
                NeworEditedGTIN := TRUE;
            END;

        EXIT(ExitGTIN);
    end;

    [Scope('OnPrem')]
    procedure InsertItemSupplierGTINBuffer(DocumentType: Option ,PO,POX,POR,ASN,INV; DocumentNo: Code[20]; LineNo: Integer; OldGTIN: Code[50]; NewGTIN: Code[50]; Change: Boolean)
    begin
        ItemSupplierGTINBuffer.Init();
        ItemSupplierGTINBuffer.VALIDATE("Document Type", DocumentType);
        ItemSupplierGTINBuffer.VALIDATE("Document No.", DocumentNo);
        ItemSupplierGTINBuffer.VALIDATE("Line No.", LineNo);
        ItemSupplierGTINBuffer.VALIDATE("Old GTIN", OldGTIN);
        ItemSupplierGTINBuffer.VALIDATE("New GTIN", NewGTIN);
        ItemSupplierGTINBuffer.VALIDATE(Change, Change);
        ItemSupplierGTINBuffer.Insert();
    end;

    [Scope('OnPrem')]
    procedure GTINIsChangedOrNew(): Boolean
    begin
        EXIT(NeworEditedGTIN);
    end;

    [Scope('OnPrem')]
    procedure GetGTINChanges(var PassedItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary)
    begin
        ItemSupplierGTINBuffer.Reset();
        IF ItemSupplierGTINBuffer.FindSet() then
            REPEAT
                PassedItemSupplierGTINBuffer := ItemSupplierGTINBuffer;
                PassedItemSupplierGTINBuffer.Insert();
            UNTIL ItemSupplierGTINBuffer.Next() = 0;
    end;

    [Scope('OnPrem')]
    procedure GetEDIResponseType(ResponseNumber: Integer): Integer
    var
        ResponseType: Option " ",Accepted,Changed,Rejected;
    begin
        CASE ResponseNumber OF
            29:
                EXIT(ResponseType::Accepted);
            27:
                EXIT(ResponseType::Rejected);
            4:
                EXIT(ResponseType::Changed);
            ELSE BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text002Msg, ResponseNumber));
                EDIErrorMgt.ThrowErrorMessage();
            END;
        END;
    end;

    [Scope('OnPrem')]
    procedure GetSPSResponseType(ResponseType: Option " ",Accepted,Changed,Rejected): Integer
    begin
        CASE ResponseType OF
            ResponseType::Accepted:
                EXIT(29);
            ResponseType::Rejected:
                EXIT(27);
            ResponseType::Changed:
                EXIT(4);
        END;
    end;

    [Scope('OnPrem')]
    procedure GetOnHoldErrorCode(): Code[20]
    begin
        EXIT('ON HOLD');
    end;

    [Scope('OnPrem')]
    procedure GetPriceDiscrepancyErrorCode(): Code[20]
    begin
        EXIT('PRICE DISCREPANCY');
    end;

    [Scope('OnPrem')]
    procedure AuditPurchaseOrder(PurchaseOrderNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        RptAuditMgmt: Report "GXL Audit Mgmt";
        AuditNo: Integer;
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, PurchaseOrderNo);
        CLEAR(RptAuditMgmt);
        //RptAuditMgmt.SetEDIOptions (TRUE, PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."No." );
        RptAuditMgmt.SetEDIOptions(TRUE, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No.");
        RptAuditMgmt.FlagNextPurchaseOrderForAudit(AuditNo, PurchaseHeader."Location Code");

        PurchaseHeader."GXL Audit Flag" := FALSE;
        PurchaseHeader.Modify();
    end;

    [Scope('OnPrem')]
    procedure IsAuditAllowed(): Boolean
    var
        AuditExceptionSchedule: Record "GXL Audit Exception Schedule";
        TodayWeekDay: Integer;
    begin
        TodayWeekDay := DATE2DWY(TODAY(), 1) - 1; //Monday = 1; -1 is for NAV option value

        AuditExceptionSchedule.Reset();
        AuditExceptionSchedule.SETRANGE("Week Day", TodayWeekDay);
        AuditExceptionSchedule.SETFILTER("Start Time", '<=%1', TIME());
        AuditExceptionSchedule.SETFILTER("End Time", '>=%1', TIME());
        EXIT(AuditExceptionSchedule.ISEMPTY());
    end;

    [Scope('OnPrem')]
    procedure MoveFile(SourceFileName: Text; TargetFileName: Text; DeleteSourceFile: Boolean)
    var
        // >> Upgrade
        //ServerFileHelper: DotNet File;
        ServerFileHelper: DotNet File1;
    // << Upgrade
    begin
        ServerFileHelper.Copy(SourceFileName, TargetFileName);

        IF DeleteSourceFile THEN
            ServerFileHelper.Delete(SourceFileName);
    end;

    [Scope('OnPrem')]
    procedure GetEDIVendorType(VendorNo: Code[20]): Integer
    var
        Vendor: Record Vendor;
    begin
        Vendor.GET(VendorNo);
        EXIT(Vendor."GXL EDI Vendor Type");
    end;

    [Scope('OnPrem')]
    procedure GetPOEDIVendorType(DocumentNo: Code[20]): Integer
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, DocumentNo) THEN
            EXIT(PurchaseHeader."GXL EDI Vendor Type");
    end;

    [Scope('OnPrem')]
    procedure LinkASNItemLine(ASNLevel1Line: Record "GXL ASN Level 1 Line"; ASNLevel2Line: Record "GXL ASN Level 2 Line"; var ASNLevel3Line: Record "GXL ASN Level 3 Line")
    begin
        //item only has pallet, blank box
        IF (ASNLevel1Line."Level 1 Code" <> '') AND (ASNLevel2Line."Level 2 Code" = '') THEN BEGIN
            ASNLevel3Line."Level 1 Line No." := ASNLevel1Line."Line No.";
            ASNLevel3Line."Loose Item Box Line" := ASNLevel2Line."Line No.";
        END;

        //item doesn't have pallet nor box code, link to box
        IF (ASNLevel1Line."Level 1 Code" = '') AND (ASNLevel2Line."Level 2 Code" = '') THEN
            ASNLevel3Line."Level 2 Line No." := ASNLevel2Line."Line No.";

        //item is in a box, regardless the pallet
        IF ASNLevel2Line."Level 2 Code" <> '' THEN
            ASNLevel3Line."Level 2 Line No." := ASNLevel2Line."Line No.";
    end;

    [Scope('OnPrem')]
    procedure GetDecimalFromText(InputText: Text): Decimal
    var
        DecimalValue: Decimal;
    begin
        IF InputText = '' THEN
            EXIT(0);

        EVALUATE(DecimalValue, InputText);

        EXIT(DecimalValue);
    end;

    [Scope('OnPrem')]
    procedure NegateDateFormula(var DateFormulaToNegate: DateFormula)
    var
        EmptyDateFormula: DateFormula;
    begin
        IF DateFormulaToNegate <> EmptyDateFormula THEN
            EVALUATE(DateFormulaToNegate, '-' + DELCHR(FORMAT(DateFormulaToNegate), '<', '-'));
    end;

    [Scope('OnPrem')]
    procedure UpdatePORNAVEDIDocumentNo(var POResponseHeader: Record "GXL PO Response Header")
    var
        POResponseHeader2: Record "GXL PO Response Header";
    begin
        POResponseHeader2.SETCURRENTKEY("Buy-from Vendor No.", "Original EDI Document No.");
        POResponseHeader2.SETRANGE("Buy-from Vendor No.", POResponseHeader."Buy-from Vendor No.");
        POResponseHeader2.SETRANGE("Original EDI Document No.", POResponseHeader."Original EDI Document No.");
        POResponseHeader2.SETFILTER("NAV EDI Document No.", '<>%1', '');
        IF POResponseHeader2.FINDLAST() THEN
            POResponseHeader."NAV EDI Document No." := INCSTR(POResponseHeader2."NAV EDI Document No.")
        ELSE
            POResponseHeader."NAV EDI Document No." := GXLMiscUtilities.GetFirstDocumentNo(POResponseHeader."Buy-from Vendor No.", POResponseHeader."Original EDI Document No.");
        POResponseHeader.Modify();
    end;

    [Scope('OnPrem')]
    procedure UpdateInvNAVEDIDocumentNo(var InputPOINVHeader: Record "GXL PO INV Header")
    var
        EDIInvHeader: Record "GXL PO INV Header";
    begin
        EDIInvHeader.SETCURRENTKEY("Buy-from Vendor No.", "Original EDI Document No.");
        EDIInvHeader.SETRANGE("Buy-from Vendor No.", InputPOINVHeader."Buy-from Vendor No.");
        EDIInvHeader.SETRANGE("Original EDI Document No.", InputPOINVHeader."Original EDI Document No.");
        EDIInvHeader.SETFILTER("NAV EDI Document No.", '<>%1', '');
        IF EDIInvHeader.FINDLAST() THEN
            InputPOINVHeader."NAV EDI Document No." := INCSTR(EDIInvHeader."NAV EDI Document No.")
        ELSE
            InputPOINVHeader."NAV EDI Document No." := GXLMiscUtilities.GetFirstDocumentNo(InputPOINVHeader."Buy-from Vendor No.", InputPOINVHeader."Original EDI Document No.");

        InputPOINVHeader.Modify();
    end;

    [Scope('OnPrem')]
    procedure UpdateASNNAVEDIDocumentNo(var InputASNHeader: Record "GXL ASN Header")
    var
        ASNHeader: Record "GXL ASN Header";
    begin
        ASNHeader.SETCURRENTKEY("Supplier No.", "Original EDI Document No.");
        ASNHeader.SETRANGE("Supplier No.", InputASNHeader."Supplier No.");
        ASNHeader.SETRANGE("Original EDI Document No.", InputASNHeader."Original EDI Document No.");
        ASNHeader.SETFILTER("NAV EDI Document No.", '<>%1', '');
        IF ASNHeader.FINDLAST() THEN
            InputASNHeader."NAV EDI Document No." := INCSTR(ASNHeader."NAV EDI Document No.")
        ELSE
            InputASNHeader."NAV EDI Document No." := GXLMiscUtilities.GetFirstDocumentNo(InputASNHeader."Supplier No.", InputASNHeader."Original EDI Document No.");
        InputASNHeader.Modify();
    end;

    [Scope('OnPrem')]
    procedure IsNewDocumentNo(NewDocNo: Code[20]; OldDocNo: Code[20]): Boolean
    begin
        EXIT(NewDocNo <> OldDocNo);
    end;

    [Scope('OnPrem')]
    procedure AllLinesHaveSameStatus(DocumentNo: Code[20]; Status: Option): Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        PDAPLReceiveBuffer.SETCURRENTKEY("Document No.");
        PDAPLReceiveBuffer.SETRANGE("Document No.", DocumentNo);
        PDAPLReceiveBuffer.SETFILTER(Status, '<>%1', Status);
        EXIT(PDAPLReceiveBuffer.ISEMPTY());
    end;

    [Scope('OnPrem')]
    procedure AllQuantitiesAreCorrect(DocumentNo: Code[20]) Success: Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        PDAPLReceiveBuffer.SETCURRENTKEY("Document No.");
        PDAPLReceiveBuffer.SETRANGE("Document No.", DocumentNo);
        PDAPLReceiveBuffer.FindSet();
        REPEAT
            Success :=
              (PDAPLReceiveBuffer.QtyOrdered = PDAPLReceiveBuffer.QtyToReceive) AND
              (PDAPLReceiveBuffer.QtyOrdered = PDAPLReceiveBuffer.InvoiceQuantity);
        UNTIL (Success = FALSE) OR (PDAPLReceiveBuffer.Next() = 0);
        EXIT(Success);
    end;

    [Scope('OnPrem')]
    procedure GetPostedPurchaseReceiptNo(DocumentNo: Code[20]; VendorNo: Code[20]) ReceiptNo: Code[20]
    begin
        PurchaseOrderIsReceived(DocumentNo, VendorNo, ReceiptNo);
    end;

    [Scope('OnPrem')]
    procedure GetPostedPurchaseInvoiceNo(DocumentNo: Code[20]; VendorNo: Code[20]) InvoiceNo: Code[20]
    begin
        PurchaseOrderIsInvoiced(DocumentNo, VendorNo, InvoiceNo);
    end;

    [Scope('OnPrem')]
    procedure GetPostedReturnShipmentNo(DocumentNo: Code[20]; VendorNo: Code[20]) ReturnShipmentNo: Code[20]
    begin
        ReturnOrderIsShipped(DocumentNo, VendorNo, ReturnShipmentNo);
    end;

    [Scope('OnPrem')]
    procedure TextMatches(Text1: Text; Text2: Text; CaseSensitive: Boolean): Boolean
    begin
        IF NOT CaseSensitive THEN BEGIN
            Text1 := UPPERCASE(Text1);
            Text2 := UPPERCASE(Text2);
        END;
        EXIT(Text1 = Text2);
    end;

    [Scope('OnPrem')]
    procedure GetPDARecBufferClosedEntryStatus(ManualClearing: Boolean): Integer
    begin
        IF ManualClearing THEN
            EXIT(1)
        ELSE
            EXIT(2);
    end;

    [Scope('OnPrem')]
    procedure PurchaseOrderIsReceived(DocumentNo: Code[20]; VendorNo: Code[20]; var ReceiptNo: Code[20]): Boolean
    var
        PurchaseReceiptHeader: Record "Purch. Rcpt. Header";
    begin
        ReceiptNo := '';
        PurchaseReceiptHeader.SETCURRENTKEY("Order No.");
        PurchaseReceiptHeader.SETRANGE("Order No.", DocumentNo);
        PurchaseReceiptHeader.SETRANGE("Buy-from Vendor No.", VendorNo);
        IF PurchaseReceiptHeader.FindFirst() THEN
            ReceiptNo := PurchaseReceiptHeader."No.";
        EXIT(ReceiptNo <> '');
    end;

    [Scope('OnPrem')]
    procedure PurchaseOrderIsInvoiced(DocumentNo: Code[20]; VendorNo: Code[20]; var InvoiceNo: Code[20]): Boolean
    var
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
    begin
        InvoiceNo := '';
        PurchaseInvoiceHeader.SETCURRENTKEY("Order No.");
        PurchaseInvoiceHeader.SETRANGE("Order No.", DocumentNo);
        PurchaseInvoiceHeader.SETRANGE("Buy-from Vendor No.", VendorNo);
        IF PurchaseInvoiceHeader.FindFirst() THEN
            InvoiceNo := PurchaseInvoiceHeader."No.";
        EXIT(InvoiceNo <> '');
    end;

    [Scope('OnPrem')]
    procedure PurchaseOrderIsCancelled(DocumentNo: Code[20]): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SETRANGE("No.", DocumentNo);
        //TODO: Order Status - EDI Functions library
        PurchaseHeader.SETRANGE("GXL Order Status", PurchaseHeader."GXL Order Status"::Cancelled);
        EXIT(NOT PurchaseHeader.ISEMPTY());
    end;

    [Scope('OnPrem')]
    procedure PDANothingReceived(DocumentNo: Code[20]) NothingReceived: Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        PDAPLReceiveBuffer.SETCURRENTKEY("Document No.");
        PDAPLReceiveBuffer.SETRANGE("Document No.", DocumentNo);
        PDAPLReceiveBuffer.FindSet();
        REPEAT
            NothingReceived := PDAPLReceiveBuffer.QtyToReceive = 0;
        UNTIL (NothingReceived = FALSE) OR (PDAPLReceiveBuffer.Next() = 0);
    end;

    [Scope('OnPrem')]
    procedure CancelPurchaseOrder(DocumentNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        SCPurchaseOrderStatusMgt: Codeunit "GXL SC-Purch. Order Status Mgt";
    begin
        PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, DocumentNo);
        SCPurchaseOrderStatusMgt.Cancel(PurchaseHeader, 0);
    end;

    [Scope('OnPrem')]
    procedure OrderHasClaims(DocumentNo: Code[20]; var ClaimDocumentType: Option; var ClaimDocumentNo: Code[20]): Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        ClaimDocumentNo := '';
        PDAPLReceiveBuffer.SETCURRENTKEY("Document No.");
        PDAPLReceiveBuffer.SETRANGE("Document No.", DocumentNo);
        PDAPLReceiveBuffer.SETFILTER("Claim Quantity", '<>0');
        IF PDAPLReceiveBuffer.FindFirst() THEN BEGIN
            ClaimDocumentType := PDAPLReceiveBuffer."Claim Document Type";
            ClaimDocumentNo := PDAPLReceiveBuffer."Claim Document No.";
        END;
        EXIT(ClaimDocumentNo <> '');
    end;

    [Scope('OnPrem')]
    procedure ReturnOrderIsShipped(DocumentNo: Code[20]; VendorNo: Code[20]; var ReturnShipmentNo: Code[20]): Boolean
    var
        ReturnShipmentHeader: Record "Return Shipment Header";
    begin
        ReturnShipmentNo := '';
        ReturnShipmentHeader.SETCURRENTKEY("Return Order No.");
        ReturnShipmentHeader.SETRANGE("Return Order No.", DocumentNo);
        IF ReturnShipmentHeader.FindFirst() THEN
            ReturnShipmentNo := ReturnShipmentHeader."No.";
        EXIT(ReturnShipmentNo <> '');
    end;

    [Scope('OnPrem')]
    procedure CreditMemoIsPosted(DocumentNo: Code[20]; VendorNo: Code[20]; var PostedCreditMemoNo: Code[20]): Boolean
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
    begin
        PostedCreditMemoNo := '';
        PurchCrMemoHdr.SETCURRENTKEY("Pre-Assigned No.");
        PurchCrMemoHdr.SETRANGE("Pre-Assigned No.", DocumentNo);
        PurchCrMemoHdr.SETRANGE("Buy-from Vendor No.", VendorNo);
        IF PurchCrMemoHdr.FindFirst() THEN
            PostedCreditMemoNo := PurchCrMemoHdr."No.";
        EXIT(PostedCreditMemoNo <> '');
    end;

    [Scope('OnPrem')]
    procedure ResetPDAReceivingBufferError(DocumentNo: Code[20])
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        NonEDIProcessManagement: Codeunit "GXL Non-EDI Process Management";
    begin
        PDAPLReceiveBuffer.SETCURRENTKEY("Document No.");
        PDAPLReceiveBuffer.SETRANGE("Document No.", DocumentNo);

        CLEAR(NonEDIProcessManagement);
        NonEDIProcessManagement.ResetError(PDAPLReceiveBuffer, FALSE);
    end;

    [Scope('OnPrem')]
    procedure IsUntrappedLockingError(ErrorMessage: Text): Boolean
    begin
        IF STRPOS(ErrorMessage, Text004Msg) <> 0 THEN
            EXIT(TRUE);
    end;

    [Scope('OnPrem')]
    procedure ConvertP2PPORResponseType(InputResponseType: Text) ConvertedResponseType: Integer
    begin
        CASE UPPERCASE(InputResponseType) OF
            'ACCEPTED':
                ConvertedResponseType := 29;
            'REJECTED':
                ConvertedResponseType := 27;
            'CHANGED':
                ConvertedResponseType := 4;
            ELSE BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text002Msg, InputResponseType));
                EDIErrorMgt.ThrowErrorMessage();
            END;
        END;
    end;

    [Scope('OnPrem')]
    procedure GetSkuOMQty(Vendor: Record Vendor; SKU: Record "Stockkeeping Unit"): Decimal
    begin
        IF Vendor."GXL EDI Order in Out. Pack UoM" THEN
            EXIT(1)
        ELSE
            EXIT(SKU."GXL Order Multiple (OM)");
    end;

    [Scope('OnPrem')]
    procedure GetSkuOPQty(Vendor: Record Vendor; SKU: Record "Stockkeeping Unit"): Decimal
    begin
        IF Vendor."GXL EDI Order in Out. Pack UoM" THEN
            EXIT(1)
        ELSE
            EXIT(SKU."GXL Order Pack (OP)");
    end;

    [Scope('OnPrem')]
    procedure GetOrderOMQty(Vendor: Record Vendor; PurchLine: Record "Purchase Line"): Decimal
    begin
        IF Vendor."GXL EDI Order in Out. Pack UoM" THEN
            EXIT(PurchLine."GXL Carton-Qty")
        ELSE
            EXIT(PurchLine.Quantity);
    end;

    [Scope('OnPrem')]
    procedure GetOrderOPQty(Vendor: Record Vendor; PurchLine: Record "Purchase Line"): Decimal
    begin
        EXIT(PurchLine."GXL Carton-Qty");
    end;

    [Scope('OnPrem')]
    procedure GetOrderUnitQty(Vendor: Record Vendor; PurchLine: Record "Purchase Line"): Decimal
    begin
        IF Vendor."GXL EDI Order in Out. Pack UoM" THEN
            EXIT(PurchLine."GXL Carton-Qty")
        ELSE
            EXIT(PurchLine.Quantity);
    end;

    [Scope('OnPrem')]
    procedure GetOrderOPItemPrice(Vendor: Record Vendor; PurchLine: Record "Purchase Line"): Decimal
    var
        GLSetup: Record "General Ledger Setup";
        SKU: Record "Stockkeeping Unit";
        Location: Record Location;
    begin
        IF (NOT Vendor."GXL EDI Order in Out. Pack UoM") OR
           (PurchLine.Type <> PurchLine.Type::Item) OR
           (NOT SKU.GET(PurchLine."Location Code", PurchLine."No."))
        THEN
            EXIT(PurchLine."Direct Unit Cost");
        // >> LCB-203   
        if Vendor.OverrideOPOMCalculation(Vendor."No.") then
            exit;
        // << LCB-203
        GLSetup.GET();
        Location.Get(SKU."Location Code");
        Location.CalcFields("GXL Location Type");
        case Location."GXL Location Type" of
            Location."GXL Location Type"::"3":       // DC
                EXIT(ROUND(PurchLine."Direct Unit Cost" * SKU."GXL Order Pack (OP)", GLSetup."Unit-Amount Rounding Precision"));

            Location."GXL Location Type"::"6":  // Store
                EXIT(ROUND(PurchLine."Direct Unit Cost" * SKU."GXL Order Multiple (OM)", GLSetup."Unit-Amount Rounding Precision"));
            ELSE
                EXIT(PurchLine."Direct Unit Cost");
        end;
    end;


    [Scope('OnPrem')]
    procedure ConvertQty_ShippingUnitToOrderUnit_VendorRec(Vendor: Record Vendor; SKU: Record "Stockkeeping Unit"; VendorPackQty: Decimal): Decimal
    var
        GLSetup: Record "General Ledger Setup";
        Location: Record Location;
    begin
        IF NOT Vendor."GXL EDI Order in Out. Pack UoM" THEN
            EXIT(VendorPackQty);
        // >> LCB-203 
        if Vendor.OverrideOPOMCalculation(Vendor."No.") then
            exit(VendorPackQty);
        // << LCB-203 
        GLSetup.GET();
        Location.Get(SKU."Location Code");
        Location.CalcFields("GXL Location Type");
        case Location."GXL Location Type" of
            Location."GXL Location Type"::"3":       // DC
                EXIT(ROUND(VendorPackQty * SKU."GXL Order Pack (OP)", 0.01, '>'));

            Location."GXL Location Type"::"6":  // Store
                EXIT(ROUND(VendorPackQty * SKU."GXL Order Multiple (OM)", 0.01, '>'));
            ELSE
                EXIT(VendorPackQty);
        end;
    end;

    [Scope('OnPrem')]
    procedure ConvertPrice_ShippingUnitToOrderUnit_VendorRec(Vendor: Record Vendor; SKU: Record "Stockkeeping Unit"; ItemPrice: Decimal): Decimal
    var
        GLSetup: Record "General Ledger Setup";
        Location: Record Location;
    begin
        IF NOT Vendor."GXL EDI Order in Out. Pack UoM" THEN
            EXIT(ItemPrice);
        // >> LCB-203 
        if Vendor.OverrideOPOMCalculation(Vendor."No.") then
            exit(ItemPrice);
        // << LCB-203 

        GLSetup.GET();
        Location.Get(SKU."Location Code");
        Location.CalcFields("GXL Location Type");
        case Location."GXL Location Type" of
            Location."GXL Location Type"::"3":       // DC
                EXIT(ROUND(ItemPrice / SKU."GXL Order Pack (OP)", GLSetup."Unit-Amount Rounding Precision"));

            Location."GXL Location Type"::"6":  // Store
                EXIT(ROUND(ItemPrice / SKU."GXL Order Multiple (OM)", GLSetup."Unit-Amount Rounding Precision"));
            ELSE
                EXIT(ItemPrice);
        end;
    end;

    [Scope('OnPrem')]
    // >> LCB-203 
    //procedure ConvertQty_ShippingUnitToOrderUnit_VendorOPFlag(VendorShipsInOP: Boolean; SKU: Record "Stockkeeping Unit"; VendorPackQty: Decimal): Decimal
    procedure ConvertQty_ShippingUnitToOrderUnit_VendorOPFlag(VendorShipsInOP: Boolean; SKU: Record "Stockkeeping Unit"; VendorPackQty: Decimal; VendorP: Code[20]): Decimal
    // << LCB-203 
    var
        GLSetup: Record "General Ledger Setup";
        Location: Record Location;
        VendorL: Record Vendor; // >> LCB-203 << 
    begin
        IF NOT VendorShipsInOP THEN
            EXIT(VendorPackQty);

        if SKU."GXL Parent Item" <> '' then // >> 001 <<
            // >> LCB-203 
            if VendorL.OverrideOPOMCalculation(VendorP) then
                exit;
        // << LCB-203  

        GLSetup.GET();
        Location.Get(SKU."Location Code");
        Location.CalcFields("GXL Location Type");
        case Location."GXL Location Type" of
            Location."GXL Location Type"::"3":       // DC
                EXIT(ROUND(VendorPackQty * SKU."GXL Order Pack (OP)", 0.01, '>'));

            Location."GXL Location Type"::"6":  // Store
                EXIT(ROUND(VendorPackQty * SKU."GXL Order Multiple (OM)", 0.01, '>'));
            ELSE
                EXIT(VendorPackQty);
        end;
    end;

    [Scope('OnPrem')]
    procedure ConvertPrice_ShippingUnitToOrderUnit_VendorOPFlag(VendorShipsInOP: Boolean; SKU: Record "Stockkeeping Unit"; ItemPrice: Decimal): Decimal
    var
        GLSetup: Record "General Ledger Setup";
        Location: Record Location;
    begin
        IF NOT VendorShipsInOP THEN
            EXIT(ItemPrice);

        GLSetup.GET();
        Location.Get(SKU."Location Code");
        Location.CalcFields("GXL Location Type");
        case Location."GXL Location Type" of
            Location."GXL Location Type"::"3":       // DC
                EXIT(ROUND(ItemPrice / SKU."GXL Order Pack (OP)", GLSetup."Unit-Amount Rounding Precision"));

            Location."GXL Location Type"::"6": // Store
                EXIT(ROUND(ItemPrice / SKU."GXL Order Multiple (OM)", GLSetup."Unit-Amount Rounding Precision"));
            ELSE
                EXIT(ItemPrice);
        end;
    end;

}

