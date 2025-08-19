/// <summary>
/// CR100-BatchAdjustCostItems
/// </summary>
page 50040 "GXL Adjust Cost Item Log"
{
    Caption = 'Adjust Cost Item Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Adjust Cost Item Log";
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
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Item No. Filter"; Rec."Item No. Filter")
                {
                    ApplicationArea = All;
                    Visible = false;
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