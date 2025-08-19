page 50389 "GXL EDI Invoice Line"
{
    Caption = 'Lines';
    PageType = ListPart;
    SourceTable = "GXL PO INV Line";
    LinksAllowed = false;
    Editable = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("PO Line No."; Rec."PO Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Primary EAN"; Rec."Primary EAN")
                {
                    ApplicationArea = All;
                }
                field("Vendor Reorder No."; Rec."Vendor Reorder No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field(OMQTY; Rec.OMQTY)
                {
                    ApplicationArea = All;
                }
                field(OPQTY; Rec.OPQTY)
                {
                    ApplicationArea = All;
                }
                field("Qty. to Invoice"; Rec."Qty. to Invoice")
                {
                    ApplicationArea = All;
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Item GST Amount"; Rec."Item GST Amount")
                {
                    ApplicationArea = All;
                }
                field("VAT %"; Rec."VAT %")
                {
                    ApplicationArea = All;
                }
                field("Unit QTY To Invoice"; Rec."Unit QTY To Invoice")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}