pageextension 50153 "GXL Retail Product Groups" extends "LSC Retail Product Groups"
{
    layout
    {
        addafter("Outbound Code")
        {
            field("GXL MPL Factor"; Rec."GXL MPL Factor")
            {
                ApplicationArea = All;
            }
        }
    }

}