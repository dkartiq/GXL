page 50018 "GXL Private Label Code"
{
    PageType = List;
    SourceTable = "GXL Private Label Type";
    UsageCategory = Lists;
    Caption = 'Private Label Code';
    ApplicationArea = All;

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

