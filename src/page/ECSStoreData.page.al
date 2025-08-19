page 50151 "GXL ECS Store Data"
{
    Caption = 'ECS Store Data';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL ECS Store Data";
    SourceTableView = sorting(Entity) where(Entity = filter(Store));
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
                field("Action"; Rec.Action)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store Name"; Rec."Store Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store Address"; Rec."Store Address")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store Address 2"; Rec."Store Address 2")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store City"; Rec."Store City")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store Post Code"; Rec."Store Post Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store Country/Region Code"; Rec."Store Country/Region Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store Region Name"; Rec."Store Region Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store Open Date"; Rec."Store Open Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store CLosed Date"; Rec."Store CLosed Date")
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