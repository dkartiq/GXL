pageextension 50039 "GXL Posted Sales Invoice" extends "Posted Sales Invoice"
{
    layout
    {
        //PS-2523 VET Clinic transfer order +
        addafter("Location Code")
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