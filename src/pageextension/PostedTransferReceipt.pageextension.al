pageextension 50052 "GXL Posted Transfer Receipt" extends "Posted Transfer Receipt"
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