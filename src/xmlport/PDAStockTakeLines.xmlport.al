// 001 19.12.2024 KDU https://petbarnjira.atlassian.net/browse/HP-2914
xmlport 50283 "GXL PDA StockTake Lines"
{
    Caption = 'PDA StockTake Lines';
    Direction = Both;
    FormatEvaluate = Xml;
    UseRequestPage = false;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/StocktakeLines';

    schema
    {
        textelement(StockTakeList)
        {

            tableelement(StockTake; "GXL PDA StockTake Line")
            {
                SourceTableView = sorting(SystemModifiedAt) order(descending); // >> 001 <<
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(StockTakeID; StockTake."Stock-Take ID")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(lineNo; StockTake."Line No.")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(StoreCode; StockTake."Store Code")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(ItemNo; StockTake."Item No.")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(ItemDescription; StockTake."Item Description")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(UOM; StockTake.UOM)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(Quantity; StockTake."Physical Quantity")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(SOH; StockTake.SOH)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(CostPrice; StockTake."Unit Cost")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(ResonCode; StockTake."Reson Code")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(Barcode; StockTake.Barcode)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(VendorNo; StockTake."Vendor No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(VendorName; StockTake."Vendor Name")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }

            }

        }

    }
    procedure SetPDAStockID(WorksheetID: Integer; LineNoP: Integer)
    begin
        StockTake.SetRange("Stock-Take ID", WorksheetID);
        if LineNoP <> 0 then
            StockTake.SetRange("Line No.", LineNoP);
    end;
}