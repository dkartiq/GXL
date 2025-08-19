codeunit 50000 "GXL Legacy Item Helpers"
{
    /*
    CR050: PS-1948 External stocktake
        New function GetItemUOM
    PS-2279 -7-10-20 LP
        Fixed issue of not converting to UOM when base qty is negative
    */

    var
        LegacyItemNoExistsErr: Label '%1 already exists on %2=%3, %4=%5';
        LegacyItemNoNotFoundErr: Label '%1 %2 not found.';

    procedure GetItemNo(LegacyItemNo: Code[20]; var ItemNo: Code[20]; var UOMCode: Code[10])
    begin
        GetItemNo(LegacyItemNo, ItemNo, UOMCode, false);
    end;

    procedure GetItemNo(LegacyItemNo: Code[20]; var ItemNo: Code[20]; var UOMCode: Code[10]; ShowError: Boolean)
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
    begin
        Clear(ItemNo);
        Clear(UOMCode);
        ItemUOM.SetCurrentKey("GXL Legacy Item No.");
        ItemUOM.SetRange("GXL Legacy Item No.", LegacyItemNo);
        if ItemUOM.FindFirst() then begin
            ItemNo := ItemUOM."Item No.";
            UOMCode := ItemUOM.Code;
        end else begin
            if ShowError then
                Error(StrSubstNo(LegacyItemNoNotFoundErr, ItemUOM.FieldCaption("GXL Legacy Item No."), LegacyItemNo));
            if Item.Get(LegacyItemNo) then begin
                ItemNo := Item."No.";
                UOMCode := Item."Base Unit of Measure";
            end;
        end;
    end;

    procedure GetItemNoForPurchase(LegacyItemNo: Code[20]; var ItemNo: Code[20]; var UOMCode: Code[10])
    begin
        GetItemNoForPurchase(LegacyItemNo, ItemNo, UOMCode, false);
    end;

    procedure GetItemNoForPurchase(LegacyItemNo: Code[20]; var ItemNo: Code[20]; var UOMCode: Code[10]; ShowError: Boolean)
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
    begin
        Clear(ItemNo);
        Clear(UOMCode);
        ItemUOM.SetCurrentKey("GXL Legacy Item No.");
        ItemUOM.SetRange("GXL Legacy Item No.", LegacyItemNo);
        if ItemUOM.FindFirst() then begin
            ItemNo := ItemUOM."Item No.";
            UOMCode := ItemUOM.Code;
        end else begin
            if ShowError then
                Error(StrSubstNo(LegacyItemNoNotFoundErr, ItemUOM.FieldCaption("GXL Legacy Item No."), LegacyItemNo));
            if Item.Get(LegacyItemNo) then begin
                ItemNo := Item."No.";
                UOMCode := Item."Purch. Unit of Measure";
                if UOMCode = '' then
                    UOMCode := Item."Base Unit of Measure";
            end;
        end;
    end;

    procedure GetLegacyItemNo(ItemNo: Code[20]; UOMCode: Code[10]; var LegacyItemNo: Code[20])
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        Clear(LegacyItemNo);
        if UOMCode = '' then
            LegacyItemNo := ItemNo
        else begin
            if not ItemUOM.Get(ItemNo, UOMCode) then begin
                //Jira PS-1333: Should not be the case in standard, it is for the case that the store database has not fully synched
                ItemUOM.Init();
                ItemUOM."Item No." := ItemNo;
                ItemUOM.Code := UOMCode;
            end;
            GetLegacyItemNo(ItemUOM, LegacyItemNo);
        end;
    end;

    procedure GetLegacyItemNo(ItemUOM: Record "Item Unit of Measure"; var LegacyItemNo: Code[20])
    begin
        LegacyItemNo := ItemUOM."GXL Legacy Item No.";
        if LegacyItemNo = '' then
            LegacyItemNo := ItemUOM."Item No.";
    end;

    procedure CheckLegacyItemNo(ItemUOM: Record "Item Unit of Measure")
    var
        ItemUOM2: Record "Item Unit of Measure";
    begin
        ItemUOM2.SetCurrentKey("GXL Legacy Item No.");
        ItemUOM2.SetRange("GXL Legacy Item No.", ItemUOM."GXL Legacy Item No.");
        ItemUOM2.SetFilter("Item No.", '<>%1', ItemUOM."Item No.");
        if ItemUOM2.FindFirst() then
            Error(LegacyItemNoExistsErr,
                ItemUOM.FieldCaption("GXL Legacy Item No."),
                ItemUOM.FieldCaption("Item No."), ItemUOM2."Item No.",
                ItemUOM.FieldCaption(Code), ItemUOM2.Code)
        else begin
            ItemUOM2.SetRange("Item No.", ItemUOM."Item No.");
            ItemUOM2.SetFilter(Code, '<>%1', ItemUOM.Code);
            if ItemUOM2.FindFirst() then
                Error(LegacyItemNoExistsErr,
                    ItemUOM.FieldCaption("GXL Legacy Item No."),
                    ItemUOM.FieldCaption("Item No."), ItemUOM2."Item No.",
                    ItemUOM.FieldCaption(Code), ItemUOM2.Code)
        end;
    end;

    procedure CalculateLegacyItemQty(LegacyItemNo: Code[20]; BaseQty: Decimal) LegacyItemQty: Decimal
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        LegacyItemQty := BaseQty;
        ItemUOM.SetCurrentKey("GXL Legacy Item No.");
        ItemUOM.SetRange("GXL Legacy Item No.", LegacyItemNo);
        if ItemUOM.FindFirst() then
            LegacyItemQty := CalculateLegacyItemQty(ItemUOM, BaseQty);
    end;

    procedure CalculateLegacyItemQty(ItemUOM: Record "Item Unit of Measure"; BaseQty: Decimal) LegacyItemQty: Decimal
    begin
        LegacyItemQty := BaseQty;
        //PS-2279+
        // if (LegacyItemQty > 0) and (ItemUOM."Qty. per Unit of Measure" > 0) then
        //     if ItemUOM."GXL Legacy Item No." <> '' then
        //         LegacyItemQty := round(BaseQty / ItemUOM."Qty. per Unit of Measure", 1, '<'); //always round down
        if (BaseQty <> 0) and (ItemUOM."Qty. per Unit of Measure" > 0) then
            LegacyItemQty := CalculateLegacyItemQty(ItemUOM, BaseQty, '<');
        //PS-2279-
    end;

    procedure CalculateLegacyItemQty(ItemUOM: Record "Item Unit of Measure"; BaseQty: Decimal; RoundMethod: Text) LegacyItemQty: Decimal
    begin
        LegacyItemQty := BaseQty;
        if (LegacyItemQty <> 0) and (ItemUOM."Qty. per Unit of Measure" > 0) then
            if ItemUOM."GXL Legacy Item No." <> '' then
                LegacyItemQty := round(BaseQty / ItemUOM."Qty. per Unit of Measure", 1, RoundMethod);
    end;

    //+ CR050: PS-1948 External stocktake
    procedure GetItemUOM(LegacyItemNo: Code[20]; var ItemUOM: Record "Item Unit of Measure"): Boolean
    begin
        Clear(ItemUOM);
        if LegacyItemNo = '' then
            exit(false);

        ItemUOM.Reset();
        ItemUOM.SetCurrentKey("GXL Legacy Item No.");
        ItemUOM.SetRange("GXL Legacy Item No.", LegacyItemNo);
        if ItemUOM.FindFirst() then
            exit(true)
        else
            exit(false);
    end;
    //- CR050: PS-1948 External stocktake
}
