codeunit 50110 "GXL SOH Event Subcribers"
{
    trigger OnRun()
    begin

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInsertItemLedgEntry', '', true, true)]
    local procedure MarkItemWithInventoryChanged(var ItemLedgerEntry: Record "Item Ledger Entry")
    var
        //ItemL: Record Item;
        //SKUL: Record "Stockkeeping Unit";
        SOHSKULog: Record "GXL SOH SKU Log";
    begin
        //>> PS-1392
        /*
        IF ItemL.Get(ItemLedgerEntry."Item No.") then begin
            if not ItemL."GXL Inventory Changed" then begin
                ItemL."GXL Inventory Changed" := true;
                ItemL.Modify();
            end;
            IF SKUL.Get(ItemLedgerEntry."Item No.", ItemLedgerEntry."Variant Code", ItemLedgerEntry."Location Code") then begin
                SKUL."GXL Inventory Changed" := true;
                SKUL.Modify();
            end;
        end;
        */
        SOHSKULog.InsertLogFromItemLedgerEntry(ItemLedgerEntry);
        //<< PS-1392
    end;

    //Removed as cost is not required to be transferred for SOH
    /*
    [EventSubscriber(ObjectType::Codeunit, Codeunit::ItemCostManagement, 'OnUpdateUnitCostSKUOnBeforeMatchSKU', '', true, true)]
    local procedure MarkSKUWithInventoryChanged(var StockkeepingUnit: Record "Stockkeeping Unit"; Item: Record Item)
    var
        SOHSKULog: Record "GXL SOH SKU Log";
    begin
        //>> PS-1392
        //StockkeepingUnit."GXL Inventory Changed" := true;
        SOHSKULog.InsertLogFromSKU(StockkeepingUnit);
        //<< PS-1392
    end;
    */


}