table 50028 "GXL GL History Batch"
{
    /*Change Log
        ERP-204: GL History
    */

    Caption = 'G/L History Batch';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Batch ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Batch ID';
        }
        field(2; "Imported Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Imported Date Time';
            Editable = false;
        }
        field(3; "Imported by User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Imported by User ID';
            Editable = false;
        }
        field(4; "Job Queue Status"; Option)
        {
            Caption = 'Job Queue Status';
            DataClassification = CustomerContent;
            OptionMembers = " ","Scheduled for Posting",Error,Posting,Completed;
            OptionCaption = ' ,Scheduled for Posting,Error,Posting,Completed';
            Editable = false;
        }
        field(5; "Job Queue Entry ID"; Guid)
        {
            Caption = 'Job Queue Entry ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6; "Job Queue Start Date Time"; DateTime)
        {
            Caption = 'Job Queue Start Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(7; "Job Queue End Date Time"; DateTime)
        {
            Caption = 'Job Queue End Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Stop Job Queue At"; DateTime)
        {
            Caption = 'Stop Job Queue At';
            DataClassification = CustomerContent;
        }
        field(10; "Open Exists"; Boolean)
        {
            Caption = 'Open Exists';
            FieldClass = FlowField;
            CalcFormula = exist("GXL GL History Line" where("Batch ID" = field("Batch ID"), "Process Status" = filter(Imported)));
            Editable = false;
        }
        field(11; "Error Exists"; Boolean)
        {
            Caption = 'Error Exists';
            FieldClass = FlowField;
            CalcFormula = exist("GXL GL History Line" where("Batch ID" = field("Batch ID"), "Process Status" = filter("Posting Error")));
            Editable = false;
        }
        field(12; "No. of Entries"; Integer)
        {
            Caption = 'No. of Entries';
            FieldClass = FlowField;
            CalcFormula = count("GXL GL History Line" where("Batch ID" = field("Batch ID")));
            Editable = false;
        }
        field(13; "No. of Open Entries"; Integer)
        {
            Caption = 'No. of Open Entries';
            FieldClass = FlowField;
            CalcFormula = count("GXL GL History Line" where("Batch ID" = field("Batch ID"), "Process Status" = filter(Imported)));
            Editable = false;
        }
        field(14; "No. of Error Entries"; Integer)
        {
            Caption = 'No. of Error Entries';
            FieldClass = FlowField;
            CalcFormula = count("GXL GL History Line" where("Batch ID" = field("Batch ID"), "Process Status" = filter("Posting Error")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Batch ID")
        {
            Clustered = true;
        }
    }

    var
        GLHistoryLine: Record "GXL GL History Line";
        GLHistoryLodBatchPostViaJobQueue: Codeunit "GXL GL History Batch-Post JQ";


    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin
        if "Job Queue Status" in ["Job Queue Status"::Posting, "Job Queue Status"::"Scheduled for Posting"] then
            FieldError("Job Queue Status");
        GLHistoryLine.SetRange("Batch ID", "Batch ID");
        GLHistoryLine.DeleteAll();
    end;

    trigger OnRename()
    begin

    end;

    procedure SendToPosting() IsSuccess: Boolean
    var
    begin
        Commit();
        PostBatchYN();
    end;

    procedure CancelBackgroudPosting()
    var
        GLHistoryBatchPostJQ: Codeunit "GXL GL History Batch-Post JQ";
    begin
        GLHistoryBatchPostJQ.CancelQueueEntry(Rec);
    end;

    local procedure PostBatchYN()
    begin
        CalcFields("Open Exists");
        if not "Open Exists" then
            Error('Either GL History Lines have already been posted or there is nothing to post.');

        if Confirm('Do you want to send the GL History batch to background posting?') then
            GLHistoryLodBatchPostViaJobQueue.EnqueueGLHistoryBatch(Rec);
    end;

}