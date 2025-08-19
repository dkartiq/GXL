/// <summary>
/// CR099 - Revaluation Journal Batch
/// </summary>
page 50043 "GXL Item Reval. Wksh Loc Lines"
{
    Caption = 'Item Revaluation Wksh. Location Lines';
    DataCaptionFields = "Batch ID";
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    ShowFilter = true;
    SourceTable = "GXL Item Reval. Wksh. Loc Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = Amount;
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleTxt;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Unit Cost (Revalued)"; Rec."Unit Cost (Revalued)")
                {
                    ApplicationArea = All;
                }
                field("Unit Cost (Calculated)"; Rec."Unit Cost (Calculated)")
                {
                    ApplicationArea = All;
                }
                field("Inventory Value (Revalued)"; Rec."Inventory Value (Revalued)")
                {
                    ApplicationArea = All;
                }
                field("Inventory Value (Calculated)"; Rec."Inventory Value (Calculated)")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Batch ID"; Rec."Batch ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Wksh. Line No."; Rec."Wksh. Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
    end;

    trigger OnOpenPage()
    begin
    end;

    var
        StatusStyleTxt: Text;
}

