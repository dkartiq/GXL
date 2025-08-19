table 50387 "GXL ASN Scanning Discrepancy"
{
    Caption = 'ASN Scanning Discrepancy';

    fields
    {
        field(1; "ASN Document Type"; Option)
        {
            Caption = 'ASN Document Type';
            OptionCaption = 'Purchase,Transfer';
            OptionMembers = Purchase,Transfer;
        }
        field(2; "ASN Document No."; Code[20])
        {
            Caption = 'ASN Document No.';
        }
        field(4; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            //TableRelation = Item; //PS-2452: Removed as Item is from NAV13, it is a legacy item no.
        }
        field(5; "Quantity Confirmed"; Decimal)
        {
        }
        field(6; "Quantity Scanned"; Decimal)
        {
        }
        field(7; Difference; Decimal)
        {
        }
    }

    keys
    {
        key(Key1; "ASN Document Type", "ASN Document No.", "Item No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

