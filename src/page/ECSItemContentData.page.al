page 50155 "GXL ECS Item Content Data"
{
    Caption = 'ECS Item Content Data';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL ECS Item Data";
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
                field("Unique ID 1 ECS Field Value"; Rec."Unique ID 1 ECS Field Value")
                {
                    Caption = 'Item No.';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unique ID 2 ECS Field Value"; Rec."Unique ID 2 ECS Field Value")
                {
                    Caption = 'UOM';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("ECS Field Name"; Rec."ECS Field Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Field Value"; Rec."Field Value")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Print Ticket"; Rec."Print Ticket")
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

    trigger OnOpenPage()
    begin
    end;

    var
}