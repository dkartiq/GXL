xmlport 50282 "GXL PDA ProductGroup"
{
    Caption = 'Product Group List';
    Direction = Export;
    FormatEvaluate = Xml;
    UseRequestPage = false;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/ProductGroup';

    schema
    {
        textelement(ProductGroupList)
        {
            tableelement(ProductGroup; "LSC Retail Product Group")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(ID; ProductGroup.Code)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(Description; ProductGroup.Description)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }

            }

        }

    }
    procedure SetItemCategory(ItemCatergoryCodeP: Code[20])
    begin
        ProductGroup.SetFilter("Item Category Code", ItemCatergoryCodeP);
    end;
}