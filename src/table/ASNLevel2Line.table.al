table 50353 "GXL ASN Level 2 Line"
{
    DataClassification = CustomerContent;
    Caption = 'ASN Level 2 Line';

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
        field(4; "Level 1 Line No."; Integer)
        {
            Caption = 'Level 1 Line No.';
            TableRelation = "GXL ASN Level 1 Line"."Line No." WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No."));
        }
        field(5; "Level 2 Type"; Option)
        {
            BlankZero = true;
            Caption = 'Level 2 Type';
            OptionCaption = ' ,Container,Pallet,Box,Item';
            OptionMembers = " ",Container,Pallet,Box,Item;
        }
        field(6; "Level 2 Code"; Code[50])
        {
            Caption = 'SSCC';
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity Shipped in OP';
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
        field(15; ILC; Code[20])
        {
            Caption = 'ILC';
        }
        field(20; "Supplier No."; Code[20])
        {
            Caption = 'Supplier ID';
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
        field(40; "Carton Quantity"; Decimal)
        {
            Caption = 'Carton Quantity';
        }
        field(50; "Carton Gross Weight"; Decimal)
        {
            Caption = 'Carton Gross Weight';
            DataClassification = CustomerContent;
        }
        field(51; "Carton Net Weight"; Decimal)
        {
            Caption = 'Carton Net Weight';
            DataClassification = CustomerContent;
        }
        field(52; "Batch No."; Code[20])
        {
            Caption = 'Batch No.';
            DataClassification = CustomerContent;
        }
        field(53; "Batch Expiry Date"; Date)
        {
            Caption = 'Batch Expiry Date';
            DataClassification = CustomerContent;
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
        key(Key2; "Level 2 Code", "Document No.", Status, "Document Type")
        {
        }
        key(Key3; "Document Type", "Supplier No.", "Level 2 Code", "Document No.", Status)
        {
        }
    }

    fieldgroups
    {
        fieldgroup(Dropdown; "Document No.", "Level 2 Code", Quantity, "Quantity Received")
        { }
    }

    trigger OnDelete()
    var
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
    begin
        ASNLevel3Line.SETRANGE("Document Type", "Document Type");
        ASNLevel3Line.SETRANGE("Document No.", "Document No.");
        if "Level 2 Code" = '' then begin //ghost box
            ASNLevel3Line.SetRange("Level 2 Line No.", 0);
            ASNLevel3Line.SetRange("Loose Item Box Line", "Line No.");
        end else
            ASNLevel3Line.SETRANGE("Level 2 Line No.", "Line No.");
        ASNLevel3Line.DELETEALL(TRUE);
    end;

    procedure ShowLevel3Lines()
    var
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
    begin
        ASNLevel3Line.RESET();
        ASNLevel3Line.FILTERGROUP(2);
        ASNLevel3Line.SETRANGE("Document Type", "Document Type");
        ASNLevel3Line.SETRANGE("Document No.", "Document No.");
        ASNLevel3Line.SETRANGE("Level 2 Line No.", "Line No.");
        ASNLevel3Line.FILTERGROUP(0);

        PAGE.RUNMODAL(PAGE::"GXL Adv. Ship. Not. Lev 3 Line", ASNLevel3Line);
    end;
}

