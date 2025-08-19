pageextension 50024 "GXL Store Transfer Shpt. List" extends "LSC Store P. Transfer Ship.Lis"
{
    /*Change Log
        PS-2344: View closed orders
    */

    layout
    {
        addafter("Store-to")
        {
            field("GXL Transfer-to Name"; Rec."Transfer-to Name")
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
            field("GXL Shipment Date"; Rec."Shipment Date")
            {
                ApplicationArea = All;
            }
        }
    }

}