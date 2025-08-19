pageextension 50006 "GXL Stockkeeping Unit List" extends "Stockkeeping Unit List"
{
    layout
    {
        addafter("Assembly Policy")
        {
            field("GXL Effective Date"; Rec."GXL Effective Date")
            {
                ApplicationArea = All;
            }
            field("GXL Quit Date"; Rec."GXL Quit Date")
            {
                ApplicationArea = All;
            }
        }
    }
}