table 50150 "GXL Bloyal Azure Log"
{
    Caption = 'Bloyal Azure Log';
    DataClassification = CustomerContent;
    LookupPageId = "GXL Bloyal Azure Log";
    DrillDownPageId = "GXL Bloyal Azure Log";

    fields
    {
        field(1; "Batch ID"; Integer)
        {
            Caption = 'Batch ID';
            DataClassification = CustomerContent;
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Web Service Name"; enum "GXL Bloyal Web Service Name")
        {
            Caption = 'Web Service Name';
            DataClassification = CustomerContent;
        }
        field(3; "File Number"; Integer)
        {
            Caption = 'File Number';
            DataClassification = CustomerContent;
        }
        field(4; "Sent Date Time"; DateTime)
        {
            Caption = 'Sent Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Sent by User"; Code[50])
        {
            Caption = 'Sent by User';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        field(6; "Start Entry No."; Integer)
        {
            Caption = 'Start Entry No.';
            DataClassification = CustomerContent;
        }
        field(7; "End Entry No."; Integer)
        {
            Caption = 'End Entry No.';
            DataClassification = CustomerContent;
        }
        field(8; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionMembers = " ","Success","Failed";
            OptionCaption = ' ,Success,Failed';
            Editable = false;
        }
        field(9; "Reset"; Boolean)
        {
            Caption = 'Reset';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                TestField("Re-Submit to Bloyal", false);
            end;
        }
        field(10; "Start Date Time Modified"; DateTime)
        {
            Caption = 'Start Date Time Modified';
            DataClassification = CustomerContent;
        }
        field(11; "End Date Time Modified"; DateTime)
        {
            Caption = 'End Date Time Modified';
            DataClassification = CustomerContent;
        }
        field(12; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "No. Of Records Sent"; Integer)
        {
            Caption = 'No. of Records Sent';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(14; "Start Processed Date Time"; DateTime)
        {
            Caption = 'Start Processed Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }

        // >> LCB-463        
        field(15; "Re-Submit to Bloyal"; Boolean)
        {
            Caption = 'Re-Submit to Bloyal';
            DataClassification = CustomerContent;
            Editable = false;
        }
        // << LCB-463
    }

    keys
    {
        key(PK; "Batch ID")
        {
            Clustered = true;
        }
        key(WebServiceName; "Web Service Name")
        { }
        key(EndEntryNo; "End Entry No.")
        { }
        key(EndDateTime; "End Date Time Modified")
        { }
        key(ResetKey; Reset)
        { }
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

    procedure InitAzureLogEntry(WebServName: enum "GXL Bloyal Web Service Name"; FileNo: Integer; StartEntryNo: Integer; EndEntryNo: Integer)
    begin
        Init();
        "Batch ID" := 0;
        "File Number" := FileNo;
        "Web Service Name" := WebServName;
        "Sent Date Time" := CurrentDateTime();
        "Start Entry No." := StartEntryNo;
        "End Entry No." := EndEntryNo;
        "Sent by User" := UserId();
    end;

    procedure InitAzureLogEntry(WebServName: Enum "GXL Bloyal Web Service Name"; FileNo: Integer; StartDateTime: DateTime; EndDateTime: DateTime)
    begin
        Init();
        "Batch ID" := 0;
        "File Number" := FileNo;
        "Web Service Name" := WebServName;
        "Start Date Time Modified" := StartDateTime;
        "End Date Time Modified" := EndDateTime;
        "Sent Date Time" := CurrentDateTime();
        "Sent by User" := UserId();
    end;

}