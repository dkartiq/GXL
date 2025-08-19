codeunit 50038 "API Message Log Managment"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        case Rec."Parameter String" of
            'CLEANUP':
                CleanUpErrorLogs();
            'RETRY':
                RetryErrorLogs();
            'PROCESS':
                ProcessAPILogs();
            else
                Error('Invalid Parameter String');
        end;
    end;

    //
    // >>>> LOCAL FUNCTIONS <<<<
    //
    local procedure CleanUpErrorLogs()
    var
        IntegrationSetup: Record "GXL Integration Setup";
        APIMessageLog: Record "API Message Log";
        CleanUpOlderThanDateTime: DateTime;
    begin
        IntegrationSetup.Get();
        IntegrationSetup.TestField("API Log CleanUp Frequency");
        CleanUpOlderThanDateTime := CreateDateTime(CalcDate(IntegrationSetup."API Log CleanUp Frequency", Today), Time);
        if CleanUpOlderThanDateTime >= CurrentDateTime then
            Error('The "%1" Date Fourmula "%2" returns a date greater than today!', IntegrationSetup.FieldCaption("API Log CleanUp Frequency"), IntegrationSetup."API Log CleanUp Frequency");

        APIMessageLog.SetRange(Status, APIMessageLog.Status::Completed);
        APIMessageLog.SetFilter("Processing End", '..%1', CleanUpOlderThanDateTime);
        if APIMessageLog.FindSet() then
            APIMessageLog.DeleteAll();
    end;

    local procedure RetryErrorLogs()
    var
        IntegrationSetup: Record "GXL Integration Setup";
        APIMessageLog: Record "API Message Log";
        RetryOlderThanDateTime: DateTime;
        RetryProcess: Boolean;
    begin
        IntegrationSetup.Get();
        IntegrationSetup.TestField("API Retry Frequency");
        RetryOlderThanDateTime := CreateDateTime(CalcDate(IntegrationSetup."API Retry Frequency", Today), Time);
        if RetryOlderThanDateTime >= CurrentDateTime then
            Error('The "%1" Date Fourmula "%2" returns a date greater than today!', IntegrationSetup.FieldCaption("API Retry Frequency"), IntegrationSetup."API Retry Frequency");

        APIMessageLog.SetFilter(Status, '%1|%2', APIMessageLog.Status::Errored, APIMessageLog.Status::Processing);
        if APIMessageLog.FindSet() then
            repeat
                RetryProcess := false;

                if APIMessageLog.Status = APIMessageLog.Status::Errored then begin
                    if IsLockError(APIMessageLog."Error Text") then
                        RetryProcess := true;
                end;

                if APIMessageLog.Status = APIMessageLog.Status::Processing then begin
                    if APIMessageLog."Processing Start" <= RetryOlderThanDateTime then
                        RetryProcess := true;
                end;

                if RetryProcess then begin
                    if APIMessageLog.Status <> APIMessageLog.Status::" " then begin
                        APIMessageLog.Status := APIMessageLog.Status::" ";
                        APIMessageLog."Error Text" := '';
                        APIMessageLog."Processing End" := 0DT;
                        APIMessageLog.Modify(false); // not to trigger event
                    end;

                    ProcessAPIMessageLogRecord(APIMessageLog);
                end;
            until APIMessageLog.Next() = 0;
    end;

    local Procedure ProcessAPILogs()
    var
        APIMessageLog: Record "API Message Log";
        IntegrationSetup: Record "GXL Integration Setup";
    begin
        IntegrationSetup.Get();
        IntegrationSetup.TestField("API Process On Event", false);

        APIMessageLog.SetRange(Status, APIMessageLog.status::" ");

        IF APIMessageLog.FindSet(true) THEN
            REPEAT
                ProcessAPIMessageLogRecord(APIMessageLog);
            UNTIL APIMessageLog.NEXT() = 0;
    end;

    local procedure ProcessAPIMessageLogRecord(APIMessageLog: Record "API Message Log")
    var
        SessionID: Integer;
    begin
        APIMessageLog.SetRecFilter();
        if not APIMessageLog.FindFirst() then
            exit;

        Codeunit.Run(Codeunit::"API Message Log Process Runner", APIMessageLog);
    end;

    local procedure ProcessAPIMessageLogRecordInBackground(APIMessageLog: Record "API Message Log")
    var
        SessionID: Integer;

    begin
        APIMessageLog.SetRecFilter();
        if not APIMessageLog.FindFirst() then
            exit;

        StartSession(SessionID, Codeunit::"API Message Log Process Runner", CompanyName, APIMessageLog);

    end;

    //
    // >>>> EVENTS FUNCTIONS <<<<
    //
    [EventSubscriber(ObjectType::Table, Database::"API Message Log", OnAfterModifyEvent, '', false, false)]
    local procedure ProcessAPIMessageLogOnModify(var Rec: Record "API Message Log"; var xRec: Record "API Message Log"; RunTrigger: Boolean)
    var
        IntegrationSetup: Record "GXL Integration Setup";
    begin
        if not RunTrigger then
            exit;

        Rec.CalcFields("API Payload");
        if not Rec."API Payload".HasValue then
            exit;

        if Rec.Status <> Rec.Status::" " then
            exit;

        if not IntegrationSetup.Get() then
            exit;

        if not IntegrationSetup."API Process On Event" then
            exit;

        ProcessAPIMessageLogRecordInBackground(Rec);
    end;

    //
    // >>>> PUBLIC FUNCTIONS <<<<
    //
    Procedure ProcessSelectedAPILogs(var APIMessageLog: Record "API Message Log"; runInBackground: Boolean)
    var
        RetryProcess: Boolean;
    begin
        if APIMessageLog.FindSet(true) then
            repeat
                if APIMessageLog.Status = APIMessageLog.Status::" " then
                    if runInBackground then
                        ProcessAPIMessageLogRecordInBackground(APIMessageLog)
                    else
                        ProcessAPIMessageLogRecord(APIMessageLog);
            until APIMessageLog.NEXT() = 0;
    end;

    Procedure ReProcessSelectedAPILogs(var APIMessageLog: Record "API Message Log"; runInBackground: Boolean)
    var
        RetryProcess: Boolean;
    begin
        if APIMessageLog.FindSet(true) then
            repeat
                RetryProcess := true;

                if APIMessageLog.Status = APIMessageLog.Status::Completed then
                    if APIMessageLog."Error Text" = '' then
                        RetryProcess := false;

                //if APIMessageLog.Status = APIMessageLog.Status::Processing then
                //    if APIMessageLog."Error Text" = '' then
                //        RetryProcess := false;

                if RetryProcess then begin
                    if APIMessageLog.Status <> APIMessageLog.Status::" " then begin
                        APIMessageLog.Status := APIMessageLog.Status::" ";
                        APIMessageLog."Error Text" := '';
                        APIMessageLog."Processing End" := 0DT;
                        APIMessageLog.Modify(false); // not to trigger event
                    end;

                    if runInBackground then
                        ProcessAPIMessageLogRecordInBackground(APIMessageLog)
                    else
                        ProcessAPIMessageLogRecord(APIMessageLog);
                end;
            until APIMessageLog.NEXT() = 0;
    end;

    procedure IsLockError(inError: Text): Boolean
    var
        LowerCaseError: text;
    begin
        LowerCaseError := LowerCase(inError);
        if (StrPos(LowerCaseError, 'lock') <> 0) or
           (StrPos(LowerCaseError, 'deadlock') <> 0) or
           (StrPos(LowerCaseError, 'a connection') <> 0) or
           (STRPOS(LowerCaseError, 'sql error') <> 0) or
           (STRPOS(LowerCaseError, 'we just updated this') <> 0)
          then
            exit(true);
    end;
}
