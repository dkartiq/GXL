codeunit 50010 "GXL Adj. Trans. Order Inv."
{
    var
        SourceCodeSetup: Record "Source Code Setup";

    procedure AdjustTOShipmentInv(TransferHeader: Record "Transfer Header"): Boolean
    var
        ToLocation: Record Location;
        ToStore: Record "LSC Store";
        TransLine: Record "Transfer Line";
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
        SourceCodeSetup.Get();
        TransLine.SetRange("Document No.", TransferHeader."No.");
        TransLine.SetFilter("Qty. to Ship", '<>%1', 0);
        IF TransLine.FindSet(false, false) then
            repeat
                AdjustTOShipmentInvLine(TransferHeader, TransLine);
            until TransLine.Next() = 0;

        exit(true);
    end;

    procedure AdjustTOShipmentInvLine(TransferHeader: Record "Transfer Header"; TransLine: Record "Transfer Line")
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        IF TransLine."Item No." = '' then
            exit;
        if TransLine."Qty. to Ship" = 0 then
            exit;
        ItemJnlLine.INIT();
        ItemJnlLine.CopyDocumentFields(
          ItemJnlLine."Document Type"::" ", TransferHeader."No.", TransferHeader."No.", SourceCodeSetup.Transfer, '');
        ItemJnlLine."Posting Date" := TransferHeader."Posting Date";
        ItemJnlLine."Document Date" := TransferHeader."Posting Date";
        //"Document Line No." := TransShptLine2."Line No.";
        ItemJnlLine."Order Type" := ItemJnlLine."Order Type"::Transfer;
        ItemJnlLine."Order No." := TransferHeader."No.";
        ItemJnlLine."Order Line No." := TransLine."Line No.";
        ItemJnlLine."Entry Type" := ItemJnlLine."Entry Type"::"Negative Adjmt.";
        ItemJnlLine."Item No." := TransLine."Item No.";
        ItemJnlLine."Variant Code" := TransLine."Variant Code";
        ItemJnlLine.Description := TransLine.Description;
        ItemJnlLine."Location Code" := TransferHeader."Transfer-from Code";
        //"New Location Code" := TransHeader."In-Transit Code";
        ItemJnlLine."Bin Code" := TransLine."Transfer-from Bin Code";
        ItemJnlLine."Shortcut Dimension 1 Code" := TransLine."Shortcut Dimension 1 Code";
        ItemJnlLine."Shortcut Dimension 2 Code" := TransLine."Shortcut Dimension 2 Code";
        ItemJnlLine."Dimension Set ID" := TransLine."Dimension Set ID";
        ItemJnlLine.Quantity := TransLine."Qty. to Ship";
        ItemJnlLine."Invoiced Quantity" := TransLine."Qty. to Ship";
        ItemJnlLine."Quantity (Base)" := TransLine."Qty. to Ship (Base)";
        ItemJnlLine."Invoiced Qty. (Base)" := TransLine."Qty. to Ship (Base)";
        ItemJnlLine."Gen. Prod. Posting Group" := TransLine."Gen. Prod. Posting Group";
        ItemJnlLine."Inventory Posting Group" := TransLine."Inventory Posting Group";
        ItemJnlLine."Unit of Measure Code" := TransLine."Unit of Measure Code";
        ItemJnlLine."Qty. per Unit of Measure" := TransLine."Qty. per Unit of Measure";
        ItemJnlLine."Country/Region Code" := TransferHeader."Trsf.-from Country/Region Code";
        ItemJnlLine."Transaction Type" := TransferHeader."Transaction Type";
        ItemJnlLine."Transport Method" := TransferHeader."Transport Method";
        ItemJnlLine."Entry/Exit Point" := TransferHeader."Entry/Exit Point";
        ItemJnlLine.Area := TransferHeader.Area;
        ItemJnlLine."Transaction Specification" := TransferHeader."Transaction Specification";
        ItemJnlLine."Item Category Code" := TransLine."Item Category Code";
        ItemJnlLine."Applies-to Entry" := TransLine."Appl.-to Item Entry";
        ItemJnlLine."Shpt. Method Code" := TransferHeader."Shipment Method Code";
        ItemJnlLine."Direct Transfer" := TransLine."Direct Transfer";
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);
    end;

    procedure PostTestAdjustment(TransferHeader: Record "Transfer Header")
    var
        AdjTransOrderInv: Codeunit "GXL Adj. Trans. Order Inv.";
    begin
        IF NOT Confirm('This will post negative adjustments if the Transfer-To Location ' +
        'is not yet live. This is intended for testing purposes only. Do you wish to continue?', false) then
            exit;
        IF NOT AdjTransOrderInv.AdjustTOShipmentInv(TransferHeader) then
            Message('Nothing posted');
    end;
}