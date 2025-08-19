table 50162 "GXL ECS Stock Range Data"
{
    /*
    ECS Integration:
        The table will log the changes in Stock Ranging
    */

    Caption = 'ECS Stock Range Data';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
        }
        field(4; UOM; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'UOM';
        }
        field(5; Ranged; Text[1])
        {
            DataClassification = CustomerContent;
            Caption = 'Ranged';
        }
        field(6; "Range Start Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Range Start Date';
        }
        field(7; "Range End Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Range End Date';
        }
        field(8; "Stock on Hand"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Stock on Hand';
            DecimalPlaces = 0 : 5;
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