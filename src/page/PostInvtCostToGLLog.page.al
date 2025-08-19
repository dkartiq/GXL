/// <summary>
/// ERP-270 - CR104 - Performance improvement post cost to G/L
/// </summary>
page 50044 "GXL PostInvtCostToGL Log"
{
    Caption = 'Post Inventory Cost to G/L Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL PostInvtCostToGL Log";
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                Editable = false;
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("From Value Entry No."; Rec."From Value Entry No.")
                {
                    ApplicationArea = All;
                }
                field("To Value Entry No."; Rec."To Value Entry No.")
                {
                    ApplicationArea = All;
                }
                field(Errored; Rec.Errored)
                {
                    ApplicationArea = All;
                }
                field("Message"; Rec.Message)
                {
                    ApplicationArea = All;
                }
                field("Start Date Time"; Rec."Start Date Time")
                {
                    ApplicationArea = All;
                }
                field("End Date Time"; Rec."End Date Time")
                {
                    ApplicationArea = All;
                }
                field("User ID"; Rec."User ID")
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