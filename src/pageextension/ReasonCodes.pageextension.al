// 001 8.07.2025 KDU HP2-Sprint2
pageextension 50012 "GXL Reason Codes" extends "Reason Codes"
{
    layout
    {
        addafter(Description)
        {
            field("GXL Audit Reason Code"; Rec."GXL Audit Reason Code")
            {
                ApplicationArea = All;
            }
            field("GXL Stock Adj."; Rec."GXL Stock Adj.")
            {
                ApplicationArea = All;
            }
            field("GXL PDA-SOH Update"; Rec."GXL PDA-SOH Update")
            {
                ApplicationArea = All;
            }
            field("GXL PO. Variance"; Rec."GXL PO. Variance")
            {
                ApplicationArea = All;
            }
            field("GXL Claimable"; Rec."GXL Claimable")
            {
                ApplicationArea = All;
            }
            field("GXL PDA Short Supply"; Rec."GXL PDA Short Supply")
            {
                ApplicationArea = All;
            }
            field("GXL PDA Over Supply"; Rec."GXL PDA Over Supply")
            {
                ApplicationArea = All;
            }
            field("GXL Ullaged"; Rec."GXL Ullaged")
            {
                ApplicationArea = All;
            }
            // >> LCB-120
            field("GXL Source of Supply"; Rec."GXL Source of Supply")
            {
                ApplicationArea = All;
            }
            // << LCB-120
            // >> 001
            field("GXL PO Change Reason Code"; Rec."GXL PO Change Reason Code")
            {
                ApplicationArea = All;
            }
            // << 001
        }
    }


}