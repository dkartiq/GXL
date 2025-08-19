pageextension 50036 "GXL IC Inbox Transactions" extends "IC Inbox Transactions"
{
    layout
    {
        //ERP-NAV Master Data Management: Automate IC Transaction +
        addlast(Control1)
        {
            field("GXL Error in Process"; Rec."GXL Error in Process")
            {
                ApplicationArea = All;
            }
        }
        //ERP-NAV Master Data Management: Automate IC Transaction -
    }

}