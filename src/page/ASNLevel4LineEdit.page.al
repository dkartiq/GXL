page 10016864 "GXL ASN Level 4 Line - Edit"
{
    Caption = 'Advance Shipping Notice Level 4 Lines - Edit';
    PageType = List;
    SourceTable = "GXL ASN Level 4 Line";
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field("Level 3 Line No."; Rec."Level 3 Line No.")
                {
                    ToolTip = 'Specifies the value of the Level 3 Line No. field.', Comment = '%';
                }
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
}