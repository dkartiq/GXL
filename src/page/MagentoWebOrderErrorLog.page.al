page 50103 "GXL Magento WebOrder Error Log"
{
    Caption = 'Magento Web Order Error Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Editable = false;
    SourceTable = "GXL Magento WebOrder Error Log";

    layout
    {
        area(Content)
        {
            repeater(RepeaterControl)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
                field("Web Order Entry No."; Rec."Web Order Entry No.")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Order Archived"; Rec."Order Archived")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    ApplicationArea = All;
                }
                field("Created by User ID"; Rec."Created by User ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}