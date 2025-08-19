/// <summary>
/// CR099 - Revaluation Journal Batch
/// </summary>
page 50041 "GXL Item Reval. Worksheets"
{
    ApplicationArea = All;
    Caption = 'Item Revaluation Worksheets';
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Worksheet,Job Queue';
    ShowFilter = true;
    SourceTable = "GXL Item Reval. Wksh. Batch";
    SourceTableView = SORTING("Batch ID")
                      ORDER(Descending);
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = "Job Queue Status";
                field("Batch ID"; Rec."Batch ID")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowWorksheetLines();
                    end;
                }
                field("Imported Date Time"; Rec."Imported Date Time")
                {
                    ApplicationArea = All;
                }
                field("Job Queue Status"; Rec."Job Queue Status")
                {
                    ApplicationArea = All;
                    StyleExpr = StatusStyleTxt;
                }
                field("No. of Lines"; Rec."No. of Lines")
                {
                    ApplicationArea = All;
                }
                field("Value Calc. Errors"; Rec."Value Calc. Errors")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field("Value Calculated Lines"; Rec."Value Calculated Lines")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Calculated Revalue Amt."; Rec."Calculated Revalue Amt.")
                {
                    ApplicationArea = All;
                }
                field("Posting Errors"; Rec."Posting Errors")
                {
                    ApplicationArea = All;
                    Style = Unfavorable;
                    StyleExpr = TRUE;
                }
                field("Posted Lines"; Rec."Posted Lines")
                {
                    ApplicationArea = All;
                }
                field("Posted Revalue Amt."; Rec."Posted Revalue Amt.")
                {
                    ApplicationArea = All;
                }
                field("Imported by User ID"; Rec."Imported by User ID")
                {
                    ApplicationArea = All;
                }
                field("Job Queue Start Date Time"; Rec."Job Queue Start Date Time")
                {
                    ApplicationArea = All;
                }
                field("Stop Job Queue At"; Rec."Stop Job Queue At")
                {
                    ApplicationArea = All;
                }
                field("Job Queue End Date Time"; Rec."Job Queue End Date Time")
                {
                    ApplicationArea = All;
                }
                field("Imported Lines"; Rec."Imported Lines")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ImportWorksheet)
            {
                ApplicationArea = All;
                Caption = 'Import New Worksheet';
                Ellipsis = true;
                Image = ImportExcel;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    GXLImportItemRevalWksh: Report "GXL Import Item Reval. Wksh.";
                    NewBatchID: Integer;
                begin
                    GXLImportItemRevalWksh.RunModal();
                    NewBatchID := GXLImportItemRevalWksh.GetNewBatchID();
                    if NewBatchID <> 0 then begin
                        if Rec.Get(NewBatchID) then
                            CurrPage.Update(false);
                    end;
                end;
            }
            action(CalculateInventoryValue)
            {
                ApplicationArea = All;
                Caption = 'Calculate Worksheet Inventory Values';
                Ellipsis = true;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                var
                    GXLCalcWkshInvtValue: Report "GXL Calc. Wksh. Invt. Value";
                begin
                    if (Rec."Batch ID" <> 0) then begin
                        if (Rec."Job Queue Status" in [Rec."Job Queue Status"::"Scheduled for Posting", Rec."Job Queue Status"::Posting]) then
                            Rec.FieldError("Job Queue Status");

                        GXLCalcWkshInvtValue.InitializeRequest(Rec."Batch ID", false);
                        GXLCalcWkshInvtValue.RunModal();
                    end;
                end;
            }
            action(SendToPosting)
            {
                ApplicationArea = All;
                Caption = 'Send to Background Posting';
                Image = PostBatch;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.SendToPosting();
                    CurrPage.Update(false);
                end;
            }
            action(CancelBackgroudPosting)
            {
                ApplicationArea = All;
                Caption = 'Remove/Reset Job Queue Status';
                Image = RemoveLine;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.CancelBackgroundPosting();
                end;
            }
            action(ShowJQErrorLog)
            {
                ApplicationArea = All;
                Caption = 'Show Last Job Queue Error';
                Image = Error;
                Promoted = true;
                PromotedCategory = Category5;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.ShowLastJobQueueError();
                end;
            }
        }
        area(navigation)
        {
            action(ShowWorksheetLines)
            {
                ApplicationArea = All;
                Caption = 'Worksheet Lines';
                Image = ItemLines;
                Promoted = true;
                PromotedCategory = Category4;
                PromotedIsBig = true;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.ShowWorksheetLines();
                end;
            }
            action(ShowLocLines)
            {
                ApplicationArea = All;
                Caption = 'Worksheet Location Lines';
                Image = Line;

                trigger OnAction()
                begin
                    Rec.ShowWorksheetLocLines();
                end;
            }

        }
    }

    trigger OnAfterGetRecord()
    begin
        StatusStyleTxt := Rec.GetStatusStyleTxt();
    end;

    trigger OnOpenPage()
    begin
        if Rec.GetFilters() = '' then
            if Rec.FindFirst() then;
    end;

    var
        StatusStyleTxt: Text;
}

