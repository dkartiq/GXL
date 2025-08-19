codeunit 50014 "GXL ItemJnlBuffBatch-Post JQ"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        ItemJnlBuffBatch: Record "GXL Item Jnl. Buffer Batch";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
    begin
        Rec.TestField("Record ID to Process");
        RecRef.Get(Rec."Record ID to Process");
        RecRef.SetTable(ItemJnlBuffBatch);
        ItemJnlBuffBatch.Find();

        BatchProcessingMgt.GetBatchFromSession(Rec."Record ID to Process", Rec."User Session ID");
        SetJobQueueStatus(ItemJnlBuffBatch, ItemJnlBuffBatch."Job Queue Status"::Posting, CurrentDateTime(), 0DT);
        if not Codeunit.Run(Codeunit::"GXL ItemJnlBuffBatch-Post", ItemJnlBuffBatch) then begin
            SetJobQueueStatus(ItemJnlBuffBatch, ItemJnlBuffBatch."Job Queue Status"::Error, 0DT, CurrentDateTime());
            BatchProcessingMgt.ResetBatchID();
            Error(GetLastErrorText());
        end;
        BatchProcessingMgt.ResetBatchID();
        SetJobQueueStatus(ItemJnlBuffBatch, ItemJnlBuffBatch."Job Queue Status"::Completed, 0DT, CurrentDateTime());
    end;


    var
        WrongJobQueueStatusErr: Label '%1 cannot be posted because it has already been scheduled for posting. Choose the Remove from Job Queue action to reset the job queue status and then post again.';

    local procedure SetJobQueueStatus(var ItemJnlBuffBatch: Record "GXL Item Jnl. Buffer Batch"; NewStatus: Option; StartDT: DateTime; EndDT: DateTime)
    var
    begin
        ItemJnlBuffBatch.LockTable();
        if ItemJnlBuffBatch.Find() then begin
            ItemJnlBuffBatch."Job Queue Status" := NewStatus;
            if StartDT <> 0DT then
                ItemJnlBuffBatch."Job Queue Start Date Time" := StartDT;
            if EndDT <> 0DT then
                ItemJnlBuffBatch."Job Queue End Date Time" := EndDT;
            ItemJnlBuffBatch.Modify();
        end;
        Commit();
    end;

    procedure EnqueueItemJnlBufferBatch(var ItemJnlBuffBatch: Record "GXL Item Jnl. Buffer Batch")
    begin
        if not (ItemJnlBuffBatch."Job Queue Status" in [ItemJnlBuffBatch."Job Queue Status"::" ", ItemJnlBuffBatch."Job Queue Status"::Error, ItemJnlBuffBatch."Job Queue Status"::Completed]) then
            Error(WrongJobQueueStatusErr, ItemJnlBuffBatch."Batch ID");
        if ItemJnlBuffBatch."Job Queue Status" = ItemJnlBuffBatch."Job Queue Status"::Completed then begin
            ItemJnlBuffBatch.CalcFields("Open Exists");
            if not ItemJnlBuffBatch."Open Exists" then
                Error(WrongJobQueueStatusErr, ItemJnlBuffBatch."Batch ID");
        end;
        ItemJnlBuffBatch."Job Queue Status" := ItemJnlBuffBatch."Job Queue Status"::"Scheduled for Posting";
        ItemJnlBuffBatch."Job Queue Entry ID" := EnqueueJobEntry(ItemJnlBuffBatch);
        ItemJnlBuffBatch.Modify();
    end;

    local procedure EnqueueJobEntry(ItemJnlBuffBatch: Record "GXL Item Jnl. Buffer Batch"): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        Clear(JobQueueEntry.ID);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"GXL ItemJnlBuffBatch-Post JQ";
        JobQueueEntry.Description := 'Batch Post Item Journal Buffer';
        JobQueueEntry."Record ID to Process" := ItemJnlBuffBatch.RecordId();
        JobQueueEntry."User Session ID" := SessionId();
        CODEUNIT.Run(CODEUNIT::"Job Queue - Enqueue", JobQueueEntry);
        exit(JobQueueEntry.ID);
    end;


    procedure CancelQueueEntry(var ItemJnlBuffBatch: Record "GXL Item Jnl. Buffer Batch")
    begin
        IF not (ItemJnlBuffBatch."Job Queue Status" in [ItemJnlBuffBatch."Job Queue Status"::" ", ItemJnlBuffBatch."Job Queue Status"::Completed]) THEN BEGIN
            DeleteJobs(ItemJnlBuffBatch);
            ItemJnlBuffBatch."Job Queue Status" := ItemJnlBuffBatch."Job Queue Status"::" ";
            ItemJnlBuffBatch.Modify();
        END;
    end;

    local procedure DeleteJobs(ItemJnlBuffBatch: Record "GXL Item Jnl. Buffer Batch")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not IsNullGuid(ItemJnlBuffBatch."Job Queue Entry ID") then
            JobQueueEntry.SetRange(ID, ItemJnlBuffBatch."Job Queue Entry ID");
        JobQueueEntry.SETRANGE("Record ID to Process", ItemJnlBuffBatch.RecordId());
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll(true);
    end;

}