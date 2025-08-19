page 50162 "GXL ECS Promotion Subpage"
{
    Caption = 'ECS Promotion Lines';
    PageType = ListPart;
    SourceTable = "GXL ECS Promotion Line";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Unit Of Measure Code"; Rec."Unit Of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Discount Value 1"; Rec."Discount Value 1")
                {
                    ApplicationArea = All;
                }
                field("Discount Value 2"; Rec."Discount Value 2")
                {
                    ApplicationArea = All;
                }
                field("Discount Quantity"; Rec."Discount Quantity")
                {
                    ApplicationArea = All;
                }
                field("Deal Text 1"; Rec."Deal Text 1")
                {
                    ApplicationArea = All;
                }
                field("Deal Text 2"; Rec."Deal Text 2")
                {
                    ApplicationArea = All;
                }
                field("Deal Text 3"; Rec."Deal Text 3")
                {
                    ApplicationArea = All;
                }
                field("Default Size"; Rec."Default Size")
                {
                    ApplicationArea = All;
                }

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