table 50257 "GXL PDA-Staging Trans. Line"
{
    DataClassification = CustomerContent;
    Caption = 'PDA-Staging Transfer Line';

    fields
    {
        field(1; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(4; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(6; "Qty. to Ship"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. to Ship';
            DecimalPlaces = 0 : 5;
        }
        field(7; "Qty. to Receive"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. to Receive';
            DecimalPlaces = 0 : 5;
        }
        field(11; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(16; "Quantity (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(22; "Qty. per Unit of Measure"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. per Unit of Measure';
        }
        field(23; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
        field(50000; "Legacy Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Legacy Item No.';
        }
    }

    keys
    {
        key(PK; "Document No.", "Line No.")
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

    procedure PopulateTempTransferLine(TempTransHeader: Record "Transfer Header"; var TempTransLine: Record "Transfer Line")
    var
        Item: Record Item;
        UOMMgt: Codeunit "Unit of Measure Management";

    begin
        Item.Get("Item No.");
        Item.TestField(Type, Item.Type::Inventory);
        TempTransLine.Init();
        TempTransLine."Document No." := TempTransHeader."No.";
        TempTransLine."Line No." := 0;
        TempTransLine."Item No." := "Item No.";
        TempTransLine."Unit of Measure Code" := "Unit of Measure Code";
        TempTransLine.Quantity := Quantity;
        TempTransLine."Qty. per Unit of Measure" := UOMMgt.GetQtyPerUnitOfMeasure(Item, "Unit of Measure Code");
        TempTransLine."Quantity (Base)" := UOMMgt.CalcBaseQty(TempTransLine.Quantity, TempTransLine."Qty. per Unit of Measure");
        TempTransLine."Qty. to Receive" := "Qty. to Receive";
        TempTransLine."Qty. to Ship" := "Qty. to Ship";
        TempTransLine.Description := Description;
        if TempTransLine.Description = '' then
            TempTransLine.Description := Item.Description;
    end;

    procedure PopulateItemAndUOM()
    var
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
    begin
        if ("Item No." = '') and ("Legacy Item No." <> '') then
            LegacyItemHelpers.GetItemNo("Legacy Item No.", "Item No.", "Unit of Measure Code");
    end;

}