// Copy of Report report 50351 "GXL Import Location Files" modified for API

///<Summary>
///This report to be added to job queue
///Import files from 3PL warehouse locations
///Files are in the location folder "Inbound File Path"
///The file may include purchase order receive, transfer order shipment, inventory adjustment or just update SOH Quantity fields in SKU
///  If the xmlport is 50097 (SOH update) then the xmlport will update SOH values
///  Otherwise, data will be created in "WH-Message Lines" for Invt. Adj, Purchase, Transfer
///  Currently there are 4 xmlports 
///  50097 - update SOH fields in SKUs
///  50094 - inventory adj.
///  50270 - purchase order
///  50271 - transfer order
///
///After import, the WH-Message Lines will be processed according to the ImportType
///</Summary>

report 50029 "Import Location Files for API"
{
    ApplicationArea = All;
    Caption = 'Import Location Files for API';
    ProcessingOnly = true;
    UsageCategory = Tasks;

    dataset
    {
        /*
        dataitem(Location; Location)
        {
            //DataItemTableView = WHERE("GXL 3PL Warehouse" = FILTER(true), "GXL Inbound File Path" = FILTER(<> ''));
            DataItemTableView = WHERE("GXL 3PL Warehouse" = FILTER(true));
            RequestFilterFields = "Code";

            trigger OnAfterGetRecord()
            var
                JobQueueEntryMgt: Codeunit "GXL Job Queue Entry Management";
                JobQueueEntrySendEmail: Codeunit "GXL Job Queue Entry-Send Email";
                RecRef: RecordRef;
                newFileName: Text;
                ArchiveDirectory: Text;
                ErrorDirectory: Text;
                ASN3PLFiles: Text[50];
            begin
                IntegrationSetup.TestField("Date Format");
                IntegrationSetup.TestField("Time Format");

                CheckDirectory(Location."GXL Inbound File Path");
                ArchiveDirectory := '';
                ErrorDirectory := '';

                IF "GXL EDI Type" = "GXL EDI Type"::" " THEN BEGIN
                    IntegrationSetup.TestField("3PL Archive Directory");
                    IntegrationSetup.TestField("3PL Error Directory");
                    cuWHDATAMGMT.CheckDirectory(IntegrationSetup."3Pl Archive Directory");
                    cuWHDATAMGMT.CheckDirectory(IntegrationSetup."3PL Error Directory");
                    ArchiveDirectory := IntegrationSetup."3Pl Archive Directory";
                    ErrorDirectory := IntegrationSetup."3PL Error Directory";
                END ELSE BEGIN
                    TestField("GXL 3PL Archive File Path");
                    TestField("GXL 3PL Error File Path");
                    cuWHDATAMGMT.CheckDirectory("GXL 3PL Archive File Path");
                    cuWHDATAMGMT.CheckDirectory("GXL 3PL Error File Path");
                    ArchiveDirectory := "GXL 3PL Archive File Path";
                    ErrorDirectory := "GXL 3PL Error File Path";
                END;

                IntegrationSetup.TESTFIELD("ASN File Name Prefix");
                ASN3PLFiles := IntegrationSetup."ASN File Name Prefix" + '*' + FORMAT(Location."GXL Receive File Format");

                _FileDirectory.RESET();
                _FileDirectory.SETRANGE(_FileDirectory.Path, Location."GXL Inbound File Path");
                _FileDirectory.SETRANGE(_FileDirectory."Is a file", TRUE);
                _FileDirectory.SETFILTER(_FileDirectory.Name, '<>%1', ASN3PLFiles);

                IF _FileDirectory.FindSet() THEN
                    REPEAT
                        IF EXISTS(_FileDirectory.Path + _FileDirectory.Name) THEN BEGIN

                            CLEARLASTERROR();
                            newFileName := cuWHDATAMGMT.AddSuffixes(_FileDirectory.Name);
                            ArchiveFile((_FileDirectory.Path + _FileDirectory.Name), ArchiveDirectory + newFileName);
                            ArchiveFile((_FileDirectory.Path + _FileDirectory.Name), ErrorDirectory + newFileName);
                            RecRef.GETTABLE(Location);

                            //ERP-301 +
                            Clear(JobQueueEntryMgt);
                            //ERP-301 -
                            //3PL files
                            JobQueueEntryMgt.SetOptions(1, RecRef, _FileDirectory.Path, _FileDirectory.Name);

                            IF NOT JobQueueEntryMgt.RUN() THEN BEGIN
                                DeleteFile(_FileDirectory.Path + _FileDirectory.Name);
                                DeleteFile(ArchiveDirectory + newFileName);
                                IF NOT ISNULLGUID(JobQueueEntry.ID) THEN BEGIN

                                    //>>upgrade
                                    //JobQueueEntry.SetErrorMessage(GETLASTERRORTEXT());
                                    JobQueueEntry.SetError(GetLastErrorText());
                                    //<<Upgrade
                                    JobQueueEntrySendEmail.SetOptions(1, ErrorDirectory + newFileName, _FileDirectory.Size);
                                    IF JobQueueEntrySendEmail.SendEmail(JobQueueEntry) THEN;

                                END;
                                ERROR(GETLASTERRORTEXT());

                            END ELSE BEGIN
                                DeleteFile(_FileDirectory.Path + _FileDirectory.Name);
                                DeleteFile(ErrorDirectory + newFileName);
                            END;

                        END;
                    UNTIL _FileDirectory.NEXT() = 0;
            end;

            trigger OnPostDataItem()
            var
                JobQueueEntry2: Record "Job Queue Entry";
            begin
                IF JobQueueEntry2.GET(JobQueueEntry.ID) THEN BEGIN
                    JobQueueEntry2."GXL No Email on Error Log" := FALSE;
                    JobQueueEntry2.MODIFY();
                    COMMIT();
                END;
            end;

            trigger OnPreDataItem()
            var
                JobQueueEntry2: Record "Job Queue Entry";
            begin
                IF JobQueueEntry2.GET(JobQueueEntry.ID) THEN BEGIN
                    JobQueueEntry2."GXL No Email on Error Log" := TRUE;
                    JobQueueEntry2.MODIFY();
                    COMMIT();
                END;
            end;
        }
        */

        //Process entries related to Purchase orders
        //TODO: Order Status - WH Message Lines on process after import files
        dataitem("WH Message Lines"; "GXL WH Message Lines")
        {
            DataItemTableView = SORTING("Document No.", "Line No.", "Import Type") WHERE("Error Found" = FILTER(false), Processed = FILTER(false), "Import Type" = FILTER("Purchase Order"));

            trigger OnAfterGetRecord()
            var
                PurchaseHeader: Record "Purchase Header";
                WHMessageLines: Record "GXL WH Message Lines";
                PurchaseLine: Record "Purchase Line";
                PurchaseLine2: Record "Purchase Line";
                Loc: Record Location;
                ASNHeader: Record "GXL ASN Header";
                OldPurchHead: Record "Purchase Header";
                OldPurchLine: Record "Purchase Line";
                ReleasePurchDoc: Codeunit "Release Purchase Document";
                ReceiveAgainstEDIASN: Boolean;
                ASNScanHeaderCreated: Boolean;
                ASNScanLineCreated: Boolean;
                PhysicalReceiptVariance: Decimal;
                LineQtyUpdated: Boolean;
            begin

                TempWHMessageLines.RESET();
                TempWHMessageLines.SETRANGE(TempWHMessageLines."Import Type", TempWHMessageLines."Import Type"::"Purchase Order");
                TempWHMessageLines.SETFILTER("Document No.", "Document No.");
                IF NOT TempWHMessageLines.FindSet() THEN BEGIN
                    TempWHMessageLines.RESET();
                    TempWHMessageLines.INIT();
                    TempWHMessageLines.TRANSFERFIELDS("WH Message Lines");
                    TempWHMessageLines.Insert();

                    PurchaseHeader.RESET();
                    PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
                    PurchaseHeader.SETRANGE("No.", "Document No.");

                    IF NOT PurchaseHeader.FINDFIRST() THEN BEGIN
                        WHMessageLines.RESET();
                        WHMessageLines.SETRANGE("Import Type", "Import Type");
                        WHMessageLines.SETFILTER("Document No.", "Document No.");
                        WHMessageLines.MODIFYALL("Error Found", TRUE);
                        WHMessageLines.MODIFYALL("Error Description", STRSUBSTNO(error2Err, FORMAT("Import Type"), "Document No."));
                        CurrReport.SKIP();
                    END ELSE BEGIN
                        //TODO: Order Status - Closed status is not accepted
                        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Closed THEN BEGIN
                            WHMessageLines.RESET();
                            WHMessageLines.SETRANGE("Import Type", "Import Type");
                            WHMessageLines.SETFILTER("Document No.", "Document No.");
                            WHMessageLines.MODIFYALL(Processed, TRUE);
                            CurrReport.SKIP();
                        END;

                    END;

                END ELSE
                    CurrReport.SKIP();

                BoolErr := FALSE;

                IF (PurchaseHeader."Location Code" <> '') AND
                   (PurchaseHeader."GXL EDI Vendor Type" = PurchaseHeader."GXL EDI Vendor Type"::VAN) AND
                   (Loc.GET(PurchaseHeader."Location Code")) AND
                   (Loc."GXL 3PL Warehouse") AND
                   (Loc."GXL EDI Type" = 0)  // Non-EDI 3PL Warehouse
                THEN BEGIN
                    ReceiveAgainstEDIASN := TRUE;
                    ASNScanHeaderCreated := CreateASNScanLogHeader(PurchaseHeader, ASNHeader);
                END;

                WHMessageLines.RESET();
                WHMessageLines.SETFILTER("Document No.", "Document No.");
                WHMessageLines.SETRANGE("Import Type", "Import Type");
                IF WHMessageLines.FindSet(TRUE) THEN BEGIN
                    OldPurchHead := PurchaseHeader; //ERP-327 +
                    REPEAT
                        LineQtyUpdated := false; //ERP-327 +
                        PhysicalReceiptVariance := 0;

                        PurchaseLine.RESET();
                        IF PurchaseLine.GET(PurchaseLine."Document Type"::Order, PurchaseHeader."No.", WHMessageLines."Line No.") THEN BEGIN
                            //Legacy Item
                            //IF PurchaseLine."No." <> WHMessageLines.GetRealItemNo() THEN BEGIN
                            if PurchaseLine."GXL Legacy Item No." <> WHMessageLines."Item No." then begin
                                WHMessageLines."Error Found" := TRUE;
                                WHMessageLines."Error Description" := STRSUBSTNO(error7Err, FORMAT("Import Type"), "Document No.", WHMessageLines."Line No.", WHMessageLines."Item No.", PurchaseLine."GXL Legacy Item No.");
                                WHMessageLines.MODIFY();
                                BoolErr := TRUE;
                            END ELSE BEGIN
                                //ERP-327 +
                                if (PurchaseLine.Quantity < WHMessageLines."Qty. To Receive") then begin
                                    if PurchaseHeader.Status = PurchaseHeader.Status::Released then begin
                                        PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
                                        ReleasePurchDoc.Reopen(PurchaseHeader);
                                    end;
                                    OldPurchLine := PurchaseLine;
                                    PurchaseLine.Validate(Quantity, WHMessageLines."Qty. To Receive");
                                    if PurchaseLine."Direct Unit Cost" <> OldPurchLine."Direct Unit Cost" then
                                        PurchaseLine.Validate("Direct Unit Cost", OldPurchLine."Direct Unit Cost");
                                    if PurchaseLine."Line Discount %" <> OldPurchLine."Line Discount %" then
                                        PurchaseLine.Validate("Line Discount %", OldPurchLine."Line Discount %");
                                    LineQtyUpdated := true;
                                end;
                                //ERP-327 -

                                IF WHMessageLines."Qty. To Receive" > PurchaseLine."Outstanding Quantity" THEN BEGIN
                                    WHMessageLines."Error Found" := TRUE;
                                    WHMessageLines."Error Description" := STRSUBSTNO(error4Err, "Item No.", FORMAT("Import Type"), "Document No.");
                                    WHMessageLines.MODIFY();
                                    BoolErr := TRUE;
                                END ELSE BEGIN
                                    ASNScanLineCreated := FALSE;

                                    IF ReceiveAgainstEDIASN THEN BEGIN
                                        //ERP-327 +
                                        if LineQtyUpdated then
                                            PurchaseLine.Modify(true);
                                        //ERP-327 -
                                        IF ASNScanHeaderCreated THEN BEGIN
                                            ASNScanLineCreated := InsertASNItemLineLog(ASNHeader, WHMessageLines, PhysicalReceiptVariance);
                                            IF NOT ASNScanLineCreated THEN BEGIN
                                                WHMessageLines."Error Found" := TRUE;
                                                WHMessageLines."Error Description" := Text002Err;
                                                WHMessageLines.MODIFY();
                                            END ELSE BEGIN
                                                IF PhysicalReceiptVariance <> 0 THEN BEGIN  // Received Quantity <> ASN Quantity
                                                    WHMessageLines."Qty. Variance" := PhysicalReceiptVariance;
                                                    WHMessageLines.MODIFY();
                                                END;
                                            END;
                                        END;
                                    END ELSE BEGIN
                                        // Receive against PO (Non-EDI Vendor)
                                        PurchaseLine.VALIDATE("Qty. to Receive", WHMessageLines."Qty. To Receive");
                                        PurchaseLine.VALIDATE("GXL Rec. Variance", WHMessageLines."Qty. Variance");
                                        PurchaseLine."GXL Qty. Variance Reason Code" := WHMessageLines."Reason Code";
                                        PurchaseLine.MODIFY(TRUE);
                                    END;
                                END;
                            END;
                        END ELSE BEGIN
                            WHMessageLines."Error Found" := TRUE;
                            WHMessageLines."Error Description" := STRSUBSTNO(error8Err, WHMessageLines."Line No.", FORMAT("Import Type"), "WH Message Lines"."Document No.");
                            WHMessageLines.MODIFY();
                            BoolErr := TRUE;
                        END;
                        WHMessageLines."Location Code" := PurchaseHeader."Location Code";
                        IF ASNScanLineCreated THEN
                            WHMessageLines.Processed := TRUE;
                        WHMessageLines.MODIFY();

                    UNTIL WHMessageLines.NEXT() = 0;

                    IF BoolErr = TRUE THEN BEGIN
                        WHMessageLines.RESET();
                        WHMessageLines.SETRANGE("Import Type", "Import Type");
                        WHMessageLines.SETFILTER("Document No.", "Document No.");
                        WHMessageLines.MODIFYALL("Error Found", TRUE);
                    END ELSE BEGIN

                        IF NOT ReceiveAgainstEDIASN THEN BEGIN
                            //If the item is not on the ASN then set the Qty. to Receive to zero
                            PurchaseLine.SETRANGE(PurchaseLine."Document Type", PurchaseLine."Document Type"::Order);
                            PurchaseLine.SETRANGE(PurchaseLine."Document No.", PurchaseHeader."No.");
                            PurchaseLine.SETRANGE(PurchaseLine.Type, PurchaseLine.Type::Item);
                            PurchaseLine.SETFILTER("No.", '<>%1', '');
                            PurchaseLine.SETFILTER("Qty. to Receive", '<>%1', 0);
                            IF PurchaseLine.FindSet(TRUE, TRUE) THEN
                                REPEAT
                                    IF NOT WHMessageLines.GET("Document No.", PurchaseLine."Line No.", "Import Type") THEN BEGIN
                                        PurchaseLine2 := PurchaseLine;
                                        PurchaseLine2."GXL Rec. Variance" := PurchaseLine."Qty. to Receive";
                                        PurchaseLine2.VALIDATE("Qty. to Receive", 0);
                                        PurchaseLine2."GXL Qty. Variance Reason Code" := IntegrationSetup."ASN Variance Reason Code";
                                        PurchaseLine2.MODIFY(TRUE);
                                    END;
                                UNTIL PurchaseLine.NEXT() = 0;

                            // Buffer POs for posting receipt
                            TempPurchaseHeader.RESET();
                            TempPurchaseHeader.SETRANGE(TempPurchaseHeader."Document Type", TempPurchaseHeader."Document Type"::Order);
                            TempPurchaseHeader.SETRANGE(TempPurchaseHeader."No.", "WH Message Lines"."Document No.");
                            IF NOT TempPurchaseHeader.FINDFIRST() THEN BEGIN
                                TempPurchaseHeader.INIT();
                                TempPurchaseHeader.TRANSFERFIELDS(PurchaseHeader);
                                TempPurchaseHeader.Insert();
                            END;
                        END;
                    END;

                    //ERP-327 +
                    if (OldPurchHead.Status = OldPurchHead.Status::Released) and (PurchaseHeader.Status <> PurchaseHeader.Status::Released) then begin
                        PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
                        ReleasePurchDoc.Run(PurchaseHeader);
                    end;
                    //ERP-327 -
                END;

            end;

            trigger OnPreDataItem()
            begin
                "WH Message Lines".RESET();
                "WH Message Lines".SETRANGE("Import Type", "WH Message Lines"."Import Type"::"Purchase Order");
                "WH Message Lines".SETRANGE("Error Found", FALSE);
                "WH Message Lines".SETRANGE(Processed, FALSE);
                TempPurchaseHeader.RESET();
                TempPurchaseHeader.DELETEALL();
            end;
        }
        //Transfer Orders
        dataitem("STO Line"; "GXL WH Message Lines")
        {
            DataItemTableView = SORTING("Document No.", "Line No.", "Import Type") WHERE("Error Found" = FILTER(false), Processed = FILTER(false), "Import Type" = FILTER("Transfer Order"));

            trigger OnAfterGetRecord()
            var
                TransferHeader: Record "Transfer Header";
                WHMessageLines: Record "GXL WH Message Lines";
                TransferLine: Record "Transfer Line";
                OldTransHead: Record "Transfer Header";
                ReleaseTransferDoc: Codeunit "Release Transfer Document";
            begin
                TempWHMessageLines.RESET();
                TempWHMessageLines.SETRANGE(TempWHMessageLines."Import Type", TempWHMessageLines."Import Type"::"Transfer Order");
                TempWHMessageLines.SETFILTER("Document No.", "Document No.");
                IF NOT TempWHMessageLines.FindSet() THEN BEGIN
                    TempWHMessageLines.RESET();
                    TempWHMessageLines.INIT();
                    TempWHMessageLines.TRANSFERFIELDS("STO Line");
                    TempWHMessageLines.Insert();

                    TransferHeader.RESET();
                    TransferHeader.SETRANGE("No.", "Document No.");
                    IF NOT TransferHeader.FINDFIRST() THEN BEGIN
                        WHMessageLines.RESET();
                        WHMessageLines.SETRANGE("Import Type", "Import Type");
                        WHMessageLines.SETFILTER("Document No.", "Document No.");
                        WHMessageLines.MODIFYALL("Error Found", TRUE);
                        WHMessageLines.MODIFYALL("Error Description", STRSUBSTNO(error2Err, FORMAT("Import Type"), "Document No."));
                        CurrReport.SKIP();
                    END ELSE BEGIN
                        //TODO: Order Status: Only New, Created or Placed are accepted
                        IF TransferHeader."GXL Order Status" >= TransferHeader."GXL Order Status"::Confirmed THEN BEGIN
                            WHMessageLines.RESET();
                            WHMessageLines.SETRANGE("Import Type", "Import Type");
                            WHMessageLines.SETFILTER("Document No.", "Document No.");
                            WHMessageLines.MODIFYALL(Processed, TRUE);

                            CurrReport.SKIP();
                        END;
                        //TODO: Remove condition on 3PL File Sent as PO is created/sent from NAV13
                        //IF TransferHeader."GXL 3PL File Sent" = FALSE THEN
                        //    CurrReport.SKIP();
                    END;

                END ELSE
                    CurrReport.SKIP();

                BoolErr := FALSE;

                //update qty to ship from the WH Message Lines

                WHMessageLines.RESET();
                WHMessageLines.SETRANGE("Import Type", "Import Type");
                WHMessageLines.SETFILTER("Document No.", "Document No.");
                IF WHMessageLines.FindSet(TRUE) THEN begin
                    //ERP-327 +
                    OldTransHead := TransferHeader;
                    //ERP-327 -
                    REPEAT
                        TransferLine.RESET();
                        IF TransferLine.GET("Document No.", WHMessageLines."Line No.") THEN BEGIN
                            //Legacy item
                            //IF TransferLine."Item No." <> WHMessageLines.GetRealItemNo() THEN BEGIN
                            if TransferLine."GXL Legacy Item No." <> WHMessageLines."Item No." then begin
                                WHMessageLines."Error Found" := TRUE;
                                WHMessageLines."Error Description" := STRSUBSTNO(error7Err, FORMAT("Import Type"), "Document No.", WHMessageLines."Line No.", WHMessageLines."Item No.", TransferLine."GXL Legacy Item No.");
                                WHMessageLines.MODIFY();
                                BoolErr := TRUE;
                            END ELSE BEGIN
                                //ERP-327 +
                                if TransferLine.Quantity < WHMessageLines."Qty. To Receive" then begin
                                    if TransferHeader.Status = TransferHeader.Status::Released then begin
                                        TransferHeader.Get(TransferHeader."No.");
                                        ReleaseTransferDoc.Reopen(TransferHeader);
                                    end;
                                    TransferLine.Get(TransferLine."Document No.", TransferLine."Line No.");
                                    TransferLine.Validate(Quantity, WHMessageLines."Qty. To Receive");
                                end;
                                //ERP-327 -
                                IF WHMessageLines."Qty. To Receive" > TransferLine."Outstanding Quantity" THEN BEGIN
                                    WHMessageLines."Error Found" := TRUE;
                                    WHMessageLines."Error Description" := STRSUBSTNO(error4Err, WHMessageLines."Item No.", FORMAT("Import Type"), "Document No.");
                                    WHMessageLines.MODIFY();
                                    BoolErr := TRUE;
                                END ELSE BEGIN
                                    TransferLine.VALIDATE("Qty. to Ship", WHMessageLines."Qty. To Receive");
                                    TransferLine.VALIDATE("GXL Qty Variance", WHMessageLines."Qty. Variance");
                                    TransferLine."GXL Qty. Variance Resaon Code" := WHMessageLines."Reason Code";
                                    TransferLine.MODIFY(TRUE);
                                END;
                            END;
                        END ELSE BEGIN
                            WHMessageLines."Error Found" := TRUE;
                            WHMessageLines."Error Description" := STRSUBSTNO(error8Err, WHMessageLines."Line No.", FORMAT("Import Type"), "Document No.");
                            WHMessageLines.MODIFY();
                            BoolErr := TRUE;
                        END;
                    UNTIL WHMessageLines.NEXT() = 0;
                end;

                IF BoolErr = TRUE THEN BEGIN
                    WHMessageLines.RESET();
                    WHMessageLines.SETRANGE("Import Type", "Import Type");
                    WHMessageLines.SETRANGE("Document No.", "Document No.");
                    WHMessageLines.MODIFYALL("Error Found", TRUE);
                END ELSE BEGIN
                    TransferLine.Reset();
                    TransferLine.SETCURRENTKEY("Document No.", "Line No.");
                    TransferLine.SETRANGE("Document No.", "Document No.");
                    TransferLine.SetRange("Derived From Line No.", 0);
                    IF TransferLine.FindSet(TRUE) THEN
                        REPEAT
                            IF (NOT WHMessageLines.GET("Document No.", TransferLine."Line No.", "Import Type")) AND
                               (TransferLine.Quantity <> 0) THEN BEGIN
                                TransferLine."GXL Qty. Variance Resaon Code" := IntegrationSetup."ASN Variance Reason Code";
                                TransferLine.VALIDATE("Qty. to Ship", 0);
                                TransferLine.VALIDATE("GXL Qty Variance", TransferLine.Quantity);
                                TransferLine.MODIFY();
                            END;
                        UNTIL TransferLine.NEXT() = 0;

                    TempTransferHeader.RESET();
                    TempTransferHeader.SETRANGE(TempTransferHeader."No.", "Document No.");
                    IF NOT TempTransferHeader.FINDFIRST() THEN BEGIN
                        TempTransferHeader.INIT();
                        TempTransferHeader.TRANSFERFIELDS(TransferHeader);
                        TempTransferHeader.Insert();
                    END;
                END;

                //ERP-327 +
                if (OldTransHead.Status = OldTransHead.Status::Released) and (TransferHeader.Status <> TransferHeader.Status::Released) then begin
                    TransferHeader.Get(TransferHeader."No.");
                    ReleaseTransferDoc.Run(TransferHeader);
                end;
                //ERP-327 -
            end;

            trigger OnPreDataItem()
            begin
                TempTransferHeader.RESET();
                TempTransferHeader.DELETEALL();
                IntegrationSetup.TESTFIELD("Suffix for TO SOH Increase");
                IntegrationSetup.TESTFIELD("Suffix for TO SOH Decrease");
            end;
        }
        //Inventory adjustment
        dataitem("WH ADJ"; "GXL WH Message Lines")
        {
            DataItemTableView = SORTING("Document No.", "Line No.", "Import Type") WHERE("Error Found" = FILTER(false), Processed = FILTER(false), "Import Type" = FILTER("Item Adj."));

            trigger OnAfterGetRecord()
            var
                WHMessageLines: Record "GXL WH Message Lines";
                Sku: Record "Stockkeeping Unit";
                Location: Record Location;
                ReasonCode: Record "Reason Code";
                ToModify: Boolean;
                EDIClaimable: Boolean;
            begin

                TempWHMessageLines.RESET();
                TempWHMessageLines.SETRANGE(TempWHMessageLines."Import Type", "Import Type"::"Item Adj.");
                TempWHMessageLines.SETFILTER("Document No.", "Document No.");
                IF NOT TempWHMessageLines.FindSet() THEN BEGIN
                    TempWHMessageLines.RESET();
                    TempWHMessageLines.INIT();
                    TempWHMessageLines.TRANSFERFIELDS("WH ADJ");
                    TempWHMessageLines.Insert();
                END ELSE
                    CurrReport.SKIP();

                WHMessageLines.RESET();
                WHMessageLines.SETRANGE("Import Type", "Import Type");
                WHMessageLines.SETFILTER("Document No.", "Document No.");
                IF WHMessageLines.FindSet() THEN BEGIN
                    REPEAT
                        Sku.RESET();
                        Sku.SetRange("Location Code", WHMessageLines."Location Code");
                        Sku.SetRange("Item No.", WHMessageLines.GetRealItemNo());
                        if Sku.IsEmpty() then begin
                            WHMessageLines."Error Found" := TRUE;
                            WHMessageLines."Error Description" := STRSUBSTNO(error6Err, WHMessageLines."Location Code", WHMessageLines."Item No.");
                            WHMessageLines.MODIFY();
                        END;
                        IF (WHMessageLines."Reason Code" <> IntegrationSetup."3PL Purch. St. Adj Reason Code") AND (WHMessageLines.Description <> '') THEN
                            IF Location.GET(WHMessageLines."Location Code") THEN
                                IF Location."GXL EDI Type" = Location."GXL EDI Type"::"3PL EDI" THEN BEGIN
                                    //PS-2210+
                                    //WHMessageLines."EDI Type" := WHMessageLines."EDI Type"::"3PL EDI";
                                    ToModify := false;
                                    if WHMessageLines."EDI Type" <> WHMessageLines."EDI Type"::"3PL EDI" then begin
                                        WHMessageLines."EDI Type" := WHMessageLines."EDI Type"::"3PL EDI";
                                        ToModify := true;
                                    end;
                                    //PS-2210-
                                    IF WHMessageLines."Reason Code" <> '' THEN BEGIN
                                        ReasonCode.RESET();
                                        IF ReasonCode.GET(WHMessageLines."Reason Code") THEN begin
                                            //PS-2210+
                                            //WHMessageLines."EDI Claimable" := ReasonCode."GXL Claimable" AND (WHMessageLines."Entry Type" = 'NEGATIVE ADJMT');
                                            EDIClaimable := ReasonCode."GXL Claimable" AND (WHMessageLines."Entry Type" = 'NEGATIVE ADJMT');
                                            if EDIClaimable <> WHMessageLines."EDI Claimable" then begin
                                                WHMessageLines."EDI Claimable" := EDIClaimable;
                                                ToModify := true;
                                            end;
                                            //PS-2210-
                                        end;
                                    END;
                                    if ToModify then //PS-2210
                                        WHMessageLines.MODIFY();
                                END;
                    UNTIL WHMessageLines.NEXT() = 0;

                    WHMessageLines.RESET();
                    WHMessageLines.SETRANGE("Import Type", "Import Type");
                    WHMessageLines.SETFILTER("Document No.", "Document No.");
                    WHMessageLines.SETRANGE("Error Found", FALSE);
                    WHMessageLines.SETRANGE("EDI Claimable", FALSE);

                    IF not WHMessageLines.IsEmpty() THEN
                        //ERP-301 - 3PL Transfer - Added param +
                        // InsertJnlLine("Document No."); 
                        InsertJnlLine("Document No.", false);
                    //ERP-301 - 3PL Transfer - Added param -
                END;
            end;

            trigger OnPreDataItem()
            begin
                TempWHMessageLines.RESET();
                TempWHMessageLines.DELETEALL();
            end;
        }
        dataitem("Integer"; "Integer")
        {

            trigger OnAfterGetRecord()
            begin
                IF Number = 1 THEN
                    TempPurchaseHeader.FINDFIRST()
                ELSE
                    TempPurchaseHeader.NEXT(1);

                PostPurchShip(TempPurchaseHeader."No.");
            end;

            trigger OnPreDataItem()
            begin
                TempPurchaseHeader.RESET();
                IF TempPurchaseHeader.FindSet() THEN
                    SETRANGE(Number, 1, TempPurchaseHeader.COUNT())
                ELSE
                    CurrReport.BREAK();
            end;
        }
        dataitem(PostSTO; "Integer")
        {

            trigger OnAfterGetRecord()
            var
                TransferHeader: Record "Transfer Header";
                SOHDecreaseDocNo: Code[20];
            begin
                IF Number = 1 THEN
                    TempTransferHeader.FINDFIRST()
                ELSE
                    TempTransferHeader.NEXT(1);

                SOHDecreaseDocNo := '';
                TransferHeader.RESET();
                TransferHeader.SETRANGE("No.", TempTransferHeader."No.");
                TransferHeader.SETFILTER("GXL Order Status", '<%1', TransferHeader."GXL Order Status"::Confirmed);
                TransferHeader.SETFILTER("Last Shipment No.", '=%1', '');
                IF not TransferHeader.IsEmpty() THEN BEGIN
                    CheckSOHIncrease(TempTransferHeader."No.", SOHDecreaseDocNo);
                    PostTransferShip(TempTransferHeader."No.");
                    //ERP-301 +
                    //Only positive adjmt 
                    // IF SOHDecreaseDocNo <> '' THEN
                    //     InsertJnlLine(SOHDecreaseDocNo);
                    //ERP-301 -
                END;
            end;

            trigger OnPreDataItem()
            begin

                TempTransferHeader.RESET();
                IF TempTransferHeader.FindSet() THEN
                    SETRANGE(Number, 1, TempTransferHeader.COUNT())
                ELSE
                    CurrReport.BREAK();
            end;
        }
        //WMSVD-002->>----------------------------------
        dataitem("Sales Order Line"; "GXL WH Message Lines")
        {
            DataItemTableView = SORTING("Document No.", "Line No.", "Import Type") WHERE("Error Found" = FILTER(false), Processed = FILTER(false), "Import Type" = FILTER("Sales Order"));

            trigger OnAfterGetRecord()
            var
                WHMessageLines: Record "GXL WH Message Lines";
                WHSalesOrderProcessor: Codeunit "WH Msg. Sales Order Processor";
            begin
                TempWHMessageLines.Reset();
                TempWHMessageLines.SetCurrentKey("Import Type", "Document No.");
                TempWHMessageLines.SetRange(TempWHMessageLines."Import Type", TempWHMessageLines."Import Type"::"Sales Order");
                TempWHMessageLines.SetRange("Document No.", "Document No.");
                if TempWHMessageLines.IsEmpty then begin
                    TempWHMessageLines := "Sales Order Line";
                    TempWHMessageLines.Insert();
                    WHSalesOrderProcessor.RunAndLog("Sales Order Line");
                    Commit();
                end;
            end;

            trigger OnPreDataItem()
            begin
                Commit();
            end;
        }
        //<<-WMSVD-002---------------------------
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        IntegrationSetup.GET();
    end;

    // >> GX202316 - New Change
    trigger OnPostReport()
    var
        WhMessageLines: Record "GXL WH Message Lines";
        IntegrationSetup: Record "GXL Integration Setup";
    begin
        IntegrationSetup.get;
        IF IntegrationSetup."TOR Auto Decrease Enable" then
            WhMessageLines.DecreaseStock();
    end;
    // << GX202316 - New Change

    var
        //_FileDirectory: Record File;
        //JobQueueEntry: Record "Job Queue Entry";
        IntegrationSetup: Record "GXL Integration Setup";
        LocationRec: Record Location;
        TempWHMessageLines: Record "GXL WH Message Lines" temporary;
        TempPurchaseHeader: Record "Purchase Header" temporary;
        TempTransferHeader: Record "Transfer Header" temporary;
        cuWHDATAMGMT: Codeunit "GXL WH Data Management";
        GXLMiscUtilities: Codeunit "GXL Misc. Utilities";
        BoolErr: Boolean;
        UOMCode: Code[10];
        error2Err: Label '%1 %2 Not found';
        //error3Err: Label 'Item %1 Not found in %2 %3';
        error4Err: Label 'Receiving Qty can not be greater than order qty Item %1 in %2 %3';
        //error5Err: Label '%1 %2 has been processed';
        error6Err: Label 'SKU %1 %2 is not exist';
        error7Err: Label 'Item No. is not matching for %1 %2 line no. %3, received %4, NAV value %5';
        error8Err: Label 'Line No. %1 can not be found in %2 %3';
        Text002Err: Label 'ASN Scan Line could not be created. Check ASN to ensure a valid item line exists';
    /*
    procedure ArchiveFile(FromDir: Text; ToDir: Text)
    begin

        COPY(FromDir, ToDir);
    end;
    */
    local procedure PostPurchShip(DocumentNumber: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
        WHMessageLines: Record "GXL WH Message Lines";
        PurchPost: Codeunit "Purch.-Post";
    begin
        COMMIT();

        PurchaseHeader.RESET();
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SETRANGE("No.", DocumentNumber);
        IF PurchaseHeader.FINDFIRST() THEN BEGIN
            //TODO: Order Status
            IF PurchaseHeader."GXL Order Status" <> PurchaseHeader."GXL Order Status"::Closed THEN BEGIN
                CLEAR(PurchPost);
                CLEARLASTERROR();
                COMMIT();
                IF PurchaseHeader."Posting Date" <> TODAY() THEN BEGIN
                    PurchaseHeader.SetHideValidationDialog(TRUE);
                    PurchaseHeader.VALIDATE("Posting Date", TODAY());
                    Commit();
                END;
                //TODO: Order Status
                if PurchaseHeader."GXL International Order" and (PurchaseHeader."GXL Order Status" <> PurchaseHeader."GXL Order Status"::Arrived) then
                    PurchaseHeader."GXL Order Status" := PurchaseHeader."GXL Order Status"::Arrived;

                if (not PurchaseHeader."GXL International Order") and (PurchaseHeader."GXL Order Status" <> PurchaseHeader."GXL Order Status"::Confirmed) then
                    PurchaseHeader."GXL Order Status" := PurchaseHeader."GXL Order Status"::Confirmed;

                PurchaseHeader.Receive := TRUE;
                PurchaseHeader.Invoice := FALSE;
                PurchaseHeader."GXL 3PL File Receive" := TRUE;

                IF PurchPost.RUN(PurchaseHeader) = FALSE THEN BEGIN
                    IF NOT GXLMiscUtilities.IsLockingError(GETLASTERRORCODE()) THEN BEGIN
                        WHMessageLines.RESET();
                        WHMessageLines.SETRANGE("Import Type", WHMessageLines."Import Type"::"Purchase Order");
                        WHMessageLines.SETFILTER("Document No.", DocumentNumber);
                        WHMessageLines.MODIFYALL("Error Found", TRUE);
                        WHMessageLines.MODIFYALL(Processed, FALSE);
                        IF GETLASTERRORTEXT() <> '' THEN
                            WHMessageLines.MODIFYALL("Error Description", COPYSTR(GETLASTERRORTEXT(), 1, MAXSTRLEN(WHMessageLines."Error Description")));
                        COMMIT();
                    END;
                END ELSE BEGIN
                    WHMessageLines.RESET();
                    WHMessageLines.SETRANGE("Import Type", WHMessageLines."Import Type"::"Purchase Order");
                    WHMessageLines.SETFILTER("Document No.", DocumentNumber);
                    WHMessageLines.MODIFYALL(Processed, TRUE);
                END;
            END ELSE BEGIN
                WHMessageLines.RESET();
                WHMessageLines.SETRANGE("Import Type", WHMessageLines."Import Type"::"Purchase Order");
                WHMessageLines.SETFILTER("Document No.", DocumentNumber);
                WHMessageLines.MODIFYALL(Processed, TRUE);

            END;
        END ELSE BEGIN
            WHMessageLines.RESET();
            WHMessageLines.SETRANGE("Import Type", WHMessageLines."Import Type"::"Purchase Order");
            WHMessageLines.SETFILTER("Document No.", DocumentNumber);
            WHMessageLines.MODIFYALL(Processed, FALSE);
            WHMessageLines.MODIFYALL("Error Found", TRUE);
            WHMessageLines.MODIFYALL("Error Description", 'Purchase Order ' + DocumentNumber + ' can not be posted');
        END;
    end;

    local procedure PostTransferShip(DocumentNumber: Code[20])
    var
        TransferHeader: Record "Transfer Header";
        WHMessageLines: Record "GXL WH Message Lines";
        TransferPostShip: Codeunit "TransferOrder-Post Shipment";
        AdjTrnasOrderInv: Codeunit "GXL Adj. Trans. Order Inv.";
        //SCPurchaseOrderStatusMgt: Codeunit "SC-Purchase Order Status Mgt";
        PostWasSuccess: Boolean;
    begin
        IF TransferHeader.GET(DocumentNumber) THEN BEGIN
            IF TransferHeader."Last Shipment No." = '' THEN BEGIN
                COMMIT();
                TransferHeader.VALIDATE("Posting Date", TODAY());
                TransferHeader."GXL 3PL File Receive" := TRUE;
                WHMessageLines.SETRANGE("Import Type", WHMessageLines."Import Type"::"Transfer Order");
                WHMessageLines.SetRange("Document No.", TransferHeader."No.");
                CLEAR(TransferPostShip);
                CLEARLASTERROR();
                PostWasSuccess := AdjTrnasOrderInv.AdjustTOShipmentInv(TransferHeader);
                IF NOT PostWasSuccess then
                    PostWasSuccess := TransferPostShip.RUN(TransferHeader);
                IF NOT PostWasSuccess THEN BEGIN
                    IF WHMessageLines.FindSet(TRUE) THEN
                        REPEAT
                            WHMessageLines."Error Found" := NOT IsSkipError(GETLASTERRORCODE(), GETLASTERRORTEXT());
                            WHMessageLines."Error Description" := COPYSTR(GETLASTERRORTEXT(), 1, MAXSTRLEN(WHMessageLines."Error Description"));
                            WHMessageLines.MODIFY();
                        UNTIL WHMessageLines.NEXT() = 0;
                END ELSE BEGIN
                    IF WHMessageLines.FindSet(TRUE) THEN
                        REPEAT
                            WHMessageLines.Processed := TRUE;
                            WHMessageLines."Error Description" := '';
                            WHMessageLines.MODIFY();
                        UNTIL WHMessageLines.NEXT() = 0;
                END;
                COMMIT();
            END;
        END;
    end;

    /*
    [Scope('OnPrem')]
    procedure SetJobQueueEntry(NewJobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry := NewJobQueueEntry;
    end;
    */

    local procedure InsertJnlLine(DocNo: Code[20]; FromTransfer: Boolean)
    var
        _recItemJournal: Record "Item Journal Line";
        RecReason: Record "Reason Code";
        RecWHMessageLines: Record "GXL WH Message Lines";
        TempWHMessageLinesL: Record "GXL WH Message Lines" temporary;
        ItemJnlPostBatch: Codeunit "Item Jnl.-Post Batch";
        LineNo: Integer;
    begin
        //ERP-301 - 3PL Transfer +
        //Added param FromTransfer
        RecWHMessageLines.RESET();
        RecWHMessageLines.SETRANGE("Import Type", RecWHMessageLines."Import Type"::"Item Adj.");
        RecWHMessageLines.SETRANGE("Document No.", DocNo);
        RecWHMessageLines.SETRANGE("Error Found", FALSE);
        RecWHMessageLines.SETRANGE(Processed, FALSE);
        RecWHMessageLines.SETRANGE("EDI Claimable", FALSE);
        IF RecWHMessageLines.FindSet() THEN BEGIN
            LocationRec.GET(RecWHMessageLines."Location Code");
            LocationRec.TestField("GXL Def. Stock Adj. Batch Name");
            DeleteItemJnlLine(LocationRec."GXL Def. Stock Adj. Batch Name");
            REPEAT

                LineNo := FindLastJournal();
                LineNo := LineNo + 10000;
                _recItemJournal.RESET();
                _recItemJournal.INIT();
                _recItemJournal."Journal Template Name" := 'ITEM';
                _recItemJournal."Journal Batch Name" := LocationRec."GXL Def. Stock Adj. Batch Name";
                _recItemJournal."Line No." := LineNo;
                _recItemJournal."Posting Date" := RecWHMessageLines."Date Imported";
                _recItemJournal."Document No." := RecWHMessageLines."Document No.";
                IF RecWHMessageLines."Reason Code" = IntegrationSetup."3PL Purch. St. Adj Reason Code" THEN BEGIN
                    _recItemJournal."Entry Type" := _recItemJournal."Entry Type"::Purchase
                END ELSE BEGIN

                    IF RecWHMessageLines."Entry Type" = 'POSITIVE ADJMT' THEN
                        _recItemJournal."Entry Type" := _recItemJournal."Entry Type"::"Positive Adjmt."
                    ELSE
                        _recItemJournal."Entry Type" := _recItemJournal."Entry Type"::"Negative Adjmt.";

                END;

                _recItemJournal.VALIDATE("Item No.", RecWHMessageLines.GetRealItemNoAndUOMCode(UOMCode));
                _recItemJournal.Validate("Unit of Measure Code", UOMCode);
                IF RecWHMessageLines.Description <> '' THEN
                    _recItemJournal.Description := RecWHMessageLines.Description;

                RecReason.RESET();
                _recItemJournal."Reason Code" := RecWHMessageLines."Reason Code";

                IF (NOT RecReason.GET(RecWHMessageLines."Reason Code")) OR (RecWHMessageLines."Reason Code" = '') THEN
                    _recItemJournal."Reason Code" := IntegrationSetup."Default STK Adj. Reason Code";

                _recItemJournal."Location Code" := RecWHMessageLines."Location Code";
                _recItemJournal."GXL User ID" := CopyStr(RecWHMessageLines."User Name", 1, MaxStrLen(_recItemJournal."GXL User ID"));
                _recItemJournal.VALIDATE(Quantity, ABS(RecWHMessageLines."Qty. To Receive"));
                _recItemJournal.VALIDATE("Shortcut Dimension 2 Code", GetDimensionValue(RecWHMessageLines."Location Code"));
                IF (_recItemJournal."Item No." <> '') AND (RecWHMessageLines."Qty. To Receive" <> 0) THEN BEGIN
                    _recItemJournal.Insert(TRUE);
                END;

                TempWHMessageLinesL := RecWHMessageLines;
                TempWHMessageLinesL.Insert();

            UNTIL RecWHMessageLines.NEXT() = 0;
        END;

        _recItemJournal.RESET();
        _recItemJournal.SETRANGE("Journal Template Name", 'ITEM');
        _recItemJournal.SETRANGE("Journal Batch Name", LocationRec."GXL Def. Stock Adj. Batch Name");
        IF _recItemJournal.FINDFIRST() THEN BEGIN
            CLEARLASTERROR();

            COMMIT();

            TempWHMessageLinesL.RESET();
            IF NOT ItemJnlPostBatch.RUN(_recItemJournal) THEN BEGIN
                //ERP-301 - 3PL Transfer +
                //Always mark error for adj entries created from transfer
                if FromTransfer then begin
                    TempWHMessageLinesL.FindSet();
                    REPEAT
                        RecWHMessageLines.GET(TempWHMessageLinesL."Document No.", TempWHMessageLinesL."Line No.", TempWHMessageLinesL."Import Type");
                        RecWHMessageLines."Error Found" := true;
                        RecWHMessageLines."Error Description" := COPYSTR(GETLASTERRORTEXT(), 1, MAXSTRLEN(RecWHMessageLines."Error Description"));
                        RecWHMessageLines.Modify();
                    UNTIL TempWHMessageLinesL.NEXT() = 0;
                end else begin
                    //ERP-301 - 3PL Transfer -
                    IF (NOT GXLMiscUtilities.IsLockingError(GETLASTERRORCODE())) AND (STRPOS(GETLASTERRORTEXT(), 'already exists') = 0) THEN BEGIN

                        TempWHMessageLinesL.RESET();
                        TempWHMessageLinesL.FindSet();
                        REPEAT
                            RecWHMessageLines.GET(TempWHMessageLinesL."Document No.", TempWHMessageLinesL."Line No.", TempWHMessageLinesL."Import Type");
                            RecWHMessageLines."Error Found" := TRUE;
                            RecWHMessageLines."Error Description" := COPYSTR(GETLASTERRORTEXT(), 1, MAXSTRLEN(RecWHMessageLines."Error Description"));
                            RecWHMessageLines.MODIFY(TRUE);
                        UNTIL TempWHMessageLinesL.NEXT() = 0;

                    end;
                end;  //ERP-301 - 3PL Transfer +
                DeleteItemJnlLine(LocationRec."GXL Def. Stock Adj. Batch Name");
            end else begin
                TempWHMessageLinesL.FindSet();
                REPEAT
                    RecWHMessageLines.GET(TempWHMessageLinesL."Document No.", TempWHMessageLinesL."Line No.", TempWHMessageLinesL."Import Type");
                    RecWHMessageLines.Processed := true;
                    RecWHMessageLines.Modify();
                UNTIL TempWHMessageLinesL.NEXT() = 0;

            END;

            COMMIT();

        END;
    end;

    local procedure FindLastJournal(): Integer
    var
        recItemJournal: Record "Item Journal Line";
    begin
        recItemJournal.RESET();
        recItemJournal.SETRANGE("Journal Template Name", 'ITEM');
        recItemJournal.SETRANGE("Journal Batch Name", LocationRec."GXL Def. Stock Adj. Batch Name");
        IF recItemJournal.FINDLAST() THEN
            EXIT(recItemJournal."Line No.");
        EXIT(10000);
    end;

    local procedure GetDimensionValue(InputLocationCode: Code[10]): Code[20]
    var
        Store: Record "LSC Store";
        DefaultDim: REcord "Default Dimension";
    begin
        Store.SetCurrentKey("Location Code");
        Store.SetRange("Location Code", InputLocationCode);
        if not Store.FindFirst() then
            exit;
        if IntegrationSetup."Store Dimension Code" = '' then
            IntegrationSetup.Get();
        IntegrationSetup.TestField("Store Dimension Code");
        IF NOT DefaultDim.Get(Database::"LSC Store", Store."No.", IntegrationSetup."Store Dimension Code") then
            exit('');
        exit(DefaultDim."Dimension Value Code");
    end;
    /*
    local procedure DeleteFile(InputFileName: Text)
    begin
        IF EXISTS(InputFileName) THEN
            ERASE(InputFileName);
    end;
    */
    local procedure DeleteItemJnlLine(InputBatchName: Code[10])
    var
        ItemJournalLine: Record "Item Journal Line";
    begin
        ItemJournalLine.SETRANGE("Journal Template Name", 'ITEM');
        ItemJournalLine.SETRANGE("Journal Batch Name", InputBatchName);
        IF NOT ItemJournalLine.ISEMPTY() THEN
            ItemJournalLine.DELETEALL(TRUE);
    end;

    local procedure IsSkipError(CodeError: Text; StringError: Text): Boolean
    begin
        IF NOT GXLMiscUtilities.IsLockingError(CodeError) THEN
            EXIT((STRPOS(LOWERCASE(StringError), LOWERCASE('You have insufficient quantity')) <> 0) OR
                 (STRPOS(LOWERCASE(StringError), LOWERCASE('is not in inventory')) <> 0) OR
                 (STRPOS(StringError, 'already exists') <> 0))
        ELSE
            EXIT(TRUE);
    end;

    local procedure CheckSOHIncrease(DocumentNo: Code[20]; var InputSOHDecreaseDocNo: Code[20])
    var
        //Sku: Record "Stockkeeping Unit";
        TransferLine: Record "Transfer Line";
        Item: Record Item;
        TransferHeader: Record "Transfer Header";
        TempLine: Record "Transfer Line" temporary;
        ItemUOM: Record "Item Unit of Measure";
        //UOMMgt: Codeunit "Unit of Measure Management";
        SOHIncreaseDocNo: Code[20];
        LineNo: Integer;
        SOHQty: Decimal;
        QtyToIncreaseBase: Decimal;
        QtyToIncrease: Decimal;
    begin
        //ERP-301 +
        TempLine.Reset();
        TempLine.DeleteAll();
        //ERP-301 -

        InitSOHEntry(DocumentNo);
        SOHIncreaseDocNo := '';
        InputSOHDecreaseDocNo := '';
        TransferLine.RESET();
        TransferLine.SETRANGE("Document No.", DocumentNo);
        TransferLine.SETFILTER("Qty. to Ship", '>0');
        TransferLine.SetRange("Derived From Line No.", 0);
        IF TransferLine.FindSet() THEN begin
            //PS-2210+
            //Non-Live Store will create negative adjustments instead of transfer shipment
            //So there is no need to check stock availability
            TransferHeader.Get(TransferLine."Document No.");
            if IsNonLiveStore(TransferHeader) then
                exit;
            //PS-2210-

            REPEAT
                //ERP-301 +
                //     //PS-2210+
                //     // Sku.Reset();
                //     // Sku.SetRange("Location Code", TransferLine."Transfer-from Code");
                //     // Sku.SetRange("Item No.", TransferLine."Item No.");
                //     // if Sku.FindFirst() then begin
                //     //     Sku.CALCFIELDS(Inventory);
                //     //     IF Sku.Inventory < TransferLine."Qty. to Ship (Base)" THEN BEGIN
                //     Item.Get(TransferLine."Item No.");
                //     Item.SetFilter("Location Filter", TransferLine."Transfer-from Code");
                //     Item.CalcFields(Inventory);
                //     SOHQty := Item.Inventory; //PS-2210
                //     if Item.Inventory < TransferLine."Qty. to Ship (Base)" then begin
                //         //PS-2210-
                //         IF SOHIncreaseDocNo = '' THEN BEGIN
                //             SOHIncreaseDocNo := TransferLine."Document No." + IntegrationSetup."Suffix for TO SOH Increase";
                //             InputSOHDecreaseDocNo := TransferLine."Document No." + IntegrationSetup."Suffix for TO SOH Decrease";
                //         END;
                //         //PS-2153+
                //         //ItemUOM.Get(TransferLine."Item No.", TransferLine."Unit of Measure Code");
                //         //SOHQty := Round(Sku.Inventory / ItemUOM."Qty. per Unit of Measure", UOMMgt.QtyRndPrecision());
                //         //SOHQty := Sku.Inventory; //PS-2210
                //         QtyToIncreaseBase := TransferLine."Qty. to Ship (Base)" - SOHQty;
                //         if (TransferLine."Qty. per Unit of Measure" = 1) or (TransferLine."Qty. per Unit of Measure" = 0) then
                //             QtyToIncrease := QtyToIncreaseBase
                //         else begin
                //             //To a whole number to avoid rounding    
                //             QtyToIncrease := Round(QtyToIncreaseBase / TransferLine."Qty. per Unit of Measure", 1, '>');
                //         end;
                //         //PS-2153-
                //         LineNo := 0;
                //         LineNo := FindLineNo(SOHIncreaseDocNo);
                //         InsertSOHEntry(SOHIncreaseDocNo,
                //                         TransferLine."Transfer-from Code",
                //                         LineNo,
                //                         //Legacy Item
                //                         //TransferLine."Item No.",
                //                         TransferLine."GXL Legacy Item No.",
                //                         //PS-2153+                                        
                //                         //TransferLine."Qty. to Ship" - SOHQty,
                //                         QtyToIncrease,
                //                         //PS-2153-
                //                         'POSITIVE ADJMT');

                //         InsertSOHEntry(
                //                         InputSOHDecreaseDocNo,
                //                         TransferLine."Transfer-from Code",
                //                         LineNo,
                //                         //Legacy Item
                //                         //TransferLine."Item No.",
                //                         TransferLine."GXL Legacy Item No.",
                //                         //PS-2153+                                        
                //                         //TransferLine."Qty. to Ship" - SOHQty,
                //                         QtyToIncrease,
                //                         //PS-2153-
                //                         'NEGATIVE ADJMT');

                //     END;
                // //END; //PS-2210

                //Added to temp file first as in a transfer may have 2 lines with the same item number (child and parent items)
                TempLine.SetRange("Item No.", TransferLine."Item No.");
                if not TempLine.Find('-') then begin
                    Item.Get(TransferLine."Item No.");
                    Item.SetFilter("Location Filter", TransferHeader."Transfer-from Code");
                    Item.CalcFields(Inventory);
                    SOHQty := Item.Inventory;

                    //Always in base UOM
                    TempLine.Init();
                    TempLine."Document No." := TransferLine."Document No.";
                    TempLine."Line No." := TransferLine."Line No.";
                    TempLine."Transfer-from Code" := TransferLine."Transfer-from Code";
                    TempLine."Transfer-to Code" := TransferLine."Transfer-to Code";
                    TempLine."Item No." := TransferLine."Item No.";
                    if (TransferLine."Qty. per Unit of Measure" = 1) and (TransferLine."GXL Legacy Item No." <> '') then
                        TempLine."GXL Legacy Item No." := TransferLine."GXL Legacy Item No."
                    else begin
                        ItemUOM.SetRange("Item No.", TransferLine."Item No.");
                        ItemUOM.SetRange("Qty. per Unit of Measure", 1);
                        ItemUOM.SetFilter("GXL Legacy Item No.", '<>%1', '');
                        if ItemUOM.FindFirst() then
                            TempLine."GXL Legacy Item No." := ItemUOM."GXL Legacy Item No."
                        else
                            TempLine."GXL Legacy Item No." := TransferLine."Item No.";
                    end;
                    TempLine."Quantity (Base)" := SOHQty;
                    TempLine."Qty. to Ship (Base)" := TransferLine."Qty. to Ship (Base)";
                    TempLine.Insert();
                end else begin
                    TempLine."Qty. to Ship (Base)" += TransferLine."Qty. to Ship (Base)";
                    TempLine.Modify();
                end;
            //ERP-301 -

            UNTIL TransferLine.NEXT() = 0;

            //ERP-301 +
            //Now check qty to ship with SOH to do positive adjustment if not enough stock
            LineNo := 0;
            TempLine.Reset();
            if TempLine.Find('-') then
                repeat
                    if (TempLine."Qty. to Ship (Base)" > TempLine."Quantity (Base)") then begin
                        IF SOHIncreaseDocNo = '' THEN BEGIN
                            SOHIncreaseDocNo := TransferHeader."No." + IntegrationSetup."Suffix for TO SOH Increase";
                            InputSOHDecreaseDocNo := TransferHeader."No." + IntegrationSetup."Suffix for TO SOH Decrease";
                        END;
                        QtyToIncreaseBase := TempLine."Qty. to Ship (Base)" - TempLine."Quantity (Base)";
                        if LineNo = 0 then
                            LineNo := FindLineNo(SOHIncreaseDocNo)
                        else
                            LineNo += 1;
                        InsertSOHEntry(SOHIncreaseDocNo,
                                        TransferHeader."Transfer-from Code",
                                        LineNo,
                                        TempLine."GXL Legacy Item No.",
                                        QtyToIncreaseBase,
                                        'POSITIVE ADJMT');
                    end;
                until TempLine.Next() = 0;
            TempLine.DeleteAll();
            //ERP-301 -

        end;

        IF SOHIncreaseDocNo <> '' THEN
            InsertJnlLine(SOHIncreaseDocNo, true); //ERP-301 - 3PL Transfer
    end;

    local procedure InsertSOHEntry(DocumentNo: Code[20]; LocationCode: Code[10]; LineNo: Integer; ItemNo: Code[20]; Qty: Decimal; EntryType: Text)
    var
        WHMessageLines: Record "GXL WH Message Lines";
    begin
        //PS-2153: Changed Param Qty datatype from Integer to Decimal
        WHMessageLines.RESET();
        WHMessageLines.INIT();
        WHMessageLines."Import Type" := WHMessageLines."Import Type"::"Item Adj.";
        WHMessageLines."Document No." := DocumentNo;
        WHMessageLines."Line No." := LineNo;
        WHMessageLines."Location Code" := LocationCode;
        WHMessageLines."Item No." := ItemNo;
        WHMessageLines."Qty. To Receive" := Qty;
        WHMessageLines."Date Imported" := Today();
        WHMessageLines."Time Imported" := Time();
        WHMessageLines."Entry Type" := EntryType;
        WHMessageLines.Insert();
    end;

    local procedure FindLineNo(DocumentNo: Code[20]) LineNo: Integer
    var
        WHMessageLines: Record "GXL WH Message Lines";
    begin
        WHMessageLines.SETCURRENTKEY("Document No.", "Line No.", "Import Type");
        WHMessageLines.SETRANGE("Document No.", DocumentNo);
        WHMessageLines.SETRANGE("Import Type", WHMessageLines."Import Type"::"Item Adj.");
        IF WHMessageLines.FINDLAST() THEN
            LineNo := WHMessageLines."Line No.";
        LineNo += 1;
        EXIT(LineNo);
    end;

    local procedure InitSOHEntry(DocumentNo: Code[20])
    var
        WHMessageLines: Record "GXL WH Message Lines";
        WHMessageLines2: Record "GXL WH Message Lines";
    begin
        WHMessageLines.SETRANGE("Import Type", WHMessageLines."Import Type"::"Item Adj.");
        WHMessageLines.SETRANGE("Document No.", DocumentNo + IntegrationSetup."Suffix for TO SOH Increase");
        WHMessageLines.SETRANGE(Processed, FALSE);
        //ERP-301 +
        // IF WHMessageLines.FindSet(TRUE) THEN
        //     REPEAT
        //         IF WHMessageLines2.GET(DocumentNo + IntegrationSetup."Suffix for TO SOH Decrease", WHMessageLines."Line No.", WHMessageLines."Import Type"::"Item Adj.") THEN
        //             IF NOT WHMessageLines2.Processed THEN BEGIN
        //                 WHMessageLines2.DELETE();
        //                 WHMessageLines.DELETE();
        //             END;
        //     UNTIL WHMessageLines.NEXT() = 0;
        WHMessageLines.DeleteAll();
        //ERP-301 -
    end;

    local procedure CreateASNScanLogHeader(PurchHeader: Record "Purchase Header"; var ASNHeader: Record "GXL ASN Header"): Boolean
    var
        ASNLevel1Line: Record "GXL ASN Level 1 Line";
        ASNLevel1Log: Record "GXL ASN Level 1 Line Scan Log";
        ASNHeaderLog: Record "GXL ASN Header Scan Log";
    begin
        ASNHeader.SETCURRENTKEY("Document Type", "Purchase Order No.");
        ASNHeader.SETRANGE("Document Type", ASNHeader."Document Type"::Purchase);
        ASNHeader.SETRANGE("Purchase Order No.", PurchHeader."No.");
        //ERP-247 >>
        //Additional status filter added because of timing when the filter imported and asn header was synched from NAV13
        //ASNHeader.SETRANGE(Status, ASNHeader.Status::Processed);
        ASNHeader.SetFilter(Status, '%1|%2', ASNHeader.Status::Processed, ASNHeader.Status::"3PL ASN Sent");
        //ERP-247 <<
        IF NOT ASNHeader.FINDFIRST() THEN
            EXIT;

        ASNHeaderLog.SETRANGE("Purchase Order No.", PurchHeader."No.");
        IF ASNHeaderLog.FINDFIRST() THEN
            EXIT(TRUE);

        ASNHeaderLog.INIT();
        ASNHeaderLog."Entry No." := 0;
        ASNHeaderLog."Document Type" := ASNHeader."Document Type";
        ASNHeaderLog."No." := ASNHeader."No.";
        ASNHeaderLog."Purchase Order No." := ASNHeader."Purchase Order No.";
        ASNHeaderLog."EDI Type" := ASNHeader."EDI Type";
        ASNHeaderLog.Insert();

        ASNLevel1Line.SETRANGE("Document Type", ASNHeader."Document Type");
        ASNLevel1Line.SETRANGE("Document No.", ASNHeader."No.");
        IF ASNLevel1Line.FindSet() THEN
            REPEAT
                ASNLevel1Log.INIT();
                ASNLevel1Log."Entry No." := 0;
                ASNLevel1Log."Document Type" := ASNLevel1Line."Document Type";
                ASNLevel1Log."Document No." := ASNLevel1Line."Document No.";
                ASNLevel1Log."Line No." := ASNLevel1Line."Line No.";
                ASNLevel1Log."Level 1 Code" := ASNLevel1Line."Level 1 Code";
                ASNLevel1Log.Quantity := ASNLevel1Line.Quantity;
                ASNLevel1Log.Insert();
            UNTIL ASNLevel1Line.NEXT() = 0;

        EXIT(TRUE);
    end;

    local procedure InsertASNItemLineLog(ASNHeader: Record "GXL ASN Header"; WHMsgLine: Record "GXL WH Message Lines"; var PhysicalRcptVariance: Decimal): Boolean
    var
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
        ASNLevel3Log: Record "GXL ASN Level 3 Line Scan Log";
        QtyReceived: Decimal;
        TotalASNQty: Decimal;
        ASNLevel3ScanLineCreated: Boolean;
    begin
        QtyReceived := WHMsgLine."Qty. To Receive";

        ASNLevel3Line.SETRANGE("Document Type", ASNHeader."Document Type");
        ASNLevel3Line.SETRANGE("Document No.", ASNHeader."No.");
        ASNLevel3Line.SETRANGE("Level 3 Code", WHMsgLine."Item No.");
        IF ASNLevel3Line.FindSet() THEN
            REPEAT
                TotalASNQty := TotalASNQty + ASNLevel3Line.Quantity;

                ASNLevel3Log.INIT();
                ASNLevel3Log."Entry No." := 0;
                ASNLevel3Log."Document Type" := ASNHeader."Document Type";
                ASNLevel3Log."Document No." := ASNHeader."No.";
                ASNLevel3Log."Line No." := ASNLevel3Line."Line No.";
                ASNLevel3Log."Level 2 Line No." := ASNLevel3Line."Level 2 Line No.";
                ASNLevel3Log."Level 3 Code" := ASNLevel3Line."Level 3 Code";
                ASNLevel3Log.Quantity := ASNLevel3Line.Quantity;
                IF QtyReceived > 0 THEN BEGIN
                    IF QtyReceived <= ASNLevel3Line.Quantity THEN
                        ASNLevel3Log."Quantity Received" := QtyReceived
                    ELSE
                        ASNLevel3Log."Quantity Received" := ASNLevel3Line.Quantity;

                    QtyReceived := QtyReceived - ASNLevel3Log."Quantity Received";
                END;
                ASNLevel3Log.Insert();

                ASNLevel3ScanLineCreated := TRUE;
            UNTIL ASNLevel3Line.NEXT() = 0;

        PhysicalRcptVariance := TotalASNQty - WHMsgLine."Qty. To Receive";

        EXIT(ASNLevel3ScanLineCreated);

    end;

    /*
    local Procedure CheckDirectory(VAR FilePathName: Text)
    var
    //i: Integer;
    //BackSlash: Text[1];
    begin
        cuWHDATAMGMT.CheckDirectory(FilePathName);
        exit;

        //i := STRLEN(FilePathName);
        //BackSlash := COPYSTR(FilePathName, i);

        //IF BackSlash <> '\' THEN
        //    FilePathName := FilePathName + '\';
    end;
    */

    //PS-2210+
    local procedure IsNonLiveStore(TransferHeader: Record "Transfer Header"): Boolean
    var
        ToLocation: Record Location;
        ToStore: Record "LSC Store";
    begin
        ToLocation.Get(TransferHeader."Transfer-to Code");
        IF NOT ToLocation.GetAssociatedStore(ToStore, true) then
            exit(false);
        if ToStore."GXL LS Live Store" then
            exit(false);
        IF ToStore."GXL Location Type" <> ToStore."GXL Location Type"::"6" then // 6 means store
            exit(false);
        IF ToStore."GXL LS Store Go-Live Date" <> 0D then begin
            if TransferHeader."GXL Expected Receipt Date" >= ToStore."GXL LS Store Go-Live Date" then
                exit(false);
        end;
        exit(true);
    end;
    //PS-2210-
}


