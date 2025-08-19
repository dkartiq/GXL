codeunit 50387 "GXL Process Intl. Ship. Advice"
{
    TableNo = "GXL Intl. Shipping Advice Head";

    //TODO: Domestic and Internaltional Order is not in scope, need to be re-visited when it is back in-scope

    trigger OnRun()
    begin
        ShipAdviceHeader := Rec;

        // Check order status
        ValidateShippingMilestoneSequence();

        // Process Shipping Advice
        UpdatePOHeaderFromShipAdvice();

        //TODO: temporarily insert as shipment is imported from NAV
        //ERP-NAV Master Data Management +
        if ShipAdviceHeader."EDI File Log Entry No." = 0 then
            ShipAdviceHeader.AddEDIFileLog();
        //ERP-NAV Master Data Management -

        // Update Shipping Advice Status
        ShipAdviceHeader.VALIDATE(Status, ShipAdviceHeader.Status::Processed);
        ShipAdviceHeader.MODIFY();

        Rec := ShipAdviceHeader;
    end;

    var
        ShipAdviceHeader: Record "GXL Intl. Shipping Advice Head";
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        Text000Txt: Label 'Order Status must not be %1 on Purchase Order No. %2 when Shipping Status is %3.';
        Text001Txt: Label 'Purchase Order No. %1 does not exist.';

    [Scope('OnPrem')]
    procedure ValidateShippingMilestoneSequence()
    var
        PurchHeader: Record "Purchase Header";
    begin
        //TODO: Order Status - Validate International ASN, order status must be consistent with ASN status
        PurchHeader.RESET();
        IF PurchHeader.GET(PurchHeader."Document Type"::Order, ShipAdviceHeader."Order No.") THEN BEGIN
            CASE ShipAdviceHeader."Order Shipping Status" OF
                ShipAdviceHeader."Order Shipping Status"::"Booked to Ship":
                    IF (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::Confirmed) AND
                       (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::"Booked to Ship")
                    THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, PurchHeader."GXL Order Status", PurchHeader."No.", ShipAdviceHeader."Order Shipping Status"));
                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                ShipAdviceHeader."Order Shipping Status"::"At CFS":
                    IF PurchHeader."GXL Order Status" < PurchHeader."GXL Order Status"::Confirmed THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, PurchHeader."GXL Order Status", PurchHeader."No.", ShipAdviceHeader."Order Shipping Status"));
                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                ShipAdviceHeader."Order Shipping Status"::Shipped:
                    IF (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::"Booked to Ship") AND
                       (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::Shipped)
                    THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, PurchHeader."GXL Order Status", PurchHeader."No.", ShipAdviceHeader."Order Shipping Status"));
                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                ShipAdviceHeader."Order Shipping Status"::Arrived:
                    IF (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::Shipped) AND
                       (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::Arrived)
                    THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, PurchHeader."GXL Order Status", PurchHeader."No.", ShipAdviceHeader."Order Shipping Status"));
                        EDIErrorMgt.ThrowErrorMessage();
                    END;
            END;
        END ELSE BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Txt, ShipAdviceHeader."Order No."));
            EDIErrorMgt.ThrowErrorMessage();
        END;
    end;

    [Scope('OnPrem')]
    procedure UpdatePOHeaderFromShipAdvice()
    var
        PurchLine: Record "Purchase Line";
        PurchHeader: Record "Purchase Header";
        cnWHDataMgmt: Codeunit "GXL WH Data Management";
    begin
        // Update Purchase Header

        IF PurchHeader.GET(PurchHeader."Document Type"::Order, ShipAdviceHeader."Order No.") THEN BEGIN
            CASE ShipAdviceHeader."Order Shipping Status" OF
                ShipAdviceHeader."Order Shipping Status"::"Booked to Ship":
                    BEGIN
                        IF ShipAdviceHeader."Vendor Order No." <> '' THEN
                            PurchHeader."Vendor Order No." := ShipAdviceHeader."Vendor Order No.";
                        // TODO International/Domestic PO - Not needed for now
                        // >> HP2-Sprint2
                        IF ShipAdviceHeader."Delivery Mode" <> 0 THEN
                            PurchHeader."GXL Freight Delivery Mode" := ShipAdviceHeader."Delivery Mode";
                        // << HP2-Sprint2
                        IF ShipAdviceHeader."Shipment Method Code" <> '' THEN
                            PurchHeader."Shipment Method Code" := ShipAdviceHeader."Shipment Method Code";
                        IF ShipAdviceHeader."Vendor Shipment No." <> '' THEN
                            PurchHeader.VALIDATE("Vendor Shipment No.", ShipAdviceHeader."Vendor Shipment No.");
                        //ERP-NAV Master Data Management +
                        IF ShipAdviceHeader."Departure Port" <> '' THEN
                            PurchHeader.VALIDATE("GXL Departure Port", ShipAdviceHeader."Departure Port");
                        IF ShipAdviceHeader."Vessel Name" <> '' THEN
                            PurchHeader.VALIDATE("GXL Container Vessel", ShipAdviceHeader."Vessel Name");
                        IF ShipAdviceHeader."Container Carrier" <> '' THEN
                            PurchHeader.VALIDATE("GXL Container Carrier", ShipAdviceHeader."Container Carrier");
                        IF ShipAdviceHeader."Container Type" <> 0 THEN
                            PurchHeader.VALIDATE("GXL Container Type", ShipAdviceHeader."Container Type");
                        IF ShipAdviceHeader."Container No." <> '' THEN
                            PurchHeader.VALIDATE("GXL Container No.", ShipAdviceHeader."Container No.");
                        IF ShipAdviceHeader."Shipping Date" <> 0D THEN
                            PurchHeader.VALIDATE("GXL Vendor Shipment Date", ShipAdviceHeader."Shipping Date");
                        IF ShipAdviceHeader."Arrival Date" <> 0D THEN
                            PurchHeader.VALIDATE("GXL Port Arrival Date", ShipAdviceHeader."Arrival Date");
                        //ERP-NAV Master Data Management -
                        IF PurchHeader."GXL Order Status" < PurchHeader."GXL Order Status"::"Booked to Ship" THEN
                            PurchHeader.VALIDATE("GXL Order Status", PurchHeader."GXL Order Status"::"Booked to Ship");
                        PurchHeader.MODIFY(TRUE);
                    END;
                ShipAdviceHeader."Order Shipping Status"::"At CFS":
                    BEGIN
                        IF ShipAdviceHeader."Vendor Order No." <> '' THEN
                            PurchHeader."Vendor Order No." := ShipAdviceHeader."Vendor Order No.";
                        // TODO International/Domestic PO - Not needed for now
                        // >> HP2-Sprint2
                        IF ShipAdviceHeader."CFS Receipt Date" <> 0D THEN
                            PurchHeader."GXL Received at Origin Date" := ShipAdviceHeader."CFS Receipt Date";
                        // << HP2-Sprint2
                        PurchHeader.MODIFY(TRUE);
                    END;
                ShipAdviceHeader."Order Shipping Status"::Shipped:
                    BEGIN
                        IF ShipAdviceHeader."Vendor Order No." <> '' THEN
                            PurchHeader."Vendor Order No." := ShipAdviceHeader."Vendor Order No.";
                        // TODO International/Domestic PO - Not needed for now
                        // >> HP2-Sprint2
                        IF ShipAdviceHeader."Delivery Mode" <> 0 THEN
                            PurchHeader."GXL Freight Delivery Mode" := ShipAdviceHeader."Delivery Mode";
                        // << HP2-Sprint2
                        IF ShipAdviceHeader."Shipment Method Code" <> '' THEN
                            PurchHeader."Shipment Method Code" := ShipAdviceHeader."Shipment Method Code";
                        IF ShipAdviceHeader."Vendor Shipment No." <> '' THEN
                            PurchHeader.VALIDATE("Vendor Shipment No.", ShipAdviceHeader."Vendor Shipment No.");
                        //ERP-NAV Master Data Management +
                        IF ShipAdviceHeader."Departure Port" <> '' THEN
                            PurchHeader.VALIDATE("GXL Departure Port", ShipAdviceHeader."Departure Port");
                        IF ShipAdviceHeader."Vessel Name" <> '' THEN
                            PurchHeader.VALIDATE("GXL Container Vessel", ShipAdviceHeader."Vessel Name");
                        IF ShipAdviceHeader."Container Carrier" <> '' THEN
                            PurchHeader.VALIDATE("GXL Container Carrier", ShipAdviceHeader."Container Carrier");
                        IF ShipAdviceHeader."Container Type" <> 0 THEN
                            PurchHeader.VALIDATE("GXL Container Type", ShipAdviceHeader."Container Type");
                        IF ShipAdviceHeader."Container No." <> '' THEN
                            PurchHeader.VALIDATE("GXL Container No.", ShipAdviceHeader."Container No.");
                        IF ShipAdviceHeader."Shipping Date" <> 0D THEN
                            PurchHeader.VALIDATE("GXL Vendor Shipment Date", ShipAdviceHeader."Shipping Date");
                        IF ShipAdviceHeader."Arrival Date" <> 0D THEN
                            PurchHeader.VALIDATE("GXL Port Arrival Date", ShipAdviceHeader."Arrival Date");
                        //ERP-NAV Master Data Management -
                        IF PurchHeader."GXL Order Status" < PurchHeader."GXL Order Status"::Shipped THEN
                            PurchHeader.VALIDATE("GXL Order Status", PurchHeader."GXL Order Status"::Shipped);
                        PurchHeader.MODIFY(TRUE);

                        // Send International Order ASN to 3PL Warehouse

                        IF PurchHeader."GXL International Order" THEN
                            IF (PurchHeader."GXL 3PL") AND
                               (NOT PurchHeader."GXL 3PL File Sent")
                            THEN
                                cnWHDataMgmt."3PLFilePurchaseCheck"(PurchHeader);
                    END;
                ShipAdviceHeader."Order Shipping Status"::Arrived:
                    BEGIN
                        IF ShipAdviceHeader."Vendor Order No." <> '' THEN
                            PurchHeader."Vendor Order No." := ShipAdviceHeader."Vendor Order No.";
                        //ERP-NAV Master Data Management +
                        IF ShipAdviceHeader."Arrival Date" <> 0D THEN
                            PurchHeader.VALIDATE("GXL Port Arrival Date", ShipAdviceHeader."Arrival Date");
                        //ERP-NAV Master Data Management -
                        IF PurchHeader."GXL Order Status" < PurchHeader."GXL Order Status"::Arrived THEN
                            PurchHeader.VALIDATE("GXL Order Status", PurchHeader."GXL Order Status"::Arrived);
                        PurchHeader.MODIFY(TRUE);
                    END;
            END;
        END;

        // Update Purchase Lines
        IF ShipAdviceHeader."Order Shipping Status" IN
          [ShipAdviceHeader."Order Shipping Status"::"Booked to Ship",
           ShipAdviceHeader."Order Shipping Status"::Shipped]
        THEN BEGIN
            PurchLine.RESET();
            PurchLine.SETRANGE("Document Type", PurchLine."Document Type"::Order);
            PurchLine.SETRANGE("Document No.", PurchHeader."No.");
            PurchLine.SETRANGE(Type, PurchLine.Type::Item);
            PurchLine.SETFILTER("Qty. to Receive", '<>%1', 0);
            IF PurchLine.FINDSET() THEN
                REPEAT
                    UpdatePOLineFromShipAdvice(PurchLine);
                UNTIL PurchLine.NEXT() = 0;
        END;
    end;

    [Scope('OnPrem')]
    procedure UpdatePOLineFromShipAdvice(var PurchLine: Record "Purchase Line")
    var
        ShipAdviceLine: Record "GXL Intl. Shipping Advice Line";
    begin
        ShipAdviceLine.RESET();
        ShipAdviceLine.SETRANGE("Shipping Advice No.", ShipAdviceHeader."No.");
        ShipAdviceLine.SETRANGE("Order Line No.", PurchLine."Line No.");
        IF ShipAdviceLine.FINDFIRST() THEN BEGIN
            IF ShipAdviceLine."Quantity Shipped" <> PurchLine."Qty. to Receive" THEN BEGIN
                PurchLine."GXL ASN Rec. Variance" := PurchLine."Qty. to Receive" - ShipAdviceLine."Quantity Shipped";
                PurchLine.VALIDATE("Qty. to Receive", ShipAdviceLine."Quantity Shipped");
                PurchLine.MODIFY(TRUE);
            END;
        END ELSE BEGIN
            // Item not shipped
            PurchLine."GXL ASN Rec. Variance" := PurchLine."Qty. to Receive";
            PurchLine.VALIDATE("Qty. to Receive", 0);
            PurchLine.MODIFY(TRUE);
        END;
    end;
}

