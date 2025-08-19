page 50153 "GXL ECS Cluster Store Data"
{
    Caption = 'ECS Cluster Store Data';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL ECS Store Data";
    SourceTableView = sorting(Entity) where(Entity = filter(StoreCluster));
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
                field("Store Group Code"; Rec."Store Group Code")
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