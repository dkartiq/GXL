codeunit 50373 "GXL EDI-Proc Adv. Ship. Notice"
{
    TableNo = "GXL ASN Header";

    trigger OnRun()
    begin
        ASNHeader := Rec;

        //ASN check order status
        ValidatePOOrderStatus();

        //ProcessASN
        UpdatePOFromASN();

        //TODO: EDI File Log
        if ASNHeader."EDI File Log Entry No." = 0 then
            ASNHeader.AddEDIFileLog();

        //update ASN header
        ASNHeader.VALIDATE(Status, ASNHeader.Status::Processed);
        ASNHeader.MODIFY();

        Rec := ASNHeader;
    end;

    var
        ASNHeader: Record "GXL ASN Header";
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        Text001Txt: Label 'Last EDI Document Status is %1 for Purchase Order %2. ';
        Text002Txt: Label 'Order Status must be %1 or %2 for Purchase Order %3. ';


    local procedure ValidatePOOrderStatus()
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchHeader.RESET();
        IF PurchHeader.GET(PurchHeader."Document Type"::Order, ASNHeader."Purchase Order No.") THEN BEGIN
            //TODO: Last EDI Document Status to be set to ASN as the ASN Header/Lines are imported from NAV13 for Validated ASN Headers only 
            If ASNHeader.Status = ASNHeader.Status::Validated then
                PurchHeader."GXL Last EDI Document Status" := PurchHeader."GXL Last EDI Document Status"::ASN;

            IF NOT (PurchHeader."GXL Last EDI Document Status" IN
                [PurchHeader."GXL Last EDI Document Status"::PO, PurchHeader."GXL Last EDI Document Status"::POR, PurchHeader."GXL Last EDI Document Status"::ASN]) THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text001Txt,
                    FORMAT(PurchHeader."GXL Last EDI Document Status"),
                    ASNHeader."Purchase Order No."));

                EDIErrorMgt.ThrowErrorMessage();
            END;
            //TODO: Order Status - EDI Process ASN - only Placed or Confirmed is accepted
            IF NOT (PurchHeader."GXL Order Status" IN [PurchHeader."GXL Order Status"::Placed, PurchHeader."GXL Order Status"::Confirmed]) THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                   STRSUBSTNO(Text002Txt,
                    'Placed', 'Confirmed', ASNHeader."Purchase Order No."));

                EDIErrorMgt.ThrowErrorMessage();
            END;
        END;
    end;

    ///<Summary>
    ///Update purchase qty. to receive and variance
    ///Update ASN File Received = true
    ///</Summary>
    local procedure UpdatePOFromASN()
    var
        PurchLine: Record "Purchase Line";
        PurchHeader: Record "Purchase Header";
    begin
        PurchLine.RESET();
        PurchLine.SETRANGE("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SETRANGE("Document No.", ASNHeader."Purchase Order No.");
        PurchLine.SETRANGE(Type, PurchLine.Type::Item);
        PurchLine.SETFILTER("Qty. to Receive", '<>%1', 0);
        IF PurchLine.FINDSET() THEN
            REPEAT
                UpdateASNItemQty(PurchLine);
            UNTIL PurchLine.NEXT() = 0;

        PurchHeader.RESET();
        IF PurchHeader.GET(PurchHeader."Document Type"::Order, ASNHeader."Purchase Order No.") THEN BEGIN
            //TODO: Last EDI Document Status to be set to ASN as the ASN Header/Lines are imported from NAV13 for Validated ASN Headers only 
            if ASNHeader.Status = ASNHeader.Status::Validated then
                PurchHeader."GXL Last EDI Document Status" := PurchHeader."GXL Last EDI Document Status"::ASN;
            PurchHeader."GXL ASN File Received" := TRUE;
            PurchHeader.MODIFY();
        END;
    end;

    ///<Summary>
    ///Update purchase qty. to receive from ASN Line Level 3
    ///</Summary>
    local procedure UpdateASNItemQty(var PurchLine: Record "Purchase Line")
    var
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
    begin
        ASNLevel3Line.RESET();
        ASNLevel3Line.SETCURRENTKEY("Document Type", "Document No.", "Level 3 Code");
        ASNLevel3Line.SETRANGE("Document Type", ASNHeader."Document Type");
        ASNLevel3Line.SETRANGE("Document No.", ASNHeader."No.");
        //Legacy item
        //ASNLevel3Line.SETRANGE("Level 3 Code", PurchLine."No.");
        ASNLevel3Line.SetRange("Level 3 Code", PurchLine."GXL Legacy Item No.");
        IF ASNLevel3Line.FINDFIRST() THEN BEGIN
            ASNLevel3Line.CALCSUMS(Quantity);
            IF ASNLevel3Line.Quantity <> PurchLine."Qty. to Receive" THEN BEGIN
                PurchLine."GXL ASN Rec. Variance" := PurchLine."Qty. to Receive" - ASNLevel3Line.Quantity;
                PurchLine.VALIDATE("Qty. to Receive", ASNLevel3Line.Quantity);
                PurchLine.MODIFY(TRUE);
            END;
        END ELSE BEGIN
            PurchLine."GXL ASN Rec. Variance" := PurchLine."Qty. to Receive";
            PurchLine.VALIDATE("Qty. to Receive", 0);
            PurchLine.MODIFY(TRUE);
        END;
    end;
}

