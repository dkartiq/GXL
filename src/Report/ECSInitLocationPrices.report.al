report 50151 "GXL ECS Init Location Prices"
{
    Caption = 'ECS - Initialise Sales Prices for a Location';
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
                    field(LocCodeCtrl; LocCode)
                    {
                        Caption = 'Location Code';
                        ApplicationArea = All;
                        TableRelation = Location;
                    }
                }
            }
        }

        actions
        {
            area(processing)
            {
            }
        }
    }

    trigger OnPreReport()
    begin
        if LocCode = '' then
            Error(LocCodeMustBeSpecifiedErr);
        PriceDate := WorkDate();
        ECSInitilaisation.InitSalesPriceDataByLocation(LocCode, PriceDate);
    end;

    var
        ECSInitilaisation: Codeunit "GXL ECS Initialisation";
        LocCode: Code[10];
        PriceDate: Date;
        LocCodeMustBeSpecifiedErr: Label 'Location Code must be specified';
}