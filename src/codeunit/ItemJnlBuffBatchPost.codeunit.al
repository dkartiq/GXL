codeunit 50013 "GXL ItemJnlBuffBatch-Post"
{
    TableNo = "GXL Item Jnl. Buffer Batch";

    trigger OnRun()
    begin
        ItemJnlBuffBatch := Rec;
        Process();
        Rec := ItemJnlBuffBatch;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        ItemJnlBuffBatch: Record "GXL Item Jnl. Buffer Batch";

    local procedure Process()
    var
        ItemJnlBuffer: Record "GXL Item Journal Buffer";
        ItemJnlBuffer2: Record "GXL Item Journal Buffer";
        ItemJnlBuffPost: Codeunit "GXL Item Jnl Buffer-Post";
        ProcessWasSuccess: Boolean;
    begin
        GetSetups();
        ItemJnlBuffer.SetCurrentKey("Process Status");
        ItemJnlBuffer.SetRange("Process Status", ItemJnlBuffer."Process Status"::Imported);
        ItemJnlBuffer.SetRange("Batch ID", ItemJnlBuffBatch."Batch ID");
        if ItemJnlBuffer.FindSet(true, true) then
            repeat
                Commit();
                ItemJnlBuffer2 := ItemJnlBuffer;
                Clear(ItemJnlBuffPost);
                ClearLastError();
                ItemJnlBuffPost.SetSetups(GLSetup, SourceCodeSetup);
                ProcessWasSuccess := ItemJnlBuffPost.Run(ItemJnlBuffer2);
                if ProcessWasSuccess then
                    ItemJnlBuffer2.UpdateJournalPosted()
                else
                    ItemJnlBuffer2.UpdateJournalErrored(CopyStr(GetLastErrorText(), 1, 250));
                ItemJnlBuffer2.Modify();
            until ItemJnlBuffer.Next() = 0;
    end;

    local procedure GetSetups()
    begin
        GLSetup.Get();
        SourceCodeSetup.Get();
    end;
}