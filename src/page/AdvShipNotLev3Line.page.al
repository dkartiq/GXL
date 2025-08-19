page 50353 "GXL Adv. Ship. Not. Lev 3 Line"
{
    Caption = 'Advance Shipping Notice Level 3 Lines';
    Editable = false;
    PageType = List;
    SourceTable = "GXL ASN Level 3 Line";
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Level 3 Type"; Rec."Level 3 Type")
                {
                }
                field("Level 3 Code"; Rec."Level 3 Code")
                {
                }
                field(GTIN; Rec.GTIN)
                {
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

                    trigger OnAction()
                    begin
                        Rec.ShowLevel4Lines();
                    end;
                }
            }
        }
    }
}

