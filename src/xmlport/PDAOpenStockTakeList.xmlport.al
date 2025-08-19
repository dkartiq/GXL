xmlport 50285 "GXL PDA Open StockTake List"
{
    Caption = 'PDA Open StockTake List';
    Direction = Both;
    FormatEvaluate = Xml;
    UseRequestPage = false;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/OpenStocktakeList';

    schema
    {
        textelement(StoreInventoryWorksheetList)
        {
            tableelement(StoreInvWrkSheet; "LSC Store Inventory Worksheet")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(StockTakeID; StoreInvWrkSheet.WorksheetSeqNo)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(description; StoreInvWrkSheet.Description)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(StoreCode; StoreInvWrkSheet."Store No.")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(StockTakeDescription; StoreInvWrkSheet."GXL StockTake Description")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(DateOpened; StoreInvWrkSheet."GXL Date Opened")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }

                trigger OnAfterGetRecord()
                begin
                    //PS-1785+
                    if not StoreInvWrkSheet."GXL Open" then
                        currXMLport.Skip();
                    if StoreInvWrkSheet."GXL No. of Stock Take Lines" = 0 then
                        currXMLport.Skip();
                    //PS-1785-
                    // >> LCB-120
                    if StoreInvWrkSheet."GXL Date Opened" = 0D then
                        currXMLport.Skip();
                    // << LCB-120
                end;
            }

        }

    }
    procedure SetPDAStockStore(StoreCode: Code[20])
    begin
        StoreInvWrkSheet.SetRange("Store No.", StoreCode);
        //PS-1875+
        //StoreInvWrkSheet.SetRange("GXL Open", true);
        //StoreInvWrkSheet.SetFilter("GXL No. of Stock Take Lines", '>%1', 0);
        StoreInvWrkSheet.SetAutoCalcFields("GXL No. of Stock Take Lines", "GXL Open");
        //PS-1875-
    end;
}