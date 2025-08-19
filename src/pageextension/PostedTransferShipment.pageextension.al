pageextension 50049 "GXL Posted Transfer Shipment" extends "Posted Transfer Shipment"
{
    layout
    {
        //PS-2523 VET Clinic transfer order +
        addafter("Transfer-to Code")
        {
            field("GXL VET Store Code"; Rec."GXL VET Store Code")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        //PS-2523 VET Clinic transfer order -
    }

}