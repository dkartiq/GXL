table 50160 "GXL ECS Promotion Line"
{
    Caption = 'ECS Promotion Line';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "ECS Event ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Event ID';
            Editable = false;
        }
        field(3; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item;

            trigger OnValidate()
            begin
                if "Item No." = '' then begin
                    "Legacy Item No." := '';
                    "Unit Of Measure Code" := '';
                    exit;
                end;

                if "Item No." <> xRec."Item No." then begin
                    GetItem();
                    if Item."Sales Unit of Measure" <> '' then
                        "Unit Of Measure Code" := Item."Sales Unit of Measure"
                    else
                        "Unit Of Measure Code" := item."Base Unit of Measure";
                    LegacyItemHelpers.GetLegacyItemNo("Item No.", "Unit Of Measure Code", "Legacy Item No.");
                end;
            end;
        }
        field(4; "Discount Value 1"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Discount Value 1';
        }
        field(5; "Discount Value 2"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Discount Value 2';
        }
        field(6; "Discount Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Discount Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(7; "Deal Text 1"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Deal Text 1';
        }
        field(8; "Deal Text 2"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Deal Text 2';
        }
        field(9; "Deal Text 3"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Deal Text 3';
        }
        field(10; "Default Size"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Size';
        }
        field(11; "Unit Of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));

            trigger OnValidate()
            begin
                TestField("Item No.");
                LegacyItemHelpers.GetLegacyItemNo("Item No.", "Unit Of Measure Code", "Legacy Item No.");
            end;
        }
        field(12; "Legacy Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Legacy Item No.';

            trigger OnValidate()
            var
                TempLegacyItemNo: Code[20];
            begin
                if "Legacy Item No." <> '' then
                    if "Item No." = '' then
                        LegacyItemHelpers.GetItemNo("Legacy Item No.", "Item No.", "Unit Of Measure Code")
                    else begin
                        LegacyItemHelpers.GetLegacyItemNo("Item No.", "Unit Of Measure Code", TempLegacyItemNo);
                        if TempLegacyItemNo <> "Legacy Item No." then
                            Error(LegacyItemNoMustBeErr, TempLegacyItemNo, "Item No.", "Unit Of Measure Code");
                    end;
            end;
        }
        field(20; "Created Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date Time';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key1; "ECS Event ID")
        { }
    }

    var
        Item: Record Item;
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        LegacyItemNoMustBeErr: Label 'Legacy Item No. must be %1 for Item No.=%2, UOM=%3';


    trigger OnInsert()
    begin
        "Created Date Time" := CurrentDateTime();
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

    local procedure GetItem()
    begin
        TestField("Item No.");
        if "Item No." <> Item."No." then
            Item.Get("Item No.");
    end;
}