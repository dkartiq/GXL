page 50017 "GXL Sub-Description 2 List"
{
    PageType = List;
    SourceTable = "GXL Sub-Description 2";
    UsageCategory = Lists;
    ApplicationArea = All;
    Caption = 'Sub-Description 2 List';

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

