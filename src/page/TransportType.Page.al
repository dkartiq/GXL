page 50375 "GXL Transport Type"
{
    Caption = 'Transport Type';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "GXL Transport Type";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                }
                field(Description; Rec.Description)
                {
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                }
                field("JDA UOM Code"; Rec."JDA UOM Code")
                {
                }
                field("Maximum Capacity"; Rec."Maximum Capacity")
                {
                }
                field("Minimum Capacity"; Rec."Minimum Capacity")
                {
                }
                field("Check Capacity"; Rec."Check Capacity")
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

