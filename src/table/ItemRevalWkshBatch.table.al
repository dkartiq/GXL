/// <summary>
/// CR099 - Revaluation Journal Batch
/// </summary>
table 50041 "GXL Item Reval. Wksh. Batch"
{
    Caption = 'Item Revaluation Wksh. Batch';
    DataCaptionFields = "Batch ID", "Imported Date Time";
    DataClassification = CustomerContent;
    DrillDownPageID = "GXL Item Reval. Worksheets";
    LookupPageID = "GXL Item Reval. Worksheets";

    fields
    {
        field(1; "Batch ID"; Integer)
        {
            AutoIncrement = true;
            Caption = 'Batch ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; "Imported Date Time"; DateTime)
        {
            Caption = 'Imported Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Imported by User ID"; Code[50])
        {
            Caption = 'Imported by User ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Job Queue Status"; Option)
        {
            Caption = 'Job Queue Status';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Not Scheduled,Scheduled for Posting,Error,Posting,Completed';
            OptionMembers = "Not Scheduled","Scheduled for Posting",Error,Posting,Completed;
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
        field(20; "No. of Lines"; Integer)
        {
            CalcFormula = Count("GXL Item Reval. Wksh. Line" WHERE("Batch ID" = FIELD("Batch ID")));
            Caption = 'No. of Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(21; "Imported Lines"; Integer)
        {
            CalcFormula = Count("GXL Item Reval. Wksh. Line" WHERE("Batch ID" = FIELD("Batch ID"),
                                                                    Status = CONST(Imported)));
            Caption = 'Imported Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(22; "Value Calculated Lines"; Integer)
        {
            BlankZero = true;
            CalcFormula = Count("GXL Item Reval. Wksh. Line" WHERE("Batch ID" = FIELD("Batch ID"),
                                                                    Status = CONST("Value Calculated")));
            Caption = 'Value Calculated Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(23; "Value Calc. Errors"; Integer)
        {
            BlankZero = true;
            CalcFormula = Count("GXL Item Reval. Wksh. Line" WHERE("Batch ID" = FIELD("Batch ID"),
                                                                    Status = CONST("Value Calc. Error")));
            Caption = 'Value Calc. Errors';
            Editable = false;
            FieldClass = FlowField;
        }
        field(24; "Posting Errors"; Integer)
        {
            BlankZero = true;
            CalcFormula = Count("GXL Item Reval. Wksh. Line" WHERE("Batch ID" = FIELD("Batch ID"),
                                                                    Status = CONST("Posting Error")));
            Caption = 'Posting Errors';
            Editable = false;
            FieldClass = FlowField;
        }
        field(25; "Posted Lines"; Integer)
        {
            BlankZero = true;
            CalcFormula = Count("GXL Item Reval. Wksh. Line" WHERE("Batch ID" = FIELD("Batch ID"),
                                                                    Status = CONST(Posted)));
            Caption = 'Posted Lines';
            Editable = false;
            FieldClass = FlowField;
        }
        field(30; "Calculated Revalue Amt."; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("GXL Item Reval. Wksh. Line".Amount WHERE("Batch ID" = FIELD("Batch ID"),
                                                                         Status = CONST("Value Calculated")));
            Caption = 'Calculated Revalue Amt.';
            Editable = false;
            FieldClass = FlowField;
        }
        field(31; "Posted Revalue Amt."; Decimal)
        {
            AutoFormatType = 1;
            BlankZero = true;
            CalcFormula = Sum("GXL Item Reval. Wksh. Line".Amount WHERE("Batch ID" = FIELD("Batch ID"),
                                                                         Status = CONST(Posted)));
            Caption = 'Posted Revalue Amt.';
            Editable = false;
            FieldClass = FlowField;
        }
    }

    keys
    {
        key(Key1; "Batch ID") { Clustered = true; }
        key(Key2; "Job Queue Status") { }
    }

    fieldgroups
    {
        fieldgroup(DropDown; "Batch ID", "Imported Date Time", "Job Queue Status") { }
    }

    trigger OnDelete()
    var
        RevalWkshLine: Record "GXL Item Reval. Wksh. Line";
    begin
        if "Job Queue Status" in ["Job Queue Status"::Posting, "Job Queue Status"::"Scheduled for Posting"] then
            FieldError("Job Queue Status");
        RevalWkshLine.SetRange("Batch ID", "Batch ID");
        RevalWkshLine.DeleteAll(true);
    end;

    trigger OnInsert()
    begin
        "Imported Date Time" := CurrentDateTime;
        "Imported by User ID" := UserId;
    end;

    trigger OnRename()
    begin
        Error('You cannot rename a %1', TableCaption);
    end;

    var
        GLSetup: Record "General Ledger Setup";

    procedure CheckBatchBeforePosting()
    var
        SourceCodeSetup: Record "Source Code Setup";
    begin
        TestField("Batch ID");
        if ("Stop Job Queue At" <> 0DT) and ("Stop Job Queue At" < CurrentDateTime) then
            FieldError("Stop Job Queue At");
        CalcFields("No. of Lines", "Imported Lines", "Value Calculated Lines", "Posting Errors", "Posted Lines");
        TestField("No. of Lines");
        if (("Imported Lines" + "Posting Errors") > 0) then
            Error('You must Calculate Inventory Values for all imported line Items before posting.');
        if ("No. of Lines" = "Posted Lines") then
            Error('All line Items are already posted.');
        if ("Value Calculated Lines" = 0) then
            Error('There are no Value Calculated lines to post.');

        SourceCodeSetup.Get();
        SourceCodeSetup.TestField("Revaluation Journal");
    end;

    procedure SendToPosting()
    begin
        Commit();
        PostBatchYN();
    end;


    procedure CancelBackgroundPosting()
    var
        RevalWkshBatchPostJQ: Codeunit "GXL Item Rev.Wksh.Batch-PostJQ";
    begin
        RevalWkshBatchPostJQ.CancelQueueEntry(Rec);
    end;

    local procedure PostBatchYN()
    var
        RevalWkshBatchPostJQ: Codeunit "GXL Item Rev.Wksh.Batch-PostJQ";
    begin
        CheckBatchBeforePosting();
        if Confirm('Do you want to send Revaluation Batch %1 to background posting?', false, "Batch ID") then
            RevalWkshBatchPostJQ.EnqueueRevalWkshBatch(Rec);
    end;


    procedure ShowLastJobQueueError()
    var
        JobQueueLogEntry: Record "Job Queue Log Entry";
    begin
        if IsNullGuid("Job Queue Entry ID") then
            exit;
        JobQueueLogEntry.SetCurrentKey(ID, Status);
        JobQueueLogEntry.SetRange(ID, "Job Queue Entry ID");
        JobQueueLogEntry.SetRange(Status, JobQueueLogEntry.Status::Error);
        if JobQueueLogEntry.FindLast() then
            JobQueueLogEntry.ShowErrorMessage();
    end;


    procedure GetStatusStyleTxt(): Text
    begin
        case "Job Queue Status" of
            "Job Queue Status"::Error:
                exit('Unfavorable');
        end;
    end;


    procedure ShowWorksheetLines()
    var
        RevalWkshLine: Record "GXL Item Reval. Wksh. Line";
    begin
        if ("Batch ID" = 0) then
            exit;
        RevalWkshLine.SetRange("Batch ID", "Batch ID");
        Page.Run(0, RevalWkshLine);
    end;

    procedure ShowWorksheetLocLines()
    var
        RevalWkshLocLine: Record "GXL Item Reval. Wksh. Loc Line";
    begin
        if "Batch ID" = 0 then
            exit;

        RevalWkshLocLine.SetRange("Batch ID", "Batch ID");
        Page.Run(0, RevalWkshLocLine);
    end;
}
