page 50002 "GXL System Admin. Activities"
{
    Caption = 'Activities';
    PageType = CardPart;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "GXL Administration Cue";

    layout
    {
        area(content)
        {
            cuegroup(JobQueueEntries)
            {
                Caption = 'Job Queue Entries';
                field("Job Queue Entries Until Today"; Rec."Job Queue Entries Until Today")
                {
                    ApplicationArea = All;
                }
                field("Job Queue Entries - Ready"; Rec."Job Queue Entries - Ready")
                {
                    ApplicationArea = All;
                }
                field("Job Queue Entries - InProcess"; Rec."Job Queue Entries - InProcess")
                {
                    ApplicationArea = All;
                }
                field("Job Queue Entries - Error"; Rec."Job Queue Entries - Error")
                {
                    ApplicationArea = All;
                }
                field("Job Queue Entries - OnHold"; Rec."Job Queue Entries - OnHold")
                {
                    ApplicationArea = All;
                }
                field("Job Queue Entries - Finished"; Rec."Job Queue Entries - Finished")
                {
                    ApplicationArea = All;
                }
                field("Job Queue Entries - OnHold T/O"; Rec."Job Queue Entries - OnHold T/O")
                {
                    ApplicationArea = All;
                }
            }
            cuegroup(MagentoWebOrder)
            {
                Caption = 'Magento Web Orders';
                field("Magento Web Order Entries"; Rec."Magento Web Order Entries")
                {
                    ApplicationArea = All;
                }
                field("Magento WO Entries - Error"; Rec."Magento WO Entries - Error")
                {
                    ApplicationArea = All;
                }
            }
            cuegroup(MyActivities)
            {
                Caption = 'My Activities';
                field("Pending User Tasks"; UserTaskManagement.GetMyPendingUserTasksCount())
                {
                    ApplicationArea = All;
                    Caption = 'Pending User Tasks';
                    Image = Checklist;
                    ToolTip = 'Specifies the number of pending tasks that are assigned to you or to a group that you are a member of.';

                    trigger OnDrillDown()
                    var
                        UserTaskList: Page "User Task List";
                    begin
                        UserTaskList.SetPageToShowMyPendingUserTasks();
                        UserTaskList.Run();
                    end;
                }
                field("Requests to Approve"; Rec."Requests to Approve")
                {
                    ApplicationArea = All;
                    DrillDownPageID = "Requests to Approve";
                    ToolTip = 'Specifies requests for certain documents, cards, or journal lines that you must approve for other users before they can proceed.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Up Cues")
            {
                ApplicationArea = All;
                Caption = 'Set Up Cues';
                Image = Setup;
                ToolTip = 'Set up the cues (status tiles) related to the role.';

                trigger OnAction()
                var
                    CueRecordRef: RecordRef;
                begin
                    CueRecordRef.GetTable(Rec);
                    CueSetup.OpenCustomizePageForCurrentUser(CueRecordRef.Number());
                end;
            }
        }
    }

    trigger OnOpenPage()
    var
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;

        Rec.SetFilter("Date Filter2", '<=%1', CreateDateTime(Today(), 0T));
        Rec.SetFilter("Date Filter3", '>%1', CreateDateTime(Today(), 0T));
        Rec.SetFilter("User ID Filter", UserId());
    end;

    var
        UserTaskManagement: Codeunit "User Task Management";
        // >> Upgrade
        //CueSetup: Codeunit "Cue Setup";
        CueSetup: Codeunit "Cues And KPIs";
    // << Upgrade
}

