/// <summary>
/// ERP-NAV Master Data Management: Automate IC Transaction
/// </summary>
table 50031 "GXL IC Automation Error Log"
{
    Caption = 'IC Automation Error Log';
    DataClassification = CustomerContent;
    LookupPageId = "GXL IC Automation Error Log";
    DrillDownPageId = "GXL IC Automation Error Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(11; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(12; "IC Partner Code"; Code[20])
        {
            Caption = 'IC Partner Code';
            DataClassification = CustomerContent;
            TableRelation = "IC Partner";
        }
        field(13; "Source Type"; Option)
        {
            Caption = 'Source Type';
            DataClassification = CustomerContent;
            OptionMembers = Journal,"Sales Document","Purchase Document";
            OptionCaption = 'Journal,Sales Document,Purchase Document';
        }
        field(14; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(15; "Document Type"; Option)
        {
            Caption = 'Document Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Payment,Invoice,"Credit Memo",Refund,Order,"Return Order";
            OptionCaption = ' ,Payment,Invoice,Credit Memo,Refund,Order,Return Order';
        }
        field(16; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(TransactionNo; "Transaction No.")
        { }
    }

    var

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}