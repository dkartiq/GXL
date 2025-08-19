page 50364 "GXL ASN Box Lines Scan Logs"
{
    Caption = 'ASN Box Lines Scan Logs';
    Editable = false;
    PageType = List;
    SourceTable = "GXL ASN Level 2 Line Scan Log";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Document Type"; Rec."Document Type")
                {
                }
                field("Document No."; Rec."Document No.")
                {
                }
                field("Line No."; Rec."Line No.")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Level 2 Code"; Rec."Level 2 Code")
                {
                }
                field(ILC; Rec.ILC)
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                }
                field("Copied to ASN"; Rec."Copied to ASN")
                {
                }
            }
        }
    }

    actions
    {
    }
}

