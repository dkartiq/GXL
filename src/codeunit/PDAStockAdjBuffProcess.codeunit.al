codeunit 50267 "GXL PDA Stock Adj Buff Process"
{
    TableNo = "GXL PDA-StAdjProcessing Buffer";

    //This codeunit is mainly used for non-claimable PDA stock adjustment

    trigger OnRun()
    var
        Item: Record Item;
        ItemJnlLine: Record "Item Journal Line";
        IntegrationSetup: Record "GXL Integration Setup";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        DimValCode: Code[20];
    begin
        PDAStockAdjProcessingBuffer := Rec;
        //if not ValidatePDAStockAdjustmentBuffer(PDAStockAdjProcessingBuffer) then
        //    exit;
        //PS-2210+
        CheckUOM(PDAStockAdjProcessingBuffer);
        //PS-2210-

        IntegrationSetup.Get();

        ItemJnlLine.Init();
        ItemJnlLine."Posting Date" := DT2Date((PDAStockAdjProcessingBuffer."Created Date Time"));
        if PDAStockAdjProcessingBuffer."Stock on Hand" > 0 then
            ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Positive Adjmt."
        else
            ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt.";
        ItemJnlLine.Validate("Entry Type");
        ItemJnlLine.Validate("Item No.", PDAStockAdjProcessingBuffer."Item No.");
        ItemJnlLine."Document No." := GetJnlDocumentNo(PDAStockAdjProcessingBuffer);
        ItemJnlLine.Validate("Location Code", PDAStockAdjProcessingBuffer."Store Code");
        if PDAStockAdjProcessingBuffer."Unit of Measure Code" <> '' then
            ItemJnlLine.Validate("Unit of Measure Code", PDAStockAdjProcessingBuffer."Unit of Measure Code")
        else
            if ItemJnlLine."Unit of Measure Code" = '' then begin
                Item.Get(ItemJnlLine."Item No.");
                ItemJnlLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
            end;
        ItemJnlLine.Validate(Quantity, Abs(PDAStockAdjProcessingBuffer."Stock on Hand"));
        ItemJnlLine."Reason Code" := PDAStockAdjProcessingBuffer."Reason Code";

        if IntegrationSetup."Store Dimension Code" <> '' then begin
            DimValCode := MiscUtilities.GetStoreDimensionValue(PDAStockAdjProcessingBuffer."Store Code", IntegrationSetup."Store Dimension Code");
            if DimValCode <> '' then begin
                GLSetup.Get();
                case true of
                    IntegrationSetup."Store Dimension Code" = GLSetup."Global Dimension 1 Code":
                        ItemJnlLine.Validate("Shortcut Dimension 1 Code", DimValCode);
                    IntegrationSetup."Store Dimension Code" = GLSetup."Global Dimension 2 Code":
                        ItemJnlLine.Validate("Shortcut Dimension 2 Code", DimValCode);
                end;
            end;
        end;

        //PS-2046+
        ItemJnlLine."GXL MIM User ID" := PDAStockAdjProcessingBuffer."MIM User ID";
        //PS-2046-

        ItemJnlPostLine.RunWithCheck(ItemJnlLine);

        Rec := PDAStockAdjProcessingBuffer;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        PDAStockAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        MiscUtilities: Codeunit "GXL Misc. Utilities";


    /*
    local procedure ValidatePDAStockAdjustmentBuffer(var PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer"): Boolean
    var
    begin
        //TODO: do we need the PDA Batch ID to check?
        exit(true);
    end;
    */

    local procedure GetJnlDocumentNo(PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer"): Code[20]
    begin
        exit(CopyStr(StrSubstNo('PDA-%1-%2', PDAStockAdjProcessingBuffer2."Store Code", PDAStockAdjProcessingBuffer2."Entry No."), 1, 20));
    end;

    //PS-2210+
    procedure CheckUOM(PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer")
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        if PDAStockAdjProcessingBuffer2."Unit of Measure Code" <> '' then
            if not ItemUOM.Get(PDAStockAdjProcessingBuffer2."Item No.", PDAStockAdjProcessingBuffer2."Unit of Measure Code") then
                Error('Item UOM does not exist. Item: %1 - UOM: %2', PDAStockAdjProcessingBuffer2."Item No.", PDAStockAdjProcessingBuffer2."Unit of Measure Code");
    end;
    //PS-2210-
}