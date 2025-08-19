/// <summary>
/// ERP-NAV Master Data Management
/// </summary>
table 50030 "GXL NAV Item/SKU Buffer"
{
    Caption = 'NAV Item/SKU Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(3; "Legacy Item No."; Code[20])
        {
            Caption = 'Legacy Item No.';
            DataClassification = CustomerContent;
        }
        field(4; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(10; "First Receipt Date"; Date)
        {
            Caption = 'First Receipt Date';
            DataClassification = CustomerContent;
        }
        field(11; Inventory; Decimal)
        {
            Caption = 'Inventory';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(12; "Qty. on Purch. Order"; Decimal)
        {
            Caption = 'Qty. on Purch. Order';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(13; "Qty. in Transit"; Decimal)
        {
            Caption = 'Qty. in Transit';
            DecimalPlaces = 0 : 5;
        }
        field(20; "Date Time Created"; DateTime)
        {
            Caption = 'Date Time Created';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "Date Time Modified"; DateTime)
        {
            Caption = 'Date Time Modified';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(100; "Replication Counter"; Integer)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Item No.", "Legacy Item No.", "Location Code")
        {
            Clustered = true;
        }
        key(ReplicationCounter; "Replication Counter")
        { }
    }

    var

    trigger OnInsert()
    begin
        if "Replication Counter" = 0 then
            "Replication Counter" := GetLastReplicationCounter() + 1;
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

    procedure GetLastReplicationCounter(): Integer
    var
        NAVItemSKUBuffer: Record "GXL NAV Item/SKU Buffer";
    begin
        NAVItemSKUBuffer.SetCurrentKey("Replication Counter");
        if NAVItemSKUBuffer.FindLast() then
            exit(NAVItemSKUBuffer."Replication Counter")
        else
            exit(0);
    end;

}