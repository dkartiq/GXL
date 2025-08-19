table 50155 "GXL ECS Item Data"
{
    /*
    ECS Integration:
        The table will log the changes in Item and related tables
    */

    Caption = 'ECS Item Data';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "ECS Data Template Code"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Data Template Code';
            TableRelation = "GXL ECS Data Template Header";
        }
        field(3; "ECS WS Function"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS WS Function';
        }
        field(4; "Source Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Table ID';
        }
        field(5; "Source Table Name"; Text[30])
        {
            Caption = 'Source Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObj."Object Name" where("Object Type" = const(Table)));
            Editable = false;
        }
        field(6; "Source Field No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Source Field No.';
        }
        field(7; "Source Field Name"; Text[30])
        {
            Caption = 'Source Field Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Field.FieldName where(TableNo = field("Source Table ID"), "No." = field("Source Field No.")));
        }
        field(8; "ECS Field Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Field Name';
        }
        field(9; "Field Value"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Field Value';
        }
        field(14; "Unique ID 1 ECS Field Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Unique ID 1 ECS Field Name';
        }
        field(15; "Unique ID 1 ECS Field Value"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Unique ID 1 ECS Field Value';
        }
        field(16; "Unique ID 2 ECS Field Name"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Unique ID 2 ECS Field Name';
        }
        field(17; "Unique ID 2 ECS Field Value"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Unique ID 2 ECS Field Value';
        }
        field(30; "Print Ticket"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Print Ticket';
        }
        field(90; "Created Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date Time';
            Editable = false;
        }
        field(91; "Last Modified Date-Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Modified Date-Time';
            Editable = false;
        }
        field(100; "Middleware Update Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Middleware Update Status';
            OptionMembers = Pending,Processing,Complete;
            OptionCaption = 'Pending,Processing,Complete';
        }
        field(101; "Middleware Update Timestamp"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Middleware Update Timestamp';
        }
        field(102; "Middleware Error"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Middleware Error';
        }
        field(103; "Middleware Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Middleware Error Message';
        }
        field(200; id; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Id';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(APIIdKey; id) { }
    }


    trigger OnInsert()
    begin
        if IsNullGuid(id) then
            id := CreateGuid();
        "Created Date Time" := CurrentDateTime();
    end;

    trigger OnModify()
    begin
        "Last Modified Date-Time" := CurrentDateTime();
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}