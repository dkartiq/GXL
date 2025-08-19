table 50355 "GXL ASN Level 4 Line"
{
    // //-- SR11653 24/10/2013 mcm PSSC0.02
    //   Modified table (all field names, option values, captions)

    Caption = 'ASN Level 4 Line';

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
        field(4; "Level 3 Line No."; Integer)
        {
            Caption = 'Level 3 Line No.';
            TableRelation = "GXL ASN Level 3 Line"."Line No." WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No."));
        }
        field(5; "Level 4 Type"; Option)
        {
            BlankZero = true;
            Caption = 'Level 4 Type';
            OptionCaption = ' ,Container,Pallet,Box,Item';
            OptionMembers = " ",Container,Pallet,Box,Item;
        }
        field(6; "Level 4 Code"; Code[50])
        {
            Caption = 'Level 4 Code';
        }
        field(7; Quantity; Decimal)
        {
            Caption = 'Quantity';
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
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.", "Level 3 Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

