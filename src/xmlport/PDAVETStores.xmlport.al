/// <summary>
/// PS-2523 VET Clinic transfer order
/// </summary>
xmlport 50269 "GXL PDA-VET Stores"
{
    Caption = 'PDA-VET Stores';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/VETStores';
    Encoding = UTF16;

    schema
    {
        textelement(VETStores)
        {
            tableelement(VETStore; "GXL VET Store")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;

                fieldelement(Code; VETStore.Code)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(Name; VETStore.Name)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
            }
        }
    }

}