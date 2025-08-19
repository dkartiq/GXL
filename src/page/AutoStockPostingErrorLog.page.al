page 50029 "GXL AutoStockPosting Error Log"
{
    Caption = 'Auto Stock Posting Error Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL AutoSTockPosting Error Log";
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                Editable = false;
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = All;
                }
                field("Transaction No."; Rec."Transaction No.")
                {
                    ApplicationArea = All;
                }
                field("Current Posting Status"; Rec."Current Posting Status")
                {
                    ApplicationArea = All;
                }
                field("Log Date Time"; Rec."Log Date Time")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
                field("No. of Runs"; Rec."No. of Runs")
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