codeunit 50034 "GXL Gen. Jnl. Events Mgt."
{

    //ERP-NAV Master Data Management: Automate IC Transaction +
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeCode', '', false, false)]
    local procedure GenJnlPostBatch_OnBeforeCode(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean)
    var
        ValueRetention: Codeunit "GXL Value Retention";
    begin
        if PreviewMode then
            exit;
        ValueRetention.SetICTransactions(GenJournalLine."Document No.", GenJournalLine."IC Partner Transaction No.");
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnAfterCode', '', false, false)]
    local procedure GenJnlPostBatch_OnAfterCode(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean)
    var
        AutoExportICTrans: Codeunit "GXL Auto Export IC Trans";
        ValueRetention: Codeunit "GXL Value Retention";
        DocNo: Code[20];
        ICTransNo: Integer;
    begin
        if PreviewMode then
            exit;
        ValueRetention.GetICTransactions(DocNo, ICTransNo);
        if (DocNo <> '') and (ICTransNo <> 0) then begin
            Commit();
            AutoExportICTrans.ProcessGenJnl(DocNo);
        end;
        ValueRetention.SetICTransactions('', 0);
    end;
    //ERP-NAV Master Data Management: Automate IC Transaction -

    //ERP-162 GL Balance by Entity Code (Dim1) +
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Batch", 'OnBeforeProcessLines', '', true, false)]
    local procedure OnBeforeProcessLines_GenJnlPostBatch(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean)
    begin
        CheckGLBalanceByDim1(GenJournalLine, PreviewMode);
    end;

    local procedure CheckGLBalanceByDim1(var GenJournalLine: Record "Gen. Journal Line"; PreviewMode: Boolean)
    var
        GLSetup: Record "General Ledger Setup";
        GenJnlTemplate: Record "Gen. Journal Template";
        GenJnlLine2: Record "Gen. Journal Line";
        DimAmountBuffer: Record "Dimension Code Amount Buffer" temporary;
    begin
        if not GenJournalLine.Find('=><') then
            exit;
        if not GenJnlTemplate.Get(GenJournalLine."Journal Template Name") then
            exit;

        if GenJnlTemplate."GXL Force Dim 1 Balance" then begin
            GLSetup.Get();
            GenJnlLine2.Copy(GenJournalLine);
            if GenJnlLine2.FindSet() then
                repeat
                    DimAmountBuffer.SetRange("Line Code", GenJnlLine2."Shortcut Dimension 1 Code");
                    if DimAmountBuffer.Find('-') then begin
                        DimAmountBuffer.Amount += GenJnlLine2.Amount;
                        DimAmountBuffer.Modify();
                    end else begin
                        DimAmountBuffer.Init();
                        DimAmountBuffer."Line Code" := GenJnlLine2."Shortcut Dimension 1 Code";
                        DimAmountBuffer.Amount := GenJnlLine2.Amount;
                        DimAmountBuffer.Insert();
                    end;
                until GenJnlLine2.Next() = 0;

            DimAmountBuffer.Reset();
            if DimAmountBuffer.FindSet() then
                repeat
                    if DimAmountBuffer.Amount <> 0 then
                        Error('%1 %2 is out of balance by %3.', GLSetup."Global Dimension 1 Code", DimAmountBuffer."Line Code", DimAmountBuffer.Amount);
                until DimAmountBuffer.Next() = 0;
            DimAmountBuffer.DeleteAll();
        end;

    end;
    //ERP-162 GL Balance by Entity Code (Dim1) -

}