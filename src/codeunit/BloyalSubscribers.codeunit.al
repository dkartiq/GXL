codeunit 50176 "GXL Bloyal Subscribers"
{

    [EventSubscriber(ObjectType::Table, Database::"Item", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsert_Item(var Rec: Record Item)
    var
        BloyalDataMgt: Codeunit "GXL Bloyal Data Management";
    begin
        //WRP-397+
        if Rec.IsTemporary() then
            exit;
        //WRP-397-

        Rec."GXL Bloyal Date Time Modified" := CurrentDateTime();
        //WRP-397+
        if BloyalDataMgt.IsBloyalProductIntegrationEnabled() then
            BloyalDataMgt.InsertToBloyalProductChangeLog(Rec."No.");
        //WRP-397-
    end;

    [EventSubscriber(ObjectType::Table, Database::Item, 'OnBeforeModifyEvent', '', true, true)]
    local procedure OnBeforeModify_Item(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    var
        xItem: Record Item;
        BloyalDataMgt: Codeunit "GXL Bloyal Data Management";
        IsModified: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;
        //WRP-397+
        if not RunTrigger then
            exit;
        //WRP-397-

        if BloyalDataMgt.IsBloyalProductIntegrationEnabled() then begin
            xItem.Get(Rec."No.");
            //WRP-397+
            //if BloyalDataMgt.Item_FieldsChanged(Rec, xItem, 1) then
            //    Rec."GXL Bloyal Date Time Modified" := CurrentDateTime();
            if (Rec.GTIN <> xItem.GTIN) then
                IsModified := true;
            if not IsModified then begin
                if BloyalDataMgt.Item_FieldsChanged(Rec, xItem, 1) then
                    IsModified := true;
            end;
            if IsModified then begin
                Rec."GXL Bloyal Date Time Modified" := CurrentDateTime();
                BloyalDataMgt.InsertToBloyalProductChangeLog(Rec."No.");
            end;
            //WRP-397-
        end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsert_ItemUnitOfMeasure(var Rec: Record "Item Unit of Measure")
    var
        //Item: Record Item;
        BloyalDataMgt: Codeunit "GXL Bloyal Data Management";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."GXL Legacy Item No." <> '' then
            if BloyalDataMgt.IsBloyalProductIntegrationEnabled() then begin
                //WRP-397+                
                //Item.Get(Rec."Item No.");
                //Item."GXL Bloyal Date Time Modified" := CurrentDateTime();
                //Item.Modify();
                BloyalDataMgt.InsertToBloyalProductChangeLog(Rec."Item No.");
                //WRP-397-
            end;
    end;


    [EventSubscriber(ObjectType::Table, Database::"Item Unit of Measure", 'OnBeforeModifyEvent', '', true, true)]
    local procedure OnBeforeModify_ItemUnitOfMeasure(var Rec: Record "Item Unit of Measure"; var xRec: Record "Item Unit of Measure"; RunTrigger: Boolean)
    var
        xItemUOM: Record "Item Unit of Measure";
        //Item: Record Item;
        BloyalDataMgt: Codeunit "GXL Bloyal Data Management";
        IsModified: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;
        //WRP-397+
        if not RunTrigger then
            exit;
        //WRP-397-

        if BloyalDataMgt.IsBloyalProductIntegrationEnabled() then begin
            if (Rec."GXL Legacy Item No." <> xRec."GXL Legacy Item No.") then
                IsModified := true
            else begin
                xItemUOM.Get(Rec."Item No.", Rec.Code);
                if (Rec."GXL Legacy Item No." <> xItemUOM."GXL Legacy Item No.") then
                    IsModified := true;
            end;
            //WRP-397+
            //if IsModified then begin
            //    Item.Get(Rec."Item No.");
            //    Item."GXL Bloyal Date Time Modified" := CurrentDateTime();
            //    Item.Modify();
            //end;
            if not IsModified then begin
                if BloyalDataMgt.UOM_FieldsChanged(Rec, xItemUOM, 1) then
                    IsModified := true;
            end;
            if IsModified then
                BloyalDataMgt.InsertToBloyalProductChangeLog(Rec."Item No.");
            //WRP-397-
        end;
    end;

    //WRP-397+
    [EventSubscriber(ObjectType::Table, Database::"LSC Barcodes", 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsert_Barcodes(var Rec: Record "LSC Barcodes")
    var
        BloyalDataMgt: Codeunit "GXL Bloyal Data Management";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec."Item No." = '' then
            exit;

        if BloyalDataMgt.IsBloyalProductIntegrationEnabled() then begin
            if BloyalDataMgt.Barcodes_FieldsChanged(Rec, Rec, 0) then
                BloyalDataMgt.InsertToBloyalProductChangeLog(Rec."Item No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Barcodes", 'OnBeforeModifyEvent', '', true, true)]
    local procedure OnBeforeModify_Barcodes(var Rec: Record "LSC Barcodes"; var xRec: Record "LSC Barcodes"; RunTrigger: Boolean)
    var
        xBarcodes: Record "LSC Barcodes";
        BloyalDataMgt: Codeunit "GXL Bloyal Data Management";
        IsModified: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;
        //WRP-397+
        if not RunTrigger then
            exit;
        //WRP-397-

        if Rec."Item No." = '' then
            exit;

        if BloyalDataMgt.IsBloyalProductIntegrationEnabled() then begin
            xBarcodes.Get(Rec."Barcode No.");
            if (Rec."Item No." <> xBarcodes."Item No.") or (Rec."Unit of Measure Code" <> xBarcodes."Unit of Measure Code") then
                IsModified := true;
            if not IsModified then begin
                if BloyalDataMgt.Barcodes_FieldsChanged(Rec, xRec, 1) then
                    IsModified := true;
            end;
            if IsModified then
                BloyalDataMgt.InsertToBloyalProductChangeLog(Rec."Item No.");
        end;
    end;

    //WRP-397-


    [EventSubscriber(ObjectType::Table, Database::"LSC Division", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsert_Division(var Rec: Record "LSC Division"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;

        Rec."GXL Bloyal Date Time Modified" := CurrentDateTime();
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Division", 'OnBeforeModifyEvent', '', true, true)]
    local procedure OnBeforeModify_Division(var Rec: Record "LSC Division"; var xRec: Record "LSC Division"; RunTrigger: Boolean)
    var
        xDivision: Record "LSC Division";
        BloyalDataMgt: Codeunit "GXL Bloyal Data Management";
        IsModified: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if BloyalDataMgt.IsBloyalProductIntegrationEnabled() then begin
            if (Rec.Description <> xRec.Description) then
                IsModified := true
            else begin
                xDivision.Get(Rec.Code);
                if Rec.Description <> xDivision.Description then
                    IsModified := true;
            end;
            if IsModified then
                Rec."GXL Bloyal Date Time Modified" := CurrentDateTime();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsert_ItemCategory(var Rec: Record "Item Category"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        Rec."GXL Bloyal Date Time Modified" := CurrentDateTime();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Item Category", 'OnBeforeModifyEvent', '', true, true)]
    local procedure OnBeforeModify_ItemCategory(var Rec: Record "Item Category"; var xRec: Record "Item Category"; RunTrigger: Boolean)
    var
        xItemCat: Record "Item Category";
        BloyalDataMgt: Codeunit "GXL Bloyal Data Management";
        IsModified: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if BloyalDataMgt.IsBloyalProductIntegrationEnabled() then begin
            if (Rec.Description <> xRec.Description) or (Rec."LSC Division Code" <> xRec."LSC Division Code") then
                IsModified := true
            else begin
                xItemCat.Get(Rec.Code);
                if (Rec.Description <> xItemCat.Description) or (Rec."LSC Division Code" <> xItemCat."LSC Division Code") then
                    IsModified := true;
            end;
            if IsModified then
                Rec."GXL Bloyal Date Time Modified" := CurrentDateTime();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Retail Product Group", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsert_RetailProdGroup(var Rec: Record "LSC Retail Product Group"; RunTrigger: Boolean)
    begin
        if Rec.IsTemporary() then
            exit;
        Rec."GXL Bloyal Date Time Modified" := CurrentDateTime();
    end;

    [EventSubscriber(ObjectType::Table, Database::"LSC Retail Product Group", 'OnBeforeModifyEvent', '', true, true)]
    local procedure OnBeforeModify_RetailProdGroup(var Rec: Record "LSC Retail Product Group"; var xRec: Record "LSC Retail Product Group"; RunTrigger: Boolean)
    var
        xRetailProdGrp: Record "LSC Retail Product Group";
        BloyalDataMgt: Codeunit "GXL Bloyal Data Management";
        IsModified: Boolean;
    begin
        if Rec.IsTemporary() then
            exit;
        if not RunTrigger then
            exit;
        if BloyalDataMgt.IsBloyalProductIntegrationEnabled() then begin
            if (Rec.Description <> xRec.Description) or (Rec."Division Code" <> xRec."Division Code") then
                IsModified := true
            else begin
                xRetailProdGrp.Get(Rec."Item Category Code", Rec.Code);
                if (Rec.Description <> xRetailProdGrp.Description) or (Rec."Division Code" <> xRetailProdGrp."Division Code") then
                    IsModified := true;
            end;
            if IsModified then
                Rec."GXL Bloyal Date Time Modified" := CurrentDateTime();
        end;
    end;

}