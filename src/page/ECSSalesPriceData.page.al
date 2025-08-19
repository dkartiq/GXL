page 50164 "GXL ECS Sales Price Data"
{
    Caption = 'ECS Sales Price Data';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL ECS Sales Price Data";
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
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Active RRP"; Rec."Active RRP")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Price Start Date"; Rec."Price Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Price End Date"; Rec."Price End Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Offer Type"; Rec."Offer Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Price Type"; Rec."Price Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Ticket Quantity"; Rec."Ticket Quantity")
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