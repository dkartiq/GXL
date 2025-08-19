page 50373 "GXL EDI Item Supplier"
{
    Caption = 'EDI Item Supplier';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "GXL EDI Item Supplier";
    UsageCategory = Lists;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Supplier; Rec.Supplier)
                {
                }
                field(ILC; Rec.ILC)
                {
                }
                field(GTIN; Rec.GTIN)
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control50005; Notes)
            {
            }
        }
    }

    actions
    {
    }
}

