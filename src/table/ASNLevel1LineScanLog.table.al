table 50366 "GXL ASN Level 1 Line Scan Log"
{
    // //-- SR12105 14/04/2015 mcm pv00.00
    //   EDI Development
    //   New Table

    Caption = 'ASN Level 1 Line Scan Log';

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
        field(5; "Level 1 Code"; Code[50])
        {
            Caption = 'SSCC';
        }
        field(6; Quantity; Decimal)
        {
            Caption = 'Quantity';
        }
        field(7; "Quantity Received"; Decimal)
        {
            Caption = 'Quantity Received';
            MinValue = 0;
        }
        field(8; "Copied to ASN"; Boolean)
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

