codeunit 50150 "GXL ECS WSF Management"
{
    trigger OnRun()
    begin

    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        DataTemplateHeader: Record "GXL ECS Data Template Header";
        DataTemplateLine: Record "GXL ECS Data Template Line";
        GlobalItem: Record Item;
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        DataTemplateMgt: Codeunit "GXL Data Template Management";
        UniqueID1ECSFieldName: Text[30];
        UniqueID1ECSFieldValue: Text[30];
        UniqueID2ECSFieldName: Text[30];
        UniqueID2ECSFieldValue: Text[30];
        InitialisationSet: Boolean;
        Level1Code: Code[10]; //Top Level (PET)
        Level2Code: Code[10]; //DEP (department)
        Level3Code: Code[10]; //CAT (category)
        Level4Code: Code[10]; //SCT (sub category)
        Level5Code: Code[10]; //ITM (item)
        Level6Code: Code[10]; //UOM (UOM)
        Level7Code: Code[10]; //BCD (barcode)
        Level1Value: Code[20];
        SetupRead: Boolean;
        ECSIntegrationType: Option " ","Store","Cluster","StoreCluster","ProductHierarchy","ItemContent","SalesPrice","StockRanging","Promotion";
        DeleteNotAllowedErr: Label 'Delete %1 is not permitted when there exists at least one item is linked to this %1 %2.';
        IntegrationIsDisabledErr: Label '%1 is %2';



    ///#region Setup
    local procedure GetSetups(): Boolean
    begin
        if not SetupRead then begin
            if IntegrationSetup.Get() then begin
                SetupRead := true;
                exit(true);
            end else
                exit(false);
        end else
            exit(true);
    end;

    procedure GetECSIntegrationOption(IntegrationType: Integer) IntegrationOption: Enum "GXL ECS Integration Option"
    begin
        IntegrationOption := IntegrationOption::Disable;
        if not GetSetups() then
            exit(IntegrationOption);

        ECSIntegrationType := IntegrationType;
        case ECSIntegrationType of
            ECSIntegrationType::Store:
                begin
                    IntegrationOption := IntegrationSetup."ECS Store Integration";
                end;

            ECSIntegrationType::Cluster:
                begin
                    IntegrationOption := IntegrationSetup."ECS Store Integration";
                end;

            ECSIntegrationType::StoreCluster:
                begin
                    IntegrationOption := IntegrationSetup."ECS Store Integration";
                end;

            ECSIntegrationType::ProductHierarchy:
                begin
                    IntegrationOption := IntegrationSetup."ECS Prod Hierarchy Integration";
                end;

            ECSIntegrationType::ItemContent:
                begin
                    IntegrationOption := IntegrationSetup."ECS Item Content Integration";
                end;

            ECSIntegrationType::SalesPrice:
                begin
                    IntegrationOption := IntegrationSetup."ECS Sales Price Integration";
                end;

            ECSIntegrationType::StockRanging:
                begin
                    IntegrationOption := IntegrationSetup."ECS Stock Ranging Integration";
                end;

            ECSIntegrationType::Promotion:
                begin
                    IntegrationOption := IntegrationSetup."ECS Promotion Integration";
                end;

        end;
        exit(IntegrationOption);
    end;


    ///#region Store
    procedure LogStore_ChangedFields(var StoreRec: Record "LSC Store"; var xStoreRec: Record "LSC Store"; UpdateType: Option "Insert","Modify","Delete")
    begin
        If StoreRec."GXL Location Type" <> StoreRec."GXL Location Type"::"6" then
            exit;

        GetSetups();
        if IntegrationSetup."ECS Store Data Template" = '' then
            exit;
        if not DataTemplateMgt.IsDataChanged(IntegrationSetup."ECS Store Data Template", StoreRec, xStoreRec, UpdateType) then
            exit;
        LogStoreUpdate(StoreRec);
    end;

    procedure LogStoreUpdate(var StoreRec: Record "LSC Store")
    var
        StoreData: Record "GXL ECS Store Data";
        Region: Record "GXL Region";
    begin
        StoreData.Init();
        StoreData."Entry No." := 0;
        StoreData.Entity := StoreData.Entity::Store;
        StoreData.Action := StoreData.Action::Upsert;
        StoreData."Store Code" := StoreRec."No.";
        if StoreRec."GXL Region Code" <> '' then begin
            Region.Get(StoreRec."GXL Region Code");
            StoreData."Store Region Name" := Region.Description;
        end else
            if StoreRec."GXL Region 2 Code" <> '' then begin
                Region.Get(StoreRec."GXL Region 2 Code");
                StoreData."Store Region Name" := Region.Description;
            end;
        StoreData.Insert(true);
    end;

    procedure LogStoreGroup_ChangedFields(var Rec: Record "LSC Store Group"; var xRec: Record "LSC Store Group"; UpdateType: Option "Insert","Modify","Delete")
    var
        StoreGroupSetup: Record "LSC Store Group Setup";
    begin
        GetSetups();
        if IntegrationSetup."ECS Cluster Data Template" = '' then
            exit;
        if not DataTemplateMgt.IsDataChanged(IntegrationSetup."ECS Cluster Data Template", Rec, xRec, UpdateType) then
            exit;
        LogStoreGroupUpdate(Rec, UpdateType);

        if Rec."GXL ECS UID" <> xRec."GXL ECS UID" then begin
            StoreGroupSetup.SetRange("Store Group", Rec.Code);
            if StoreGroupSetup.FindSet() then
                repeat
                    if xRec."GXL ECS UID" > 0 then
                        LogStoreGroupStoresUpdate(xRec, 2); //Delete old
                    if Rec."GXL ECS UID" > 0 then
                        LogStoreGroupStoresUpdate(Rec, 0); //Add new 
                until StoreGroupSetup.Next() = 0;
        end;
    end;

    procedure LogStoreGroupUpdate(var StoreGroup: Record "LSC Store Group"; UpdateType: Option "Insert","Modify","Delete")
    var
        StoreData: Record "GXL ECS Store Data";
    begin
        if StoreGroup."GXL ECS UID" <= 0 then
            exit;

        StoreData.Init();
        StoreData."Entry No." := 0;
        StoreData.Entity := StoreData.Entity::Cluster;
        case UpdateType of
            UpdateType::Insert,
            UpdateType::Modify:
                StoreData.Action := StoreData.Action::Upsert;
            UpdateType::Delete:
                StoreData.Action := StoreData.Action::Delete;
        end;
        StoreData."Store Group Code" := format(StoreGroup."GXL ECS UID");
        StoreData.Insert(true);
    end;


    procedure LogStoreGroupStores_ChangedFields(var Rec: Record "LSC Store Group Setup"; var xRec: Record "LSC Store Group Setup"; UpdateType: Option "Insert","Modify","Delete")
    begin
        GetSetups();
        if IntegrationSetup."ECS StoreCluster Data Template" = '' then
            exit;
        if not DataTemplateMgt.IsDataChanged(IntegrationSetup."ECS StoreCluster Data Template", Rec, xRec, UpdateType) then
            exit;
        LogStoreGroupStoresUpdate(Rec, UpdateType);
    end;
    // >> Upgrade
    //procedure LogStoreGroupStoresUpdate(var Rec: Record "Store Group Setup"; UpdateType: Option "Insert","Modify","Delete")
    procedure LogStoreGroupStoresUpdate(var Rec: Record "LSC Store Group Setup"; UpdateType: Option "Insert","Modify","Delete")
    // << Upgrade
    var
        StoreData: Record "GXL ECS Store Data";
    begin
        StoreData.Init();
        StoreData."Entry No." := 0;
        StoreData.Entity := StoreData.Entity::StoreCluster;
        case UpdateType of
            UpdateType::Insert:
                StoreData.Action := StoreData.Action::Upsert;
            UpdateType::Delete:
                StoreData.Action := StoreData.Action::Delete;
        end;
        StoreData."Store Code" := Rec."Store Code";
        Rec.CalcFields("GXL ECS UID");
        if Rec."GXL ECS UID" > 0 then
            StoreData."Store Group Code" := format(Rec."GXL ECS UID");
        StoreData.Insert(true);
    end;

    procedure LogStoreGroupStoresUpdate(var StoreGroup: Record "LSC Store Group"; UpdateType: Option "Insert","Modify","Delete")
    var
        StoreData: Record "GXL ECS Store Data";
    begin
        StoreData.Init();
        StoreData."Entry No." := 0;
        StoreData.Entity := StoreData.Entity::StoreCluster;
        case UpdateType of
            UpdateType::Insert:
                StoreData.Action := StoreData.Action::Upsert;
            UpdateType::Delete:
                StoreData.Action := StoreData.Action::Delete;
        end;
        StoreData."Store Code" := StoreGroup.Code;
        StoreData."Store Group Code" := format(StoreGroup."GXL ECS UID");
        StoreData.Insert(true);
    end;

    //#region "Product Hierarchy"
    local procedure InitialiseProdHierarchyLevels()
    begin
        if not InitialisationSet then begin
            Level1Code := 'PET';
            Level2Code := 'DEP';
            Level3Code := 'CAT';
            Level4Code := 'SCT';
            Level5Code := 'ITM';
            Level6Code := 'UOM';
            Level7Code := 'BCD';
            Level1Value := 'DC';
            InitialisationSet := true;
        end;
    end;

    local procedure GetBarcodeDescription(Barcodes: Record "LSC Barcodes") Desc: Text[250]
    begin
        if Barcodes.Description = '' then
            Desc := Barcodes."Barcode No."
        else
            Desc := Barcodes.Description;
    end;

    local procedure GetItemDescription(Item: Record Item) Desc: Text[250]
    begin
        if Item."GXL Signage 1" <> '' then
            Desc := Item."GXL Signage 1"
        else
            Desc := Item.Description;

        if Desc = '' then
            Desc := Item."No.";
    end;

    local procedure GetRetailProdGroupDescription(RetailProdGrp: Record "LSC Retail Product Group") Desc: Text[250]
    begin
        if RetailProdGrp.Description = '' then
            Desc := RetailProdGrp.Code
        else
            Desc := RetailProdGrp.Description;
    end;

    local procedure GetItemCategoryDescription(ItemCat: Record "Item Category") Desc: Text[250]
    begin
        if ItemCat.Description = '' then
            Desc := ItemCat.Code
        else
            Desc := ItemCat.Description;
    end;

    local procedure GetDivisionDescription(Division: Record "LSC Division") Desc: Text[250]
    begin
        if Division.Description = '' then
            Desc := Division.Code
        else
            Desc := Division.Description;
    end;

    local procedure LogProductHierarchyUpdate(RequestGUID: Guid; MessageType: Integer; ParentType: Code[10]; ParentVal: Code[20]; ChildType: Code[10]; ChildVal: Code[20]; ChildDesc: Text[250]; ItemNo: Code[20])
    var
        ProdHierarchyData: Record "GXL ECS Prod. Hierarchy Data";
    begin
        ProdHierarchyData.Init();
        ProdHierarchyData."Entry No." := 0;
        ProdHierarchyData."Request ID" := RequestGUID;
        ProdHierarchyData."Message Type" := MessageType;
        ProdHierarchyData."Hierarchy Parent Type" := ParentType;
        ProdHierarchyData."Hierarchy Parent Value Code" := ParentVal;
        ProdHierarchyData."Hierarchy Child Type" := ChildType;
        ProdHierarchyData."Hierarchy Child Value Code" := ChildVal;
        ProdHierarchyData."Hierarchy Child Description" := ChildDesc;
        ProdHierarchyData."Item No." := ItemNo;
        ProdHierarchyData.Insert(true);
    end;


    procedure LogBarcodesProdHierarchy_ChangedFields(var Barcodes: Record "LSC Barcodes"; var xBarcodes: Record "LSC Barcodes"; UpdateType: Option "Insert","Modify","Delete")
    var
        Item: Record Item;
        Desc: Text[250];
        RequestGUID: Guid;
    begin
        if Barcodes."Barcode No." = '' then
            exit;

        if Barcodes."Item No." <> '' then begin
            Item.Get(Barcodes."Item No.");
            if Item."LSC Retail Product Code" = '' then
                exit;
        end;

        Desc := GetBarcodeDescription(Barcodes);

        InitialiseProdHierarchyLevels();
        RequestGUID := CreateGuid();
        case UpdateType of
            UpdateType::Insert:
                begin
                    if (Barcodes."Item No." <> '') and (Barcodes."Unit of Measure Code" <> '') then
                        LogBarcodesProdHierarchyUpdate(RequestGUID, Barcodes, 5);
                end;

            UpdateType::Modify:
                begin
                    if (Barcodes."Item No." <> xBarcodes."Item No.") or
                        (Barcodes."Unit of Measure Code" <> xBarcodes."Unit of Measure Code") then begin
                        //remove old barcode structure
                        if (xBarcodes."Item No." <> '') and (xBarcodes."Unit of Measure Code" <> '') then
                            LogBarcodesProdHierarchyUpdate(RequestGUID, xBarcodes, 3);

                        //create new ones
                        if (Barcodes."Item No." <> '') and (Barcodes."Unit of Measure Code" <> '') then
                            LogBarcodesProdHierarchyUpdate(RequestGUID, Barcodes, 5);

                    end else
                        if Barcodes.Description <> Barcodes.Description then
                            LogBarcodesProdHierarchyUpdate(RequestGUID, Barcodes, 5);
                end;

            UpdateType::Delete:
                begin
                    if (Barcodes."Item No." <> '') and (Barcodes."Unit of Measure Code" <> '') then
                        LogBarcodesProdHierarchyUpdate(RequestGUID, Barcodes, 3);
                end;

        end;
    end;

    local procedure LogBarcodesProdHierarchyUpdate(RequestGUID: Guid; var Barcodes: Record "LSC Barcodes"; MessageType: Integer)
    var
        Desc: Text[250];
    begin
        if (Barcodes."Barcode No." <> '') and (Barcodes."Item No." <> '') and (Barcodes."Unit of Measure Code" <> '') then begin
            Desc := GetBarcodeDescription(Barcodes);
            LogProductHierarchyUpdate(
                RequestGUID, MessageType, Level6Code, Barcodes."Unit of Measure Code", Level7Code, Barcodes."Barcode No.", Desc, Barcodes."Item No."
            );
        end;
    end;

    local procedure LogBarcodesProdHierarchyUpdate(RequestGUID: Guid; ItemUOM: Record "Item Unit of Measure"; MessageType: Integer)
    var
        Barcodes: Record "LSC Barcodes";
    begin
        Barcodes.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code");
        Barcodes.SetRange("Item No.", ItemUOM."Item No.");
        Barcodes.SetRange("Unit of Measure Code", ItemUOM.Code);
        if Barcodes.FindSet(false, false) then
            repeat
                LogBarcodesProdHierarchyUpdate(RequestGUID, Barcodes, MessageType);
            until Barcodes.Next() = 0;
    end;

    local procedure LogBarcodesProdHierarchyUpdate(RequestGUID: Guid; var Item: Record Item; MessageType: Integer)
    var
        Barcodes: Record "LSC Barcodes";
    begin
        Barcodes.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code");
        Barcodes.SetRange("Item No.", Item."No.");
        if Barcodes.FindSet(false, false) then
            repeat
                LogBarcodesProdHierarchyUpdate(RequestGUID, Barcodes, MessageType);
            until Barcodes.Next() = 0;
    end;

    procedure LogItemUOMProdHierarchy_ChangedFields(var ItemUOM: Record "Item Unit of Measure"; var xItemUOM: Record "Item Unit of Measure"; UpdateType: Option "Insert","Modify","Delete")
    var
        Item: Record Item;
        Desc: Text[250];
        RequestGUID: Guid;
    begin
        Item.Get(ItemUOM."Item No.");
        if Item."LSC Retail Product Code" = '' then
            exit;

        Desc := GetItemDescription(Item);

        InitialiseProdHierarchyLevels();
        RequestGUID := CreateGuid();
        case UpdateType of
            UpdateType::Insert:
                begin
                    LogItemUOMProdHierarchyUpdate(RequestGUID, ItemUOM, Desc, 5);
                end;

            UpdateType::Delete:
                begin
                    //Barcode
                    LogBarcodesProdHierarchyUpdate(RequestGUID, ItemUOM, 3);

                    LogItemUOMProdHierarchyUpdate(RequestGUID, ItemUOM, Desc, 3);
                end;
        end;
    end;

    local procedure LogItemUOMProdHierarchyUpdate(RequestGUID: Guid; var ItemUOM: Record "Item Unit of Measure"; Desc: Text[250]; MessageType: Integer)
    begin
        LogProductHierarchyUpdate(
            RequestGUID, MessageType, Level5Code, ItemUOM."Item No.", Level6Code, ItemUOM.Code, Desc, ''
        );
    end;

    local procedure LogItemUOMProdHierarchyUpdate(RequestGUID: Guid; var Item: Record Item; MessageType: Integer)
    var
        ItemUOM: Record "Item Unit of Measure";
        Desc: Text[250];
    begin

        Desc := GetItemDescription(Item);

        ItemUOM.SetRange("Item No.", Item."No.");
        if ItemUOM.FindSet(false, false) then
            repeat
                LogItemUOMProdHierarchyUpdate(RequestGUID, ItemUOM, Desc, MessageType);
            until ItemUOM.Next() = 0;

    end;

    procedure LogItemProdHierarchy_ChangedFields(var Item: Record Item; var xItem: Record Item; UpdateType: Option "Insert","Modify","Delete")
    var
        RequestGUID: Guid;
        Desc: Text[250];
        xDesc: Text[250];
    begin

        InitialiseProdHierarchyLevels();
        RequestGUID := CreateGuid();
        case UpdateType of
            UpdateType::Insert:
                begin
                    if Item."LSC Retail Product Code" <> '' then
                        BuildCompleteProductHierarchyStructure(RequestGUID, Item);
                end;
            UpdateType::Modify:
                begin
                    //Sub category
                    if (Item."LSC Retail Product Code" <> xItem."LSC Retail Product Code") then begin
                        //Remove old sub-cat from the hierarchy
                        if xItem."LSC Retail Product Code" <> '' then
                            LogItemProdHierarchyUpdate(RequestGUID, xItem, 3);

                        //Insert the full hierarchy structure for the product
                        if Item."LSC Retail Product Code" <> '' then
                            BuildCompleteProductHierarchyStructure(RequestGUID, Item);

                    end else begin
                        if (Item."LSC Retail Product Code" <> '') then begin
                            xDesc := GetItemDescription(xItem);
                            Desc := GetItemDescription(Item);
                            if (Desc <> xDesc) then begin
                                //Item
                                LogItemProdHierarchyUpdate(RequestGUID, Item, 5);

                                //UOM
                                LogItemUOMProdHierarchyUpdate(RequestGUID, Item, 5);
                            end;
                        end;
                    end;
                end;

            UpdateType::Delete:
                begin
                    if Item."LSC Retail Product Code" <> '' then begin
                        //Barcode
                        LogBarcodesProdHierarchyUpdate(RequestGUID, Item, 3);

                        //UOM
                        LogItemUOMProdHierarchyUpdate(RequestGUID, Item, 3);

                        //Item
                        LogItemProdHierarchyUpdate(RequestGUID, Item, 3);
                    end;
                end;
        end;

    end;

    procedure BuildCompleteProductHierarchyStructure(RequestGUID: Guid; var Item: Record Item)
    var
        Division: Record "LSC Division";
        ItemCat: Record "Item Category";
        RetailProdGrp: Record "LSC Retail Product Group";
    begin
        if (Item."LSC Division Code" = '') or (Item."Item Category Code" = '') or (Item."LSC Retail Product Code" = '') then
            exit;
        if not Division.Get(Item."LSC Division Code") then
            exit;
        if not ItemCat.Get(Item."Item Category Code") then
            exit;
        if not RetailProdGrp.Get(Item."Item Category Code", Item."LSC Retail Product Code") then
            exit;

        InitialiseProdHierarchyLevels();

        //Department
        LogDivisionProdHierarchyUpdate(RequestGUID, Division, 5);

        //Cat
        LogItemCategoryProdHierarchyUpdate(RequestGUID, ItemCat, Item, 5);

        //Sub-Cat
        LogRetailProdGroupProdHierarchyUpdate(RequestGUID, RetailProdGrp, 5);

        //Item
        LogItemProdHierarchyUpdate(RequestGUID, Item, 5);

        //UOM
        LogItemUOMProdHierarchyUpdate(RequestGUID, Item, 5);

        //Barcode
        LogBarcodesProdHierarchyUpdate(RequestGUID, Item, 5);

    end;

    local procedure LogItemProdHierarchyUpdate(RequestGUID: Guid; var Item: Record Item; MessageType: Integer)
    var
        Desc: Text[250];
    begin
        if Item."LSC Retail Product Code" <> '' then begin
            Desc := GetItemDescription(Item);
            LogProductHierarchyUpdate(
                RequestGUID, MessageType, Level4Code, Item."LSC Retail Product Code", Level5Code, Item."No.", Desc, ''
            );
        end;
    end;

    procedure LogRetailProdGroupProdHierarchy(var RetailProdGrp: Record "LSC Retail Product Group"; var xRetailProdGrp: Record "LSC Retail Product Group"; UpdateType: Option "Insert","Modify","Delete")
    var
        RequestGUID: Guid;
    begin
        if (RetailProdGrp."Item Category Code" = '') or (RetailProdGrp.Code = '') then
            exit;

        InitialiseProdHierarchyLevels();
        RequestGUID := CreateGuid();
        case UpdateType of
            UpdateType::Modify:
                begin
                    if RetailProdGrp.Description <> xRetailProdGrp.Description then
                        if RetailProductGroupExistsOnItem(RetailProdGrp) then
                            LogRetailProdGroupProdHierarchyUpdate(RequestGUID, RetailProdGrp, 5);
                end;

            UpdateType::Delete:
                begin
                    if RetailProductGroupExistsOnItem(RetailProdGrp) then
                        Error(DeleteNotAllowedErr, RetailProdGrp.TableCaption(), RetailProdGrp.Code)
                end;
        end;
    end;

    local procedure LogRetailProdGroupProdHierarchyUpdate(RequestGUID: Guid; var RetailProdGrp: Record "LSC Retail Product Group"; MessageType: Integer)
    var
        Desc: Text[250];
    begin
        if (RetailProdGrp."Item Category Code" = '') or (RetailProdGrp.Code = '') then
            exit;

        Desc := GetRetailProdGroupDescription(RetailProdGrp);
        LogProductHierarchyUpdate(
            RequestGUID, MessageType, Level3Code, RetailProdGrp."Item Category Code", Level4Code, RetailProdGrp.Code, Desc, ''
        );

    end;

    procedure LogItemCategoryProdHierarchy(var ItemCat: Record "Item Category"; var xItemCat: Record "Item Category"; UpdateType: Option "Insert","Modify","Delete")
    var
        Item: Record Item;
        TempItem: Record Item temporary;
        RequestGUID: Guid;
    begin
        if ItemCat.Code = '' then
            exit;

        InitialiseProdHierarchyLevels();
        RequestGUID := CreateGuid();
        //Level 3 - Item cat is based on Level 2 - Division, can only log update basing on values on Item
        case UpdateType of
            UpdateType::Modify:
                begin
                    if ItemCat.Description <> xItemCat.Description then begin
                        Item.SetRange("Item Category Code", ItemCat.Code);
                        if Item.FindSet(false, false) then
                            repeat
                                TempItem.SetRange("LSC Division Code", Item."LSC Division Code");
                                if not TempItem.FindFirst() then begin
                                    TempItem := Item;
                                    TempItem.Insert();
                                end;
                            until Item.Next() = 0;

                        TempItem.Reset();
                        if TempItem.FindSet() then
                            repeat
                                LogItemCategoryProdHierarchyUpdate(RequestGUID, ItemCat, TempItem, 5);
                            until TempItem.Next() = 0;
                        TempItem.DeleteAll();
                    end;
                end;

            UpdateType::Delete:
                begin
                    if ItemCatExistsOnItem(ItemCat) then
                        Error(DeleteNotAllowedErr, ItemCat.TableCaption(), ItemCat.Code);

                end;
        end;
    end;

    local procedure LogItemCategoryProdHierarchyUpdate(RequestGUID: Guid; var ItemCat: Record "Item Category"; Item: Record Item; MessageType: Integer)
    var
        Desc: Text[250];
    begin
        if (Item."LSC Division Code" = '') or (Item."Item Category Code" = '') then
            exit;

        Desc := GetItemCategoryDescription(ItemCat);
        LogProductHierarchyUpdate(
            RequestGUID, MessageType, Level2Code, Item."LSC Division Code", Level3Code, ItemCat.Code, Desc, ''
        );

    end;

    procedure LogDivisionProdHierarchy(var Division: Record "LSC Division"; xDivision: Record "LSC Division"; UpdateType: Option "Insert","Modify","Delete")
    var
        RequestGUID: Guid;
    begin
        if Division.Code = '' then
            exit;

        InitialiseProdHierarchyLevels();
        RequestGUID := CreateGuid();
        case UpdateType of
            UpdateType::Modify:
                begin
                    if Division.Description <> xDivision.Description then
                        if DivisionExistsOnItem(Division) then
                            LogDivisionProdHierarchyUpdate(RequestGUID, Division, 5);
                end;

            UpdateType::Delete:
                begin
                    if DivisionExistsOnItem(Division) then
                        Error(DeleteNotAllowedErr, Division.Code, Division.TableCaption());
                end;
        end;
    end;

    local procedure LogDivisionProdHierarchyUpdate(RequestGUID: Guid; var Division: Record "LSC Division"; MessagetType: Integer)
    var
        Desc: Text[250];
    begin
        if Division.Code = '' then
            exit;

        Desc := GetDivisionDescription(Division);
        LogProductHierarchyUpdate(
            RequestGUID, MessagetType, Level1Code, Level1Value, Level2Code, Division.Code, Desc, ''
        );

    end;

    procedure RetailProductGroupExistsOnItem(RetailProdGrp: Record "LSC Retail Product Group"): Boolean
    var
        Item: Record Item;
    begin
        Item.SetCurrentKey("LSC Retail Product Code");
        Item.SetRange("LSC Retail Product Code", RetailProdGrp.Code);
        Item.SetRange("Item Category Code", RetailProdGrp."Item Category Code");
        exit(not Item.IsEmpty());
    end;

    procedure ItemCatExistsOnItem(ItemCat: Record "Item Category"): Boolean
    var
        Item: Record Item;
    begin
        Item.SetRange("Item Category Code", ItemCat.Code);
        exit(not Item.IsEmpty());
    end;

    procedure DivisionExistsOnItem(Division: Record "LSC Division"): Boolean
    var
        Item: Record Item;
    begin
        Item.SetCurrentKey("LSC Division Code");
        Item.SetRange("LSC Division Code", Division.Code);
        exit(not Item.IsEmpty());
    end;

    //#region Item Content
    procedure LogItemContent_ChangedFields(var Item: Record Item; var xItem: Record Item)
    var
        FoundEditedField: Boolean;
    begin
        FoundEditedField := LogItemContentUpdate(Item, xItem);

        //Print ticket
        if FoundEditedField then
            LogItemDataPrintTicket(false);

    end;

    procedure LogBarcodeItemContent_ChangedFields(var Barcodes: Record "LSC Barcodes"; xBarcodes: Record "LSC Barcodes")
    begin
        LogItemContentUpdate(Barcodes, xBarcodes);
    end;

    procedure LogItemContentUpdate(Rec: Variant; xRec: Variant) FoundEditedField: Boolean
    var
        Item: Record Item;
        Barcodes: Record "LSC Barcodes";
        ItemUOM: Record "Item Unit of Measure";
        RecRef: RecordRef;
        xRecRef: RecordRef;
        FldRef: FieldRef;
        xFldRef: FieldRef;
    begin
        FoundEditedField := false;
        GetSetups();
        if IntegrationSetup."ECS Item Content Data Template" = '' then
            exit;

        DataTemplateHeader.SetRange(Code, IntegrationSetup."ECS Item Content Data Template");
        if not DataTemplateHeader.FindFirst() then
            exit;

        RecRef.GetTable(Rec);
        xRecRef.GetTable(xRec);

        Clear(UniqueID1ECSFieldName);
        Clear(UniqueID1ECSFieldValue);
        Clear(UniqueID2ECSFieldName);
        Clear(UniqueID2ECSFieldValue);

        DataTemplateLine.Reset();
        DataTemplateLine.SetRange("ECS Data Template Code", DataTemplateHeader.Code);
        DataTemplateLine.SetRange("Table ID", DataTemplateHeader."Table ID");
        DataTemplateLine.SetRange("Mandatory Unique ID", true);
        if DataTemplateLine.FindFirst() then begin
            FldRef := RecRef.Field(DataTemplateLine."Field No.");

            UniqueID1ECSFieldName := FldRef.Name();
            UniqueID1ECSFieldValue := FldRef.Value();

            if UniqueID1ECSFieldValue = '' then
                exit;
        end;

        //UOM
        DataTemplateLine.SetRange("Table ID", Database::"Item Unit of Measure");
        DataTemplateLine.SetRange("Field No.", 2); //field "Code"
        if not DataTemplateLine.FindFirst() then
            exit;
        UniqueID2ECSFieldName := ItemUOM.FieldName(Code);

        DataTemplateLine.Reset();
        DataTemplateLine.SetRange("ECS Data Template Code", DataTemplateHeader.Code);
        DataTemplateLine.SetRange("Table ID", RecRef.Number());
        DataTemplateLine.SetRange("Send to ECS", true);
        if not DataTemplateLine.FindSet() then
            exit;

        case RecRef.Number() of
            Database::"Item":
                begin
                    Item := Rec;
                    ItemUOM.SetRange("Item No.", Item."No.");
                end;
            Database::"LSC Barcodes":
                begin
                    Barcodes := Rec;
                    ItemUOM.SetRange("Item No.", Barcodes."Item No.");
                    ItemUOM.SetRange(Code, Barcodes."Unit of Measure Code");
                end;
            else
                exit;
        end;

        if ItemUOM.FindSet() then
            repeat
                DataTemplateLine.FindSet();
                repeat
                    UniqueID2ECSFieldValue := ItemUOM.Code;

                    FldRef := RecRef.Field(DataTemplateLine."Field No.");
                    xFldRef := xRecRef.Field(DataTemplateLine."Field No.");

                    if FldRef.Value() <> xFldRef.Value() then begin
                        FoundEditedField := true;
                        LogItemDataUpdate(Rec, RecRef, FldRef);
                    end;

                until DataTemplateLine.Next() = 0;
            until ItemUOM.Next() = 0;


        //changed made through config package (Rec=xRec), log all fields
        if not FoundEditedField then begin
            if ItemUOM.FindSet() then
                repeat
                    DataTemplateLine.FindSet();
                    repeat
                        UniqueID2ECSFieldValue := ItemUOM.Code;

                        FldRef := RecRef.Field(DataTemplateLine."Field No.");
                        LogItemDataUpdate(Rec, RecRef, FldRef);
                    until DataTemplateLine.Next() = 0;
                until ItemUOM.Next() = 0;

        end;
    end;

    local procedure LogItemDataUpdate(Rec: Variant; RecRef: RecordRef; FldRef: FieldRef)
    var
        ItemData: Record "GXL ECS Item Data";
        Barcodes: Record "LSC Barcodes";
    begin

        ItemData.Init();
        ItemData."Entry No." := 0;
        ItemData."ECS Data Template Code" := DataTemplateHeader.Code;
        ItemData."ECS WS Function" := DataTemplateHeader."ECS WS Function";
        ItemData."Source Table ID" := DataTemplateLine."Table ID";
        ItemData."Source Field No." := DataTemplateLine."Field No.";
        ItemData."ECS Field Name" := DataTemplateLine."ECS Field Name";
        if (RecRef.Number() = Database::"LSC Barcodes") and (FldRef.Number() = 1) then begin
            Barcodes := Rec;
            if Barcodes."Show for Item" then
                ItemData."Field Value" := FldRef.Value()
            else
                ItemData."Field Value" := '0000000000';
        end else
            ItemData."Field Value" := FldRef.Value();
        ItemData."Unique ID 1 ECS Field Name" := UniqueID1ECSFieldName;
        ItemData."Unique ID 1 ECS Field Value" := UniqueID1ECSFieldValue;
        ItemData."Unique ID 2 ECS Field Name" := UniqueID2ECSFieldName;
        ItemData."Unique ID 2 ECS Field Value" := UniqueID2ECSFieldValue;
        ItemData."Print Ticket" := false;
        ItemData.Insert(true);

    end;

    procedure LogItemContent_PrintTicket(var Item: Record Item)
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        if not Item.FindSet() then
            exit;

        GetSetups();
        if IntegrationSetup."ECS Item Content Data Template" = '' then
            exit;
        DataTemplateHeader.SetRange(Code, IntegrationSetup."ECS Item Content Data Template");
        if not DataTemplateHeader.FindFirst() then
            exit;

        UniqueID1ECSFieldName := Item.FieldName("No.");
        UniqueID2ECSFieldName := ItemUOM.FieldName(Code);
        repeat
            UniqueID1ECSFieldValue := Item."No.";

            ItemUOM.SetRange("Item No.", Item."No.");
            if ItemUOM.FindSet() then
                repeat
                    UniqueID2ECSFieldValue := ItemUOM.Code;
                    LogItemDataPrintTicket(true);
                until ItemUOM.Next() = 0;
        until Item.Next() = 0;

    end;

    local procedure LogItemDataPrintTicket(PrintTicket: Boolean)
    var
        ItemData: Record "GXL ECS Item Data";
    begin
        ItemData.Init();
        ItemData."Entry No." := 0;
        ItemData."ECS Data Template Code" := DataTemplateHeader.Code;
        ItemData."ECS WS Function" := DataTemplateHeader."ECS WS Function";
        ItemData."Source Table ID" := DataTemplateHeader."Table ID";
        ItemData."ECS Field Name" := 'PRINT_TICKET';
        if PrintTicket then
            ItemData."Field Value" := '1'
        else
            ItemData."Field Value" := '0';
        ItemData."Unique ID 1 ECS Field Name" := UniqueID1ECSFieldName;
        ItemData."Unique ID 1 ECS Field Value" := UniqueID1ECSFieldValue;
        ItemData."Unique ID 2 ECS Field Name" := UniqueID2ECSFieldName;
        ItemData."Unique ID 2 ECS Field Value" := UniqueID2ECSFieldValue;
        ItemData."Print Ticket" := PrintTicket;
        ItemData.Insert(true);
    end;


    ///#region SalesPrice
    //procedure LogSalesPrice_ChangedFields(var Rec: Record "Sales Price"; var xRec: Record "Sales Price"; UpdateType: Option "Insert","Modify","Delete")
    procedure LogSalesPrice_ChangedFields(var Rec: Record "Price List Line"; var xRec: Record "Price List Line"; UpdateType: Option "Insert","Modify","Delete")
    begin
        GetSetups();
        if IntegrationSetup."ECS Sales Price Data Template" = '' then
            exit;
        if not DataTemplateMgt.IsDataChanged(IntegrationSetup."ECS Sales Price Data Template", Rec, xRec, UpdateType) then
            exit;
        LogSalesPriceDataUpdate(Rec);
    end;

    //procedure LogSalesPriceDataUpdate(SalesPrice: Record "Sales Price")
    procedure LogSalesPriceDataUpdate(SalesPrice: Record "Price List Line")
    var
    begin
        // >> Upgrade
        // if GlobalItem."No." <> SalesPrice."Item No." then begin
        //     if not GlobalItem.Get(SalesPrice."Item No.") then
        if GlobalItem."No." <> SalesPrice."Asset No." then begin
            if not GlobalItem.Get(SalesPrice."Asset No.") then
                // << Upgrade
                exit;
            if GlobalItem.Blocked then
                exit;
        end;

        LogSalesPriceDataUpdate(SalesPrice, GlobalItem);

    end;

    //procedure LogSalesPriceDataUpdate(SalesPrice: Record "Sales Price"; Item: Record Item)
    procedure LogSalesPriceDataUpdate(SalesPrice: Record "Price List Line"; Item: Record Item)
    var
        SalesPriceData: Record "GXL ECS Sales Price Data";
        PriceEndDate: Date;
        ActivePriceRRP: Decimal;
        OfferType: Code[10];
        PriceType: Code[10];
        AllCode: Code[20];
    begin

        OfferType := '501';
        AllCode := 'ALL';
        // >> Upgrade
        // if (SalesPrice."Sales Type" = SalesPrice."Sales Type"::"All Customers") or
        //     ((SalesPrice."Sales Type" = SalesPrice."Sales Type"::"Customer Price Group") and (SalesPrice."Sales Code" = AllCode)) then
        if (SalesPrice."Source Type" = SalesPrice."Source Type"::"All Customers") or
      ((SalesPrice."Source Type" = SalesPrice."Source Type"::"Customer Price Group") and (SalesPrice."Source No." = AllCode)) then
            // << Upgrade
            PriceType := '20' //National
        else
            PriceType := '40'; //Store

        if SalesPrice."Ending Date" = 0D then
            PriceEndDate := 99991212D
        else
            PriceEndDate := SalesPrice."Ending Date";
        // >> Upgrade
        // if SalesPrice."Unit Price Including VAT" <> 0 then
        //     ActivePriceRRP := SalesPrice."Unit Price Including VAT"
        // else
        // << Upgrade
        ActivePriceRRP := SalesPrice."Unit Price";

        SalesPriceData.Init();
        SalesPriceData."Entry No." := 0;
        if PriceType = '20' then
            SalesPriceData."Location Code" := ''
        else
            // >> Upgrade
            //     SalesPriceData."Location Code" := SalesPrice."Sales Code";
            // SalesPriceData."Item No." := SalesPrice."Item No.";
            SalesPriceData."Location Code" := SalesPrice."Source No.";
        SalesPriceData."Item No." := SalesPrice."Asset No.";
        // << pgrade
        SalesPriceData.UOM := SalesPrice."Unit of Measure Code";
        SalesPriceData.Description := Item.Description;
        SalesPriceData."Offer Type" := OfferType;
        SalesPriceData."Price Type" := PriceType;
        SalesPriceData."Price Start Date" := SalesPrice."Starting Date";
        SalesPriceData."Price End Date" := PriceEndDate;
        if SalesPrice."Minimum Quantity" = 0 then
            SalesPriceData."Ticket Quantity" := 1
        else
            SalesPriceData."Ticket Quantity" := SalesPrice."Minimum Quantity";
        SalesPriceData."Active RRP" := ActivePriceRRP;
        SalesPriceData.Insert(true);
    end;

    ///#region Promotion
    procedure LogPromotionUpdate()
    var
        PromoData: Record "GXL ECS Promotion Data";
        PromoHeader: Record "GXL ECS Promotion Header";
        PromoLines: Record "GXL ECS Promotion Line";
    begin

        GetSetups();
        if IntegrationSetup."ECS Promotion Integration" = IntegrationSetup."ECS Promotion Integration"::Disable then
            Error(IntegrationIsDisabledErr, IntegrationSetup.FieldCaption("ECS Promotion Integration"), IntegrationSetup."ECS Promotion Integration");

        PromoLines.SetCurrentKey("ECS Event ID");

        PromoHeader.SetCurrentKey("Event Status", "Start Date", "Event Code");
        PromoHeader.SetRange("Event Status", PromoHeader."Event Status"::Planning);
        if PromoHeader.FindSet() then begin
            repeat
                PromoLines.SetRange("ECS Event ID", PromoHeader."ECS Event ID");
                if PromoLines.FindSet() then
                    repeat
                        PromoData.Init();
                        PromoData."Entry No." := 0;
                        PromoData."ECS Event ID" := PromoLines."ECS Event ID";
                        PromoData."Event Code" := PromoHeader."Event Code";
                        PromoData."Promotion Type" := PromoHeader."Promotion Type";
                        PromoData."Location Hierarchy Type" := PromoHeader."Location Hierarchy Type";
                        PromoData."Location Hierarchy Code" := PromoHeader."Location Hierarchy Code";
                        PromoData."Item No." := PromoLines."Item No.";
                        PromoData."Unit Of Measure Code" := PromoLines."Unit Of Measure Code";
                        PromoData."Discount Value 1" := PromoLines."Discount Value 1";
                        PromoData."Discount Value 2" := PromoLines."Discount Value 2";
                        PromoData."Discount Quantity" := PromoLines."Discount Quantity";
                        PromoData."Deal Text 1" := PromoLines."Deal Text 1";
                        PromoData."Deal Text 2" := PromoLines."Deal Text 2";
                        PromoData."Deal Text 3" := PromoLines."Deal Text 3";
                        PromoData."Default Size" := PromoLines."Default Size";
                        PromoData."Start Date" := PromoHeader."Start Date";
                        PromoData."End Date" := PromoHeader."End Date";
                        PromoData.Insert(true);

                    until PromoLines.Next() = 0;
            until PromoHeader.Next() = 0;

            PromoHeader.ModifyAll("Event Status", PromoHeader."Event Status"::Active);
        end;
    end;

    ///#region Stock Range
    procedure LogSKUStockRange_ChangedFields(var Rec: Record "Stockkeeping Unit"; var xRec: Record "Stockkeeping Unit"; UpdateType: Option "Insert","Modify","Delete")
    begin
        GetSetups();
        if IntegrationSetup."ECS Stock Range Data Template" = '' then
            exit;
        if not DataTemplateMgt.IsDataChanged(IntegrationSetup."ECS Stock Range Data Template", Rec, xRec, UpdateType) then
            exit;
        LogStockRangeUpdate(Rec);
    end;

    procedure LogItemUOMStockRange_ChangedFields(var Rec: Record "Item Unit of Measure"; var xRec: Record "Item Unit of Measure"; UpdateType: Option "Insert","Modify","Delete")
    begin
        GetSetups();
        if IntegrationSetup."ECS Stock Range Data Template" = '' then
            exit;
        if not DataTemplateMgt.IsDataChanged(IntegrationSetup."ECS Stock Range Data Template", Rec, xRec, UpdateType) then
            exit;
        LogStockRangeUpdate(Rec);
    end;

    procedure LogStockRangeUpdate(var SKURec: Record "Stockkeeping Unit")
    var
        ItemUOM: Record "Item Unit of Measure";
    begin
        ItemUOM.SetRange("Item No.", SKURec."Item No.");
        if ItemUOM.FindSet() then
            repeat
                LogStockRangeUpdate(SKURec, ItemUOM);
            until ItemUOM.Next() = 0;
    end;

    procedure LogStockRangeUpdate(var ItemUOM: Record "Item Unit of Measure")
    var
        SKURec: Record "Stockkeeping Unit";
    begin
        SKURec.SetRange("Item No.", ItemUOM."Item No.");
        if SKURec.FindSet() then
            repeat
                LogStockRangeUpdate(SKURec, ItemUOM);
            until SKURec.Next() = 0;
    end;

    procedure LogStockRangeUpdate(SKURec: Record "Stockkeeping Unit"; ItemUOM: Record "Item Unit of Measure")
    var
        StockRangeData: Record "GXL ECS Stock Range Data";
        Ranged: Text[1];
        RangeStartDate: Date;
        RangeEndDate: Date;
        SOHQty: Decimal;
    begin

        SOHQty := SKURec."GXL Total SOH";
        if SOHQty > 0 then
            Ranged := 'Y'
        else
            Ranged := 'N';

        // Calculate Range End Date
        if Ranged = 'Y' then
            RangeEndDate := 99991212D // End of time
        else
            if SKURec."GXL Quit Date" = 0D then
                RangeEndDate := 99991212D  // End of time
            else
                if SKURec."GXL Quit Date" > Today() then
                    RangeEndDate := SKURec."GXL Quit Date"
                else
                    RangeEndDate := CalcDate('<1D>', Today());  // Tomorrow

        // Calculate Range Start Date
        if SKURec."GXL Effective Date" = 0D then
            RangeStartDate := 19700101D   // Default date in ECS when no date is specified
        else
            if SKURec."GXL Effective Date" > Today() then
                RangeStartDate := SKURec."GXL Effective Date"
            else
                RangeStartDate := CalcDate('<1D>', Today());  // Tomorrow

        if RangeStartDate > RangeEndDate then
            RangeStartDate := RangeEndDate;

        SOHQty := LegacyItemHelpers.CalculateLegacyItemQty(ItemUOM, SOHQty);

        StockRangeData.Init();
        StockRangeData."Entry No." := 0;
        StockRangeData."Location Code" := SKURec."Location Code";
        StockRangeData."Item No." := SKURec."Item No.";
        StockRangeData.UOM := ItemUOM.Code;
        StockRangeData."Stock on Hand" := SOHQty;
        StockRangeData.Ranged := Ranged;
        StockRangeData."Range Start Date" := RangeStartDate;
        StockRangeData."Range End Date" := RangeEndDate;
        StockRangeData.Insert(true);

    end;

}