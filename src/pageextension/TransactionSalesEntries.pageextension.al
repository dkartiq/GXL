pageextension 50025 "GXL Transaction Sales Entries" extends "LSC Transaction Sales Entries"
{
    /*Change Log
        PS-1951
    */

    layout
    {
        addafter("Item No.")
        {
            field("GXL Item Description"; Rec."GXL Item Description")
            {
                ApplicationArea = All;
            }
        }
        addlast(Control1)
        {
            field("GXL Legacy Item No."; Rec."GXL Legacy Item No.")
            {
                ApplicationArea = All;
                Visible = false;
            }
        }
    }

}