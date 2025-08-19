report 50016 "GXL ImportGenJnlFromExcel"
{
    /*
    PS-2284: import general journal lines from excel
    */

    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'Import General Journal from Excel';


    dataset
    {
    }

    requestpage
    {
        SaveValues = true;
        layout
        {
            area(Content)
            {
                group(ImportOptions)
                {
                    Caption = 'Import Options';
                    field(OpenJnlAfterImport; OpenJnlAfterImport)
                    {
                        Caption = 'Open Jnl. Batch after Import';
                        ToolTip = 'Specfies that if the general journal should be open after finish importing';
                        ApplicationArea = All;
                        Visible = not CalledFromPage;
                    }
                    field(FirstDataRowNoCtrl; FirstDataRowNo)
                    {
                        Caption = 'First Data Row No.';
                        ToolTip = 'Specifies the starting row number in the spreadsheet to be imported from';
                        ApplicationArea = All;
                        MinValue = 1;
                    }
                }
                group(ExcelImportTemplate)
                {
                    Caption = 'Excel Export Template';

                    field(ExportCtrl; ExportTemplate)
                    {
                        Caption = 'Export';
                        ToolTip = 'Export the excel template to be used for importing';
                        ApplicationArea = All;
                        ShowCaption = false;
                        trigger OnDrillDown()
                        begin
                            ExportExcelTemplate();
                        end;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if FirstDataRowNo <= 0 then
                FirstDataRowNo := 2;
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            ExcelBuf: Record "Excel Buffer" temporary;
        begin
            if CloseAction = Action::OK then begin
                ServerFileName := '';
                UploadIntoStream('Import excel file', '', 'Excel files (*.xlsx)|*.xlsx', ServerFileName, InS);
                if (ServerFileName = '') then
                    exit(false);
                SheetName := ExcelBuf.SelectSheetsNameStream(InS);
                if (SheetName = '') then
                    exit(false);
                exit(true);
            end;
        end;

    }

    trigger OnPreReport()
    begin
        ImportGenJnlBuffers();
    end;

    trigger OnPostReport()
    var
        GenJnlManagment: Codeunit GenJnlManagement;
    begin
        Commit();
        if (not CalledFromPage) and OpenJnlAfterImport and (NoOfLinesImported > 0) then
            GenJnlManagment.TemplateSelectionFromBatch(GenJnlBatch);

        Message('%1 General Journal Line(s) inserted', NoOfLinesImported);
    end;

    local procedure GetSetups()
    var
        i: Integer;
    begin
        if not SetupRead then begin
            GLSetup.Get();
            GLSetupShortcutDimCode[1] := GLSetup."Shortcut Dimension 1 Code";
            GLSetupShortcutDimCode[2] := GLSetup."Shortcut Dimension 2 Code";
            GLSetupShortcutDimCode[3] := GLSetup."Shortcut Dimension 3 Code";
            GLSetupShortcutDimCode[4] := GLSetup."Shortcut Dimension 4 Code";
            GLSetupShortcutDimCode[5] := GLSetup."Shortcut Dimension 5 Code";
            GLSetupShortcutDimCode[6] := GLSetup."Shortcut Dimension 6 Code";
            GLSetupShortcutDimCode[7] := GLSetup."Shortcut Dimension 7 Code";
            GLSetupShortcutDimCode[8] := GLSetup."Shortcut Dimension 8 Code";

            i := 0;
            Dim.Reset();
            if Dim.FindSet() then
                repeat
                    i += 1;
                    TempDimValue.Init();
                    TempDimValue."Dimension Code" := Dim.Code;
                    TempDimValue."Global Dimension No." := i;
                    TempDimValue.Insert();
                until Dim.Next() = 0;

            SetupRead := true;
        end;
    end;

    local procedure ImportGenJnlBuffers()
    var
        TempXLBuf: Record "Excel Buffer" temporary;
        TempGenJnlLine: Record "Gen. Journal Line" temporary;
        Window: Dialog;
        TotalRecNo: Integer;
        RecNo: Integer;
        ShortcutDimCode: ARRAY[8] of Code[20];
        CellValue: Text;
        CellID: Text;
        PrevRowNo: Integer;
    begin
        if FirstDataRowNo <= 0 then
            Error('You must specify the first data row no.');

        GetSetups();
        InitColumnFieldMapping(true, TempXLBuf);

        TempXLBuf.OpenBookStream(InS, SheetName);
        TempXLBuf.ReadSheet();
        Window.OPEN('General Journal Import...\\Progress @1@@@@@@@@@@@@@@@@@@@@@@@@@');
        Window.UPDATE(1, 0);
        TotalRecNo := TempXLBuf.Count();
        RecNo := 0;
        NoOfLinesImported := 0;
        PendingTempLineToInsert := false;
        PrevRowNo := 0;

        TempXLBuf.SetFilter("Row No.", '>=%1', FirstDataRowNo);
        if TempXLBuf.Find('-') then begin
            repeat
                RecNo := RecNo + 1;
                if (TempXLBuf."Row No." > PrevRowNo) then
                    Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));

                if (TempXLBuf."Row No." > PrevRowNo) and PendingTempLineToInsert and (PrevRowNo > 0) then
                    InsertGenlJnlLine(TempGenJnlLine, TempDimSetEntry, ShortcutDimCode);

                if ColFieldMapping.Get(TempXLBuf."Column No.") then begin
                    CellID := StrSubstNo('%1%2', TempXLBuf.xlColID, TempXLBuf.xlRowID);
                    CleanTheCellValue(TempXLBuf);
                    CellValue := TempXLBuf."Cell Value as Text";
                    if (CellValue <> '') then
                        if not ValidateCellValue(TempXLBuf."Row No.", CellValue, ColFieldMapping."Field No.", TempGenJnlLine, TempDimSetEntry, ShortcutDimCode) then
                            Error('Cell %1 ''%2'' : %3', CellID, ColFieldMapping."New Value", GetLastErrorText());

                end;
                PrevRowNo := TempXLBuf."Row No.";
            until TempXLBuf.Next() = 0;
            if PendingTempLineToInsert then
                InsertGenlJnlLine(TempGenJnlLine, TempDimSetEntry, ShortcutDimCode);
        end;
        TempXLBuf.Reset();
        Window.Close();
    end;

    [TryFunction]
    local procedure ValidateCellValue(RowNo: Integer; CellValue: Text; ColFieldNo: Integer; var TempGenJnlLine: Record "Gen. Journal Line" temporary; var TempDimSetEntry: Record "Dimension Set Entry" temporary; var ShortcutDimCode: array[8] of Code[20])
    var
        DateVar: Date;
        DecVar: Decimal;
        IntVar: Integer;
    begin
        PendingTempLineToInsert := true;
        RowFieldWithValue.Init();
        RowFieldWithValue.Number := ColFieldNo;
        RowFieldWithValue.Insert();

        TempGenJnlLine."Adjmt. Entry No." := RowNo;
        case ColFieldNo of
            TempGenJnlLine.FieldNo("Journal Template Name"):
                TempGenJnlLine."Journal Template Name" := CellValue;
            TempGenJnlLine.FieldNo("Journal Batch Name"):
                TempGenJnlLine."Journal Batch Name" := CellValue;
            TempGenJnlLine.FieldNo("Line No."):
                begin
                    Evaluate(IntVar, CellValue);
                    TempGenJnlLine."Line No." := IntVar;
                end;
            TempGenJnlLine.FieldNo("Account Type"):
                if not Evaluate(TempGenJnlLine."Account Type", CellValue) then
                    TempGenJnlLine."Account Type" := TempGenJnlLine."Account Type"::"G/L Account";
            TempGenJnlLine.FieldNo("Account No."):
                TempGenJnlLine."Account No." := CellValue;
            TempGenJnlLine.FieldNo("Posting Date"):
                begin
                    Evaluate(DateVar, CellValue);
                    TempGenJnlLine."Posting Date" := DateVar;
                end;

            TempGenJnlLine.FieldNo("Document Type"):
                if Evaluate(TempGenJnlLine."Document Type", CellValue) then
                    ;
            TempGenJnlLine.FieldNo("Document No."):
                TempGenJnlLine."Document No." := CellValue;

            TempGenJnlLine.FieldNo(Description):
                TempGenJnlLine.Description := COPYSTR(CellValue, 1, MAXStrLen(TempGenJnlLine.Description));

            TempGenJnlLine.FieldNo(Amount):
                begin
                    Evaluate(DecVar, CellValue);
                    if (DecVar <> ROUND(DecVar, 0.01)) then
                        Error('Max. 2 decimals allowed');
                    TempGenJnlLine.Amount := DecVar;
                end;
            TempGenJnlLine.FieldNo(TempGenJnlLine."Document Date"):
                begin
                    Evaluate(DateVar, CellValue);
                    TempGenJnlLine."Document Date" := DateVar;
                end;
            TempGenJnlLine.FieldNo("External Document No."):
                TempGenJnlLine."External Document No." := CellValue;

            TempGenJnlLine.FieldNo("Bal. Account Type"):
                if Evaluate(TempGenJnlLine."Bal. Account Type", CellValue) then
                    ;
            TempGenJnlLine.FieldNo("Bal. Account No."):
                TempGenJnlLine."Bal. Account No." := CellValue;

            TempGenJnlLine.FieldNo("Source Code"):
                TempGenJnlLine."Source Code" := CellValue;

            else
                if (ColFieldNo < 0) and (CellValue <> '') then begin
                    //Dim columns are negative
                    ColFieldNo := -ColFieldNo;
                    if StrLen(CellValue) > MaxStrLen(TempGenJnlLine."Shortcut Dimension 1 Code") then
                        Error('The cell contains more than max. %1 characters', MaxStrLen(TempGenJnlLine."Shortcut Dimension 1 Code"));

                    TempDimValue.Reset();
                    TempDimValue.SetRange("Global Dimension No.", ColFieldNo);
                    TempDimValue.FindFirst();

                    TempDimSetEntry.Init();
                    TempDimSetEntry."Dimension Set ID" := 0;
                    TempDimSetEntry."Dimension Code" := TempDimValue."Dimension Code";
                    TempDimSetEntry.Validate("Dimension Value Code", CellValue);
                    TempDimSetEntry.Insert();

                    if TempDimValue."Dimension Code" = GLSetupShortcutDimCode[1] then
                        ShortcutDimCode[1] := CellValue;
                    if TempDimValue."Dimension Code" = GLSetupShortcutDimCode[2] then
                        ShortcutDimCode[2] := CellValue;
                end;

        end;

    end;

    [TryFunction]
    local procedure CheckOnInsertGenlJnlLine(var TempGenJnlLine: Record "Gen. Journal Line" temporary; var TempDimSetEntry: Record "Dimension Set Entry" temporary)
    var
        GLAcc: Record "G/L Account";
        DimNo: Integer;
    begin
        if TempGenJnlLine."Journal Template Name" = '' then
            Error(TheFieldIsMandatoryErr, TempGenJnlLine.FieldCaption("Journal Template Name"));
        if GenJnlTemplate.Name <> TempGenJnlLine."Journal Template Name" then
            GenJnlTemplate.Get(TempGenJnlLine."Journal Template Name");

        if TempGenJnlLine."Journal Batch Name" = '' then
            Error(TheFieldIsMandatoryErr, TempGenJnlLine.FieldCaption("Journal Batch Name"));
        if (GenJnlBatch."Journal Template Name" <> TempGenJnlLine."Journal Template Name") or (GenJnlBatch.Name <> TempGenJnlLine."Journal Batch Name") then
            GenJnlBatch.Get(TempGenJnlLine."Journal Template Name", TempGenJnlLine."Journal Batch Name");

        if TempGenJnlLine."Account No." = '' then
            Error(TheFieldIsMandatoryErr, TempGenJnlLine.FieldCaption("Account No."));
        GLAcc.Get(TempGenJnlLine."Account No.");
        GLAcc.TestField(Blocked, false);

        if TempGenJnlLine."Line No." = 0 then
            Error(TheFieldIsMandatoryErr, TempGenJnlLine.FieldCaption("Line No."));
        if TempGenJnlLine."Document No." = '' then
            Error(TheFieldIsMandatoryErr, TempGenJnlLine.FieldCaption("Document No."));
        if TempGenJnlLine."Posting Date" = 0D then
            Error(TheFieldIsMandatoryErr, TempGenJnlLine.FieldCaption("Posting Date"));
        if TempGenJnlLine.Amount = 0 then
            Error(TheFieldIsMandatoryErr, TempGenJnlLine.FieldCaption(Amount));
        if TempGenJnlLine.Description = '' then
            Error(TheFieldIsMandatoryErr, TempGenJnlLine.FieldCaption(Description));
        if TempGenJnlLine."Document Date" = 0D then
            Error(TheFieldIsMandatoryErr, TempGenJnlLine.FieldCaption("Document Date"));

    end;

    local procedure InsertGenlJnlLine(var TempGenJnlLine: Record "Gen. Journal Line" temporary; var TempDimSetEntry: Record "Dimension Set Entry" temporary; var ShortcutDimCode: array[8] of Code[20])
    begin
        if not CheckOnInsertGenlJnlLine(TempGenJnlLine, TempDimSetEntry) then
            Error('Row %1 : %2', TempGenJnlLine."Line No.", GetLastErrorText());

        GenJnlLine.Init();
        GenJnlLine."Journal Template Name" := TempGenJnlLine."Journal Template Name";
        GenJnlLine."Journal Batch Name" := TempGenJnlLine."Journal Batch Name";
        GenJnlLine."Source Code" := GenJnlTemplate."Source Code";
        GenJnlLine."Reason Code" := GenJnlBatch."Reason Code";
        GenJnlLine."Line No." := TempGenJnlLine."Line No.";
        GenJnlLine."Account Type" := TempGenJnlLine."Account Type";
        GenJnlLine.Validate("Account No.", TempGenJnlLine."Account No.");
        GenJnlLine."Document No." := TempGenJnlLine."Document No.";
        GenJnlLine.Validate("Posting Date", TempGenJnlLine."Posting Date");
        if TempGenJnlLine."Document Date" <> 0D then
            GenJnlLine.Validate("Document Date", TempGenJnlLine."Document Date")
        else
            GenJnlLine.Validate("Document Date", TempGenJnlLine."Posting Date");
        GenJnlLine.Description := TempGenJnlLine.Description;
        GenJnlLine."External Document No." := TempGenJnlLine."External Document No.";
        GenJnlLine.Validate(Amount, TempGenJnlLine.Amount);

        GenJnlLine."Shortcut Dimension 1 Code" := ShortcutDimCode[1];
        GenJnlLine."Shortcut Dimension 2 Code" := ShortcutDimCode[2];
        GenJnlLine."Dimension Set ID" := DimensionMgt.GetDimensionSetID(TempDimSetEntry);
        GenJnlLine.Insert(true);

        NoOfLinesImported := NoOfLinesImported + 1;
        PendingTempLineToInsert := false;
        Clear(TempGenJnlLine);
        Clear(ShortcutDimCode);
        TempDimSetEntry.Reset();
        TempDimSetEntry.DeleteAll();
        RowFieldWithValue.DeleteAll();

    end;

    local procedure CleanTheCellValue(var TempXLBuf: Record "Excel Buffer" temporary)
    var
        i: Integer;
        NewCellValueTxt: Text;
    begin
        TempXLBuf."Cell Value as Text" := DelChr(TempXLBuf."Cell Value as Text", '<>', ' ');
        if (TempXLBuf."Cell Value as Text" = '') then
            EXIT;
        for i := 1 to StrLen(TempXLBuf."Cell Value as Text") do
            if TempXLBuf."Cell Value as Text"[i] >= 32 then // Skip tab, crlf etc.
                NewCellValueTxt := NewCellValueTxt + COPYSTR(TempXLBuf."Cell Value as Text", i, 1);

        TempXLBuf."Cell Value as Text" := NewCellValueTxt;
    end;

    local procedure ExportExcelTemplate()
    var
        TempXLBuf: Record "Excel Buffer" temporary;
        TempXLBuf2: Record "Excel Buffer" temporary;
    begin
        GetSetups();
        InitColumnFieldMapping(ShowDimCodeOnExport, TempXLBuf);
        ColFieldMapping.FindSet();
        repeat
            TempXLBuf.Init();
            TempXLBuf.Validate("Row No.", 1);
            TempXLBuf.Validate("Column No.", ColFieldMapping."Entry No.");
            TempXLBuf."Cell Value as Text" := ColFieldMapping."New Value";
            TempXLBuf.Comment := ColFieldMapping."Old Value";
            TempXLBuf.Bold := true;
            TempXLBuf."Cell Type" := TempXLBuf."Cell Type"::Text;
            TempXLBuf.Insert();
            TempXLBuf2 := TempXLBuf;
            TempXLBuf2.Insert();

        until ColFieldMapping.Next() = 0;

        TempXLBuf.NewRow();
        TempXLBuf.AddInfoColumn('Column', false, true, false, false, '', TempXLBuf."Cell Type"::Text);
        TempXLBuf.AddInfoColumn('Field Name', false, true, false, false, '', TempXLBuf."Cell Type"::Text);
        TempXLBuf.AddInfoColumn('Notes', false, true, false, false, '', TempXLBuf."Cell Type"::Text);
        TempXLBuf2.FindSet();
        repeat
            TempXLBuf.NewRow();
            TempXLBuf.AddInfoColumn(TempXLBuf2.xlColID, false, false, false, false, '', TempXLBuf."Cell Type"::Text);
            TempXLBuf.AddInfoColumn(TempXLBuf2."Cell Value as Text", false, false, false, false, '', TempXLBuf."Cell Type"::Text);
            TempXLBuf.AddInfoColumn(TempXLBuf2.Comment, false, false, false, false, '', TempXLBuf."Cell Type"::Text);
        until TempXLBuf2.Next() = 0;

        TempXLBuf.CreateNewBook('General Journal');
        TempXLBuf.SetUseInfoSheet();
        TempXLBuf.WriteSheet('General Journal', 'Import Template', '');
        TempXLBuf.CloseBook();
        TempXLBuf.OpenExcel();
    end;

    local procedure InitColumnFieldMapping(ShowDimCodeCaptions: Boolean; var TempXLBuf: Record "Excel Buffer" temporary)
    var
        GenJnlLine2: Record "Gen. Journal Line";
        DimNo: Integer;
        DimCodeCaption: Text;
        i: Integer;
    begin
        Clear(TempXLBuf);
        TempXLBuf.DeleteAll();
        Clear(ColFieldMapping);
        ColFieldMapping.DeleteAll();
        i := 0;

        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Journal Template Name"), GenJnlLine2.FieldCaption("Journal Template Name"), 'Mandatory');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Journal Batch Name"), GenJnlLine2.FieldCaption("Journal Batch Name"), 'Mandatory');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Line No."), GenJnlLine2.FieldCaption("Line No."), 'Mandatory');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Account Type"), GenJnlLine2.FieldCaption("Account Type"), 'Mandatory');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Account No."), GenJnlLine2.FieldCaption("Account No."), 'Mandatory');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Posting Date"), GenJnlLine2.FieldCaption("Posting Date"), 'Mandatory');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Document Type"), GenJnlLine2.FieldCaption("Document Type"), '');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Document No."), GenJnlLine2.FieldCaption("Document No."), 'Mandatory');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo(Description), GenJnlLine2.FieldCaption(Description), 'Mandatory');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Bal. Account No."), GenJnlLine2.FieldCaption("Bal. Account No."), '');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Currency Code"), GenJnlLine2.FieldCaption("Currency Code"), '');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo(Amount), GenJnlLine2.FieldCaption(Amount), 'Mandatory');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Currency Factor"), GenJnlLine2.FieldCaption("Currency Factor"), '');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Source Code"), GenJnlLine2.FieldCaption("Source Code"), '');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Due Date"), GenJnlLine2.FieldCaption("Due Date"), '');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Bal. Account Type"), GenJnlLine2.FieldCaption("Bal. Account Type"), '');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("Document Date"), GenJnlLine2.FieldCaption("Document Date"), 'Mandatory');
        i += 1;
        SetColFieldMapping(i, GenJnlLine2.FieldNo("External Document No."), GenJnlLine2.FieldCaption("External Document No."), '');

        // Dim Col:
        DimNo := 0;
        Dim.Reset();
        if Dim.FindSet() then
            repeat
                DimNo += 1;

                i += 1;
                DimCodeCaption := Dim."Code Caption" + ' (' + Dim.TableCaption() + ')';
                SetColFieldMapping(i, -DimNo, DimCodeCaption, '');

            until Dim.Next() = 0;

    end;

    local procedure SetColFieldMapping(ColNo: Integer; TheFieldNo: Integer; TheFieldCaption: Text; TheFieldDescription: Text)
    begin
        Clear(ColFieldMapping);
        ColFieldMapping."Entry No." := ColNo;
        ColFieldMapping."Field No." := TheFieldNo;
        ColFieldMapping."New Value" := TheFieldCaption;
        ColFieldMapping."Old Value" := TheFieldDescription;
        ColFieldMapping.Insert();

    end;

    local procedure GetNextLineNo(TemplateName: Code[10]; BatchName: Code[10]): Integer
    var
        GenJnlLine2: Record "Gen. Journal Line";
    begin
        if (GenJnlTemplateName <> TemplateName) or (GenJnlBatchName <> BatchName) or (LastLineNo = 0) then begin
            GenJnlLine2.SetRange("Journal Template Name", TemplateName);
            GenJnlLine2.SetRange("Journal Batch Name", BatchName);
            if GenJnlLine2.FindLast() then
                LastLineNo := GenJnlLine2."Line No."
            else
                LastLineNo := 0;
            GenJnlTemplateName := TemplateName;
            GenJnlBatchName := BatchName;
        end;
        LastLineNo += 1;
        exit(LastLineNo);
    end;

    procedure SetCallFromPage(NewCalledFromPage: Boolean)
    begin
        CalledFromPage := NewCalledFromPage;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        ColFieldMapping: Record "Change Log Entry" temporary;
        RowFieldWithValue: Record "Integer" temporary;
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Dim: Record Dimension;
        TempDimValue: Record "Dimension Value" temporary;
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimensionMgt: Codeunit DimensionManagement;
        InS: InStream;
        NextLineNo: Integer;
        ShowDimCodeOnExport: Boolean;
        ServerFileName: Text;
        SheetName: Text;
        GLSetupShortcutDimCode: array[8] of Code[20];
        FirstDataRowNo: Integer;
        PendingTempLineToInsert: Boolean;
        NoOfLinesImported: Integer;
        ExportTemplate: Text;
        OpenJnlAfterImport: Boolean;
        CalledFromPage: Boolean;
        SetupRead: Boolean;
        LastLineNo: Integer;
        GenJnlTemplateName: Code[10];
        GenJnlBatchName: Code[10];
        TheFieldIsMandatoryErr: Label 'The %1 is mandatory';
}