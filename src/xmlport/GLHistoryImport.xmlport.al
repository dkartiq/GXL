xmlport 50003 "GXL GL History Import"
{
    /*Change Log
        ERP-204 GL History Batches
    */

    Caption = 'G/L History Import';
    Format = VariableText;
    FormatEvaluate = Legacy;
    Direction = Import;

    schema
    {
        textelement(Root)
        {
            tableelement("GXL GL History Line"; "GXL GL History Line")
            {
                XmlName = 'Import';
                fieldelement(TemplateName; "GXL GL History Line"."Journal Template Name")
                {
                }
                fieldelement(AccountNo; "GXL GL History Line"."Account No.")
                {
                }
                fieldelement(PostingDate; "GXL GL History Line"."Posting Date")
                {
                }
                fieldelement(DocumentNo; "GXL GL History Line"."Document No.")
                {
                }
                fieldelement(Description; "GXL GL History Line".Description)
                {
                }
                fieldelement(Amount; "GXL GL History Line".Amount)
                {
                }
                fieldelement(Dim1Code; "GXL GL History Line"."Shortcut Dimension 1 Code")
                {
                }
                fieldelement(Dim2Code; "GXL GL History Line"."Shortcut Dimension 2 Code")
                {
                }
                fieldelement(BatchName; "GXL GL History Line"."Journal Batch Name")
                {
                }
                fieldelement(DocumentDate; "GXL GL History Line"."Document Date")
                {
                }
                fieldelement(Reverse; "GXL GL History Line".Reverse)
                {
                    MinOccurs = Zero;
                }
                fieldelement(ReverseDate; "GXL GL History Line"."Reverse Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ExtDocNo; "GXL GL History Line"."External Document No.")
                {
                }
                fieldelement(Dim3Code; "GXL GL History Line"."Shortcut Dimension 3 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(Dim4Code; "GXL GL History Line"."Shortcut Dimension 4 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(Dim5Code; "GXL GL History Line"."Shortcut Dimension 5 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(Dim6Code; "GXL GL History Line"."Shortcut Dimension 6 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(Dim7Code; "GXL GL History Line"."Shortcut Dimension 7 Code")
                {
                    MinOccurs = Zero;
                }
                fieldelement(Dim8Code; "GXL GL History Line"."Shortcut Dimension 8 Code")
                {
                    MinOccurs = Zero;
                }


                trigger OnBeforeInsertRecord()
                begin
                    if BatchID = 0 then
                        BatchID := InsertGLHistoryBatch();
                    intNo := GetNextNo();

                    CheckMandatory("GXL GL History Line", intNo);

                    GLHistoryLine.Init();
                    GLHistoryLine.TransferFields("GXL GL History Line");
                    GLHistoryLine."Batch ID" := BatchID;
                    GLHistoryLine."Line No." := intNo;
                    GLHistoryLine.Reverse := false;
                    GLHistoryLine."Reverse Date" := 0D;
                    GLHistoryLine.Insert();

                    // Bufffer line if Reverse
                    IF "GXL GL History Line".Reverse THEN BEGIN
                        TempGLHistoryLine.Copy(GLHistoryLine);
                        TempGLHistoryLine."Posting Date" := "GXL GL History Line"."Reverse Date";
                        TempGLHistoryLine.Insert();
                    END;

                    currXMLport.Skip();
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    trigger OnPostXmlPort()
    begin
        if TempGLHistoryLine.FindSet() then begin
            repeat
                intNo := GetNextNo();
                GLHistoryLine2.Init();
                GLHistoryLine2.TransferFields(TempGLHistoryLine);
                GLHistoryLine2."Batch ID" := BatchID;
                GLHistoryLine2."Line No." := intNo;
                GLHistoryLine2."Posting Date" := TempGLHistoryLine."Reverse Date";
                GLHistoryLine2.Amount := TempGLHistoryLine.Amount * -1;
                GLHistoryLine2.Insert();
            until TempGLHistoryLine.Next() = 0;
        end;
        TempGLHistoryLine.DeleteAll();
    end;

    trigger OnPreXmlPort()
    begin
        GLSetup.Get();
        TempGLHistoryLine.DeleteAll;
        LastLineNo := 0;
        BatchID := 0;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        GLHistoryLine: Record "GXL GL History Line";
        GLHistoryLine2: Record "GXL GL History Line";
        TempGLHistoryLine: Record "GXL GL History Line" temporary;
        intNo: Integer;
        BatchID: Integer;
        LastLineNo: Integer;
        FieldIsRequiredErr: Label '%1 is required (Row = %2)';

    local procedure GetNextNo(): Integer
    begin
        LastLineNo := LastLineNo + 1;
        exit(LastLineNo);
    end;


    local procedure InsertGLHistoryBatch(): Integer
    var
        GLHistoryBatch: Record "GXL GL History Batch";
        LastBatchID: Integer;
    begin
        GLHistoryBatch.Reset();
        if GLHistoryBatch.FindLast() then
            LastBatchID := GLHistoryBatch."Batch ID";
        LastBatchID := LastBatchID + 1;
        GLHistoryBatch.Init();
        GLHistoryBatch."Batch ID" := LastBatchID;
        GLHistoryBatch."Imported Date Time" := CurrentDateTime();
        GLHistoryBatch."Imported by User ID" := UserId();
        GLHistoryBatch.Insert(true);
        exit(GLHistoryBatch."Batch ID");
    end;

    local procedure CheckMandatory(GLHistoryLine2: Record "GXL GL History Line"; RowNo: Integer)
    begin
        if GLHistoryLine2."Account No." = '' then
            Error(FieldIsRequiredErr, GLHistoryLine2.FieldCaption("Account No."), RowNo);
        if GLHistoryLine2."Document No." = '' then
            Error(FieldIsRequiredErr, GLHistoryLine2.FieldCaption("Document No."), RowNo);
        if GLHistoryLine2."Posting Date" = 0D then
            Error(FieldIsRequiredErr, GLHistoryLine2.FieldCaption("Posting Date"), RowNo);
        //if GLHistoryLine2.Amount = 0 then
        //    Error(FieldIsRequiredErr, GLHistoryLine2.FieldCaption(Amount), RowNo);
        if GLHistoryLine2.Description = '' then
            Error(FieldIsRequiredErr, GLHistoryLine2.FieldCaption(Description), RowNo);
    end;
}

