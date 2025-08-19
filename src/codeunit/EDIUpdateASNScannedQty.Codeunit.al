codeunit 50378 "GXL EDI-Update ASN Scanned Qty"
{
    TableNo = "GXL ASN Header Scan Log";

    trigger OnRun()
    var
        ASNHeader: Record "GXL ASN Header";
        ASNLevel1Log: Record "GXL ASN Level 1 Line Scan Log";
        ASNLevel2Log: Record "GXL ASN Level 2 Line Scan Log";
        ASNLevel3Log: Record "GXL ASN Level 3 Line Scan Log";
        ASNLevel1: Record "GXL ASN Level 1 Line";
        ASNLevel2: Record "GXL ASN Level 2 Line";
        ASNLevel3: Record "GXL ASN Level 3 Line";
        PurchHeader: Record "Purchase Header";
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
    begin
        IF Rec."Copied to ASN" THEN
            EXIT;

        ASNHeaderScanLog := Rec;

        ASNHeader.SETRANGE("Document Type", Rec."Document Type");
        ASNHeader.SETRANGE("No.", Rec."No.");
        IF ASNHeader.FINDFIRST() THEN BEGIN
            //If it is "3PL EDI", only "3PL ASN Sent" is accepted
            //Otherwise, only Processed is accepted
            IF (ASNHeader."3PL EDI" = FALSE) AND (ASNHeader.Status <> ASNHeader.Status::Processed) THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, FORMAT(ASNHeader.Status::Processed), ASNHeader."No."));
                EDIErrorMgt.ThrowErrorMessage();
            END ELSE
                IF (ASNHeader."3PL EDI" = TRUE) AND (ASNHeader.Status <> ASNHeader.Status::"3PL ASN Sent") THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, FORMAT(ASNHeader.Status::"3PL ASN Sent"), ASNHeader."No."));
                    EDIErrorMgt.ThrowErrorMessage();
                END;

            //Update ASN1 (Pallet)
            ASNLevel1Log.SETRANGE("Document Type", ASNHeader."Document Type");
            ASNLevel1Log.SETRANGE("Document No.", ASNHeader."No.");
            IF ASNLevel1Log.FINDSET() THEN
                REPEAT
                    ASNLevel1.GET(ASNLevel1Log."Document Type", ASNLevel1Log."Document No.", ASNLevel1Log."Line No.");
                    ASNLevel1.VALIDATE("Quantity Received", ASNLevel1Log."Quantity Received");
                    ASNLevel1.MODIFY(TRUE);
                UNTIL ASNLevel1Log.NEXT() = 0;

            //Update ASN2 (Box)
            ASNLevel2Log.SETRANGE("Document Type", ASNHeader."Document Type");
            ASNLevel2Log.SETRANGE("Document No.", ASNHeader."No.");
            IF ASNLevel2Log.FINDSET() THEN
                REPEAT
                    ASNLevel2.GET(ASNLevel2Log."Document Type", ASNLevel2Log."Document No.", ASNLevel2Log."Line No.");
                    ASNLevel2.VALIDATE("Quantity Received", ASNLevel2Log."Quantity Received");

                    //Legacy Item
                    if (ASNLevel2.ILC <> '') and (ASNLevel2."Item No." = '') then
                        LegacyItemHelpers.GetItemNoForPurchase(ASNLevel2.ILC, ASNLevel2."Item No.", ASNLevel2."Unit of Measure Code");

                    ASNLevel2.MODIFY(TRUE);
                UNTIL ASNLevel2Log.NEXT() = 0;

            //Update ASN3 (item)
            ASNLevel3Log.SETRANGE("Document Type", ASNHeader."Document Type");
            ASNLevel3Log.SETRANGE("Document No.", ASNHeader."No.");
            IF ASNLevel3Log.FINDSET() THEN
                REPEAT
                    ASNLevel3.GET(ASNLevel3Log."Document Type", ASNLevel3Log."Document No.", ASNLevel3Log."Line No.");
                    ASNLevel3.VALIDATE("Quantity Received", ASNLevel3Log."Quantity Received");

                    //Legacy Item
                    if (ASNLevel3."Level 3 Type" = ASNLevel3."Level 3 Type"::Item) and (ASNLevel3."Level 3 Code" <> '') and (ASNLevel3."Item No." = '') then
                        LegacyItemHelpers.GetItemNoForPurchase(ASNLevel3."Level 3 Code", ASNLevel3."Item No.", ASNLevel3."Unit of Measure Code");

                    ASNLevel3.MODIFY(TRUE);
                UNTIL ASNLevel3Log.NEXT() = 0;

            //TODO: EDI File Log
            if ASNHeader."EDI File Log Entry No." = 0 then
                ASNHeader.AddEDIFileLog();

            ASNHeader.VALIDATE(Status, ASNHeader.Status::Scanned);
            ASNHeader."Received from PDA" := CURRENTDATETIME();

            //PS-2046+
            ASNHeader."MIM User ID" := ASNHeaderScanLog."MIM User ID";
            //PS-2046-

            ASNHeader.MODIFY(TRUE);
            ASNHeaderScanLog.VALIDATE("Copied to ASN", TRUE);
            ASNHeaderScanLog.MODIFY(TRUE);

            IF ASNHeader."3PL EDI" THEN BEGIN
                PurchHeader.RESET();
                IF PurchHeader.GET(PurchHeader."Document Type"::Order, ASNHeader."Purchase Order No.") THEN BEGIN
                    if not PurchHeader."GXL 3PL File Receive" then begin
                        PurchHeader."GXL 3PL File Receive" := TRUE;
                        PurchHeader.MODIFY();
                    end;
                END;
            END;
            Rec := ASNHeaderScanLog;

            COMMIT();

            IF EDIValidateScannedASN.RUN(ASNHeader) THEN;

        END;
    end;

    var
        ASNHeaderScanLog: Record "GXL ASN Header Scan Log";
        EDIValidateScannedASN: Codeunit "GXL EDI-Validate Scanned ASN";
        Text000Txt: Label 'Document Type must be %1 for ASN %2 Before Scanned Qty can be updated';
}

