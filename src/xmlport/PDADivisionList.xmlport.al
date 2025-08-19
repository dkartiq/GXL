xmlport 50280 "GXL PDA Division List"
{
    Caption = 'Division List';
    Direction = Export;
    FormatEvaluate = Xml;
    UseRequestPage = false;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/DivisionList';

    schema
    {
        textelement(DivisionList)
        {
            tableelement(Division; "LSC Division")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(ID; Division.Code)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(Description; Division.Description)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
            }
        }
    }

}