/// <summary>
/// ERP-NAV Master Data Management
/// </summary>
report 50019 "GXL NAV Item/SKU-Calculate SOH"
{
    Caption = 'NAV Item/SKU-Calculate SOH';
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem(ItemFilter; Item)
        {
            RequestFilterFields = "No.", "Location Filter";

            trigger OnPreDataItem()
            begin
                CurrReport.Break();
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                }
            }
        }

    }

    var
        NAVItemSKUBuffer: Record "GXL NAV Item/SKU Buffer";
        NextReplicationCounter: Integer;
        NextEntryNo: Integer;
        LastBatchNo: Integer;
        CommitEvery: Integer;
        NoOfRecs: Integer;


    trigger OnPreReport()
    begin
        NextReplicationCounter := NAVItemSKUBuffer.GetLastReplicationCounter();
        NAVItemSKUBuffer.Reset();

        CommitEvery := 100;
        NoOfRecs := 0;
        Calculate();
        Commit();
    end;

    local procedure Calculate()
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        TempItem: Record Item temporary;
        TempSKU: Record "Stockkeeping Unit" temporary;
        NAVItemSKUCalcSOHLog: Record "GXL NAV Item/SKU SOH-Calc. Log";
        ItemLegdEntry: Record "Item Ledger Entry";
        InventoryBySKUQry: Query "GXL Inventory by SKU";
        PurchOrdBySKuQry: Query "GXL Purchase Order by SKU";
        TransferBySKUQry: Query "GXL Transfer In-transit by SKU";
        LogEntryNo: Integer;
        UseLastLog: Boolean;
    begin
        if ItemFilter.GetFilters() = '' then begin
            UseLastLog := true;
            if not NAVItemSKUCalcSOHLog.FindLast() then
                UseLastLog := false;
            if ItemLegdEntry.FindLast() then;
        end else
            UseLastLog := false;

        if not UseLastLog then begin
            Item.CopyFilters(ItemFilter);
            Item.SetAutoCalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit", "GXl First Receipt Date");
            if Item.FindSet() then
                repeat
                    if (NoOfRecs <> 0) and ((NoOfRecs mod CommitEvery) = 0) then
                        Commit();
                    NoOfRecs += 1;

                    InsertNAVItemSKUBuffer(Item."No.", '', Item.Inventory, Item."Qty. on Purch. Order", Item."Qty. in Transit", Item."GXl First Receipt Date");

                    SKU.SetRange("Item No.", Item."No.");
                    if ItemFilter.GetFilter("Location Filter") <> '' then
                        SKU.SetFilter("Location Code", ItemFilter.GetFilter("Location Filter"));
                    SKU.SetAutoCalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit", "GXL First Receipt Date");
                    if SKU.FindSet(false) then
                        repeat
                            InsertNAVItemSKUBuffer(SKU."Item No.", SKU."Location Code", SKU.Inventory, SKU."Qty. on Purch. Order", SKU."Qty. in Transit", SKU."GXL First Receipt Date");
                        until SKU.Next() = 0;
                until Item.Next() = 0;

        end else begin

            LogEntryNo := NAVItemSKUCalcSOHLog."Entry No.";
            InventoryBySKUQry.SetFilter(InventoryBySKuQry.Entry_No_Filter, '>%1', NAVItemSKUCalcSOHLog."Last Item Ledger Entry No.");
            InventoryBySKUQry.Open();
            while InventoryBySKUQry.Read() do begin
                if (NoOfRecs <> 0) and ((NoOfRecs mod CommitEvery) = 0) then
                    Commit();
                if not TempItem.Get(InventoryBySKUQry.Item_No) then begin
                    NoOfRecs += 1;
                    Item.Get(InventoryBySKUQry.Item_No);
                    Item.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit", "GXl First Receipt Date");
                    InsertNAVItemSKUBuffer(Item."No.", '', Item.Inventory, Item."Qty. on Purch. Order", Item."Qty. in Transit", Item."GXl First Receipt Date");

                    TempItem := Item;
                    TempItem.Insert();
                end;
                SKU.SetRange("Item No.", InventoryBySKUQry.Item_No);
                SKU.SetRange("Location Code", InventoryBySKUQry.Location_Code);
                if SKU.FindFirst() then begin
                    SKU.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit", "GXL First Receipt Date");
                    InsertNAVItemSKUBuffer(SKU."Item No.", SKU."Location Code", SKU.Inventory, SKU."Qty. on Purch. Order", SKU."Qty. in Transit", SKU."GXL First Receipt Date");

                    TempSKU := SKU;
                    TempSKU.Insert();
                end;
            end;
            InventoryBySKUQry.Close();
            Commit;

            //purchase order
            NoOfRecs := 0;
            PurchOrdBySKuQry.Open();
            while PurchOrdBySKuQry.Read() do begin
                if (NoOfRecs <> 0) and ((NoOfRecs mod CommitEvery) = 0) then
                    Commit();
                if not TempItem.Get(PurchOrdBySKuQry.Item_No) then begin
                    NoOfRecs += 1;
                    Item.Get(PurchOrdBySKuQry.Item_No);
                    Item.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit", "GXl First Receipt Date");
                    InsertNAVItemSKUBuffer(Item."No.", '', Item.Inventory, Item."Qty. on Purch. Order", Item."Qty. in Transit", Item."GXl First Receipt Date");

                    TempItem := Item;
                    TempItem.Insert();
                end;

                TempSKU.SetRange("Item No.", PurchOrdBySKuQry.Item_No);
                TempSKU.SetRange("Location Code", PurchOrdBySKuQry.Location_Code);
                if not TempSKU.Find('-') then begin
                    SKU.SetRange("Item No.", PurchOrdBySKuQry.Item_No);
                    SKU.SetRange("Location Code", PurchOrdBySKuQry.Location_Code);
                    if SKU.FindFirst() then begin
                        SKU.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit", "GXL First Receipt Date");
                        InsertNAVItemSKUBuffer(SKU."Item No.", SKU."Location Code", SKU.Inventory, SKU."Qty. on Purch. Order", SKU."Qty. in Transit", SKU."GXL First Receipt Date");

                        TempSKU := SKU;
                        TempSKU.Insert();
                    end;
                end;
            end;
            PurchOrdBySKuQry.Close();
            Commit();

            //transfer order
            NoOfRecs := 0;
            TransferBySKUQry.Open();
            while TransferBySKUQry.Read() do begin
                if (NoOfRecs <> 0) and ((NoOfRecs mod CommitEvery) = 0) then
                    Commit();
                if not TempItem.Get(TransferBySKUQry.Item_No) then begin
                    NoOfRecs += 1;
                    Item.Get(TransferBySKUQry.Item_No);
                    Item.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit", "GXl First Receipt Date");
                    InsertNAVItemSKUBuffer(Item."No.", '', Item.Inventory, Item."Qty. on Purch. Order", Item."Qty. in Transit", Item."GXl First Receipt Date");

                    TempItem := Item;
                    TempItem.Insert();
                end;

                TempSKU.SetRange("Item No.", TransferBySKUQry.Item_No);
                TempSKU.SetRange("Location Code", TransferBySKUQry.Transfer_to_Code);
                if not TempItem.Find('-') then begin
                    SKU.SetRange("Item No.", TransferBySKUQry.Item_No);
                    SKU.SetRange("Location Code", TransferBySKUQry.Transfer_to_Code);
                    if SKU.FindFirst() then begin
                        SKU.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit", "GXL First Receipt Date");
                        InsertNAVItemSKUBuffer(SKU."Item No.", SKU."Location Code", SKU.Inventory, SKU."Qty. on Purch. Order", SKU."Qty. in Transit", SKU."GXL First Receipt Date");
                    end;
                end;
            end;
            TransferBySKUQry.Close();

            TempItem.Reset();
            TempItem.DeleteAll();
            TempSKU.Reset();
            TempSKU.DeleteAll();
        end;
        Commit();

        if ItemFilter.GetFilters() = '' then begin
            NAVItemSKUCalcSOHLog.Init();
            NAVItemSKUCalcSOHLog."Entry No." := LogEntryNo + 1;
            NAVItemSKUCalcSOHLog."Last Item Ledger Entry No." := ItemLegdEntry."Entry No.";
            NAVItemSKUCalcSOHLog.Insert(true);
        end;
    end;

    local procedure InsertNAVItemSKUBuffer(ItemNo: Code[20]; LocCode: Code[10]; QtyBase: Decimal; QtyPOBase: Decimal; QtyinTransitBase: Decimal; FirstReceiptDate: Date)
    var
        ItemUOM: Record "Item Unit of Measure";
        NAVItemSKUBuffer2: Record "GXL NAV Item/SKU Buffer";
        UOMMgt: Codeunit "Unit of Measure Management";
        QtyBase2: Decimal;
        QtyPOBase2: Decimal;
        QtyinTransitBase2: Decimal;
    begin
        ItemUOM.SetRange("Item No.", ItemNo);
        ItemUOM.SetFilter("GXL Legacy Item No.", '<>%1', '');
        if ItemUOM.FindSet(false) then
            repeat
                if ItemUOM."Qty. per Unit of Measure" = 1 then begin
                    QtyBase2 := QtyBase;
                    QtyPOBase2 := QtyPOBase;
                    QtyinTransitBase2 := QtyinTransitBase;
                end else begin
                    QtyBase2 := Round(UOMMgt.CalcQtyFromBase(QtyBase, ItemUOM."Qty. per Unit of Measure"), 1, '<');
                    QtyPOBase2 := Round(UOMMgt.CalcQtyFromBase(QtyPOBase, ItemUOM."Qty. per Unit of Measure"), 1, '<');
                    QtyinTransitBase2 := Round(UOMMgt.CalcQtyFromBase(QtyInTransitBase, ItemUOM."Qty. per Unit of Measure"), 1, '<');
                end;
                NAVItemSKUBuffer2.SetCurrentKey("Item No.", "Legacy Item No.", "Location Code");
                NAVItemSKUBuffer2.SetRange("Item No.", ItemUOM."Item No.");
                NAVItemSKUBuffer2.SetRange("Legacy Item No.", ItemUOM."GXL Legacy Item No.");
                NAVItemSKUBuffer2.SetRange("Location Code", LocCode);
                if NAVItemSKUBuffer2.FindFirst() then begin
                    if not ((NAVItemSKUBuffer2.Inventory = QtyBase2) and
                            (NAVItemSKUBuffer2."Qty. on Purch. Order" = QtyPOBase2) and
                            (NAVItemSKUBuffer2."Qty. in Transit" = QtyinTransitBase2) and
                            (NAVItemSKUBuffer2."First Receipt Date" = FirstReceiptDate)) then begin

                        NextReplicationCounter += 1;
                        NAVItemSKUBuffer2.Inventory := QtyBase2;
                        NAVItemSKUBuffer2."Qty. on Purch. Order" := QtyPOBase2;
                        NAVItemSKUBuffer2."Qty. in Transit" := QtyinTransitBase2;
                        NAVItemSKUBuffer2."First Receipt Date" := FirstReceiptDate;
                        NAVItemSKUBuffer2."Replication Counter" := NextReplicationCounter;
                        NAVItemSKUBuffer2."Date Time Modified" := CurrentDateTime();
                        NAVItemSKUBuffer2.Modify();
                    end;
                end else begin
                    if (FirstReceiptDate <> 0D) or (QtyBase2 <> 0) or (QtyPOBase2 <> 0) or (QtyinTransitBase2 <> 0) then begin
                        NextReplicationCounter += 1;
                        NAVItemSKUBuffer.Init();
                        NAVItemSKUBuffer."Item No." := ItemNo;
                        NAVItemSKUBuffer."Legacy Item No." := ItemUOM."GXL Legacy Item No.";
                        NAVItemSKUBuffer."Location Code" := LocCode;
                        NAVItemSKUBuffer."First Receipt Date" := FirstReceiptDate;
                        if ItemUOM."Qty. per Unit of Measure" = 1 then begin
                            NAVItemSKUBuffer.Inventory := QtyBase;
                            NAVItemSKUBuffer."Qty. on Purch. Order" := QtyPOBase;
                            NAVItemSKUBuffer."Qty. in Transit" := QtyInTransitBase;
                        end else begin
                            NAVItemSKUBuffer.Inventory := Round(UOMMgt.CalcQtyFromBase(QtyBase, ItemUOM."Qty. per Unit of Measure"), 1, '<');
                            NAVItemSKUBuffer."Qty. on Purch. Order" := Round(UOMMgt.CalcQtyFromBase(QtyPOBase, ItemUOM."Qty. per Unit of Measure"), 1, '<');
                            NAVItemSKUBuffer."Qty. in Transit" := Round(UOMMgt.CalcQtyFromBase(QtyInTransitBase, ItemUOM."Qty. per Unit of Measure"), 1, '<');
                        end;
                        NAVItemSKUBuffer."Date Time Created" := CurrentDateTime();
                        NAVItemSKUBuffer."Date Time Modified" := NAVItemSKUBuffer."Date Time Created";
                        NAVItemSKUBuffer."Replication Counter" := NextReplicationCounter;
                        NAVItemSKUBuffer.Insert();
                    end;
                end;
            until ItemUOM.Next() = 0;

    end;
}