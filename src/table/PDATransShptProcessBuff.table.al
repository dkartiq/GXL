table 50263 "GXL PDA-TransShpt Process Buff"
{
    DataClassification = CustomerContent;
    Caption = 'PDA-Transfer Shipment Process Buffer';

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
        field(7; "Shipment Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Shipment Date';
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
        //PS-2523 VET Clinic transfer order +
        field(100; "Process Status"; Option)
        {
            Caption = 'Process Status';
            DataClassification = CustomerContent;
            OptionMembers = " ","Shipment Posting Error","Shipment Posted","Receipt Posting Error","Receipt Posted","Sales Creation Error","Sales Created","Sales Posting Error","Sales Posted","Closed";
        }
        field(101; "Transfer Shipment No."; Code[20])
        {
            Caption = 'Transfer Shipment No.';
            DataClassification = CustomerContent;
            TableRelation = "Transfer Shipment Header";
        }
        field(102; "Transfer Receipt No."; Code[20])
        {
            Caption = 'Transfer Receipt No.';
            DataClassification = CustomerContent;
            TableRelation = "Transfer Receipt Header";
        }
        field(103; "Sales Order No."; Code[20])
        {
            Caption = 'Sales Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Header"."No." where("Document Type" = const(Order));
        }
        field(104; "Posted Sales Invoice No."; Code[20])
        {
            Caption = 'Posted Sales Invoice No.';
            DataClassification = CustomerContent;
            TableRelation = "Sales Invoice Header";
        }
        //PS-2523 VET Clinic transfer order -
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
        key(ProcessStatus; "Process Status", "No.", "Line No.")
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