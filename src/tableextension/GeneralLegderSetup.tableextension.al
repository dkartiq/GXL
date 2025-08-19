tableextension 50029 "GXL General Legder Setup" extends "General Ledger Setup"
{
    fields
    {
        //ERP-NAV Master Data Management: Automate IC Transaction +
        field(50001; "GXL Automate IC Transactions"; Boolean)
        {
            Caption = 'Automate IC Transactions';
            DataClassification = CustomerContent;
        }
        field(50002; "GXL Incoming IC Template Name"; Code[10])
        {
            Caption = 'Incoming IC Jnl. Template Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Template".Name where(Type = const(Intercompany));
        }
        field(50003; "GXL Incoming IC Batch Name"; Code[10])
        {
            Caption = 'Incoming IC Jnl. Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Journal Batch".Name where("Journal Template Name" = field("GXL Incoming IC Template Name"));
        }
        field(50004; "GXL Automate IC E-Mail"; Text[250])
        {
            Caption = 'Automate IC E-Mail';
            DataClassification = CustomerContent;
        }
        //ERP-NAV Master Data Management: Automate IC Transaction -
    }

}