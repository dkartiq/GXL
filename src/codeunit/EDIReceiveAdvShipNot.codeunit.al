codeunit 50365 "GXL EDI-Receive Adv. Ship. Not"
{

    TableNo = "GXL ASN Header";

    trigger OnRun()
    var
        ReceivingDiscrepancy: Boolean;
    begin
        ASNHeader := Rec;
        Vendor.Reset();
        Vendor.GET(ASNHeader."Supplier No.");
        //ASN check order status
        IF ASNHeader."EDI Type" = ASNHeader."EDI Type"::" " THEN
            ValidatePOOrderStatus();

        DeleteEDIClaimEntry();

        ReceivingDiscrepancy := ReceivePOFromASN();
        PostPurchaseReceipt();

        //TODO: EDI File log
        if ASNHeader."EDI File Log Entry No." = 0 then
            ASNHeader.AddEDIFileLog();

        //update ASN header
        ASNHeader."Receiving Discrepancy" := ReceivingDiscrepancy;
        ASNHeader.VALIDATE(Status, ASNHeader.Status::Received);
        ASNHeader.MODIFY();

        Rec := ASNHeader;
    end;

    var
        ASNHeader: Record "GXL ASN Header";
        Vendor: Record Vendor;
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        Text001Msg: Label 'Last EDI Document Status is %1 for Purchase Order %2. ';
        Text002Msg: Label 'Order Status must be %1 for Purchase Order %2. ';
    //Text003Msg: Label '%1 on %2 must match the counted value. ASN value: %3. Counted value: %4.';


    local procedure ValidatePOOrderStatus()
    var
        PurchHeader: Record "Purchase Header";
    begin
        PurchHeader.Reset();
        IF PurchHeader.GET(PurchHeader."Document Type"::Order, ASNHeader."Purchase Order No.") THEN BEGIN
            //Last EDI Document Status = ASN is updated during validate ASN Header/Lines or during process ASN Header/Lines
            IF PurchHeader."GXL Last EDI Document Status" <> PurchHeader."GXL Last EDI Document Status"::ASN THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text001Msg,
                    FORMAT(PurchHeader."GXL Last EDI Document Status"),
                    ASNHeader."Purchase Order No."));

                EDIErrorMgt.ThrowErrorMessage();
            END;

            //TODO: Order Status - EDI Receive ASN, check status must be confirmed
            //The Order Status has been set to Confirmed during codeunit "EDI Valid Adv Ship Notice" - AceeptOrRejectASN
            IF (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::Confirmed) THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(Text002Msg,
                    'Confirmed', ASNHeader."Purchase Order No."));

                EDIErrorMgt.ThrowErrorMessage();
            END;

        END;
    end;

    local procedure ReceivePOFromASN(): Boolean
    var
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
        PurchLine: Record "Purchase Line";
        TempASNLevel3Line: Record "GXL ASN Level 3 Line" temporary;
        ItemNo: Code[20];
        ClaimEntryLineNo: Integer;
        BoolDiscrepancy: Boolean;
        ItemGTIN: Code[50];
        ItemConfirmedQuantity: Decimal;
        ItemReceivedQuantity: Decimal;
        TempASNLevel3LineNo: Integer;
    begin
        ItemNo := '';
        ItemGTIN := '';
        ItemConfirmedQuantity := 0;
        ItemReceivedQuantity := 0;

        BoolDiscrepancy := FALSE;
        ClaimEntryLineNo := 0;
        ASNLevel3Line.Reset();
        ASNLevel3Line.SETCURRENTKEY("Document Type", "Document No.", "Level 3 Code");
        ASNLevel3Line.SETRANGE("Document Type", ASNHeader."Document Type");
        ASNLevel3Line.SETRANGE("Document No.", ASNHeader."No.");
        IF ASNLevel3Line.FindSet() then
            REPEAT
                IF ItemNo <> ASNLevel3Line."Level 3 Code" THEN BEGIN

                    IF ItemNo <> '' THEN BEGIN// if not first record
                        TempASNLevel3LineNo += 10000;
                        InsertASNLevel3Buffer(TempASNLevel3Line, ASNLevel3Line, ItemNo, ItemGTIN, ItemConfirmedQuantity, ItemReceivedQuantity, TempASNLevel3LineNo);
                    END;

                    ItemNo := ASNLevel3Line."Level 3 Code";
                    ItemGTIN := ASNLevel3Line.GTIN;
                    ItemConfirmedQuantity := ASNLevel3Line.Quantity;
                    ItemReceivedQuantity := ASNLevel3Line."Quantity Received";

                END ELSE BEGIN

                    ItemConfirmedQuantity += ASNLevel3Line.Quantity;
                    ItemReceivedQuantity += ASNLevel3Line."Quantity Received";

                END;
            UNTIL ASNLevel3Line.Next() = 0;

        InsertASNLevel3Buffer(TempASNLevel3Line, ASNLevel3Line, ItemNo, ItemGTIN, ItemConfirmedQuantity, ItemReceivedQuantity, TempASNLevel3LineNo + 10000);

        TempASNLevel3Line.Reset();
        IF TempASNLevel3Line.FindSet() then
            REPEAT
                IF TempASNLevel3Line."Quantity Received" < TempASNLevel3Line.Quantity THEN BEGIN
                    PurchLine.Reset();
                    PurchLine.SETRANGE("Document Type", PurchLine."Document Type"::Order);
                    PurchLine.SETRANGE("Document No.", ASNHeader."Purchase Order No.");
                    PurchLine.SETRANGE(Type, PurchLine.Type::Item);
                    //Legacy Item No.
                    //PurchLine.SETFILTER("No.", TempASNLevel3Line."Level 3 Code");
                    PurchLine.SetFilter("GXL Legacy Item No.", TempASNLevel3Line."Level 3 Code");
                    IF PurchLine.FindFirst() THEN BEGIN
                        IF NOT BoolDiscrepancy THEN
                            BoolDiscrepancy := TRUE;
                        IF Vendor."GXL Ullaged Supplier" = Vendor."GXL Ullaged Supplier"::Ullaged THEN BEGIN
                            ClaimEntryLineNo += 10000;

                            CreateEDIClaimEntry(PurchLine, TempASNLevel3Line, ClaimEntryLineNo);
                        END ELSE BEGIN
                            PurchLine.VALIDATE("Qty. to Receive", TempASNLevel3Line."Quantity Received");
                            PurchLine.MODIFY(TRUE);
                        END;
                    END;
                END;
            UNTIL TempASNLevel3Line.Next() = 0;

        EXIT(BoolDiscrepancy);
    end;

    local procedure DeleteEDIClaimEntry()
    var
        EDIClaimEntry: Record "GXL EDI Claim Entry";
    begin
        EDIClaimEntry.Reset();
        EDIClaimEntry.SETRANGE("ASN Document No.", ASNHeader."No.");
        EDIClaimEntry.SETRANGE("ASN Document Type", ASNHeader."Document Type");
        EDIClaimEntry.SETRANGE("Purchase Order No.", ASNHeader."Purchase Order No.");
        IF NOT EDIClaimEntry.IsEmpty() THEN
            EDIClaimEntry.DELETEALL();
    end;

    local procedure CreateEDIClaimEntry(PurchLine: Record "Purchase Line"; var InputTempASNLevel3Line: Record "GXL ASN Level 3 Line" temporary; LineNo: Integer)
    var
        EDIClaimEntry: Record "GXL EDI Claim Entry";
    begin
        EDIClaimEntry.Reset();
        EDIClaimEntry.Init();
        EDIClaimEntry."ASN Document No." := ASNHeader."No.";
        EDIClaimEntry."ASN Document Type" := ASNHeader."Document Type";
        EDIClaimEntry."Purchase Order No." := PurchLine."Document No.";
        EDIClaimEntry."Line No." := LineNo;
        EDIClaimEntry."Item No." := PurchLine."No.";
        EDIClaimEntry.GTIN := InputTempASNLevel3Line.GTIN;
        EDIClaimEntry."Confirmed Quantity" := PurchLine."GXL Confirmed Quantity";
        EDIClaimEntry."Scanned Quantity" := InputTempASNLevel3Line."Quantity Received";
        EDIClaimEntry."Purchase Order Line No." := PurchLine."Line No.";
        EDIClaimEntry.Status := EDIClaimEntry.Status::Open;
        EDIClaimEntry.INSERT(TRUE);
    end;

    local procedure PostPurchaseReceipt()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchPost: Codeunit "Purch.-Post";
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, ASNHeader."Purchase Order No.");
        IF ASNHeader."Received from PDA" <> 0DT THEN BEGIN
            PurchaseHeader.VALIDATE("Posting Date", DT2DATE(ASNHeader."Received from PDA"));
            PurchaseHeader.MODIFY(TRUE);
        END;

        PurchaseHeader.Receive := TRUE;
        PurchaseHeader.Invoice := FALSE;
        //PS-2046
        PurchaseHeader."GXL MIM User ID" := ASNHeader."MIM User ID";
        //PS-2046-

        IF ASNHeader."EDI Type" = ASNHeader."EDI Type"::"P2P Contingency" THEN BEGIN
            IF ASNHeader."Supplier Reference Date" <> 0D THEN BEGIN
                PurchaseHeader.VALIDATE("Posting Date", ASNHeader."Supplier Reference Date");
                PurchaseHeader.MODIFY(TRUE);
            END;

            //PurchPost.SetPDAReceiving; // TODO
        END;

        PurchPost.RUN(PurchaseHeader);

    end;

    local procedure InsertASNLevel3Buffer(var TempASNLevel3Line: Record "GXL ASN Level 3 Line" temporary; InputASNLevel3Line: Record "GXL ASN Level 3 Line"; InputItemNo: Code[20]; InputItemGTIN: Code[50]; InputConfirmedQuantity: Decimal; InputReceivedQuantity: Decimal; InputTempASNLevel3LineNo: Integer)
    begin
        TempASNLevel3Line.INIT();

        TempASNLevel3Line.TRANSFERFIELDS(InputASNLevel3Line);

        TempASNLevel3Line."Line No." := InputTempASNLevel3LineNo;

        TempASNLevel3Line."Level 3 Code" := InputItemNo;
        TempASNLevel3Line.GTIN := InputItemGTIN;
        TempASNLevel3Line.Quantity := InputConfirmedQuantity;
        TempASNLevel3Line."Quantity Received" := InputReceivedQuantity;

        TempASNLevel3Line.INSERT();
    end;
}

