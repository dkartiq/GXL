pageextension 50027 "GXL Purchase Return Order" extends "Purchase Return Order"
{
    layout
    {
        addafter(Status)
        {
            // >> LCB-13
            field("Send Email to Vendor"; Rec."Send Email to Vendor")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Send Email to Vendor';
            }
            // << LCB-13
        }
    }
}
