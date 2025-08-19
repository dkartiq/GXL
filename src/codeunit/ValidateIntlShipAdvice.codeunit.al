codeunit 50386 "GXL Validate Intl. Ship Advice"
{
    TableNo = "GXL Intl. Shipping Advice Head";

    //TODO: Domestic and Internaltional Order is not in scope, need to be re-visited when it is back in-scope

    trigger OnRun()
    var
    begin
        ShipAdviceHeader := Rec;

        ValidateShipAdviceHeader();

        IF ShipAdviceHeader."Order Shipping Status" IN
           [ShipAdviceHeader."Order Shipping Status"::"Booked to Ship", ShipAdviceHeader."Order Shipping Status"::Shipped]
        THEN
            ValidateShipAdviceLines();

        //TODO: temporarily insert as shipment is imported from NAV
        //ERP-NAV Master Data Management +
        if ShipAdviceHeader."EDI File Log Entry No." = 0 then
            ShipAdviceHeader.AddEDIFileLog();
        //ERP-NAV Master Data Management -

        ShipAdviceHeader.VALIDATE(Status, ShipAdviceHeader.Status::Validated);
        ShipAdviceHeader.MODIFY();

        Rec := ShipAdviceHeader;
    end;

    var
        ShipAdviceHeader: Record "GXL Intl. Shipping Advice Head";
        PurchHeader: Record "Purchase Header";
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        Text000Txt: Label '%1 must have a value when %2 is %3.';
        Text001Txt: Label 'Shipping Advice must have Item lines when %1 is %2.';
        Text002Txt: Label '%1 must have a value.';
        Text008Txt: Label '%1 cannot be less than %2 on Shiipping Advice Line %3.';
        Text009Txt: Label 'Purchase Order %1 does not exist.';
        Text010Txt: Label '%1 on Shipping Advice must be the same as %2 on Purchase Order. Shipping Advice value: %3, Purchase Order value: %4.';
        //Text011: Label '%1 on %2 must match the counted value. Shipping Advice value: %3. Counted value: %4.';
        //Text012: Label '%1 on Shipping Advice line must be less than or equal to %2 on Purchase Line. ASN Item Line value: %3. Purchase Line value: %4.';
        //Text013: Label 'Item %1 does not exist in Purchase Order %2.';
        //Text014: Label 'Purchase Order %1 has been cancelled.';
        //Text015: Label 'Item %1 is a duplicate.';
        Text018Txt: Label 'Purchase Order Line %1 does not exist.';
        Text019Txt: Label '%1 must have a value on Shipping Advice Line %2.';
        //Text020: Label 'Shipping Advice cannot be accepted for Purchase Order %3 where %1 = %2.';
        Text021Txt: Label '%1 cannot be greater than %2 on Shipping Advice Line %3.';
    //Text022: Label '%1 cannot be earlier than %2 in Purchase Order %3.';

    local procedure ValidateShipAdviceHeader()
    begin
        IF ShipAdviceHeader."Order No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text002Txt, ShipAdviceHeader.FIELDCAPTION("Order No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END ELSE
            IF NOT PurchHeader.GET(PurchHeader."Document Type"::Order, ShipAdviceHeader."Order No.") THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text009Txt, ShipAdviceHeader."Order No."));
                EDIErrorMgt.ThrowErrorMessage();
            END ELSE BEGIN
                ShipAdviceHeader."Freight Forwarding Agent Code" := PurchHeader."GXL Freight Forwarder Code";
            END;

        IF ShipAdviceHeader."Order Shipping Status" = 0 THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text002Txt, ShipAdviceHeader.FIELDCAPTION("Order Shipping Status")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF ShipAdviceHeader."Buy-from Vendor No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text002Txt, ShipAdviceHeader.FIELDCAPTION("Buy-from Vendor No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END ELSE
            IF ShipAdviceHeader."Buy-from Vendor No." <> PurchHeader."Buy-from Vendor No." THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text010Txt,
                  ShipAdviceHeader.FIELDCAPTION("Buy-from Vendor No."),
                  PurchHeader.FIELDCAPTION("Buy-from Vendor No."),
                  ShipAdviceHeader."Buy-from Vendor No.",
                  PurchHeader."Buy-from Vendor No."));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        IF ShipAdviceHeader."Order Shipping Status" = ShipAdviceHeader."Order Shipping Status"::"At CFS" THEN
            IF ShipAdviceHeader."CFS Receipt Date" = 0D THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ShipAdviceHeader.FIELDCAPTION("CFS Receipt Date"),
                  ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        IF ShipAdviceHeader."Order Shipping Status" IN
          [ShipAdviceHeader."Order Shipping Status"::"Booked to Ship",
           ShipAdviceHeader."Order Shipping Status"::Shipped]
        THEN
            IF ShipAdviceHeader."Shipping Date" = 0D THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ShipAdviceHeader.FIELDCAPTION("Shipping Date"),
                  ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        IF ShipAdviceHeader."Order Shipping Status" IN
          [ShipAdviceHeader."Order Shipping Status"::"Booked to Ship",
           ShipAdviceHeader."Order Shipping Status"::Shipped,
           ShipAdviceHeader."Order Shipping Status"::Arrived]
        THEN
            IF ShipAdviceHeader."Arrival Date" = 0D THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ShipAdviceHeader.FIELDCAPTION("Shipping Date"),
                  ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        IF (ShipAdviceHeader."Shipping Date" <> 0D) AND
           (ShipAdviceHeader."Arrival Date" <> 0D) AND
           (ShipAdviceHeader."Shipping Date" > ShipAdviceHeader."Arrival Date")
        THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text021Txt, ShipAdviceHeader.FIELDCAPTION("Arrival Date"), ShipAdviceHeader.FIELDCAPTION("Shipping Date"), ShipAdviceHeader."No."));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF ShipAdviceHeader."Order Shipping Status" = ShipAdviceHeader."Order Shipping Status"::Shipped THEN BEGIN
            IF ShipAdviceHeader."Vendor Shipment No." = '' THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ShipAdviceHeader.FIELDCAPTION("Vendor Shipment No."),
                  ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF ShipAdviceHeader."Shipment Method Code" = '' THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ShipAdviceHeader.FIELDCAPTION("Shipment Method Code"),
                  ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF ShipAdviceHeader."Departure Port" = '' THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ShipAdviceHeader.FIELDCAPTION("Departure Port"),
                  ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
                EDIErrorMgt.ThrowErrorMessage();
            END ELSE
                //ERP-NAV Master Data Management +
                IF ShipAdviceHeader."Departure Port" <> PurchHeader."GXL Departure Port" THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text010Txt,
                      ShipAdviceHeader.FIELDCAPTION("Departure Port"),
                      PurchHeader.FIELDCAPTION("GXL Departure Port"),
                      ShipAdviceHeader."Departure Port",
                      PurchHeader."GXL Departure Port"));
                    EDIErrorMgt.ThrowErrorMessage();
                END;
            //ERP-NAV Master Data Management -

            IF ShipAdviceHeader."Vessel Name" = '' THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ShipAdviceHeader.FIELDCAPTION("Vessel Name"),
                  ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF ShipAdviceHeader."Container Carrier" = '' THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ShipAdviceHeader.FIELDCAPTION("Container Carrier"),
                  ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF ShipAdviceHeader."Container Type" = 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ShipAdviceHeader.FIELDCAPTION("Container Type"),
                  ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF ShipAdviceHeader."Container No." = '' THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ShipAdviceHeader.FIELDCAPTION("Container No."),
                  ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF ShipAdviceHeader."Delivery Mode" = 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ShipAdviceHeader.FIELDCAPTION("Delivery Mode"),
                  ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
                EDIErrorMgt.ThrowErrorMessage();
            END;
        END;
    end;

    local procedure ValidateShipAdviceLines()
    var
        ShipAdviceLine: Record "GXL Intl. Shipping Advice Line";
        PurchLine: Record "Purchase Line";
    begin
        ShipAdviceLine.SETRANGE("Shipping Advice No.", ShipAdviceHeader."No.");
        IF ShipAdviceLine.FINDSET() THEN BEGIN
            REPEAT
                IF ShipAdviceLine."Item No." = '' THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(Text019Txt, ShipAdviceLine.FIELDCAPTION("Item No."), ShipAdviceLine."Line No."));
                    EDIErrorMgt.ThrowErrorMessage();
                END;

                IF ShipAdviceLine."Unit of Measure Code" = '' THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(Text019Txt, ShipAdviceLine.FIELDCAPTION("Unit of Measure Code"), ShipAdviceLine."Line No."));
                    EDIErrorMgt.ThrowErrorMessage();
                END;

                IF ShipAdviceLine."Quantity Shipped" < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(Text008Txt, ShipAdviceLine.FIELDCAPTION("Quantity Shipped"), 0, ShipAdviceLine."Line No."));
                    EDIErrorMgt.ThrowErrorMessage();
                END;

                IF ShipAdviceLine."Carton-Quantity Shipped" < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(Text008Txt, ShipAdviceLine.FIELDCAPTION("Carton-Quantity Shipped"), 0, ShipAdviceLine."Line No."));
                    EDIErrorMgt.ThrowErrorMessage();
                END;

                IF NOT PurchLine.GET(PurchLine."Document Type"::Order, ShipAdviceHeader."Order No.", ShipAdviceLine."Order Line No.") THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(Text018Txt, ShipAdviceLine."Order Line No."));
                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    IF ShipAdviceLine."Quantity Shipped" > PurchLine.Quantity THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(Text008Txt, ShipAdviceLine.FIELDCAPTION("Quantity Shipped"), PurchLine.Quantity, ShipAdviceLine."Line No."));
                        EDIErrorMgt.ThrowErrorMessage();
                    END;

                    IF ShipAdviceLine."Carton-Quantity Shipped" > PurchLine."GXL Carton-Qty" THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(Text008Txt, ShipAdviceLine.FIELDCAPTION("Carton-Quantity Shipped"), PurchLine."GXL Carton-Qty", ShipAdviceLine."Line No."));
                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                END;
            UNTIL ShipAdviceLine.NEXT() = 0;
        END ELSE BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Txt, ShipAdviceHeader.FIELDCAPTION("Order Shipping Status"), ShipAdviceHeader."Order Shipping Status"));
            EDIErrorMgt.ThrowErrorMessage();
        END;
    end;
}

