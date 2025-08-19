pageextension 50032 "GXL Posted Purchase Receipts" extends "Posted Purchase Receipts"
{
    /*Change Log
        PS-2534: Add POR to posted receipts
    */
    layout
    {
        addlast(Control1)
        {
            field("GXL Order No."; Rec."Order No.")
            {
                ApplicationArea = All;
            }
            //ERP-NAV Master Data Management +
            field("GXL International Order"; Rec."GXL International Order")
            {
                ApplicationArea = All;
                Editable = false;
            }
            //ERP-NAV Master Data Management -
        }
    }

}