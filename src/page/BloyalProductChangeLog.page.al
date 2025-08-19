page 50026 "GXL Bloyal Product Change Log"
{
    Caption = 'Bloyal Product Change Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Bloyal Product Change Log";
    InsertAllowed = false;
    ModifyAllowed = false;

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
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Log Date Time"; Rec."Log Date Time")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Processed; Rec.IsProcessed())
                {
                    Caption = 'Processed';
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

}