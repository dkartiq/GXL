table 50010 "GXL Item Jnl. Buffer Batch"
{
    // 001  19.03.2022  KDU  BAU LCB-6 New column Reason Code has been added.
    Caption = 'Item Journal Buffer Batch';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Batch ID"; Integer)
        {
            Caption = 'Batch ID';
            DataClassification = CustomerContent;
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
        field(10; "Open Exists"; Boolean)
        {
            Caption = 'Open Exists';
            FieldClass = FlowField;
            CalcFormula = exist("GXL Item Journal Buffer" where("Batch ID" = field("Batch ID"), "Process Status" = filter(Imported)));
            Editable = false;
        }
        field(11; "Error Exists"; Boolean)
        {
            Caption = 'Error Exists';
            FieldClass = FlowField;
            CalcFormula = exist("GXL Item Journal Buffer" where("Batch ID" = field("Batch ID"), "Process Status" = filter("Posting Error")));
            Editable = false;
        }
        field(12; "No. of Entries"; Integer)
        {
            Caption = 'No. of Entries';
            FieldClass = FlowField;
            CalcFormula = count("GXL Item Journal Buffer" where("Batch ID" = field("Batch ID")));
            Editable = false;
        }
        field(13; "No. of Open Entries"; Integer)
        {
            Caption = 'No. of Open Entries';
            FieldClass = FlowField;
            CalcFormula = count("GXL Item Journal Buffer" where("Batch ID" = field("Batch ID"), "Process Status" = filter(Imported)));
            Editable = false;
        }
        field(14; "No. of Error Entries"; Integer)
        {
            Caption = 'No. of Error Entries';
            FieldClass = FlowField;
            CalcFormula = count("GXL Item Journal Buffer" where("Batch ID" = field("Batch ID"), "Process Status" = filter("Posting Error")));
            Editable = false;
        }
        // >> 001 
        field(15; "Reason Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        // << 001
    }

    keys
    {
        key(PK; "Batch ID")
        {
            Clustered = true;
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


    procedure SendToPosting() IsSuccess: Boolean
    var
        ErrorMessageMgt: Codeunit "Error Message Management";
        ErrorMessageHandler: Codeunit "Error Message Handler";
    begin
        Commit();
        ErrorMessageMgt.Activate(ErrorMessageHandler);
        IsSuccess := CODEUNIT.RUN(Codeunit::"GXL ItemJnlBuffBatch-Post(Y/N)", Rec);
        IF NOT IsSuccess THEN
            ErrorMessageHandler.ShowErrors();
    end;

    procedure CancelBackgroudPosting()
    var
        ItemJnlBuffBatchPostJQ: Codeunit "GXL ItemJnlBuffBatch-Post JQ";
    begin
        ItemJnlBuffBatchPostJQ.CancelQueueEntry(Rec);
    end;
}