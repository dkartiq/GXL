codeunit 50030 "GXL GL History Batch-Post JQ"
{
    /*Change Log
        ERP-204 GL History Batches
    */

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        GLHistoryBatch: Record "GXL GL History Batch";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
    begin
        Rec.TestField("Record ID to Process");
        RecRef.Get(Rec."Record ID to Process");
        RecRef.SetTable(GLHistoryBatch);
        GLHistoryBatch.Find();

        BatchProcessingMgt.GetBatchFromSession(Rec."Record ID to Process", Rec."User Session ID");
        SetJobQueueStatus(GLHistoryBatch, GLHistoryBatch."Job Queue Status"::Posting, CurrentDateTime(), 0DT);
        if not Codeunit.Run(Codeunit::"GXL GL History Batch-Post", GLHistoryBatch) then begin
            SetJobQueueStatus(GLHistoryBatch, GLHistoryBatch."Job Queue Status"::Error, 0DT, CurrentDateTime());
            BatchProcessingMgt.ResetBatchID();
            Error(GetLastErrorText());
        end;
        BatchProcessingMgt.ResetBatchID();
        SetJobQueueStatus(GLHistoryBatch, GLHistoryBatch."Job Queue Status"::Completed, 0DT, CurrentDateTime());
    end;


    var
        WrongJobQueueStatusErr: Label '%1 cannot be posted because it has already been scheduled for posting. Choose the Remove from Job Queue action to reset the job queue status and then post again.';
        JobQueueCompletedErr: Label '%1 has been completed posting';

    local procedure SetJobQueueStatus(var GLHistoryBatch: Record "GXL GL History Batch"; NewStatus: Option; StartDT: DateTime; EndDT: DateTime)
    var
    begin
        GLHistoryBatch.LockTable();
        if GLHistoryBatch.Find() then begin
            GLHistoryBatch."Job Queue Status" := NewStatus;
            if StartDT <> 0DT then
                GLHistoryBatch."Job Queue Start Date Time" := StartDT;
            if EndDT <> 0DT then
                GLHistoryBatch."Job Queue End Date Time" := EndDT;
            GLHistoryBatch.Modify();
        end;
        Commit();
    end;

    procedure EnqueueGLHistoryBatch(var GLHistoryBatch: Record "GXL GL History Batch")
    begin
        if not (GLHistoryBatch."Job Queue Status" in [GLHistoryBatch."Job Queue Status"::" ", GLHistoryBatch."Job Queue Status"::Error, GLHistoryBatch."Job Queue Status"::Completed]) then
            Error(WrongJobQueueStatusErr, GLHistoryBatch."Batch ID");
        if GLHistoryBatch."Job Queue Status" = GLHistoryBatch."Job Queue Status"::Completed then begin
            GLHistoryBatch.CalcFields(GLHistoryBatch."Open Exists");
            if not GLHistoryBatch."Open Exists" then
                Error(JobQueueCompletedErr, GLHistoryBatch."Batch ID");
        end;
        GLHistoryBatch."Job Queue Status" := GLHistoryBatch."Job Queue Status"::"Scheduled for Posting";
        GLHistoryBatch."Job Queue Entry ID" := EnqueueJobEntry(GLHistoryBatch);
        GLHistoryBatch.Modify();

    end;

    local procedure EnqueueJobEntry(GLHistoryBatch: Record "GXL GL History Batch"): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        Clear(JobQueueEntry.ID);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"GXL GL History Batch-Post JQ";
        JobQueueEntry.Description := 'Batch Post G/L History';
        JobQueueEntry."Record ID to Process" := GLHistoryBatch.RecordId();
        JobQueueEntry."User Session ID" := SessionId();
        CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
        exit(JobQueueEntry.ID);

    end;


    procedure CancelQueueEntry(var GLHistoryBatch: Record "GXL GL History Batch")
    begin
        IF not (GLHistoryBatch."Job Queue Status" in [GLHistoryBatch."Job Queue Status"::" ", GLHistoryBatch."Job Queue Status"::Completed]) THEN BEGIN
            DeleteJobs(GLHistoryBatch);
            GLHistoryBatch."Job Queue Status" := GLHistoryBatch."Job Queue Status"::" ";
            GLHistoryBatch.Modify();
        END;
    end;

    local procedure DeleteJobs(GLHistoryBatch: Record "GXL GL History Batch")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not IsNullGuid(GLHistoryBatch."Job Queue Entry ID") then
            JobQueueEntry.SetRange(ID, GLHistoryBatch."Job Queue Entry ID");
        JobQueueEntry.SETRANGE("Record ID to Process", GLHistoryBatch.RecordId());
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll(true);

    end;

}