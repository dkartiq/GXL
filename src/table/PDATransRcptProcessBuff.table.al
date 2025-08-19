table 50264 "GXL PDA-TransRcpt Process Buff"
{
    DataClassification = CustomerContent;
    Caption = 'PDA-Transfer Receipt Process Buffer';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer Order No.';
        }
        field(3; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
        }
        field(6; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(7; "Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Receipt Date';
        }
        field(10; "Created by User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Created by User ID';
        }
        field(11; "Created Date-Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date-Time';
        }
        field(20; Processed; Boolean)
        {
            Caption = 'Processed';
            Editable = false;
        }
        field(21; "Processing Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Processing Date Time';
            Editable = false;
        }
        field(22; Errored; Boolean)
        {
            Caption = 'Error';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(23; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
            Editable = false;
        }
        //PS-2046+
        field(200; "MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(OrderLineNo; "No.", "Line No.")
        {
        }
        key(Processed; Processed, Errored, "No.", "Line No.")
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

}