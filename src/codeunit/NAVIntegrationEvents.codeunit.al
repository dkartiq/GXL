codeunit 50140 "GXL NAV Integration Events"
{
    trigger OnRun()
    begin

    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Shipment", 'OnAfterInsertTransShptLine', '', true, true)]
    local procedure TransferShipNegativeStockAdjBuffer(TransLine: Record "Transfer Line"; var TransShptLine: Record "Transfer Shipment Line")
    var
        PDAStockAdjProcessBuffL: Record "GXL PDA-StAdjProcessing Buffer";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
    begin
        if TransShptLine.Quantity = 0 then
            exit;

        //ERP-NAV Master Data Management +
        IntegrationSetup.Get();
        if IntegrationSetup."Sync NAV-13 Inactive" then
            exit;
        //ERP-NAV Master Data Management -

        //Only sync back to NAV13 for store-to-store transfer
        if not TransLine.GXL_CheckStoreToStoreTransfer() then
            exit;

        PDAStockAdjProcessBuffL.Reset();
        PDAStockAdjProcessBuffL.Init();
        PDAStockAdjProcessBuffL."Entry No." := 0;
        PDAStockAdjProcessBuffL.Type := PDAStockAdjProcessBuffL.Type::ADJ;
        PDAStockAdjProcessBuffL."Store Code" := TransLine."Transfer-from Code";
        PDAStockAdjProcessBuffL."Item No." := TransShptLine."Item No.";
        PDAStockAdjProcessBuffL."Unit of Measure Code" := TransShptLine."Unit of Measure Code";
        PDAStockAdjProcessBuffL."Stock on Hand" := -TransShptLine.Quantity;
        PDAStockAdjProcessBuffL."Legacy Item No." := TransLine."GXL Legacy Item No.";
        if PDAStockAdjProcessBuffL."Legacy Item No." = '' then
            LegacyItemHelpers.GetLegacyItemNo(TransShptLine."Item No.", TransShptLine."Unit of Measure Code", PDAStockAdjProcessBuffL."Legacy Item No.");
        PDAStockAdjProcessBuffL."Document No." := TransShptLine."Document No.";
        PDAStockAdjProcessBuffL."Reason Code" := 'ADJ';
        PDAStockAdjProcessBuffL.Processed := true;
        PDAStockAdjProcessBuffL.SetRMSID(); //<< PS-1386
        PDAStockAdjProcessBuffL.Insert(true);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"TransferOrder-Post Receipt", 'OnAfterInsertTransRcptLine', '', true, true)]
    local procedure TransferRcptPositiveStockAdjBuffer(TransLine: Record "Transfer Line"; var TransRcptLine: Record "Transfer Receipt Line")
    var
        PDAStockAdjProcessBuffL: Record "GXL PDA-StAdjProcessing Buffer";
        PDAReceivingBuffer: Record "GXL PDA-PL Receive Buffer"; // >> LCB-227 <<
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
    begin
        if TransRcptLine.Quantity = 0 then
            exit;

        // >> LCB-227
        PdaReceivingBuffer.SetRange("Entry Type", PdaReceivingBuffer."Entry Type"::Transfer);
        PdaReceivingBuffer.SetRange("Document No.", TransRcptLine."Transfer Order No.");
        PdaReceivingBuffer.SetRange("Receipt Type", PDAReceivingBuffer."Receipt Type"::Full);
        IF PdaReceivingBuffer.IsEmpty then begin
            PdaReceivingBuffer.SetRange("Receipt Type");
            PdaReceivingBuffer.SetRange(PdaReceivingBuffer."Line No.", TransRcptLine."Line No.");
            PdaReceivingBuffer.SetRange("No.", TransRcptLine."Item No.");
        end;
        if PdaReceivingBuffer.FindSet() then
            repeat
                if PdaReceivingBuffer.Status IN [PdaReceivingBuffer.Status::"Processing Error", PdaReceivingBuffer.Status::"Receiving Error"] then begin
                    PdaReceivingBuffer.Validate(Processed, true);
                    PdaReceivingBuffer.Validate(Status, PdaReceivingBuffer.Status::Received);
                    PdaReceivingBuffer.ClearError(PdaReceivingBuffer);
                end;
            until PdaReceivingBuffer.Next() = 0;
        // << LCB-227

        //Only sync back to NAV13 for store-to-store transfer
        if not TransLine.GXL_CheckStoreToStoreTransfer() then
            exit;

        //ERP-NAV Master Data Management +
        IntegrationSetup.Get();
        if IntegrationSetup."Sync NAV-13 Inactive" then
            exit;
        //ERP-NAV Master Data Management -

        PDAStockAdjProcessBuffL.Reset();
        PDAStockAdjProcessBuffL.Init();
        PDAStockAdjProcessBuffL."Entry No." := 0;
        PDAStockAdjProcessBuffL.Type := PDAStockAdjProcessBuffL.Type::ADJ;
        PDAStockAdjProcessBuffL."Store Code" := TransLine."Transfer-to Code";
        PDAStockAdjProcessBuffL."Item No." := TransRcptLine."Item No.";
        PDAStockAdjProcessBuffL."Unit of Measure Code" := TransRcptLine."Unit of Measure Code";
        PDAStockAdjProcessBuffL."Stock on Hand" := TransRcptLine.Quantity;
        PDAStockAdjProcessBuffL."Legacy Item No." := TransLine."GXL Legacy Item No.";
        if PDAStockAdjProcessBuffL."Legacy Item No." = '' then
            LegacyItemHelpers.GetLegacyItemNo(TransRcptLine."Item No.", TransRcptLine."Unit of Measure Code", PDAStockAdjProcessBuffL."Legacy Item No.");
        PDAStockAdjProcessBuffL."Document No." := TransRcptLine."Document No.";
        PDAStockAdjProcessBuffL."Reason Code" := 'ADJ';
        PDAStockAdjProcessBuffL.Processed := true;
        PDAStockAdjProcessBuffL.SetRMSID(); //<< PS-1386
        PDAStockAdjProcessBuffL.Insert(true);

    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item Jnl.-Post Line", 'OnAfterPostItemJnlLine', '', true, true)]
    local procedure ItemJournalPositiveAdj(var ItemJournalLine: Record "Item Journal Line")
    var
        PDAStockAdjProcessBuffL: Record "GXL PDA-StAdjProcessing Buffer";
        ItemUOML: Record "Item Unit of Measure";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        OKToPost: Boolean;
    begin
        if ItemJournalLine.Quantity = 0 then
            exit;

        OKToPost := false;
        if (ItemJournalLine."Entry Type" IN [ItemJournalLine."Entry Type"::"Positive Adjmt.", ItemJournalLine."Entry Type"::"Negative Adjmt."]) AND ItemJournalLine."Phys. Inventory" then
            OKToPost := true;

        if ItemJournalLine."GXL POS Adjustment" then
            OKToPost := true;

        If OKToPost then begin
            //ERP-NAV Master Data Management +
            IntegrationSetup.Get();
            if IntegrationSetup."Sync NAV-13 Inactive" then
                exit;
            //ERP-NAV Master Data Management -

            if ItemUOML.Get(ItemJournalLine."Item No.", ItemJournalLine."Unit of Measure Code") then begin
                PDAStockAdjProcessBuffL.Reset();
                PDAStockAdjProcessBuffL."Entry No." := 0;
                PDAStockAdjProcessBuffL.Type := PDAStockAdjProcessBuffL.Type::ADJ;
                if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::"Negative Adjmt." then
                    PDAStockAdjProcessBuffL."Stock on Hand" := -ItemJournalLine.Quantity;
                if ItemJournalLine."Entry Type" = ItemJournalLine."Entry Type"::"Positive Adjmt." then
                    PDAStockAdjProcessBuffL."Stock on Hand" := ItemJournalLine.Quantity;
                PDAStockAdjProcessBuffL."Store Code" := ItemJournalLine."Location Code";
                PDAStockAdjProcessBuffL."Item No." := ItemJournalLine."Item No.";
                PDAStockAdjProcessBuffL."Unit of Measure Code" := ItemJournalLine."Unit of Measure Code";
                LegacyItemHelpers.GetLegacyItemNo(ItemUOML, PDAStockAdjProcessBuffL."Legacy Item No.");
                PDAStockAdjProcessBuffL."Document No." := ItemJournalLine."Document No.";
                PDAStockAdjProcessBuffL."Reason Code" := ItemJournalLine."Reason Code";
                PDAStockAdjProcessBuffL.Processed := true;
                PDAStockAdjProcessBuffL.SetRMSID(); //<< PS-1386
                PDAStockAdjProcessBuffL.Insert(true);
            end;
        end;
    end;

}