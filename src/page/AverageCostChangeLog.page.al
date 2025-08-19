//CR029: Average Cost trapping
page 50027 "GXL Average Cost Change Log"
{
    Caption = 'Average Cost Change Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Average Cost Change Log";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost Before Run"; Rec."Unit Cost Before Run")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost After Run"; Rec."Unit Cost After Run")
                {
                    ApplicationArea = All;
                }
                field("Average Cost Before Run"; Rec."Average Cost Before Run")
                {
                    ApplicationArea = All;
                }
                field("Average Cost After Run"; Rec."Average Cost After Run")
                {
                    ApplicationArea = All;
                }
                field("Last Value Entry Before Run"; Rec."Last Value Entry Before Run")
                {
                    ApplicationArea = All;
                }
                field("Last Value Entry After Run"; Rec."Last Value Entry After Run")
                {
                    ApplicationArea = All;
                }
                field("Run Date"; Rec."Run Date")
                {
                    ApplicationArea = All;
                }
                field("Run Time"; Rec."Run Time")
                {
                    ApplicationArea = All;
                }
                field("Run by User ID"; Rec."Run by User ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Archive)
            {
                Caption = 'Archive';
                ApplicationArea = All;
                Image = Archive;
                RunObject = report "GXL AvgCostChangeLog-Archive";
            }
        }
    }
}