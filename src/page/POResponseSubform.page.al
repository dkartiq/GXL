page 50358 "GXL PO Response Subform"
{
    Caption = 'PO Response Subform';
    LinksAllowed = false;
    PageType = ListPart;
    SourceTable = "GXL PO Response Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {
                }
                field("PO Line No."; Rec."PO Line No.")
                {
                }
                field("Item Response Indicator"; Rec."Item Response Indicator")
                {
                }
                field("Item No."; Rec."Item No.")
                {
                }
                field("Primary EAN"; Rec."Primary EAN")
                {
                }
                field("Vendor Reorder No."; Rec."Vendor Reorder No.")
                {
                }
                field(Description; Rec.Description)
                {
                }
                field(OMQTY; Rec.OMQTY)
                {
                }
                field(OPQTY; Rec.OPQTY)
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Carton-Qty"; Rec."Carton-Qty")
                {
                }
                field("Direct Unit Cost"; Rec."Direct Unit Cost")
                {
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                }
                field("PO Response Number"; Rec."PO Response Number")
                {
                }
            }
        }
    }

    actions
    {
    }
}

