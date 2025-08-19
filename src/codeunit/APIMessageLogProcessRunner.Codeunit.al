codeunit 50039 "API Message Log Process Runner"
{
    TableNo = "API Message Log";

    trigger OnRun()
    begin
        ProcessAPIMessageLogRecord(Rec);
    end;

    local procedure ProcessAPIMessageLogRecord(APIMessageLog: Record "API Message Log")
    var
        IntegrationSetup: Record "GXL Integration Setup";
        JobQueueEntryMgt: Codeunit "GXL Job Queue Entry Management";
        APIMessageLogManagment: Codeunit "API Message Log Managment";
        ProcessType: Integer;
        ProcessSuccess: Boolean;
        LockRetry: Integer;
        LockError: boolean;
        SkipRetry: Boolean;
        ErrText: Text;
    begin
        IntegrationSetup.get;
        IntegrationSetup.TestField("API Lock Retry No.");

        APIMessageLog.TestField(Status, APIMessageLog.Status::" ");

        IF APIMessageLog."Location Code" = '' THEN begin
            APIMessageLog.Status := APIMessageLog.Status::Errored;
            APIMessageLog."Error Text" := 'Location Code cannot be Blank';
            APIMessageLog."Processing End" := CurrentDateTime;
            APIMessageLog.Modify(false); // not to trigger event
            exit;
        end;

        APIMessageLog.CalcFields("API Payload");
        IF NOT (APIMessageLog."API Payload".HasValue) THEN begin
            APIMessageLog.Status := APIMessageLog.Status::Errored;
            APIMessageLog."Error Text" := 'Paylod Blob is empty';
            APIMessageLog."Processing End" := CurrentDateTime;
            APIMessageLog.Modify(false); // not to trigger event
            exit;
        end;

        if not APIMessageLog.IsAPITypeEnabledForLocation(APIMessageLog."Location Code", APIMessageLog."API Type") then begin
            APIMessageLog.Status := APIMessageLog.Status::Errored;
            APIMessageLog."Error Text" := StrSubstNo('API is not enabled for this Location (%1) and API Type (%2) combination.', APIMessageLog."Location Code", APIMessageLog."API Type");
            APIMessageLog."Processing End" := CurrentDateTime;
            APIMessageLog.Modify(false); // not to trigger event
            exit;
        end;

        ProcessType := APIMessageLog.GetProcessTypeByAPIType();

        if ProcessType = 0 then begin
            APIMessageLog.Status := APIMessageLog.Status::Errored;
            APIMessageLog."Error Text" := StrSubstNo('The API Type (%1) is not a process available in the API.', APIMessageLog."API Type");
            APIMessageLog."Processing End" := CurrentDateTime;
            APIMessageLog.Modify(false); // not to trigger event
            exit;
        end;

        APIMessageLog.Status := APIMessageLog.Status::Processing;
        APIMessageLog."Error Text" := '';
        APIMessageLog."Processing End" := 0DT;
        APIMessageLog."Processing Start" := CurrentDateTime;
        APIMessageLog.Modify(false); // not to trigger event

        Commit();
        repeat
            ClearLastError();
            LockError := false;
            SkipRetry := false;
            ErrText := '';

            Case ProcessType of
                1:
                    begin
                        Clear(JobQueueEntryMgt);
                        JobQueueEntryMgt.SetOptionsForAPILog(ProcessType, APIMessageLog);
                        ProcessSuccess := JobQueueEntryMgt.RUN();
                    end;
                2:
                    ProcessSuccess := ProcessASN(APIMessageLog);
                else begin
                    ProcessSuccess := false;
                    ErrText := StrSubstNo('Invalid Type "%1".', APIMessageLog."API Type");
                    SkipRetry := true;
                end;

            end;

            if not ProcessSuccess then begin
                ErrText := GetLastErrorText();

                LockError := APIMessageLogManagment.IsLockError(ErrText);

                if LockError then begin
                    LockRetry += 1;
                    Sleep(1000);
                end;
            end;
        until (ProcessSuccess) or (LockRetry >= IntegrationSetup."API Lock Retry No.") or (not LockError) or SkipRetry;

        APIMessageLog.get(APIMessageLog."Entry No.");

        APIMessageLog."Lock Retry" := LockRetry;
        APIMessageLog."Processing End" := CurrentDateTime;

        if ProcessSuccess then begin
            APIMessageLog.Status := APIMessageLog.Status::Completed;
            APIMessageLog."Error Text" := '';
        end else begin
            APIMessageLog.Status := APIMessageLog.Status::Errored;
            APIMessageLog."Error Text" := CopyStr(ErrText, 1, MaxStrLen(APIMessageLog."Error Text"));
        end;

        APIMessageLog.Modify(false); // not to trigger event

        Commit();
    end;

    local procedure ProcessASN(var APIMessageLog: Record "API Message Log") processSuccess: Boolean
    var
        APIProcessASN: Codeunit "API Message Log Process ASN";
    begin
        APIProcessASN.SetAPILogEntry(APIMessageLog);
        //processSuccess := APIProcessASN.Run();
        if APIProcessASN.Run() then;   //no need to trace error in msg api.
        processSuccess := true;
    end;

    // *** NOT USED ***
    local procedure ImportASN(var APIMessageLog: Record "API Message Log") processSuccess: Boolean
    var
        APILog: Record "API Message Log";
        XMLBlob: Codeunit "Temp Blob";
        XMLPortID: Integer;
        outStm: OutStream;
        inStr: InStream;
    begin
        processSuccess := false;

        APILog.Get(APIMessageLog."Entry No.");
        APILog.SetRecFilter();
        APILog.FindFirst();

        APILog.TestField("API Type");

        APILog.CalcFields("API Payload");
        IF not APILog."API Payload".HasValue then
            Error('API Message Log Payload Blob has no Value');

        XMLBlob.CreateOutStream(outStm);
        outStm.WriteText(APILog.PayloadToTextAsDecoded());

        if not XMLBlob.HasValue() then
            Error('API Message Log Payload Blob has no Value');

        XMLBlob.CREATEINSTREAM(inStr);

        XMLPortID := APILog.GetRelatedXMLPortID();

        processSuccess := XMLPORT.IMPORT(XMLPortID, inStr);
    end;
}
