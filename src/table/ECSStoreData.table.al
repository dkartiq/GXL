table 50151 "GXL ECS Store Data"
{
    /*
    ECS Integration:
        The table will log the changes in Store, Store Group and Store Group Setup
    */

    Caption = 'ECS Store Data';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; Entity; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Entity';
            OptionMembers = " ",Store,Cluster,StoreCluster;
            OptionCaption = ' ,Store,Cluster,StoreCluster';
        }
        field(3; "Action"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Action';
            OptionMembers = " ","Upsert","Modify","Delete";
            OptionCaption = ' ,Upsert,Modify,Delete';
        }
        field(11; "Store Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Code';
        }
        field(12; "Store Group Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Group Code';
        }
        field(13; "Store Name"; Text[100])
        {
            Caption = 'Name';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store".Name where("No." = field("Store Code")));
            Editable = false;
        }
        field(15; "Store Address"; Text[100])
        {
            Caption = 'Address';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store".Address where("No." = field("Store Code")));
            Editable = false;
        }
        field(16; "Store Address 2"; Text[50])
        {
            Caption = 'Address 2';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store"."Address 2" where("No." = field("Store Code")));
            Editable = false;
        }
        field(17; "Store City"; Text[30])
        {
            Caption = 'City';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store".City where("No." = field("Store Code")));
            Editable = false;
        }
        field(18; "Store Post Code"; Code[20])
        {
            Caption = 'Post Code';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store"."Post Code" where("No." = field("Store Code")));
            Editable = false;
        }
        field(19; "Store County"; Text[30])
        {
            Caption = 'State';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store".County where("No." = field("Store Code")));
            Editable = false;
        }
        field(20; "Store Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store"."Country Code" where("No." = field("Store Code")));
            Editable = false;
        }
        field(21; "Store Region Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Region Code';
        }
        field(22; "Store Open Date"; Date)
        {
            Caption = 'Open Date';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store"."GXL Open Date" where("No." = field("Store Code")));
            Editable = false;
        }
        field(23; "Store CLosed Date"; Date)
        {
            Caption = 'Closed Date';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store"."GXL Closed Date" where("No." = field("Store Code")));
            Editable = false;
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
        key(Entity; Entity)
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