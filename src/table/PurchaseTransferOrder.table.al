table 50035 "GXL Purchase/Transfer Order"
{
    /*
    001 24.03.2022  PREM    LCB-4   New Fields created i.e. "ASN Required", "ASN Created", "ASN No."", "ASN Received".   Amount FieldClass changed to Normal
    ERP-295 19-08-2021
    */

    DataClassification = CustomerContent;
    Caption = 'Purchase/Transfer Order';

    fields
    {
        field(1; "Document Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';
            OptionMembers = "Purchase","Transfer";
            OptionCaption = 'Purchase,Transfer';
        }
        field(2; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(3; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor No.';
            TableRelation = Vendor;
        }
        field(4; "Vendor Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Name';
        }
        field(9; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
        }
        field(10; "Expected Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Receipt Date';
        }
        field(11; "Store No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Store No.';
            TableRelation = "LSC Store";
        }
        field(19; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(20; Amount; Decimal)
        {
            Caption = 'Amount';
            // >> 001
            /*
            FieldClass = FlowField;
            CalcFormula = sum("Purchase Line".Amount where("Document Type" = const(Order), "Document No." = field("No.")));
            */
            // << 001
            Editable = false;
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
        }
        field(50; "Store-from No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Store-from No.';
            TableRelation = "LSC Store";
        }
        field(51; "Store-from Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Store-from Name';
        }
        field(52; "Store-to No."; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Store-to No.';
            TableRelation = "LSC Store";
        }
        field(53; "Store-to Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Store-to Name';
        }
        // >> 001
        field(54; "ASN Required"; Boolean) { }
        field(55; "ASN Created"; Boolean) { }
        field(56; "ASN No."; Code[20]) { }
        field(57; "ASN Received"; Boolean) { }
        // << 001

    }

    keys
    {
        key(PK; "Document Type", "No.")
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

}