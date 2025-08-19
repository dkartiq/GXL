pageextension 50042 "GXL Store Transfer Receipt" extends "LSC Store P. Transfer Receipt"
{
    layout
    {
        //PS-2523 VET Clinic transfer order +
        addlast("Transfer-to")
        {
            field("GXL VET Store Code"; Rec."GXL VET Store Code")
            {
                ApplicationArea = All;
            }
        }
        //PS-2523 VET Clinic transfer order -
    }

}