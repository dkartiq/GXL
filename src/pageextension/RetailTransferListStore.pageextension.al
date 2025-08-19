pageextension 50021 "GXL Retail Transfer List Store" extends "LSC Retail Transfer List Store"
{
    /*Change Log
        PS-2344: View closed orders
    */

    layout
    {
        addafter("Store-from")
        {
            field("GXL Transfer-from Name"; Rec."Transfer-from Name")
            {
                ApplicationArea = All;
            }
        }
        addafter("Store-to")
        {
            field("GXL Transfer-to Name"; Rec."Transfer-to Name")
            {
                ApplicationArea = All;
            }
        }
        addafter(Status)
        {
            field("GXL Receipt Date"; Rec."Receipt Date")
            {
                ApplicationArea = All;
            }
        }
    }

}