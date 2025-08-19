table 50161 "GXL ECS Promotion Data"
{
    /*
    ECS Integration:
        The table will log the changes in ECS Promotions
    */

    Caption = 'ECS Promotion Data';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "ECS Event ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Event ID';
        }
        field(3; "Event Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Event Code';
            NotBlank = true;
        }
        field(4; "Promotion Type"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Promotion Type';
        }
        field(5; "Location Hierarchy Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Location Hierarchy Type';
            OptionMembers = " ",All,State,Region,Cluster,Location;
            OptionCaption = ' ,All,State,Region,Cluster,Location';
        }
        field(6; "Location Hierarchy Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Hierarchy Code';
        }
        field(8; "Start Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Start Date';
        }
        field(9; "End Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'End Date';
        }
        field(10; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
        }
        field(11; "Unit Of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
        }
        field(12; "Discount Value 1"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Discount Value 1';
        }
        field(13; "Discount Value 2"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Discount Value 2';
        }
        field(14; "Discount Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Discount Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(15; "Deal Text 1"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Deal Text 1';
        }
        field(16; "Deal Text 2"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Deal Text 2';
        }
        field(17; "Deal Text 3"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Deal Text 3';
        }
        field(18; "Default Size"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Size';
        }
        field(20; "ECS Cluster UID"; Integer)
        {
            Caption = 'ECS Cluster UID';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store Group"."GXL ECS UID" where(Code = field("Location Hierarchy Code")));
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