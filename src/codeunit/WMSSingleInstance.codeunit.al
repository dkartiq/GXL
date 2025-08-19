codeunit 50352 "GXL WMS Single Instance"
{
    SingleInstance = true;

    var
        TempWHMessageLines: Record "GXL WH Message Lines" temporary;
        VendorExportFileName: Text;
        EDIFileLogEntryNo: Integer;
        EDIPartnerNo: Code[20];
        FilePath: Text;
        GXLAutomaticStockPostTrans: Codeunit "GXL Automatic Stock Post Trans";
        GXL_IsReturnNonSaleable: Boolean;
        GXL_ReturnReasonCode: Code[10];
        GXL_ItemPostingBuffer: array[2] of Record "LSC Item Posting Buffer" temporary;
        Text001: Label 'Table %1 is not temporary';
        LineCounter: Integer;
        glUndoItemPosting: Boolean;
        BackOfficeSetup: Record "LSC Retail Setup";
        GlobalStatement: Record "LSC Statement";
        Store: Record "LSC Store";
        StatementPost: Codeunit "LSC Statement-Post";
        TransPostingFunctions: Codeunit "LSC Trans. Posting Functions";
        MCSHideDialog: Boolean;

    procedure Init3PLBuffer(VAR InputTempWHMessageLines: Record "GXL WH Message Lines" TEMPORARY)
    begin
        TempWHMessageLines.COPY(InputTempWHMessageLines, TRUE);
    end;

    procedure Get3PLBuffer(VAR OutputTempWHMessageLines: Record "GXL WH Message Lines" TEMPORARY)
    begin
        OutputTempWHMessageLines.Copy(TempWHMessageLines, true);
    end;

    procedure SetVendorExportFileName(NewVendorExportFileName: Text)
    begin
        VendorExportFileName := NewVendorExportFileName;
    end;

    procedure GetVendorExportFileName(): Text
    begin
        exit(VendorExportFileName);
    end;

    procedure SetEDIFileLogEntryNo(NewEDIFileLogEntryNo: Integer)
    begin
        EDIFileLogEntryNo := NewEDIFileLogEntryNo;
    end;

    procedure GetEDIFileLogEntryNo(): Integer
    begin
        exit(EDIFileLogEntryNo);
    end;

    procedure SetEDIPartnerNo(NewEDIPartnerNo: Code[20])
    begin
        EDIPartnerNo := NewEDIPartnerNo;
    end;

    procedure GetEDIPartnerNo(): Code[20]
    begin
        exit(EDIPartnerNo);
    end;

    procedure GetFilePath(): Text
    begin
        exit(FilePath);
    end;

    procedure SetFilePath(NewFilePath: Text)
    begin
        FilePath := NewFilePath;
    end;

    //REF-R051----------------------------------------------------
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", OnBeforeProcessTransactionStatus, '', false, false)]
    local procedure OnBeforeProcessTransactionStatus(var TransactionStatus: Record "LSC Transaction Status"; Statement: Record "LSC Statement");
    var
        IntegrationSetup: Record "GXL Integration Setup";
    begin
        GXL_IsReturnNonSaleable := GXLAutomaticStockPostTrans.CheckReturnCodeNonSaleable(TransactionStatus."Store No.", TransactionStatus."POS Terminal No.", TransactionStatus."Transaction No.");
        if GXL_ReturnReasonCode = '' then begin
            if IntegrationSetup.Get() then
                GXL_ReturnReasonCode := IntegrationSetup."POS Return Non-Saleable Reason";
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", OnBeforeStatementPost, '', false, false)]
    local procedure OnBeforeStatementPost(var Statement: Record "LSC Statement"; var IsHandled: Boolean);
    begin
        DeleteItemPostingBuffer(1);
        DeleteItemPostingBuffer(2);
        GlobalStatement := Statement;
        BackOfficeSetup.Get();
        Store.Get(Statement."Store No.");
        TransPostingFunctions.InitFunction();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", OnBeforeDeleteStatement, '', false, false)]
    local procedure OnBeforeDeleteStatement(var Statement: Record "LSC Statement");
    begin
        //>> MCS1.00:PS-1685
        GXL_PostReturnNonSaleableItems(Statement);
        GXL_ItemPostingBuffer[1].DELETEALL;
        //<< MCS1.00:PS-1685
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", OnBeforeInsertItemPostingBufferSales, '', false, false)]
    local procedure OnBeforeInsertItemPostingBufferSales(var ItemPostingBuffer: Record "LSC Item Posting Buffer"; var TransSalesEntry: Record "LSC Trans. Sales Entry"; var TransactionHeader: Record "LSC Transaction Header");
    begin
        //>> MCS1.00:PS-1865
        IF GXL_IsReturnNonSaleable AND (TransSalesEntry.Quantity > 0) THEN
            GXL_FillItemPostingBufferForReturnNonSaleable(ItemPostingBuffer, TransSalesEntry, TransactionHeader);
        //<< MCS1.00:PS-1865
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", OnBeforeRunItemPosting, '', false, false)]
    local procedure OnBeforeRunItemPosting(var Statement: Record "LSC Statement"; UndoItemPosting: Boolean; var IsHandled: Boolean; var locStatement: Record "LSC Statement");
    begin
        glUndoItemPosting := UndoItemPosting;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", OnAfterStatementPost, '', false, false)]
    local procedure OnAfterStatementPost(var Statement: Record "LSC Statement");
    begin
        DeleteItemPostingBuffer(1);
        DeleteItemPostingBuffer(2);
    end;

    local procedure DeleteItemPostingBuffer(Index: Integer)
    begin
        if not GXL_ItemPostingBuffer[Index].IsTemporary then
            Error(Text001, GXL_ItemPostingBuffer[Index].TableCaption);
        GXL_ItemPostingBuffer[Index].Reset();
        GXL_ItemPostingBuffer[Index].DeleteAll();
    end;

    local procedure GXL_PostReturnNonSaleableItems(var Statement: Record "LSC Statement")
    begin
        //MCS1.00:PS-1865
        GXL_ItemPostingBuffer[1].RESET;
        IF GXL_ItemPostingBuffer[1].FINDSET THEN
            REPEAT
                //LineCounter := LineCounter + 1;
                //IF NOT Statement.Debugmode THEN
                //Win.UPDATE(6,LineCounter);
                GXL_PostReturnNonSaleableItemAdj(Statement);
            UNTIL GXL_ItemPostingBuffer[1].NEXT = 0;
    end;

    local procedure GXL_FillItemPostingBufferForReturnNonSaleable(ItemPostingBuffer: Record "LSC Item Posting Buffer"; TransSalesEntry: Record "LSC Trans. Sales Entry"; Transaction: Record "LSC Transaction Header")
    var
        myInt: Integer;
    begin
        //MCS1.00:PS-1865
        CLEAR(GXL_ItemPostingBuffer[1]);
        GXL_ItemPostingBuffer[1].Type := GXL_ItemPostingBuffer[1].Type::NegAdjust;

        GXL_ItemPostingBuffer[1]."Serial No." := TransSalesEntry."Serial No.";
        GXL_ItemPostingBuffer[1]."Lot No." := TransSalesEntry."Lot No.";
        GXL_ItemPostingBuffer[1]."Expiration Date" := TransSalesEntry."Expiration Date";
        GXL_ItemPostingBuffer[1]."Item No." := TransSalesEntry."Item No.";

        GXL_ItemPostingBuffer[1]."Location Code" := ItemPostingBuffer."Location Code";
        GXL_ItemPostingBuffer[1]."Department Code" := ItemPostingBuffer."Department Code";
        GXL_ItemPostingBuffer[1]."Document No." := ItemPostingBuffer."Document No.";
        IF glUndoItemPosting THEN
            GXL_ItemPostingBuffer[1].Quantity := -TransSalesEntry.Quantity
        ELSE
            GXL_ItemPostingBuffer[1].Quantity := TransSalesEntry.Quantity;
        GXL_ItemPostingBuffer[1]."Neg. Qty" := GXL_ItemPostingBuffer[1].Quantity <= 0;
        GXL_ItemPostingBuffer[1].Amount := TransSalesEntry."Net Amount";
        GXL_ItemPostingBuffer[1]."Cost Amount" := TransSalesEntry."Cost Amount";

        GXL_ItemPostingBuffer[1]."Offer No." := TransSalesEntry."Periodic Disc. Group";
        GXL_ItemPostingBuffer[1]."Promotion No." := TransSalesEntry."Promotion No.";
        GXL_ItemPostingBuffer[1]."Sales Type" := ItemPostingBuffer."Sales Type";

        IF TransSalesEntry."Variant Code" <> '' THEN
            GXL_ItemPostingBuffer[1]."Source No." := TransSalesEntry."Variant Code";
        IF Transaction."To Account" THEN
            GXL_ItemPostingBuffer[1]."Customer No." := ItemPostingBuffer."Customer No.";

        IF glUndoItemPosting THEN BEGIN
            GXL_ItemPostingBuffer[1].Amount := -GXL_ItemPostingBuffer[1].Amount;
            GXL_ItemPostingBuffer[1]."Cost Amount" := -GXL_ItemPostingBuffer[1]."Cost Amount";
        END;
        IF TransSalesEntry."Variant Code" <> '' THEN
            GXL_ItemPostingBuffer[1]."Source No." := TransSalesEntry."Variant Code";

        IF BackOfficeSetup."Item Posting Date" = BackOfficeSetup."Item Posting Date"::"Transaction Date" THEN
            GXL_ItemPostingBuffer[1].Date := Transaction.Date
        ELSE
            GXL_ItemPostingBuffer[1].Date := GlobalStatement."Posting Date";

        GXL_ItemPostingBuffer[1]."Salesperson Code" := ItemPostingBuffer."Salesperson Code";

        GXL_UpdItemPostingBuffer;
    end;

    local procedure GXL_UpdItemPostingBuffer()
    begin
        //MCS1.00:PS-1865
        GXL_ItemPostingBuffer[2] := GXL_ItemPostingBuffer[1];
        IF GXL_ItemPostingBuffer[2].FIND THEN BEGIN
            GXL_SumItemPostingBuffer(2);
        END ELSE BEGIN
            GXL_ItemPostingBuffer[1].INSERT;
        END;
    end;

    local procedure GXL_SumItemPostingBuffer(SumToIndex: Integer)
    var
        myInt: Integer;
    begin
        //MCS1.00:PS-1865
        GXL_ItemPostingBuffer[SumToIndex].Quantity := GXL_ItemPostingBuffer[2].Quantity +
        GXL_ItemPostingBuffer[1].Quantity;
        GXL_ItemPostingBuffer[SumToIndex].Amount := GXL_ItemPostingBuffer[2].Amount +
        GXL_ItemPostingBuffer[1].Amount;
        GXL_ItemPostingBuffer[SumToIndex]."Cost Amount" := GXL_ItemPostingBuffer[2]."Cost Amount" +
        GXL_ItemPostingBuffer[1]."Cost Amount";
        GXL_ItemPostingBuffer[SumToIndex].MODIFY;
    end;

    local procedure GXL_PostReturnNonSaleableItemAdj(Var Statement: Record "LSC Statement")
    var
        Item: Record Item;
        ItemJnlLine: Record "Item Journal Line";
        GenPostingSetup: Record "General Posting Setup";
        Cust: Record Customer;
        RBOtoAdjust: Record "LSC Adj. Item Ledgers for RBO";
        AdjustedUnitCost: Decimal;
        DiscBuffer: Record "LSC Discount Ledger Entry" temporary;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        CodeDictionary_l: Dictionary of [Integer, Code[20]];
        DimSource_l: List of [Dictionary of [Integer, Code[20]]];
        RetailItemJnlExt: Codeunit "LSC Retail Item Jnl. Ext.";
    begin
        //MCS1.00:PS-1865

        GXL_ItemPostingBuffer[1].Quantity := ROUND(GXL_ItemPostingBuffer[1].Quantity, 0.00001);

        IF GXL_ItemPostingBuffer[1].Quantity <> 0 THEN BEGIN
            Item.GET(GXL_ItemPostingBuffer[1]."Item No.");
            IF (FORMAT(Item."LSC Lifecycle Length") <> '') AND
                (Item."LSC Lifecycle Starting Date" = 0D) THEN BEGIN
                Item."LSC Lifecycle Starting Date" := TODAY;
                Item."LSC Lifecycle Ending Date" := CALCDATE(Item."LSC Lifecycle Length", TODAY);
                Item.MODIFY;
            END;
            IF Item.Type <> Item.Type::"Non-Inventory" THEN BEGIN
                TransPostingFunctions.SetItemBlockReserve(Item."No.");
                CLEAR(ItemJnlLine);
                ItemJnlLine.INIT;
                ItemJnlLine."Item No." := GXL_ItemPostingBuffer[1]."Item No.";
                ItemJnlLine."Variant Code" := GXL_ItemPostingBuffer[1]."Source No.";
                ItemJnlLine."Posting Date" := GXL_ItemPostingBuffer[1].Date;
                ItemJnlLine."Document Date" := Statement."Posting Date";
                ItemJnlLine.VALIDATE("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
                ItemJnlLine."Document No." := GXL_ItemPostingBuffer[1]."Document No.";
                ItemJnlLine."External Document No." := GXL_ItemPostingBuffer[1]."Document No.";
                ItemJnlLine.Description := Item.Description;
                ItemJnlLine."Location Code" := GXL_ItemPostingBuffer[1]."Location Code";
                ItemJnlLine."Inventory Posting Group" := Item."Inventory Posting Group";
                ItemJnlLine."Source Posting Group" := '';
                IF Item."Base Unit of Measure" <> '' THEN BEGIN
                    ItemJnlLine.VALIDATE("Unit of Measure Code", Item."Base Unit of Measure");
                    ItemJnlLine.VALIDATE(Quantity, GXL_ItemPostingBuffer[1].Quantity);
                END ELSE BEGIN
                    ItemJnlLine."Unit of Measure Code" := '';
                    ItemJnlLine."Qty. per Unit of Measure" := 1;
                    ItemJnlLine.VALIDATE("Quantity (Base)", GXL_ItemPostingBuffer[1].Quantity);
                END;
                ItemJnlLine."LSC BO Doc. No." := Statement."Posting No.";
                IF Statement."Posting No." = '' THEN
                    ItemJnlLine."LSC BO Doc. No." := Statement."No.";
                ItemJnlLine."Unit Amount" := ROUND(GXL_ItemPostingBuffer[1].Amount / GXL_ItemPostingBuffer[1].Quantity);
                ItemJnlLine.Amount := GXL_ItemPostingBuffer[1].Amount;
                ItemJnlLine."Salespers./Purch. Code" := GXL_ItemPostingBuffer[1]."Salesperson Code";
                ItemJnlLine."Source Code" := BackOfficeSetup."Source Code";
                ItemJnlLine."Gen. Bus. Posting Group" := Store."Store Gen. Bus. Post. Gr.";
                ItemJnlLine."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                ItemJnlLine."LSC Offer No." := GXL_ItemPostingBuffer[1]."Offer No.";
                ItemJnlLine."LSC Promotion No." := GXL_ItemPostingBuffer[1]."Promotion No.";
                ItemJnlLine."Reason Code" := GXL_ReturnReasonCode;

                ItemJnlLine."Expiration Date" := GXL_ItemPostingBuffer[1]."Expiration Date";
                IF (GXL_ItemPostingBuffer[1]."Serial No." <> '') OR (GXL_ItemPostingBuffer[1]."Lot No." <> '') THEN
                    TransPostingFunctions.AddSerialNoAndLotNoTracking(ItemJnlLine, GXL_ItemPostingBuffer[1]."Serial No.", GXL_ItemPostingBuffer[1]."Lot No.", GXL_ItemPostingBuffer[1]."Expiration Date");

                IF GXL_ItemPostingBuffer[1]."Customer No." <> '' THEN BEGIN
                    Cust.GET(GXL_ItemPostingBuffer[1]."Customer No.");
                    GenPostingSetup.GET(Cust."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group");
                    ItemJnlLine."Gen. Bus. Posting Group" := Cust."Gen. Bus. Posting Group";
                    ItemJnlLine."Source No." := GXL_ItemPostingBuffer[1]."Customer No.";
                    ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Customer;
                END;

                CodeDictionary_l.Add(Database::Item, ItemJnlLine."Item No.");
                AddToDimList(CodeDictionary_l, DimSource_l);
                CodeDictionary_l.Add(Database::"LSC Store", Store."No.");
                AddToDimList(CodeDictionary_l, DimSource_l);
                IF GXL_ItemPostingBuffer[1]."Customer No." <> '' THEN BEGIN
                    CodeDictionary_l.Add(Database::Customer, GXL_ItemPostingBuffer[1]."Customer No.");
                    AddToDimList(CodeDictionary_l, DimSource_l);
                END;
                IF GXL_ItemPostingBuffer[1]."Salesperson Code" <> '' THEN BEGIN
                    CodeDictionary_l.Add(Database::"Salesperson/Purchaser", GXL_ItemPostingBuffer[1]."Salesperson Code");
                    AddToDimList(CodeDictionary_l, DimSource_l);
                END;
                IF GXL_ItemPostingBuffer[1]."Sales Type" <> '' THEN BEGIN
                    CodeDictionary_l.Add(Database::"LSC Sales Type", GXL_ItemPostingBuffer[1]."Sales Type");
                    AddToDimList(CodeDictionary_l, DimSource_l);
                END;

                StatementPost.CreateItemJnlLineDim(ItemJnlLine, DimSource_l, '');

                ItemJnlPostLine.RunWithCheck(ItemJnlLine);

                TransPostingFunctions.ResetItemBlockReserve;
                IF BackOfficeSetup."Update Cost Amount" THEN BEGIN
                    IF NOT RBOtoAdjust.FINDLAST THEN
                        RBOtoAdjust."Entry No." := 0;
                    RBOtoAdjust.INIT;
                    RBOtoAdjust."Entry No." += 1;
                    RBOtoAdjust."Item Ledger No." := RetailItemJnlExt.GetItemLedgEntryNo;
                    RBOtoAdjust."Item No." := ItemJnlLine."Item No.";
                    RBOtoAdjust."Adjusted Qty." := -ItemJnlLine.Quantity;
                    AdjustedUnitCost := (GXL_ItemPostingBuffer[1]."Cost Amount" / GXL_ItemPostingBuffer[1].Quantity) - ItemJnlLine."Unit Cost";
                    RBOtoAdjust."Adjusted Amount" := AdjustedUnitCost * GXL_ItemPostingBuffer[1].Quantity;
                    RBOtoAdjust."RBO No." := COPYSTR(ItemJnlLine."External Document No.", 1, MAXSTRLEN(RBOtoAdjust."RBO No."));
                    RBOtoAdjust.Date := TODAY;
                    RBOtoAdjust.Time := TIME;
                    IF RBOtoAdjust."Adjusted Amount" <> 0 THEN
                        RBOtoAdjust.INSERT;
                END;
            END;
        END;
    end;

    local procedure AddToDimList(var CodeDictionary_p: Dictionary of [Integer, Code[20]]; var DimSource_p: List of [Dictionary of [Integer, Code[20]]])
    begin
        DimSource_p.Add(CodeDictionary_p);
        Clear(CodeDictionary_p);
    end;
    //-----------------------------------------------------------

    //R128-BEGIN------------------------------------------
    procedure MCSSetHideDialog(NewHideDialog: Boolean)
    begin
        MCSHideDialog := NewHideDialog;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Inventory Adjustment", OnBeforeOpenWindow, '', false, false)]
    local procedure OnBeforeOpenWindow(var IsHandled: Boolean);
    begin
        if MCSHideDialog then
            IsHandled := true;        
    end;
    //R128-END--------------------------------------------
}