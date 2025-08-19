page 50163 "GXL ECS Promotion Data"
{
    Caption = 'ECS Promotion Data';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL ECS Promotion Data";
    InsertAllowed = false;
    DeleteAllowed = false;

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
                field("ECS Event ID"; Rec."ECS Event ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Event Code"; Rec."Event Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Promotion Type"; Rec."Promotion Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Location Hierarchy Type"; Rec."Location Hierarchy Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Location Hierarchy Code"; Rec."Location Hierarchy Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("ECS Cluster UID"; Rec."ECS Cluster UID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit Of Measure Code"; Rec."Unit Of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Default Size"; Rec."Default Size")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Discount Value 1"; Rec."Discount Value 1")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Discount Value 2"; Rec."Discount Value 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Discount Quantity"; Rec."Discount Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Deal Text 1"; Rec."Deal Text 1")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Deal Text 2"; Rec."Deal Text 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Deal Text 3"; Rec."Deal Text 3")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("End Date"; Rec."End Date")
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