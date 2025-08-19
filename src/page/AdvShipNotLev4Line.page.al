page 50354 "GXL Adv. Ship. Not. Lev 4 Line"
{
    Caption = 'Advance Shipping Notice Level 4 Lines';
    Editable = false;
    PageType = List;
    SourceTable = "GXL ASN Level 4 Line";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Level 4 Type"; Rec."Level 4 Type")
                {
                }
                field("Level 4 Code"; Rec."Level 4 Code")
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Weight of Stock"; Rec."Weight of Stock")
                {
                }
                field("Nominal Weight"; Rec."Nominal Weight")
                {
                }
                field("Count / Pack Size"; Rec."Count / Pack Size")
                {
                }
                field("Use by Date"; Rec."Use by Date")
                {
                }
                field("Packed on Date"; Rec."Packed on Date")
                {
                }
                field("Inners / Outer"; Rec."Inners / Outer")
                {
                }
                field("Legal Requirements"; Rec."Legal Requirements")
                {
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1101244014; Notes)
            {
            }
            systempart(Control1101244015; MyNotes)
            {
            }
        }
    }

    actions
    {
    }
}

