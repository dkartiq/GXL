//<Summary>
//Create ASN Header and Lines for P2P and P2P Contingency purchase orders from a PDA-PL Receive Buffer record
//For P2P Contigency, ASN Header status is set to Scanned, the validation process will be skipped
//For P2P, ASN header status is set to Scanned, this type of ASN needs to go through the validation process
//Currently, only P2P Contingency purchase order is used in this codeunit
//</Summary>
codeunit 50384 "GXL P2P-Create ASN"
{
    TableNo = "GXL PDA-PL Receive Buffer";

    trigger OnRun()
    begin
        PDAPLReceiveBuffer := Rec;
        PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, PDAPLReceiveBuffer."Document No.");
        Location.GET(PurchaseHeader."Location Code");
        CreateASNHeader();
        CreateASNScanLogHeader();
        LineNo := 0;
        CreateASNItemLine();
        IF TotalQuantity <> 0 THEN BEGIN
            ASNLevel1.Quantity := TotalQuantity;
            ASNLevel1.Modify();
            ASNLevel1Log.Quantity := TotalQuantity;
            ASNLevel1Log.Modify();
            ASNHeader."Total Items" := TotalQuantity;
            ASNHeader.Modify();
        END;
        UpdateLine(PDAPLReceiveBuffer, PDAPLReceiveBuffer.Status::Processed, '', PurchaseHeader."Buy-from Vendor No.", EDIFileLogEntryNo, '');
    end;

    var
        PurchaseHeader: Record "Purchase Header";
        EDISetup: Record "GXL Integration Setup";
        ASNHeader: Record "GXL ASN Header";
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        ASNLevel1Log: Record "GXL ASN Level 1 Line Scan Log";
        ASNLevel3Log: Record "GXL ASN Level 3 Line Scan Log";
        ASNLevel1: Record "GXL ASN Level 1 Line";
        ASNLevel3: Record "GXL ASN Level 3 Line";
        ASNHeaderLog: Record "GXL ASN Header Scan Log";
        ASNLevel2: Record "GXL ASN Level 2 Line";
        ASNLevel2Log: Record "GXL ASN Level 2 Line Scan Log";
        Location: Record Location;
        EDIFileLogEntryNo: Integer;
        LineNo: Integer;
        TotalQuantity: Decimal;


    [Scope('OnPrem')]
    procedure SetOption(InputEDILogEntryNo: Integer)
    begin
        EDIFileLogEntryNo := InputEDILogEntryNo;
    end;

    [Scope('OnPrem')]
    procedure CreateASNHeader()
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
    begin
        EDISetup.GET();
        ASNHeader.Init();
        ASNHeader."Document Type" := ASNHeader."Document Type"::Purchase;
        ASNHeader."No." := NoSeriesMgt.GetNextNo(EDISetup."P2P Contingency ASN Nos.", 0D, TRUE);
        ASNHeader."Supplier No." := PurchaseHeader."Buy-from Vendor No.";
        ASNHeader."Purchase Order No." := PurchaseHeader."No.";
        ASNHeader."Total Pallets" := 1;
        IF PurchaseHeader."GXL EDI Vendor Type" = PurchaseHeader."GXL EDI Vendor Type"::"Point 2 Point Contingency" THEN
            ASNHeader.Status := ASNHeader.Status::Scanned
        ELSE
            ASNHeader.Status := ASNHeader.Status::Processed;
        ASNHeader."EDI File Log Entry No." := EDIFileLogEntryNo;
        ASNHeader."EDI Type" := ASNHeader."EDI Type"::"P2P Contingency";
        ASNHeader."Ship-To Code" := PurchaseHeader."Location Code";
        ASNHeader."Ship-for Code" := PurchaseHeader."Location Code";
        ASNHeader."Expected Receipt Date" := PurchaseHeader."Expected Receipt Date";
        ASNHeader."Supplier Reference Date" := DT2DATE(PDAPLReceiveBuffer."Received from PDA");
        //PS-2046+
        ASNHeader."MIM User ID" := PDAPLReceiveBuffer."MIM User ID";
        //PS-2046-
        ASNHeader.Insert();

        ASNLevel1.Init();
        ASNLevel1."Document Type" := ASNHeader."Document Type";
        ASNLevel1."Document No." := ASNHeader."No.";
        ASNLevel1."Line No." := 10000;
        ASNLevel1."Level 1 Type" := ASNLevel1."Level 1 Type"::Pallet;
        ASNLevel1.Status := ASNHeader.Status;
        ASNLevel1.Insert();
    end;

    local procedure CreateASNItemLine()
    var
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        PurchaseLine: Record "Purchase Line";
        ReceivedQty: Decimal;
    begin
        PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
        PurchaseLine.SETFILTER(Quantity, '>%1', 0);
        IF PurchaseLine.FindSet() THEN
            REPEAT
                LineNo += 10000;
                ReceivedQty := 0;
                IF PDAPLReceiveBuffer."Receipt Type" = PDAPLReceiveBuffer."Receipt Type"::Full THEN
                    ReceivedQty := PurchaseLine."Qty. to Receive"
                ELSE BEGIN
                    PDAPLReceiveBuffer2.Reset();
                    PDAPLReceiveBuffer2.SetCurrentKey("Document No.", "Line No.");
                    PDAPLReceiveBuffer2.SETRANGE("Document No.", PurchaseHeader."No.");
                    PDAPLReceiveBuffer2.SETRANGE("Line No.", PurchaseLine."Line No.");
                    IF PDAPLReceiveBuffer2.FindFirst() THEN BEGIN
                        ReceivedQty := PDAPLReceiveBuffer2.QtyToReceive;
                    END;
                END;

                //Legacy Item
                // IF PurchaseHeader."GXL EDI Vendor Type" = PurchaseHeader."GXL EDI Vendor Type"::"Point 2 Point Contingency" THEN
                //     InsertASNItemLine(PurchaseLine."No.", PurchaseLine."Qty. to Receive", ReceivedQty)  // PurchaseLine."Qty. to Receive" has been updated with ASN.Shipped Quantity (x50047) on ASN import
                // ELSE
                //     InsertASNItemLine(PurchaseLine."No.", PurchaseLine.Quantity, 0);

                // InsertASNItemLineLog(PurchaseLine."No.", PurchaseLine.Quantity, ReceivedQty);
                IF PurchaseHeader."GXL EDI Vendor Type" = PurchaseHeader."GXL EDI Vendor Type"::"Point 2 Point Contingency" THEN
                    InsertASNItemLine(PurchaseLine."No.", PurchaseLine."Unit of Measure Code", PurchaseLine."GXL Legacy Item No.", PurchaseLine."Qty. to Receive", ReceivedQty)  // PurchaseLine."Qty. to Receive" has been updated with ASN.Shipped Quantity (x50047) on ASN import
                ELSE
                    InsertASNItemLine(PurchaseLine."No.", PurchaseLine."Unit of Measure Code", PurchaseLine."GXL Legacy Item No.", PurchaseLine.Quantity, 0);

                InsertASNItemLineLog(PurchaseLine."GXL Legacy Item No.", PurchaseLine.Quantity, ReceivedQty);
            UNTIL PurchaseLine.Next() = 0;

    end;

    local procedure InsertASNItemLine(ItemNo: Code[20]; UOMCode: Code[10]; ILC: Code[20]; QuantityShipped: Decimal; QuantityReceived: Decimal)
    begin
        ASNLevel2.Init();
        ASNLevel2."Document Type" := ASNHeader."Document Type";
        ASNLevel2."Document No." := ASNHeader."No.";
        ASNLevel2."Line No." := LineNo;
        ASNLevel2."Level 1 Line No." := 10000;
        ASNLevel2."Level 2 Type" := ASNLevel2."Level 2 Type"::Box;
        ASNLevel2.Status := ASNHeader.Status;
        ASNLevel2.Insert();

        ASNLevel3.Init();
        ASNLevel3."Document Type" := ASNHeader."Document Type";
        ASNLevel3."Document No." := ASNHeader."No.";
        ASNLevel3."Line No." := LineNo;
        ASNLevel3."Level 3 Type" := ASNLevel3."Level 3 Type"::Item;
        //Legacy Item
        //ASNLevel3."Level 3 Code" := ItemNo;
        ASNLevel3."Level 3 Code" := ILC;
        ASNLevel3."Item No." := ItemNo;
        ASNLevel3."Unit of Measure Code" := UOMCode;

        ASNLevel3."Level 1 Line No." := 10000;
        ASNLevel3.Quantity := QuantityShipped;
        ASNLevel3."Quantity Received" := QuantityReceived;
        ASNLevel3.Status := ASNHeader.Status;
        ASNLevel3."Loose Item Box Line" := LineNo;

        ASNLevel3.Insert();
        TotalQuantity += QuantityShipped;
    end;

    [Scope('OnPrem')]
    procedure CreateASNScanLogHeader()
    begin
        ASNHeaderLog.Init();
        ASNHeaderLog."Document Type" := ASNHeader."Document Type";
        ASNHeaderLog."No." := ASNHeader."No.";
        ASNHeaderLog."Purchase Order No." := ASNHeader."Purchase Order No.";
        ASNHeaderLog."EDI Type" := ASNHeader."EDI Type";
        ASNHeaderLog."Entry No." := 0;
        //PS-2046+
        ASNHeaderLog."MIM User ID" := ASNHeader."MIM User ID";
        //PS-2046-
        ASNHeaderLog.Insert();

        ASNLevel1Log.Init();
        ASNLevel1Log."Document Type" := ASNHeader."Document Type";
        ASNLevel1Log."Document No." := ASNHeader."No.";
        ASNLevel1Log."Line No." := 10000;
        ASNLevel1Log."Entry No." := 0;
        ASNLevel1Log.Insert();
    end;

    local procedure InsertASNItemLineLog(ItemNo: Code[20]; OrderQuantity: Decimal; Quantity: Decimal)
    begin
        ASNLevel2Log.Init();
        ASNLevel2Log."Document Type" := ASNHeader."Document Type";
        ASNLevel2Log."Document No." := ASNHeader."No.";
        ASNLevel2Log."Line No." := LineNo;
        ASNLevel2Log."Level 1 Line No." := 10000;
        ASNLevel2Log."Entry No." := 0;
        ASNLevel2Log.Insert();

        ASNLevel3Log.Init();
        ASNLevel3Log."Document Type" := ASNHeader."Document Type";
        ASNLevel3Log."Document No." := ASNHeader."No.";
        ASNLevel3Log."Line No." := LineNo;
        ASNLevel3Log."Level 1 Line No." := 10000;
        ASNLevel3Log."Level 3 Code" := ItemNo;
        ASNLevel3Log.Quantity := OrderQuantity;
        ASNLevel3Log."Quantity Received" := Quantity;
        ASNLevel3Log."Entry No." := 0;
        ASNLevel3Log.Insert();
    end;

    [Scope('OnPrem')]
    procedure UpdateLine(InputPDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; InputStatus: Enum "GXL PDA-PL Receive Status"; ErrorText: Text; VendorNo: Code[20]; EDILogEntryNo: Integer; ErrorCode: Text)
    var
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
    begin
        PDAPLReceiveBuffer2.Reset();
        PDAPLReceiveBuffer2.SetCurrentKey("Document No.", "Line No.");
        PDAPLReceiveBuffer2.SETRANGE("Document No.", InputPDAPLReceiveBuffer."Document No.");
        IF PDAPLReceiveBuffer2.FindSet() THEN
            REPEAT
                PDAPLReceiveBuffer2.Errored := InputStatus <> InputStatus::Processed;
                PDAPLReceiveBuffer2."Error Code" := COPYSTR(ErrorCode, 1, MAXSTRLEN(PDAPLReceiveBuffer2."Error Code"));
                PDAPLReceiveBuffer2."Error Message" := ErrorText;
                PDAPLReceiveBuffer2.Status := InputStatus;
                PDAPLReceiveBuffer2."Vendor No." := VendorNo;
                PDAPLReceiveBuffer2."EDI Vendor Type" := PDAPLReceiveBuffer2."EDI Vendor Type"::"Point 2 Point Contingency";
                PDAPLReceiveBuffer2.Processed := InputStatus = InputStatus::Processed;
                PDAPLReceiveBuffer2."EDI File Log Entry No." := EDILogEntryNo;
                PDAPLReceiveBuffer2.Modify();
            UNTIL PDAPLReceiveBuffer2.Next() = 0;
    end;
}

