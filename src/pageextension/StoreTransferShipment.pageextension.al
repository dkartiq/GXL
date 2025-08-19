pageextension 50041 "GXL Store Transfer Shipment" extends "LSC Store P. Transfer Shipment"
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