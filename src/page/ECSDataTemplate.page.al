page 50157 "GXL ECS Data Template"
{
    Caption = 'ECS Data Template';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "GXL ECS Data Template Header";
    RefreshOnActivate = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                }
                field("ECS WS Function"; Rec."ECS WS Function")
                {
                    ApplicationArea = All;
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                }
            }
            part("GXL ECS Data Template Subpage"; "GXL ECS Data Template Subpage")
            {
                SubPageLink = "ECS Data Template Code" = field(Code);
                ApplicationArea = All;
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

}