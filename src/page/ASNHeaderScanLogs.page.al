page 50361 "GXL ASN Header Scan Logs"
{
    Caption = 'ASN Header Scan Logs';
    Editable = false;
    PageType = List;
    SourceTable = "GXL ASN Header Scan Log";
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
                field("No."; Rec."No.")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    Style = Strong;
                    StyleExpr = TRUE;
                }
                field("Copied to ASN"; Rec."Copied to ASN")
                {
                }
                //PS-2046+
                field("MIM User ID"; Rec."MIM User ID")
                {
                    ApplicationArea = All;
                }
                //PS-2046-
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Scanned ASN Pallet Lines")
            {
                Caption = 'Scanned ASN Pallet Lines';
                Image = Line;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.ShowPalletLines();
                end;
            }
            action("Scanned ASN Box Lines")
            {
                Caption = 'Scanned ASN Box Lines';
                Image = Line;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.ShowBoxLines();
                end;
            }
            action("Scanned ASN Item Lines")
            {
                Caption = 'Scanned ASN Item Lines';
                Image = Line;
                ApplicationArea = All;

                trigger OnAction()
                begin
                    Rec.ShowItemLines();
                end;
            }
        }
    }
}

