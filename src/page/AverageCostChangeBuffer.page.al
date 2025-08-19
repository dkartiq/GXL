//CR029: Average Cost trapping
page 50028 "GXL Average Cost Change Buffer"
{
    Caption = 'Average Cost Change Buffer';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Average Cost Change Buffer";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Last Unit Cost"; Rec."Last Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Last Average Cost"; Rec."Last Average Cost")
                {
                    ApplicationArea = All;
                }
                field("Last Value Entry No."; Rec."Last Value Entry No.")
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