// 001 23.06.2025 KDU HAR2-397
codeunit 50370 "GXL EDI-Valid Pur. Order Resp."
{
    TableNo = "GXL PO Response Header";

    trigger OnRun()
    begin
        PurchaseHeader.Reset();
        IF NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec."Order No.") THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text003Txt, MiscUtilities.AddOriginalDocNo(Rec."Response Number", Rec."Original EDI Document No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        ValidateDuplication(Rec);

        ValidatePOResponseHeader(Rec);

        CLEAR(EDIFunctions);
        IF Rec."Response Type" = Rec."Response Type"::Changed THEN BEGIN
            ValidateAllPurchLinesExist(Rec."Response Number", Rec."Order No.");
            ValidatePOResponseLines(Rec);
        END;

        Rec.Status := Rec.Status::Validated;
        Rec.Modify();
    end;

    var
        PurchaseHeader: Record "Purchase Header";
        EDIFunctions: Codeunit "GXL EDI Functions Library";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        Text000Txt: Label '%1 must have a value. It cannot be zero or blank.';
        Text001Txt: Label 'PO Resonse must have Item lines.';
        Text002Txt: Label '%1 cannot be less than %2.';
        Text003Txt: Label 'Purchase Order for PO Response %1 doesn''t exist.';
        Text004Txt: Label 'Line No. %1 not found on Purchase Order %2.';
        Text005Txt: Label '%1 on PO Response Item Line must be less than or equal to %2 on %5. PO Response Item Line value: %3. Purchase Line value: %4.';
        //Text006Txt: Label 'Item %1 doesn''t exist in Purchase Order %2.';
        //Text007Txt: Label 'Purchase Order %1 has been cancelled.';
        Text008Txt: Label 'There is already a valid PO Response %1 %2 for Purchase Order %3.';
        Text009Txt: Label 'PO Response is missing PO Line No. %1.';
        Text010Txt: Label 'SKU for PO Response %1 Line No. %2 doesn''t exist.';
        Text011Txt: Label '%1 on PO Response Item Line must be equal to %2 on %5. PO Response Item Line value: %3. Purchase Line value: %4.';
        Text012Txt: Label 'There is already a valid PO %1 %2 for supplier %3.';

    local procedure ValidateDuplication(POResponseHeader: Record "GXL PO Response Header"): Boolean
    var
        POResponseHeader2: Record "GXL PO Response Header";
    begin
        // Error if a validated POR already exists for a given PO
        POResponseHeader2.Reset();
        POResponseHeader2.SETCURRENTKEY("Order No.");
        POResponseHeader2.SETRANGE("Order No.", POResponseHeader."Order No.");
        POResponseHeader2.SETFILTER(Status, '%1..', POResponseHeader2.Status::Validated);
        POResponseHeader2.SETFILTER("EDI File Log Entry No.", '<>%1', POResponseHeader."EDI File Log Entry No.");
        IF POResponseHeader2.FindFirst() THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text008Txt,
                //There is already a valid PO Response %1 for Purchase Order %2.
                POResponseHeader2.FIELDCAPTION("Response Number"),
                MiscUtilities.AddOriginalDocNo(POResponseHeader2."Response Number", POResponseHeader2."Original EDI Document No."),
                POResponseHeader."Order No."));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        // Error if a validated POR already exists for a given supplier
        POResponseHeader2.Reset();
        POResponseHeader2.SETCURRENTKEY("Original EDI Document No.", "Buy-from Vendor No.");
        POResponseHeader2.SETRANGE("Original EDI Document No.", POResponseHeader."Original EDI Document No.");
        POResponseHeader2.SETRANGE("Buy-from Vendor No.", POResponseHeader."Buy-from Vendor No.");
        POResponseHeader2.SETFILTER(Status, '%1..', POResponseHeader2.Status::Validated);
        IF POResponseHeader2.FindFirst() THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text012Txt,
                //There is already a valid PO Response %1 for supplier %2.
                POResponseHeader2.FIELDCAPTION("Response Number"),
                MiscUtilities.AddOriginalDocNo(POResponseHeader2."Response Number", POResponseHeader2."Original EDI Document No."),
                POResponseHeader."Buy-from Vendor No."));
            EDIErrorMgt.ThrowErrorMessage();
        END;
    end;

    local procedure ValidatePOResponseHeader(POResponseHeader: Record "GXL PO Response Header")
    begin
        IF POResponseHeader."Original EDI Document No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POResponseHeader.FIELDCAPTION("Response Number")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseHeader."PO Response Date" = 0D THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POResponseHeader.FIELDCAPTION("PO Response Date")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseHeader."Order No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POResponseHeader.FIELDCAPTION("Order No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseHeader."Expected Receipt Date" = 0D THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POResponseHeader.FIELDCAPTION("Expected Receipt Date")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseHeader."Response Type" = POResponseHeader."Response Type"::" " THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POResponseHeader.FIELDCAPTION("Response Type")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        // The only field that can be changed on the header is Delivery Date
    end;

    local procedure ValidateAllPurchLinesExist(POResponseNo: Text; PurchaseOrderNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        POResponseLine: Record "GXL PO Response Line";
    begin
        PurchaseLine.Reset();
        PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SETRANGE("Document No.", PurchaseOrderNo);
        IF PurchaseLine.FindSet() THEN BEGIN

            POResponseLine.Reset();
            POResponseLine.SETCURRENTKEY("PO Response Number");
            POResponseLine.SETRANGE("PO Response Number", POResponseNo);

            REPEAT

                POResponseLine.SETRANGE("PO Line No.", PurchaseLine."Line No.");
                IF POResponseLine.IsEmpty() THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text009Txt, PurchaseLine."Line No."));
                    EDIErrorMgt.ThrowErrorMessage();
                END;

            UNTIL PurchaseLine.Next() = 0;

        END;
    end;

    local procedure ValidatePOResponseLines(POResponseHeader: Record "GXL PO Response Header")
    var
        POResponseLine: Record "GXL PO Response Line";
    begin
        POResponseLine.Reset();
        POResponseLine.SETCURRENTKEY("PO Response Number");
        POResponseLine.SETRANGE("PO Response Number", POResponseHeader."Response Number");
        IF POResponseLine.FindSet() THEN BEGIN

            REPEAT

                ValidatePOResponseLine(POResponseLine, POResponseHeader."Order No.", POResponseHeader."Buy-from Vendor No.");

            UNTIL POResponseLine.Next() = 0;

        END ELSE BEGIN

            EDIErrorMgt.SetErrorMessage(Text001Txt);
            EDIErrorMgt.ThrowErrorMessage();

        END;
    end;

    local procedure ValidatePOResponseLine(POResponseLine: Record "GXL PO Response Line"; PurchOrderNo: Code[20]; VendorNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        SKU: Record "Stockkeeping Unit";
        OldGTIN: Code[50];
    begin
        PurchaseLine.Reset();
        IF NOT PurchaseLine.GET(PurchaseLine."Document Type"::Order, PurchOrderNo, POResponseLine."PO Line No.") THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text004Txt, POResponseLine."PO Line No.", PurchOrderNo));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseLine."Line No." = 0 THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, POResponseLine.FIELDCAPTION("Line No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseLine."Vendor Reorder No." <> PurchaseLine."GXL Vendor Reorder No." THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text011Txt,
                POResponseLine.FIELDCAPTION("Vendor Reorder No."),
                PurchaseLine.FIELDCAPTION("GXL Vendor Reorder No."),
                POResponseLine."Vendor Reorder No.",
                PurchaseLine."GXL Vendor Reorder No.",
                PurchaseLine.TABLECAPTION()));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        SKU.Reset();
        SKU.SETCURRENTKEY("Location Code", "Item No.");
        SKU.SETRANGE("Location Code", PurchaseLine."Location Code");
        SKU.SETRANGE("Item No.", PurchaseLine."No.");
        IF NOT SKU.FindFirst() THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text010Txt, POResponseLine."PO Line No.", PurchOrderNo));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseLine.OMQTY <> SKU."GXL Order Multiple (OM)" THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text011Txt,
                POResponseLine.FIELDCAPTION(OMQTY),
                SKU.FIELDCAPTION("GXL Order Multiple (OM)"),
                POResponseLine.OMQTY,
                SKU."GXL Order Multiple (OM)",
                SKU.TABLECAPTION()));
            EDIErrorMgt.ThrowErrorMessage();
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseLine.OPQTY <> SKU."GXL Order Pack (OP)" THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text011Txt,
                POResponseLine.FIELDCAPTION(OPQTY),
                SKU.FIELDCAPTION("GXL Order Pack (OP)"),
                POResponseLine.OPQTY,
                SKU."GXL Order Pack (OP)",
                SKU.TABLECAPTION()));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseLine.Quantity < 0 THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text002Txt, POResponseLine.FIELDCAPTION(Quantity), 0));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseLine.Quantity > PurchaseLine.Quantity THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text005Txt,
                POResponseLine.FIELDCAPTION(Quantity),
                PurchaseLine.FIELDCAPTION(Quantity),
                POResponseLine.Quantity,
                PurchaseLine.Quantity,
                PurchaseLine.TABLECAPTION()));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseLine."Carton-Qty" > PurchaseLine."GXL Carton-Qty" THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text005Txt,
                POResponseLine.FIELDCAPTION("Carton-Qty"),
                PurchaseLine.FIELDCAPTION("GXL Carton-Qty"),
                POResponseLine."Carton-Qty",
                PurchaseLine."GXL Carton-Qty",
                PurchaseLine.TABLECAPTION()));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF POResponseLine.Quantity > 0 THEN
            IF POResponseLine."Direct Unit Cost" <> PurchaseLine."Direct Unit Cost" THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text011Txt,
                    POResponseLine.FIELDCAPTION("Direct Unit Cost"),
                    PurchaseLine.FIELDCAPTION("Direct Unit Cost"),
                    POResponseLine."Direct Unit Cost",
                    PurchaseLine."Direct Unit Cost",
                    PurchaseLine.TABLECAPTION()));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        IF POResponseLine."Unit of Measure Code" <> PurchaseLine."Unit of Measure Code" THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text011Txt,
                POResponseLine.FIELDCAPTION("Unit of Measure Code"),
                PurchaseLine.FIELDCAPTION("Unit of Measure Code"),
                POResponseLine."Unit of Measure Code",
                PurchaseLine."Unit of Measure Code",
                PurchaseLine.TABLECAPTION()));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        // Validate GTIN ,PO,POX,POR,ASN,INV
        OldGTIN := EDIFunctions.ValidateGTIN(POResponseLine."Item No.", VendorNo, POResponseLine."Primary EAN");
        IF EDIFunctions.GTINIsChangedOrNew() THEN //GTINisChangedOrNew means its either a new gtin or an overwritten one
            EDIFunctions.InsertItemSupplierGTINBuffer(1, POResponseLine."PO Response Number", POResponseLine."Line No.", OldGTIN, POResponseLine."Primary EAN", (OldGTIN <> ''));
        //all the mandatory fields on po response line and header (apart from expected receipt date and quantity on line)
        //need to be checked against mappend values on PO
        //Quantity on POR can be changed - may be equal or less than quantity on PO.
    end;

    local procedure UpdatePurchaseOrder()
    begin
        PurchaseHeader."GXL Last EDI Document Status" := PurchaseHeader."GXL Last EDI Document Status"::POR;
        PurchaseHeader.Modify();
    end;

    [Scope('OnPrem')]
    procedure GetGTINChanges(var ItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary)
    begin
        EDIFunctions.GetGTINChanges(ItemSupplierGTINBuffer);
    end;
}

