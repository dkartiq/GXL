page 10016861 "GXL ASN SF - Edit"
{
    Caption = 'Pallet Lines - Edit';
    PageType = ListPart;
    SourceTable = "GXL ASN Level 1 Line";
    AutoSplitKey = true;
    DelayedInsert = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line No. field.', Comment = '%';
                }
                field("Level 1 Type"; Rec."Level 1 Type")
                {
                }
                field("Level 1 Code"; Rec."Level 1 Code")
                {
                }
                field(Quantity; Rec.Quantity)
                {
                }
                field("Quantity Received"; Rec."Quantity Received")
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
                field("Package Gross Weight"; Rec."Package Gross Weight")
                {
                }
                field("Package Net Weight"; Rec."Package Net Weight")
                {
                }
                field("Number of Layers"; Rec."Number of Layers")
                {
                }
                field("Units Per Layer"; Rec."Units Per Layer")
                {
                }
                field("Batch No."; Rec."Batch No.")
                {
                }
                field("Batch Expiry Date"; Rec."Batch Expiry Date")
                {
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group("&Line")
            {
                Caption = '&Line';
                action("&Box Lines")
                {
                    Caption = '&Box Lines';
                    Image = Line;
                    ApplicationArea = All;
                    RunObject = page "GXL ASN Level 3 Line - Edit";
                    RunPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Level 2 Line No." = field("Line No.");
                }
                action("&Item Lines")
                {
                    Caption = '&Item Lines';
                    Image = Line;
                    ApplicationArea = All;
                    RunObject = page "GXL ASN Level 4 Line - Edit";
                    RunPageLink = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Level 3 Line No." = field("Line No.");
                }
            }
        }
    }
}

