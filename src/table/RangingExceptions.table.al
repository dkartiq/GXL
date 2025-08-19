table 50004 "GXL Ranging Exceptions"
{
    Caption = 'Ranging Exceptions';
    DataClassification = CustomerContent;
    LookupPageId = "GXL Ranging Exceptions";
    DrillDownPageId = "GXL Ranging Exceptions";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(2; "Store Code"; Code[10])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("GXL Location Type" = filter("6"));
        }
        field(3; Range; Boolean)
        {
            Caption = 'Range';
            DataClassification = CustomerContent;
        }
        field(4; "Last Modified Date"; Date)
        {
            Caption = 'Last Modified Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.", "Store Code")
        {
            Clustered = true;
        }
        key(LastModifiedDate; "Last Modified Date") { }
    }

    var

    trigger OnInsert()
    begin
        "Last Modified Date" := Today();
    end;

    trigger OnModify()
    begin
        "Last Modified Date" := Today();
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin
        Error('You cannot rename a %1', TableCaption());
    end;

}