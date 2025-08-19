xmlport 50254 "GXL PDA-Unit Of Measure"
{
    Caption = 'PDA-Legacy Item';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/UnitOfMeasure';
    Encoding = UTF16;

    schema
    {
        textelement(UOMs)
        {
            MinOccurs = Once;
            MaxOccurs = Once;
            tableelement(UOM; "Unit of Measure")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(Code; UOM.Code)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(Description; UOM.Description)
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


}