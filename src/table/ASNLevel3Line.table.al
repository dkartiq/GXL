table 50354 "GXL ASN Level 3 Line"
{
    DataClassification = CustomerContent;
    Caption = 'ASN Level 3 Line';

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Purchase,Transfer';
            OptionMembers = Purchase,Transfer;
        }
        field(2; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "GXL ASN Header"."No." WHERE("Document Type" = FIELD("Document Type"));
        }
        field(3; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(4; "Level 2 Line No."; Integer)
        {
            Caption = 'Level 2 Line No.';
            TableRelation = "GXL ASN Level 2 Line"."Line No." WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No."));
        }
        field(5; "Level 3 Type"; Option)
        {
            BlankZero = true;
            Caption = 'Level 3 Type';
            OptionCaption = ' ,Container,Pallet,Box,Item';
            OptionMembers = " ",Container,Pallet,Box,Item;
        }
        field(6; "Level 3 Code"; Code[50])
        {
            Caption = 'Item No.';
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity Shipped in Unit';
        }
        field(8; "Weight of Stock"; Decimal)
        {
            Caption = 'Weight of Stock';
        }
        field(9; "Nominal Weight"; Decimal)
        {
            Caption = 'Nominal Weight';
        }
        field(10; "Count / Pack Size"; Decimal)
        {
            Caption = 'Count / Pack Size';
        }
        field(11; "Use by Date"; Date)
        {
            Caption = 'Use by Date';
        }
        field(12; "Packed on Date"; Date)
        {
            Caption = 'Packed on Date';
        }
        field(13; "Inners / Outer"; Decimal)
        {
            Caption = 'Inners / Outer';
        }
        field(14; "Legal Requirements"; Text[100])
        {
            Caption = 'Legal Requirements';
        }
        field(15; GTIN; Code[50])
        {
            Caption = 'GTIN';
        }
        field(16; "Level 1 Line No."; Integer)
        {
            Caption = 'Level 1 Line No.';
            TableRelation = "GXL ASN Level 1 Line"."Line No." WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No."));
        }
        field(21; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Imported,Validation Error,Validated,Processing Error,Processed,Scan Process Error,Scanned,Receiving Error,Receiving,Received,Return Order Creation Error,Return Order Created,Return Order Application Error,Return Order Applied,Return Shipment Posting Error,Return Shipment Posted,,,,,,,,,,,,3PL ASN Sending Error,3PL ASN Sent';
            OptionMembers = Imported,"Validation Error",Validated,"Processing Error",Processed,"Scan Process Error",Scanned,"Receiving Error",Receiving,Received,"Return Order Creation Error","Return Order Created","Return Order Application Error","Return Order Applied","Return Shipment Posting Error","Return Shipment Posted",,,,,,,,,,,,"3PL ASN Sending Error","3PL ASN Sent";
        }
        field(22; "Quantity Received"; Decimal)
        {
            Caption = 'Quantity Received';
        }
        field(23; "Loose Item Box Line"; Integer)
        {
            Caption = 'Loose Item Box Line';
            TableRelation = "GXL ASN Level 2 Line"."Line No." where("Document Type" = field("Document Type"), "Document No." = field("Document No."));
            ValidateTableRelation = false;
        }
        field(40; "Carton Quantity"; Decimal)
        {
            Caption = 'Carton Quantity';
        }
        field(50; "Batch No."; Code[20])
        {
            Caption = 'Batch No.';
        }
        field(51; "Batch Expiry Date"; Date)
        {
            Caption = 'Batch Expiry Date';
        }
        field(100; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(101; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Document Type", "Document No.", "Level 3 Code")
        {
            SumIndexFields = Quantity, "Quantity Received";
        }
        key(Key3; "Level 3 Code", "Document No.", "Level 1 Line No.", "Level 2 Line No.", Status, "Document Type")
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Document No.", "Level 3 Code", GTIN, Quantity, "Quantity Received")
        { }
    }

    trigger OnInsert()
    var
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
    begin
        if ("Level 3 Type" = "Level 3 Type"::Item) and ("Level 3 Code" <> '') and ("Item No." = '') then
            LegacyItemHelpers.GetItemNoForPurchase("Level 3 Code", "Item No.", "Unit of Measure Code");
    end;

    trigger OnDelete()
    var
        ASNLevel4Line: Record "GXL ASN Level 4 Line";
    begin
        ASNLevel4Line.SETRANGE("Document Type", "Document Type");
        ASNLevel4Line.SETRANGE("Document No.", "Document No.");
        ASNLevel4Line.SETRANGE("Level 3 Line No.", "Line No.");
        ASNLevel4Line.DELETEALL(TRUE);
    end;

    procedure ShowLevel4Lines()
    var
        ASNLevel4Line: Record "GXL ASN Level 4 Line";
    begin
        ASNLevel4Line.RESET();
        ASNLevel4Line.FILTERGROUP(2);
        ASNLevel4Line.SETRANGE("Document Type", "Document Type");
        ASNLevel4Line.SETRANGE("Document No.", "Document No.");
        ASNLevel4Line.SETRANGE("Level 3 Line No.", "Line No.");
        ASNLevel4Line.FILTERGROUP(0);

        PAGE.RUNMODAL(PAGE::"GXL Adv. Ship. Not. Lev 4 Line", ASNLevel4Line);
    end;
}

