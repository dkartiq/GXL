//CR050: PS-1948 External stocktake
codeunit 50021 "GXL Ext. Stocktake-Post Batch"
{
    TableNo = "GXL External Stocktake Batch";

    trigger OnRun()
    begin
        ItemJnlBuffBatch := Rec;
        ValidateLegacyItems();
        Commit();
        Process();
        Rec := ItemJnlBuffBatch;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        ItemJnlBuffBatch: Record "GXL External Stocktake Batch";

    local procedure Process()
    var
        ExtStocktakeLine: Record "GXL External Stocktake Line";
        ExtStocktakeLine2: Record "GXL External Stocktake Line";
        ExtStocktakeLine3: Record "GXL External Stocktake Line";
        ExtStocktakePostLine: Codeunit "GXL Ext. Stockatke-Post Line";
        ProcessWasSuccess: Boolean;
        PrevItemNo: Code[20];
    begin
        GetSetups();
        PrevItemNo := '';
        ExtStocktakeLine.SetCurrentKey("Process Status", "Item No.");
        ExtStocktakeLine.SetRange("Process Status", ExtStocktakeLine."Process Status"::Imported);
        ExtStocktakeLine.SetRange("Batch ID", ItemJnlBuffBatch."Batch ID");
        if ExtStocktakeLine.FindSet(true, true) then
            repeat
                if (PrevItemNo <> ExtStocktakeLine."Item No.") then begin
                    Commit();
                    ExtStocktakeLine2 := ExtStocktakeLine;
                    Clear(ExtStocktakePostLine);
                    ClearLastError();
                    ExtStocktakePostLine.SetSetups(GLSetup, SourceCodeSetup);
                    ProcessWasSuccess := ExtStocktakePostLine.Run(ExtStocktakeLine2);

                    ExtStocktakeLine3.SetCurrentKey("Item No.");
                    ExtStocktakeLine3.SetRange("Item No.", ExtStocktakeLine."Item No.");
                    ExtStocktakeLine3.SetRange("Batch ID", ExtStocktakeLine."Batch ID");
                    ExtStocktakeLine3.SetRange("Process Status", ExtStocktakeLine3."Process Status"::Imported);
                    if ProcessWasSuccess then
                        SetStatusPosted(ExtStocktakeLine3)
                    else
                        SetStatusErrored(ExtStocktakeLine3, CopyStr(GetLastErrorText(), 1, 250));
                end;
                PrevItemNo := ExtStocktakeLine."Item No.";
            until ExtStocktakeLine.Next() = 0;
    end;

    local procedure ValidateLegacyItems()
    var
        ExtStocktakeLine: Record "GXL External Stocktake Line";
        ExtStocktakeLine2: Record "GXL External Stocktake Line";
        ItemUOM: Record "Item Unit of Measure";
        LeagacyItemhelpers: Codeunit "GXL Legacy Item Helpers";
    begin
        ExtStocktakeLine.SetCurrentKey("Process Status", "Item No.");
        ExtStocktakeLine.SetRange("Process Status", ExtStocktakeLine."Process Status"::Imported);
        ExtStocktakeLine.SetRange("Batch ID", ItemJnlBuffBatch."Batch ID");
        ExtStocktakeLine.SetFilter("Legacy Item No.", '<>%1', '');
        ExtStocktakeLine.SetFilter("Item No.", '=%1', '');
        if ExtStocktakeLine.FindSet(true, true) then
            repeat
                ExtStocktakeLine2 := ExtStocktakeLine;
                if LeagacyItemhelpers.GetItemUOM(ExtStocktakeLine."Legacy Item No.", ItemUOM) then begin
                    ExtStocktakeLine2."Item No." := ItemUOM."Item No.";
                    ExtStocktakeLine2."Unit of Measure Code" := ItemUOM.Code;
                    ExtStocktakeLine2."Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                    ExtStocktakeLine2.CalculateInventory();
                    ExtStocktakeLine2.Modify();
                end else begin
                    ExtStocktakeLine2.UpdateJournalErrored(StrSubstNo('%1 not found', ExtStocktakeLine.FieldCaption("Legacy Item No.")));
                    ExtStocktakeLine2.Modify();
                end;
            until ExtStocktakeLine.Next() = 0;
    end;

    local procedure SetStatusPosted(var ExtStocktakeLine: Record "GXL External Stocktake Line")
    var
        ExtStocktakeLine2: Record "GXL External Stocktake Line";
    begin
        if ExtStocktakeLine.FindSet() then
            repeat
                ExtStocktakeLine2 := ExtStocktakeLine;
                ExtStocktakeLine2.UpdateJournalPosted();
                ExtStocktakeLine2.Modify();
            until ExtStocktakeLine.Next() = 0;
    end;

    local procedure SetStatusErrored(var ExtStocktakeLine: Record "GXL External Stocktake Line"; ErrMessage: Text[250])
    var
        ExtStocktakeLine2: Record "GXL External Stocktake Line";
    begin
        if ExtStocktakeLine.FindSet() then
            repeat
                ExtStocktakeLine2 := ExtStocktakeLine;
                ExtStocktakeLine2.UpdateJournalErrored(ErrMessage);
                ExtStocktakeLine2.Modify();
            until ExtStocktakeLine.Next() = 0;
    end;

    local procedure GetSetups()
    begin
        GLSetup.Get();
        SourceCodeSetup.Get();
    end;
}