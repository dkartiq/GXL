codeunit 50359 "GXL SC-Purch. Order Status Mgt"
{
    TableNo = "Purchase Header";

    //TODO: Order Status: perform manual order status change
    trigger OnRun()
    begin
        CASE StoredPurchOptions OF
            StoredPurchOptions::Confirm:
                PerformManualConfirm(Rec);
            StoredPurchOptions::BookToShip:
                PerformManualBookToShip(Rec);
            StoredPurchOptions::Ship:
                PerformManualShip(Rec);
            StoredPurchOptions::Arrive:
                PerformManualArrive(Rec);
            StoredPurchOptions::Close:
                PerformManualClose(Rec);
            StoredPurchOptions::Cancel:
                PerformManualCancel(Rec);
        END;
    end;

    var
        AllowedTolerancePct: Decimal;
        CalculatedDifferencePct: Decimal;
        CheckClosedSuspended: Boolean;
        DeleteHeader: Boolean;
        CancelledFromEDI: Boolean;
        ConfirmedFromEDI: Boolean;
        StoredPurchOptions: Option Confirm,BookToShip,Ship,Arrive,Close,Cancel;
        Text000Msg: Label 'Are you sure you want to cancel the Purchase Order ?';
        Text001Msg: Label 'has to be at least %1 in order to be Confirmed.';
        IsManualConfirm: Boolean;


    [Scope('OnPrem')]
    procedure PerformManualConfirm(var PurchaseHeader: Record "Purchase Header")
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::Confirmed THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" IN [PurchaseHeader."GXL Order Status"::New, PurchaseHeader."GXL Order Status"::Created] THEN
            PurchaseHeader.FIELDERROR("GXL Order Status", STRSUBSTNO(Text001Msg, PurchaseHeader."GXL Order Status"::Placed));
        IsManualConfirm := true; // >> HP2-Sprint2 <<
        ConfirmPurchHeader(PurchaseHeader);
    end;

    procedure PerformManualBookToShip(var PurchaseHeader: Record "Purchase Header")
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;
        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::"Booked to Ship" THEN
            EXIT;

        //TODO: Domestic and Internaltional Order is not in scope, need to be re-visited when it is back in-scope
        //TESTFIELD("GXL Domestic Order", FALSE);
        PurchaseHeader.TESTFIELD("GXL Order Status", PurchaseHeader."GXL Order Status"::Confirmed);
        //TESTFIELD("Expected Shipment Date");
        //TESTFIELD("Into Port Arrival Date");
        //TESTFIELD("Into DC Delivery Date");

        BookToShip(PurchaseHeader);
    end;

    procedure PerformManualShip(var PurchaseHeader: Record "Purchase Header")
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::Shipped THEN
            EXIT;

        //TODO: Domestic and Internaltional Order is not in scope, need to be re-visited when it is back in-scope
        //TESTFIELD("GXL Domestic Order", FALSE);
        PurchaseHeader.TESTFIELD("GXL Order Status", PurchaseHeader."GXL Order Status"::"Booked to Ship");

        ShipPurchHeader(PurchaseHeader);
    end;

    [Scope('OnPrem')]
    procedure PerformManualArrive(var PurchaseHeader: Record "Purchase Header")
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::Arrived THEN
            EXIT;

        //TODO: Domestic and Internaltional Order is not in scope, need to be re-visited when it is back in-scope
        //TESTFIELD("GXL Domestic Order", FALSE);
        PurchaseHeader.TESTFIELD("GXL Order Status", PurchaseHeader."GXL Order Status"::Shipped);

        Arrive(PurchaseHeader);
    end;

    [Scope('OnPrem')]
    procedure PerformManualClose(var PurchaseHeader: Record "Purchase Header")
    begin
    end;

    [Scope('OnPrem')]
    procedure PerformManualCancel(var PurchaseHeader: Record "Purchase Header")
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Cancelled THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Closed THEN
            PurchaseHeader.FIELDERROR("GXL Order Status");

        IF PurchaseHeader."GXL Order Status" IN [PurchaseHeader."GXL Order Status"::Shipped, PurchaseHeader."GXL Order Status"::Arrived] THEN
            PurchaseHeader.FIELDERROR("GXL Order Status");

        IF CONFIRM(Text000Msg, FALSE) THEN
            Cancel(PurchaseHeader, 0);
    end;

    [Scope('OnPrem')]
    procedure Place(var PurchaseHeader: Record "Purchase Header")
    var
        cnWHDataMgmt: Codeunit "GXL WH Data Management";
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" > PurchaseHeader."GXL Order Status"::Placed THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" IN [PurchaseHeader."GXL Order Status"::New, PurchaseHeader."GXL Order Status"::Created] THEN BEGIN
            IF NOT CheckMandatoryInternationalOrderFields(PurchaseHeader, GuiAllowed()) THEN
                EXIT;

            PurchaseHeader.VALIDATE("GXL Order Status", PurchaseHeader."GXL Order Status"::Placed);
            IF (PurchaseHeader."GXL Vendor File Exchange") AND (NOT PurchaseHeader."GXL Vendor File Sent") THEN
                cnWHDataMgmt.VendorFileCheck(PurchaseHeader);

            // PurchaseHeader.VALIDATE("GXL PO Placed Date", TODAY());
            PurchaseHeader.VALIDATE("GXL PO Placed Date", CalcDate('-1D', Today));
            IF PurchaseHeader."GXL Last EDI Document Status" = PurchaseHeader."GXL Last EDI Document Status"::" " THEN BEGIN
                PurchaseHeader.VALIDATE("GXL Vendor File Sent", TRUE);
                PurchaseHeader.VALIDATE("GXL Vendor File Sent Date", TODAY());
            END;

            PurchaseHeader.MODIFY(TRUE);
        END;
    end;

    [Scope('OnPrem')]
    procedure ConfirmPurchHeader(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseHeader2: Record "Purchase Header";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        EmailManagement: Codeunit "GXL Email Management";
        cnWHDataMgmt: Codeunit "GXL WH Data Management";
    begin

        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::Confirmed THEN
            EXIT;

        //TODO: Order created in NAV13, the information is not synched

        IF (NOT PurchaseHeader."GXL International Order")
        THEN
            IF GuiAllowed() THEN
                PurchaseHeader.TESTFIELD("Vendor Order No.")
            ELSE BEGIN
                IF PurchaseHeader."Vendor Order No." = '' THEN
                    EXIT;
            END;

        IF NOT CheckMandatoryInternationalOrderFields(PurchaseHeader, GuiAllowed()) THEN
            EXIT;


        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Created THEN
            Place(PurchaseHeader);

        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Placed THEN BEGIN

            IF NilSupplyPurchaseHeader(PurchaseHeader) THEN BEGIN

                Cancel(PurchaseHeader, 3);

                EmailManagement.SendEmailFromConfirmPurchaseHeader(PurchaseHeader, GuiAllowed(), GuiAllowed(), 0)

            END ELSE BEGIN
                IF PurchaseHeader.Status <> PurchaseHeader.Status::Released THEN
                    ReleasePurchaseDocument.RUN(PurchaseHeader);
                IF (PurchaseHeader."GXL EDI Order" AND ConfirmedFromEDI) OR PurchaseHeader."GXL Vendor File Exchange" THEN
                    PurchaseHeader."GXL Last EDI Document Status" := PurchaseHeader."GXL Last EDI Document Status"::POR;
                // TODO International/Domestic PO - Not needed for now
                IF PurchaseHeader."GXL International Order" THEN
                    PurchaseHeader.VALIDATE("GXL Send to Freight Forwarder", TRUE);
                if IsManualConfirm or (not PurchaseHeader."GXL International Order") then // >> HP2-Sprint2 <<
                    PurchaseHeader.VALIDATE("GXL Order Status", PurchaseHeader."GXL Order Status"::Confirmed);
                PurchaseHeader.Modify(true); // >> 001 <<
                PurchaseHeader2.GET(PurchaseHeader."Document Type", PurchaseHeader."No.");

                IF NOT PurchaseHeader."GXL International Order" THEN
                    IF (PurchaseHeader."GXL 3PL") AND (NOT PurchaseHeader."GXL 3PL File Sent") THEN
                        cnWHDataMgmt."3PLFilePurchaseCheck"(PurchaseHeader2);

                PurchaseHeader2.MODIFY(TRUE);
                Commit();

                IF PurchaseOrderLinesOutsideTolerance(PurchaseHeader) THEN
                    EmailManagement.SendEmailFromConfirmPurchaseHeader(PurchaseHeader, GuiAllowed(), GuiAllowed(), 0);

            END;
        END;
    end;
    // >> HP2-SPRINT2
    [Scope('OnPrem')]
    procedure ConfirmPurchHeaderforEDI(var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseHeader2: Record "Purchase Header";
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
        EmailManagement: Codeunit "GXL Email Management";
        cnWHDataMgmt: Codeunit "GXL WH Data Management";
    begin

        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::Confirmed THEN
            EXIT;

        //TODO: Order created in NAV13, the information is not synched

        IF (NOT PurchaseHeader."GXL International Order")
        THEN
            IF GuiAllowed() THEN
                PurchaseHeader.TESTFIELD("Vendor Order No.")
            ELSE BEGIN
                IF PurchaseHeader."Vendor Order No." = '' THEN
                    EXIT;
            END;

        IF NOT CheckMandatoryInternationalOrderFields(PurchaseHeader, GuiAllowed()) THEN
            EXIT;


        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Created THEN
            Place(PurchaseHeader);

        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Placed THEN BEGIN

            IF NilSupplyPurchaseHeader(PurchaseHeader) THEN BEGIN

                Cancel(PurchaseHeader, 3);

                EmailManagement.SendEmailFromConfirmPurchaseHeader(PurchaseHeader, GuiAllowed(), GuiAllowed(), 0)

            END ELSE BEGIN
                IF PurchaseHeader.Status <> PurchaseHeader.Status::Released THEN
                    ReleasePurchaseDocument.RUN(PurchaseHeader);

                if PurchaseHeader."GXL EDI Vendor Type" <> PurchaseHeader."GXL EDI Vendor Type"::"Point 2 Point" then // >> HP2-SPRINT <<
                    IF (PurchaseHeader."GXL EDI Order" AND ConfirmedFromEDI) OR PurchaseHeader."GXL Vendor File Exchange" THEN
                        PurchaseHeader."GXL Last EDI Document Status" := PurchaseHeader."GXL Last EDI Document Status"::POR;
                // TODO International/Domestic PO - Not needed for now
                IF PurchaseHeader."GXL International Order" THEN
                    PurchaseHeader.VALIDATE("GXL Send to Freight Forwarder", TRUE);
                // >> 001
                // PurchaseHeader.VALIDATE("GXL Order Status", PurchaseHeader."GXL Order Status"::Confirmed);
                PurchaseHeader.Modify(true);
                // << 001 
                PurchaseHeader2.GET(PurchaseHeader."Document Type", PurchaseHeader."No.");

                IF NOT PurchaseHeader."GXL International Order" THEN
                    IF (PurchaseHeader."GXL 3PL") AND (NOT PurchaseHeader."GXL 3PL File Sent") THEN
                        cnWHDataMgmt."3PLFilePurchaseCheck"(PurchaseHeader2);

                PurchaseHeader2.MODIFY(TRUE);
                Commit();
                // >> 001
                // IF PurchaseOrderLinesOutsideTolerance(PurchaseHeader) THEN
                //     EmailManagement.SendEmailFromConfirmPurchaseHeader(PurchaseHeader, GuiAllowed(), GuiAllowed(), 0);
                // << 001
            END;

        END;
    end;
    // << HP2-SPRINT2
    [Scope('OnPrem')]
    procedure BookToShip(var PurchaseHeader: Record "Purchase Header")
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::"Booked to Ship" THEN
            EXIT;
        //TODO: Domestic and Internaltional Order is not in scope, need to be re-visited when it is back in-scope
        /*
        IF "GXL Domestic Order" THEN
            EXIT;

        IF "GXL Order Status" = "GXL Order Status"::Confirmed THEN BEGIN
            IF NOT CheckMandatoryInternationalOrderFields(PurchaseHeader, GuiAllowed()) THEN
                EXIT;

            VALIDATE("GXL Order Status", "GXL Order Status"::"Booked to Ship");
            MODIFY(TRUE);
        END;
        */
    end;

    procedure ShipPurchHeader(var PurchaseHeader: Record "Purchase Header")
    var
        cnWHDataMgmt: Codeunit "GXL WH Data Management";
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::Shipped THEN
            EXIT;

        IF NOT PurchaseHeader."GXL International Order" THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::"Booked to Ship" THEN BEGIN
            //IF NOT CheckMandatoryInternationalOrderFields(PurchaseHeader, GuiAllowed()) THEN
            //    EXIT;

            PurchaseHeader.VALIDATE("GXL Order Status", PurchaseHeader."GXL Order Status"::Shipped);

            IF PurchaseHeader."GXL International Order" THEN
                IF (PurchaseHeader."GXL 3PL") AND (NOT PurchaseHeader."GXL 3PL File Sent") THEN
                    cnWHDataMgmt."3PLFilePurchaseCheck"(PurchaseHeader);

            PurchaseHeader.MODIFY(TRUE);
        END;
    end;

    [Scope('OnPrem')]
    procedure Arrive(var PurchaseHeader: Record "Purchase Header")
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::Arrived THEN
            EXIT;
        //TODO: Domestic and Internaltional Order is not in scope, need to be re-visited when it is back in-scope
        /*
        IF "GXL Domestic Order" THEN
            EXIT;

        IF "GXL Order Status" = "GXL Order Status"::Shipped THEN BEGIN
            IF NOT CheckMandatoryInternationalOrderFields(PurchaseHeader, GuiAllowed()) THEN
                EXIT;

            VALIDATE("GXL Order Status", "GXL Order Status"::Arrived);
            MODIFY(TRUE);
        END;
        */
    end;

    [Scope('OnPrem')]
    procedure Close(var PurchaseHeader: Record "Purchase Header")
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::Closed THEN
            IF NOT CheckClosedSuspended THEN
                EXIT;

        PurchaseHeader.ZeroQuantityReceivedInLines();

        PurchaseHeader.VALIDATE("GXL Order Status", PurchaseHeader."GXL Order Status"::Closed);
        PurchaseHeader.MODIFY(TRUE);

        DeleteHeader := EverythingReceivedInvoiced(PurchaseHeader);

        IF DeleteHeader THEN BEGIN
            Commit();
            PurchaseHeader.DELETE(TRUE);
        END;
    end;

    procedure CloseWithoutModify(var PurchaseHeader: Record "Purchase Header")
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" >= PurchaseHeader."GXL Order Status"::Closed THEN
            IF NOT CheckClosedSuspended THEN
                EXIT;

        PurchaseHeader.VALIDATE("GXL Order Status", PurchaseHeader."GXL Order Status"::Closed);
    end;


    [Scope('OnPrem')]
    procedure Cancel(var PurchaseHeader: Record "Purchase Header"; ReasonCancelled: Option " ",Expired,"Past Due","Nil Supply","Expired and Past Due")
    var
        ReleasePurchaseDocument: Codeunit "Release Purchase Document";
    begin
        IF PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Cancelled THEN
            EXIT;

        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Closed THEN
            EXIT;

        IF PurchaseHeader.Status = PurchaseHeader.Status::Released THEN
            ReleasePurchaseDocument.Reopen(PurchaseHeader);

        IF CancelledFromEDI THEN BEGIN
            PurchaseHeader.VALIDATE("GXL Last EDI Document Status", PurchaseHeader."GXL Last EDI Document Status"::POX);
            PurchaseHeader.VALIDATE("GXL Cancelled via EDI", TRUE);
        END;

        PurchaseHeader.VALIDATE("GXL Order Status", PurchaseHeader."GXL Order Status"::Cancelled);
        PurchaseHeader.ZeroQuantityInLines(TRUE);  // Skip Order Status Check

        IF PurchaseHeader."GXL International Order" THEN
            // Send cancellation only if the confirmed order was sent to freight forwarder
            // TODO International/Domestic PO - Not needed for now
            // IF "GXL Freight Forward. File Sent" THEN
            //     VALIDATE("GXL Send to Freight Forwarder", TRUE);

            PurchaseHeader."GXL Expired Order" := FALSE;

        CASE ReasonCancelled OF
            ReasonCancelled::Expired:
                PurchaseHeader."GXL Expired Order" := TRUE;
            ReasonCancelled::"Expired and Past Due":
                BEGIN
                    PurchaseHeader."GXL Expired Order" := TRUE;
                    //   "Past Due Order" := TRUE;
                END;
        END;

        PurchaseHeader.MODIFY(TRUE);

    end;

    [Scope('OnPrem')]
    procedure NilSupplyPurchaseHeader(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
        IF PurchaseLine.IsEmpty() THEN   //no lines at all
            EXIT(FALSE);

        PurchaseLine.SETFILTER("GXL Confirmed Quantity", '>%1', 0);

        EXIT(PurchaseLine.IsEmpty());
    end;

    local procedure PurchaseOrderLinesOutsideTolerance(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PurchaseLine: Record "Purchase Line";
        IntegrationSetup: Record "GXL Integration Setup";
    begin
        IntegrationSetup.Get();
        AllowedTolerancePct := ROUND(IntegrationSetup."Allowable Tolerance %", 0.01);

        PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
        IF PurchaseLine.FindSet() THEN BEGIN
            REPEAT
                IF PurchaseLine."LSC Original Quantity" <> 0 THEN BEGIN
                    CalculatedDifferencePct := ROUND((PurchaseLine."GXL Confirmed Quantity" - PurchaseLine."LSC Original Quantity") / PurchaseLine."LSC Original Quantity" * 100, 0.01);

                    IF ABS(CalculatedDifferencePct) > ABS(AllowedTolerancePct) THEN
                        EXIT(TRUE);
                END;
            UNTIL PurchaseLine.Next() = 0;
        END ELSE
            EXIT(FALSE);
    end;

    [Scope('OnPrem')]
    procedure SuspendCheckClosed(Suspend: Boolean)
    begin
        CheckClosedSuspended := Suspend;
    end;

    local procedure EverythingReceivedInvoiced(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
        PurchaseLine.SETFILTER("Qty. Rcd. Not Invoiced", '<>%1', 0);
        EXIT(PurchaseLine.IsEmpty());
    end;

    [Scope('OnPrem')]
    procedure ConfirmTransfers(PH: Record "Purchase Header"; TH: Record "Transfer Header")
    var
        cnWHDataMgmt: Codeunit "GXL WH Data Management";
    begin
        cnWHDataMgmt."3PLFileTransferCheck"(TH);
    end;

    [Scope('OnPrem')]
    procedure PerformManualConfirmSTO(var TransferHeader: Record "Transfer Header")
    begin
        IF TransferHeader."GXL Order Status" >= TransferHeader."GXL Order Status"::Confirmed THEN
            EXIT;

        IF TransferHeader."Last Shipment No." = '' THEN
            ERROR('Transfer Shipment has not been posted');

        TransferHeader.VALIDATE("GXL Order Status", TransferHeader."GXL Order Status"::Confirmed);
    end;

    [Scope('OnPrem')]
    procedure SetEDIOptions(CancelledFromEDINew: Boolean; ConfirmedFromEDINew: Boolean)
    begin
        CancelledFromEDI := CancelledFromEDINew;
        ConfirmedFromEDI := ConfirmedFromEDINew;
    end;

    [Scope('OnPrem')]
    procedure SetPurchOptions(PassedPurchOptions: Option Confirm,BookToShip,Ship,Arrive,Close,Cancel)
    begin
        StoredPurchOptions := PassedPurchOptions;
    end;

    [Scope('OnPrem')]
    procedure NilReceivePurchaseHeader(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
        IF PurchaseLine.IsEmpty() THEN   //no lines at all
            EXIT(FALSE);

        PurchaseLine.SETFILTER("Qty. to Receive", '>%1', 0);

        EXIT(PurchaseLine.IsEmpty());
    end;

    [Scope('OnPrem')]
    procedure PlainConfirmPurchaseOrder(var PurchaseHeader: Record "Purchase Header"): Boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        IF PurchaseHeader."GXL Order Status" > PurchaseHeader."GXL Order Status"::Confirmed THEN
            EXIT(false); //false

        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Confirmed THEN
            EXIT(TRUE);

        PurchaseHeader."GXL Order Status" := PurchaseHeader."GXL Order Status"::Confirmed;
        PurchaseHeader.MODIFY();

        PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");

        //PurchaseLine.MODIFYALL("GXL Order Status", PurchaseHeader."GXL Order Status");

        EXIT(TRUE);
    end;


    local procedure CheckMandatoryInternationalOrderFields(PurchaseHeader: Record "Purchase Header"; ShowError: Boolean): Boolean
    var
        ErrorTxt: Text;
        ErrorTxt2: Text;
        Text50000: Label '%1 must be specified in Purchase Order %2.';

        Text50001: Label '%1 cannot be earlier than %2 in Purchase Order %3.';
    begin
        // Note: Have not implemented this. Not sure if we need to - 20200210 SBM
        // exit(true);

        WITH PurchaseHeader DO BEGIN
            IF ("Document Type" <> "Document Type"::Order) OR
               ("GXL Domestic Order") OR (NOT "GXL International Order")
            THEN
                EXIT(TRUE);
            CASE 0D OF
                "GXL Expected Shipment Date":
                    ErrorTxt := FIELDCAPTION("GXL Expected Shipment Date");
                "GXL Into Port Arrival Date":
                    ErrorTxt := FIELDCAPTION("GXL Into Port Arrival Date");
                "GXL Into DC Delivery Date":
                    ErrorTxt := FIELDCAPTION("GXL Into DC Delivery Date");
                "GXL Vendor Shipment Date":
                    ErrorTxt := FIELDCAPTION("GXL Vendor Shipment Date");
                "GXL Port Arrival Date":
                    ErrorTxt := FIELDCAPTION("GXL Port Arrival Date");
                "GXL DC Receipt Date":
                    ErrorTxt := FIELDCAPTION("GXL DC Receipt Date");
            END;
            IF ErrorTxt = '' THEN BEGIN
                CASE '' OF
                    "GXL Departure Port":
                        ErrorTxt := FIELDCAPTION("GXL Departure Port");
                    "GXL Arrival Port":
                        ErrorTxt := FIELDCAPTION("GXL Arrival Port");
                    "GXL Incoterms Code":
                        ErrorTxt := FIELDCAPTION("GXL Incoterms Code");
                    "GXL Import Agent Number":
                        ErrorTxt := FIELDCAPTION("GXL Import Agent Number");
                END;
                //>> MCS1.49 (IPP-23)
                IF ("GXL Order Status" = "GXL Order Status"::"Booked to Ship") AND
                   ("GXL Container No." = '')
                THEN
                    ErrorTxt := FIELDCAPTION("GXL Container No.");
                //<< MCS1.49 (IPP-23)
            END;

            IF ErrorTxt <> '' THEN BEGIN
                IF NOT ShowError THEN
                    EXIT(FALSE)
                ELSE
                    ERROR(Text50000, ErrorTxt, "No.");
            END;

            CASE TRUE OF
                "GXL Expected Shipment Date" > "GXL Into Port Arrival Date":
                    BEGIN
                        ErrorTxt := FIELDCAPTION("GXL Into Port Arrival Date");
                        ErrorTxt2 := FIELDCAPTION("GXL Expected Shipment Date");
                    END;
                "GXL Into Port Arrival Date" > "GXL Into DC Delivery Date":
                    BEGIN
                        ErrorTxt := FIELDCAPTION("GXL Expected Shipment Date");
                        ErrorTxt2 := FIELDCAPTION("GXL Into DC Delivery Date");
                    END;
                "GXL Vendor Shipment Date" > "GXL Port Arrival Date":
                    BEGIN
                        ErrorTxt := FIELDCAPTION("GXL Port Arrival Date");
                        ErrorTxt2 := FIELDCAPTION("GXL Vendor Shipment Date");
                    END;
                "GXL Port Arrival Date" > "GXL DC Receipt Date":
                    BEGIN
                        ErrorTxt := FIELDCAPTION("GXL Vendor Shipment Date");
                        ErrorTxt2 := FIELDCAPTION("GXL DC Receipt Date");
                    END;
            END;
            IF ErrorTxt <> '' THEN BEGIN
                IF NOT ShowError THEN
                    EXIT(FALSE)
                ELSE
                    ERROR(Text50001, ErrorTxt, ErrorTxt2, "No.");
            END;
            EXIT(TRUE);
        END;
        //<< MCS1.49

    end;

}

