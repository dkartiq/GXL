pageextension 50034 "GXL Posted Purchase Invoices" extends "Posted Purchase Invoices"
{
    layout
    {
        addlast(Control1)
        {
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