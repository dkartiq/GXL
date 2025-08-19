page 50014 "GXL Sub-Category 4 List"
{
    PageType = List;
    SourceTable = "GXL Sub-Category 4";
    UsageCategory = Lists;
    ApplicationArea = All;
    Caption = 'Sub-Category 4 List';

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
                field("MPL Factor"; Rec."MPL Factor")
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

