codeunit 50015 "GXL Job Queue Events"
{
    // >> Upgrade
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Dispatcher", 'OnAfterHandleRequest', '', true, true)]
    // local procedure JobQueueDispatcher_OnAfterHandleRequest(var JobQueueEntry: Record "Job Queue Entry"; WasSuccess: Boolean)
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue Error Handler", 'OnAfterLogError', '', true, true)]
    local procedure JobQueueErrorHandler_OnAfterLogError(var JobQueueEntry: Record "Job Queue Entry")
    // << Upgrade
    var
        JobQueueEntrySendEmail: Codeunit "GXL Job Queue Entry-Send Email";
    begin
        if (JobQueueEntry.Status = JobQueueEntry.Status::Error) and (not JobQueueEntry."GXL No Email on Error Log") and
            (JobQueueEntry."GXL Error Notif. Email Address" <> '') then begin
            JobQueueEntrySendEmail.SetOptions(1, '', 0);
            if JobQueueEntrySendEmail.SendEmail(JobQueueEntry) then;
        end;
    end;
}