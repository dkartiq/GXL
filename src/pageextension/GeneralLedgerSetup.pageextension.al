pageextension 50035 "GXL General Ledger Setup" extends "General Ledger Setup"
{
    layout
    {
        //ERP-NAV Master Data Management: Automate IC Transaction +
        addlast(Content)
        {
            group("GXL ICTrans")
            {
                Caption = 'IC Transactions';
                field("GXL Automate IC Transactions"; Rec."GXL Automate IC Transactions")
                {
                    ApplicationArea = All;
                }
                field("GXL Incoming IC Template Name"; Rec."GXL Incoming IC Template Name")
                {
                    ApplicationArea = All;
                }
                field("GXL Incoming IC Batch Name"; Rec."GXL Incoming IC Batch Name")
                {
                    ApplicationArea = All;
                }
                field("GXL Automate IC E-Mail"; Rec."GXL Automate IC E-Mail")
                {
                    ApplicationArea = All;
                }
            }
        }
        //ERP-NAV Master Data Management: Automate IC Transaction -
    }

}