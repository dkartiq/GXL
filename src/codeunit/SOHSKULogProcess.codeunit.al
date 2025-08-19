codeunit 50111 "GXL SOH SKU Log-Process"
{
    /*Change Log
        PS-2683 2021-10-15 LP: Add integration events
    */

    TableNo = "GXL SOH SKU Log";

    trigger OnRun()
    var
        SavedBatchID: Code[20];
    begin
        SavedBatchID := GlobalBatchID;
        ClearAll();
        GlobalBatchID := SavedBatchID;

        SOHSKULog := Rec;
        ProcessSOHSKULog();
        Commit();
        if SOHSKULog.Delete() then;
    end;

    var
        SOHSKULog: Record "GXL SOH SKU Log";
        TempSOHStagingData: Record "GXL SOH Staging Data" temporary;
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        GlobalBatchID: Code[20];
        QtyonHand: Decimal;
        CommitQty: Decimal;
        TempEntryNo: Integer;


    procedure SetBatchID(NewBatchID: Code[20])
    begin
        GlobalBatchID := NewBatchID;
    end;


    local procedure ProcessSOHSKULog()
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.SetRange("Item No.", SOHSKULog."Item No.");
        SKU.SetRange("Location Code", SOHSKULog."Location Code");
        if SKU.FindFirst() then
            ProcessSKU(SKU);
    end;

    local procedure CreateTempSOHStagingData(var SKU: Record "Stockkeeping Unit"; ItemUOM: Record "Item Unit of Measure")
    begin
        TempEntryNo += 1;
        TempSOHStagingData.Init();
        TempSOHStagingData."Auto ID" := TempEntryNo;
        TempSOHStagingData."Batch ID" := GlobalBatchID;
        TempSOHStagingData."Item No." := SKU."Item No.";
        TempSOHStagingData."Legacy Item No." := ItemUOM."GXL Legacy Item No.";
        TempSOHStagingData."New Qty." := LegacyItemHelpers.CalculateLegacyItemQty(ItemUOM, QtyonHand);
        TempSOHStagingData."Location Code" := SKU."Location Code";
        TempSOHStagingData."Store Code" := SKU."Location Code";
        TempSOHStagingData.UOM := ItemUOM.Code;
        if ItemUOM."Qty. per Unit of Measure" = 1 then
            TempSOHStagingData."Base SOH" := QtyonHand;
        TempSOHStagingData."Commited Qty." := LegacyItemHelpers.CalculateLegacyItemQty(ItemUOM, CommitQty, '>');
        TempSOHStagingData.Insert();
    end;

    local procedure TransferTempSOHStagingData()
    var
        SOHStagingData: Record "GXL SOH Staging Data";
    begin
        TempSOHStagingData.Reset();
        if TempSOHStagingData.FindSet() then
            repeat
                SOHStagingData.Init();
                SOHStagingData.TransferFields(TempSOHStagingData);
                SOHStagingData."Auto ID" := 0;
                SOHStagingData."Log Date" := Today();
                SOHStagingData."Log Time" := Time();
                SOHStagingData.Insert(true);
            until TempSOHStagingData.Next() = 0;
        TempSOHStagingData.DeleteAll();
    end;

    procedure ProcessSKU(var SKU: Record "Stockkeeping Unit")
    var
        ItemUOM: Record "Item Unit of Measure";
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
    begin
        TempSOHStagingData.Reset();
        TempSOHStagingData.DeleteAll();

        SKU.CalcFields(Inventory);
        QtyonHand := SKU.Inventory;

        //PS-2683 +
        OnBeforePassQuantity(SKU, QtyonHand);
        //PS-2683 -

        CommitQty := PDAItemIntegration.GetCommittedQty(SKU);
        ItemUOM.SetRange("Item No.", SKU."Item No.");
        ItemUOM.SetFilter("GXL Legacy Item No.", '<>%1', '');
        if ItemUOM.FindSet() then
            repeat
                CreateTempSOHStagingData(SKU, ItemUOM);
            until ItemUOM.Next() = 0;

        TransferTempSOHStagingData();
    end;

    //PS-2683 +
    [IntegrationEvent(false, false)]
    local procedure OnBeforePassQuantity(var StockkeepingUnit: Record "Stockkeeping Unit"; var QtyonHandEvent: Decimal)
    begin
    end;
    //PS-2683 -
}