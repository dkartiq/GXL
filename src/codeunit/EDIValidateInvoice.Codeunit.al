// 001 25.11.2024 KDU https://petbarnjira.atlassian.net/browse/LCB-507
codeunit 50375 "GXL EDI-Validate Invoice"
{
    TableNo = "GXL PO INV Header";

    trigger OnRun()
    begin
        //ERP-247 >>
        IntegrationSetup.Get();
        IntegrationSetup.TestField("Amount Rounding Precision");
        //ERP-247 <<

        POINVHeader := Rec;

        //validate INV mandatory fields and Accept | Reject Invoice
        // >> LCB-505
        ManualAcceptanceAllowed := false;
        ManualAcceptanceErrorMsg := '';
        // << LCB-505
        ValidateINVHeader();
        ValidateINVLines();

        //check discrepancy
        IF ManualAcceptanceAllowed THEN BEGIN
            EDIErrorMgt.SetErrorMessage(EDIFunctions.GetPriceDiscrepancyErrorCode() + ManualAcceptanceErrorMsg);
            EDIErrorMgt.ThrowErrorMessage();
        END;

        //update purchase header
        PurchaseHeader."GXL Last EDI Document Status" := PurchaseHeader."GXL Last EDI Document Status"::INV;
        PurchaseHeader.Modify();

        //update PO INV Header
        POINVHeader.Status := POINVHeader.Status::Validated;
        POINVHeader.Modify();

        Rec := POINVHeader;

        // >> LCB-505
        Clear(ManualAcceptanceAllowed);
        Clear(ManualAcceptanceErrorMsg);
        // << LCB-505
    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        POINVHeader: Record "GXL PO INV Header";
        PurchaseHeader: Record "Purchase Header";
        Location: Record Location;
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        EDIFunctions: Codeunit "GXL EDI Functions Library";
        ManualAcceptanceAllowed: Boolean;
        ManualAcceptanceErrorMsg: Text[250];
        Text000Txt: Label '%1 must have a value. It cannot be zero or blank.';
        Text001Txt: Label '%1 must be equal to %2.';
        Text002Txt: Label '%1 cannot be less than %2.';
        Text003Txt: Label 'Invoice must have lines.';
        Text004Txt: Label 'Purchase Order for Invoice %1 doesn''t exist.';
        Text005Txt: Label 'There is already a valid Invoice %1 %2 for Purchase Order %3.';
        Text006Txt: Label 'Purchase Order %1 already has %2 populated. Value: %3.';
        Text007Txt: Label 'ASN %1 for this Invoice has been rejected.';
        Text008Txt: Label 'ASN %1 for this Invoice doesn''t exist.';
        Text009Txt: Label 'Number of lines on the Invoice is different to the number of Purchase Order lines received.\\Invoice line count: %1. Purchase Order received line count: %2.';
        Text010Txt: Label 'Purchase Line %1 %2 for Purchase Order %3 doesn''t exist.';
        Text011Txt: Label 'Purchase Line %1 %2 for Purchase Order %3 must have %4 = %5.';
        Text012Txt: Label 'Item No. on Purchase Line %1 is different to the one on the Invoice. Purchase Line value: %2. Invoice Line value: %3.';
        Text013Txt: Label '%1 on Purchase Line %2 is different to the one on the Invoice. Purchase Line value: %3. Invoice Line value: %4.';
        Text014Txt: Label '%1 on Purchase Order %2 is different to the one on the Invoice. Purchase Order value: %3. Invoice value: %4.';
        //Text015Txt: Label 'Qty. to Invoice on Purchase Line %1 is different to the one on the Invoice. Purchase Line value: %2. Invoice Line value: %3';
        Text016Txt: Label '%1 used as GLN on Invoice %2 is different to the %5 on the EDI Setup. Invoice value: %3. EDI Setup value: %4.';
        Text017Txt: Label 'There is already a valid Invoice %1 %2 for Supplier %3.';

    local procedure ValidateINVHeader()
    var
        POINVHeader2: Record "GXL PO INV Header";
        Vendor: Record Vendor;
    //IntegrationSetup: Record "GXL Integration Setup"; //ERP-247 <<
    begin
        //IntegrationSetup.Get(); //ERP-247 <<
        IF POINVHeader."Purchase Order No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVHeader.FIELDCAPTION("Purchase Order No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END ELSE BEGIN
            IF NOT PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, POINVHeader."Purchase Order No.") THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text004Txt, POINVHeader."No."));
                EDIErrorMgt.ThrowErrorMessage();
            END ELSE BEGIN
                PurchaseHeader.CALCFIELDS("GXL ASN Created", "GXL ASN Number", Amount, "Amount Including VAT");
                Location.Get(PurchaseHeader."Location Code");
                Location.CalcFields("GXL Location Type");
            END;
        END;

        POINVHeader2.SETCURRENTKEY("Buy-from Vendor No.", "Original EDI Document No.", Status);
        POINVHeader2.SETRANGE("Buy-from Vendor No.", POINVHeader."Buy-from Vendor No.");
        POINVHeader2.SETRANGE("Original EDI Document No.", POINVHeader."Original EDI Document No.");
        POINVHeader2.SETFILTER(Status, '>=%1', POINVHeader2.Status::Validated);
        IF POINVHeader2.FindSet() THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text017Txt,
                POINVHeader2.FIELDCAPTION("No."),
                POINVHeader2."Original EDI Document No.",
                POINVHeader."Buy-from Vendor No."));

            EDIErrorMgt.ThrowErrorMessage();
        END;

        POINVHeader2.Reset();
        //subsequent invoice

        POINVHeader2.SETCURRENTKEY("Purchase Order No.", Status);
        POINVHeader2.SETRANGE("Purchase Order No.", POINVHeader."Purchase Order No.");
        POINVHeader2.SETFILTER(Status, '>=%1', POINVHeader2.Status::Validated);

        IF POINVHeader2.FindSet() THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text005Txt,
                POINVHeader2.FIELDCAPTION("No."),
                POINVHeader2."No.",
                POINVHeader."Purchase Order No."));

            EDIErrorMgt.ThrowErrorMessage();
        END;

        //Vendor invoice number is missing.
        IF POINVHeader."Original EDI Document No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVHeader.FIELDCAPTION("No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END ELSE BEGIN
            //vendor invoice no. already updated on Purchase Order
            IF (PurchaseHeader."Vendor Invoice No." <> '') AND
               (PurchaseHeader."Vendor Invoice No." <> POINVHeader."Original EDI Document No.")
            THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text006Txt,
                    PurchaseHeader."No.",
                    PurchaseHeader.FIELDCAPTION("Vendor Invoice No."),
                    PurchaseHeader."Vendor Invoice No."));

                EDIErrorMgt.ThrowErrorMessage();
            END;
        END;

        IF POINVHeader."Invoice Received Date" = 0D THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVHeader.FIELDCAPTION("Invoice Received Date")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POINVHeader."Pay-to Vendor No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVHeader.FIELDCAPTION("Pay-to Vendor No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END ELSE BEGIN
            IF POINVHeader."Pay-to Vendor No." <> IntegrationSetup."GLN for EDI" THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text016Txt,
                    POINVHeader.FIELDCAPTION("Pay-to Vendor No."),
                    POINVHeader."No.",
                    POINVHeader."Pay-to Vendor No.",
                    IntegrationSetup."GLN for EDI",
                    IntegrationSetup.FIELDCAPTION("GLN for EDI")));

                EDIErrorMgt.ThrowErrorMessage();
            END;
        END;

        IF POINVHeader."Buy-from Vendor No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVHeader.FIELDCAPTION("Buy-from Vendor No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END ELSE BEGIN
            IF POINVHeader."Buy-from Vendor No." <> PurchaseHeader."Buy-from Vendor No." THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text014Txt,
                    PurchaseHeader.FIELDCAPTION("Buy-from Vendor No."),
                    PurchaseHeader."No.",
                    PurchaseHeader."Buy-from Vendor No.",
                    POINVHeader."Buy-from Vendor No."));

                EDIErrorMgt.ThrowErrorMessage();
            END;
        END;

        IF POINVHeader."Supplier ABN" = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVHeader.FIELDCAPTION("Supplier ABN")));
            EDIErrorMgt.ThrowErrorMessage();
        END ELSE BEGIN
            Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
            IF POINVHeader."Supplier ABN" <> Vendor.ABN THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text014Txt,
                    POINVHeader.FIELDCAPTION("Supplier ABN"),
                    PurchaseHeader."No.",
                    Vendor.ABN,
                    POINVHeader."Supplier ABN"));

                EDIErrorMgt.ThrowErrorMessage();
            END
        END;

        IF POINVHeader."Invoice Type" <> POINVHeader."Invoice Type"::"Tax Invoice" THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text001Txt,
                POINVHeader.FIELDCAPTION("Invoice Type"),
                POINVHeader."Invoice Type"::"Tax Invoice"));

            EDIErrorMgt.ThrowErrorMessage();
        END;

        //TODO: temporarily removed the Orignal ASN No. as ASN header is imported from NAV 13
        // >> HP2-Spriny2
        IF POINVHeader."Original ASN No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVHeader.FIELDCAPTION("ASN Number")));
            EDIErrorMgt.ThrowErrorMessage();
        END ELSE BEGIN
            // << HP2-Spriny2
            if POINVHeader."Original ASN No." <> '' then begin
                ValidateASNNumber();

                //asn number is different to the one on the invoice
                IF POINVHeader."ASN Number" <> PurchaseHeader."GXL ASN Number" THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text014Txt,
                        PurchaseHeader.FIELDCAPTION("GXL ASN Number"),
                        PurchaseHeader."No.",
                        PurchaseHeader."GXL ASN Number",
                        POINVHeader."ASN Number"));

                    EDIErrorMgt.ThrowErrorMessage();
                END;
            END;

            //Price on the invoice does not match the Direct Unit Cost on the correspondent PO line
            IF POINVHeader.Amount < 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text002Txt,
                    POINVHeader.FIELDCAPTION(Amount),
                    0));

                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF POINVHeader."Amount Incl. VAT" < 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text002Txt,
                    POINVHeader.FIELDCAPTION("Amount Incl. VAT"),
                    0));

                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF POINVHeader."Total GST" < 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text002Txt,
                    POINVHeader.FIELDCAPTION("Total GST"),
                    0));

                EDIErrorMgt.ThrowErrorMessage();
            END;
        end;
    end;

    local procedure ValidateINVLines()
    var
        POINVLine: Record "GXL PO INV Line";
        PurchaseLine: Record "Purchase Line";
        PurchSetup: Record "Purchases & Payables Setup"; // >> LCB-250 <<
        VendorL: Record Vendor; // >> 001 <<
        EDISetup: Record "GXL Integration Setup";
        InvoiceLineCount: Integer;
        ReceivedOrderCount: Integer;
        CartonQtyReceived: Decimal;
        BlankorOnHoldCode: Code[20];
    begin
        PurchSetup.Get(); // >> LCB-250 <<
        POINVLine.SETRANGE("INV No.", POINVHeader."No.");

        IF POINVLine.FindSet() THEN BEGIN
            REPEAT

                IF POINVLine."PO Line No." <= 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVLine.FIELDCAPTION("PO Line No.")));
                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    IF NOT PurchaseLine.Get(PurchaseHeader."Document Type", PurchaseHeader."No.", POINVLine."PO Line No.") THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(
                            Text010Txt,
                            PurchaseLine.FIELDCAPTION("Line No."),
                            PurchaseLine."Line No.",
                            PurchaseHeader."No."));

                        EDIErrorMgt.ThrowErrorMessage();
                    END ELSE BEGIN
                        IF PurchaseLine.Type <> PurchaseLine.Type::Item THEN BEGIN
                            EDIErrorMgt.SetErrorMessage(
                              STRSUBSTNO(
                                Text011Txt,
                                PurchaseLine.FIELDCAPTION("Line No."),
                                PurchaseLine."Line No.",
                                PurchaseHeader."No.",
                                PurchaseLine.FIELDCAPTION(Type),
                                PurchaseLine.Type));

                            EDIErrorMgt.ThrowErrorMessage();
                        END;
                    END;
                END;

                //INV. PO Line No. does not match PO.Line No
                IF POINVLine."Item No." = '' THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVLine.FIELDCAPTION(ILC)));
                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    IF POINVLine."Item No." <> PurchaseLine."No." THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(
                            Text012Txt,
                            PurchaseLine."Line No.",
                            PurchaseLine."GXL Legacy Item No.",
                            POINVLine.ILC));

                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                END;

                //SupplierNo(Vendor Reorder No.) does not match the PO
                IF POINVLine."Vendor Reorder No." = '' THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVLine.FIELDCAPTION("Vendor Reorder No.")));
                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    // >> LCB-250 code commented
                    if PurchSetup."GXL EDI Validate VendReord No." then
                        IF POINVLine."Vendor Reorder No." <> PurchaseLine."GXL Vendor Reorder No." THEN BEGIN
                            EDIErrorMgt.SetErrorMessage(
                              STRSUBSTNO(
                                Text013Txt,
                                PurchaseLine.FIELDCAPTION("GXL Vendor Reorder No."),
                                PurchaseLine."Line No.",
                                PurchaseLine."GXL Vendor Reorder No.",
                                POINVLine."Vendor Reorder No."));

                            EDIErrorMgt.ThrowErrorMessage();
                        END;
                    // << LCB-250
                END;

                IF POINVLine.OMQTY < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text002Txt,
                        POINVLine.FIELDCAPTION(OMQTY),
                        0));

                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    IF POINVLine.OMQTY <> GetOMQty(PurchaseLine) THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(
                            Text013Txt,
                            POINVLine.FIELDCAPTION(OMQTY),
                            PurchaseLine."Line No.",
                            GetOMQty(PurchaseLine),
                            POINVLine.OMQTY));

                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                END;

                IF POINVLine.OPQTY < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text002Txt,
                        POINVLine.FIELDCAPTION(OPQTY),
                        0));

                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    IF POINVLine.OPQTY <> GetOPQty(PurchaseLine) THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(
                            Text013Txt,
                            POINVLine.FIELDCAPTION(OPQTY),
                            PurchaseLine."Line No.",
                            GetOPQty(PurchaseLine),
                            POINVLine.OPQTY));

                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                END;

                IF POINVLine."Qty. to Invoice" < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text002Txt,
                        POINVLine.FIELDCAPTION("Qty. to Invoice"),
                        0));

                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    // >> LCB-504
                    // IF PurchaseHeader."GXL EDI Order in Out. Pack UoM" THEN BEGIN
                    //     IF Location."GXL Location Type" = Location."GXL Location Type"::"3" THEN  // Location Type = DC
                    //         CartonQtyReceived := ROUND(PurchaseLine."Quantity Received" / POINVLine.OPQTY, 0.01, '>')
                    //     ELSE
                    //         CartonQtyReceived := ROUND(PurchaseLine."Quantity Received" / POINVLine.OMQTY, 0.01, '>');
                    // END ELSE
                    //     CartonQtyReceived := ROUND(PurchaseLine."Quantity Received" / POINVLine.OMQTY / POINVLine.OPQTY, 0.01, '>');

                    //IF POINVLine."Qty. to Invoice" <> CartonQtyReceived THEN BEGIN
                    IF POINVLine."Unit QTY To Invoice" <> PurchaseLine."Quantity Received" THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(
                            Text013Txt,
                            POINVLine.FIELDCAPTION("Unit QTY To Invoice"),
                            PurchaseLine."Line No.",
                            //  CartonQtyReceived,
                            PurchaseLine."Quantity Received",
                            POINVLine."Unit QTY To Invoice"));

                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                    // << LCB-504
                END;

                IF POINVLine."Unit QTY To Invoice" < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text002Txt,
                        POINVLine.FIELDCAPTION("Unit QTY To Invoice"),
                        0));

                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN

                    IF POINVLine."Unit QTY To Invoice" <> PurchaseLine."Quantity Received" THEN BEGIN
                        BlankorOnHoldCode := '';
                        EDIErrorMgt.SetErrorMessage(BlankorOnHoldCode +
                        STRSUBSTNO(
                          Text013Txt,
                          PurchaseLine.FIELDCAPTION("Quantity Received"),
                          PurchaseLine."Line No.",
                          PurchaseLine."Quantity Received",
                          POINVLine."Unit QTY To Invoice"));

                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                END;

                //The price on the invoice is checked against PO
                IF POINVLine."Direct Unit Cost" < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text002Txt,
                        POINVLine.FIELDCAPTION("Direct Unit Cost"),
                        0));

                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    EDISetup.Get(); // >> LCB-505 <<
                    IF ROUND(POINVLine."Direct Unit Cost", IntegrationSetup."Amount Rounding Precision") <> ROUND(PurchaseLine."Direct Unit Cost", IntegrationSetup."Amount Rounding Precision") THEN BEGIN
                        IF ABS(ROUND(POINVLine."Direct Unit Cost", EDISetup."Amount Rounding Precision") - ROUND(PurchaseLine."Direct Unit Cost", EDISetup."Amount Rounding Precision")) > EDISetup."P2P INV Line Amount Variance" THEN begin // >> LCB-505 <<
                            IF NOT ManualAcceptanceAllowed THEN BEGIN
                                ManualAcceptanceErrorMsg := STRSUBSTNO(
                                  Text013Txt,
                                  PurchaseLine.FIELDCAPTION("Direct Unit Cost"),
                                  PurchaseLine."Line No.",
                                  PurchaseLine."Direct Unit Cost",
                                  POINVLine."Direct Unit Cost");

                                ManualAcceptanceAllowed := TRUE;
                            END;
                        end; // >> LCB-505 <<
                        // << LCB-505
                    END;
                END;

                IF POINVLine.Amount < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text002Txt,
                        POINVLine.FIELDCAPTION(Amount),
                        0));

                    EDIErrorMgt.ThrowErrorMessage();
                END;

                IF POINVLine."Amount Incl. VAT" < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text002Txt,
                        POINVLine.FIELDCAPTION("Amount Incl. VAT"),
                        0));

                    EDIErrorMgt.ThrowErrorMessage();
                END;

                IF POINVLine."Item GST Amount" < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text002Txt,
                        POINVLine.FIELDCAPTION("Item GST Amount"),
                        0));

                    EDIErrorMgt.ThrowErrorMessage();
                END;

                IF POINVLine."Unit of Measure Code" = '' THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVLine.FIELDCAPTION("Unit of Measure Code")));
                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    if VendorL.Get(POINVHeader."Buy-from Vendor No.") and (not VendorL."GXL EDI Order in Out. Pack UoM") then // >> 001 <<
                        IF POINVLine."Unit of Measure Code" <> PurchaseLine."Unit of Measure Code" THEN BEGIN
                            EDIErrorMgt.SetErrorMessage(
                            STRSUBSTNO(
                                Text013Txt,
                                PurchaseLine.FIELDCAPTION("Unit of Measure Code"),
                                PurchaseLine."Line No.",
                                PurchaseLine."Unit of Measure Code",
                                POINVLine."Unit of Measure Code"));

                            EDIErrorMgt.ThrowErrorMessage();
                        END;
                END;

                IF POINVLine."VAT %" < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text002Txt,
                        POINVLine.FIELDCAPTION("VAT %"),
                        0));

                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    IF POINVLine."VAT %" <> PurchaseLine."VAT %" THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(
                            Text013Txt,
                            PurchaseLine.FIELDCAPTION("VAT %"),
                            PurchaseLine."Line No.",
                            PurchaseLine."VAT %",
                            POINVLine."VAT %"));

                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                END;

                if POINVLine."Qty. to Invoice" > 0 then // >> LCB-503 <<
                    InvoiceLineCount += 1;

            UNTIL POINVLine.Next() = 0;

            //The number of lines in the invoice is different than the number of PO lines received
            PurchaseLine.Reset();
            PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
            PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
            PurchaseLine.SETFILTER("Quantity Received", '<>%1', 0);

            ReceivedOrderCount := PurchaseLine.Count();

            IF InvoiceLineCount <> ReceivedOrderCount THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text009Txt,
                    InvoiceLineCount,
                    ReceivedOrderCount));

                EDIErrorMgt.ThrowErrorMessage();
            END;

        END ELSE BEGIN
            EDIErrorMgt.SetErrorMessage(Text003Txt);
            EDIErrorMgt.ThrowErrorMessage();
        END;
    end;

    local procedure GetOMQty(InputPurchaseLine: Record "Purchase Line"): Decimal
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        IF StockkeepingUnit.Get(PurchaseHeader."Location Code", InputPurchaseLine."No.", '') THEN
            EXIT(StockkeepingUnit."GXL Order Multiple (OM)");
    end;

    local procedure GetOPQty(InputPurchaseLine: Record "Purchase Line"): Decimal
    var
        StockkeepingUnit: Record "Stockkeeping Unit";
    begin
        IF StockkeepingUnit.Get(PurchaseHeader."Location Code", InputPurchaseLine."No.", '') THEN
            EXIT(StockkeepingUnit."GXL Order Pack (OP)");
    end;

    [Scope('OnPrem')]
    procedure ValidateASNNumber()
    var
        ASNHeader: Record "GXL ASN Header";
    begin
        //TODO: temporarily add condition as Original EDI Document No. is not mandatory in ASN header
        if POINVHeader."Original ASN No." <> '' then begin
            ASNHeader.Reset();
            ASNHeader.SETRANGE("Document Type", ASNHeader."Document Type"::Purchase);
            ASNHeader.SETRANGE("Purchase Order No.", POINVHeader."Purchase Order No.");
            ASNHeader.SETRANGE("Original EDI Document No.", POINVHeader."Original ASN No.");
            IF ASNHeader.IsEmpty() THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text008Txt, POINVHeader."Original ASN No."));
                EDIErrorMgt.ThrowErrorMessage();
            END ELSE BEGIN
                ASNHeader.SETFILTER(Status, '%1..', ASNHeader.Status::Validated);
                IF ASNHeader.FindFirst() THEN BEGIN
                    POINVHeader."ASN Number" := ASNHeader."No.";
                    POINVHeader.Modify();
                END
                ELSE BEGIN
                    ASNHeader.SETFILTER(Status, '=%1', ASNHeader.Status::"Validation Error");
                    IF not ASNHeader.IsEmpty() THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text007Txt, POINVHeader."Original ASN No."));
                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                END;
            END;
        end;
    end;
}

