//CR050: PS-1948 External stocktake
report 50014 "GXL ImportExtStocktakeFrExcel"
{
    UsageCategory = Tasks;
    ApplicationArea = All;
    ProcessingOnly = true;
    Caption = 'Import External Stocktake from Excel';


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
                    field(FirstDataRowNoCtrl; FirstDataRowNo)
                    {
                        Caption = 'First Data Row No.';
                        ToolTip = 'Specifies the starting row number in the spreadsheet to be imported from';
                        ApplicationArea = All;
                        MinValue = 1;
                    }
                    field(DocNoCtrl; DocNo)
                    {
                        Caption = 'Document No.';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(PostingDateCtrl; PostingDate)
                    {
                        Caption = 'Posting Date';
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field(LocCodeCtrl; LocCode)
                    {
                        Caption = 'Location Code';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        TableRelation = Location;
                    }
                    field(GenProdPostGrpCtrl; GenProdPostGrpCode)
                    {
                        Caption = 'Gen. Prod. Posting Group';
                        ApplicationArea = All;
                        TableRelation = "Gen. Product Posting Group";
                    }
                    field(Dim2CodeCtrl; Dim2Code)
                    {
                        Caption = 'Shortcut Dimension 2 Code';
                        CaptionClass = '1,2,2';
                        ApplicationArea = All;
                        ShowMandatory = true;
                        TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
                    }
                    field(ReasonCodeCtrl; ReasonCode)
                    {
                        Caption = 'Reason Code';
                        ApplicationArea = All;
                        TableRelation = "Reason Code";
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
                    field(ShowDimCodeOnExportCtrl; ShowDimCodeOnExport)
                    {
                        Caption = 'Show Company Dim. Code Captions';
                        ToolTip = 'Specifies the company dimension caption will be used in the import file';
                        ApplicationArea = All;
                        Visible = false;
                    }
                }
            }
        }

        trigger OnOpenPage()
        begin
            if FirstDataRowNo <= 0 then
                FirstDataRowNo := 2;
            DocNo := '';
            PostingDate := 0D;
            LocCode := '';
            Dim2Code := '';
            if GenProdPostGrpCode <> '' then
                if not GenProdPostGroup.Get(GenProdPostGrpCode) then
                    GenProdPostGrpCode := '';
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
        GLSetup.Get();
        if DocNo = '' then
            Error('You must enter Document No.');
        if PostingDate = 0D then
            Error('You must enter Posting Date');
        if LocCode = '' then
            Error('You must enter Location Code');
        if Dim2Code = '' then
            Error('You must enter %1', GLSetup."Global Dimension 2 Code");

        GLSetupShortcutDimCode[1] := GLSetup."Shortcut Dimension 1 Code";
        GLSetupShortcutDimCode[2] := GLSetup."Shortcut Dimension 2 Code";
        GLSetupShortcutDimCode[3] := GLSetup."Shortcut Dimension 3 Code";
        GLSetupShortcutDimCode[4] := GLSetup."Shortcut Dimension 4 Code";
        GLSetupShortcutDimCode[5] := GLSetup."Shortcut Dimension 5 Code";
        GLSetupShortcutDimCode[6] := GLSetup."Shortcut Dimension 6 Code";
        GLSetupShortcutDimCode[7] := GLSetup."Shortcut Dimension 7 Code";
        GLSetupShortcutDimCode[8] := GLSetup."Shortcut Dimension 8 Code";


        ImportExtStocktakeLines();
    end;

    trigger OnPostReport()
    var
    begin
        Commit();
        Message('%1 External Stocktake Line(s) inserted', NoOfLinesImported);
    end;

    local procedure ImportExtStocktakeLines()
    var
        TempXLBuf: Record "Excel Buffer" temporary;
        TempExtStocktakeLine: Record "GXL External Stocktake Line" temporary;
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

        InitColumnFieldMapping(true, TempXLBuf);

        TempXLBuf.OpenBookStream(InS, SheetName);
        TempXLBuf.ReadSheet();
        Window.OPEN('External Stocktake Import...\\Progress @1@@@@@@@@@@@@@@@@@@@@@@@@@');
        Window.UPDATE(1, 0);
        TotalRecNo := TempXLBuf.Count();
        RecNo := 0;
        NoOfLinesImported := 0;
        PendingTempLineToInsert := false;


        TempXLBuf.SetFilter("Row No.", '>=%1', FirstDataRowNo);
        if TempXLBuf.Find('-') then begin
            BatchID := InsertExtStocktakeLineBatch();
            repeat
                RecNo := RecNo + 1;
                if (TempXLBuf."Row No." > PrevRowNo) then
                    Window.UPDATE(1, ROUND(RecNo / TotalRecNo * 10000, 1));

                if (TempXLBuf."Row No." > PrevRowNo) and PendingTempLineToInsert and (PrevRowNo > 0) then
                    InsertExtStocktakeLine(TempExtStocktakeLine, ShortcutDimCode);

                if ColFieldMapping.Get(TempXLBuf."Column No.") then begin
                    CellID := StrSubstNo('%1%2', TempXLBuf.xlColID, TempXLBuf.xlRowID);
                    CleanTheCellValue(TempXLBuf);
                    CellValue := TempXLBuf."Cell Value as Text";
                    if (CellValue <> '') then
                        if not ValidateCellValue(TempXLBuf."Row No.", CellValue, ColFieldMapping."Field No.", TempExtStocktakeLine, ShortcutDimCode) then
                            Error('Cell %1 ''%2'' : %3', CellID, ColFieldMapping."New Value", GetLastErrorText());

                end;
                PrevRowNo := TempXLBuf."Row No.";
            until TempXLBuf.Next() = 0;
            if PendingTempLineToInsert then
                InsertExtStocktakeLine(TempExtStocktakeLine, ShortcutDimCode);
        end;
        TempXLBuf.Reset();
        Window.Close();
    end;

    [TryFunction]
    local procedure ValidateCellValue(RowNo: Integer; CellValue: Text; ColFieldNo: Integer; var TempExtStocktakeLine: Record "GXL External Stocktake Line" temporary; var ShortcutDimCode: ARRAY[8] of Code[20])
    var
        DateVar: Date;
        DecVar: Decimal;
    begin
        PendingTempLineToInsert := true;
        RowFieldWithValue.Init();
        RowFieldWithValue.Number := ColFieldNo;
        RowFieldWithValue.Insert();
        TempExtStocktakeLine."Line No." := RowNo;
        case ColFieldNo of
            TempExtStocktakeLine.FieldNo("Posting Date"):
                begin
                    Evaluate(DateVar, CellValue);
                    TempExtStocktakeLine."Posting Date" := DateVar;
                end;
            TempExtStocktakeLine.FieldNo("Entry Type"):
                begin
                    Evaluate(TempExtStocktakeLine."Entry Type", CellValue);
                end;
            TempExtStocktakeLine.FieldNo("Document No."):
                begin
                    TempExtStocktakeLine."Document No." := CellValue;
                end;
            TempExtStocktakeLine.FieldNo("Legacy Item No."):
                begin
                    TempExtStocktakeLine."Legacy Item No." := CellValue;
                end;
            TempExtStocktakeLine.FieldNo(Description):
                TempExtStocktakeLine.Description := COPYSTR(CellValue, 1, MAXStrLen(TempExtStocktakeLine.Description));
            TempExtStocktakeLine.FieldNo(Quantity):
                begin
                    Evaluate(DecVar, CellValue);
                    if (DecVar <> ROUND(DecVar, 0.00001)) then
                        Error('Max. 5 decimals allowed');
                    TempExtStocktakeLine."Qty. (Phys. Inventory)" := DecVar;
                    TempExtStocktakeLine.Validate("Qty. (Phys. Inventory)");
                end;
            TempExtStocktakeLine.FieldNo("Location Code"):
                begin
                    Location.Get(CellValue);
                    Location.TestField("Use As In-Transit", false);
                    TempExtStocktakeLine."Location Code" := CellValue;
                end;
            TempExtStocktakeLine.FieldNo("Source Code"):
                begin
                    TempExtStocktakeLine."Source Code" := CellValue;
                end;
            TempExtStocktakeLine.FieldNo("Gen. Prod. Posting Group"):
                begin
                    TempExtStocktakeLine."Gen. Prod. Posting Group" := CellValue;
                end;
            TempExtStocktakeLine.FieldNo("Document Date"):
                begin
                    Evaluate(DateVar, CellValue);
                    TempExtStocktakeLine."Document Date" := DateVar;
                end;
            else
                if (ColFieldNo < 0) then begin
                    //Dim columns are negative
                    ColFieldNo := -ColFieldNo;
                    if StrLen(CellValue) > MAXStrLen(TempExtStocktakeLine."Shortcut Dimension 1 Code") then
                        Error('The cell contains more than max. %1 characters', MAXStrLen(TempExtStocktakeLine."Shortcut Dimension 1 Code"));
                    if GLSetupShortcutDimCode[ColFieldNo] = '' then
                        Error('Shortcut Dimension %1 is not defined in the %2', ColFieldNo, GLSetup.TABLECAPTION());
                    DimensionMgt.CheckDimValue(GLSetupShortcutDimCode[ColFieldNo], CellValue);
                    ShortcutDimCode[ColFieldNo] := CellValue;
                end;

        end;
    end;

    [TryFunction]
    local procedure CheckOnInsertExtStocktakeLine(var TempExtStocktakeLine: Record "GXL External Stocktake Line" temporary; var ShortcutDimCode: ARRAY[8] of Code[20])
    begin
    end;

    local procedure InsertExtStocktakeLine(var TempExtStocktakeLine: Record "GXL External Stocktake Line" temporary; var ShortcutDimCode: ARRAY[8] of Code[20])
    var
        ItemUOM: Record "Item Unit of Measure";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        DimNo: Integer;
    begin
        if not CheckOnInsertExtStocktakeLine(TempExtStocktakeLine, ShortcutDimCode) then
            Error('Row %1 : %2', TempExtStocktakeLine."Line No.", GetLastErrorText());

        NextLineNo := NextLineNo + 10000;
        ExtStocktakeLine.Init();
        ExtStocktakeLine.TransferFields(TempExtStocktakeLine);
        ExtStocktakeLine."Batch ID" := BatchID;
        ExtStocktakeLine."Line No." := ExtStocktakeLine."Line No.";

        for DimNo := 1 to 8 do
            if ShortcutDimCode[DimNo] <> '' then
                case DimNo of
                    1:
                        ExtStocktakeLine."Shortcut Dimension 1 Code" := ShortcutDimCode[DimNo];
                    2:
                        ExtStocktakeLine."Shortcut Dimension 2 Code" := ShortcutDimCode[DimNo];
                    3:
                        ExtStocktakeLine."Shortcut Dimension 3 Code" := ShortcutDimCode[DimNo];
                    4:
                        ExtStocktakeLine."Shortcut Dimension 4 Code" := ShortcutDimCode[DimNo];
                    5:
                        ExtStocktakeLine."Shortcut Dimension 5 Code" := ShortcutDimCode[DimNo];
                    6:
                        ExtStocktakeLine."Shortcut Dimension 6 Code" := ShortcutDimCode[DimNo];
                    7:
                        ExtStocktakeLine."Shortcut Dimension 7 Code" := ShortcutDimCode[DimNo];
                    8:
                        ExtStocktakeLine."Shortcut Dimension 8 Code" := ShortcutDimCode[DimNo];
                end;

        ExtStocktakeLine."Entry Type" := ExtStocktakeLine."Entry Type"::"Positive Adjmt.";
        ExtStocktakeLine."Document No." := DocNo;
        ExtStocktakeLine."Posting Date" := PostingDate;
        ExtStocktakeLine."Location Code" := LocCode;
        ExtStocktakeLine."Shortcut Dimension 2 Code" := Dim2Code;
        ExtStocktakeLine."Gen. Prod. Posting Group" := GenProdPostGrpCode;
        ExtStocktakeLine."Reason Code" := ReasonCode;
        if LegacyItemHelpers.GetItemUOM(ExtStocktakeLine."Legacy Item No.", ItemUOM) then begin
            ExtStocktakeLine."Item No." := ItemUOM."Item No.";
            ExtStocktakeLine."Unit of Measure Code" := ItemUOM.Code;
            ExtStocktakeLine."Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
            ExtStocktakeLine.Validate("Qty. (Phys. Inventory)");
            ExtStocktakeLine.CalculateInventory();
        end;

        ExtStocktakeLine.Insert(true);

        NoOfLinesImported := NoOfLinesImported + 1;
        PendingTempLineToInsert := false;
        Clear(TempExtStocktakeLine);
        Clear(ShortcutDimCode);
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

        TempXLBuf.CreateNewBook('External Stocktake');
        TempXLBuf.SetUseInfoSheet();
        TempXLBuf.WriteSheet('External Stocktake', 'Import Template', '');
        TempXLBuf.CloseBook();
        TempXLBuf.OpenExcel();
    end;

    local procedure InitColumnFieldMapping(ShowDimCodeCaptions: Boolean; var TempXLBuf: Record "Excel Buffer" temporary)
    var
        ExtStocktakeLine2: Record "GXL External Stocktake Line";
        i: Integer;
    begin
        Clear(TempXLBuf);
        TempXLBuf.DeleteAll();
        Clear(ColFieldMapping);
        ColFieldMapping.DeleteAll();
        i := 0;
        i += 1;
        SetColFieldMapping(i, ExtStocktakeLine2.FieldNo("Legacy Item No."), ExtStocktakeLine2.FieldCaption("Legacy Item No."), 'Mandatory');
        i += 1;
        SetColFieldMapping(i, ExtStocktakeLine2.FieldNo(Quantity), ExtStocktakeLine2.FieldCaption(Quantity), 'Mandatory');

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

    local procedure InsertExtStocktakeLineBatch(): Integer
    var
        ExtStocktakeBatch: Record "GXL External Stocktake Batch";
        LastBatchID: Integer;
    begin
        ExtStocktakeBatch.Reset();
        if ExtStocktakeBatch.FindLast() then
            LastBatchID := ExtStocktakeBatch."Batch ID";
        LastBatchID := LastBatchID + 1;
        ExtStocktakeBatch.Init();
        ExtStocktakeBatch."Batch ID" := LastBatchID;
        ExtStocktakeBatch."Imported Date Time" := CurrentDateTime();
        ExtStocktakeBatch."Imported by User ID" := UserId();
        ExtStocktakeBatch."Location Code" := LocCode;
        ExtStocktakeBatch.Insert(true);
        exit(ExtStocktakeBatch."Batch ID");
    end;

    var
        GLSetup: Record "General Ledger Setup";
        ColFieldMapping: Record "Change Log Entry" temporary;
        RowFieldWithValue: Record "Integer" temporary;
        ExtStocktakeLine: Record "GXL External Stocktake Line";
        Location: Record Location;
        GenProdPostGroup: Record "Gen. Product Posting Group";
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
        BatchID: Integer;
        DocNo: Code[20];
        PostingDate: Date;
        LocCode: Code[10];
        Dim2Code: Code[20];
        GenProdPostGrpCode: Code[20];
        ReasonCode: Code[10];
}