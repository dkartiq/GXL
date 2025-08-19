/// <summary>
/// CR099 - Revaluation Journal Batch
/// </summary>
report 50042 "GXL Import Item Reval. Wksh."
{
    Caption = 'Import Item Revaluation Worksheet';
    ProcessingOnly = true;

    dataset
    {
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group("CSV File")
                {
                    Caption = 'CSV File';
                    field(FirstDataRowNo; FirstDataRowNo)
                    {
                        ApplicationArea = All;
                        Caption = 'First Data Row No.';
                        MinValue = 1;
                    }
                }
                group("Worksheet Lines")
                {
                    Caption = 'Worksheet Lines';
                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Revaluation Date';
                        ShowMandatory = true;
                    }
                    field(NextDocNo; DocNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Document No.';
                        ShowMandatory = true;
                    }
                    field(ReasonCode; ReasonCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Reason Code';
                        TableRelation = "Reason Code";
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            if PostingDate = 0D then
                PostingDate := WorkDate();
            if FirstDataRowNo <= 0 then
                FirstDataRowNo := 1;
        end;

        trigger OnQueryClosePage(CloseAction: Action): Boolean
        var
            FileMgt: Codeunit "File Management";
        begin
            if CloseAction = ACTION::OK then begin
                if not CheckImportValues() then
                    exit(false);
                if ServerFileName = '' then
                    ServerFileName := FileMgt.UploadFile('Import Item Revaluation CSV File', FileExtensionTok);
                if ServerFileName = '' then
                    exit(false);
            end;
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        NewBatchID := 0;
    end;

    trigger OnPreReport()
    var
        GXLCalcWkshInvtValue: Report "GXL Calc. Wksh. Invt. Value";
    begin
        CheckImportValues();
        if ServerFileName = '' then
            Error('ServerFileName ?');
        if FirstDataRowNo <= 0 then
            FirstDataRowNo := 1;

        GLSetup.Get();

        DoImport();

        if (NewBatchID = 0) then begin
            Message('Nothing to import.');
        end else begin
            Commit();
            GXLCalcWkshInvtValue.InitializeRequest(NewBatchID, true);
            GXLCalcWkshInvtValue.UseRequestPage(false);
            GXLCalcWkshInvtValue.RunModal();
        end;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        PostingDate: Date;
        DocNo: Code[20];
        ReasonCode: Code[10];
        DocumentNoMissingErrMsg: Label 'You must enter a Document No.';
        PostingDateMissingErrMsg: Label 'You must enter a Revaluation Date';
        FirstDataRowNo: Integer;
        NewBatchID: Integer;
        ServerFileName: Text;
        FileExtensionTok: Label '.csv';

    local procedure DoImport()
    var
        RevalWkshBatch: Record "GXL Item Reval. Wksh. Batch";
        RevalWkshLine: Record "GXL Item Reval. Wksh. Line";
        TempRevalWkshLine: Record "GXL Item Reval. Wksh. Line" temporary;
        CSVBuffer: Record "CSV Buffer" temporary;
        CSVBuffer2: Record "CSV Buffer" temporary;
        Item: Record Item;
        InvtPostGrp: Record "Inventory Posting Group";
        GenProdPostGrp: Record "Gen. Product Posting Group";
        NewItemNo: Code[20];
        NewRevalUnitCost: Decimal;
        HasUnitCost: Boolean;
        NextLineNo: Integer;
        NewPostingDate: Date;
        NewInvtPostGrpCode: Code[20];
        NewGenProdPostGrpCode: Code[20];
    begin
        CSVBuffer.LoadData(ServerFileName, ',');
        if FirstDataRowNo > 1 then
            CSVBuffer.SetFilter("Line No.", '%1..', FirstDataRowNo);

        if not CSVBuffer.Find('-') then
            Error('No data found in file to import.');
        repeat
            CSVBuffer2.Copy(CSVBuffer, true);
            CSVBuffer2.SetRange("Line No.", CSVBuffer2."Line No.");
            NewItemNo := '';
            HasUnitCost := false;
            //ERP-320 +
            NewPostingDate := 0D;
            NewInvtPostGrpCode := '';
            NewGenProdPostGrpCode := '';
            //ERP-320 -
            repeat
                case CSVBuffer2."Field No." of
                    1:
                        begin
                            NewItemNo := CSVBuffer2.Value;
                            if not Item.Get(NewItemNo) then
                                Error('Item %2 does not exist (row %1)', CSVBuffer."Line No.", NewItemNo);
                        end;
                    2:
                        begin
                            CSVBuffer2.Value := DelChr(CSVBuffer2.Value, '=', '"');
                            if not Evaluate(NewRevalUnitCost, CSVBuffer2.Value) then
                                Error('New Unit Cost %2 is invalid (row %1)', CSVBuffer2."Line No.", CSVBuffer2.Value);
                            if (NewRevalUnitCost <= 0) or (NewRevalUnitCost <> Round(NewRevalUnitCost, GLSetup."Unit-Amount Rounding Precision")) then
                                Error('New Unit Cost %2 is invalid (row %1)', CSVBuffer2."Line No.", NewRevalUnitCost);
                            HasUnitCost := true;
                        end;
                    //ERP-320 +
                    3:
                        begin
                            CSVBuffer2.Value := DelChr(CSVBuffer2.Value, '=', '"');
                            if CSVBuffer2.Value <> '' then
                                if not Evaluate(NewPostingDate, CSVBuffer2.Value) then
                                    Error('Posting Date %2 is invalid (row %1)', CSVBuffer2."Line No.", CSVBuffer2.Value);
                        end;
                    4:
                        begin
                            NewInvtPostGrpCode := CSVBuffer2.Value;
                            if NewInvtPostGrpCode <> '' then
                                if not InvtPostGrp.Get(NewInvtPostGrpCode) then
                                    Error('Inventory Posting Group %2 is invalid (row %1)', CSVBuffer2."Line No.", NewInvtPostGrpCode);
                        end;
                    5:
                        begin
                            NewGenProdPostGrpCode := CSVBuffer2.Value;
                            if NewGenProdPostGrpCode <> '' then
                                if not GenProdPostGrp.Get(NewGenProdPostGrpCode) then
                                    Error('Gen. Product Posting Group %2 is invalid (row %1)', CSVBuffer2."Line No.", NewGenProdPostGrpCode);
                        end;
                //ERP-320 -
                end;
            until CSVBuffer2.Next() = 0;
            CSVBuffer := CSVBuffer2;

            if (NewItemNo <> '') xor HasUnitCost then
                Error('Item No. and new Unit Cost must both be specified (row %1)', CSVBuffer."Line No.");

            NextLineNo += 10;
            TempRevalWkshLine.Init();
            TempRevalWkshLine."Line No." := NextLineNo;
            TempRevalWkshLine."Item No." := Item."No.";
            TempRevalWkshLine."Unit of Measure Code" := Item."Base Unit of Measure";
            TempRevalWkshLine."Posting Date" := PostingDate;
            TempRevalWkshLine."Reason Code" := ReasonCode;
            TempRevalWkshLine."Document No." := DocNo;
            TempRevalWkshLine."Item Description" := Item.Description;
            TempRevalWkshLine."Unit Cost (Revalued)" := NewRevalUnitCost;
            //ERP-320 +
            if NewPostingDate <> 0D then
                TempRevalWkshLine."Posting Date" := NewPostingDate
            else
                if PostingDate = 0D then
                    TempRevalWkshLine."Posting Date" := WorkDate();
            TempRevalWkshLine."Inventory Posting Group" := NewInvtPostGrpCode;
            TempRevalWkshLine."Gen. Product Posting Group" := NewGenProdPostGrpCode;
            //ERP-320 -
            TempRevalWkshLine.Insert();
        until CSVBuffer.Next() = 0;

        if TempRevalWkshLine.FindSet then begin
            RevalWkshBatch.Init();
            RevalWkshBatch.Insert(true);
            NewBatchID := RevalWkshBatch."Batch ID";

            repeat
                RevalWkshLine := TempRevalWkshLine;
                RevalWkshLine."Batch ID" := NewBatchID;
                RevalWkshLine.Insert(true);
            until TempRevalWkshLine.Next = 0;
        end;
    end;

    [TryFunction]
    local procedure CheckImportValues()
    begin
        if DocNo = '' then
            Error(DocumentNoMissingErrMsg);
        //ERP-320 +
        //if PostingDate = 0D then
        //    Error(PostingDateMissingErrMsg);
        //ERP-320 -
    end;


    procedure GetNewBatchID() CreatedNewBatchID: Integer
    begin
        exit(NewBatchID);
    end;
}

