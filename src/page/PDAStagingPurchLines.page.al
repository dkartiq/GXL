page 50256 "GXL PDA-Staging Purch. Lines"
{
    Caption = 'PDA-Staging Purch. Lines';
    PageType = ListPart;
    SourceTable = "GXL PDA-Staging Purch. Line";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Qty. to Receive"; Rec."Qty. to Receive")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                }
                field("Carton-Qty"; Rec."Carton-Qty")
                {
                    ApplicationArea = All;
                }
                field("Qty. Variance Reason Code"; Rec."Qty. Variance Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Vendor Reorder No."; Rec."Vendor Reorder No.")
                {
                    ApplicationArea = All;
                }
                field("Legacy Item No."; Rec."Legacy Item No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}