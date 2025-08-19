//CR050: PS-1948 External stocktake
codeunit 50022 "GXL ExtStocktake-Post Batch JQ"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        ExtStocktakeBatch: Record "GXL External Stocktake Batch";
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        RecRef: RecordRef;
    begin
        Rec.TestField("Record ID to Process");
        RecRef.Get(Rec."Record ID to Process");
        RecRef.SetTable(ExtStocktakeBatch);
        ExtStocktakeBatch.Find();

        BatchProcessingMgt.GetBatchFromSession(Rec."Record ID to Process", Rec."User Session ID");
        SetJobQueueStatus(ExtStocktakeBatch, ExtStocktakeBatch."Job Queue Status"::Posting, CurrentDateTime(), 0DT);
        if not Codeunit.Run(Codeunit::"GXL Ext. Stocktake-Post Batch", ExtStocktakeBatch) then begin
            SetJobQueueStatus(ExtStocktakeBatch, ExtStocktakeBatch."Job Queue Status"::Error, 0DT, CurrentDateTime());
            BatchProcessingMgt.ResetBatchID();
            Error(GetLastErrorText());
        end;
        BatchProcessingMgt.ResetBatchID();
        SetJobQueueStatus(ExtStocktakeBatch, ExtStocktakeBatch."Job Queue Status"::Completed, 0DT, CurrentDateTime());
    end;


    var
        WrongJobQueueStatusErr: Label '%1 cannot be posted because it has already been scheduled for posting. Choose the Remove from Job Queue action to reset the job queue status and then post again.';

    local procedure SetJobQueueStatus(var ExtStocktakeBatch: Record "GXL External Stocktake Batch"; NewStatus: Option; StartDT: DateTime; EndDT: DateTime)
    var
    begin
        ExtStocktakeBatch.LockTable();
        if ExtStocktakeBatch.Find() then begin
            ExtStocktakeBatch."Job Queue Status" := NewStatus;
            if StartDT <> 0DT then
                ExtStocktakeBatch."Job Queue Start Date Time" := StartDT;
            if EndDT <> 0DT then
                ExtStocktakeBatch."Job Queue End Date Time" := EndDT;
            ExtStocktakeBatch.Modify();
        end;
        Commit();
    end;

    procedure EnqueueExternalStocktakeBatch(var ExtStocktakeBatch: Record "GXL External Stocktake Batch")
    begin
        if not (ExtStocktakeBatch."Job Queue Status" in [ExtStocktakeBatch."Job Queue Status"::" ", ExtStocktakeBatch."Job Queue Status"::Error, ExtStocktakeBatch."Job Queue Status"::Completed]) then
            Error(WrongJobQueueStatusErr, ExtStocktakeBatch."Batch ID");
        if ExtStocktakeBatch."Job Queue Status" = ExtStocktakeBatch."Job Queue Status"::Completed then begin
            ExtStocktakeBatch.CalcFields("Open Exists");
            if not ExtStocktakeBatch."Open Exists" then
                Error(WrongJobQueueStatusErr, ExtStocktakeBatch."Batch ID");
        end;
        ExtStocktakeBatch."Job Queue Status" := ExtStocktakeBatch."Job Queue Status"::"Scheduled for Posting";
        ExtStocktakeBatch."Job Queue Entry ID" := EnqueueJobEntry(ExtStocktakeBatch);
        ExtStocktakeBatch.Modify();
    end;

    local procedure EnqueueJobEntry(ExtStocktakeBatch: Record "GXL External Stocktake Batch"): Guid
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        Clear(JobQueueEntry.ID);
        JobQueueEntry."Object Type to Run" := JobQueueEntry."Object Type to Run"::Codeunit;
        JobQueueEntry."Object ID to Run" := Codeunit::"GXL ExtStocktake-Post Batch JQ";
        JobQueueEntry.Description := 'Batch Post External Stocktake ' + Format(ExtStocktakeBatch."Batch ID");
        JobQueueEntry."Record ID to Process" := ExtStocktakeBatch.RecordId();
        JobQueueEntry."User Session ID" := SessionId();
        Codeunit.Run(Codeunit::"Job Queue - Enqueue", JobQueueEntry);
        exit(JobQueueEntry.ID);
    end;


    procedure CancelQueueEntry(var ExtStocktakeBatch: Record "GXL External Stocktake Batch")
    begin
        IF not (ExtStocktakeBatch."Job Queue Status" in [ExtStocktakeBatch."Job Queue Status"::" ", ExtStocktakeBatch."Job Queue Status"::Completed]) THEN BEGIN
            DeleteJobs(ExtStocktakeBatch);
            ExtStocktakeBatch."Job Queue Status" := ExtStocktakeBatch."Job Queue Status"::" ";
            ExtStocktakeBatch.Modify();
        END;
    end;

    local procedure DeleteJobs(ExtStocktakeBatch: Record "GXL External Stocktake Batch")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if not IsNullGuid(ExtStocktakeBatch."Job Queue Entry ID") then
            JobQueueEntry.SetRange(ID, ExtStocktakeBatch."Job Queue Entry ID");
        JobQueueEntry.SetRange("Record ID to Process", ExtStocktakeBatch.RecordId());
        if not JobQueueEntry.IsEmpty() then
            JobQueueEntry.DeleteAll(true);
    end;

}