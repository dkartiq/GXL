table 50262 "GXL Vend. Claim Classification"
{
    DataClassification = CustomerContent;
    Caption = 'Vendor Claim Classification';
    LookupPageId = "GXL Vend. Claim Classification";

    fields
    {
        field(1; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            NotBlank = true;
        }
        field(2; "Claim Reason Code"; Code[10])
        {
            Caption = 'Claim Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
            NotBlank = true;
        }
        field(3; "Ullage Claim Classification"; Enum "GXL Vendor Ullaged Status")
        {
            Caption = 'Ullage Claim Classification';
            DataClassification = CustomerContent;
        }
        field(4; "Purch. Credit Memo Account"; Code[20])
        {
            Caption = 'Purch. CR/Adj Note Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        field(10; "Vendor Name"; Text[100])
        {
            Caption = 'Vendor Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Vendor No.")));
            Editable = false;
        }
        field(11; "Claim Description"; Text[100])
        {
            Caption = 'Claim Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Reason Code".Description where(Code = field("Claim Reason Code")));
            Editable = false;
        }
        field(13; "Purc. Cr. Memo Account Name"; Text[100])
        {
            Caption = 'Purch. CR/Adj Note Account Name';
            FieldClass = FlowField;
            CalcFormula = lookup("G/L Account".Name where("No." = field("Purch. Credit Memo Account")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Vendor No.", "Claim Reason Code")
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