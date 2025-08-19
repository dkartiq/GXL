codeunit 50028 "GXL GL History-Post"
{
    /*Change Log
        ERP-204 GL History Batches
    */

    TableNo = "GXL GL History Line";

    trigger OnRun()
    var
        SavedGLSetup: Record "General Ledger Setup";
        SavedSourceCodeSetup: Record "Source Code Setup";
        SavedSetupRead: Boolean;
        LineOk: Boolean;
    begin
        SavedGLSetup := GLSetup;
        SavedSourceCodeSetup := SourceCodeSetup;
        SavedSetupRead := SetupRead;

        ClearAll();
        GLSetup := SavedGLSetup;
        SourceCodeSetup := SavedSourceCodeSetup;
        SetupRead := SavedSetupRead;

        GlobalGLHistoryLine := Rec;
        GetSetups();

        LineOk := true;
        TempGLHistoryLine.DeleteAll();
        CopyToTempLine();
        if TempGLHistoryLine.Find('-') then
            repeat
                if not CheckLine(TempGLHistoryLine) then
                    LineOk := false;
            until (not LineOk) or (TempGLHistoryLine.Next() = 0);

        if LineOk then begin
            ClearLastDimCodeArray();
            if TempGLHistoryLine.Find('-') then
                repeat
                    PostLine(TempGLHistoryLine);
                until TempGLHistoryLine.Next() = 0;
        end else
            Error(Sb.ToText());

        TempGLHistoryLine.DeleteAll();
        Clear(GenJnlPostLine);
        Rec := GlobalGLHistoryLine;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        GlobalGLHistoryLine: Record "GXL GL History Line";
        TempGLHistoryLine: Record "GXL GL History Line" temporary;
        GLAcc: Record "G/L Account";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GLSetupShortcutDimCode: array[8] of Code[20];
        ShortcutDimCode: array[8] of Code[20];
        LastDimCode: array[8] of Code[20];
        LastDimSetID: Integer;
        Ok: Boolean;
        Sb: TextBuilder;
        SetupRead: Boolean;
        BalanceChecked: Boolean;


    local procedure CopyToTempLine()
    var
        GLHistoryLine: Record "GXL GL History Line";
    begin
        GLHistoryLine.SetCurrentKey("Document No.", "Posting Date");
        GLHistoryLine.SetRange("Document No.", GlobalGLHistoryLine."Document No.");
        GLHistoryLine.SetRange("Posting Date", GlobalGLHistoryLine."Posting Date");
        GLHistoryLine.SetRange("Batch ID", GlobalGLHistoryLine."Batch ID");
        if GLHistoryLine.FindSet() then
            repeat
                TempGLHistoryLine := GLHistoryLine;
                TempGLHistoryLine.Insert();
            until GLHistoryLine.Next() = 0;
    end;

    local procedure CheckLine(var GLHistoryLine: Record "GXL GL History Line"): Boolean
    begin
        Sb.Clear();
        if GLHistoryLine."Account No." = '' then
            Sb.AppendLine(StrSubstNo('%1 is empty', GLHistoryLine.FieldCaption("Account No.")));

        GLAcc.Get(GLHistoryLine."Account No.");
        GLAcc.TestField(Blocked, false);

        if GLHistoryLine."Document No." = '' then
            Sb.AppendLine(StrSubstNo('%1 is empty', GLHistoryLine.FieldCaption("Document No.")));
        if GLHistoryLine."Posting Date" = 0D then
            Sb.AppendLine(StrSubstNo('%1 is empty', GLHistoryLine.FieldCaption("Posting Date")));
        if GLHistoryLine.Description = '' then
            Sb.AppendLine(StrSubstNo('%1 is empty', GLHistoryLine.FieldCaption(Description)));

        if not BalanceChecked then begin
            if not GLHistoryLine.IsBatchBalanced(GLHistoryLine."Batch ID", GLHistoryLine."Document No.", GLHistoryLine."Posting Date") then
                Sb.AppendLine(StrSubstNo('GL does not balance Document No. = %1, Posting Date = %2', GLHistoryLine."Document No.", GLHistoryLine."Posting Date"));
            BalanceChecked := true;
        end;

        if LastDimCode[1] <> GLHistoryLine."Shortcut Dimension 1 Code" then
            CheckDim(1, GLHistoryLine."Shortcut Dimension 1 Code");
        if LastDimCode[2] <> GLHistoryLine."Shortcut Dimension 2 Code" then
            CheckDim(2, GLHistoryLine."Shortcut Dimension 2 Code");
        if LastDimCode[3] <> GLHistoryLine."Shortcut Dimension 3 Code" then
            CheckDim(3, GLHistoryLine."Shortcut Dimension 3 Code");
        if LastDimCode[4] <> GLHistoryLine."Shortcut Dimension 4 Code" then
            CheckDim(4, GLHistoryLine."Shortcut Dimension 4 Code");
        if LastDimCode[5] <> GLHistoryLine."Shortcut Dimension 5 Code" then
            CheckDim(5, GLHistoryLine."Shortcut Dimension 5 Code");
        if LastDimCode[6] <> GLHistoryLine."Shortcut Dimension 6 Code" then
            CheckDim(6, GLHistoryLine."Shortcut Dimension 6 Code");
        if LastDimCode[7] <> GLHistoryLine."Shortcut Dimension 7 Code" then
            CheckDim(7, GLHistoryLine."Shortcut Dimension 7 Code");
        if LastDimCode[8] <> GLHistoryLine."Shortcut Dimension 8 Code" then
            CheckDim(8, GLHistoryLine."Shortcut Dimension 8 Code");

        if Sb.Length() > 0 then
            Ok := false
        else
            Ok := true;
        exit(Ok);

    end;

    local procedure CheckDim(DimNo: Integer; DimCode: Code[20])
    var
        DimVal: Record "Dimension Value";
    begin
        if DimCode <> '' then begin
            if not DimVal.Get(GLSetupShortcutDimCode[DimNo], DimCode) then
                Sb.AppendLine(StrSubstNo('Dimension: %1 %2 is not found', GLSetupShortcutDimCode[DimNo], DimCode))
            else
                if DimVal.Blocked then
                    Sb.AppendLine(StrSubstNo('Dimension: %1 %2 is blocked', GLSetupShortcutDimCode[DimNo], DimCode));
        end;
        LastDimCode[DimNo] := DimCode;
    end;


    local procedure ClearLastDimCodeArray()
    var
        i: Integer;
    begin
        for i := 1 to 8 do
            LastDimCode[i] := '';
    end;

    local procedure PostLine(var GLHistoryLine: Record "GXL GL History Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.Init();
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::"G/L Account";
        GenJnlLine."Posting Date" := GLHistoryLine."Posting Date";
        if GLHistoryLine."Document Date" <> 0D then
            GenJnlLine."Document Date" := GLHistoryLine."Document Date"
        else
            GenJnlLine."Document Date" := GLHistoryLine."Posting Date";
        GenJnlLine."Document No." := GLHistoryLine."Document No.";
        GenJnlLine."Copy VAT Setup to Jnl. Lines" := false;
        GenJnlLine."Allow Zero-Amount Posting" := true;
        GenJnlLine.Validate("Account No.", GLHistoryLine."Account No.");
        GenJnlLine.Description := GLHistoryLine.Description;

        GenJnlLine.Validate(Amount, GLHistoryLine.Amount);
        GenJnlLine."External Document No." := GLHistoryLine."External Document No.";
        GenJnlLine."Source Code" := SourceCodeSetup."General Journal";
        GenJnlLine."Shortcut Dimension 1 Code" := GLHistoryLine."Shortcut Dimension 1 Code";
        GenJnlLine."Shortcut Dimension 2 Code" := GLHistoryLine."Shortcut Dimension 2 Code";

        GetDimensions(GLHistoryLine);
        GenJnlLine."Dimension Set ID" := GetDimensionSetId();
        CopyArray(LastDimCode, ShortcutDimCode, 1);

        GenJnlPostLine.RunWithCheck(GenJnlLine);

    end;

    local procedure GetDimensionSetId(): Integer
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        i: Integer;
        FoundDim: Boolean;
        AllDimMatched: Boolean;
    begin
        AllDimMatched := true;
        for i := 1 to 8 do
            if LastDimCode[i] <> ShortcutDimCode[i] then
                AllDimMatched := false;

        if AllDimMatched and (LastDimSetID <> 0) then
            exit(LastDimSetID)
        else begin
            FoundDim := false;
            for i := 1 to 8 do
                if ShortcutDimCode[i] <> '' then begin
                    TempDimSetEntry.Init();
                    TempDimSetEntry."Dimension Set ID" := 0;
                    TempDimSetEntry."Dimension Code" := GLSetupShortcutDimCode[i];
                    TempDimSetEntry.Validate("Dimension Value Code", ShortcutDimCode[i]);
                    TempDimSetEntry.Insert();
                    FoundDim := true;
                end;

            if FoundDim then
                LastDimSetID := DimMgt.GetDimensionSetID(TempDimSetEntry)
            else
                LastDimSetID := 0;
            exit(LastDimSetID);
        end;

    end;

    local procedure GetDimensions(var GLHistoryLine: Record "GXL GL History Line")
    begin
        ShortcutDimCode[1] := GLHistoryLine."Shortcut Dimension 1 Code";
        ShortcutDimCode[2] := GLHistoryLine."Shortcut Dimension 2 Code";
        ShortcutDimCode[3] := GLHistoryLine."Shortcut Dimension 3 Code";
        ShortcutDimCode[4] := GLHistoryLine."Shortcut Dimension 4 Code";
        ShortcutDimCode[5] := GLHistoryLine."Shortcut Dimension 5 Code";
        ShortcutDimCode[6] := GLHistoryLine."Shortcut Dimension 6 Code";
        ShortcutDimCode[7] := GLHistoryLine."Shortcut Dimension 7 Code";
        ShortcutDimCode[8] := GLHistoryLine."Shortcut Dimension 8 Code";
    end;

    local procedure GetSetups()
    begin
        if not SetupRead then begin
            GLSetup.Get();
            SourceCodeSetup.Get();
            SetupRead := true;
        end;
        GLSetupShortcutDimCode[1] := GLSetup."Shortcut Dimension 1 Code";
        GLSetupShortcutDimCode[2] := GLSetup."Shortcut Dimension 2 Code";
        GLSetupShortcutDimCode[3] := GLSetup."Shortcut Dimension 3 Code";
        GLSetupShortcutDimCode[4] := GLSetup."Shortcut Dimension 4 Code";
        GLSetupShortcutDimCode[5] := GLSetup."Shortcut Dimension 5 Code";
        GLSetupShortcutDimCode[6] := GLSetup."Shortcut Dimension 6 Code";
        GLSetupShortcutDimCode[7] := GLSetup."Shortcut Dimension 7 Code";
        GLSetupShortcutDimCode[8] := GLSetup."Shortcut Dimension 8 Code";

    end;

    procedure SetSetups(NewGLSetup: Record "General Ledger Setup"; NewSourceCodeSetup: Record "Source Code Setup")
    begin
        GLSetup := NewGLSetup;
        SourceCodeSetup := NewSourceCodeSetup;
        SetupRead := true;
    end;

}