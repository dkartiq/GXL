//CR050: PS-1948 External stocktake
page 50025 "GXL External Stocktake Lines"
{
    Caption = 'External Stocktake Lines';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL External Stocktake Line";
    Editable = false;
    LinksAllowed = false;
    ShowFilter = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Batch ID"; Rec."Batch ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Process Status"; Rec."Process Status")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Legacy Item No."; Rec."Legacy Item No.")
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
                field("Qty. Calculated (Base)"; Rec."Qty. Calculated (Base)")
                {
                    ApplicationArea = All;
                }
                field("Qty. (Phys. Inventory)"; Rec."Qty. (Phys. Inventory)")
                {
                    ApplicationArea = All;
                }
                field("Qty. Phys. Inventory (Base)"; Rec."Qty. Phys. Inventory (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
                field("Processed Date Time"; Rec."Processed Date Time")
                {
                    ApplicationArea = All;
                }
                field("Processed by User"; Rec."Processed by User")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ResetErrors)
            {
                Caption = 'Reset Errors';
                Image = ResetStatus;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ExtStocktakeLine: Record "GXL External Stocktake Line";
                begin
                    CurrPage.SetSelectionFilter(ExtStocktakeLine);
                    Rec.ResetError(ExtStocktakeLine);
                    CurrPage.Update(false);
                end;
            }
        }
    }
}