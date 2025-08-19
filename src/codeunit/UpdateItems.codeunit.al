codeunit 50007 "GXL Update Items"
{
    TableNo = Item;

    trigger OnRun()
    var
        Item: Record Item;
    begin
        Item.Copy(Rec);

        if GuiAllowed() then
            Windows.Open(
                'Updating Items        \\' +
                'Item No.    #1##########'
            );

        UpdateItems(Item);

        if GuiAllowed() then
            Windows.Close();

    end;

    var
        ProductStatusMgt: Codeunit "GXL Product Status Management";
        Windows: Dialog;


    //Summary>
    //Update Item and its SKUs
    //</Summary>
    local procedure UpdateItems(var _Item: Record Item)
    var
        Item: Record Item;
        Item2: Record Item;
        SKU: Record "Stockkeeping Unit";
        SKU2: Record "Stockkeeping Unit";
        ItemSKUFunctions: Codeunit "GXL Item/SKU Functions";
        ModifyRec: Boolean;
        OldStatus: Enum "GXL Product Status";
    begin
        Item.Copy(_Item);
        Item.SetFilter("GXL Product Status", '<>%1', Item."GXL Product Status"::Inactive);
        Item.SetAutoCalcFields("GXl First Receipt Date");
        if Item.FindSet() then
            repeat
                if GuiAllowed() then
                    Windows.Update(1, Item."No.");

                ModifyRec := false;
                Clear(ProductStatusMgt);
                Item2 := Item;

                //Update age of item (number of weeks in stocks)
                if ItemSKUFunctions.UpdateAgeOfItem(Item2) then
                    ModifyRec := true;

                //Update new item flag
                if ItemSKUFunctions.UpdateNewItemFlag(Item2) then
                    ModifyRec := true;

                //Update product status
                Clear(ProductStatusMgt);
                OldStatus := Item2."GXL Product Status";
                ProductStatusMgt.SetSkipUpdateSKUs(true);
                ProductStatusMgt.UpdateItemStatus(Item2);
                if Item2."GXL Product Status" <> OldStatus then
                    ModifyRec := true;

                if ModifyRec then begin
                    Item2.Modify(true);
                    Commit();
                end;

                SKU.Reset();
                SKU.SetRange("Item No.", Item."No.");
                SKU.SetFilter("GXL Product Status", '<>%1', SKU."GXL Product Status"::Inactive);
                if SKU.FindSet() then
                    repeat
                        SKU2 := SKU;
                        UpdateSKU(Item2, SKU2);
                    until SKU.Next() = 0;

                Commit();

            until Item.Next() = 0;
    end;

    //<Summary>
    //Update age of item and product status on SKU
    //</Summary>
    local procedure UpdateSKU(var Item: Record Item; var SKU: Record "Stockkeeping Unit")
    var
        ItemSKUFunctions: Codeunit "GXL Item/SKU Functions";
        ProdRangingMgt: Codeunit "GXL Product Ranging Management";
        ModifyRec: Boolean;
        OldStatus: enum "GXL Product Status";
    begin
        ModifyRec := false;

        //Update ages of item in store
        if ItemSKUFunctions.UpdateAgeOfItem(SKU) then
            ModifyRec := true;

        //Update new ranging flag
        if ItemSKUFunctions.UpdateSKUNewRangingFlag(SKU) then
            ModifyRec := true;

        //Update product status
        Clear(ProductStatusMgt);
        OldStatus := SKU."GXL Product Status";
        //No Validation on SKU as the function UpdateSKUStatus will do the status update/check including de-range if applicable 
        if Item."GXL Product Status" in [Item."GXL Product Status"::Approved, Item."GXL Product Status"::"New-Line", Item."GXL Product Status"::Active] then begin
            if ProdRangingMgt.CheckSKUIsLegal(SKU."Item No.", SKU."Location Code") then
                SKU."GXL Product Status" := Item."GXL Product Status";
        end else
            SKU."GXL Product Status" := Item."GXL Product Status";
        ProductStatusMgt.SetGlobalItem(Item);
        ProductStatusMgt.UpdateSKUStatus(SKU);
        if OldStatus <> SKU."GXL Product Status" then
            ModifyRec := true;

        if ModifyRec then begin
            SKU.Modify(true);
            Commit();
        end;

    end;

}