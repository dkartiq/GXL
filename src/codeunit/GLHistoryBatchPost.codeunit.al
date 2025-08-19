codeunit 50029 "GXL GL History Batch-Post"
{
    /*Change Log
        ERP-204 GL History Batches
    */

    TableNo = "GXL GL History Batch";

    trigger OnRun()
    begin
        GLHistoryBatch := Rec;
        Process();
        Rec := GLHistoryBatch;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        GLHistoryBatch: Record "GXL GL History Batch";

    local procedure Process()
    var
        GLHistoryLine: Record "GXL GL History Line";
        GLHistoryLine2: Record "GXL GL History Line";
        GLHistoryPost: Codeunit "GXL GL History-Post";
        ProcessWasSuccess: Boolean;
        DocumentNo: Code[20];
        PostingDate: Date;
    begin
        GetSetups();
        GLHistoryLine.SetCurrentKey("Process Status", "Document No.", "Posting Date");
        GLHistoryLine.SetRange("Process Status", GLHistoryLine."Process Status"::Imported);
        GLHistoryLine.SetRange("Batch ID", GLHistoryBatch."Batch ID");
        if GLHistoryLine.FindSet(true, true) then
            repeat
                if (DocumentNo <> GLHistoryLine."Document No.") or (PostingDate <> GLHistoryLine."Posting Date") then begin
                    if GLHistoryBatch."Stop Job Queue At" <> 0DT then
                        if CurrentDateTime() > GLHistoryBatch."Stop Job Queue At" then begin
                            Commit();
                            GLHistoryBatch.CalcFields("No. of Open Entries");
                            Error('Time overlapped. Job queue was forced to be stopped: Batch posting has not been completed. There are %1 entries not processed', GLHistoryBatch."No. of Open Entries");
                        end;

                    Commit();
                    DocumentNo := GLHistoryLine."Document No.";
                    PostingDate := GLHistoryLine."Posting Date";
                    Clear(GLHistoryPost);
                    ClearLastError();
                    GLHistoryLine2 := GLHistoryLine;
                    GLHistoryPost.SetSetups(GLSetup, SourceCodeSetup);
                    ProcessWasSuccess := GLHistoryPost.Run(GLHistoryLine2);
                    if ProcessWasSuccess then
                        GLHistoryLine2.UpdateJournalPosted(GLHistoryLine2."Batch ID", DocumentNo, PostingDate)
                    else
                        GLHistoryLine2.UpdateJournalErrored(GLHistoryLine2."Batch ID", DocumentNo, PostingDate, CopyStr(GetLastErrorText(), 1, 250));
                end;
            until GLHistoryLine.Next() = 0;
    end;

    local procedure GetSetups()
    begin
        GLSetup.Get();
        SourceCodeSetup.Get();
    end;
}