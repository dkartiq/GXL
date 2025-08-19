/// <summary>
/// CR103 - G/L Import Dim2 and document date are mandatory
/// </summary>
xmlport 50004 "GXL Gen. Jnl. Import - Petbarn"
{
    Caption = 'GL Journal Import - Petbarn';
    Format = VariableText;
    FormatEvaluate = Legacy;
    Direction = Import;
    FieldSeparator = ',';
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement("Gen. Journal Line"; "Gen. Journal Line")
            {
                RequestFilterFields = "Journal Template Name", "Journal Batch Name";
                XmlName = 'Import';
                AutoSave = false;
                fieldelement(TemplateName; "Gen. Journal Line"."Journal Template Name")
                {
                    FieldValidate = yes;

                    trigger OnAfterAssignField()
                    begin
                        if recGJT.Name <> "Gen. Journal Line"."Journal Template Name" then
                            recGJT.Get("Gen. Journal Line"."Journal Template Name");
                    end;
                }
                fieldelement(AccountNo; "Gen. Journal Line"."Account No.")
                {
                    FieldValidate = yes;
                }
                fieldelement(PostingDate; "Gen. Journal Line"."Posting Date")
                {
                    FieldValidate = yes;
                }
                fieldelement(DocumentNo; "Gen. Journal Line"."Document No.")
                {
                    FieldValidate = yes;

                }
                fieldelement(Description; "Gen. Journal Line".Description)
                {
                    FieldValidate = yes;
                }
                fieldelement(Amount; "Gen. Journal Line".Amount)
                {
                    FieldValidate = yes;
                }
                fieldelement(Dim2Code; "Gen. Journal Line"."Shortcut Dimension 2 Code")
                {
                    FieldValidate = yes;
                }
                fieldelement(BatchName; "Gen. Journal Line"."Journal Batch Name")
                {
                    FieldValidate = yes;
                }
                fieldelement(DocumentDate; "Gen. Journal Line"."Document Date")
                {
                    FieldValidate = yes;
                }
                fieldelement(GenPostingType; "Gen. Journal Line"."Gen. Posting Type")
                {
                    FieldValidate = Yes;
                }
                fieldelement(VATBusPostingGroup; "Gen. Journal Line"."VAT Bus. Posting Group")
                {
                    FieldValidate = Yes;
                }
                fieldelement(VATProdPostingGroup; "Gen. Journal Line"."VAT Prod. Posting Group")
                {
                    FieldValidate = Yes;
                }
                fieldelement(Reverse; "Gen. Journal Line"."Reversing Entry")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ReverseDate; "Gen. Journal Line"."Due Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ExtDocNo; "Gen. Journal Line"."External Document No.")
                {
                    FieldValidate = No;
                    MinOccurs = Zero;
                }
                textelement(Dim8Code)
                {
                    MinOccurs = Zero;
                    MaxOccurs = Once;
                }
                trigger OnAfterGetRecord()
                begin
                    "Gen. Journal Line".ShowShortcutDimCode(ShortcutDimCode);
                    Dim8Code := ShortcutDimCode[8];
                end;

                trigger OnBeforeInsertRecord()
                begin
                    gRowNo += 1;

                    ValidateMandatoryFields("Gen. Journal Line", gRowNo);

                    intNo := getNextNo("Gen. Journal Line"."Journal Template Name", "Gen. Journal Line"."Journal Batch Name");

                    recGJL.Init;
                    recGJL.Validate("Journal Template Name", "Gen. Journal Line"."Journal Template Name");
                    recGJL.Validate("Journal Batch Name", "Gen. Journal Line"."Journal Batch Name");
                    recGJL.Validate("Line No.", intNo);
                    recGJL.Validate("Account Type", "Gen. Journal Line"."Account Type"::"G/L Account");
                    recGJL.Validate("Account No.", "Gen. Journal Line"."Account No.");
                    recGJL.Validate("Document No.", "Gen. Journal Line"."Document No.");
                    recGJL.Validate("Posting Date", "Gen. Journal Line"."Posting Date");
                    recGJL.Validate(Description, "Gen. Journal Line".Description);
                    recGJL.Validate(Amount, "Gen. Journal Line".Amount);
                    recGJL.Validate("External Document No.", "Gen. Journal Line"."External Document No.");
                    recGJL.Validate("Shortcut Dimension 1 Code", "Gen. Journal Line"."Shortcut Dimension 1 Code");
                    recGJL.Validate("Shortcut Dimension 2 Code", "Gen. Journal Line"."Shortcut Dimension 2 Code");
                    recGJL.Validate("Document Date", "Gen. Journal Line"."Document Date");
                    recGJL.Validate("Source Code", recGJT."Source Code");
                    recGJL.Validate("Gen. Posting Type", "Gen. Journal Line"."Gen. Posting Type");
                    recGJL.Validate("VAT Bus. Posting Group", "Gen. Journal Line"."VAT Bus. Posting Group");
                    recGJL.Validate("VAT Prod. Posting Group", "Gen. Journal Line"."VAT Prod. Posting Group");
                    recGJL.Insert(true);

                    ValDimCode(recGJL, 8, Dim8Code);
                    recGJL.Modify(true);

                    // Bufffer line if Reverse
                    IF "Gen. Journal Line"."Reversing Entry" THEN BEGIN
                        recTempGJL.COPY(recGJL);
                        recTempGJL."Due Date" := "Gen. Journal Line"."Due Date"; //Reversing Date
                        recTempGJL.INSERT(TRUE);
                    END;

                    Clear(Dim8Code);
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
        if recTempGJL.FindSet then begin
            repeat
                intNo := getNextNo(recTempGJL."Journal Template Name", recTempGJL."Journal Batch Name");
                recGJL2.Init();
                recGJL2.Validate("Journal Template Name", recTempGJL."Journal Template Name");
                recGJL2.Validate("Journal Batch Name", recTempGJL."Journal Batch Name");
                recGJL2.Validate("Line No.", intNo);
                recGJL2.Validate("Account Type", recTempGJL."Account Type");
                recGJL2.Validate("Account No.", recTempGJL."Account No.");
                recGJL2.Validate("Document No.", recTempGJL."Document No.");
                recGJL2.VALIDATE("Posting Date", recTempGJL."Due Date");
                recGJL2.Validate(Description, recTempGJL.Description);
                recGJL2.Validate(Amount, recTempGJL.Amount * -1);
                recGJL2."External Document No." := recTempGJL."External Document No.";

                recGJL2."Dimension Set ID" := recTempGJL."Dimension Set ID";
                recGJL2."Shortcut Dimension 1 Code" := recTempGJL."Shortcut Dimension 1 Code";
                recGJL2."Shortcut Dimension 2 Code" := recTempGJL."Shortcut Dimension 2 Code";

                recGJL2.Validate("Document Date", recTempGJL."Document Date");

                recGJL2.Validate("Source Code", recGJT."Source Code");

                recGJL2.Validate("Gen. Posting Type", recTempGJL."Gen. Posting Type");
                recGJL2.Validate("VAT Bus. Posting Group", recTempGJL."VAT Bus. Posting Group");
                recGJL2.Validate("VAT Prod. Posting Group", recTempGJL."VAT Prod. Posting Group");

                recGJL2.Insert(true);

            until recTempGJL.Next() = 0;
        end;
        recTempGJL.DeleteAll();
    end;

    trigger OnPreXmlPort()
    begin
        recTempGJL.DeleteAll;
        LastLineNo := 0;
        LastJnlTemplateName := '';
        LastJnlBatchName := '';
    end;


    var
        recGJL: Record "Gen. Journal Line";
        recGJL2: Record "Gen. Journal Line";
        recTempGJL: Record "Gen. Journal Line" temporary;
        recGJT: Record "Gen. Journal Template";
        intNo: Integer;
        gRowNo: Integer;
        ShortcutDimCode: array[8] of Code[20];
        LastLineNo: Integer;
        LastJnlTemplateName: Code[10];
        LastJnlBatchName: Code[10];

    local procedure getNextNo(JournalTemplateName: Code[10]; JournalBatchName: Code[10]): Integer
    var
        _recGJL: Record "Gen. Journal Line";
    begin
        if (LastJnlTemplateName <> JournalTemplateName) or (LastJnlBatchName <> JournalBatchName) then
            LastLineNo := 0;

        if LastLineNo = 0 then begin
            _recGJL.Reset;
            _recGJL.SetRange("Journal Template Name", JournalTemplateName);
            _recGJL.SetRange("Journal Batch Name", JournalBatchName);
            if _recGJL.FindLast then
                LastLineNo := _recGJL."Line No.";
        end;
        LastJnlTemplateName := JournalTemplateName;
        LastJnlBatchName := JournalBatchName;
        LastLineNo := LastLineNo + 1;
        exit(LastLineNo);
    end;

    local procedure ValDimCode(var Line: Record "Gen. Journal Line"; Index: Integer; Value: Code[20])
    begin
        if Value <> '' then
            Line.ValidateShortcutDimCode(Index, Value);
    end;

    local procedure ValidateMandatoryFields(GenJournalLine: Record "Gen. Journal Line"; RowNo: Integer)
    var
        MandatoryFieldErr: Label '%1 must have a value in row %2.';
    begin
        if GenJournalLine."Journal Template Name" = '' then
            Error(MandatoryFieldErr, GenJournalLine.FieldCaption("Journal Template Name"), RowNo);

        if GenJournalLine."Account No." = '' then
            Error(MandatoryFieldErr, GenJournalLine.FieldCaption("Account No."), RowNo);

        if GenJournalLine."Posting Date" = 0D then
            Error(MandatoryFieldErr, GenJournalLine.FieldCaption("Posting Date"), RowNo);

        if GenJournalLine."Document No." = '' then
            Error(MandatoryFieldErr, GenJournalLine.FieldCaption("Document No."), RowNo);

        if GenJournalLine.Description = '' then
            Error(MandatoryFieldErr, GenJournalLine.FieldCaption(Description), RowNo);

        if GenJournalLine.Amount = 0 then
            Error(MandatoryFieldErr, GenJournalLine.FieldCaption(Amount), RowNo);

        if GenJournalLine."Shortcut Dimension 2 Code" = '' then
            Error(MandatoryFieldErr, GenJournalLine.FieldCaption("Shortcut Dimension 2 Code"), RowNo);

        if GenJournalLine."Journal Batch Name" = '' then
            Error(MandatoryFieldErr, GenJournalLine.FieldCaption("Journal Batch Name"), RowNo);

        if GenJournalLine."Document Date" = 0D then
            Error(MandatoryFieldErr, GenJournalLine.FieldCaption("Document Date"), RowNo);
    end;
}

