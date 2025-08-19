/// <summary>
/// ERP-270 - CR104 - Performance improvement post cost to G/L
/// </summary>
table 50044 "GXL PostInvtCostToGL Log"
{
    Caption = 'Post Inventory Cost to G/L Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "From Value Entry No."; Integer)
        {
            Caption = 'From Value Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "To Value Entry No."; Integer)
        {
            Caption = 'To Value Entry No.';
            DataClassification = CustomerContent;
        }
        field(4; "Message"; Text[250])
        {
            Caption = 'Message';
            DataClassification = CustomerContent;
        }
        field(5; Errored; Boolean)
        {
            Caption = 'Errored';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Start Date Time"; DateTime)
        {
            Caption = 'Start Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "End Date Time"; DateTime)
        {
            Caption = 'End Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
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

}