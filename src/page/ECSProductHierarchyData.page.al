page 50154 "GXL ECS Product Hierarchy Data"
{
    Caption = 'ECS Product Hierarchy Data';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL ECS Prod. Hierarchy Data";
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
                field("Request ID"; Rec."Request ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Message Type"; Rec."Message Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Hierarchy Parent Type"; Rec."Hierarchy Parent Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Hierarchy Parent Value Code"; Rec."Hierarchy Parent Value Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Hierarchy Child Type"; Rec."Hierarchy Child Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Hierarchy Child Value Code"; Rec."Hierarchy Child Value Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Hierarchy Child Description"; Rec."Hierarchy Child Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
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