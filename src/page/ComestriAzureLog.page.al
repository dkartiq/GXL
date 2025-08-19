page 50480 "GXL Comestri Azure Log"
{
    /* Change Log
        WRP-287 2020-09-18 LP
            Remove Rest flag and other fields are not applicable as Comestri is a full feed data extract
    */

    Caption = 'Comestri Azure Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Comestri Azure Log";
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
                //WRP-287
                /*
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
                */
                //WRP-287
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
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
                //WRP-287
                /*
                field("Reset"; Reset)
                {
                    ApplicationArea = All;
                }
                */
                //WRP-287
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