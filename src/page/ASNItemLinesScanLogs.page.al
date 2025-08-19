page 50362 "GXL ASN Item Lines Scan Logs"
{
    Caption = 'ASN Item Lines Scan Logs';
    Editable = false;
    PageType = List;
    SourceTable = "GXL ASN Level 3 Line Scan Log";
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
                field("Level 3 Code"; Rec."Level 3 Code")
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
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

