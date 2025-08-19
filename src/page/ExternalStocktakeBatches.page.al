//CR050: PS-1948 External stocktake
page 50024 "GXL External Stocktake Batches"
{
    Caption = 'External Stocktake Batches';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL External Stocktake Batch";
    Editable = false;

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
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
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
                Caption = 'Import External Stocktake';
                ToolTip = 'Import external stock take from excel file';
                Image = ImportExcel;
                trigger OnAction()
                var
                    ImportExtStocktakeFromExcel: Report "GXL ImportExtStocktakeFrExcel";
                begin
                    ImportExtStocktakeFromExcel.RunModal();
                end;
            }
            action(ProcessJounralBatch)
            {
                ApplicationArea = All;
                Caption = 'Send to Background Posting';
                ToolTip = 'Send to Background Posting';
                Image = PostBatch;

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
        }
        area(Navigation)
        {
            action(ShowExtStocktakeLineerLines)
            {
                ApplicationArea = All;
                Caption = 'External Stocktake Lines';
                ToolTip = 'Show External Stocktake Lines belong to the batch';
                Image = ItemLines;

                trigger OnAction()
                var
                    ExtStocktakeLine: Record "GXL External Stocktake Line";
                begin
                    ExtStocktakeLine.SetRange("Batch ID", Rec."Batch ID");
                    Page.RunModal(0, ExtStocktakeLine);
                end;
            }
        }
    }

    var
}