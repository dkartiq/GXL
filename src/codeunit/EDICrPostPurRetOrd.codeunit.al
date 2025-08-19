codeunit 50366 "GXL EDI-Cr+Post Pur. Ret. Ord."
{
    TableNo = "GXL ASN Header";

    trigger OnRun()
    begin
        CASE ProcessWhich OF
            ProcessWhich::"Create Return Order":
                CreateReturnOrder(Rec);
            ProcessWhich::"Apply Return Order":
                ApplyReturnOrder(Rec);
            ProcessWhich::"Post Return Shipment":
                PostReturnShipment(Rec);
            ProcessWhich::"Post Return Credit":
                PostReturnCredit(Rec);
        END;
    end;

    var
        //LastPostedDocumentNo: Code[20];
        ProcessWhich: Option ,"Create Return Order","Apply Return Order","Post Return Shipment","Post Return Credit";

    [Scope('OnPrem')]
    procedure SetEDIOptions(NewProcessWhich: Option ,"Create Return Order","Apply Return Order","Post Return Shipment","Post Return Credit")
    begin
        ProcessWhich := NewProcessWhich;
    end;

    /*
    [Scope('OnPrem')]
    procedure GetLastPostedDocumentNo(): Code[20]
    begin
        EXIT(LastPostedDocumentNo);
    end;
    */

    local procedure CreateReturnOrder(ASNHeader: Record "GXL ASN Header")
    var
        EDIClaimEntry: Record "GXL EDI Claim Entry";
        IntegrationSetup: Record "GXL Integration Setup";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLines: Record "Purchase Line";
        PurchaseLinesRelated: Record "Purchase Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        GXLUtils: Codeunit "GXL Misc. Utilities";
        ClaimMgt: Codeunit "GXL Claim Management";
        NextCRMemoNo: Code[30];
    begin
        EDIClaimEntry.SETRANGE("ASN Document No.", ASNHeader."No.");
        EDIClaimEntry.SETRANGE("ASN Document Type", ASNHeader."Document Type");
        IF EDIClaimEntry.FindFirst() THEN BEGIN
            //Create Purchase Return Order
            IntegrationSetup.Get();
            PurchaseHeader.INIT();
            PurchaseHeader.VALIDATE("No. Series", IntegrationSetup."EDI Return Order No. Series");
            PurchaseHeader."No." := NoSeriesMgt.GetNextNo(IntegrationSetup."EDI Return Order No. Series", 0D, TRUE);
            PurchaseHeader.VALIDATE("Document Type", PurchaseHeader."Document Type"::"Return Order");
            PurchaseHeader.INSERT(TRUE);
            PurchaseHeader.VALIDATE("Buy-from Vendor No.", IntegrationSetup."EDI Return Order Vendor No.");
            //PS-2613 +
            //Force so Location Code and Store No. can be populated correctly
            PurchaseHeader."LSC Store No." := '';
            //PS-2613 -
            PurchaseHeader.VALIDATE("Location Code", ASNHeader."Ship-To Code");
            PurchaseHeader.VALIDATE("Posting Date", ASNHeader."Supplier Reference Date");

            //PS-2638 +
            // won't work if return order was not posted in sequence
            // NextCRMemoNo := ASNHeader."Purchase Order No." + '_000';
            // NextCRMemoNo := GXLUtils.GetNextVendorCRMemoNoPH(NextCRMemoNo, IntegrationSetup."EDI Return Order Vendor No.");
            // NextCRMemoNo := GXLUtils.GetNextVendorCRMemoNoVLE(NextCRMemoNo, IntegrationSetup."EDI Return Order Vendor No.");
            NextCRMemoNo := ClaimMgt.GetNextVendorCRMemoNo(ASNHeader."Purchase Order No.", PurchaseHeader."Pay-to Vendor No.");
            //PS-2638 -
            PurchaseHeader.VALIDATE("Vendor Cr. Memo No.", NextCRMemoNo);

            //TODO: Order Status - create Claim document - probably it is not required as only purchase return order or credit note is created
            PurchaseHeader.VALIDATE("GXL Order Status", PurchaseHeader."GXL Order Status"::New);
            PurchaseHeader.VALIDATE("Bal. Account Type", IntegrationSetup."EDI Ret. Order Bal. Acc. Type");
            PurchaseHeader.VALIDATE("Bal. Account No.", IntegrationSetup."EDI Ret. Order Bal. Acc. No.");
            PurchaseHeader.VALIDATE("Reason Code", IntegrationSetup."EDI Return Order Reason Code");
            // >> HP-2139
            /*
            //PS-2613 +
            //Revalidate dimensions to activate store dimension from LS event subs
            //It is LS bug as it should have called CreateDim on validating Location or Store
            PurchaseHeader.CreateDim(
                Database::Vendor, PurchaseHeader."Pay-to Vendor No.",
                Database::"Salesperson/Purchaser", PurchaseHeader."Purchaser Code",
                Database::Campaign, PurchaseHeader."Campaign No.",
                Database::"Responsibility Center", PurchaseHeader."Responsibility Center");
            //PS-2613 -
            */
            // << HP-2139

            PurchaseHeader."GXL MIM User ID" := ASNHeader."MIM User ID"; //PS-2565 Missing MIM User ID +
            PurchaseHeader.MODIFY(TRUE);

            REPEAT
                //Create Lines
                IF PurchaseLinesRelated.GET(PurchaseLinesRelated."Document Type"::Order, EDIClaimEntry."Purchase Order No.", EDIClaimEntry."Purchase Order Line No.") THEN BEGIN
                    PurchaseLines.INIT();
                    PurchaseLines.VALIDATE("Document Type", PurchaseLines."Document Type"::"Return Order");
                    PurchaseLines.VALIDATE("Document No.", PurchaseHeader."No.");
                    PurchaseLines.VALIDATE("Line No.", PurchaseLinesRelated."Line No."); //LineNo might have to come from associated pl
                    PurchaseLines.INSERT(TRUE);
                    PurchaseLines.VALIDATE(Type, PurchaseLines.Type::Item);
                    PurchaseLines.VALIDATE("No.", PurchaseLinesRelated."No."); //check associated asn level 3
                    PurchaseLines.VALIDATE("Unit of Measure Code", PurchaseLinesRelated."Unit of Measure Code");
                    PurchaseLines.VALIDATE(Quantity, EDIClaimEntry."Confirmed Quantity" - EDIClaimEntry."Scanned Quantity");
                    PurchaseLines.VALIDATE("Direct Unit Cost", PurchaseLinesRelated."Direct Unit Cost");
                    IF PurchaseLines."VAT Prod. Posting Group" <> PurchaseLinesRelated."VAT Prod. Posting Group" THEN
                        PurchaseLines.VALIDATE("VAT Prod. Posting Group", PurchaseLinesRelated."VAT Prod. Posting Group");
                    PurchaseLines.MODIFY(TRUE);
                    EDIClaimEntry.VALIDATE("Claim Document No.", PurchaseLines."Document No.");
                    EDIClaimEntry.VALIDATE("Claim Document Line No.", PurchaseLines."Line No.");
                    EDIClaimEntry.MODIFY(TRUE);
                END;
            UNTIL EDIClaimEntry.Next() = 0;

            //TODO: EDI File Log
            if ASNHeader."EDI File Log Entry No." = 0 then
                ASNHeader.AddEDIFileLog();

            ASNHeader.VALIDATE("Claim Document No.", PurchaseHeader."No.");
            ASNHeader.VALIDATE(Status, ASNHeader.Status::"Return Order Created");
            ASNHeader.MODIFY(TRUE);
        END;
    end;

    local procedure ApplyReturnOrder(ASNHeader: Record "GXL ASN Header")
    var
        EDIClaimEntry: Record "GXL EDI Claim Entry";
        PurchaseLines: Record "Purchase Line";
    begin
        EDIClaimEntry.SETRANGE("ASN Document No.", ASNHeader."No.");
        EDIClaimEntry.SETRANGE("ASN Document Type", ASNHeader."Document Type");
        IF EDIClaimEntry.FindSet() THEN
            REPEAT
                PurchaseLines.SETRANGE("Document Type", PurchaseLines."Document Type"::"Return Order");
                PurchaseLines.SETRANGE("Document No.", EDIClaimEntry."Claim Document No.");
                PurchaseLines.SETRANGE("Line No.", EDIClaimEntry."Claim Document Line No.");
                IF PurchaseLines.FindSet() THEN
                    REPEAT
                        PurchaseLines.VALIDATE("Appl.-to Item Entry", EDIClaimEntry."Receipt Item Ledger Entry No.");
                        PurchaseLines.MODIFY(TRUE);

                        //TODO: EDI File Log
                        if ASNHeader."EDI File Log Entry No." = 0 then
                            ASNHeader.AddEDIFileLog();

                        ASNHeader.VALIDATE(Status, ASNHeader.Status::"Return Order Applied");
                        ASNHeader.MODIFY(TRUE);
                    UNTIL PurchaseLines.Next() = 0;
            UNTIL EDIClaimEntry.Next() = 0;
    end;

    local procedure PostReturnShipment(ASNHeader: Record "GXL ASN Header")
    var
        PurchaseHeader: Record "Purchase Header";
        EDIClaimEntry: Record "GXL EDI Claim Entry";
    begin
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::"Return Order");
        PurchaseHeader.SETRANGE("No.", ASNHeader."Claim Document No.");
        IF PurchaseHeader.FindFirst() THEN BEGIN
            PurchaseHeader.Ship := TRUE;
            //PS-2046+
            PurchaseHeader."GXL MIM User ID" := ASNHeader."MIM User ID";
            //PS-2046-
            CODEUNIT.RUN(CODEUNIT::"Purch.-Post", PurchaseHeader);

            EDIClaimEntry.SETRANGE("ASN Document No.", ASNHeader."No.");
            EDIClaimEntry.SETRANGE("ASN Document Type", ASNHeader."Document Type");
            IF EDIClaimEntry.FindSet() THEN
                REPEAT
                    EDIClaimEntry.VALIDATE("Posted Return Shipment No.", PurchaseHeader."Last Return Shipment No.");
                    EDIClaimEntry.MODIFY(TRUE);
                UNTIL EDIClaimEntry.Next() = 0;

            //TODO: EDI File Log
            if ASNHeader."EDI File Log Entry No." = 0 then
                ASNHeader.AddEDIFileLog();

            ASNHeader.VALIDATE(Status, ASNHeader.Status::"Return Shipment Posted");
            ASNHeader.MODIFY(TRUE);
        END;
    end;

    local procedure PostReturnCredit(ASNHeader: Record "GXL ASN Header")
    var
        PurchaseHeader: Record "Purchase Header";
        EDIClaimEntry: Record "GXL EDI Claim Entry";
    begin
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::"Return Order");
        PurchaseHeader.SETRANGE("No.", ASNHeader."Claim Document No.");
        IF PurchaseHeader.FindFirst() THEN BEGIN
            PurchaseHeader.Invoice := TRUE;
            //PS-2046+
            PurchaseHeader."GXL MIM User ID" := ASNHeader."MIM User ID";
            //PS-2046-
            CODEUNIT.RUN(CODEUNIT::"Purch.-Post", PurchaseHeader);

            EDIClaimEntry.SETRANGE("ASN Document No.", ASNHeader."No.");
            EDIClaimEntry.SETRANGE("ASN Document Type", ASNHeader."Document Type");
            IF EDIClaimEntry.FindSet() THEN
                REPEAT
                    EDIClaimEntry.VALIDATE("Posted Return Credit No.", PurchaseHeader."Last Posting No.");
                    EDIClaimEntry.MODIFY(TRUE);
                UNTIL EDIClaimEntry.Next() = 0;

            //TODO: EDI File Log
            if ASNHeader."EDI File Log Entry No." = 0 then
                ASNHeader.AddEDIFileLog();

            ASNHeader.VALIDATE("Claim Credit Memo No.", PurchaseHeader."Last Posting No.");
            ASNHeader.MODIFY(TRUE);

        END;
    end;
}

