codeunit 50353 "GXL Item Jnl. Post. Event Subs"
{
    var
        WmsSingleInstance: Codeunit "GXL WMS Single Instance";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Batch", 'OnBeforeUpdateDeleteLines', '', true, false)]
    local procedure IJPBOnBeforeUpdateDeleteLines(VAR ItemJournalLine: Record "Item Journal Line"; ItemRegNo: Integer)
    var
        TempWHMessageLines: Record "GXL WH Message Lines" temporary;
        WHMessageLines: Record "GXL WH Message Lines";
    begin
        WmsSingleInstance.Get3PLBuffer(TempWHMessageLines);
        if TempWHMessageLines.FindSet() then
            repeat
                WHMessageLines.GET(TempWHMessageLines."Document No.", TempWHMessageLines."Line No.", TempWHMessageLines."Import Type");
                WHMessageLines.Processed := true;
                WHMessageLines.MODIFY(TRUE);
            until TempWHMessageLines.Next() = 0;
    end;

    //PS-2046+
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitItemLedgEntry', '', true, false)]
    local procedure OnAfterInitItemLedgEntry(ItemJournalLine: Record "Item Journal Line"; var NewItemLedgEntry: Record "Item Ledger Entry")
    begin
        NewItemLedgEntry."GXL MIM User ID" := ItemJournalLine."GXL MIM User ID";
    end;
    //PS-2046-

    //ERP-320+
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterInitValueEntry', '', true, false)]
    local procedure OnAfterInitValueEntry(ItemJournalLine: Record "Item Journal Line"; var ValueEntry: Record "Value Entry"; var ValueEntryNo: Integer)
    begin
        if (ItemJournalLine."Value Entry Type" = ItemJournalLine."Value Entry Type"::Revaluation) and (ItemJournalLine."Inventory Posting Group" <> '') then
            ValueEntry."Inventory Posting Group" := ItemJournalLine."Inventory Posting Group";
    end;
    //ERP-320-

    //PS-2393+
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnBeforeInsertPhysInvtLedgEntry', '', true, false)]
    local procedure OnBeforeInsertPhysInvtLedgEntry(ItemJournalLine: Record "Item Journal Line"; var PhysInventoryLedgerEntry: Record "Phys. Inventory Ledger Entry")
    begin
        PhysInventoryLedgerEntry."GXL MIM User ID" := ItemJournalLine."GXL MIM User ID";
        PhysInventoryLedgerEntry."GXL Stocktake Name" := ItemJournalLine."GXL Stocktake Name";
        if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::"Negative Adjmt." then begin
            PhysInventoryLedgerEntry."GXL Standard Cost Amount" := -ItemJournalLine."GXL Standard Cost Amount";
            PhysInventoryLedgerEntry."GXL Item Ledger Quantity" := -ItemJournalLine.Quantity;
            PhysInventoryLedgerEntry."GXL Item Ledger Amount" := -ItemJournalLine.Amount;
        end else begin
            PhysInventoryLedgerEntry."GXL Standard Cost Amount" := ItemJournalLine."GXL Standard Cost Amount";
            PhysInventoryLedgerEntry."GXL Item Ledger Quantity" := ItemJournalLine.Quantity;
            PhysInventoryLedgerEntry."GXL Item Ledger Amount" := ItemJournalLine.Amount;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Journal Line", 'OnAfterValidateEvent', 'Qty. (Phys. Inventory)', true, false)]
    local procedure OnAfterValidateQtyPhysInventory_ItemJnlLine(var Rec: Record "Item Journal Line")
    begin
        if Rec."Phys. Inventory" then
            Rec.GXLUpdateCostAmount();
    end;
    //PS-2393-
}