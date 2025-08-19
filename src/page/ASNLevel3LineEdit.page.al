page 10016863 "GXL ASN Level 3 Line - Edit"
{
    Caption = 'Advance Shipping Notice Level 3 Lines - Edit';
    PageType = List;
    SourceTable = "GXL ASN Level 3 Line";
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
                field("Level 1 Line No."; Rec."Level 1 Line No.")
                {
                    ToolTip = 'Specifies the value of the Level 1 Line No. field.', Comment = '%';
                }
                field("Level 2 Line No."; Rec."Level 2 Line No.")
                {
                    ToolTip = 'Specifies the value of the Level 2 Line No. field.', Comment = '%';
                }
                field("Level 3 Type"; Rec."Level 3 Type")
                {
                }
                field("Level 3 Code"; Rec."Level 3 Code")
                {
                }
                field(GTIN; Rec.GTIN)
                {
                }
                field("Item No."; Rec."Item No.")
                {
                    ToolTip = 'Specifies the value of the Item No. field.', Comment = '%';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the value of the Unit of Measure Code field.', Comment = '%';
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                }
                field("Weight of Stock"; Rec."Weight of Stock")
                {
                    Visible = false;
                }
                field("Nominal Weight"; Rec."Nominal Weight")
                {
                    Visible = false;
                }
                field("Count / Pack Size"; Rec."Count / Pack Size")
                {
                    Visible = false;
                }
                field("Use by Date"; Rec."Use by Date")
                {
                    Visible = false;
                }
                field("Packed on Date"; Rec."Packed on Date")
                {
                    Visible = false;
                }
                field("Inners / Outer"; Rec."Inners / Outer")
                {
                    Visible = false;
                }
                field("Legal Requirements"; Rec."Legal Requirements")
                {
                    Visible = false;
                }
                field("Batch No."; Rec."Batch No.")
                {
                }
                field("Batch Expiry Date"; Rec."Batch Expiry Date")
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
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                action("&Level 4 Lines")
                {
                    Caption = '&Level 4 Lines';
                    Image = Line;
                    Visible = false;
                    ApplicationArea = All;
                    RunObject = page "GXL ASN Level 4 Line - Edit";
                    RunPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Level 3 Line No." = field("Line No.");
                }
            }
        }
    }
}