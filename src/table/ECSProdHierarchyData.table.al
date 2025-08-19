table 50152 "GXL ECS Prod. Hierarchy Data"
{
    /*
    ECS Integration:
        The table will log the changes in product hierarchy which includes the following levels
            1. Top Level - hardcoded
            2. Division
            3. Item Category
            4. Retail Product Group
            5. Item
            6. UOM
            7. Barcode
    */

    DataClassification = CustomerContent;
    Caption = 'ECS Prod. Hierarchy Data';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Request ID"; Guid)
        {
            DataClassification = CustomerContent;
            Caption = 'Request ID';
        }
        field(3; "Message Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Message Type';
            OptionMembers = "0","1","2","3","4","5";
            OptionCaption = '0,Create,Update,Delete,4,Upsert';
        }
        field(4; "Hierarchy Parent Type"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Hierarchy Parent Type';
        }
        field(5; "Hierarchy Parent Value Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Hierarchy Parent Value Code';
        }
        field(6; "Hierarchy Child Type"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Hierarchy Child Type';
        }
        field(7; "Hierarchy Child Value Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Hierarchy Child Value Code';
        }
        field(8; "Hierarchy Child Description"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Hierarchy Child Description';
        }
        field(9; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
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
        key(Hierarchy; "Hierarchy Parent Type")
        {
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