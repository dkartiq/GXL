table 50153 "GXL ECS Data Template Header"
{
    Caption = 'ECS Data Template Header';
    DataClassification = CustomerContent;
    LookupPageId = "GXL ECS Data Templates";
    DrillDownPageId = "GXL ECS Data Templates";

    fields
    {
        field(1; "Code"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }
        field(2; "ECS WS Function"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS WS Function';
        }
        field(3; "Table ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table ID';
            TableRelation = AllObj."Object ID" where("Object Type" = const(Table));
        }
        field(4; "Table Name"; Text[250])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, "ECS WS Function", "Table ID", "Table Name")
        {
        }
        fieldgroup(Brick; Code, "ECS WS Function", "Table ID")
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