report 50355 "GXL ASN Scanning Discrepancy"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/ASNScanningDiscrepancy.rdlc';
    Caption = 'ASN Scanning Discrepancy';
    UsageCategory = Administration;
    ApplicationArea = All;

    dataset
    {
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number) ORDER(Ascending);
            column(CompanyName; COMPANYNAME())
            {
            }
            column(ASNDocumentType; TempASNScanningDiscrepancy."ASN Document Type")
            {
            }
            column(ASNDocumentNo; TempASNScanningDiscrepancy."ASN Document No.")
            {
                IncludeCaption = true;
            }
            column(ItemNo; TempASNScanningDiscrepancy."Item No.")
            {
                IncludeCaption = true;
            }
            column(QuantityConfirmed; TempASNScanningDiscrepancy."Quantity Confirmed")
            {
            }
            column(QuantityScanned; TempASNScanningDiscrepancy."Quantity Scanned")
            {
            }
            column(Difference; TempASNScanningDiscrepancy.Difference)
            {
            }

            trigger OnAfterGetRecord()
            begin
                IF Number = 1 THEN
                    TempASNScanningDiscrepancy.FindSet()
                ELSE
                    TempASNScanningDiscrepancy.Next();
            end;

            trigger OnPreDataItem()
            var
                RecordCount: Integer;
            begin
                TempASNScanningDiscrepancy.Reset();
                RecordCount := TempASNScanningDiscrepancy.Count();

                IF RecordCount = 0 THEN
                    CurrReport.Quit();

                Integer.SETRANGE(Number, 1, RecordCount);
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

    trigger OnPostReport()
    begin
        TempASNScanningDiscrepancy.Reset();
        TempASNScanningDiscrepancy.DeleteAll();
    end;

    var
        TempASNScanningDiscrepancy: Record "GXL ASN Scanning Discrepancy" temporary;

    [Scope('OnPrem')]
    procedure SetASNScanningDiscrepancy(var TempASNScanningDiscrepancyNew: Record "GXL ASN Scanning Discrepancy" temporary)
    begin
        TempASNScanningDiscrepancy.Reset();
        TempASNScanningDiscrepancy.DeleteAll();

        TempASNScanningDiscrepancyNew.Reset();
        IF TempASNScanningDiscrepancyNew.FindSet() THEN
            REPEAT
                TempASNScanningDiscrepancy := TempASNScanningDiscrepancyNew;
                TempASNScanningDiscrepancy.INSERT();
            UNTIL TempASNScanningDiscrepancyNew.Next() = 0;
    end;
}

