codeunit 50151 "GXL ECS Subscribers"
{
    var
        ECSIntegrationType: Option " ","Store","Cluster","StoreCluster","ProductHierarchy","ItemContent","Promotion","SalesPrice","StockRanging";
        IntegrationOption: Enum "GXL ECS Integration Option";
        YouCannotRenameErr: Label 'You cannot rename %1';


    [EventSubscriber(ObjectType::Table, Database::"LSC Store", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModify_Store(var Rec: Record "LSC Store"; var xRec: Record "LSC Store"; RunTrigger: Boolean)
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::Store);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogStore_ChangedFields(Rec, xRec, 1);

    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Store Group", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsert_StoreGroup(var Rec: Record "LSC Store Group")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::Cluster);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogStoreGroup_ChangedFields(Rec, Rec, 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Store Group", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModify_StoreGroup(var Rec: Record "LSC Store Group"; var xRec: Record "LSC Store Group"; RunTrigger: Boolean)
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::Cluster);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogStoreGroup_ChangedFields(Rec, xRec, 1);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Store Group", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDelete_StoreGroup(var Rec: Record "LSC Store Group")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::Cluster);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogStoreGroup_ChangedFields(Rec, Rec, 2);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Store Group Setup", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsert_StoreGroupSetup(var Rec: Record "LSC Store Group Setup")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::StoreCluster);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogStoreGroupStores_ChangedFields(Rec, Rec, 0);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Store Group Setup", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDelete_StoreGroupSetup(var Rec: Record "LSC Store Group Setup")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::StoreCluster);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogStoreGroupStores_ChangedFields(Rec, Rec, 2);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Barcodes", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsert_Barcodes(var Rec: Record "LSC Barcodes")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogBarcodesProdHierarchy_ChangedFields(Rec, Rec, 0);

        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ItemContent);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogBarcodeItemContent_ChangedFields(Rec, Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Barcodes", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModify_Barcodes(var Rec: Record "LSC Barcodes"; var xRec: Record "LSC Barcodes"; RunTrigger: Boolean)
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        //ECS
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogBarcodesProdHierarchy_ChangedFields(Rec, xRec, 1);

        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ItemContent);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogBarcodeItemContent_ChangedFields(Rec, xRec);

    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Barcodes", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDelete_Barcodes(var Rec: Record "LSC Barcodes")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;

        //ECS    
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogBarcodesProdHierarchy_ChangedFields(Rec, Rec, 2);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsert_ItemUnitOfMeasure(var Rec: Record "Item Unit of Measure")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;

        //ECS    
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogItemUOMProdHierarchy_ChangedFields(Rec, Rec, 0);

        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::StockRanging);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogItemUOMStockRange_ChangedFields(Rec, Rec, 0);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDelete_ItemUnitOfMeasure(var Rec: Record "Item Unit of Measure")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogItemUOMProdHierarchy_ChangedFields(Rec, Rec, 2);
    end;


    [EventSubscriber(ObjectType::Table, Database::"Item", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsert_Item(var Rec: Record Item)
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;

        //ECS    
        if Rec."LSC Retail Product Code" <> '' then begin
            IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
            if IntegrationOption <> IntegrationOption::Disable then
                ECSWSFMgt.LogItemProdHierarchy_ChangedFields(Rec, Rec, 0);
        end;

        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ItemContent);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogItemContent_ChangedFields(Rec, Rec);

    end;

    [EventSubscriber(ObjectType::Table, Database::"Item", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModify_Item(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        //ECS
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogItemProdHierarchy_ChangedFields(Rec, xRec, 1);

        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ItemContent);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogItemContent_ChangedFields(Rec, xRec);

    end;


    [EventSubscriber(ObjectType::Table, Database::"Item", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDelete_Item(var Rec: Record Item)
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogItemProdHierarchy_ChangedFields(Rec, Rec, 2);

    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Retail Product Group", 'OnBeforeRenameEvent', '', true, true)]
    local procedure OnBeforeRename_RetailProductGroup(var Rec: Record "LSC Retail Product Group")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            Error(YouCannotRenameErr, Rec.TableCaption());
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Retail Product Group", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModify_RetailProductGroup(var Rec: Record "LSC Retail Product Group"; var xRec: Record "LSC Retail Product Group"; RunTrigger: Boolean)
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        if (Rec.Description <> xRec.Description) then begin
            IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
            if IntegrationOption <> IntegrationOption::Disable then
                ECSWSFMgt.LogRetailProdGroupProdHierarchy(Rec, xRec, 1);
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Retail Product Group", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDelete_RetailProductGroup(var Rec: Record "LSC Retail Product Group")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogRetailProdGroupProdHierarchy(Rec, Rec, 2);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnBeforeRenameEvent', '', true, true)]
    local procedure OnBeforeRename_ItemCategory(var Rec: Record "Item Category")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            Error(YouCannotRenameErr, Rec.TableCaption());
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModify_ItemCategory(var Rec: Record "Item Category"; var xRec: Record "Item Category"; RunTrigger: Boolean)
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogItemCategoryProdHierarchy(Rec, xRec, 1);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDelete_ItemCategory(var Rec: Record "Item Category")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogItemCategoryProdHierarchy(Rec, Rec, 2);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Division", 'OnBeforeRenameEvent', '', true, true)]
    local procedure OnBeforeRename_Division(var Rec: Record "LSC Division")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            Error(YouCannotRenameErr, Rec.TableCaption());
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Division", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModify_Division(var Rec: Record "LSC Division"; var xRec: Record "LSC Division"; RunTrigger: Boolean)
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogDivisionProdHierarchy(Rec, xRec, 1);
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Division", 'OnBeforeDeleteEvent', '', true, true)]
    local procedure OnBeforeDelete_Division(var Rec: Record "LSC Division")
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::ProductHierarchy);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogDivisionProdHierarchy(Rec, Rec, 2);
    end;
    // >> Upgrade
    // [EventSubscriber(ObjectType::Table, Database::"Sales Price", 'OnAfterInsertEvent', '', true, true)]
    // local procedure OnAfterInsert_SalesPrice(var Rec: Record "Sales Price")
    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsert_SalesPrice(var Rec: Record "Price List Line")
    // << Upgrade
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::SalesPrice);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogSalesPrice_ChangedFields(Rec, Rec, 0);
    end;
    // >> Upgrade
    // [EventSubscriber(ObjectType::Table, Database::"Sales Price", 'OnAfterModifyEvent', '', true, true)]
    // local procedure OnAfterModify_SalesPrice(var Rec: Record "Sales Price"; var xRec: Record "Sales Price"; RunTrigger: Boolean)
    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModify_SalesPrice(var Rec: Record "Price List Line"; var xRec: Record "Price List Line"; RunTrigger: Boolean)
    // << Upgrade
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        //ECS
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::SalesPrice);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogSalesPrice_ChangedFields(Rec, xRec, 1);

    end;

    // >> Upgrade
    //[EventSubscriber(ObjectType::Table, Database::"Sales Price", 'OnAfterDeleteEvent', '', true, true)]
    //local procedure OnAfterDelete_SalesPrice(var Rec: Record "Sales Price")
    [EventSubscriber(ObjectType::Table, Database::"Price List Line", 'OnAfterDeleteEvent', '', true, true)]
    local procedure OnAfterDelete_SalesPrice(var Rec: Record "Price List Line")
    // << Upgrade
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::SalesPrice);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogSalesPrice_ChangedFields(Rec, Rec, 2);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Stockkeeping Unit", 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModify_StockkeepingUnit(var Rec: Record "Stockkeeping Unit"; var xRec: Record "Stockkeeping Unit"; RunTrigger: Boolean)
    var
        ECSWSFMgt: Codeunit "GXL ECS WSF Management";
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;

        //ECS    
        IntegrationOption := ECSWSFMgt.GetECSIntegrationOption(ECSIntegrationType::StockRanging);
        if IntegrationOption <> IntegrationOption::Disable then
            ECSWSFMgt.LogSKUStockRange_ChangedFields(Rec, xRec, 1);
    end;


    local procedure RetrieveItem(Item: Record Item; var xItem: Record Item; var RecRetrieved: Boolean)
    begin
        if not RecRetrieved then begin
            xItem := Item;
            xItem.Find();
            RecRetrieved := true;
        end;
    end;

}