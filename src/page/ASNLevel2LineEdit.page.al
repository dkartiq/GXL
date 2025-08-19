page 10016862 "GXL ASN Level 2 Line - Edit"
{
    Caption = 'Advance Shipping Notice Level 2 Lines - Edit';
    ApplicationArea = All;
    PageType = List;
    SourceTable = "GXL ASN Level 2 Line";
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Level 2 Type"; Rec."Level 2 Type")
                {
                    ApplicationArea = All;
                }
                field("Level 2 Code"; Rec."Level 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
                {
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field("Level 1 Line No."; Rec."Level 1 Line No.")
                {
                    ToolTip = 'Specifies the value of the Level 1 Line No. field.', Comment = '%';
                }
                field(ILC; Rec.ILC)
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Quantity Received"; Rec."Quantity Received")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Weight of Stock"; Rec."Weight of Stock")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Nominal Weight"; Rec."Nominal Weight")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Count / Pack Size"; Rec."Count / Pack Size")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Use by Date"; Rec."Use by Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Packed on Date"; Rec."Packed on Date")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Inners / Outer"; Rec."Inners / Outer")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Legal Requirements"; Rec."Legal Requirements")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field("Carton Gross Weight"; Rec."Carton Gross Weight")
                {
                    ApplicationArea = All;
                }
                field("Carton Net Weight"; Rec."Carton Net Weight")
                {
                    ApplicationArea = All;
                }
                field("Batch No."; Rec."Batch No.")
                {
                    ApplicationArea = All;
                }
                field("Batch Expiry Date"; Rec."Batch Expiry Date")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1101244015; Notes)
            {
            }
            systempart(Control1101244016; MyNotes)
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
                action("&Box Lines")
                {
                    ApplicationArea = All;
                    Caption = '&Box Lines';
                    Image = Line;
                    RunObject = page "GXL ASN Level 3 Line - Edit";
                    RunPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Level 2 Line No." = field("Line No.");
                }
            }
        }
    }
}