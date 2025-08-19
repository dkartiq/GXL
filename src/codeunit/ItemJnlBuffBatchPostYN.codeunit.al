codeunit 50016 "GXL ItemJnlBuffBatch-Post(Y/N)"
{
    TableNo = "GXL Item Jnl. Buffer Batch";

    trigger OnRun()
    begin
        Rec.CalcFields("Open Exists");
        if not Rec."Open Exists" then
            Error('Either Item Journal Buffer Lines have already been posted or there is nothing to post.');

        if Confirm('Do you want to send the item jounral buffer batch to background posting?') then
            ItemJnlBuffBatchPostViaJobQueue.EnqueueItemJnlBufferBatch(Rec);
    end;

    var
        ItemJnlBuffBatchPostViaJobQueue: Codeunit "GXL ItemJnlBuffBatch-Post JQ";
}