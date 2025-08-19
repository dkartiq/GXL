/// <summary>
/// ERP-270 - CR104 - Performance improvement post cost to G/L
/// Batch report to split posting into a defined number of records
/// </summary>
report 50022 "GXL Batch Post InvtCost to G/L"
{
    Caption = 'Batch Post Inventory Cost to G/L';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    AdditionalSearchTerms = 'reconcile inventory';
    ProcessingOnly = true;
    Permissions = tabledata "Job Queue Entry" = r, tabledata "Scheduled Task" = r, tabledata "GXL PostInvtCostToGL Log" = rmid;

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PostMethod; PostMethod)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Posting Method';
                        OptionCaption = 'Per Posting Group,Per Entry';
                        ToolTip = 'Specifies if the batch job tests the posting of inventory value to the general ledger per inventory posting group or per posted value entry. If you post per entry, you achieve a detailed specification of how the inventory affects the general ledger.';
                    }
                    field(DocumentNo; DocNo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Document No.';
                        ToolTip = 'Specifies the number of the document that is processed by the report or batch job.';
                    }
                    field(DateFilter; DateFilter)
                    {
                        ApplicationArea = All;
                        Caption = 'Date Filter';

                        trigger OnValidate()
                        var
                            PostValueEntryToGL: Record "Post Value Entry to G/L";
                        begin
                            TextMgt.MakeDateFilter(DateFilter);
                            PostValueEntryToGL.SetFilter("Posting Date", DateFilter);
                            DateFilter := PostValueEntryToGL.GetFilter("Posting Date");
                        end;
                    }
                }
            }
        }

    }

    var
        SupplyChainSetup: Record "GXL Supply Chain Setup";
        GlobalJobQueueEntry: Record "Job Queue Entry";
        PostInvtCostLog: Record "GXL PostInvtCostToGL Log";
        TextMgt: Codeunit "Filter Tokens";
        SetupRead: Boolean;
        Window: Dialog;
        DocNo: Code[20];
        PostMethod: Option "per Posting Group","per Entry";
        CommitPer: Integer;
        TotalRec: Integer;
        LastLogEntryNo: Integer;
        NoOfSuccessEntries: Integer;
        RunFromJQ: Boolean;
        StartDT: DateTime;
        DateFilter: Text;
        Text000: Label 'Please enter a %1 when posting %2.';
        Text001: Label 'Do not enter a %1 when posting %2.';
        Text012: Label 'per Posting Group,per Entry';


    trigger OnPreReport()
    var
        ScheduledTask: Record "Scheduled Task";
        JobQueueEntry: Record "Job Queue Entry";
        ItemValueEntry: Record "Value Entry";
    begin
        case PostMethod of
            PostMethod::"per Posting Group":
                if DocNo = '' then
                    Error(
                      Text000, ItemValueEntry.FieldCaption("Document No."), SelectStr(PostMethod + 1, Text012));
            PostMethod::"per Entry":
                if DocNo <> '' then
                    Error(
                      Text001, ItemValueEntry.FieldCaption("Document No."), SelectStr(PostMethod + 1, Text012));
        end;

        if GuiAllowed() then
            Window.Open(
                'Post Inventory Cost to G/L        \\' +
                'No. of Records Processed #1#######');

        RunFromJQ := false;
        if not GuiAllowed() then begin
            JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Report);
            JobQueueEntry.SetRange("Object ID to Run", Report::"GXL Batch Post InvtCost to G/L");
            JobQueueEntry.SetRange(Status, JobQueueEntry.Status::"In Process");
            if JobQueueEntry.FindFirst() then
                repeat
                    if ScheduledTask.Get(JobQueueEntry."System Task ID") then begin
                        RunFromJQ := true;
                        GlobalJobQueueEntry := JobQueueEntry;
                    end;
                until RunFromJQ or (JobQueueEntry.Next() = 0);
        end;

        RunCode();

        if GuiAllowed() then
            Window.Close();
    end;

    local procedure RunCode()
    var
        PostValueEntryToGL: Record "Post Value Entry to G/L";
        JobQueueEntry: Record "Job Queue Entry";
        LastValueEntryNo: Integer;
        FromEntryNo: Integer;
        ToEntryNo: Integer;
        ExitLoop: Boolean;
        Continue: Boolean;
        JQEndDT: DateTime;
        i: Integer;
    begin
        GetSetup();
        CommitPer := SupplyChainSetup."PostCostG/L - Commit per";
        StartDT := CurrentDateTime();
        NoOfSuccessEntries := 0;
        i := 0;

        PostValueEntryToGL.Reset();
        if DateFilter <> '' then
            PostValueEntryToGL.SetFilter("Posting Date", DateFilter);
        if PostValueEntryToGL.FindLast() then
            LastValueEntryNo := PostValueEntryToGL."Value Entry No."
        else
            exit;

        PostValueEntryToGL.SetFilter("Value Entry No.", '..%1', LastValueEntryNo);
        PostValueEntryToGL.FindFirst();
        Continue := true;
        while Continue do begin
            if RunFromJQ and (i <> 0) then begin
                if GlobalJobQueueEntry."Ending Time" <> 0T then begin
                    JQEndDT := CreateDateTime(Today, GlobalJobQueueEntry."Ending Time");
                    if GlobalJobQueueEntry."Earliest Start Date/Time" > JQEndDT then
                        JQEndDT := CreateDateTime(Today + 1, GlobalJobQueueEntry."Ending Time");
                    if JQEndDT <= CurrentDateTime() then
                        Continue := false;
                end;
            end;


            if Continue then begin
                FromEntryNo := PostValueEntryToGL."Value Entry No.";
                if CommitPer > 1 then begin
                    if PostValueEntryToGL.Next(CommitPer - 1) > 0 then
                        ToEntryNo := PostValueEntryToGL."Value Entry No."
                    else begin
                        ToEntryNo := LastValueEntryNo;
                        Continue := false;
                    end;
                end else
                    ToEntryNo := PostValueEntryToGL."Value Entry No.";
                ProcessPostInvtCostToGL(FromEntryNo, ToEntryNo);
                if PostValueEntryToGL.Next(1) <= 0 then
                    Continue := false;
            end;

            i += 1;
        end;

        Commit();
        LogSuccessEntry(NoOfSuccessEntries, StartDT);
        Commit();

    end;

    local procedure ProcessPostInvtCostToGL(FromEntryNo: Integer; ToEntryNo: Integer)
    var
        PostValueEntryToGL: Record "Post Value Entry to G/L";
        PostInvtCostToGL: Codeunit "GXL Post InvtCost to G/L";
        CurrStartDT: DateTime;
        NoOfRec: Integer;
        ProcessWasSuccess: Boolean;
        NewDocNo: Code[20];
        TempDocNo: Code[50];
    begin
        CurrStartDT := CurrentDateTime();
        Commit();
        Clear(PostInvtCostToGL);
        PostValueEntryToGL.Reset();
        PostValueEntryToGL.SetRange("Value Entry No.", FromEntryNo, ToEntryNo);
        if DateFilter <> '' then
            PostValueEntryToGL.SetFilter("Posting Date", DateFilter);

        NoOfRec := PostValueEntryToGL.Count;
        TotalRec := TotalRec + NoOfRec;
        if GuiAllowed() then
            Window.Update(1, TotalRec);

        NewDocNo := DocNo;
        if (NewDocNo <> '') and (StrPos(DocNo, '%1') <> 0) then begin
            TempDocNo := StrSubstNo(DocNo, Format(Today, 0, '<Year,2><Month,2><Day,2>'));
            if StrLen(TempDocNo) <= 20 then
                NewDocNo := TempDocNo;
        end;

        PostInvtCostToGL.SetProperties(PostMethod, NewDocNo);
        ProcessWasSuccess := PostInvtCostToGL.Run(PostValueEntryToGL);
        Commit();
        if not ProcessWasSuccess then
            LogErrorEntry(FromEntryNo, ToEntryNo, CurrStartDT, CopyStr(GetLastErrorText(), 1, 250))
        else
            NoOfSuccessEntries += NoOfRec;
    end;

    local procedure GetLastLogNo()
    begin
        PostInvtCostLog.LockTable();
        if PostInvtCostLog.FindLast() then
            LastLogEntryNo := PostInvtCostLog."Entry No.";
    end;

    local procedure LogErrorEntry(FrEntryNo: Integer; ToEntryNo: Integer; CurrStartDT: DateTime; ErrMsg: Text[250])
    begin
        GetLastLogNo();
        LastLogEntryNo += 1;
        PostInvtCostLog.Init();
        PostInvtCostLog."Entry No." := LastLogEntryNo;
        PostInvtCostLog."From Value Entry No." := FrEntryNo;
        PostInvtCostLog."To Value Entry No." := ToEntryNo;
        PostInvtCostLog.Errored := true;
        PostInvtCostLog.Message := ErrMsg;
        PostInvtCostLog."User ID" := UserId();
        PostInvtCostLog."Start Date Time" := CurrStartDT;
        PostInvtCostLog."End Date Time" := CurrentDateTime();
        PostInvtCostLog.Insert();
    end;

    local procedure LogSuccessEntry(NoOfEntries: Integer; CurrStartDT: DateTime)
    begin
        GetLastLogNo();
        LastLogEntryNo += 1;
        PostInvtCostLog.Init();
        PostInvtCostLog."Entry No." := LastLogEntryNo;
        PostInvtCostLog.Message := CopyStr(StrSubstNo('Total of %1 entries successfully processed', NoOfEntries), 1, 250);
        PostInvtCostLog."User ID" := UserId();
        PostInvtCostLog."Start Date Time" := CurrStartDT;
        PostInvtCostLog."End Date Time" := CurrentDateTime();
        PostInvtCostLog.Insert();
    end;

    local procedure GetSetup()
    begin
        if not SetupRead then begin
            SupplyChainSetup.Get();
            SupplyChainSetup.TestField("PostCostG/L - Commit per");
            SetupRead := true;
        end;
    end;

}