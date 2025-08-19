table 50159 "GXL ECS Promotion Header"
{
    Caption = 'ECS Promotion Header';
    DataClassification = CustomerContent;
    LookupPageId = "GXL ECS Promotions";
    DrillDownPageId = "GXL ECS Promotions";

    fields
    {
        field(1; "Event Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Event Code';
            NotBlank = true;
        }
        field(2; "Promotion Type"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Promotion Type';
            TableRelation = "GXL ECS Promotion Type";
            NotBlank = true;
        }
        field(3; "Location Hierarchy Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Location Hierarchy Type';
            OptionMembers = " ",All,State,Region,Cluster,Location;
            OptionCaption = ' ,All,State,Region,Cluster,Location';
        }
        field(4; "Location Hierarchy Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Hierarchy Code';
            TableRelation = if ("Location Hierarchy Type" = const(State)) "Country/Region"
            else
            if ("Location Hierarchy Type" = const(Region)) "GXL Region"
            else
            if ("Location Hierarchy Type" = const(Cluster)) "LSC Store Group"
            else
            if ("Location Hierarchy Type" = const(Location)) "LSC Store";

        }
        field(5; "ECS Event ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Event ID';
            AutoIncrement = true;
            Editable = false;
        }
        field(6; "Event Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Event Status';
            OptionMembers = Planning,Active,Inactive;
            OptionCaption = 'Planning,Active,Inactive';
        }
        field(7; "Event Name"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Event Name';
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
    }

    keys
    {
        key(PK; "Event Code", "Promotion Type", "Location Hierarchy Type", "Location Hierarchy Code")
        {
            Clustered = true;
        }
        key(Key1; "ECS Event ID")
        {
        }
        key(Key2; "Event Status", "Start Date", "End Date")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Event Code", "Event Name", "Promotion Type", "Location Hierarchy Type", "Location Hierarchy Code")
        { }
        fieldgroup(Brick; "Event Code", "Event Name", "Promotion Type", "Location Hierarchy Type", "Location Hierarchy Code")
        { }
    }

    var
        ECSPromotionLine: Record "GXL ECS Promotion Line";

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin
        ECSPromotionLine.Reset();
        ECSPromotionLine.SetCurrentKey("ECS Event ID");
        ECSPromotionLine.SetRange("ECS Event ID", "ECS Event ID");
        ECSPromotionLine.DeleteAll();
    end;

    trigger OnRename()
    begin

    end;

}