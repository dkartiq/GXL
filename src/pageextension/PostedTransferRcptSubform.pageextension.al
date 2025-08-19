pageextension 50053 "GXL Posted TransferRcptSubform" extends "Posted Transfer Rcpt. Subform"
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