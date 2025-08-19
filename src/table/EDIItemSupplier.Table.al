table 50377 "GXL EDI Item Supplier"
{
    Caption = 'EDI Item Supplier';

    fields
    {
        field(1; Supplier; Code[20])
        {
            Caption = 'Supplier';
            TableRelation = Vendor;
        }
        field(2; ILC; Code[20])
        {
            Caption = 'ILC';
            //TableRelation = Item;
        }
        field(3; GTIN; Code[50])
        {
            Caption = 'GTIN';
        }
    }

    keys
    {
        key(Key1; ILC, Supplier)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

