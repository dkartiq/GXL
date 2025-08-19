page 50377 "GXL UOM Category List"
{
    Caption = 'UOM Category List';
    PageType = List;
    SourceTable = "GXL UOM Category";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Category Code"; Rec."Category Code")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Standard UOM Code"; Rec."Standard UOM Code")
                {
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                }
            }
        }
    }

    actions
    {
    }
}

