xmlport 50281 "GXL PDA ItemCategory"
{
    Caption = 'Item Category List';
    Direction = Export;
    FormatEvaluate = Xml;
    UseRequestPage = false;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/ItemCategory';

    schema
    {
        textelement(ItemCategoryList)
        {
            tableelement(ItemCategory; "Item Category")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(ID; ItemCategory.Code)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(Description; ItemCategory.Description)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
            }
        }
    }
    procedure SetDivisionCode(DivisionCodeP: Code[20])
    begin
        ItemCategory.SetRange("LSC Division Code", DivisionCodeP);
    end;
}