page 50110 "GXL SOH Staging Data Log"
{
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    Caption = 'SOH Staging Data Log';
    SourceTable = "GXL SOH Staging Data";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Batch ID"; Rec."Batch ID")
                { ApplicationArea = All; }
                field("Auto ID"; Rec."Auto ID")
                { ApplicationArea = All; }
                field("Log Date"; Rec."Log Date")
                { ApplicationArea = All; }
                field("Log Time"; Rec."Log Time")
                { ApplicationArea = All; }
                field("Store Code"; Rec."Store Code")
                { ApplicationArea = All; }
                field("Location Code"; Rec."Location Code")
                { ApplicationArea = All; }
                field("Legacy Item No."; Rec."Legacy Item No.")
                { ApplicationArea = All; }
                field("New Qty."; Rec."New Qty.")
                { ApplicationArea = All; }
                field("Commited Qty."; Rec."Commited Qty.")
                { ApplicationArea = All; }
                field("Item No."; Rec."Item No.")
                { ApplicationArea = All; }
                field(UOM; Rec.UOM)
                { ApplicationArea = All; }
                field("Base SOH"; Rec."Base SOH")
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

