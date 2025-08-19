page 50150 "GXL Bloyal Azure Log"
{
    Caption = 'Bloyal Azure Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Bloyal Azure Log";
    InsertAllowed = false;
    DeleteAllowed = true;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Batch ID"; Rec."Batch ID")
                {
                    ApplicationArea = All;
                }
                field("File Number"; Rec."File Number")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Web Service Name"; Rec."Web Service Name")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Start Entry No."; Rec."Start Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("End Entry No."; Rec."End Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Start Date Time Modified"; Rec."Start Date Time Modified")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("End Date Time Modified"; Rec."End Date Time Modified")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No. Of Records Sent"; Rec."No. Of Records Sent")
                {
                    ApplicationArea = All;
                }
                field("Sent Date Time"; Rec."Sent Date Time")
                {
                    ApplicationArea = All;
                }
                field("Sent by User"; Rec."Sent by User")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                // >> LCB-463
                field("Re-Submit to Bloyal"; Rec."Re-Submit to Bloyal")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                // << LCB-463
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
                field("Reset"; Rec.Reset)
                {
                    ApplicationArea = All;
                }
                field("Start Processed Date Time"; Rec."Start Processed Date Time")
                {
                    ApplicationArea = All;
                    Visible = false;
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