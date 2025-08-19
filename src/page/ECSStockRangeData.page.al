page 50165 "GXL ECS Stock Range Data"
{
    Caption = 'ECS Stock Range Data';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL ECS Stock Range Data";
    InsertAllowed = false;
    DeleteAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(UOM; Rec.UOM)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Stock on Hand"; Rec."Stock on Hand")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Ranged; Rec.Ranged)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Range Start Date"; Rec."Range Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Range End Date"; Rec."Range End Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Middleware Update Status"; Rec."Middleware Update Status")
                {
                    ApplicationArea = All;
                }
                field("Middleware Update Timestamp"; Rec."Middleware Update Timestamp")
                {
                    ApplicationArea = All;
                }
                field("Middleware Error"; Rec."Middleware Error")
                {
                    ApplicationArea = All;
                }
                field("Middleware Error Message"; Rec."Middleware Error Message")
                {
                    ApplicationArea = All;
                }

            }
        }
    }

    actions
    {
    }
}