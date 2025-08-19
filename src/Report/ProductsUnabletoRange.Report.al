report 50004 "GXL Products Unable to Range"
{
    Caption = 'Products Unable to Range';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/ProductsUnabletoRange.rdlc';


    dataset
    {
        dataitem("Illegal Product Range Log"; "GXL Illegal Product Range Log")
        {
            RequestFilterFields = "Logged Date", "Sent Date";
            column(COMPANYNAME; CompName)
            {
            }
            column(ILC; "Illegal Product Range Log"."Item No.")
            {
            }
            column(StoreCode; "Illegal Product Range Log"."Store Code")
            {
            }
            column(StoreName; "Illegal Product Range Log"."Store Name")
            {
            }
            column(ILCDescription; "Illegal Product Range Log"."Item Description")
            {
            }
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
        CompName := CompanyName();
    end;

    var
        CompName: Text;
}

