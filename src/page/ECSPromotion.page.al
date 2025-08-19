page 50161 "GXL ECS Promotion"
{
    Caption = 'ECS Promotion';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "GXL ECS Promotion Header";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Event Code"; Rec."Event Code")
                {
                    ApplicationArea = All;
                }
                field("Event Name"; Rec."Event Name")
                {
                    ApplicationArea = All;
                }
                field("ECS Event ID"; Rec."ECS Event ID")
                {
                    ApplicationArea = All;
                }
                field("Promotion Type"; Rec."Promotion Type")
                {
                    ApplicationArea = All;
                }
                field("Location Hierarchy Type"; Rec."Location Hierarchy Type")
                {
                    ApplicationArea = All;
                }
                field("Location Hierarchy Code"; Rec."Location Hierarchy Code")
                {
                    ApplicationArea = All;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = All;
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = All;
                }
                field("Event Status"; Rec."Event Status")
                {
                    ApplicationArea = All;
                }
            }
            part(PromotionLines; "GXL ECS Promotion Subpage")
            {
                ApplicationArea = All;
                SubPageLink = "ECS Event ID" = field("ECS Event ID");
                Caption = 'Lines';
            }
        }
    }

    actions
    {
        area(Processing)
        {
        }
    }

    var
}