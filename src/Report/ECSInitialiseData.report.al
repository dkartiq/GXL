report 50150 "GXL ECS Initialise Data"
{
    Caption = 'ECS - Initialse Data';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    Caption = 'Options';
                    field(ECSIntegration; ECSIntegrationType)
                    {
                        Caption = 'ECS Integration';
                        ApplicationArea = All;
                        OptionCaption = 'All,Store,Cluster,StoreCluster,ProductHierarchy,ItemContent,SalesPrice,StockRanging';
                    }
                }
            }
        }

        actions
        {
        }
    }

    trigger OnPreReport()
    begin
        case ECSIntegrationType of
            ECSIntegrationType::All:
                begin
                    Clear(ECSInitilaisation);
                    ECSInitilaisation.InitialseStore(Store);

                    Clear(ECSInitilaisation);
                    ECSInitilaisation.InitialiseCluster(StoreGroup);

                    Clear(ECSInitilaisation);
                    ECSInitilaisation.InitialiseStoreCluster(StoreGroupSetup);

                    Clear(ECSInitilaisation);
                    ECSInitilaisation.InitialiseProductHierarchy(Item);

                    Clear(ECSInitilaisation);
                    ECSInitilaisation.InitialiseItemContent(Item);

                    Clear(ECSInitilaisation);
                    ECSInitilaisation.InitialiseSalesPrice(SalesPrice);

                    Clear(ECSInitilaisation);
                    ECSInitilaisation.InitialiseStockRanging(SKU);
                end;

            ECSIntegrationType::Store:
                ECSInitilaisation.InitialseStore(Store);

            ECSIntegrationType::Cluster:
                ECSInitilaisation.InitialiseCluster(StoreGroup);

            ECSIntegrationType::StoreCluster:
                ECSInitilaisation.InitialiseStoreCluster(StoreGroupSetup);

            ECSIntegrationType::ProductHierarchy:
                ECSInitilaisation.InitialiseProductHierarchy(Item);

            ECSIntegrationType::ItemContent:
                ECSInitilaisation.InitialiseItemContent(Item);

            ECSIntegrationType::SalesPrice:
                ECSInitilaisation.InitialiseSalesPrice(SalesPrice);

            ECSIntegrationType::StockRanging:
                ECSInitilaisation.InitialiseStockRanging(SKU);

        end;
    end;

    var
        Store: Record "LSC Store";
        StoreGroup: Record "LSC Store Group";
        StoreGroupSetup: Record "LSC Store Group Setup";
        Item: Record Item;
        // >> Upgrade
        //SalesPrice: Record "Sales Price";
        SalesPrice: Record "Price List Line";
        // << Upgrade
        SKU: Record "Stockkeeping Unit";
        ECSInitilaisation: Codeunit "GXL ECS Initialisation";
        ECSIntegrationType: Option "All","Store","Cluster","StoreCluster","ProductHierarchy","ItemContent","SalesPrice","StockRanging";

}