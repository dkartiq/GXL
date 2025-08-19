page 50143 "GXL NAV Confirmed Order Lines"
{
    PageType = ListPart;
    SourceTable = "GXL NAV Confirmed Order Line";
    Caption = 'NAV Confirmed Order Lines';
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Caption = 'Legacy Item No.';
                }
                field("Real Item No."; Rec."Real Item No.")
                {
                    ApplicationArea = All;
                }
                field("Real Item UOM"; Rec."Real Item UOM")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
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
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Including VAT"; Rec."Amount Including VAT")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}