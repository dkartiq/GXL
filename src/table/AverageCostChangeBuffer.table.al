//CR029: Average Cost trapping
//<Summary>
//This table is used to log item number and its pre-post unit cost/average cost on posting an inbound transaction
//</Summary>
table 50012 "GXL Average Cost Change Buffer"
{
    Caption = 'Average Cost Change Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(3; "Last Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost Before Run';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
        }
        field(5; "Last Average Cost"; Decimal)
        {
            Caption = 'Average Cost';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
        }
        field(7; "Last Value Entry No."; Integer)
        {
            Caption = 'Last Value Entry No.';
            DataClassification = CustomerContent;
        }

    }

    keys
    {
        key(PK; "Item No.")
        {
            Clustered = true;
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