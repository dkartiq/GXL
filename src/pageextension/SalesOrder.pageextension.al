pageextension 50037 "GXL Sales Order" extends "Sales Order"
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