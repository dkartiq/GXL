tableextension 50030 "GXL IC Inbox Transaction" extends "IC Inbox Transaction"
{
    fields
    {
        //ERP-NAV Master Data Management: Automate IC Transaction +
        field(50000; "GXL Error in Process"; Integer)
        {
            Caption = 'Error in Process';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = count("GXL IC Automation Error Log" where("Transaction No." = field("Transaction No.")));
        }
        //ERP-NAV Master Data Management: Automate IC Transaction -
    }

}