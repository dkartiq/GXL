codeunit 50275 "GXL PDA-Process Trans Receipts"
{
    TableNo = "Job Queue Entry";
    Permissions = tabledata "GXL PDA-TransRcpt Process Buff" = rm;

    trigger OnRun()
    begin
        GlobalJobQueueEntry := Rec;
        GlobalNoOfErrors := 0;
        CopyTransReceiptToProcessBuffer();
        PostTransferReceipts();

        if GlobalNoOfErrors <> 0 then
            SendError(GlobalNoOfErrors);
    end;

    var
        GlobalJobQueueEntry: Record "Job Queue Entry";
        GlobalNoOfErrors: Integer;

    procedure CopyTransReceiptToProcessBuffer()
    var
        PDATransRcptLine: Record "GXL PDA-Trans Receipt Line";
        PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff";
    begin
        PDATransRcptLine.Reset();
        if PDATransRcptLine.FindSet() then
            repeat
                PDATransRcptProcessBuff.Init();
                PDATransRcptProcessBuff.TransferFields(PDATransRcptLine);
                PDATransRcptProcessBuff."Entry No." := 0;
                PDATransRcptProcessBuff.Insert(true);
            until PDATransRcptLine.Next() = 0;
        PDATransRcptLine.DeleteAll();
        Commit();
    end;

    procedure PostTransferReceipts()
    var
        PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff";
        TempDocumentSearchResult: Record "Document Search Result" temporary;
    begin
        PDATransRcptProcessBuff.Reset();
        PDATransRcptProcessBuff.SetCurrentKey(Processed, Errored, "No.", "Line No.");
        PDATransRcptProcessBuff.SetRange(Processed, false);
        PDATransRcptProcessBuff.SetRange(Errored, false);

        GetUniqueReceiptNos(PDATransRcptProcessBuff, TempDocumentSearchResult);

        TempDocumentSearchResult.Reset();
        if TempDocumentSearchResult.FindSet() then
            repeat
                PostPerReceipt(TempDocumentSearchResult."Doc. No.");
                Commit();
            until TempDocumentSearchResult.Next() = 0;
        TempDocumentSearchResult.DeleteAll();

    end;

    procedure PostPerReceipt(OrderNo: Code[20])
    var
        TransHead: Record "Transfer Header";
        PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff";
        PDAProcessTransRcpt: Codeunit "GXL PDA-Post Trans Receipt";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        ProcessWasSuccess: Boolean;
    begin
        if not TransHead.Get(OrderNo) then begin
            SetRcptBufferProcessed(OrderNo);
            exit;
        end;

        PDATransRcptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransRcptProcessBuff.SetRange("No.", OrderNo);
        PDATransRcptProcessBuff.FindSet();

        Clear(PDAProcessTransRcpt);
        ClearLastError();
        ProcessWasSuccess := PDAProcessTransRcpt.Run(PDATransRcptProcessBuff);
        if not ProcessWasSuccess then begin
            if not MiscUtilities.IsLockingError(GetLastErrorCode()) then begin
                GlobalNoOfErrors += 1;
                SetRcptBufferError(OrderNo, GetLastErrorText())
            end;
        end else
            SetRcptBufferProcessed(OrderNo);
    end;

    local procedure GetUniqueReceiptNos(var PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff"; var TempDocumentSearchResult: Record "Document Search Result" temporary)
    begin
        if PDATransRcptProcessBuff.FindSet() then
            repeat
                if not TempDocumentSearchResult.Get(0, PDATransRcptProcessBuff."No.", 0) then begin
                    TempDocumentSearchResult.Init();
                    TempDocumentSearchResult."Doc. Type" := 0;
                    TempDocumentSearchResult."Doc. No." := PDATransRcptProcessBuff."No.";
                    TempDocumentSearchResult."Table ID" := 0;
                    TempDocumentSearchResult.Insert();
                end;
                PDATransRcptProcessBuff.SetRange("No.", PDATransRcptProcessBuff."No.");
                PDATransRcptProcessBuff.FindLast();
                PDATransRcptProcessBuff.SetRange("No.");
            until PDATransRcptProcessBuff.Next() = 0;
    end;

    local procedure SetRcptBufferError(OrderNo: Code[20]; ErrText: Text)
    var
        PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff";
    begin
        PDATransRcptProcessBuff.Reset();
        PDATransRcptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransRcptProcessBuff.SetRange("No.", OrderNo);
        if PDATransRcptProcessBuff.FindSet() then
            repeat
                PDATransRcptProcessBuff.Errored := true;
                PDATransRcptProcessBuff."Error Message" := CopyStr(ErrText, 1, MaxStrLen(PDATransRcptProcessBuff."Error Message"));
                PDATransRcptProcessBuff.Modify();
            until PDATransRcptProcessBuff.Next() = 0;
    end;

    local procedure SetRcptBufferProcessed(OrderNo: Code[20])
    var
        PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff";
    begin
        PDATransRcptProcessBuff.Reset();
        PDATransRcptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransRcptProcessBuff.SetRange("No.", OrderNo);
        if PDATransRcptProcessBuff.FindSet() then
            repeat
                PDATransRcptProcessBuff.Processed := true;
                PDATransRcptProcessBuff."Processing Date Time" := CurrentDateTime();
                PDATransRcptProcessBuff.Errored := false;
                PDATransRcptProcessBuff."Error Message" := '';
                PDATransRcptProcessBuff.Modify();
            until PDATransRcptProcessBuff.Next() = 0;
    end;

    local procedure ResetRcptBufferError(OrderNo: Code[20])
    var
        PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff";
    begin
        PDATransRcptProcessBuff.Reset();
        PDATransRcptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransRcptProcessBuff.SetRange("No.", OrderNo);
        if PDATransRcptProcessBuff.FindSet() then
            repeat
                PDATransRcptProcessBuff.Errored := false;
                PDATransRcptProcessBuff."Error Message" := '';
                PDATransRcptProcessBuff.Modify();
            until PDATransRcptProcessBuff.Next() = 0;
    end;

    procedure ResetError(var _PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff")
    var
        PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff";
        PDATransRcptProcessBuff2: Record "GXL PDA-TransRcpt Process Buff";
        TempDocumentSearchResult: Record "Document Search Result" temporary;
    begin
        PDATransRcptProcessBuff.Copy(_PDATransRcptProcessBuff);
        PDATransRcptProcessBuff.SetCurrentKey(Processed, Errored, "No.", "Line No.");
        PDATransRcptProcessBuff.SetRange(Processed, false);
        PDATransRcptProcessBuff.SetRange(Errored, true);

        GetUniqueReceiptNos(PDATransRcptProcessBuff, TempDocumentSearchResult);

        TempDocumentSearchResult.Reset();
        if TempDocumentSearchResult.FindSet() then
            repeat
                PDATransRcptProcessBuff2.SetCurrentKey("No.", "Line No.");
                PDATransRcptProcessBuff2.SetRange("No.", TempDocumentSearchResult."Doc. No.");
                PDATransRcptProcessBuff2.SetRange(Processed, true);
                if PDATransRcptProcessBuff2.IsEmpty() then
                    ResetRcptBufferError(TempDocumentSearchResult."Doc. No.");
            until TempDocumentSearchResult.Next() = 0;
    end;

    local procedure SendError(NoOfErrors: Integer)
    var
        PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff";
        JobQueueEntrySendEnail: Codeunit "GXL Job Queue Entry-Send Email";
        ErrMsg: Text;
    begin
        if not IsNullGuid(GlobalJobQueueEntry.ID) then
            if GlobalJobQueueEntry."GXL Error Notif. Email Address" <> '' then begin
                ErrMsg := StrSubstNo('There are %1 transfer receipts could not be posted. Please check "Error Message" on the %2 for details',
                    NoOfErrors, PDATransRcptProcessBuff.TableCaption());
                // >> Upgrade
                //GlobalJobQueueEntry.SetErrorMessage(ErrMsg);
                GlobalJobQueueEntry.SetError(ErrMsg);
                // << Upgrade
                JobQueueEntrySendEnail.SetOptions(1, '', 0); //Error
                JobQueueEntrySendEnail.SendEmail(GlobalJobQueueEntry);
            end;
    end;


}