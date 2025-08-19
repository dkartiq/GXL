xmlport 50255 "GXL PDA-Facing Update"
{
    Caption = 'PDA-Facing Update';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/FacingUpdate';
    Encoding = UTF16;

    schema
    {
        textelement(PDAFacingDetails)
        {
            MinOccurs = Once;
            MaxOccurs = Once;
            tableelement(StoreFacingReport; "GXL PDA-Facing Update by Store")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(Store; StoreFacingReport."Store Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ItemNumber; StoreFacingReport."Item No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(UOM; StoreFacingReport."Unit of Measure Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(StoreFacing; StoreFacingReport."Store Facing")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(CashierNumber; StoreFacingReport."Cashier Number")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }

            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    var

    procedure SetReportFilter(ItemNumber: Code[20]; UOM: Code[10]; Store: Code[10]; StartDate: Date; EndDate: Date)
    begin
        if ItemNumber <> '' then
            StoreFacingReport.SetRange("Item No.", ItemNumber);
        if UOM <> '' then
            StoreFacingReport.SetRange("Unit of Measure Code", UOM);
        if (StartDate <> 0D) and (EndDate = 0D) then
            StoreFacingReport.SetFilter("Date Modified", '>=%1', StartDate);
        if (StartDate = 0D) and (EndDate <> 0D) then
            StoreFacingReport.SetFilter("Date Modified", '<=%1', EndDate);
        if (StartDate <> 0D) and (EndDate <> 0D) then
            StoreFacingReport.SetRange("Date Modified", StartDate, EndDate);
        if not StoreFacingReport.FindFirst() then
            Error('No Records found.');
    end;


}