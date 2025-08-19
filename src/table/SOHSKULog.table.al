table 50111 "GXL SOH SKU Log"
{
    Caption = 'SOH SKU Log';
    DataClassification = CustomerContent;

    fields
    {
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(3; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
    }

    keys
    {
        key(PK; "Item No.", "Location Code")
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


    procedure InsertLogFromItemLedgerEntry(ItemLedgEntry: Record "Item Ledger Entry")
    var
        SOHSKULog: Record "GXL SOH SKU Log";
    begin
        if SOHSKULog.Get(ItemLedgEntry."Item No.", ItemLedgEntry."Location Code") then
            exit;

        SOHSKULog.Init();
        SOHSKULog."Item No." := ItemLedgEntry."Item No.";
        SOHSKULog."Location Code" := ItemLedgEntry."Location Code";
        SOHSKULog.Insert();
    end;

    procedure InsertLogFromSKU(SKU: Record "Stockkeeping Unit")
    var
        SOHSKULog: Record "GXL SOH SKU Log";
    begin
        if SOHSKULog.Get(SKU."Item No.", SKU."Location Code") then
            exit;

        SOHSKULog.Init();
        SOHSKULog."Item No." := SKU."Item No.";
        SOHSKULog."Location Code" := SKU."Location Code";
        SOHSKULog.Insert();
    end;

}