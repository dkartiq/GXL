/// <summary>
/// NAV9-11 Integrations
/// </summary>
table 50027 "GXL Cancel NAV Order Log"
{
    Caption = 'Cancel NAV Order Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Document Type"; Option)
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
        field(10; "Creation Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Creation Date Time';
        }
        field(11; "Created By User"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Created By User';
        }
    }

    keys
    {
        key(PK; "Document Type", "No.")
        {
            Clustered = true;
        }
    }

    var


    trigger OnInsert()
    begin
        "Creation Date Time" := CurrentDateTime();
        "Created By User" := UserId;
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

}
