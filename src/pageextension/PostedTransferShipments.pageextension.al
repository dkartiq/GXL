pageextension 50048 "GXL Posted Transfer Shipments" extends "Posted Transfer Shipments"
{
    /*Change Log
    PS-2534: Add TOR to posted shipments
    */

    layout
    {
        addlast(Control1)
        {
            field("GXL Transfer Order No."; Rec."Transfer Order No.")
            {
                ApplicationArea = All;
            }
        }
        //PS-2523 VET Clinic transfer order +
        addafter("Transfer-to Code")
        {
            field("GXL VET Store Code"; Rec."GXL VET Store Code")
            {
                ApplicationArea = All;
            }
        }
        //PS-2523 VET Clinic transfer order -
    }

}