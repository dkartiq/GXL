pageextension 50023 "GXL Store Transfer Rcpt. List" extends "LSC Store P. Transfer Rec.List"
{
    /*Change Log
        PS-2344: View closed orders
    */

    layout
    {
        addafter("Store-from")
        {
            field("GXL Transfer-from Name"; Rec."Transfer-from Name")
            {
                ApplicationArea = All;
            }
        }
        addafter("Transfer-to Code")
        {
            //PS-2523 VET Clinic transfer order +
            field("GXL VET Store Code"; Rec."GXL VET Store Code")
            {
                ApplicationArea = All;
            }
            //PS-2523 VET Clinic transfer order -
            field("GXL Transfer Order No."; Rec."Transfer Order No.")
            {
                ApplicationArea = All;
            }
            field("GXL Receipt Date"; Rec."Receipt Date")
            {
                ApplicationArea = All;
            }
        }
    }

}