table 50024 "GXL NAV Cancelled Order"
{
    /*Change Log
        PS-2270: Sync NAV cancelled orders from NAV13 over
    */

    DataClassification = CustomerContent;
    Caption = 'NAV Cancelled Order';

    fields
    {
        field(1; "Document Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';
            OptionMembers = "Purchase","Transfer";
            OptionCaption = 'Purchase,Transfer';
        }
        field(3; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(70000; "Replication Counter"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Replication Counter';
        }
        field(70001; "Creation Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Creation Date Time';
        }
        field(70002; "Created By User"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Created By User';
        }
        field(80000; "Process Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed Status';
            OptionMembers = Imported,"Processing Error",Processed;
            OptionCaption = 'Imported,Processing Error,Processed';
            Editable = false;
        }
        field(80001; "Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
            Editable = false;
        }
        field(80002; "Processed Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed Date Time';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document Type", "No.")
        {
            Clustered = true;
        }
        key(ReplicationCounter; "Replication Counter")
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

    procedure ResetError()
    var
    begin
        if "Process Status" <> "Process Status"::"Processing Error" then
            Error('Only Status = Processing Error can be reset.');

        Validate("Process Status", "Process Status"::Imported);
    end;
}