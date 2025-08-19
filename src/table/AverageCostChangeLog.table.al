//CR029: Average Cost trapping
//<Summary>
//This table is used to log cost change during item cost adjustment batch job
//</Summary>
table 50011 "GXL Average Cost Change Log"
{
    Caption = 'Average Cost Change Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(3; "Unit Cost Before Run"; Decimal)
        {
            Caption = 'Unit Cost Before Run';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
        }
        field(4; "Unit Cost After Run"; Decimal)
        {
            Caption = 'Unit Cost After Run';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
        }
        field(5; "Average Cost Before Run"; Decimal)
        {
            Caption = 'Average Cost Before Run';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
        }
        field(6; "Average Cost After Run"; Decimal)
        {
            Caption = 'Average Cost After Run';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
        }
        field(7; "Last Value Entry Before Run"; Integer)
        {
            Caption = 'Last Value Entry No. Before Run';
            DataClassification = CustomerContent;
            TableRelation = "Value Entry";
        }
        field(8; "Last Value Entry After Run"; Integer)
        {
            Caption = 'Last Value Entry No. After Run';
            DataClassification = CustomerContent;
            TableRelation = "Value Entry";
        }
        field(10; "Run Date"; Date)
        {
            Caption = 'Run Date';
            DataClassification = CustomerContent;
        }
        field(11; "Run Time"; Time)
        {
            Caption = 'Run Time';
            DataClassification = CustomerContent;
        }
        field(12; "Run by User ID"; Code[50])
        {
            Caption = 'Run by User ID';
            DataClassification = EndUserIdentifiableInformation;
            TableRelation = User."User Name";
            Editable = false;
        }
        field(13; "Copied from Buffer"; Boolean)
        {
            Caption = 'Copied from Buffer';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(ItemNo; "Item No.")
        { }
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