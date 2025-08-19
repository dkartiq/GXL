codeunit 50005 "GXL Product Ranging Management"
{
    trigger OnRun()
    begin

    end;

    var
        GlobalItem: Record Item;
        GlobalLoc: Record Location;
        GlobalStore: Record "LSC Store";
        GlobalWhStore: Record "LSC Store";
        GlobalSKU: Record "Stockkeeping Unit";
        TempLocation: Record Location temporary;
        ItemSKUFunctions: Codeunit "GXL Item/SKU Functions";
        DeletedDate: Date;
        EffectiveDate: Date;
        IllegalDate: Date;
        IllegalSKURangeFlag: Boolean;


    ///<Summary>
    //This function is to range for specific item-store
    //Create/update Product-Store Ranging
    // - Range the product basing on Ranging Exception and Illegal Items
    // - Create SKU if it does not exist
    ///</Summary>
    local procedure CreateProductStoreRangingLine(RangingException: Record "GXL Ranging Exceptions")
    var
        WhseCode: Code[10];
        ToRange: Boolean;
        SKUExists: Boolean;
    begin
        if not RangingException.Range then
            exit;
        if not GetItem(RangingException."Item No.") then
            exit;
        if not ProductStatusCanBeRanged(GlobalItem."GXL Product Status") then
            exit;

        ToRange := true;
        if GetLocation(RangingException."Store Code") then begin
            //Stop if warehouse SKU (i.e. SKU source of supply code) cannot be ranged
            //i.e. warehouse SKU product status is either Quit or Inactive
            if GlobalItem."GXL Source of Supply" = GlobalItem."GXL Source of Supply"::WH then
                if SourceofSupplyCodeCannotBeRanged(RangingException."Item No.", RangingException."Store Code") then
                    ToRange := false;

            if ToRange then begin
                GetSKU(RangingException."Item No.", RangingException."Store Code");
                GetStore(RangingException."Store Code");
                CheckDeletedDate(GlobalStore);
                if GetRangeFlagFromDate(DeletedDate) then begin
                    //Insert/Update Product-Store Ranging
                    //SKU will be created for store and warehouse if does not exist
                    InsertRanging(GlobalItem, GlobalStore);
                    SKUExists := GetSKU(RangingException."Item No.", RangingException."Store Code");

                    //Insert Product-Store Ranging for Warehouse from warehouse assignment of the distributor and store
                    if SKUExists then begin
                        //SKU does exist for Item/Location
                        //Check warehouse assignment from SKU and insert ranging, if applicable
                        if (GlobalSKU."GXL Distributor Number" <> '') and
                            (GlobalSKU."GXL Source of Supply" <> GlobalSKU."GXL Source of Supply"::SD) then begin
                            WhseCode := ItemSKUFunctions.GetWHAssignment(GlobalSKU."GXL Distributor Number", RangingException."Store Code");
                            if (WhseCode <> '') then
                                if not TempLocation.Get(WhseCode) then begin
                                    GetWhStore(WhseCode);
                                    CheckDeletedDate(GlobalWhStore);
                                    InsertRanging(GlobalItem, GlobalWhStore);

                                    TempLocation.Init();
                                    TempLocation.Code := WhseCode;
                                    TempLocation.Insert()
                                end;
                        end;
                    end else begin
                        //Otherwise check warehouse assignment from Item and insert ranging, if applicable
                        if (GlobalItem."GXL Distributor Number" <> '') and
                            (GlobalItem."GXL Source of Supply" <> GlobalItem."GXL Source of Supply"::SD) then begin
                            WhseCode := ItemSKUFunctions.GetWHAssignment(GlobalItem."GXL Distributor Number", RangingException."Store Code");
                            if WhseCode <> '' then
                                if not TempLocation.Get(WhseCode) then begin
                                    GetWhStore(WhseCode);
                                    CheckDeletedDate(GlobalWhStore);
                                    InsertRanging(GlobalItem, GlobalWhStore);

                                    TempLocation.Init();
                                    TempLocation.Code := WhseCode;
                                    TempLocation.Insert()
                                end;
                        end;
                    end;
                end;
            end;
        end;
    end;


    ///<Summary>
    //This function is to range the item for all stores
    //Create/update Product-Store Ranging
    // - Range the product basing on Ranging Exception and Illegal Items
    // - Create SKU if it does not exist
    ///</Summary>
    procedure CreateItemRangingLine(ItemNo: Code[20])
    var
        RangingException: Record "GXL Ranging Exceptions";
    begin
        if not GetItem(ItemNo) then
            exit;
        if not ProductStatusCanBeRanged(GlobalItem."GXL Product Status") then
            exit;

        TempLocation.Reset();
        TempLocation.DeleteAll();
        RangingException.SetRange("Item No.", ItemNo);
        RangingException.SetRange(Range, true);
        if RangingException.FindSet(false) then
            repeat
                CreateProductStoreRangingLine(RangingException);
            until RangingException.Next() = 0;
        TempLocation.Reset();
        TempLocation.DeleteAll();
    end;


    ///<Summary>
    //This function is to check the existing Product-Store Ranging and de-range if applicable
    //Criterias to be de-ranged:
    //  1. Store closed
    //  2. Product status is either Quit or Inactive
    //  3. Not configured as "Range" in ranging exception
    //  4. Is in illegal item list
    //  5. The only exception that if the SKU is warehouse SKU and product is ranged from other store(s), then not de-ranged
    ///</Summary>
    procedure GetRangingFlag(var ProdStoreRanging: Record "GXL Product-Store Ranging"): Boolean
    var
        IsRanged: Boolean;
    begin
        if not GetItem(ProdStoreRanging."Item No.") then
            exit;

        //Only approved, new-line, active and discontinued-WH products are to be ranged
        IsRanged := true;
        IllegalSKURangeFlag := false;

        //De-range if store is closed
        GetStore(ProdStoreRanging."Store Code");
        if not CheckStoreClosed(GlobalStore) then begin
            if ProductStatusCanBeRanged(GlobalItem."GXL Product Status") then begin
                if IsRangedInRangeException(ProdStoreRanging."Item No.", ProdStoreRanging."Store Code") then begin
                    //Product is already ranged in ranging exception but is in illegal item, then de-range and mark to log it later
                    if not CheckSKUIsLegal(ProdStoreRanging."Item No.", ProdStoreRanging."Store Code") then
                        IllegalSKURangeFlag := true
                    else
                        //No further check as it is ranged
                        exit(true);
                end else begin
                    //Not in the ranging exception but is a WH location, check if product is ranged in any of the store
                    //If it is, then this warehouse is considered to be ranged
                    if GlobalStore."GXL Location Type" = GlobalStore."GXL Location Type"::"3" then begin
                        IsRanged := CheckWarehouse(ProdStoreRanging."Item No.", ProdStoreRanging."Store Code");
                        if IsRanged then
                            exit(true);
                    end;
                end;
            end;
        end;

        //De-range
        ProdStoreRanging.Ranged := false;
        ProdStoreRanging."Last Deleted Date" := ProdStoreRanging."Deleted Date";
        ProdStoreRanging."Deleted Date" := Today();
        exit(false);
    end;

    ///<Summary>
    //Check item and store is configured as ranged in ranging exception
    ///</Summary>
    procedure IsRangedInRangeException(ItemCode: Code[20]; LocCode: Code[10]): Boolean
    var
        RangingException: Record "GXL Ranging Exceptions";
    begin
        if RangingException.Get(ItemCode, LocCode) then
            exit(RangingException.Range)
        else
            exit(false);
    end;

    ///<Summary>
    //Check item and store is configured as ranged in ranging exception
    ///</Summary>
    procedure IsRangedInProdStoreRanging(ItemCode: Code[20]; LocCode: Code[10]): Boolean
    var
        ProdStoreRanging: Record "GXL Product-Store Ranging";
    begin
        if ProdStoreRanging.Get(ItemCode, LocCode) then
            exit(ProdStoreRanging.Ranged)
        else
            exit(false);
    end;

    ///<Summary>
    //This function is to range the items belong to a store
    //Create Product-store ranging for a new store
    //Ranging the product/store basing on ranging exception and illegal item
    //Quit or inactive products are not to be ranged
    ///</Summary>
    procedure CreateItemRangingLineFromLocation(LocationCode: Code[10])
    var
        Item: Record Item;
        RangingException: Record "GXL Ranging Exceptions";
        Windows: Dialog;
    begin
        if not GetLocation(LocationCode) then
            exit;

        TempLocation.Reset();
        TempLocation.DeleteAll();

        Item.Reset();
        Item.SetCurrentKey("GXL Product Status");
        Item.SetFilter("GXL Product Status", '<>%1&<>%2',
            Item."GXL Product Status"::Quit, Item."GXL Product Status"::Inactive);
        Item.SetFilter("GXL Effective Date", '<>%1', 0D);
        if Item.FindSet() then begin
            if GuiAllowed() then
                Windows.Open(
                    'Update Product Ranging for Location ' + LocationCode + '\\' +
                    'Item No.        #1##################'
                );

            repeat
                RangingException.SetRange("Item No.", Item."No.");
                RangingException.SetRange("Store Code", LocationCode);
                RangingException.SetRange(Range, true);
                if RangingException.FindFirst() then begin
                    if GuiAllowed() then
                        Windows.Update(1, Item."No.");

                    CreateProductStoreRangingLine(RangingException);
                end;
            until Item.Next() = 0;

            TempLocation.Reset();
            TempLocation.DeleteAll();

            if GuiAllowed() then
                Windows.Close();
        end;
    end;

    ///<Summary>
    //This function will derange an item basing on range exceptions
    ///</Summary>
    procedure CheckRangeException(ItemCode: Code[20])
    var
        RangingException: Record "GXL Ranging Exceptions";
    begin
        RangingException.Reset();
        RangingException.SetRange("Item No.", ItemCode);
        RangingException.SetRange(Range, false);
        if RangingException.FindSet() then begin
            GetItem(RangingException."Item No.");
            UpdateRangingException(RangingException);
        end;

    end;


    ///<Summary>
    //Update product ranging exception
    //This function is used when loading new ranging exceptions
    ///</Summary>
    procedure UpdateRangingException(var _RangingException: Record "GXL Ranging Exceptions")
    var
        RangingException: Record "GXL Ranging Exceptions";
        SKU: Record "Stockkeeping Unit";
    begin
        RangingException.Copy(_RangingException);
        if _RangingException.GetFilter("Last Modified Date") <> '' then
            RangingException.SetCurrentKey("Last Modified Date");
        if RangingException.FindSet() then
            repeat
                if not RangingException.Range then begin
                    DerangeProdStoreRanging(RangingException);
                    DerangeSKU(RangingException);
                end else begin
                    //Range
                    GetItem(RangingException."Item No.");
                    if ProductStatusCanBeRanged(GlobalItem."GXL Product Status") then begin
                        //Reset product status of SKU if it is not Quit/Inactive
                        //It is mainly reset the Quit Date
                        SKU.Reset();
                        SKU.SetRange("Location Code", RangingException."Store Code");
                        SKU.SetRange("Item No.", RangingException."Item No.");
                        SKU.SetFilter("GXL Product Status", '<>%1&<>%2', SKU."GXL Product Status"::Quit, SKU."GXL Product Status"::Inactive);
                        if SKU.FindFirst() then begin
                            SKU."GXL Product Status" := GlobalItem."GXL Product Status";
                            SKU.Validate("GXL Quit Date", 0D);
                            SKU.Modify();
                        end;
                        if GlobalItem."GXL Effective Date" = 0D then
                            GlobalItem."GXL Effective Date" := Today();
                        CreateProductStoreRangingLine(RangingException);
                    end;
                end;
            until RangingException.Next() = 0;
    end;

    ///<Summary>
    //Derange Product-Store Ranging
    ///</Summary>
    local procedure DerangeProdStoreRanging(RangingException: Record "GXL Ranging Exceptions")
    var
        ProdStoreRanging: Record "GXL Product-Store Ranging";
    begin
        ProdStoreRanging.Reset();
        ProdStoreRanging.SetRange("Item No.", RangingException."Item No.");
        ProdStoreRanging.SetRange("Store Code", RangingException."Store Code");
        ProdStoreRanging.SetRange(Ranged, true);
        if ProdStoreRanging.FindFirst() then begin
            ProdStoreRanging."Last Deleted Date" := ProdStoreRanging."Deleted Date";
            ProdStoreRanging."Deleted Date" := Today();
            ProdStoreRanging.Ranged := false;
            ProdStoreRanging.Modify();
        end;
    end;

    ///<Summary>
    //Derange SKU
    //set product status to Quit
    ///</Summary>
    local procedure DerangeSKU(RangingException: Record "GXL Ranging Exceptions")
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.Reset();
        SKU.SetRange("Location Code", RangingException."Store Code");
        SKU.SetRange("Item No.", RangingException."Item No.");
        SKU.SetFilter("GXL Product Status", '<>%1&<>%2', SKU."GXL Product Status"::Quit, SKU."GXL Product Status"::Inactive);
        if SKU.FindFirst() then begin
            SKU.CalcFields("GXL Warehouse SKU");
            if SKU."GXL Warehouse SKU" and (SKU."GXL Source of Supply" = SKU."GXL Source of Supply"::WH) then begin
                if SKU."GXL Product Status" <> SKU."GXL Product Status"::"Discontinued-WH only" then begin
                    SKU.Validate("GXL Product Status", SKU."GXL Product Status"::"Discontinued-WH only");
                    SKU.Modify(true);
                end;
            end else begin
                SKU.Validate("GXL Product Status", SKU."GXL Product Status"::Quit);
                SKU."GXL Quit Date" := Today();
                SKU.Modify(true);
            end;
        end;
    end;


    ///<Summary>
    //Insert/update a Product-Store Ranging record to be ranged or de-ranged
    //Create a SKU if it does not exist for ranged product-store only
    //Quit SKU if it is de-ranged
    ///</Summary>
    local procedure InsertRanging(Item: Record Item; Store: Record "LSC Store")
    var
        ProdStoreRanging: Record "GXL Product-Store Ranging";
        PrevRangeFlag: Boolean;
    begin
        if Store."Location Code" = '' then
            exit;

        if not ProdStoreRanging.Get(Item."No.", Store."Location Code") then begin
            ProdStoreRanging.Init();
            ProdStoreRanging."Item No." := Item."No.";
            ProdStoreRanging."Store Code" := Store."Location Code";
            ProdStoreRanging."Effective Date" := EffectiveDate;
            ProdStoreRanging."Deleted Date" := DeletedDate;
            ProdStoreRanging.Ranged := GetRangeFlagFromDate(ProdStoreRanging."Deleted Date");
            SetIllegalProdStoreRange(ProdStoreRanging);
            ProdStoreRanging.Insert(true);

            if ProdStoreRanging.Ranged then
                CreateSKU(GlobalItem, Store, '');
        end else begin
            PrevRangeFlag := ProdStoreRanging.Ranged;
            ProdStoreRanging."Effective Date" := EffectiveDate;
            ProdStoreRanging."Last Deleted Date" := ProdStoreRanging."Deleted Date";
            ProdStoreRanging."Deleted Date" := DeletedDate;
            ProdStoreRanging.Ranged := GetRangeFlagFromDate(ProdStoreRanging."Deleted Date");

            if PrevRangeFlag <> ProdStoreRanging.Ranged then begin
                SetIllegalProdStoreRange(ProdStoreRanging);
                ProdStoreRanging.Modify(true);
                if not ProdStoreRanging.Ranged then
                    //Change SKU product status to Discontinued-WH if it is a warehouse SKU, otherwise change to Quit
                    QuitSKU(ProdStoreRanging)
                else begin
                    UpdateSKU(GlobalItem, Store, '');
                end;
            end;
        end;
        if IllegalSKURangeFlag then
            LogIllegalProductRange(ProdStoreRanging."Item No.", ProdStoreRanging."Store Code");
    end;


    ///<Summary>
    //Get Item
    ///</Summary>    
    local procedure GetItem(ItemNo: Code[20]): Boolean
    begin
        if GlobalItem."No." <> ItemNo then begin
            if GlobalItem.Get(ItemNo) then
                exit(true)
            else
                exit(false);
        end else
            exit(true);
    end;

    ///<Summary>
    //Set Item
    ///</Summary>    
    procedure SetItem(var Item: Record Item)
    begin
        GlobalItem := Item;
    end;

    ///<Summary>
    //Get Location
    ///</Summary>
    local procedure GetLocation(LocCode: Code[10]): Boolean
    begin
        if GlobalLoc.Code <> LocCode then begin
            if GlobalLoc.Get(LocCode) then begin
                GlobalLoc.CalcFields("GXL Location Type");
                exit(true);
            end else
                exit(false);
        end else
            exit(false);
    end;

    ///<Summary>
    //Set Location
    ///</Summary>    
    procedure SetLocation(var Loc: Record Location)
    begin
        GlobalLoc := Loc;
    end;

    ///<Summary>
    //Get Store
    ///</Summary>
    local procedure GetStore(LocCode: Code[10])
    var
        Loc: Record Location;
    begin
        if GlobalStore."Location Code" <> LocCode then begin
            Loc.Code := LocCode;
            if not Loc.GetAssociatedStore(GlobalStore, true) then begin
                GlobalStore."Location Code" := LocCode;
                GlobalStore."GXL Location Type" := GlobalStore."GXL Location Type"::"6";
            end;
        end;
    end;

    ///<Summary>
    //Get Store
    ///</Summary>
    local procedure GetWhStore(WhseCode: Code[10])
    var
        Loc: Record Location;
    begin
        if GlobalWhStore."Location Code" <> WhseCode then begin
            Loc.Code := WhseCode;
            if not Loc.GetAssociatedStore(GlobalWhStore, true) then begin
                GlobalWhStore."Location Code" := WhseCode;
                GlobalWhStore."GXL Location Type" := GlobalWhStore."GXL Location Type"::"3";
            end;
        end;
    end;

    ///<Summary>
    //Get SKU
    ///</Summary>
    local procedure GetSKU(ItemNo: Code[20]; LocCode: Code[10]): Boolean
    begin
        if (GlobalSKU."Item No." <> ItemNo) or (GlobalSKU."Location Code" <> LocCode) then begin
            if GlobalSKU.Get(LocCode, ItemNo, '') then
                exit(true)
            else
                exit(false);
        end else
            exit(true);
    end;


    ///<Summary>
    //Set SKU
    ///</Summary>    
    procedure SetSKU(var SKU: Record "Stockkeeping Unit")
    begin
        GlobalSKU := SKU;
    end;


    ///<Summary>
    //Check if the product status is valid for ranging
    //Only Approved, New-Line, Active and Discontinued-WH is valid for rangng
    ///</Summary>
    procedure ProductStatusCanBeRanged(ProdStatus: Enum "GXL Product Status"): Boolean
    begin

        if ProdStatus in [ProdStatus::Approved, ProdStatus::"New-Line", ProdStatus::Active, ProdStatus::"Discontinued-WH only"] then
            exit(true)
        else
            exit(false);
    end;


    ///<Summary>
    //Set SKU Status to Discontinued-WH if it is a WH SKU
    //Otherwise set Status to Quit
    ///</Summary>
    procedure QuitSKU(ProdStoreRanging: Record "GXL Product-Store Ranging")
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.SetRange("Item No.", ProdStoreRanging."Item No.");
        SKU.SetRange("Location Code", ProdStoreRanging."Store Code");
        if SKU.FindFirst() then
            //Do not change product status if it is already Quit or Inactive
            if ProductStatusCanBeRanged(SKU."GXL Product Status") then begin
                SKU.CalcFields("GXL Warehouse SKU");
                if SKU."GXL Warehouse SKU" and (SKU."GXL Source of Supply" = SKU."GXL Source of Supply"::WH) then begin
                    if SKU."GXL Product Status" <> SKU."GXL Product Status"::"Discontinued-WH only" then begin
                        SKU.Validate("GXL Product Status", SKU."GXL Product Status"::"Discontinued-WH only");
                        SKU.Modify(true);
                    end;
                end else begin
                    SKU.Validate("GXL Product Status", SKU."GXL Product Status"::Quit);
                    SKU.Validate("GXL Quit Date", ProdStoreRanging."Deleted Date");
                    SKU.Modify(true);
                end;
            end;
    end;

    ///<Summary>
    //Check if the item-warehouse is ranged
    //If exists an SKU for warehouse, check warehouse SKU
    //Otherwise check product store ranging
    ///</Summary>
    local procedure CheckWarehouse(ItemNo: Code[20]; WhseCode: Code[10]): Boolean
    var
        SKU: Record "Stockkeeping Unit";
        ProdStoreRanging: Record "GXL Product-Store Ranging";
    begin
        SKU.SetRange("Item No.", ItemNo);
        SKU.SetRange("Location Code", WhseCode);
        if not SKU.IsEmpty() then
            exit(CheckWHSkuIsRanged(ItemNo, WhseCode));

        //No SKU created for the warehouse, check product-store ranging
        if ProdStoreRanging.Get(ItemNo, WhseCode) then begin
            ProdStoreRanging.CalcFields("Product Status");
            if ProductStatusCanBeRanged(ProdStoreRanging."Product Status") then
                exit(ProdStoreRanging.Ranged);
        end;
        exit(false);
    end;

    ///<Summary>
    //Ckeck warehouse SKU if it is ranged
    //  As warehouse is usually not configured as Range in ranging exception
    //  but the stores that are sourced product from this warehouse, is ranged
    //  then it is considered to be ranged
    ///</Summary>
    local procedure CheckWHSkuIsRanged(ItemNo: Code[20]; WhseCode: Code[10]): Boolean
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.SetCurrentKey("GXL Source of Supply Code");
        SKU.SetRange("Item No.", ItemNo);
        if not SKU.IsEmpty() then begin
            SKU.SetRange("GXL Source of Supply Code", WhseCode);
            SKU.SetAutoCalcFields("GXL Ranged");
            if SKU.FindSet() then
                repeat
                    if SKU."GXL Ranged" then
                        exit(true);
                until SKU.Next() = 0;
            exit(false);
        end else
            exit(true);
    end;

    ///<Summary>
    //Create a SKU if it does not exist
    ///</Summary>
    local procedure CreateSKU(VAR Item2: Record Item; Store: Record "LSC Store"; VariantCode: Code[10])
    var
        SKU: Record "Stockkeeping Unit";
        WhSKU: Record "Stockkeeping Unit";
    begin
        //Only create SKUs for Location Type is WH or Store
        if not (Store."GXL Location Type" in [Store."GXL Location Type"::"3", Store."GXL Location Type"::"6"]) then
            exit;

        if not SKU.Get(Store."Location Code", Item2."No.", VariantCode) then begin
            SKU.Init();
            SKU."Item No." := Item2."No.";
            SKU."Location Code" := Store."Location Code";
            SKU."Variant Code" := VariantCode;

            SKU.CopyFromItem(Item2);

            if SKU."GXL Effective Date" < Today() then
                SKU."GXL Effective Date" := Today();

            if (Item2."GXL Source of Supply" = Item2."GXL Source of Supply"::SD) and
                (Store."GXL Location Type" = Store."GXL Location Type"::"3") then begin
                if GetSOS(Store."Location Code", Item2."No.", WhSKU) then begin
                    SKU."GXL Source of Supply" := WhSKU."GXL Source of Supply";
                    SKU."GXL Supplier Number" := WhSKU."GXL Supplier Number";
                    SKU."GXL Agent Number" := WhSKU."GXL Agent Number";
                    SKU."GXL Distributor Number" := WhSKU."GXL Distributor Number";
                end;
            end;

            SKU.Insert(true);

            SetSKU(SKU);
        end;
    end;

    ///<Summary>
    //Update SKU as product is ranged
    ///</Summary>
    local procedure UpdateSKU(VAR Item2: Record Item; Store: Record "LSC Store"; VariantCode: Code[10])
    var
        SKU: Record "Stockkeeping Unit";
    begin

        if not SKU.Get(Store."Location Code", Item2."No.", VariantCode) then
            CreateSKU(Item2, Store, VariantCode)
        else begin

            if SKU."GXL Effective Date" = 0D then
                SKU."GXL Effective Date" := Today();

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
                            SKU."GXL Discontinued Date" := Item2."GXL Discontinued Date";
                            if (Store."GXL Closed Date" < Item2."GXL Discontinued Date") and (Store."GXL Closed Date" <> 0D) then
                                SKU."GXL Discontinued Date" := Store."GXL Closed Date";
                        end;
                    end;
            end;

            SKU.Modify();
            SetSKU(SKU);
        end;
    end;

    ///<Summary>
    //Check if store is closed
    ///</Summary>
    procedure CheckStoreClosed(Store: Record "LSC Store"): Boolean
    var
    begin
        if (Store."GXL Closed Date" = 0D) or (Store."GXL Closed Date" > Today()) then
            exit(false)
        else
            exit(true);

    end;


    ///<Summary>
    //Check if store is closed
    ///</Summary>
    local procedure CheckDeletedDate(Store: Record "LSC Store")
    begin
        DeletedDate := 0D;
        EffectiveDate := GlobalItem."GXL Effective Date";
        if Store."GXL Open Date" > EffectiveDate then
            EffectiveDate := Store."GXL Open Date";

        DeletedDate := Store."GXL Closed Date";
    end;

    ///<Summary>
    //Not to be ranged if deleted date if it is set and before or equal to today date
    ///</Summary>
    local procedure GetRangeFlagFromDate(_DeletedDate: Date): Boolean
    begin
        if (_DeletedDate <> 0D) and (_DeletedDate <= Today()) then
            exit(false)
        else
            exit(true);
    end;


    ///<Summary>
    //Check source of supply warehouse SKU if it cannot be ranged
    ///</Summary>
    procedure SourceofSupplyCodeCannotBeRanged(ItemNo: Code[20]; LocCode: Code[10]): Boolean
    var
        SKU: Record "Stockkeeping Unit";
        WhSKU: Record "Stockkeeping Unit";
    begin
        SKU.Reset();
        SKU.SetRange("Item No.", ItemNo);
        SKU.SetRange("Location Code", LocCode);
        if SKU.IsEmpty() then
            exit(false);

        SKU.SetFilter("GXL Source of Supply Code", '<>%1', '');
        if SKU.FindFirst() then begin
            WhSKU.Reset();
            WhSKU.SetRange("Item No.", ItemNo);
            WhSKU.SetRange("Location Code", SKU."GXL Source of Supply Code");
            if WhSKU.FindFirst() then begin
                if not ProductStatusCanBeRanged(WhSKU."GXL Product Status") then
                    exit(true)
                else
                    exit(false);
            end else
                exit(false);
        end;
        exit(true);
    end;

    ///<Summary>
    //Get the active store SKU record where source of supply code is from the warehouse
    ///</Summary>
    procedure GetSOS(WhseCode: Code[10]; ItemNo: Code[20]; var WhSKU: Record "Stockkeeping Unit"): Boolean
    begin
        WhSKU.Reset();
        WhSKU.SetRange("Item No.", ItemNo);
        WhSKU.SetRange("GXL Source of Supply Code", WhseCode);
        WhSKU.SetFilter("GXL Product Status", '<>%1&<>%2', WhSKU."GXL Product Status"::Quit, WhSKU."GXL Product Status"::Inactive);
        if WhSKU.Findfirst() then
            exit(true);

        exit(false);
    end;

    ///<Summary>
    //Check product and store is in illegal item list
    ///</Summary>
    procedure CheckSKUIsLegal(ItemCode: Code[20]; StoreCode: Code[10]): Boolean
    var
        IllegalItem: Record "GXL Illegal Item";
    begin
        exit(IllegalItem.CheckSKUIsLegal(ItemCode, StoreCode, IllegalDate));
    end;

    ///<Summary>
    //Set the flag if the product is ranged but is in illegal item list
    //This flag will be used to log into illegal product range log
    ///</Summary>
    local procedure SetIllegalProdStoreRange(var _ProdStoreRange: Record "GXL Product-Store Ranging")
    begin
        IllegalSKURangeFlag := false;
        if _ProdStoreRange.Ranged then
            if NOT CheckSKUIsLegal(_ProdStoreRange."Item No.", _ProdStoreRange."Store Code") then begin
                IllegalSKURangeFlag := true;
                _ProdStoreRange.Ranged := false;
                if IllegalDate = 0D then
                    IllegalDate := Today();
                if (_ProdStoreRange."Deleted Date" = 0D) OR (_ProdStoreRange."Deleted Date" < IllegalDate) then
                    _ProdStoreRange."Deleted Date" := IllegalDate;
            end;
    end;

    ///<Summary>
    //Add to illegal product range log if the product is ranged but is in illegal item list
    ///</Summary>
    procedure LogIllegalProductRange(ItemCode: Code[20]; StoreCode: Code[10])
    var
        IllegalProdRangeLog: Record "GXL Illegal Product Range Log";
    begin
        //If already logged since the last modified date in Illegal Item table then do not log again
        if IllegalProdRangeLog.CheckIllegalProdLogged(ItemCode, StoreCode) then
            exit;

        IllegalProdRangeLog.LogIllegalProdRanged(ItemCode, StoreCode);
    end;

    ///<Summary>
    //Get the Illegal SKU Range flag
    ///</Summary>
    procedure GetIllegalSKURangeFlag(): Boolean
    begin
        exit(IllegalSKURangeFlag);
    end;

    ///<Summary>
    //De-Range all product-store ranging if status is changed to Quit/Inactive
    ///</Summary>
    procedure DerangeProductRangingOnQuit(var Item: Record Item)
    var
        ProductStoreRanging: Record "GXL Product-Store Ranging";
    begin
        if not ProductStatusCanBeRanged(Item."GXL Product Status") then begin
            ProductStoreRanging.SetRange("Item No.", Item."No.");
            ProductStoreRanging.SetRange(Ranged, true);
            if not ProductStoreRanging.IsEmpty() then
                ProductStoreRanging.ModifyAll(Ranged, false);
        end;
    end;

    ///<Summary>
    //De-Range product-store ranging for SKU if status is changed to Quit/Inactive
    ///</Summary>
    procedure DerangeProductRangingOnQuit(var SKU: Record "Stockkeeping Unit")
    var
        ProductStoreRanging: Record "GXL Product-Store Ranging";
    begin
        if not ProductStatusCanBeRanged(SKU."GXL Product Status") then begin
            ProductStoreRanging.SetRange("Item No.", SKU."Item No.");
            ProductStoreRanging.SetRange("Store Code", SKU."Location Code");
            ProductStoreRanging.SetRange(Ranged, true);
            if ProductStoreRanging.FindFirst() then begin
                ProductStoreRanging."Last Deleted Date" := ProductStoreRanging."Deleted Date";
                if (SKU."GXL Quit Date" = 0D) or (SKU."GXL Quit Date" > Today()) then
                    ProductStoreRanging."Deleted Date" := Today()
                else
                    ProductStoreRanging."Deleted Date" := SKU."GXL Quit Date";
                ProductStoreRanging.Ranged := false;
                ProductStoreRanging.Modify(true);
            end;
        end;
    end;

}