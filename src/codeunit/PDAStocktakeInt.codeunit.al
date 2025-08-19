codeunit 50272 "GXL PDA-Stocktake Int."
{
    /*Change Log
        PS-2163 09-09-2020 LP
            Not allow to create stocktake with same name
        PS-2137 28-09-2020 LP
            Only base UOM is used in stocktake
    */

    trigger OnRun()
    begin

    end;

    var
        // >> Upgrade
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        // << Upgrade
        ErrorText: Text;
        inputStream: InStream;
        outputStream: OutStream;

    procedure CreateNewStockTake(Store: Code[20]; User: Text[100]; StockTakeDescription: Text[250]; DateOpened: Date; ReasonCode: Code[20]; DivisionCode: Code[20]; ItemCategoryCode: Code[20]; ProductGroupCode: Code[20]; var Created: Boolean; var StockTakeList: XmlPort "GXL PDA StockTake Lines"): Text
    var
        StoreInvWrkshtL: Record "LSC Store Inventory Worksheet";
        PDAStockTakeLineL: Record "GXL PDA StockTake Line";
        //ItemUOML: Record "Item Unit of Measure";
        ItemL: Record Item;
        StoreRecL: Record "LSC Store";
        VendorRecL: Record Vendor;
        SKU: Record "Stockkeeping Unit";
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
        HeaderCreatedL: Boolean;
        LineNoL: Integer;
        WorksheetIDL: Integer;
        CommittedQty: Decimal;
        PhysQty: Decimal;
        WorkShhtErr: Label 'No open worksheet Found';
        ItemNotfoundErr: Label 'No Item found with the given combination';
    begin
        StockTakeList.SetPDAStockID(0, 0);

        //PS-2163+
        if ExistStocktakeWorksheet(Store, StockTakeDescription) then begin
            ErrorText := StrSubstNo('Stocktake Worksheet %1 already exists', StockTakeDescription);
            exit(ErrorText);
        end;
        //PS-2163-

        HeaderCreatedL := false;
        LineNoL := 0;
        StoreRecL.Get(Store);
        StoreInvWrkshtL.Reset();
        StoreInvWrkshtL.SetRange("Store No.", Store);
        StoreInvWrkshtL.CalcFields("No. of Lines", "GXL Open", "GXL No. of Stock Take Lines");
        StoreInvWrkshtL.SetRange("No. of Lines", 0);
        StoreInvWrkshtL.SetRange("GXL Open", true);
        StoreInvWrkshtL.SetRange("GXL No. of Stock Take Lines", 0);
        if StoreInvWrkshtL.FindFirst() then begin
            WorksheetIDL := StoreInvWrkshtL.WorksheetSeqNo;
            StoreInvWrkshtL."GXL StockTake Description" := StockTakeDescription;
            IF DateOpened <> 0D then
                StoreInvWrkshtL."GXL Date Opened" := DateOpened
            else
                StoreInvWrkshtL."GXL Date Opened" := Today;
            StoreInvWrkshtL."GXL User ID" := User;
            StoreInvWrkshtL.Modify();
        end else
            exit(WorkShhtErr);

        PDAStockTakeLineL.Reset();
        PDAStockTakeLineL.SetRange("Stock-Take ID", WorksheetIDL);
        IF PDAStockTakeLineL.FindLast() then
            LineNoL := PDAStockTakeLineL."Line No.";
        ItemL.Reset();
        ItemL.SetRange("LSC Division Code", DivisionCode);
        ItemL.SetRange("Item Category Code", ItemCategoryCode);
        if ProductGroupCode <> '' then
            ItemL.SetRange("LSC Retail Product Code", ProductGroupCode);
        //ItemL.SetRange("Location Filter", StoreRecL."Location Code");
        IF ItemL.FindSet() then begin
            repeat
                ItemL.SetFilter("Location Filter", StoreRecL."Location Code");
                ItemL.CalcFields(Inventory);
                //PS-2089+
                SKU.Init();
                SKU."Item No." := ItemL."No.";
                SKU."Location Code" := StoreRecL."Location Code";
                CommittedQty := PDAItemIntegration.GetMagentoSuspendedQty(SKU);
                PhysQty := ItemL.Inventory - CommittedQty;
                //PS-2089-

                //PS-2137+
                //Only Base UOM will be used
                // ItemUOML.Reset();
                // ItemUOML.SetRange("Item No.", ItemL."No.");
                // IF ItemUOML.FindSet() then begin
                //     repeat
                //         PDAStockTakeLineL.Reset();
                //         PDAStockTakeLineL.SetRange("Stock-Take ID", WorksheetIDL);
                //         PDAStockTakeLineL.SetRange("Item No.", ItemL."No.");
                //         PDAStockTakeLineL.SetRange(UOM, ItemUOML.Code);
                //         IF not PDAStockTakeLineL.FindFirst() then begin
                //             LineNoL += 10000;
                //             PDAStockTakeLineL.Reset();
                //             PDAStockTakeLineL.Init();
                //             PDAStockTakeLineL."Stock-Take ID" := WorksheetIDL;
                //             PDAStockTakeLineL."Line No." := LineNoL;
                //             PDAStockTakeLineL."Item No." := ItemL."No.";
                //             PDAStockTakeLineL."Item Description" := CopyStr(ItemL.Description + ItemL."Description 2", 1, MaxStrLen(PDAStockTakeLineL."Item Description"));
                //             PDAStockTakeLineL."Store Code" := Store;
                //             PDAStockTakeLineL.UOM := ItemUOML.Code;
                //             if (ItemL."Vendor No." <> '') and VendorRecL.Get(ItemL."Vendor No.") then begin
                //                 PDAStockTakeLineL."Vendor No." := ItemL."Vendor No.";
                //                 PDAStockTakeLineL."Vendor Name" := VendorRecL.Name;
                //             end;
                //             //PS-2089+
                //             // if ItemL."Base Unit of Measure" = ItemUOML.Code then
                //             //     PDAStockTakeLineL.SOH := ItemL.Inventory
                //             // else
                //             //     PDAStockTakeLineL.SOH := ItemL.Inventory / ItemUOML."Qty. per Unit of Measure";
                //             if ItemUOML."Qty. per Unit of Measure" <> 0 then
                //                 PDAStockTakeLineL.SOH := PhysQty / ItemUOML."Qty. per Unit of Measure"
                //             else
                //                 PDAStockTakeLineL.SOH := PhysQty;
                //             //PS-2089-
                //             PDAStockTakeLineL."Unit Cost" := ItemL."Unit Cost";
                //             PDAStockTakeLineL.Barcode := PDAItemIntegration.FindItemBarcode(ItemL."No.", ItemUOML.Code);
                //             PDAStockTakeLineL."Reson Code" := ReasonCode;
                //             //PS-2046+
                //             PDAStockTakeLineL."MIM User ID" := User;
                //             //PS-2046-
                //             PDAStockTakeLineL.Insert();
                //             Created := true;
                //         end;
                //     until ItemUOML.Next() = 0;
                // end else begin
                //     LineNoL += 10000;
                //     PDAStockTakeLineL.Reset();
                //     PDAStockTakeLineL.Init();
                //     PDAStockTakeLineL."Stock-Take ID" := WorksheetIDL;
                //     PDAStockTakeLineL."Line No." := LineNoL;
                //     PDAStockTakeLineL."Item No." := ItemL."No.";
                //     PDAStockTakeLineL."Item Description" := CopyStr(ItemL.Description + ItemL."Description 2", 1, MaxStrLen(PDAStockTakeLineL."Item Description"));
                //     PDAStockTakeLineL."Store Code" := Store;
                //     if (ItemL."Vendor No." <> '') and VendorRecL.Get(ItemL."Vendor No.") then begin
                //         PDAStockTakeLineL."Vendor No." := ItemL."Vendor No.";
                //         PDAStockTakeLineL."Vendor Name" := VendorRecL.Name;
                //     end;
                //     PDAStockTakeLineL.UOM := ItemL."Base Unit of Measure";
                //     PDAStockTakeLineL.Barcode := PDAItemIntegration.FindItemBarcode(ItemL."No.", ItemL."Base Unit of Measure");
                //     PDAStockTakeLineL."Reson Code" := ReasonCode;
                //     //PS-2089+
                //     //PDAStockTakeLineL.SOH := ItemL.Inventory;
                //     PDAStockTakeLineL.SOH := PhysQty;
                //     //PS-2089-
                //     PDAStockTakeLineL."Unit Cost" := ItemL."Unit Cost";
                //     //PS-2046+
                //     PDAStockTakeLineL."MIM User ID" := User;
                //     //PS-2046-
                //     PDAStockTakeLineL.Insert();
                //     Created := true
                // END;

                LineNoL += 10000;
                PDAStockTakeLineL.Reset();
                PDAStockTakeLineL.Init();
                PDAStockTakeLineL."Stock-Take ID" := WorksheetIDL;
                PDAStockTakeLineL."Line No." := LineNoL;
                PDAStockTakeLineL."Item No." := ItemL."No.";
                PDAStockTakeLineL."Item Description" := CopyStr(ItemL.Description + ItemL."Description 2", 1, MaxStrLen(PDAStockTakeLineL."Item Description"));
                PDAStockTakeLineL."Store Code" := Store;
                if (ItemL."Vendor No." <> '') and VendorRecL.Get(ItemL."Vendor No.") then begin
                    PDAStockTakeLineL."Vendor No." := ItemL."Vendor No.";
                    PDAStockTakeLineL."Vendor Name" := VendorRecL.Name;
                end;
                PDAStockTakeLineL.UOM := ItemL."Base Unit of Measure";
                PDAStockTakeLineL.Barcode := PDAItemIntegration.FindItemBarcode(ItemL."No.", ItemL."Base Unit of Measure");
                PDAStockTakeLineL."Reson Code" := ReasonCode;
                PDAStockTakeLineL.SOH := PhysQty;
                PDAStockTakeLineL."Unit Cost" := ItemL."Unit Cost";
                PDAStockTakeLineL."MIM User ID" := User;
                PDAStockTakeLineL.Insert();
                Created := true
            //PS-2137-
            until ItemL.Next() = 0;
        end else
            exit(ItemNotfoundErr);

        //PDAStockTakeLineL.Reset();
        //PDAStockTakeLineL.SetRange("Stock-Take ID", WorksheetIDL);
        StockTakeList.SetPDAStockID(WorksheetIDL, 0);
        //StockTakeList.SetTableView(PDAStockTakeLineL);
        ErrorText := '';
        ClearLastError();
        ErrorText := GetLastErrorText();
        exit(ErrorText);
    end;

    procedure UpdateStockTakeQuantity(StoreCode: Code[10]; UserID: Text[50]; StockTakeID: Code[20]; xmlInput: BigText): Text
    var
        StoreInvtWorksheet: Record "LSC Store Inventory Worksheet";
        xmlInbound: XmlPort "GXL PDA StockTake Update";
    begin
        if not StoreInvtWorksheet.Get(StockTakeID) then
            exit(StrSubstNo('Stocktake %1 does not exist.', StocktakeID));
        StoreInvtWorksheet.CalcFields("GXL Open");
        if not StoreInvtWorksheet."GXL Open" then
            Exit(StrSubstNo('Stocktake %1 has already been committed', StockTakeID));

        SaveInputXml(xmlInput);
        xmlInbound.SetSource(inputStream);
        IF Not xmlInbound.Import() THEN BEGIN
            ErrorText := COPYSTR(GETLASTERRORTEXT(), 1, 1024);
            exit(ErrorText)
        end;
    end;



    procedure CommitStockTake(StoreCode: Code[10]; StockTakeID: Integer): Text
    var
        StoreInvLineL: Record "LSC Store Inventory Line";
        PDAStockTakeLineL: Record "GXL PDA StockTake Line";
        StoreInvWrkShtL: Record "LSC Store Inventory Worksheet";
        SKU: Record "Stockkeeping Unit";
        StrInvMgtL: Codeunit "LSC Store Inventory Management";
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
        QtyCommitted: Decimal;
    begin
        StoreInvWrkShtL.Get(StockTakeID); //PS-2393+

        PDAStockTakeLineL.Reset();
        PDAStockTakeLineL.SetRange("Stock-Take ID", StockTakeID);
        IF PDAStockTakeLineL.FindSet() then
            repeat
                StoreInvLineL.Reset();
                StoreInvLineL.Init(); //PS-2089+
                StoreInvLineL.Validate(WorksheetSeqNo, StockTakeID);
                StoreInvLineL.Validate("Line No.", PDAStockTakeLineL."Line No.");
                StoreInvLineL.Validate("Posting Date", Today());
                StoreInvLineL.Validate("Item No.", PDAStockTakeLineL."Item No.");
                StoreInvLineL.Validate("Unit of Measure Code", PDAStockTakeLineL.UOM);
                //PS-2089+
                //"Qty. (Calculated)" is the Inventory - unposted Trans Lines by standard LS
                //Change to exclude click and collect (i.e. magento suspended orders)

                SKU.Init();
                SKU."Item No." := PDAStockTakeLineL."Item No.";
                SKU."Location Code" := StoreCode;
                //PS-2393+: Moved down
                //QtyCommitted := PDAItemIntegration.GetMagentoSuspendedQty(SKU); 
                //PS-2393-: Moved down

                //Qty. Calculated is on base UOM
                //Qty. (Phys. Inventory) is on UOM which will be used to convert to Quantity (Base)
                //Quantity is the differece b/w Quantity (Base) - Qty. Calculated
                //so Quantity is always in base UOM

                //PS-2393+
                //Changed since only base UOM will be used for stocktake (re PS-2137), so SOH will be used
                if StoreInvLineL."Qty. per Unit of Measure" = 1 then
                    StoreInvLineL.Validate("Qty. (Calculated)", PDAStockTakeLineL.SOH)
                else begin
                    QtyCommitted := PDAItemIntegration.GetMagentoSuspendedQty(SKU);
                    //PS-2393-                
                    StoreInvLineL.Validate("Qty. (Calculated)", StoreInvLineL."Qty. (Calculated)" - QtyCommitted);
                end;
                //PS-2089-
                StoreInvLineL.Validate("Qty. (Phys. Inventory)", PDAStockTakeLineL."Physical Quantity");
                StoreInvLineL.Validate("Reason Code", PDAStockTakeLineL."Reson Code");
                //PS-2046+
                StoreInvLineL."GXL MIM User ID" := PDAStockTakeLineL."MIM User ID";
                if StoreInvLineL."GXL MIM User ID" = '' then
                    StoreInvLineL."GXL MIM User ID" := UserId();
                //PS-2046-
                //PS-2393+
                StoreInvLineL."GXL Stocktake Name" := StoreInvWrkShtL."GXL StockTake Description";
                //PS-2393-
                StoreInvLineL.Insert(true);
            until PDAStockTakeLineL.Next() = 0;

        PDAStockTakeLineL.Reset();
        PDAStockTakeLineL.SetRange("Stock-Take ID", StockTakeID);
        PDAStockTakeLineL.DeleteAll();


        StoreInvLineL.Reset();
        StoreInvLineL.SetRange(WorksheetSeqNo, StockTakeID);
        StoreInvLineL.SetRange(Quantity, 0);
        StoreInvLineL.DeleteAll();

        StoreInvWrkShtL.Get(StockTakeID);
        StrInvMgtL.CompressWorksheet(StoreInvWrkShtL);

        EXIT(ProcessPostStoreInv(StockTakeID));

        //exit(SucessMsg);
    end;

    local procedure SaveInputXml(xmlInput: BigText)
    begin
        // >> Upgrade
        //TempBlob.Blob.CreateOutStream(outputStream, TextEncoding::UTF16);
        TempBlob.CreateOutStream(outputStream, TextEncoding::UTF16);
        // << Upgrade
        xmlInput.Write(outputStream);
        // >> Upgrade
        //TempBlob.Blob.CreateInStream(inputStream, TextEncoding::UTF16);
        TempBlob.CreateInStream(inputStream, TextEncoding::UTF16);
        // << Upgrade
    end;

    local procedure ProcessPostStoreInv(WorksheetSeqNo: Integer): Text
    var
        StoreInventoryWorksheet: Record "LSC Store Inventory Worksheet";
        BatchPosting: Codeunit "LSC Batch Posting";
        StoreInvMgt_g: Codeunit "LSC Store Inventory Management";
        //StoreInvJournal: Page "Store Inventory Journal";
        ErrorMessage: Text;
        NothingToPostErr: Label 'Nothing to Post';
        AlreadyOnQErr: Label 'The Worksheet is already on the Batch Posting Queue.';
    //PutOnQ: Label 'The Worksheet has been put on the Batch Posting Queue.';
    begin
        StoreInventoryWorksheet.GET(WorksheetSeqNo);
        //IF NOT CheckForCompression(StoreInventoryWorksheet) THEN
        //  EXIT;
        ErrorMessage := '';
        StoreInventoryWorksheet.CALCFIELDS("No. of Lines");
        IF StoreInventoryWorksheet."No. of Lines" = 0 THEN
            ErrorMessage := NothingToPostErr;

        IF ErrorMessage = '' THEN
            IF StoreInventoryWorksheet."Use Batch Posting" THEN BEGIN
                IF BatchPosting.UpdateBatchPostingStatus(StoreInventoryWorksheet.WorksheetSeqNo) <> '' THEN
                    ERROR(AlreadyOnQErr);
                BatchPosting.ValidateSIWorksheetLines(StoreInventoryWorksheet);
                BatchPosting.QueueStoreInventoryWorksheet(StoreInventoryWorksheet);
                //MESSAGE(PutOnQ);
            END ELSE
                IF StoreInvMgt_g.WorksheetIsJournal(StoreInventoryWorksheet) THEN
                    StoreInvMgt_g.PostWorksheet(StoreInventoryWorksheet, ErrorMessage)
                ELSE
                    StoreInvMgt_g.ProcessWorksheet(StoreInventoryWorksheet, ErrorMessage);

        StoreInventoryWorksheet."GXL Date Opened" := 0D;
        StoreInventoryWorksheet."GXL StockTake Description" := '';
        StoreInventoryWorksheet."GXL User ID" := '';
        StoreInventoryWorksheet.Modify();

        Exit(ErrorMessage);
    end;

    //PS-2042+
    /*
    [EventSubscriber(ObjectType::Page, Page::"Store Inv. Worksheet Buffer", 'OnAfterGetCurrRecordEvent', '', true, true)]
    local procedure CopyStocktakeFields(var Rec: Record "Store Inv. Worksheet Buffer")
    var
        //StoreInvWorkShtBuffL: Record "Store Inv. Worksheet Buffer";
        StoreInvWorkshtL: Record "Store Inventory Worksheet";
    begin
        IF StoreInvWorkshtL.Get(Rec.WorksheetSeqNo) then begin
            StoreInvWorkshtL.CalcFields("GXL No. of Stock Take Lines", "GXL Open");
            Rec."GXL Date Opened" := StoreInvWorkshtL."GXL Date Opened";
            Rec."GXL StockTake Description" := StoreInvWorkshtL."GXL StockTake Description";
            Rec."GXL User ID" := StoreInvWorkshtL."GXL User ID";
            Rec."GXL No. of Stock Take Lines" := StoreInvWorkshtL."GXL No. of Stock Take Lines";
            Rec."GXL Open" := StoreInvWorkshtL."GXL Open";
            Rec.Modify();
        end;
    end;

    [EventSubscriber(ObjectType::Page, Page::"Store Inv. Worksheet Buffer", 'OnAfterBuildPage', '', true, true)]
    local procedure CopyStocktakeFieldsOnAfterBuildPage(var StoreInvWorksheetBuffer: Record "Store Inv. Worksheet Buffer")
    var
        StoreInvWorkShtBuffL: Record "Store Inv. Worksheet Buffer";
        StoreInvWorkshtL: Record "Store Inventory Worksheet";
    begin
        With StoreInvWorkShtBuffL DO begin
            Reset();
            if FindSet() then
                repeat
                    IF StoreInvWorkshtL.Get(WorksheetSeqNo) then begin
                        StoreInvWorkshtL.CalcFields("GXL No. of Stock Take Lines", "GXL Open");
                        "GXL Date Opened" := StoreInvWorkshtL."GXL Date Opened";
                        "GXL StockTake Description" := StoreInvWorkshtL."GXL StockTake Description";
                        "GXL User ID" := StoreInvWorkshtL."GXL User ID";
                        "GXL No. of Stock Take Lines" := StoreInvWorkshtL."GXL No. of Stock Take Lines";
                        "GXL Open" := StoreInvWorkshtL."GXL Open";
                        Modify();
                    end;
                until Next() = 0;
        end;
    end;
    */

    [EventSubscriber(ObjectType::Page, Page::"LSC Store Inv. Wrksh. Buffer", 'OnBuildPage_OnBeforeInsertInvWrkshBuffer', '', true, false)]
    local procedure OnBuilPageOnBeforeInsertWkshBuffer(var StoreInventoryWorksheet: Record "LSC Store Inventory Worksheet"; var StoreInvWorksheetBuffer: Record "LSC Store Inv. Wrksh. Buffer")
    begin
        StoreInventoryWorksheet.CalcFields("GXL No. of Stock Take Lines", "GXL Open");
        StoreInvWorksheetBuffer."GXL Date Opened" := StoreInventoryWorksheet."GXL Date Opened";
        StoreInvWorksheetBuffer."GXL StockTake Description" := StoreInventoryWorksheet."GXL StockTake Description";
        StoreInvWorksheetBuffer."GXL User ID" := StoreInventoryWorksheet."GXL User ID";
        StoreInvWorksheetBuffer."GXL No. of Stock Take Lines" := StoreInventoryWorksheet."GXL No. of Stock Take Lines";
        StoreInvWorksheetBuffer."GXL Open" := StoreInventoryWorksheet."GXL Open";
    end;

    [EventSubscriber(ObjectType::Page, Page::"LSC Store Inv. Wrksh. Buffer", 'OnBuildRec_OnBeforeModifyInvWrkshBuffer', '', true, false)]
    local procedure OnReBuilRecOnBeforeModifyWkshBuffer(var StoreInventoryWorksheet: Record "LSC Store Inventory Worksheet"; var StoreInvWorksheetBuffer: Record "LSC Store Inv. Wrksh. Buffer")
    begin
        StoreInventoryWorksheet.CalcFields("GXL No. of Stock Take Lines", "GXL Open");
        StoreInvWorksheetBuffer."GXL Date Opened" := StoreInventoryWorksheet."GXL Date Opened";
        StoreInvWorksheetBuffer."GXL StockTake Description" := StoreInventoryWorksheet."GXL StockTake Description";
        StoreInvWorksheetBuffer."GXL User ID" := StoreInventoryWorksheet."GXL User ID";
        StoreInvWorksheetBuffer."GXL No. of Stock Take Lines" := StoreInventoryWorksheet."GXL No. of Stock Take Lines";
        StoreInvWorksheetBuffer."GXL Open" := StoreInventoryWorksheet."GXL Open";
    end;
    //PS-2042-


    [EventSubscriber(ObjectType::Page, Page::"LSC Store Inv. Wrksh. Buffer", 'OnAfterActionEvent', 'Process/Post', true, false)]
    local procedure OnAfterPostActionInWorkSht(var Rec: Record "LSC Store Inv. Wrksh. Buffer")
    var
        StoreInvLineL: Record "LSC Store Inventory Line";
        StoreInvWrkShtL: Record "LSC Store Inventory Worksheet";
    begin
        StoreInvLineL.Reset();
        StoreInvLineL.SetRange(WorksheetSeqNo, Rec.WorksheetSeqNo);
        //if not StoreInvLineL.FindFirst() then begin
        if StoreInvLineL.IsEmpty() then begin
            if StoreInvWrkShtL.Get(Rec.WorksheetSeqNo) then begin
                StoreInvWrkShtL."GXL Date Opened" := 0D;
                StoreInvWrkShtL."GXL StockTake Description" := '';
                StoreInvWrkShtL."GXL User ID" := '';
                StoreInvWrkShtL.Modify();
            end;
        end;
    end;


    [EventSubscriber(ObjectType::Page, Page::"LSC Store Inventory Journal", 'OnAfterActionEvent', 'Process/Post', true, false)]
    local procedure OnAfterPostActionInJournal(var Rec: Record "LSC Store Inventory Line")
    var
        StoreInvLineL: Record "LSC Store Inventory Line";
        StoreInvWrkShtL: Record "LSC Store Inventory Worksheet";
    begin
        StoreInvLineL.Reset();
        StoreInvLineL.SetRange(WorksheetSeqNo, Rec.WorksheetSeqNo);
        //if not StoreInvLineL.FindFirst() then begin
        if StoreInvLineL.IsEmpty() then begin
            if StoreInvWrkShtL.Get(Rec.WorksheetSeqNo) then begin
                StoreInvWrkShtL."GXL Date Opened" := 0D;
                StoreInvWrkShtL."GXL StockTake Description" := '';
                StoreInvWrkShtL."GXL User ID" := '';
                StoreInvWrkShtL.Modify();
            end;
        end;
    end;


    //PS-1875+
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Store Inventory Management", 'OnAfterPostWorksheet', '', true, false)]
    local procedure OnAfterPostWorksheet_StoreInvtMgt(var StoreInventoryWorksheet: Record "LSC Store Inventory Worksheet")
    begin
        ClearDateOpened(StoreInventoryWorksheet);
        //PS-2102+
        ClearPDAStocktakeLines(StoreInventoryWorksheet);
        //PS-2102-
    end;

    local procedure ClearDateOpened(var StoreInventoryWorksheet: Record "LSC Store Inventory Worksheet")
    begin
        if (StoreInventoryWorksheet."GXL Date Opened" <> 0D) or (StoreInventoryWorksheet."GXL User ID" <> '') or
            (StoreInventoryWorksheet."GXL StockTake Description" <> '') then begin
            StoreInventoryWorksheet."GXL Date Opened" := 0D;
            StoreInventoryWorksheet."GXL User ID" := '';
            StoreInventoryWorksheet."GXL StockTake Description" := '';
            StoreInventoryWorksheet.Modify();
        end;
    end;
    //PS-1875-

    //PS-2102+
    local procedure ClearPDAStocktakeLines(var StoreInventoryWorksheet: Record "LSC Store Inventory Worksheet")
    var
        PDAStocktakeLine: Record "GXL PDA StockTake Line";
    begin
        PDAStocktakeLine.SetRange("Stock-Take ID", StoreInventoryWorksheet.WorksheetSeqNo);
        if not PDAStocktakeLine.IsEmpty() then
            PDAStocktakeLine.DeleteAll();
    end;
    //PS-2102-

    //PS-2046+
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Store Inventory Management", 'ErrorInPostWorksheet_OnBeforeStoreInvLineInError', '', true, false)]
    local procedure OnPostWkshOnBeforeInsertItemJnlLine(var TempItemJournalLine: Record "Item Journal Line"; StoreInventoryLine: Record "LSC Store Inventory Line")
    begin
        TempItemJournalLine."GXL MIM User ID" := StoreInventoryLine."GXL MIM User ID";
        //PS-2393+
        TempItemJournalLine."GXL Stocktake Name" := StoreInventoryLine."GXL Stocktake Name";
        //PS-2393-
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Store Inventory Management", 'OnCompressWorksheet_BeforeUpdateBuffer', '', true, false)]
    local procedure OnCompressWorksheetOnBeforeUpdateBuffer(var StoreInventoryLine: Record "LSC Store Inventory Line"; var StoreInventoryLineTemp: Record "LSC Store Inventory Line" temporary)
    begin
        StoreInventoryLineTemp."GXL MIM User ID" := StoreInventoryLine."GXL MIM User ID";
        //PS-2393+
        StoreInventoryLineTemp."GXL Stocktake Name" := StoreInventoryLine."GXL Stocktake Name";
        //PS-2393-
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Store Inventory Management", 'OnBeforeStoreInvLineInsertOnCompressWorksheet', '', true, false)]
    local procedure OnCompressWorksheetOnBeforeInsertStoreInvtLine(var StoreInventoryLineTemp: Record "LSC Store Inventory Line" temporary; var StoreInventoryLine: Record "LSC Store Inventory Line")
    begin
        StoreInventoryLine."GXL MIM User ID" := StoreInventoryLineTemp."GXL MIM User ID";
        //PS-2393+
        StoreInventoryLine."GXL Stocktake Name" := StoreInventoryLineTemp."GXL Stocktake Name";
        //PS-2393-
    end;
    //PS-2046-

    //PS-2163+
    local procedure ExistStocktakeWorksheet(StoreCode: Code[10]; StocktakeDescription: Text): Boolean
    var
        StoreInvtWksh: Record "LSC Store Inventory Worksheet";
    begin
        StoreInvtWksh.SetRange("Store No.", StoreCode);
        StoreInvtWksh.SetFilter("GXL StockTake Description", '@' + StocktakeDescription);
        if not StoreInvtWksh.IsEmpty() then
            exit(true)
        else
            exit(false);
    end;
    //PS-2163-
}