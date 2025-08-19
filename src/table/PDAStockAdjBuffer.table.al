table 50252 "GXL PDA-Stock Adj. Buffer"
{
    Caption = 'PDA-Stock Adj. Buffer';
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
        field(2; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            OptionMembers = "ADJ","SOH","ALL";
            OptionCaption = 'ADJ,SOH,ALL';
        }
        field(3; "Store Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Code';
            TableRelation = Location;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
        field(10; "Stock on Hand"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Stock on Hand';
            DecimalPlaces = 0 : 5;
        }
        field(11; "Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(12; "Created Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date Time';
        }
        field(13; "Error Occured"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Error';
        }
        field(14; "Error Code"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Code';
        }
        field(15; "Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
        }
        field(16; Processed; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed';
        }
        field(17; "Claim Document Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Claim Document Type';
            OptionMembers = " ",PO,PI,STO,"STO-SHIP","STO-REC";
            OptionCaption = ' ,Purchase Order,Purchase Invoice,Transfer Order,Transfer Shipment,Transfer Receipt';
        }
        field(18; "Claim Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Claim Document No.';
        }
        field(100; "Legacy Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Legacy Item No.';
            Editable = false;
            //It is mainly used for WH Messages Lines transfer for reference purposes
        }
        //PS-2046+
        field(200; "MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }

    var
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";


    trigger OnInsert()
    begin
        "Created Date Time" := CurrentDateTime();
        if ("Legacy Item No." = '') and ("Item No." <> '') then
            LegacyItemHelpers.GetLegacyItemNo("Item No.", "Unit of Measure Code", "Legacy Item No.");
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