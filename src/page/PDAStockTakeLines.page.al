page 50264 "GXL PDA Stocktake Lines"
{
    Caption = 'PDA Stocktake Lines';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL PDA StockTake Line";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Stock-Take ID"; Rec."Stock-Take ID")
                { ApplicationArea = All; }
                field("Line No."; Rec."Line No.")
                { ApplicationArea = All; }
                field("Item No."; Rec."Item No.")
                { ApplicationArea = All; }
                field("Item Description"; Rec."Item Description")
                { ApplicationArea = All; }
                field("Physical Quantity"; Rec."Physical Quantity")
                { ApplicationArea = All; }
                field(UOM; Rec.UOM)
                { ApplicationArea = All; }
                field("Unit Cost"; Rec."Unit Cost")
                { ApplicationArea = All; }
                field("Store Code"; Rec."Store Code")
                { ApplicationArea = All; }
                field(SOH; Rec.SOH)
                { ApplicationArea = All; }

            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
        }
    }
}