//CR050: PS-1948 External stocktake
codeunit 50023 "GXL ExtStocktake-Post Batch YN"
{
    TableNo = "GXL External Stocktake Batch";

    trigger OnRun()
    begin
        Rec.CalcFields("Open Exists");
        if not Rec."Open Exists" then
            Error('Either External Stocktake Lines have already been posted or there is nothing to post.');

        if Confirm('Do you want to send the external stocktake batch to background posting?') then
            ExtStocktakePostBatchViaJobQueue.EnqueueExternalStocktakeBatch(Rec);
    end;

    var
        ExtStocktakePostBatchViaJobQueue: Codeunit "GXL ExtStocktake-Post Batch JQ";
}