table 50157 "GXL ECS Sales Price Data"
{
    /*
    ECS Integration:
        The table will log the changes in Sales Price
    */

    Caption = 'ECS Sales Price Data';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(3; "Location Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
        }
        field(5; UOM; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'UOM';
        }
        field(6; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(7; "Active RRP"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Active RRP';
        }
        field(8; "Price Start Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Price Start Date';
        }
        field(9; "Price End Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Price End Date';
        }
        field(10; "Offer Type"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Offer Type';
        }
        field(11; "Price Type"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Price Type';
        }
        field(12; "Ticket Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Ticket Quantity';
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