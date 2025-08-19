report 50012 "GXL Average basket size"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/Averagebasketsize.rdlc';

    ApplicationArea = All;
    Caption = 'Average basket size';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("IS Store"; "LSC Store")
        {
            DataItemTableView = SORTING("No.");
            RequestFilterFields = "No.", "Date Filter";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(COMPANYNAME; CompanyName)
            {
            }
            column("USERID"; UserId)
            {
            }
            column(IS_Store__No__; "No.")
            {
            }
            column(IS_Store_Name; Name)
            {
            }
            column(IS_Store__Sales__Qty___; "Sales (Qty.)")
            {
            }
            column(IS_Store__Sales__LCY__; "Sales (LCY)")
            {
            }
            column(TotalBaskets; TotalBaskets)
            {
            }
            column(AverageBasket; AverageBasket)
            {
            }
            column(Average_basket_sizeCaption; Average_basket_sizeCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(IS_Store__No__Caption; FieldCaption("No."))
            {
            }
            column(IS_Store_NameCaption; FieldCaption(Name))
            {
            }
            column(IS_Store__Sales__Qty___Caption; FieldCaption("Sales (Qty.)"))
            {
            }
            column(IS_Store__Sales__LCY__Caption; FieldCaption("Sales (LCY)"))
            {
            }
            column(Total_basketsCaption; Total_basketsCaptionLbl)
            {
            }
            column(Average_basketCaption; Average_basketCaptionLbl)
            {
            }

            trigger OnAfterGetRecord()
            begin
                AverageBasket := 0;
                "IS Store".CalcFields("No. of Sales Transactions");
                TotalBaskets := "No. of Sales Transactions";

                if ("Sales (LCY)" <> 0) and (TotalBaskets <> 0) then
                    AverageBasket := "Sales (LCY)" / TotalBaskets;
            end;

            trigger OnPreDataItem()
            begin
                LimitUserAccess();
            end;
        }

    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }


    labels
    {
    }

    trigger OnPreReport()
    begin
        if not RetailUser.Get(UserId()) then
            Clear(RetailUser);
    end;

    var
        RetailUser: Record "LSC Retail User";
        TotalBaskets: Integer;
        AverageBasket: Decimal;
        Average_basket_sizeCaptionLbl: Label 'Average basket size';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Total_basketsCaptionLbl: Label 'Total baskets';
        Average_basketCaptionLbl: Label 'Average basket';


    local procedure LimitUserAccess()
    begin
        if RetailUser."Store No." <> '' then begin
            "IS Store".FilterGroup(2);
            "IS Store".SetRange("No.", RetailUser."Store No.");
            "IS Store".FilterGroup(0);
        end;
    end;
}

