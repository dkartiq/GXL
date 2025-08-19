table 50023 "GXL AutoStockPosting Error Log"
{
    Caption = 'Auto Stock Posting Error Log';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = ToBeClassified;
        }
        field(2; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            DataClassification = CustomerContent;
        }
        field(3; "POS Terminal No."; Code[10])
        {
            Caption = 'POS Terminal No.';
            DataClassification = CustomerContent;
        }
        field(4; "Transaction No."; Integer)
        {
            Caption = 'Transaction No.';
            DataClassification = CustomerContent;
        }
        field(5; "Current Posting Status"; Option)
        {
            Caption = 'Current Posting Status';
            OptionMembers = " ","Item Posted",Posted;
            OptionCaption = ' ,Item Posted,Posted';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Transaction Status".Status where("Store No." = field("Store No."), "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No.")));
            Editable = false;
        }
        field(10; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
        }
        field(11; "Log Date Time"; DateTime)
        {
            Caption = 'Log Date Time';
            DataClassification = CustomerContent;
        }
        field(12; "No. of Runs"; Integer)
        {
            Caption = 'No. of Runs';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Store No.", "POS Terminal No.", "Transaction No.")
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

}