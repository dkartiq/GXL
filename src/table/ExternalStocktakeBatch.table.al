//CR050: PS-1948 External stocktake
table 50020 "GXL External Stocktake Batch"
{
    Caption = 'External Stocktake Batch';
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
            CalcFormula = exist("GXL External Stocktake Line" where("Batch ID" = field("Batch ID"), "Process Status" = filter(Imported)));
            Editable = false;
        }
        field(11; "Error Exists"; Boolean)
        {
            Caption = 'Error Exists';
            FieldClass = FlowField;
            CalcFormula = exist("GXL External Stocktake Line" where("Batch ID" = field("Batch ID"), "Process Status" = filter("Posting Error")));
            Editable = false;
        }
        field(12; "No. of Entries"; Integer)
        {
            Caption = 'No. of Entries';
            FieldClass = FlowField;
            CalcFormula = count("GXL External Stocktake Line" where("Batch ID" = field("Batch ID")));
            Editable = false;
        }
        field(13; "No. of Open Entries"; Integer)
        {
            Caption = 'No. of Open Entries';
            FieldClass = FlowField;
            CalcFormula = count("GXL External Stocktake Line" where("Batch ID" = field("Batch ID"), "Process Status" = filter(Imported)));
            Editable = false;
        }
        field(14; "No. of Error Entries"; Integer)
        {
            Caption = 'No. of Error Entries';
            FieldClass = FlowField;
            CalcFormula = count("GXL External Stocktake Line" where("Batch ID" = field("Batch ID"), "Process Status" = filter("Posting Error")));
            Editable = false;
        }
        field(15; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
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
        ExtStocktakeLine: Record "GXL External Stocktake Line";

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin
        ExtStocktakeLine.SetRange("Batch ID", "Batch ID");
        ExtStocktakeLine.DeleteAll();
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
        IsSuccess := Codeunit.Run(Codeunit::"GXL ExtStocktake-Post Batch YN", Rec);
        IF not IsSuccess then
            ErrorMessageHandler.ShowErrors();
    end;

    procedure CancelBackgroudPosting()
    var
        ExtStocktakeBatchPostJQ: Codeunit "GXL ExtStocktake-Post Batch JQ";
    begin
        ExtStocktakeBatchPostJQ.CancelQueueEntry(Rec);
    end;

}