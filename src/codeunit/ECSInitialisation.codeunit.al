codeunit 50153 "GXL ECS Initialisation"
{
    trigger OnRun()
    begin

    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        GlobalItem: Record Item;
        ECSWMSMgt: Codeunit "GXL ECS WSF Management";
        SetupRead: Boolean;
        Windows: Dialog;
        IntegrationIsDisabledErr: Label '%1 is %2';


    procedure InitialseStore(var StoreRec: Record "LSC Store")
    begin
        GetSetups();
        if IntegrationSetup."ECS Store Integration" = IntegrationSetup."ECS Store Integration"::Disable then
            Error(IntegrationIsDisabledErr, IntegrationSetup.FieldCaption("ECS Store Integration"), IntegrationSetup."ECS Store Integration");

        if GuiAllowed() then
            Windows.Open(
                'Initialising ECS Store       \\' +
                'Store         #1#############'
            );

        StoreRec.SetRange("GXL Location Type", StoreRec."GXL Location Type"::"6");
        if StoreRec.FindSet() then
            repeat
                if GuiAllowed() then
                    Windows.Update(1, StoreRec."No.");
                ECSWMSMgt.LogStoreUpdate(StoreRec);
            until StoreRec.Next() = 0;
        if GuiAllowed() then
            Windows.Close();
    end;

    procedure InitialiseCluster(var StoreGroup: Record "LSC Store Group")
    begin
        GetSetups();
        if IntegrationSetup."ECS Store Integration" = IntegrationSetup."ECS Store Integration"::Disable then
            Error(IntegrationIsDisabledErr, IntegrationSetup.FieldCaption("ECS Store Integration"), IntegrationSetup."ECS Store Integration");

        if GuiAllowed() then
            Windows.Open(
                'Initialising ECS Cluster       \\' +
                'Store Group     #1#############'
            );
        if StoreGroup.FindSet() then
            repeat
                if GuiAllowed() then
                    Windows.Update(1, StoreGroup.Code);
                ECSWMSMgt.LogStoreGroupUpdate(StoreGroup, 0);
            until StoreGroup.Next() = 0;
        if GuiAllowed() then
            Windows.Close();
    end;

    procedure InitialiseStoreCluster(var StoreGroupSetup: Record "LSC Store Group Setup")
    begin
        GetSetups();
        if IntegrationSetup."ECS Store Integration" = IntegrationSetup."ECS Store Integration"::Disable then
            Error(IntegrationIsDisabledErr, IntegrationSetup.FieldCaption("ECS Store Integration"), IntegrationSetup."ECS Store Integration");

        if GuiAllowed() then
            Windows.Open(
                'Initialising ECS Store Cluster \\' +
                'Store Group     #1#############' +
                'Store           #2#############'
            );
        if StoreGroupSetup.FindSet() then
            repeat
                if GuiAllowed() then begin
                    Windows.Update(1, StoreGroupSetup."Store Group");
                    Windows.Update(2, StoreGroupSetup."Store Code");
                end;
                ECSWMSMgt.LogStoreGroupStoresUpdate(StoreGroupSetup, 0);
            until StoreGroupSetup.Next() = 0;
        if GuiAllowed() then
            Windows.Close();
    end;

    procedure InitialiseProductHierarchy(var Item: Record Item)
    var
        RequestGUID: Guid;
    begin
        GetSetups();
        if IntegrationSetup."ECS Prod Hierarchy Integration" = IntegrationSetup."ECS Prod Hierarchy Integration"::Disable then
            Error(IntegrationIsDisabledErr, IntegrationSetup.FieldCaption("ECS Prod Hierarchy Integration"), IntegrationSetup."ECS Prod Hierarchy Integration");

        if GuiAllowed() then
            Windows.Open(
                'Initialising ECS Product Hierarchy\\' +
                'Item No.           #1#############'
            );
        if Item.FindSet() then
            repeat
                if GuiAllowed() then
                    Windows.Update(1, Item."No.");
                RequestGUID := CreateGuid();
                ECSWMSMgt.BuildCompleteProductHierarchyStructure(RequestGUID, Item);
            until Item.Next() = 0;
        if GuiAllowed() then
            Windows.Close();
    end;

    procedure InitialiseItemContent(var Item: Record Item)
    var
        Barcodes: Record "LSC Barcodes";
    begin
        GetSetups();
        if IntegrationSetup."ECS Item Content Integration" = IntegrationSetup."ECS Item Content Integration"::Disable then
            Error(IntegrationIsDisabledErr, IntegrationSetup.FieldCaption("ECS Item Content Integration"), IntegrationSetup."ECS Item Content Integration");

        if GuiAllowed() then
            Windows.Open(
                'Initialising ECS Item Content\\' +
                'Item No.      #1#############'
            );
        Item.SetRange(Blocked, false);
        if Item.FindSet() then
            repeat
                if GuiAllowed() then
                    Windows.Update(1, Item."No.");
                ECSWMSMgt.LogItemContentUpdate(Item, Item);

                Barcodes.SetCurrentKey("Item No.");
                Barcodes.SetRange("Item No.", Item."No.");
                if Barcodes.FindSet() then
                    repeat
                        ECSWMSMgt.LogItemContentUpdate(Barcodes, Barcodes);
                    until Barcodes.Next() = 0;
            until Item.Next() = 0;
        if GuiAllowed() then
            Windows.Close();
    end;
    // >> Upgrade
    //procedure InitialiseSalesPrice(var SalesPrice: Record "Sales Price")
    procedure InitialiseSalesPrice(var SalesPrice: Record "Price List Line")
    // << Upgrade
    begin
        GetSetups();
        if IntegrationSetup."ECS Sales Price Integration" = IntegrationSetup."ECS Sales Price Integration"::Disable then
            Error(IntegrationIsDisabledErr, IntegrationSetup.FieldCaption("ECS Sales Price Integration"), IntegrationSetup."ECS Sales Price Integration");

        if GuiAllowed() then
            Windows.Open(
                'Initialising ECS Sales Price  \\' +
                'Sales Type     #1#############\' +
                'Item No.       #2#############'
            );
        if SalesPrice.FindSet() then
            repeat
                if GuiAllowed() then begin
                    // >> Upgrade
                    // Windows.Update(1, SalesPrice."Sales Code");
                    // Windows.Update(2, SalesPrice."Item No.");
                    Windows.Update(1, SalesPrice."Source No.");
                    Windows.Update(2, SalesPrice."Asset No.");
                    // << Upgrade
                end;
                ECSWMSMgt.LogSalesPriceDataUpdate(SalesPrice);
            until SalesPrice.Next() = 0;
        if GuiAllowed() then
            Windows.Close();
    end;

    procedure InitSalesPriceDataByLocation(LocCode: Code[10]; PriceDate: Date)
    var
        // >> Upgrade
        //SalesPrice: Record "Sales Price";
        SalesPrice: Record "Price List Line";
    // << Upgrade
    begin
        GetSetups();
        if IntegrationSetup."ECS Sales Price Integration" = IntegrationSetup."ECS Sales Price Integration"::Disable then
            Error(IntegrationIsDisabledErr, IntegrationSetup.FieldCaption("ECS Sales Price Integration"), IntegrationSetup."ECS Sales Price Integration");

        if GuiAllowed() then
            Windows.Open(
                'Initialising ECS Sales Price  \\' +
                'Sales Type     #1#############\' +
                'Item No.       #2#############'
            );

        // >> Upgrade
        //SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
        SalesPrice.SetRange("Source Type", SalesPrice."Source Type"::"Customer Price Group");
        // << Upgrade
        SalesPrice.SetFilter("Starting Date", '%1|>=%2', 0D, PriceDate);
        if SalesPrice.FindSet() then
            repeat
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

                if GuiAllowed() then begin
                    // >> Upgrade
                    // Windows.Update(1, SalesPrice."Sales Code");
                    // Windows.Update(2, SalesPrice."Item No.");
                    Windows.Update(1, SalesPrice."Source No.");
                    Windows.Update(2, SalesPrice."Asset No.");
                    // << Upgrade
                end;

                ECSWMSMgt.LogSalesPriceDataUpdate(SalesPrice, GlobalItem);

            until SalesPrice.Next() = 0;

        if GuiAllowed() then
            Windows.Close();

    end;

    procedure InitialiseStockRanging(var SKU: Record "Stockkeeping Unit")
    begin
        GetSetups();
        if IntegrationSetup."ECS Stock Ranging Integration" = IntegrationSetup."ECS Stock Ranging Integration"::Disable then
            Error(IntegrationIsDisabledErr, IntegrationSetup.FieldCaption("ECS Stock Ranging Integration"), IntegrationSetup."ECS Stock Ranging Integration");

        if GuiAllowed() then
            Windows.Open(
                'Initialising ECS Stock Ranging\\' +
                'Location       #1#############\' +
                'Item No.       #2#############'
            );
        if SKU.FindSet() then
            repeat
                if GuiAllowed() then begin
                    Windows.Update(1, SKU."Location Code");
                    Windows.Update(2, SKU."Item No.");
                end;
                ECSWMSMgt.LogStockRangeUpdate(SKU);
            until SKU.Next() = 0;
        if GuiAllowed() then
            Windows.Close();
    end;


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

}