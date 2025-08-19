// 001 17.04.2025 BY LCB-799 
pageextension 50047 "GXL Fixed Asset Card" extends "Fixed Asset Card"
{
    // >> 001
    layout
    {
        addafter("Last Date Modified")
        {
            field("FA Tax Type"; Rec."GXL FA Tax Type")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Fa Rule Type field.', Comment = '%';
            }
            field("Tax Only"; Rec."GXL Tax Only")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Tax Only field.', Comment = '%';
            }
        }
    }
    // << 001

    actions
    {
        addlast(Reporting)
        {
            //ERP-255 +
            action("GXL Petbarn Detailed FA")
            {
                Caption = 'Petbarn Detailed Fixed Asset';
                Image = Report;
                RunObject = report "GXL Petbarn Detailed FA";
            }
            //ERP-255 -
        }
    }

}