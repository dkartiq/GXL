// 001 07.11.2024 KDU https://petbarnjira.atlassian.net/browse/LCB-340/
codeunit 50377 "GXL P2P-Validate Invoice"
{
    TableNo = "GXL PO INV Header";

    trigger OnRun()
    var
    begin
        POINVHeader := Rec;
        CLEAR(EDIFunctions);
        //validate INV mandatory fields and Accept | Reject Invoice
        // >> LCB-505
        ManualAcceptanceAllowed := false;
        ManualAcceptanceErrorMsg := '';
        // << LCB-505
        ValidateINVHeader();
        ValidateP2PAllInvLinesExist();
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
        PurchaseHeader: Record "Purchase Header";
        POINVHeader: Record "GXL PO INV Header";
        EDIFunctions: Codeunit "GXL EDI Functions Library";
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        ManualAcceptanceAllowed: Boolean;
        Text000Txt: Label '%1 must have a value. It cannot be zero or blank.';
        Text002Txt: Label '%1 cannot be less than %2.';
        Text003Txt: Label 'Purchase Order for Invoice No. %1 doesn''t exist.';
        //Text004Txt: Label 'Line No. %1 not found on Purchase Order %2.';
        Text005Txt: Label 'There is already a valid Invoice %1 %2 for Purchase Order %3.';
        Text017Txt: Label 'Vendor Invoice Number %1 is lready used for this vendor %2';
        //Text014: Label '%1 on Purchase Order %2 is different to the one on the Invoice. Purchase Order value: %3. Invoice value: %4.';
        //Text015: Label 'Qty. to Invoice on Purchase Line %1 is different to the one on the Invoice. Purchase Line value: %2. Invoice Line value: %3';
        //Text016: Label '%1 used as GLN on Invoice %2 is different to the %5 on the EDI Setup. Invoice value: %3. EDI Setup value: %4.';
        //Text001: Label '%1 must be equal to %2.';
        //Text018: Label 'Invoice must have lines.';
        //Text019: Label 'Purchase Order for Invoice %1 doesn''t exist.';
        //Text006: Label 'Purchase Order %1 already has %2 populated. Value: %3.';
        //Text007: Label 'ASN %1 for this Invoice has been rejected.';
        //Text008: Label 'ASN %1 for this Invoice doesn''t exist.';
        Text009Txt: Label 'Number of lines on the Invoice is different to the number of Purchase Order lines received.\\Invoice line count: %1. Purchase Order received line count: %2.';
        Text010Txt: Label 'Purchase Line %1 %2 for Purchase Order %3 doesn''t exist.';
        Text011Txt: Label 'Purchase Line %1 %2 for Purchase Order %3 must have %4 = %5.';
        Text012Txt: Label 'Item No. on Purchase Line %1 is different to the one on the Invoice. Purchase Line value: %2. Invoice Line value: %3.';
        Text013Txt: Label '%1 on Purchase Line %2 is different to the one on the Invoice. Purchase Line value: %3. Invoice Line value: %4.';
        Text020Txt: Label '%1 on PO Invoice Item Line must be less or equal to %2 on %5. PO Invoice Item Line value: %3. Purchase Line value: %4.';
        //Text021Txt: Label 'Item %1 doesn''t exist in Purchase Order %2.';
        Text022Txt: Label 'Vendor Reorder No %1 doesn''t exist in Purchase Order %2.';
        ManualAcceptanceErrorMsg: Text;

    local procedure ValidateP2PAllInvLinesExist()
    var
        PurchaseLine: Record "Purchase Line";
        POINVLine: Record "GXL PO INV Line";
        POINVLine2: Record "GXL PO INV Line";
    begin
        POINVLine.SETRANGE("INV No.", POINVHeader."No.");
        POINVLine.SETRANGE("PO Line No.", 0);
        IF POINVLine.FindSet(TRUE, TRUE) THEN
            REPEAT
                POINVLine2 := POINVLine;
                IF (POINVLine."Vendor Reorder No." <> '') THEN BEGIN
                    PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
                    PurchaseLine.SETRANGE("Document No.", POINVHeader."Purchase Order No.");
                    PurchaseLine.SETFILTER("GXL Vendor Reorder No.", POINVLine."Vendor Reorder No.");
                    IF PurchaseLine.FindFirst() THEN BEGIN
                        POINVLine2."PO Line No." := PurchaseLine."Line No.";
                        POINVLine2."Item No." := PurchaseLine."No.";
                        POINVLine2."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
                        POINVLine2.ILC := PurchaseLine."GXL Legacy Item No.";
                        POINVLine2.Modify();
                    END ELSE BEGIN
                        EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text022Txt, POINVLine."Vendor Reorder No.", POINVHeader."Purchase Order No."));
                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                END;
                COMMIT();
            UNTIL POINVLine.Next() = 0;

    end;

    local procedure CheckVendorInvoiceNo(VendInvNumber: Code[20]; PaytoVend: Code[20]): Boolean
    var
        PurchSetup: Record "Purchases & Payables Setup";
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        PurchSetup.Get();
        IF PurchSetup."Ext. Doc. No. Mandatory" OR
           (VendInvNumber <> '')
        THEN BEGIN
            VendLedgEntry.Reset();
            VendLedgEntry.SETCURRENTKEY("External Document No.");
            VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Invoice);
            VendLedgEntry.SETRANGE("External Document No.", VendInvNumber);
            VendLedgEntry.SETRANGE("Vendor No.", PaytoVend);
            IF not VendLedgEntry.IsEmpty() THEN
                EXIT(TRUE)
        END;
        EXIT(FALSE)
    end;

    local procedure CheckDirectUnitCost(PurchaseLine: Record "Purchase Line"; POINVLine: Record "GXL PO INV Line")
    var
        Vendor: Record Vendor;
        EDISetup: Record "GXL Integration Setup";
    begin
        IF POINVLine."Direct Unit Cost" = 0 THEN
            EXIT;
        EDISetup.Get();

        IF ROUND(POINVLine."Direct Unit Cost", EDISetup."Amount Rounding Precision") = ROUND(PurchaseLine."Direct Unit Cost", EDISetup."Amount Rounding Precision") THEN
            EXIT;

        IF ABS(ROUND(POINVLine."Direct Unit Cost", EDISetup."Amount Rounding Precision") - ROUND(PurchaseLine."Direct Unit Cost", EDISetup."Amount Rounding Precision")) <= EDISetup."P2P INV Line Amount Variance" THEN // >> LCB-505 <<
            EXIT;

        Vendor.GET(PurchaseLine."Pay-to Vendor No.");

        IF NOT Vendor."GXL Acc. Lower Cost Purch. Inv" THEN BEGIN
            ManualAcceptanceAllowed := TRUE;
            ManualAcceptanceErrorMsg :=
                        STRSUBSTNO(
                          Text013Txt,
                          POINVLine.FIELDCAPTION("Direct Unit Cost"),
                          PurchaseLine."Line No.",
                          PurchaseLine."Direct Unit Cost",
                          POINVLine."Direct Unit Cost");

        END ELSE BEGIN
            IF POINVLine."Direct Unit Cost" > PurchaseLine."Direct Unit Cost" THEN BEGIN
                ManualAcceptanceAllowed := TRUE;
                ManualAcceptanceErrorMsg :=
                            STRSUBSTNO(
                              Text020Txt,
                              POINVLine.FIELDCAPTION("Direct Unit Cost"),
                              PurchaseLine.FIELDCAPTION("Direct Unit Cost"),
                              POINVLine."Direct Unit Cost",
                              PurchaseLine."Direct Unit Cost",
                              PurchaseLine.TABLECAPTION());
            END;
        END;

    end;

    local procedure ValidateINVHeader()
    var
        POINVHeader2: Record "GXL PO INV Header";
        EDISetup: Record "GXL Integration Setup";
    begin
        EDISetup.Get();
        IF POINVHeader."Purchase Order No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVHeader.FIELDCAPTION("Purchase Order No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END ELSE BEGIN
            IF NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, POINVHeader."Purchase Order No.") THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text003Txt, POINVHeader."No."));
                EDIErrorMgt.ThrowErrorMessage();
            END;
        END;

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
        POINVHeader."Vendor Invoice No." := POINVHeader."Original EDI Document No."; // >> 001 <<
        IF POINVHeader."Vendor Invoice No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVHeader.FIELDCAPTION("Vendor Invoice No.")));

            EDIErrorMgt.ThrowErrorMessage();
        END ELSE
            IF CheckVendorInvoiceNo(POINVHeader."Vendor Invoice No.", PurchaseHeader."Pay-to Vendor No.") THEN BEGIN
                // >> 001
                POINVHeader.Validate("Vendor Invoice No.", PurchaseHeader."No.");
                IF CheckVendorInvoiceNo(POINVHeader."Vendor Invoice No.", PurchaseHeader."Pay-to Vendor No.") THEN BEGIN
                    // << 001
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text017Txt,
                        POINVHeader."Vendor Invoice No.",
                        PurchaseHeader."Pay-to Vendor No."));

                    EDIErrorMgt.ThrowErrorMessage();
                END;
            end; // >> 001 <<

        IF POINVHeader."Invoice Received Date" = 0D THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVHeader.FIELDCAPTION("Invoice Received Date")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POINVHeader."P2P Supplier ABN" = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVHeader.FIELDCAPTION("P2P Supplier ABN")));
            EDIErrorMgt.ThrowErrorMessage();
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

        IF POINVHeader."Supplier Name" = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text000Txt,
                POINVHeader.FIELDCAPTION("Supplier Name")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

    end;

    local procedure ValidateINVLines()
    var
        POINVLine: Record "GXL PO INV Line";
        PurchaseLine: Record "Purchase Line";
        InvoiceLineCount: Integer;
        ReceivedOrderCount: Integer;
    begin
        POINVLine.SETRANGE("INV No.", POINVHeader."No.");
        IF POINVLine.FindSet() THEN BEGIN
            REPEAT
                IF POINVLine."Vendor Reorder No." = '' THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVLine.FIELDCAPTION("Vendor Reorder No.")));
                    EDIErrorMgt.ThrowErrorMessage();
                END;

                IF POINVLine."PO Line No." <= 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POINVLine.FIELDCAPTION("PO Line No.")));
                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    IF NOT PurchaseLine.GET(PurchaseHeader."Document Type", PurchaseHeader."No.", POINVLine."PO Line No.") THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(
                            Text010Txt,
                            PurchaseLine.FIELDCAPTION("Line No."),
                            POINVLine."PO Line No.",
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

                //The quantity on the invoice (possibly adjusted with a short receipt claim) is checked against the quantity received
                //If invoice quantity less short received claim quantity matches the receipt then the invoice is accepted

                IF POINVLine."Qty. to Invoice" < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text002Txt,
                        POINVLine.FIELDCAPTION("Qty. to Invoice"),
                        0));

                    EDIErrorMgt.ThrowErrorMessage();
                END ELSE BEGIN
                    // >> LCB-504
                    //IF POINVLine."Qty. to Invoice" <> PurchaseLine."Quantity Received" THEN BEGIN
                    IF POINVLine."Unit QTY To Invoice" <> PurchaseLine."Quantity Received" THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(
                            Text013Txt,
                            POINVLine.FIELDCAPTION("Unit QTY To Invoice"),
                            PurchaseLine."Line No.",
                            PurchaseLine."Quantity Received",
                            POINVLine."Unit QTY To Invoice"));

                        EDIErrorMgt.ThrowErrorMessage();
                    END;
                    // << LCB-504
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
                    CheckDirectUnitCost(PurchaseLine, POINVLine);
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

                InvoiceLineCount += 1;

            UNTIL POINVLine.Next() = 0;

            //The number of lines in the invoice is different than the number of PO lines received
            PurchaseLine.Reset();
            PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
            PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
            PurchaseLine.SETFILTER("Quantity Received", '<>%1', 0);

            ReceivedOrderCount := PurchaseLine.COUNT();

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
}

