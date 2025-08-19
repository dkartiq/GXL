table 50261 "GXL PDA-Staging Purch. Line"
{
    Caption = 'PDA-Staging Purchase Lines';
    DataClassification = CustomerContent;

    fields
    {
        field(3; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(4; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(5; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            OptionMembers = " ","G/L Account",Item,,"Fixed Asset","Charge (Item)";
            OptionCaption = ' ,G/L Account,Item,,Fixed Asset,Charge (Item)';
        }
        field(6; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
            TableRelation = if (Type = const(" ")) "Standard Text" else
            if (Type = const("G/L Account")) "G/L Account" else
            if (Type = const("Fixed Asset")) "Fixed Asset" else
            if (Type = const("Charge (Item)")) "Item Charge" else
            if (Type = const(Item)) Item;
        }
        field(7; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(11; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(15; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(18; "Qty. to Receive"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. to Receive';
            DecimalPlaces = 0 : 5;
        }
        field(22; "Direct Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Direct Unit Cost';
            AutoFormatType = 2;
            AutoFormatExpression = "Currency Code";
            CaptionClass = GetCaptionClass(FieldNo("Direct Unit Cost"));
        }
        field(25; "VAT %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'GST %';
        }
        field(27; "Line Discount %"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Discount %';
        }
        field(28; "Line Discount Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Discount Amount';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
            CaptionClass = GetCaptionClass(FieldNo("Line Discount Amount"));
        }
        field(29; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
        }
        field(30; "Amount Including VAT"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount Including GST';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
        }
        field(91; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(103; "Line Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Line Amount';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
            CaptionClass = GetCaptionClass(FieldNo("Line Amount"));
        }
        field(5404; "Qty. per Unit of Measure"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. per Unit of Measure';
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(5407; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("No."));
        }
        field(5415; "Quantity (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(50000; "Legacy Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Legacy Item No.';
        }
        field(50001; "Carton-Qty"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Carton-Qty.';
            DecimalPlaces = 0 : 5;
        }
        field(50351; "Qty. Variance Reason Code"; Code[10])
        {
            Caption = 'Qty. Variance Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(50356; "Vendor Reorder No."; Code[20])
        {
            Caption = 'Vendor Reorder No.';
            DataClassification = CustomerContent;
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

    procedure GetCaptionClass(FieldNumber: Integer): Text
    var
        PDAStagingCaptionClassMgmt: Codeunit "GXL PDA-Staging PL CaptionMgt";
    begin
        exit(PDAStagingCaptionClassMgmt.GetPDAStgingPurchaseLineCaptionClass(Rec, FieldNumber));
    end;

    procedure PopulateTempPurchLine(TempPurchHeader: Record "Purchase Header"; var TempPurchLine: Record "Purchase Line"; KeepPrice: Boolean)
    begin
        TempPurchLine.SetPurchHeader(TempPurchHeader);
        TempPurchLine.Init();
        TempPurchLine."Document Type" := TempPurchLine."Document Type"::Order;
        TempPurchLine."Document No." := TempPurchHeader."No.";
        TempPurchLine."Line No." := 0;
        TempPurchLine.Type := TempPurchLine.Type::Item;
        TempPurchLine.Validate("No.", "No.");
        TempPurchLine.Validate("Location Code", "Location Code");
        TempPurchLine.Validate(Quantity, Quantity);
        if KeepPrice then begin
            if TempPurchLine."Direct Unit Cost" <> "Direct Unit Cost" then
                TempPurchLine.Validate("Direct Unit Cost", "Direct Unit Cost");
            if TempPurchLine."Line Discount %" <> "Line Discount %" then
                TempPurchLine.Validate("Line Discount %", "Line Discount %");
        end;
        TempPurchLine."GXL Qty. Variance Reason Code" := "Qty. Variance Reason Code";
    end;

    procedure PopulateItemAndUOM()
    var
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
    begin
        if ("No." = '') and ("Legacy Item No." <> '') then
            LegacyItemHelpers.GetItemNoForPurchase("Legacy Item No.", "No.", "Unit of Measure Code");
    end;

}