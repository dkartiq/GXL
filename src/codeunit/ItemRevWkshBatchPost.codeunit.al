/// <summary>
/// CR099 - Revaluation Journal Batch
/// </summary>
codeunit 50042 "GXL Item Rev.Wksh.Batch-Post"
{
    TableNo = "GXL Item Reval. Wksh. Batch";

    trigger OnRun()
    begin
        RevalWkshBatch := Rec;
        Process();
        Rec := RevalWkshBatch;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        RevalWkshBatch: Record "GXL Item Reval. Wksh. Batch";

    local procedure Process()
    var
        RevalWkshLine: Record "GXL Item Reval. Wksh. Line";
        RevalWkshLine2: Record "GXL Item Reval. Wksh. Line";
        RevalWkshLinePost: Codeunit "GXL Item Rev.Wksh.Line-Post";
        ProcessWasSuccess: Boolean;

    begin
        GetSetups();
        RevalWkshLine.SetCurrentKey(Status);
        RevalWkshLine.SetFilter(Status, '%1|%2', RevalWkshLine.Status::"Value Calculated", RevalWkshLine.Status::"Posting Error");
        RevalWkshLine.SetRange("Batch ID", RevalWkshBatch."Batch ID");
        if RevalWkshLine.FindSet(true, true) then begin
            RevalWkshBatch.CheckBatchBeforePosting();
            repeat
                if RevalWkshBatch."Stop Job Queue At" <> 0DT then
                    if CurrentDateTime() > RevalWkshBatch."Stop Job Queue At" then begin
                        Commit();
                        Error('Time overlapped. Job queue was forced to be stopped: Batch posting has not been completed.');
                    end;

                Commit();

                Clear(RevalWkshLinePost);
                ClearLastError();
                RevalWkshLine2 := RevalWkshLine;
                RevalWkshLinePost.SetSetups(GLSetup, SourceCodeSetup);
                ProcessWasSuccess := RevalWkshLinePost.Run(RevalWkshLine2);

                if ProcessWasSuccess then
                    RevalWkshLine2.SetNewStatus(RevalWkshLine2.Status::Posted, '')
                else
                    RevalWkshLine2.SetNewStatus(RevalWkshLine2.Status::"Posting Error", GetLastErrorText());

                RevalWkshLine2.SetNewUserDateTime();
                RevalWkshLine2.Modify();
            until RevalWkshLine.Next() = 0;
        end;
    end;

    local procedure GetSetups()
    begin
        GLSetup.Get();
        SourceCodeSetup.Get();
    end;
}