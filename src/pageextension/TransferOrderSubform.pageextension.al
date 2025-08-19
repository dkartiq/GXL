// 001 14.08.2025 BY HP2-Sprint2-Changes
pageextension 50404 "GXL Transfer Order Subform" extends "Transfer Order Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Item Category Description"; Rec."Item Category Description")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Item Category Description field.';
            }
        }
        addafter("Receipt Date")
        {
            field("GXL Last JDA Date Modified"; Rec."GXL Last JDA Date Modified")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Last JDA Date Modified field.', Comment = '%';
            }
            field("GXL Unit Cost"; Rec."GXL Unit Cost")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Unit Cost field.', Comment = '%';
            }
            field("Vendor Reorder No."; Rec."Vendor Reorder No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Vendor Reorder No. field.', Comment = '%';
            }
        }
    }

}