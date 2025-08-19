pageextension 50038 "GXL Sales Order List" extends "Sales Order List"
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