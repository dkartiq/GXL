codeunit 50175 "GXL Bloyal Data Management"
{
    Permissions = tabledata "GXL Bloyal Product Change Log" = imd;

    trigger OnRun()
    begin

    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        DataTemplateMgt: Codeunit "GXL Data Template Management";
        SetupRead: Boolean;


    local procedure GetSetup()
    begin
        if not SetupRead then begin
            if IntegrationSetup.Get() then
                SetupRead := true;
        end;
    end;

    procedure Item_FieldsChanged(var Item: Record Item; var xItem: Record Item; UpdateType: Option "Insert","Modify","Delete"): Boolean
    begin
        if not IsBloyalProductIntegrationEnabled() then
            exit(false);

        //WRP-397+
        //Release 2
        //if not DataTemplateMgt.IsDataChanged(IntegrationSetup."Bloyal Product Template", Item, xItem, UpdateType) then
        if not DataTemplateMgt.IsDataChangedBeforeModifyEvent(IntegrationSetup."Bloyal Product Template", Item, xItem, UpdateType) then
            //WRP-397-
            exit(false);
        exit(true);

    end;

    procedure IsBloyalProductIntegrationEnabled(): Boolean
    begin
        GetSetup();
        if IntegrationSetup."Bloyal Product Template" = '' then
            exit(false);
        exit(true);
    end;

    //WRP-397+
    procedure UOM_FieldsChanged(var UOM: Record "Item Unit of Measure"; xUOM: Record "Item Unit of Measure"; UpdateType: Option "Insert","Modify","Delete"): Boolean
    begin
        if not IsBloyalProductIntegrationEnabled() then
            exit(false);

        //Release 2
        //if not DataTemplateMgt.IsDataChanged(IntegrationSetup."Bloyal Product Template", UOM, xUOM, UpdateType) then
        if not DataTemplateMgt.IsDataChangedBeforeModifyEvent(IntegrationSetup."Bloyal Product Template", UOM, xUOM, UpdateType) then
            exit(false);
        exit(true);

    end;

    procedure Barcodes_FieldsChanged(var Barcodes: Record "LSC Barcodes"; xBarcodes: Record "LSC Barcodes"; UpdateType: Option "Insert","Modify","Delete"): Boolean
    begin
        if not IsBloyalProductIntegrationEnabled() then
            exit(false);

        //Release 2
        //if not DataTemplateMgt.IsDataChanged(IntegrationSetup."Bloyal Product Template", Barcodes, xBarcodes, UpdateType) then
        if not DataTemplateMgt.IsDataChangedBeforeModifyEvent(IntegrationSetup."Bloyal Product Template", Barcodes, xBarcodes, UpdateType) then
            exit(false);
        exit(true);

    end;

    procedure InsertToBloyalProductChangeLog(ItemNo: Code[20])
    var
        BloyalProdChangeLog: Record "GXL Bloyal Product Change Log";
    begin
        BloyalProdChangeLog.SetCurrentKey("Item No.");
        BloyalProdChangeLog.SetRange("Item No.", ItemNo);
        if BloyalProdChangeLog.FindLast() then
            if not BloyalProdChangeLog.IsProcessed() then
                exit;

        BloyalProdChangeLog.Reset();
        BloyalProdChangeLog.Init();
        BloyalProdChangeLog."Entry No." := 0;
        BloyalProdChangeLog."Item No." := ItemNo;
        BloyalProdChangeLog."Log Date Time" := CurrentDateTime();
        BloyalProdChangeLog.Insert(true);
    end;
    //WRP-397-
}