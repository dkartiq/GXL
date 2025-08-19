pageextension 50050 "GXL Posted TransferShptSubform" extends "Posted Transfer Shpt. Subform"
{
    layout
    {
        //PS-2523 VET Clinic transfer order +
        addbefore(Quantity)
        {
            field("GXL Original Order Quantity"; Rec."GXL Original Order Quantity")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the original quantity of transfer order line';
            }
        }
        //PS-2523 VET Clinic transfer order -

    }

}