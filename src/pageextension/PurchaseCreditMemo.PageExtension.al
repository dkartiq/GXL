pageextension 50029 "GXL Purchase Credit Memo" extends "Purchase Credit Memo"
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
