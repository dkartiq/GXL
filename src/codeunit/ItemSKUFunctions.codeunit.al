codeunit 50002 "GXL Item/SKU Functions"
{

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit", 'OnAfterCopyFromItem', '', false, false)]
    local procedure OnAfterCopyFromItem_SKU(Item: Record Item; var StockkeepingUnit: Record "Stockkeeping Unit")
    var
        ItemSKUFunctions: Codeunit "GXL Item/SKU Functions";
    begin
        ItemSKUFunctions.CopyFromItem(Item, StockkeepingUnit);
    end;


    procedure CopyFromItem(Item: Record Item; var SKU: Record "Stockkeeping Unit")
    var
        Store: Record "LSC Store";
        Loc: Record Location;
    begin
        SKU."GXL Category Code" := Item."GXL Category Code";
        SKU."GXL Product Type" := Item."GXL Product Type";
        SKU."GXL Source of Supply" := Item."GXL Source of Supply";
        SKU."GXL Supplier Number" := Item."GXL Supplier Number";
        SKU."GXL Agent Number" := Item."GXL Agent Number";
        SKU."GXL Distributor Number" := Item."GXL Distributor Number";
        if SKU."GXL Source of Supply" <> SKU."GXL Source of Supply"::SD then
            SKU."GXL Source of Supply Code" := GetWHAssignment(SKU."GXL Distributor Number", SKU."Location Code");

        SKU."GXL Order Pack (OP)" := Item."GXL Order Pack (OP)";
        SKU."GXL Order Multiple (OM)" := Item."GXL Order Multiple (OM)";
        SKU."GXL SC-Size" := Item."GXL SC-Size";
        SKU."GXL Expiry Date Flag" := Item."GXL Expiry Date Flag";
        SKU."GXL Forecast Flag" := Item."GXL Forecast Flag";
        SKU."GXL Replenish Flag" := Item."GXL Replenish Flag";

        SKU."GXL On-Line Status" := Item."GXL On-Line Status";
        SKU."GXL Like Item" := Item."GXL Like Item";
        SKU."GXL Like Item Factor" := Item."GXL Like Item Factor";
        SKU."GXL Supersession Item" := Item."GXL Supersession Item";
        SKU."GXL Private Label Flag" := Item."GXL Private Label Flag";
        SKU."GXL Parent Item" := Item."GXL Parent Item";
        SKU."GXL Parent Quantity" := Item."GXL Parent Quantity";
        SKU."GXL Import Flag" := Item."GXL Import Flag";
        SKU."GXL MPL Factor" := Item."GXL MPL Factor";

        //Product life cycle and ranging
        SKU."GXL Product Status" := Item."GXL Product Status";
        if SKU."GXL Product Status" in [SKU."GXL Product Status"::"New-Line", SKU."GXL Product Status"::Active] then
            SKU."GXL Product Status" := SKU."GXL Product Status"::Approved;
        SKU."GXL Product Range Code" := Item."GXL Product Range Code";
        SKU."GXL Effective Date" := Item."GXL Effective Date";
        SKU."GXL Quit Date" := Item."GXL Quit Date";
        SKU."GXL Discontinued Date" := 0D;

        Loc.Code := SKU."Location Code";
        if Loc.GetAssociatedStore(Store, true) then begin
            if (Store."GXL Open Date" <> 0D) then
                if (Store."GXL Open Date" > SKU."GXL Effective Date") then
                    SKU."GXL Effective Date" := Store."GXL Open Date";

            if (Store."GXL Closed Date" <> 0D) then
                if (Store."GXL Closed Date" < SKU."GXL Quit Date") then
                    SKU."GXL Quit Date" := Store."GXL Closed Date";


            case Store."GXL Location Type" of
                Store."GXL Location Type"::"3": //SD
                    begin
                        if SKU."GXL Source of Supply" = SKU."GXL Source of Supply"::WH then begin
                            SKU."GXL Discontinued Date" := Item."GXL Discontinued Date";
                            if (Store."GXL Closed Date" < Item."GXL Discontinued Date") and (Store."GXL Closed Date" <> 0D) then
                                SKU."GXL Discontinued Date" := Store."GXL Closed Date";
                        end;

                        if (SKU."GXL Source of Supply" in [SKU."GXL Source of Supply"::WH, SKU."GXL Source of Supply"::FT]) then begin
                            SKU."GXL Order Minimum" := Item."GXL Order Pack (OP)";
                            SKU."GXL Order Increment" := Item."GXL Order Pack (OP)";
                        end else
                            if (SKU."GXL Source of Supply" = SKU."GXL Source of Supply"::XD) then begin
                                SKU."GXL Order Minimum" := item."GXL Order Multiple (OM)";
                                SKU."GXL Order Increment" := Item."GXL Order Multiple (OM)";
                            end;

                    end;
                Store."GXL Location Type"::"6": //Store
                    begin
                        SKU."GXL Order Minimum" := Item."GXL Order Multiple (OM)";
                        SKU."GXL Order Increment" := Item."GXL Order Multiple (OM)";
                    end;
            end;

        end;
        SKU."GXL New Ranging Flag" := true;
        if SKU."GXL Product Status" in [SKU."GXL Product Status"::Quit, SKU."GXL Product Status"::Inactive] then
            SKU."GXL New Ranging Flag" := false;

        SKU.Validate("GXL Quit Date");
    end;

    procedure GetWHAssignment(Distributor: Code[20]; StoreCode: Code[10]): Code[10]
    var
        WHAssgmt: Record "GXL Warehouse Assignment";
    begin
        WHAssgmt.SetRange("Distributor Code", Distributor);
        WHAssgmt.SetRange("Store Code", StoreCode);
        if WHAssgmt.FindFirst() then
            exit(WHAssgmt."Warehouse Code");
        exit('');

    end;

    procedure UpdateSKUMPLFactor(var Item: Record Item; MPLFactor: Integer)
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.SetRange("Item No.", Item."No.");
        if SKU.FindSet() then
            repeat
                SKU."GXL MPL Factor" := MPLFactor;
                SKU.Validate("GXL Minimum Presentation Level", MPLFactor * sku."GXL MPL Factor");
                if SKU."GXL Minimum Presentation Level" > sku."GXL Shelf Capacity" then
                    SKU.Validate("GXL Shelf Capacity", SKU."GXL Minimum Presentation Level");
                SKU.Modify(true);
            until SKU.Next() = 0;
    end;

    procedure UpdateFacing(var SKU: Record "Stockkeeping Unit"; var xSKU: Record "Stockkeeping Unit"; OldFacing: Integer; NewFacing: Integer)
    begin
        SKU.Validate("GXL Minimum Presentation Level", SKU."GXL MPL Factor" * SKU."GXL Facing");
        if OldFacing <> 0 then
            SKU.Validate("GXL Shelf Capacity", (xSKU."GXL Shelf Capacity" / OldFacing) * NewFacing);

    end;

    procedure InitSupplyChain(var Item: Record Item)
    var
    begin
        if Item."GXL Product Type" <> Item."GXL Product Type"::" " then
            Item.TestField("GXL Product Range Code");

        CheckOrderMutiple(Item);

        //product ranging
        Item."GXL New Item" := true;
        Item."GXL Delta Ranging Required" := true;
    end;

    procedure UpdateSKUOrderPack(var Item: Record Item)
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.Reset();
        SKU.SetCurrentKey("Item No.");
        SKU.SetRange("Item No.", Item."No.");
        SKU.SetFilter("GXL Product Status", '<>%1', SKU."GXL Product Status"::Inactive);
        if SKU.FindSet() then
            repeat
                if (SKU."GXL Order Pack (OP)" <> Item."GXL Order Pack (OP)") or (SKU."GXL Order Multiple (OM)" <> Item."GXL Order Multiple (OM)") then begin
                    if (SKU."GXL Order Pack (OP)" <> Item."GXL Order Pack (OP)") then
                        SKU.Validate("GXL Order Pack (OP)", Item."GXL Order Pack (OP)");
                    if SKU."GXL Order Multiple (OM)" <> Item."GXL Order Multiple (OM)" then
                        SKU.Validate("GXL Order Multiple (OM)", Item."GXL Order Multiple (OM)");
                    SKU.Modify(true);
                end;
            until SKU.Next() = 0;
    end;

    procedure CheckOrderMutiple(Item: Record Item)
    begin
        if (Item."GXL Order Multiple (OM)" <> 0) and (Item."GXL Order Pack (OP)" <> 0) then begin
            if (Item."GXL Order Pack (OP)" MOD Item."GXL Order Multiple (OM)") <> 0 then
                Error(StrSubstNo('OP should be in mutiples of OM for item %1', Item."No."));
        end else
            if Item."GXL Order Pack (OP)" <> 0 then
                Item.TestField("GXL Order Multiple (OM)");
    end;

    procedure UpdateAgeOfItem(var Item: Record Item) ModifyRec: Boolean;
    var
        ProdStatusMgt: Codeunit "GXL Product Status Management";
        FirstReceiptDate: Date;
        AgeOfItem: Integer;
    begin
        ModifyRec := false;
        //CR036 +
        //FirstReceiptDate := Item."GXL First Receipt Date";
        FirstReceiptDate := ProdStatusMgt.GetFirstReceiptDate_Item(Item);
        //CR036 -
        if FirstReceiptDate <> 0D then begin
            AgeOfItem := Round((Today() - FirstReceiptDate) / 7, 1, '>');
            if AgeOfItem > Item."GXL Age of Item" then begin
                Item.Validate("GXL Age of Item", AgeOfItem);
                ModifyRec := true;
            end;
        end;
    end;

    procedure UpdateAgeOfItem(var SKU: Record "Stockkeeping Unit") ModifyRec: Boolean;
    var
        ProdStatusMgt: Codeunit "GXL Product Status Management";
        FirstReceiptDate: Date;
        AgeOfItem: Integer;
    begin
        ModifyRec := false;
        //CR036 +
        //FirstReceiptDate := Item."GXL First Receipt Date";
        FirstReceiptDate := ProdStatusMgt.GetFirstReceiptDate_SKU(SKU);
        //CR036 -
        if FirstReceiptDate <> 0D then begin
            AgeOfItem := Round((Today() - FirstReceiptDate) / 7, 1, '>');
            if AgeOfItem > SKU."GXL Age of Item" then begin
                SKU.Validate("GXL Age of Item", AgeOfItem);
                ModifyRec := true;
            end;
        end;
    end;

    procedure UpdateNewItemFlag(var Item: Record Item) ModifyRec: Boolean;
    var
        ProdStatusMgt: Codeunit "GXL Product Status Management";
        FirstReceiptDate: Date;
    begin
        ModifyRec := false;
        if Item."GXL New Item" then begin
            //CR036 +
            //FirstReceiptDate := Item."GXL First Receipt Date";
            FirstReceiptDate := ProdStatusMgt.GetFirstReceiptDate_Item(Item);
            //CR036 -
            if FirstReceiptDate <> 0D then begin
                if CalcDate('<4W>', FirstReceiptDate) <= Today() then begin
                    Item."GXL New Item" := false;
                    ModifyRec := true;
                end;
            end;
        end;
    end;

    procedure UpdateSKUNewRangingFlag(var SKU: Record "Stockkeeping Unit") ModifyRec: Boolean;
    var
        ProdStatusMgt: Codeunit "GXL Product Status Management";
        FirstReceiptDate: Date;
    begin
        ModifyRec := false;
        if SKU."GXL New Ranging Flag" then begin
            //CR036 +
            //FirstReceiptDate := Item."GXL First Receipt Date";
            FirstReceiptDate := ProdStatusMgt.GetFirstReceiptDate_SKU(SKU);
            //CR036 -
            if FirstReceiptDate <> 0D then begin
                if CalcDate('<12W>', FirstReceiptDate) <= Today() then begin
                    SKU."GXL New Ranging Flag" := false;
                    ModifyRec := true;
                end;
            end;
        end;
    end;

    procedure GetDivisionDesc(DivisionCode: Code[10]): Text
    var
        Division: Record "LSC Division";
    begin
        if Division.Get(DivisionCode) then
            exit(Division.Description);
    end;

    procedure GetItemCatDesc(ItemCatCode: Code[20]): Text
    var
        ItemCat: Record "Item Category";
    begin
        if ItemCat.Get(ItemCatCode) then
            exit(ItemCat.Description);
    end;

    procedure GetProductGroupDesc(ItemCatCode: Code[20]; ProdGrpCode: Code[20]): Text
    var
        RetailProdGrp: Record "LSC Retail Product Group";
    begin
        if RetailProdGrp.Get(ItemCatCode, ProdGrpCode) then
            exit(RetailProdGrp.Description);
    end;

    procedure GetSubCat3Desc(SubCatCode: Code[30]): Text
    var
        Sub3Cat: Record "GXL Sub-Category 3";
    begin
        if Sub3Cat.Get(SubCatCode) then
            exit(Sub3Cat.Description);
    end;

    procedure GetSubCat4Desc(SubCatCode: Code[40]): Text
    var
        Sub4Cat: Record "GXL Sub-Category 4";
    begin
        if Sub4Cat.Get(SubCatCode) then
            exit(Sub4Cat.Description);
    end;

}