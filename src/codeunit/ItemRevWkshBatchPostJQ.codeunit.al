/// <summary>
/// CR099 - Revaluation Journal Batch
/// </summary>
codeunit 50043 "GXL Item Rev.Wksh.Batch-PostJQ"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        RevalWkshBatch: Record "GXL Item Reval. Wksh. Batch";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
    begin
        Rec.Testfield("Record ID to Process");
        RecRef.Get(Rec."Record ID to Process");
        RecRef.SetTable(RevalWkshBatch);
        RevalWkshBatch.Find();

        BatchProcessingMgt.GetBatchFromSession(Rec."Record ID to Process", Rec."User Session ID");
        SetJobQueueStatus(RevalWkshBatch, RevalWkshBatch."Job Queue Status"::Posting, CurrentDateTime(), 0DT);
        if not Codeunit.Run(Codeunit::"GXL Item Rev.Wksh.Batch-Post", RevalWkshBatch) then begin
            SetJobQueueStatus(RevalWkshBatch, RevalWkshBatch."Job Queue Status"::Error, 0DT, CurrentDateTime());
            BatchProcessingMgt.ResetBatchID();
            Error(GetLastErrorText());
        end;
        BatchProcessingMgt.ResetBatchID();
        SetJobQueueStatus(RevalWkshBatch, RevalWkshBatch."Job Queue Status"::Completed, 0DT, CurrentDateTime());
    end;


    var
        WrongJobQueueStatusErr: Label '%1 cannot be posted because it has already been scheduled for posting. Choose the Remove from Job Queue action to reset the job queue status and then post again.';
        JobQueueCompletedErr: Label '%1 has been completed posting';

    local procedure SetJobQueueStatus(var RevalWkshBatch: Record "GXL Item Reval. Wksh. Batch"; NewStatus: Option; StartDT: DateTime; EndDT: DateTime)
    var
    begin
        RevalWkshBatch.LockTable();
        if RevalWkshBatch.Find() then begin
            RevalWkshBatch."Job Queue Status" := NewStatus;
            if StartDT <> 0DT then
                RevalWkshBatch."Job Queue Start Date Time" := StartDT;
            if EndDT <> 0DT then
                RevalWkshBatch."Job Queue End Date Time" := EndDT;
            RevalWkshBatch.Modify();
        end;
        Commit();
    end;

    procedure EnqueueRevalWkshBatch(var RevalWkshBatch: Record "GXL Item Reval. Wksh. Batch")
    begin
        if not (RevalWkshBatch."Job Queue Status" in [RevalWkshBatch."Job Queue Status"::"Not Scheduled", RevalWkshBatch."Job Queue Status"::Error, RevalWkshBatch."Job Queue Status"::Completed]) then
            Error(WrongJobQueueStatusErr, RevalWkshBatch."Batch ID");
        if RevalWkshBatch."Job Queue Status" = RevalWkshBatch."Job Queue Status"::Completed then begin
            RevalWkshBatch.CalcFields("No. of Lines", "Posted Lines");
            if (RevalWkshBatch."No. of Lines" = RevalWkshBatch."Posted Lines") then
                Error(JobQueueCompletedErr, RevalWkshBatch."Batch ID");
        end;
        RevalWkshBatch."Job Queue Status" := RevalWkshBatch."Job Queue Status"::"Scheduled for Posting";
        RevalWkshBatch."Job Queue Entry ID" := EnqueueJobEntry(RevalWkshBatch);
        RevalWkshBatch.Modify();
    end;

    local procedure EnqueueJobEntry(RevalWkshBatch: Record "GXL Item Reval. Wksh. Batch"): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        Clear(JobQueueEntry.ID);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"GXL Item Rev.Wksh.Batch-PostJQ";
        JobQueueEntry.Description := StrSubstNo('Batch Post Item Revaluation Wksh. %1', RevalWkshBatch."Batch ID");
        JobQueueEntry."Record ID to Process" := RevalWkshBatch.RecordId();
        JobQueueEntry."User Session ID" := SessionId();
        CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
        exit(JobQueueEntry.ID);
    end;


    procedure CancelQueueEntry(var RevalWkshBatch: Record "GXL Item Reval. Wksh. Batch")
    begin
        IF not (RevalWkshBatch."Job Queue Status" in [RevalWkshBatch."Job Queue Status"::"Not Scheduled", RevalWkshBatch."Job Queue Status"::Completed]) THEN BEGIN
            DeleteJobs(RevalWkshBatch);
            RevalWkshBatch."Job Queue Status" := RevalWkshBatch."Job Queue Status"::"Not Scheduled";
            RevalWkshBatch.Modify();
        END;
    end;

    local procedure DeleteJobs(RevalWkshBatch: Record "GXL Item Reval. Wksh. Batch")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not IsNullGuid(RevalWkshBatch."Job Queue Entry ID") then
            JobQueueEntry.SetRange(ID, RevalWkshBatch."Job Queue Entry ID");
        JobQueueEntry.SETRANGE("Record ID to Process", RevalWkshBatch.RecordId());
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll(true);
    end;
}