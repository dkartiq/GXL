codeunit 50006 "GXL Product Status Management"
{
    ///<Summary>
    //Product Status Life cycle    
    //Approved Products
    //--has been created. The status is set upon Product creation in the system
    //New Line Products
    //--is newly ranged and either hasn't arrived into the business yet, 
    //--or is less than 4 weeks old (based on First Store Receipt Date) and one week prior to delivery into the first store
    //--The system needs to update the status ovrnight
    //Active Products
    //--is part of the current range and has been in stores for 4 or more weeks. (Based on First Receipt at first store)
    //--The system needs to update the status ovrnight
    //Discontinued-WH only Products
    //--for WH products only
    //--is currently Active, but no further orders will be placed into the WH. 
    //--Store orders will still be generated up until stock has been depleted from the WH
    //--When a Discontinued Date is entered into the System at the Product level the system needs to update the status overnight
    //Quit Products
    //--will no longer be ranged
    //--No more stock exists in WH. 
    //--When a Quit Date is entered into the system at the Product Level, the system needs to update the status overnight.
    //--If the product is Discontinued (WH Only), once the Stock on hand in the WH equals zero, and there are no further orders due to arrive, the system needs to update the status overnight.
    //Inactive Products 
    //--When there is not more stocks and no further orders will be placed in any WH or store
    //--when a Quit date is entered into the system
    ///</Summary>
    trigger OnRun()
    begin

    end;

    var
        Location: Record Location;
        Store: Record "LSC Store";
        GlobalItem: Record Item;
        GlobalItemRead: Boolean;
        SkipUpdateSKUs: Boolean;
        SourceOfSupplyMustBeWHErr: Label 'Source of Supply must be WH. Status cannot be changed';
        WHSKUHasStockErr: Label 'WH SKU has stock. Status cannot be changed';


    ///<Summary>
    //Update product status on item card
    //It should be only called via batch job
    ///</Summary>
    procedure UpdateItemStatus(var Item: Record Item)
    var
        FirstRcptDate: Date;
        NewProdStatus: Enum "GXL Product Status";
    begin
        if Item."GXL Product Status" = Item."GXL Product Status"::Inactive then
            exit;

        NewProdStatus := Item."GXL Product Status";

        //Set to Discontined-WH if conditions are met
        if ProductStatusIsActiveRange(Item."GXL Product Status") then
            if IsDiscontinuedDateMet(Item."GXL Discontinued Date") then
                if Item."GXL Source of Supply" = Item."GXL Source of Supply"::WH then
                    NewProdStatus := Item."GXL Product Status"::"Discontinued-WH only";

        //Set to Quit if conditions are met
        if NewProdStatus <> NewProdStatus::Quit then
            if IsQuitConditionsMet(Item) then
                NewProdStatus := Item."GXL Product Status"::Quit;

        case NewProdStatus of
            Item."GXL Product Status"::Approved,
            Item."GXL Product Status"::"New-Line",
            Item."GXL Product Status"::Active:
                begin
                    //Approved => New-Line if first receipt date is within 7 days but less than 4 weeks
                    //New-Line => Active if first receipt date is more then 4 weeks
                    if (not IsQuitDateMet(Item."GXL Quit Date")) and (not IsDiscontinuedDateMet(Item."GXL Discontinued Date")) then begin
                        //CR036 +
                        //CalcFields("GXL First Receipt Date");
                        //FirstRcptDate := "GXL First Receipt Date";
                        FirstRcptDate := GetFirstReceiptDate_Item(Item);
                        //CR036 -
                        if (FirstRcptDate <> 0D) then begin
                            if IsActiveProduct(FirstRcptDate) then
                                NewProdStatus := Item."GXL Product Status"::Active
                            else begin
                                if IsNewLineProduct(FirstRcptDate) then
                                    NewProdStatus := Item."GXL Product Status"::"New-Line"
                                else
                                    NewProdStatus := Item."GXL Product Status"::Approved;
                            end;
                        end;
                    end;
                end;

            Item."GXL Product Status"::"Discontinued-WH only":
                begin
                    //This status is only be applicable if Source of supply is WH
                    //Discontinued-WH => Quit if all WH SKUs have no stock
                    if Item."GXL Source of Supply" = Item."GXL Source of Supply"::WH then
                        if (not IsQuitDateMet(Item."GXL Quit Date")) and IsDiscontinuedDateMet(Item."GXL Discontinued Date") then
                            if not WHSKUHasStock(Item) then
                                NewProdStatus := Item."GXL Product Status"::Quit;
                end;
            Item."GXL Product Status"::Quit:
                begin
                    //Quit => Inactive if there is no stock or outstanfing PO
                    if not CheckHasStock(Item) then
                        NewProdStatus := Item."GXL Product Status"::Inactive;
                end;
        end;

        if Item."GXL Product Status" <> NewProdStatus then begin
            if SkipUpdateSKUs then
                Item."GXL Product Status" := NewProdStatus
            else
                Item.Validate("GXL Product Status", NewProdStatus);
        end;
    end;

    ///<Summary>
    //Update product status on SKU
    //It should be only called via batch job
    ///</Summary>
    procedure UpdateSKUStatus(var SKU: Record "Stockkeeping Unit")
    var
        ProdRangingMgt: Codeunit "GXL Product Ranging Management";
        NewProductStatus: Enum "GXL Product Status";
        NewQuitDate: Date;
        FirstRcptDate: Date;
        ItemProdStatusIsActive: Boolean;
    begin
        if SKU."GXL Product Status" = SKU."GXL Product Status"::Inactive then
            exit;

        if not GetGlobalItem(SKU."Item No.") then
            exit;
        ItemProdStatusIsActive := ProductStatusIsActiveRange(GlobalItem."GXL Product Status");

        NewProductStatus := SKU."GXL Product Status";
        NewQuitDate := 0D;
        SKU.CalcFields("GXL Warehouse SKU");

        //Set Discountinued-WH if conditions are met
        //Note that only warehouse SKU has discontinued date entered
        if ProductStatusIsActiveRange(SKU."GXL Product Status") then
            if IsDiscontinuedDateMet(SKU."GXL Discontinued Date") then
                if (SKU."GXL Source of Supply" = SKU."GXL Source of Supply"::WH) then
                    NewProductStatus := SKU."GXL Product Status"::"Discontinued-WH only";

        //Set Quit if conditions are met
        if NewProductStatus <> NewProductStatus::Quit then begin
            if IsQuitConditionsMet(SKU) then
                NewProductStatus := SKU."GXL Product Status"::Quit;
        end;

        case NewProductStatus of
            SKU."GXL Product Status"::Approved,
            SKU."GXL Product Status"::"New-Line",
            SKU."GXL Product Status"::Active:
                begin
                    //Approved => New-Line if first receipt date is within 7 days but less than 4 weeks
                    //Approved => Active if first receipt date is more then 4 weeks (it is just in case if the batch job did not run in-time)
                    if (not IsQuitDateMet(SKU."GXL Quit Date")) and (not IsDiscontinuedDateMet(SKU."GXL Discontinued Date")) and
                        ItemProdStatusIsActive then begin
                        //CR036 +
                        //CalcFields("GXl First Receipt Date");
                        //FirstRcptDate := "GXl First Receipt Date";
                        FirstRcptDate := GetFirstReceiptDate_SKU(SKU);
                        //CR036 -
                        if (FirstRcptDate <> 0D) then begin
                            if IsActiveProduct(FirstRcptDate) then
                                NewProductStatus := SKU."GXL Product Status"::Active
                            else begin
                                if IsNewLineProduct(FirstRcptDate) then
                                    NewProductStatus := SKU."GXL Product Status"::"New-Line"
                                else
                                    NewProductStatus := SKU."GXL Product Status"::Approved;
                            end;
                        end;
                    end;
                end;

            SKU."GXL Product Status"::"Discontinued-WH only":
                begin
                    //This status is only be applicable if Source of supply is WH
                    //Discontinued-WH => Quit if SKU is warehouse SKU and have no stock
                    if SKU."GXL Source of Supply" = SKU."GXL Source of Supply"::WH then begin
                        if (not IsQuitDateMet(SKU."GXL Quit Date")) and IsDiscontinuedDateMet(SKU."GXL Discontinued Date") and
                            SKU."GXL Warehouse SKU" then
                            if not SKUHasStock(SKU) then begin
                                NewProductStatus := SKU."GXL Product Status"::Quit;
                                NewQuitDate := Today();
                            end;
                    end;
                end;

            SKU."GXL Product Status"::Quit:
                begin
                    //Quit => Inactive if there is no stock or outstanfing PO
                    if not SKUHasStock(SKU) then
                        NewProductStatus := SKU."GXL Product Status"::Inactive;
                end;
        end;

        if NewProductStatus <> SKU."GXL Product Status" then begin
            //Not to run Validate 
            SKU."GXL Product Status" := NewProductStatus;
            if NewQuitDate <> 0D then
                //Validate Quit Date will validate Quit Date and status for other related store SKUs, if applicable
                //and also will de-range the SKU
                SKU.Validate("GXL Quit Date", NewQuitDate)
            else
                ProdRangingMgt.DerangeProductRangingOnQuit(SKU);

        end;
    end;

    ///<Summary>
    //Check if the discontinued date is before or equal today date
    ///</Summary>
    local procedure IsDiscontinuedDateMet(DiscontinuedDate: Date): Boolean
    begin
        if DiscontinuedDate <> 0D then
            if DiscontinuedDate <= Today() then
                exit(true);
        exit(false);
    end;

    ///<Summary>
    //Check if quit date is before is equal to today date
    ///</Summary>
    local procedure IsQuitDateMet(QuitDate: Date): Boolean
    begin
        if (QuitDate <> 0D) then
            if (QuitDate <= Today()) then
                exit(true);
        exit(false);
    end;

    ///<Summary>
    //Product has not been arrived in the business yet or just arrived in one week
    ///</Summary>
    procedure IsApprovedProduct(FirstRcptDate: Date): Boolean
    begin
        if FirstRcptDate <> 0D then begin
            if (Today() - FirstRcptDate) <= 7 then
                exit(true)
            else
                exit(false);
        end else
            exit(true);
    end;

    ///<Summary>
    //Product has arrived in the business in less than 4 weeks
    ///</Summary>
    procedure IsNewLineProduct(FirstRcptDate: Date): Boolean
    begin
        if FirstRcptDate <> 0D then
            if ((Today() - FirstRcptDate) <= 28) and ((Today() - FirstRcptDate) > 7) then
                exit(true);
        exit(false);
    end;

    ///<Summary>
    //Product has arrived in the business for more than 4 weeks
    ///</Summary>
    procedure IsActiveProduct(FirstRcptDate: Date): Boolean
    begin
        if (FirstRcptDate <> 0D) then
            if ((Today() - FirstRcptDate) > 28) then
                exit(true);
        exit(false);
    end;

    ///<Summary>
    //The following conditions are to be set the status to be Quit:
    //  Quit date is before or equal to today date
    //  Source of supply is WH and all the Warehouse SKUs contain no stock
    //  Source of supply is not WH
    ///</Summary>
    local procedure IsQuitConditionsMet(var Item: Record Item): Boolean
    begin
        if not IsQuitDateMet(Item."GXL Quit Date") then
            exit(false);

        //If source of supply is WH then check if any WH SKU has SOH or outstanding PO
        if Item."GXL Source of Supply" = Item."GXL Source of Supply"::WH then begin
            if not WHSKUHasStock(Item) then
                exit(true)
            else
                exit(false);
        end else
            exit(true);
    end;

    ///<Summary>
    //The following conditions are to be set the status to be Quit:
    //  Quit date is before or equal to today date
    //  Source of supply is WH and SKU is a Warehouse SKU and contain no stock
    //  Source of supply is WH and SKU is not a Warehouse SKU
    //  Source of supply is not WH
    ///</Summary>
    local procedure IsQuitConditionsMet(var SKU: Record "Stockkeeping Unit"): Boolean
    begin
        if not IsQuitDateMet(SKU."GXL Quit Date") then
            exit(false);

        //If source of supply is WH and SKU is a warehouse SKU, then check if stock exists
        if SKU."GXL Source of Supply" = SKU."GXL Source of Supply"::WH then begin
            SKU.CalcFields("GXL Warehouse SKU");
            if SKU."GXL Warehouse SKU" then begin
                if not SKUHasStock(SKU) then
                    exit(true)
                else
                    exit(false);
            end else
                exit(true);
        end else
            exit(true);
    end;

    ///<Summary>
    //The following conditions will set status to Inactive
    //  Status is Quit
    //  All SKUs contain no stock
    ///</Summary>
    local procedure IsInactiveConditionsMet(var Item: Record Item): Boolean
    begin
        if Item."GXL Product Status" <> Item."GXL Product Status"::Quit then
            exit(false);

        if CheckHasStock(Item) then
            exit(false)
        else
            exit(true);
    end;


    ///<Summary>
    //The following conditions will set status to Inactive
    //  Status is Quit
    //  SKU contains no stock
    ///</Summary>
    local procedure IsInactiveConditionsMet(var SKU: Record "Stockkeeping Unit"): Boolean
    begin
        if SKU."GXL Product Status" <> SKU."GXL Product Status"::Quit then
            exit(false);

        if SKUHasStock(SKU) then
            exit(false)
        else
            exit(true);
    end;

    ///<Summary>
    //Check if product status is either Approved, New-Line, Active
    ///</Summary>
    local procedure ProductStatusIsActiveRange(ProdStatus: Enum "GXL Product Status"): Boolean
    begin

        if ProdStatus in [ProdStatus::Approved, ProdStatus::"New-Line", ProdStatus::Active] then
            exit(true)
        else
            exit(false);
    end;


    ///<Summary>
    //Product Status on Item is updated manually
    //Status can only be changed manually if the following conditions are met
    //  - Approved, New-Line and Active: 
    //    Re-validate the status by checking the first receipt date
    //    Set the discontinued date and quit date if they are not blank and before or equal to today date
    //  - Discontinued-WH only:
    //    Only allowed if Source of supply is WH
    //    Set the Discontinued Date if it is not set or after today date
    //  - Quit:
    //    If Source of supply is WH, only allowed if all warehouse SKUs contain no stock
    //    Set the Quit Date if it is not set or after today date
    //  - Inactive:
    //    Only allowed if all the SKUs contain no stock
    //
    //  Flow the product status to SKUs - logic of product status in SKU will be followed
    ///</Summary>
    procedure OnValidateProductStatus_Item(var Item: Record Item; var xItem: Record Item; CurrFieldNo: Integer)
    var
        FirstRcptDate: Date;
    begin
        if Item."GXL Product Status" <> xItem."GXL Product Status" then begin
            case Item."GXL Product Status" of
                Item."GXL Product Status"::Approved,
                Item."GXL Product Status"::"New-Line",
                Item."GXL Product Status"::Active:
                    begin
                        if CurrFieldNo = Item.FieldNo("GXL Product Status") then begin
                            //Revalidate status to make sure it is correct on update manually
                            //CR036 +
                            //CalcFields("GXL First Receipt Date");
                            //FirstRcptDate := "GXl First Receipt Date";
                            FirstRcptDate := GetFirstReceiptDate_Item(Item);
                            //CR036 -
                            if IsActiveProduct(FirstRcptDate) then
                                Item."GXL Product Status" := Item."GXL Product Status"::Active
                            else
                                if IsNewLineProduct(FirstRcptDate) then
                                    Item."GXL Product Status" := Item."GXL Product Status"::"New-Line"
                                else
                                    Item."GXL Product Status" := Item."GXL Product Status"::Approved;
                        end;

                        if (Item."GXL Discontinued Date" <> 0D) and (Item."GXL Discontinued Date" <= Today()) then
                            Item.Validate("GXL Discontinued Date", 0D);
                        if (Item."GXL Quit Date" <> 0D) and (Item."GXL Quit Date" <= Today()) then
                            Item.Validate("GXL Quit Date", 0D);
                    end;

                Item."GXL Product Status"::"Discontinued-WH only":
                    begin
                        //Only source of supply WH is allowed
                        if Item."GXL Source of Supply" <> Item."GXL Source of Supply"::WH then
                            Error(SourceOfSupplyMustBeWHErr);
                        if (Item."GXL Discontinued Date" > Today()) or (Item."GXL Discontinued Date" = 0D) then
                            Item.Validate("GXL Discontinued Date", Today());
                    end;

                Item."GXL Product Status"::Quit:
                    begin
                        //If source of supply is WH and any WH SKUs have stock then not allowed
                        if Item."GXL Source of Supply" = Item."GXL Source of Supply"::WH then begin
                            if WHSKUHasStock(Item) then
                                Error(WHSKUHasStockErr)
                        end;
                        if (Item."GXL Quit Date" > Today()) or (Item."GXL Quit Date" = 0D) then
                            Item.Validate("GXL Quit Date", Today());
                    end;

                Item."GXL Product Status"::Inactive:
                    begin
                        //Total inventory is not zero or at least one store contains stock, not allowed
                        if CheckHasStock(Item) then
                            Error('The stock on hand or stock on order is not zero for item ' + Item."No.");
                    end;
            end;
        end;
    end;

    ///<Summary>
    //Update Discontinued Date manually on Item
    //  Only allowed if source of supply os WH
    //  If discontinued date is before or equal to today date the set status to Discontinued-WH only
    //  Flow the discontinued date to warehouse SKUs that are still in active stage
    ///</Summary>
    procedure OnValidateDiscontinuedDate_Item(var Item: Record Item; var xItem: Record Item)
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if Item."GXL Discontinued Date" <> 0D then
            if Item."GXL Source of Supply" <> Item."GXL Source of Supply"::WH then
                Error(SourceOfSupplyMustBeWHErr);

        if Item."GXL Discontinued Date" <> xItem."GXL Discontinued Date" then begin
            if IsDiscontinuedDateMet(Item."GXL Discontinued Date") then
                Item."GXL Product Status" := Item."GXL Product Status"::"Discontinued-WH only";

            //Update WH SKU
            Store.SetCurrentKey("GXL Location Type");
            Store.SetRange("GXL Location Type", Store."GXL Location Type"::"3"); //WH
            if Store.FindSet() then
                repeat
                    SKU.SetRange("Item No.", Item."No.");
                    SKU.SetRange("Location Code", Store."Location Code");
                    SKU.SetFilter("GXL Product Status", '%1|%2|%3|%4',
                        SKU."GXL Product Status"::Approved, SKU."GXL Product Status"::"New-Line", SKU."GXL Product Status"::Active,
                        SKU."GXL Product Status"::"Discontinued-WH only");
                    if SKU.FindFirst() then begin
                        SKU.Validate("GXL Discontinued Date", Item."GXL Discontinued Date");
                        SKU.Modify(true);
                    end;
                until Store.Next() = 0;
        end;
    end;

    ///<Summary>
    //Update Quit Date manually on Item
    //  If quit date is before or equal to today date and all the warehouse SKUs contain no stock then set status to Quit
    //  Flow the quit date to SKUs that are still in active stage
    ///</Summary>
    procedure OnValidateQuitDate_Item(var Item: Record Item; var xItem: Record Item)
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if Item."GXL Quit Date" <> xItem."GXL Quit Date" then begin
            if not WHSKUHasStock(Item) then begin
                if IsQuitDateMet(Item."GXL Quit Date") then
                    Item."GXL Product Status" := Item."GXL Product Status"::Quit;

                SKU.SetRange("Item No.", Item."No.");
                if SKU.FindSet() then
                    repeat
                        UpdateSKUQuitDate(SKU, SKU, Item."GXL Quit Date");
                        SKU.Modify();
                    until SKU.Next() = 0;
            end else
                UpdateWHSKUQuitDate(Item);
        end;
    end;

    ///<Summary>
    //Update Source of Supply manually on Item
    //  If product status is Discontinued-WH, only allowed if source of supply is WH
    ///</Summary>
    procedure OnValidateSourceOfSupply_Item(var Item: Record Item; var
                                                                       xItem: Record Item)
    begin
        if Item."GXL Source of Supply" <> xItem."GXL Source of Supply" then begin
            if Item."GXL Product Status" = Item."GXL Product Status"::"Discontinued-WH only" then
                if Item."GXL Source of Supply" <> Item."GXL Source of Supply"::WH then
                    Error('Product Status %1 can only be used for WH.', Item."GXL Product Status");
        end;
    end;

    ///<Summary>
    //Product Status on SKU is updated manually
    //Status can only be changed manually if the following conditions are met
    //  - Approved, New-Line and Active:     
    //    Re-validate the status by checking the first receipt date
    //    Set the discontinued date and quit date if they are not blank and before or equal to today date
    //  - Discontinued-WH only:
    //    Only allowed if Source of supply is WH
    //    If the SKU is a warehouse SKU, set the Discontinued Date if it is not set or after today date
    //  - Quit:
    //    If Source of supply is WH and is a warehouse SKU, only allowed if SKU contains no stock
    //    Set the Quit Date if it is not set or after today date
    //  - Inactive:
    //    Only allowed if SKU contains no stock
    ///</Summary>
    procedure OnValidateProductStatus_SKU(var SKU: Record "Stockkeeping Unit"; var xSKU: Record "Stockkeeping Unit"; CurrFieldNo: Integer)
    var
        ProdRangingMgt: Codeunit "GXL Product Ranging Management";
        FirstRcptDate: Date;
    begin
        if SKU."GXL Product Status" <> xSKU."GXL Product Status" then begin
            if SKU."GXL Product Status" in [SKU."GXL Product Status"::Approved, SKU."GXL Product Status"::"New-Line",
                                        SKU."GXL Product Status"::Active, SKU."GXL Product Status"::"Discontinued-WH only"] then
                //If store is closed, there is no need to update status
                if IsStoreClosed(SKU) then begin
                    SKU."GXL Product Status" := xSKU."GXL Product Status";
                    exit;
                end;

            case SKU."GXL Product Status" of
                SKU."GXL Product Status"::Approved,
                SKU."GXL Product Status"::"New-Line":
                    begin
                        //Note that Discontinued Date when it is set, the status will be changed to Discontuned-WH only
                        //So this case only occurs when status is changed manually, or is flowed from Item
                        if (SKU."GXL Discontinued Date" <> 0D) and (SKU."GXL Discontinued Date" <= Today()) then
                            SKU.Validate("GXL Discontinued Date", 0D);

                        //Note that Quit Date when it is set, the status will be changed to Quit for non-warehouse
                        //So this case only occurs when status is changed manually, or is flowed from Item
                        if (SKU."GXL Quit Date" <> 0D) and (SKU."GXL Quit Date" <= Today()) then
                            SKU.Validate("GXL Quit Date", 0D);
                    end;

                SKU."GXL Product Status"::Active:
                    begin
                        //Re-validate Status to make sure it is correct as Active Status won't be touched by the batch job
                        //CR036 +
                        //CalcFields("GXl First Receipt Date");
                        //FirstRcptDate := "GXl First Receipt Date";
                        FirstRcptDate := GetFirstReceiptDate_SKU(SKU);
                        //CR036 -
                        if IsActiveProduct(FirstRcptDate) then
                            SKU."GXL Product Status" := SKU."GXL Product Status"::Active
                        else
                            if IsNewLineProduct(FirstRcptDate) then
                                SKU."GXL Product Status" := SKU."GXL Product Status"::"New-Line"
                            else
                                SKU."GXL Product Status" := SKU."GXL Product Status"::Approved;

                        //Note that Discontinued Date when it is set, the status will be changed to Discontuned-WH only
                        //So this case only occurs when status is changed manually, or is flowed from Item
                        if (SKU."GXL Discontinued Date" <> 0D) and (SKU."GXL Discontinued Date" <= Today()) then
                            SKU.Validate("GXL Discontinued Date", 0D);

                        //Note that Quit Date when it is set, the status will be changed to Quit for non-warehouse
                        //So this case only occurs when status is changed manually, or is flowed from Item
                        if (SKU."GXL Quit Date" <> 0D) and (SKU."GXL Quit Date" <= Today()) then
                            SKU.Validate("GXL Quit Date", 0D);
                    end;

                SKU."GXL Product Status"::"Discontinued-WH only":
                    begin
                        //Only Source of supply WH is allowed
                        //If SKU is a warehouse SKU, update discontinued date if not set
                        if SKU."GXL Source of Supply" <> SKU."GXL Source of Supply"::WH then
                            Error(SourceOfSupplyMustBeWHErr);
                        SKU.CalcFields("GXL Warehouse SKU");
                        if SKU."GXL Warehouse SKU" then begin
                            if SKU."GXL Discontinued Date" = 0D then
                                SKU.Validate("GXL Discontinued Date", Today());
                        end;
                    end;

                SKU."GXL Product Status"::Quit:
                    begin
                        //Not allowed to chnage status to Quit if source of supply is WH and is a warehouse SKU and has stock
                        if SKU."GXL Source of Supply" = SKU."GXL Source of Supply"::WH then begin
                            SKU.CalcFields("GXL Warehouse SKU");
                            if SKU."GXL Warehouse SKU" then begin
                                if CurrFieldNo = SKU.FieldNo("GXL Product Status") then begin
                                    if SKUHasStock(SKU) then begin
                                        if GuiAllowed() then
                                            Error(WHSKUHasStockErr)
                                        else begin
                                            SKU."GXL Product Status" := xSKU."GXL Product Status";
                                            exit;
                                        end;
                                    end;
                                end;
                            end;
                            if CurrFieldNo <> SKU.FieldNo("GXL Quit Date") then
                                if (SKU."GXL Quit Date" = 0D) or (SKU."GXL Quit Date" > Today()) then
                                    SKU.Validate("GXL Quit Date", Today());

                            //When warehouse SKU's status is quit, update all related stores to quit as well
                            if SKU."GXL Warehouse SKU" then
                                UpdateStoreSKU(SKU);
                        end else
                            if CurrFieldNo <> SKU.FieldNo("GXL Quit Date") then
                                if (SKU."GXL Quit Date" = 0D) or (SKU."GXL Quit Date" > Today()) then
                                    SKU.Validate("GXL Quit Date", Today());
                    end;

                SKU."GXL Product Status"::Inactive:
                    begin
                        if CurrFieldNo = SKU.FieldNo("GXL Product Status") then begin
                            if SKUHasStock(SKU) then
                                if GuiAllowed() then
                                    Error(StrSubstNo('SKU %1 - %2 still has stock', SKU."Item No.", SKU."Location Code"))
                                else begin
                                    SKU."GXL Product Status" := xSKU."GXL Product Status";
                                    exit;
                                end;
                        end;
                    end;
            end;

            ProdRangingMgt.DerangeProductRangingOnQuit(SKU);

        end;
    end;

    ///<Summary>
    //Update Discontinued Date manually on SKU
    //  Only allowed if source of supply os WH and SKU is a warehouse SKU
    //  If discontinued date is before or equal to today date the set status to Discontinued-WH only
    ///</Summary>
    procedure OnValidateDiscontinuedDate_SKU(var SKU: Record "Stockkeeping Unit"; var xSKU: Record "Stockkeeping Unit")
    begin
        if SKU."GXL Discontinued Date" <> xSKU."GXL Discontinued Date" then begin
            if SKU."GXL Discontinued Date" <> 0D then begin
                if SKU."GXL Source of Supply" <> SKU."GXL Source of Supply"::WH then
                    Error(SourceOfSupplyMustBeWHErr);
                SKU.CalcFields("GXL Warehouse SKU");
                if not SKU."GXL Warehouse SKU" then
                    SKU.TestField("GXL Warehouse SKU", true);
            end;
            if IsDiscontinuedDateMet(SKU."GXL Discontinued Date") then
                SKU."GXL Product Status" := SKU."GXL Product Status"::"Discontinued-WH only";
        end;
    end;

    ///<Summary>
    //Update Quit Date manually on Item
    //  If quit date is before or equal to today date, update status to Quit 
    //      Except if source of supply is WH and SKU is a warehouse SKU and contains stock, status won't be changed
    ///</Summary>
    procedure OnValidateQuitDate_SKU(var SKU: Record "Stockkeeping Unit"; var xSKU: Record "Stockkeeping Unit"; CurrFldNo: Integer)
    var
        ProdRangingMgt: Codeunit "GXL Product Ranging Management";
    begin
        if SKU."GXL Quit Date" <> xSKU."GXL Quit Date" then begin
            Clear(Store);
            Location.Code := SKU."Location Code";
            if Location.GetAssociatedStore(Store, true) then begin
                if Store."GXL Closed Date" <> 0D then
                    if (SKU."GXL Quit Date" > Store."GXL Closed Date") or (SKU."GXL Quit Date" = 0D) then
                        SKU."GXL Quit Date" := Store."GXL Closed Date";
            end;
            if (SKU."GXL Quit Date" <> xSKU."GXL Quit Date") then begin
                SKU.CalcFields("GXL Warehouse SKU");
                if IsQuitDateMet(SKU."GXL Quit Date") then begin
                    if (SKU."GXL Source of Supply" = SKU."GXL Source of Supply"::WH) then begin
                        if SKU."GXL Warehouse SKU" then begin
                            if not SKUHasStock(SKU) then begin
                                if CurrFldNo = SKU.FieldNo("GXL Quit Date") then
                                    //The validation on product status will update ranging                                   
                                    SKU.Validate("GXL Product Status", SKU."GXL Product Status"::Quit);

                                //When warehouse SKU's status is quit, update all related stores to quit as well
                                UpdateStoreSKU(SKU);
                            end;
                        end else begin
                            SKU."GXL Product Status" := SKU."GXL Product Status"::Quit;
                        end;
                    end else
                        SKU."GXL Product Status" := SKU."GXL Product Status"::Quit;
                end;
                if not SKU."GXL Warehouse SKU" then
                    ProdRangingMgt.DerangeProductRangingOnQuit(SKU);
            end;
        end;
    end;

    ///<Summary>
    //Update Source of Supply manually on SKU
    //  If product status is Discontinued-WH, only allowed if source of supply os WH
    ///</Summary>
    procedure OnValidateSourceOfSupply_SKU(var SKU: Record "Stockkeeping Unit"; var xSKU: Record "Stockkeeping Unit")
    begin
        if SKU."GXL Source of Supply" <> xSKU."GXL Source of Supply" then begin
            if SKU."GXL Product Status" = SKU."GXL Product Status"::"Discontinued-WH only" then
                if SKU."GXL Source of Supply" <> SKU."GXL Source of Supply"::WH then
                    Error('Product Status %1 can only be used for WH.', SKU."GXL Product Status");
        end;
    end;

    ///<Summary>
    //Only applicable for item that its source of supply is WH
    //Check if any of the warehouse SKU contains stock
    ///</Summary>
    local procedure WHSKUHasStock(var Item: Record Item): Boolean
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if Item."GXL Source of Supply" = Item."GXL Source of Supply"::WH then begin
            Store.SetCurrentKey("GXL Location Type");
            Store.SetRange("GXL Location Type", Store."GXL Location Type"::"3"); //3=WH
            if Store.FindSet() then
                repeat
                    SKU.SetRange("Item No.", Item."No.");
                    SKU.SetRange("Location Code", Store."Location Code");
                    if SKU.FindFirst() then begin
                        if SKUHasStock(SKU) then
                            exit(true);
                    end;
                until Store.Next() = 0;
        end;
        exit(false);
    end;

    //<Summary>
    //Check if inventory is zero and no oustanding POs/TOs
    //Check all SKUs that have zero inventory and oustanding POs/TOs
    //</Summary>
    local procedure CheckHasStock(var Item: Record Item): Boolean
    var
        SKU: Record "Stockkeeping Unit";
    begin
        Item.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit");
        if (Item.Inventory <> 0) or (Item."Qty. on Purch. Order" <> 0) or (Item."Qty. in Transit" <> 0) then
            exit(true);

        SKU.SetRange("Item No.", Item."No.");
        SKU.SetAutoCalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit");
        if SKU.FindSet() then
            repeat
                if SKUHasStock(SKU) then
                    exit(true);
            until SKU.Next() = 0;

        exit(false);
    end;

    /*
    //<Summary>
    //Check if SKU has zero stock on hand (physical SOH) and oustanding POs
    //</Summary>
    local procedure SKUHasStock_SOH(var SKU: Record "Stockkeeping Unit"): Boolean
    begin
        with SKU do begin
            CalcFields("Qty. on Purch. Order");
            if ("Qty. on Purch. Order" <> 0) or ("GXL Total SOH" <> 0) then
                exit(true)
            else
                exit(false);
        end;
    end;
    */

    //<Summary>
    //Check if SKU has zero inventory and outstanging POs/TOs
    //</Summary>
    local procedure SKUHasStock(var SKU: Record "Stockkeeping Unit"): Boolean
    begin
        SKU.CalcFields(Inventory, "Qty. on Purch. Order", "Qty. in Transit");
        if (SKU.Inventory <> 0) or (SKU."Qty. on Purch. Order" <> 0) or (SKU."Qty. in Transit" <> 0) then
            exit(true)
        else
            exit(false);
    end;


    //<Summary>
    //Update SKUs Product Status and Quit Date for stores that have the same Source of Supply Code
    //</Summary>
    local procedure UpdateStoreSKU(var SKU: Record "Stockkeeping Unit")
    var
        StoreSKU: Record "Stockkeeping Unit";
    begin
        StoreSKU.SetCurrentKey("GXL Source of Supply Code");
        StoreSKU.SetRange("Item No.", SKU."Item No.");
        StoreSKU.SetRange("GXL Source of Supply Code", SKU."Location Code");
        if StoreSKU.FindSet() then
            repeat
                if (StoreSKU."GXL Product Status" <> StoreSKU."GXL Product Status"::Quit) or (StoreSKU."GXL Quit Date" <> SKU."GXL Quit Date") then begin
                    StoreSKU."GXL Product Status" := SKU."GXL Product Status";
                    StoreSKU.Validate("GXL Quit Date", SKU."GXL Quit Date");
                    StoreSKU.Modify(true);
                end;
            until StoreSKU.Next() = 0;
    end;

    //<Summary>
    //Check if the store is closed
    //</Summary>
    procedure IsStoreClosed(SKU: Record "Stockkeeping Unit"): Boolean
    begin
        Location.Code := SKU."Location Code";
        if Location.GetAssociatedStore(Store, true) then
            if (Store."GXL Closed Date" <> 0D) and (Store."GXL Closed Date" <= Today()) then
                exit(true);
        exit(false);
    end;


    procedure SetGlobalItem(NewItem: Record Item)
    begin
        GlobalItem := NewItem;
        GlobalItemRead := true;
    end;

    local procedure GetGlobalItem(ItemNo: Code[20]): Boolean
    begin
        if not GlobalItemRead then begin
            if not GlobalItem.Get(ItemNo) then
                exit(false);
            GlobalItemRead := true;
        end;
        exit(true);
    end;


    //<Summmary>
    //Update Quit Date on warehouse SKU
    //</Summary>
    local procedure UpdateWHSKUQuitDate(Item: Record Item)
    var
        SKU: Record "Stockkeeping Unit";
    begin
        if Item."GXL Quit Date" = 0D then begin
            SKU.SetRange("Item No.", Item."No.");
            SKU.SetFilter("GXL Product Status", '%1|%2|%3|%4',
                SKU."GXL Product Status"::Approved, SKU."GXL Product Status"::"New-Line", SKU."GXL Product Status"::Active,
                SKU."GXL Product Status"::"Discontinued-WH only");
            if SKU.FindSet() then
                repeat
                    if SKU."GXL Quit Date" <> 0D then begin
                        SKU.Validate("GXL Quit Date", 0D);
                        SKU.Modify(true);
                    end;
                until SKU.Next() = 0;
        end else begin
            //Update WH SKU
            Store.SetCurrentKey("GXL Location Type");
            Store.SetRange("GXL Location Type", Store."GXL Location Type"::"3"); //WH
            if Store.FindSet() then
                repeat
                    SKU.SetRange("Item No.", Item."No.");
                    SKU.SetRange("Location Code", Store."Location Code");
                    SKU.SetFilter("GXL Product Status", '%1|%2|%3|%4',
                        SKU."GXL Product Status"::Approved, SKU."GXL Product Status"::"New-Line", SKU."GXL Product Status"::Active,
                        SKU."GXL Product Status"::"Discontinued-WH only");
                    if SKU.FindFirst() then begin
                        UpdateSKUQuitDate(SKU, SKU, Item."GXL Quit Date");
                        SKU.Modify(true);
                    end;
                until Store.Next() = 0;

        end;
    end;

    //<Summmary>
    //Update Quit Date on SKU
    //</Summary>
    local procedure UpdateSKUQuitDate(var SKU: Record "Stockkeeping Unit"; var xSKU: Record "Stockkeeping Unit"; QuitDate: Date)
    begin
        if (QuitDate > SKU."GXL Quit Date") and (SKU."GXL Product Status" in [SKU."GXL Product Status"::Quit, SKU."GXL Product Status"::Inactive]) then
            exit;

        SKU."GXL Quit Date" := QuitDate;
        Clear(Store);
        Location.Code := SKU."Location Code";
        if Location.GetAssociatedStore(Store, true) then
            if Store."GXL Closed Date" <> 0D then
                if (QuitDate > Store."GXL Closed Date") or (QuitDate = 0D) then
                    QuitDate := Store."GXL Closed Date";

        if (QuitDate <> 0D) then begin
            if (SKU."GXL Source of Supply" = SKU."GXL Source of Supply"::WH) then begin
                SKU.CalcFields("GXL Warehouse SKU");
                if SKU."GXL Warehouse SKU" then begin
                    if not SKUHasStock(SKU) then begin
                        if IsQuitDateMet(QuitDate) then begin
                            SKU."GXL Product Status" := SKU."GXL Product Status"::Quit;
                            UpdateStoreSKU(SKU);
                        end else begin
                            SKU."GXL Quit Date" := xSKU."GXL Quit Date";
                            exit;
                        end;
                    end else begin
                        SKU."GXL Quit Date" := xSKU."GXL Quit Date";
                        exit;
                    end;
                end else begin
                    if SourceOfSupplySKUHasStock(SKU) then begin
                        SKU."GXL Quit Date" := xSKU."GXL Quit Date";
                        exit;
                    end;
                end;
            end else begin
                if SKU."GXL Quit Date" <= Today() then begin
                    SKU."GXL Product Status" := SKU."GXL Product Status"::Quit;
                end;
            end;
        end;

        if SKU."GXL Quit Date" <> xSKU."GXL Quit Date" then
            SKU.Validate("GXL Quit Date");

    end;

    local procedure SourceOfSupplySKUHasStock(var SKU: Record "Stockkeeping Unit"): Boolean
    var
        WarehouseSKU: Record "Stockkeeping Unit";
    begin
        if SKU."GXL Source of Supply Code" = '' then
            exit(false);

        WarehouseSKU.SetRange("Item No.", SKU."Item No.");
        WarehouseSKU.SetRange("Location Code", SKU."GXL Source of Supply Code");
        if WarehouseSKU.FindFirst() then
            exit(SKUHasStock(WarehouseSKU))
        else
            exit(false);
    end;

    //<Summary>
    //When a store is closed (close date is specified)
    //Update all SKUs Quit Date
    //</Summary>
    procedure UpdateStatusOnStoreClosedDate(OldClosedDate: Date; NewClosedDate: Date; LocationCode: Code[10])
    var
        SKU: Record "Stockkeeping Unit";
        SKU2: Record "Stockkeeping Unit";
    begin
        SKU.Reset();
        SKU.SetCurrentKey("GXL Product Status");
        SKU.SetFilter("GXL Product Status", '<>%1&<>%2', SKU."GXL Product Status"::Quit, SKU."GXL Product Status"::Inactive);
        SKU.SetRange("Location Code", LocationCode);
        if SKU.FindSet() then
            repeat
                SKU2 := SKU;
                if (SKU."GXL Quit Date" = 0D) or (OldClosedDate = SKU."GXL Quit Date") then begin
                    SKU2.Validate("GXL Quit Date", NewClosedDate);
                    SKU2.Modify(true);
                end else
                    if (SKU."GXL Quit Date" > NewClosedDate) then begin
                        SKU2.Validate("GXL Quit Date", NewClosedDate);
                        SKU2.Modify(true);
                    end;
            until SKU.Next() = 0;
    end;

    //<Summary>
    //Set flag to not running update SKUs product status on updating item product status
    //It is usually used if update SKUs product status are to be run after the process update item product status
    //</Summary>
    procedure SetSkipUpdateSKUs(_value: Boolean)
    begin
        SkipUpdateSKUs := _value;
    end;

    //CR036 +
    //<Summary>
    //Get the first receipt date of an item
    //If the item was received from NAV13 i.e. "GXL NAV First Receipt Date" is not empty then use this
    //Otherwise use the first receipt date from Item Ledger Entry
    //</Summary>
    procedure GetFirstReceiptDate_Item(var Item: Record Item): Date
    var
    begin
        if Item."GXL NAV First Receipt Date" <> 0D then
            exit(Item."GXL NAV First Receipt Date")
        else begin
            Item.CalcFields("GXL First Receipt Date");
            exit(Item."GXL First Receipt Date");
        end;
    end;

    //<Summary>
    //Get the first receipt date of a SKU
    //If the item was received from NAV13 i.e. "GXL NAV First Receipt Date" is not empty then use this
    //Otherwise use the first receipt date from Item Ledger Entry
    //</Summary>
    procedure GetFirstReceiptDate_SKU(var SKU: Record "Stockkeeping Unit"): Date
    var
    begin
        if SKU."GXL NAV First Receipt Date" <> 0D then
            exit(SKU."GXL NAV First Receipt Date")
        else begin
            SKU.CalcFields("GXL First Receipt Date");
            exit(SKU."GXL First Receipt Date");
        end;
    end;

    procedure OnValidateNAVFirstReceiptDate_Item(var Item: Record Item; var xItem: Record Item)
    var
        FirstRcptDate: Date;
    begin
        if Item."GXL NAV First Receipt Date" <> xItem."GXL NAV First Receipt Date" then begin
            case Item."GXL Product Status" of
                Item."GXL Product Status"::Approved,
                Item."GXL Product Status"::"New-Line",
                Item."GXL Product Status"::Active:
                    begin
                        FirstRcptDate := GetFirstReceiptDate_Item(Item);
                        if IsActiveProduct(FirstRcptDate) then
                            Item."GXL Product Status" := Item."GXL Product Status"::Active
                        else
                            if IsNewLineProduct(FirstRcptDate) then
                                Item."GXL Product Status" := Item."GXL Product Status"::"New-Line"
                            else
                                Item."GXL Product Status" := Item."GXL Product Status"::Approved;
                    end;
            end;
        end;
    end;

    procedure OnValidateNAVFirstReceiptDate_SKU(var SKU: Record "Stockkeeping Unit"; var xSKU: Record "Stockkeeping Unit")
    var
        FirstRcptDate: Date;
    begin
        if SKU."GXL NAV First Receipt Date" <> xSKU."GXL NAV First Receipt Date" then begin
            case SKU."GXL Product Status" of
                SKU."GXL Product Status"::Approved,
                SKU."GXL Product Status"::"New-Line",
                SKU."GXL Product Status"::Active:
                    begin
                        FirstRcptDate := GetFirstReceiptDate_SKU(SKU);
                        if IsActiveProduct(FirstRcptDate) then
                            SKU."GXL Product Status" := SKU."GXL Product Status"::Active
                        else
                            if IsNewLineProduct(FirstRcptDate) then
                                SKU."GXL Product Status" := SKU."GXL Product Status"::"New-Line"
                            else
                                SKU."GXL Product Status" := SKU."GXL Product Status"::Approved;
                    end;
            end;
        end;
    end;
    //CR036 -
}