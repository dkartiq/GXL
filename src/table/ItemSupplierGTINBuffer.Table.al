table 50376 "GXL Item-Supplier-GTIN Buffer"
{

    Caption = 'Item-Supplier-GTIN Buffer';

    fields
    {
        field(1; "Document Type"; Option)
        {
            OptionCaption = ' ,Purchase Order,Purchase Order Cancellation,Purchase Order Response,Advance Shipping Notice,Invoice';
            OptionMembers = " ",PO,POX,POR,ASN,INV;
        }
        field(2; "Document No."; Code[50])
        {
            Description = 'pv00.01';
        }
        field(3; "Line No."; Integer)
        {
        }
        field(4; "Old GTIN"; Code[50])
        {
        }
        field(5; "New GTIN"; Code[50])
        {
        }
        field(6; Change; Boolean)
        {
        }
    }

    keys
    {
        key(Key1; "Document Type", "Document No.", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

