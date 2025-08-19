table 50368 "GXL ASN Level 3 Line Scan Log"
{

    Caption = 'ASN Level 3 Line Scan Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Purchase,Transfer';
            OptionMembers = Purchase,Transfer;
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            TableRelation = "GXL ASN Header"."No." WHERE("Document Type" = FIELD("Document Type"));
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; "Level 1 Line No."; Integer)
        {
            Caption = 'Level 1 Line No.';
        }
        field(6; "Level 2 Line No."; Integer)
        {
            Caption = 'Level 2 Line No.';
        }
        field(7; "Level 3 Code"; Code[50])
        {
            Caption = 'Item No.';
        }
        field(8; Quantity; Decimal)
        {
            Caption = 'Quantity Shipped in Unit';
        }
        field(9; "Quantity Received"; Decimal)
        {
            Caption = 'Quantity Received';
            MinValue = 0;
        }
        field(10; "Copied to ASN"; Boolean)
        {
            Caption = 'Copied to ASN';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
        }
        key(Key2; "Document No.", "Copied to ASN", "Document Type")
        {
            Clustered = true;
        }
        key(Key3; "Document No.", "Line No.", "Document Type") { }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
    begin
    end;
}

