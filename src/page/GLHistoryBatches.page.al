page 50037 "GXL GL History Batches"
{
    /*Change Log
        ERP-204 GL History Batches
    */

    Caption = 'G/L History Batches';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL GL History Batch";
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Batch ID"; Rec."Batch ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Stop Job Queue At"; Rec."Stop Job Queue At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the time the batch posting via job queue will be stopped if it does not complete.';
                }
                field("Job Queue Status"; Rec."Job Queue Status")
                {
                    ApplicationArea = All;
                }
                field("Job Queue Start Date Time"; Rec."Job Queue Start Date Time")
                {
                    ApplicationArea = All;
                }
                field("Job Queue End Date Time"; Rec."Job Queue End Date Time")
                {
                    ApplicationArea = All;
                }
                field("No. of Entries"; Rec."No. of Entries")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("No. of Open Entries"; Rec."No. of Open Entries")
                {
                    ApplicationArea = All;
                }
                field("No. of Error Entries"; Rec."No. of Error Entries")
                {
                    ApplicationArea = All;
                }
                field("Imported Date Time"; Rec."Imported Date Time")
                {
                    ApplicationArea = All;
                }
                field("Imported by User ID"; Rec."Imported by User ID")
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
            action(ImportOpenBalance)
            {
                ApplicationArea = All;
                Caption = 'Import G/L History';
                ToolTip = 'Import G/L history from CSV file';
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    ImportGLHistoy: XmlPort "GXL GL History Import";
                begin
                    ImportGLHistoy.Run();
                end;
            }
            action(ProcessJounralBatch)
            {
                ApplicationArea = All;
                Caption = 'Send to Background Posting';
                ToolTip = 'Send to Background Posting';
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.SendToPosting();
                    CurrPage.Update(false);
                end;
            }
            action(RemoveFromJobQueue)
            {
                ApplicationArea = All;
                Caption = 'Remove/Reset Job Queue Status';
                ToolTip = 'Remove or reset the scheduled processing of this record from the job queue.';
                Image = RemoveLine;

                trigger OnAction()
                begin
                    Rec.CancelBackgroudPosting();
                end;
            }
            action(ShowJQErrorLog)
            {
                ApplicationArea = All;
                Caption = 'Show Last Job Queue Error';
                Image = Error;

                trigger OnAction()
                var
                    JobQueueLogEntry: Record "Job Queue Log Entry";
                begin
                    if Rec."Job Queue Status" <> Rec."Job Queue Status"::Error then
                        exit;

                    JobQueueLogEntry.SetCurrentKey(Id, Status);
                    JobQueueLogEntry.SetRange(ID, Rec."Job Queue Entry ID");
                    JobQueueLogEntry.SetRange(Status, JobQueueLogEntry.Status::Error);
                    if JobQueueLogEntry.FindLast() then
                        JobQueueLogEntry.ShowErrorMessage();
                end;
            }
        }
        area(Navigation)
        {
            action(ShowGLHistoryLines)
            {
                ApplicationArea = All;
                Caption = 'G/L History Lines';
                ToolTip = 'Show G/L History Lines belong to the batch';
                Image = ItemLines;

                trigger OnAction()
                var
                    GLHistoryLine: Record "GXL GL History Line";
                begin
                    GLHistoryLine.SetRange("Batch ID", Rec."Batch ID");
                    Page.RunModal(0, GLHistoryLine);
                end;
            }
        }
    }

    var
}