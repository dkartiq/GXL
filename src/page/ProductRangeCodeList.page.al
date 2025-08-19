page 50019 "GXL Product Range Code List"
{
    PageType = List;
    SourceTable = "GXL Product Range Code";
    UsageCategory = Lists;
    ApplicationArea = All;
    Caption = 'Product Range Code List';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

