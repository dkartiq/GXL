pageextension 50022 "GXL Store Purch. Rcpt List" extends "LSC Store P. Purchase Rec.List"
{
    /*Change Log
        PS-2344: View closed orders
    */

    layout
    {
        modify("Posting Date")
        {
            Visible = true;
        }
        addafter("Buy-from Vendor Name")
        {
            field("GXL Order No."; Rec."Order No.")
            {
                ApplicationArea = All;
            }
        }
    }

}