page 50015 "GXL Lead Time Setup"
{
    Caption = 'Lead Time Setup';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Lead Time";
    DelayedInsert = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("From Type"; Rec."From Type")
                {
                    ApplicationArea = All;
                }
                field("From Code"; Rec."From Code")
                {
                    ApplicationArea = All;
                }
                field("To Type"; Rec."To Type")
                {
                    ApplicationArea = All;
                }
                field("To Code"; Rec."To Code")
                {
                    ApplicationArea = All;
                }
                field("Lead Time Type"; Rec."Lead Time Type")
                {
                    ApplicationArea = All;
                }
                field("Lead Time"; Rec."Lead Time")
                {
                    ApplicationArea = All;
                }
                field("Last Date Modified"; Rec."Last Date Modified")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

}