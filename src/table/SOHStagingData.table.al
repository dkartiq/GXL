//PS-1392: Re-designed
table 50110 "GXL SOH Staging Data"
{
    DataClassification = CustomerContent;
    Caption = 'SOH Staging Data';

    fields
    {
        field(1; "Batch ID"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Batch ID';
        }
        field(2; "Auto ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Auto ID';
            AutoIncrement = true;
        }
        field(3; "Log Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Log Time';
        }
        field(4; "Store Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Code';
            TableRelation = "LSC Store";
        }
        field(5; "Legacy Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Legacy Item No.';

        }
        field(6; "New Qty."; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'New Qty.';
        }
        field(7; "Commited Qty."; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Commited Qty.';
        }
        field(8; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(9; UOM; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'UOM';
            TableRelation = "Unit of Measure";
        }
        field(10; "Base SOH"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Base SOH';
        }
        field(11; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
        }
        field(12; "Log Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Log Date';
        }
        field(13; "Replication Counter"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Replication Counter';

            //<< PS-1392: Removed as Aauto ID is used for replication            
            /*
            trigger OnValidate()
            var
                TransSalesEntry: Record "LSC Trans. Sales Entry";
                ClientSessionUtility: Codeunit "Client Session Utility";
            begin
                IF NOT ClientSessionUtility.UpdateReplicationCounters() THEN
                    EXIT;
                TransSalesEntry.SETCURRENTKEY("Replication Counter");
                IF TransSalesEntry.FINDLAST() THEN
                    "Replication Counter" := TransSalesEntry."Replication Counter" + 1
                ELSE
                    "Replication Counter" := 1;
            end;
            */
        }

    }

    keys
    {
        key(PK; "Auto ID")
        {
            Clustered = true;
        }
        key(BatchID; "Batch ID") { }
        key(LogDate; "Log Date") { }
    }

    var

    trigger OnInsert()
    begin
        //Validate("Replication Counter"); //<< PS-1392: Removed as Aauto ID is used for replication
    end;

    trigger OnModify()
    begin
        //Validate("Replication Counter"); //<< PS-1392: Removed as Aauto ID is used for replication
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}