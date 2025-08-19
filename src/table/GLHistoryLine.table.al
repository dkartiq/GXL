table 50029 "GXL GL History Line"
{
    /*Change Log
        ERP-204: GL History
    */

    Caption = 'G/L History Line';
    DataClassification = CustomerContent;
    LookupPageId = "GXL GL History Lines";
    DrillDownPageId = "GXL GL History Lines";

    fields
    {
        field(1; "Batch ID"; Integer)
        {
            Caption = 'Batch ID';
            DataClassification = CustomerContent;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(3; "Journal Template Name"; Code[10])
        {
            Caption = 'Journal Template Name';
            DataClassification = CustomerContent;
        }
        field(4; "Journal Batch Name"; Code[10])
        {
            Caption = 'Journal Batch Name';
            DataClassification = CustomerContent;
        }
        field(5; "Account No."; Code[20])
        {
            Caption = 'Account No.';
            DataClassification = CustomerContent;
        }
        field(6; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(8; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(9; Amount; Decimal)
        {
            Caption = 'Amount';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(10; "Document Date"; Date)
        {
            Caption = 'Document Date';
            DataClassification = CustomerContent;
        }
        field(11; "External Document No."; Code[35])
        {
            Caption = 'External Document No.';
            DataClassification = CustomerContent;
        }
        field(20; Reverse; Boolean)
        {
            Caption = 'Reverse';
            DataClassification = CustomerContent;
        }
        field(21; "Reverse Date"; Date)
        {
            Caption = 'Reverse Date';
            DataClassification = CustomerContent;
        }
        field(101; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 1 Code';
            CaptionClass = '1,2,1';
        }
        field(102; "Shortcut Dimension 2 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 2 Code';
            CaptionClass = '1,2,2';
        }
        field(103; "Shortcut Dimension 3 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 3 Code';
            CaptionClass = '1,2,3';
        }
        field(104; "Shortcut Dimension 4 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 4 Code';
            CaptionClass = '1,2,4';
        }
        field(105; "Shortcut Dimension 5 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 5 Code';
            CaptionClass = '1,2,5';
        }
        field(106; "Shortcut Dimension 6 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 6 Code';
            CaptionClass = '1,2,6';
        }
        field(107; "Shortcut Dimension 7 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 7 Code';
            CaptionClass = '1,2,7';
        }
        field(108; "Shortcut Dimension 8 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 8 Code';
            CaptionClass = '1,2,8';
        }
        field(200; "Process Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Process Status';
            OptionMembers = Imported,"Posting Error",Posted;
            OptionCaption = 'Imported,Posting Error,Posted';
            Editable = false;
        }
        field(201; "Processed Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed Date Time';
            Editable = false;
        }
        field(202; "Processed by User"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Processed by User';
            Editable = false;
        }
        field(203; "Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Batch ID", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Document No.", "Posting Date") { }
        key(Key3; "Process Status", "Document No.", "Posting Date")
        {
        }
    }

    var


    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;


    procedure ResetError(var NewGLHistoryLine: Record "GXL GL History Line")
    var
        GLHistoryLine: Record "GXL GL History Line";
        DocNo: Code[20];
        PostingDate: Date;
    begin
        GLHistoryLine.Copy(NewGLHistoryLine);
        GLHistoryLine.SetCurrentKey("Process Status", "Document No.", "Posting Date");
        GLHistoryLine.SetRange("Process Status", GLHistoryLine."Process Status"::"Posting Error");
        GLHistoryLine.SetRange("Batch ID", NewGLHistoryLine."Batch ID");
        GLHistoryLine.SetRange("Line No.");
        if GLHistoryLine.IsEmpty() then
            Error('Processed Status must be Posting Error can be reset');

        if GLHistoryLine.FindSet() then
            repeat
                if (DocNo <> GLHistoryLine."Document No.") or
                    (PostingDate <> GLHistoryLine."Posting Date") then begin
                    DocNo := GLHistoryLine."Document No.";
                    PostingDate := GLHistoryLine."Posting Date";
                    ResetErrorByDocumentNo(GLHistoryLine."Batch ID", DocNo, PostingDate);
                end;
            until GLHistoryLine.Next() = 0;
    end;

    procedure ResetErrorByDocumentNo(BatchID: Integer; DocumentNo: Code[20]; PostingDate: Date)
    var
        GLHistoryLine: Record "GXL GL History Line";
    begin
        GLHistoryLine.SetCurrentKey("Document No.", "Posting Date");
        GLHistoryLine.SetRange("Document No.", DocumentNo);
        GLHistoryLine.SetRange("Posting Date", PostingDate);
        GLHistoryLine.SetRange("Batch ID", BatchID);
        GLHistoryLine.SetRange("Process Status", GLHistoryLine."Process Status"::"Posting Error");
        if GLHistoryLine.FindSet() then
            GLHistoryLine.ModifyAll("Process Status", GLHistoryLine."Process Status"::Imported);
    end;

    procedure UpdateJournalPosted(BatchID: Integer; DocumentNo: Code[20]; PostingDate: Date)
    var
        GLHistoryLine: Record "GXL GL History Line";
    begin
        GLHistoryLine.SetCurrentKey("Document No.", "Posting Date");
        GLHistoryLine.SetRange("Document No.", DocumentNo);
        GLHistoryLine.SetRange("Posting Date", PostingDate);
        GLHistoryLine.SetRange("Batch ID", BatchID);
        GLHistoryLine.SetFilter("Process Status", '<>%1', GLHistoryLine."Process Status"::Posted);
        if GLHistoryLine.FindSet() then
            repeat
                GLHistoryLine.UpdateJournalPosted();
                GLHistoryLine.Modify();
            until GLHistoryLine.Next() = 0;
    end;

    procedure UpdateJournalPosted()
    begin
        "Process Status" := "Process Status"::Posted;
        "Error Message" := '';
        "Processed Date Time" := CurrentDateTime();
        "Processed by User" := UserId();
    end;

    procedure UpdateJournalErrored(BatchID: Integer; DocumentNo: Code[20]; PostingDate: Date; ErrorMsg: Text[250])
    var
        GLHistoryLine: Record "GXL GL History Line";
    begin
        GLHistoryLine.SetCurrentKey("Document No.", "Posting Date");
        GLHistoryLine.SetRange("Document No.", DocumentNo);
        GLHistoryLine.SetRange("Posting Date", PostingDate);
        GLHistoryLine.SetRange("Batch ID", BatchID);
        GLHistoryLine.SetFilter("Process Status", '<>%1', GLHistoryLine."Process Status"::"Posting Error");
        if GLHistoryLine.FindSet() then
            repeat
                GLHistoryLine.UpdateJournalErrored(ErrorMsg);
                GLHistoryLine.Modify();
            until GLHistoryLine.Next() = 0;
    end;

    procedure UpdateJournalErrored(ErrorMsg: Text[250])
    begin
        "Process Status" := "Process Status"::"Posting Error";
        "Error Message" := ErrorMsg;
        "Processed Date Time" := CurrentDateTime();
        "Processed by User" := UserId();
    end;


    procedure IsBatchBalanced(BatchID: Integer; DocumentNo: Code[20]; PostingDate: Date): Boolean
    var
        GLHistoryLine: Record "GXL GL History Line";
    begin
        GLHistoryLine.SetCurrentKey("Document No.", "Posting Date");
        GLHistoryLine.SetRange("Document No.", DocumentNo);
        GLHistoryLine.SetRange("Posting Date", PostingDate);
        GLHistoryLine.SetRange("Batch ID", BatchID);
        GLHistoryLine.CalcSums(Amount);
        exit(GLHistoryLine.Amount = 0);
    end;
}