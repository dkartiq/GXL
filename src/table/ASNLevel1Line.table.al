table 50352 "GXL ASN Level 1 Line"
{
    Caption = 'ASN Level 1 Line';

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
        field(4; "Level 1 Type"; Option)
        {
            BlankZero = true;
            Caption = 'Level 1 Type';
            OptionCaption = ' ,Container,Pallet,Box,Item';
            OptionMembers = " ",Container,Pallet,Box,Item;
        }
        field(5; "Level 1 Code"; Code[50])
        {
            Caption = 'SSCC';
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(7; "Weight of Stock"; Decimal)
        {
            Caption = 'Weight of Stock';
        }
        field(8; "Nominal Weight"; Decimal)
        {
            Caption = 'Nominal Weight';
        }
        field(9; "Count / Pack Size"; Decimal)
        {
            Caption = 'Count / Pack Size';
        }
        field(10; "Use by Date"; Date)
        {
            Caption = 'Use by Date';
        }
        field(11; "Packed on Date"; Date)
        {
            Caption = 'Packed on Date';
        }
        field(12; "Inners / Outer"; Decimal)
        {
            Caption = 'Inners / Outer';
        }
        field(13; "Legal Requirements"; Text[100])
        {
            Caption = 'Legal Requirements';
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
            Description = 'MCS1.58';
        }
        field(50; "Package Gross Weight"; Decimal)
        {
            Description = 'MCS1.58';
        }
        field(51; "Package Net Weight"; Decimal)
        {
            Description = 'MCS1.58';
        }
        field(52; "Number of Layers"; Integer)
        {
            Description = 'MCS1.58';
        }
        field(53; "Units Per Layer"; Integer)
        {
            Description = 'MCS1.58';
        }
        field(54; "Batch No."; Code[20])
        {
            Description = 'MCS1.58';
        }
        field(55; "Batch Expiry Date"; Date)
        {
            Description = 'MCS1.58';
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Level 1 Code", "Document No.", Status, "Document Type")
        {
        }
        key(Key3; "Document Type", "Supplier No.", "Level 1 Code", "Document No.", Status)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
    begin
        ASNLevel2Line.SETRANGE("Document Type", "Document Type");
        ASNLevel2Line.SETRANGE("Document No.", "Document No.");
        ASNLevel2Line.SETRANGE("Level 1 Line No.", "Line No.");
        ASNLevel2Line.DELETEALL(TRUE);

        ASNLevel3Line.SETRANGE("Document Type", "Document Type");
        ASNLevel3Line.SETRANGE("Document No.", "Document No.");
        ASNLevel3Line.SETRANGE("Level 1 Line No.", "Line No.");
        ASNLevel3Line.DELETEALL(TRUE);
    end;


    procedure ShowLevel2Lines()
    var
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
    begin
        ASNLevel2Line.RESET();

        ASNLevel2Line.FILTERGROUP(2);
        ASNLevel2Line.SETRANGE("Document Type", "Document Type");
        ASNLevel2Line.SETRANGE("Document No.", "Document No.");
        ASNLevel2Line.SETRANGE("Level 1 Line No.", "Line No.");
        ASNLevel2Line.SETFILTER(ASNLevel2Line."Level 2 Code", '<>%1', '');
        ASNLevel2Line.FILTERGROUP(0);

        PAGE.RUNMODAL(PAGE::"GXL Adv. Ship. Not. Lev 2 Line", ASNLevel2Line);
    end;


    procedure ShowLevel3Lines()
    var
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
    begin
        //Ghost box
        ASNLevel3Line.RESET();

        ASNLevel3Line.FILTERGROUP(2);
        ASNLevel3Line.SETRANGE("Document Type", "Document Type");
        ASNLevel3Line.SETRANGE("Document No.", "Document No.");
        ASNLevel3Line.SETRANGE("Level 2 Line No.", 0);
        ASNLevel3Line.SETRANGE("Level 1 Line No.", "Line No.");
        ASNLevel3Line.FILTERGROUP(0);

        PAGE.RUNMODAL(PAGE::"GXL Adv. Ship. Not. Lev 3 Line", ASNLevel3Line);
    end;
}

