page 50160 "GXL ECS Promotions"
{
    Caption = 'ECS Promotions';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL ECS Promotion Header";
    SourceTableView = sorting("ECS Event ID");
    CardPageId = "GXL ECS Promotion";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("ECS Event ID"; Rec."ECS Event ID")
                {
                    ApplicationArea = All;
                }
                field("Event Code"; Rec."Event Code")
                {
                    ApplicationArea = All;
                }
                field("Event Name"; Rec."Event Name")
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
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(ImportPromotions)
            {
                Caption = 'Import Promotions';
                ApplicationArea = All;
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Xmlport.Run(Xmlport::"GXL ECS Import Promotions");
                end;
            }
            action(ActivatePromotions)
            {
                Caption = 'Activate Promotions for ECS';
                ApplicationArea = All;
                Image = ReleaseDoc;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ECSWSFMgt: Codeunit "GXL ECS WSF Management";
                begin
                    ECSWSFMgt.LogPromotionUpdate();
                end;
            }
        }
    }
}