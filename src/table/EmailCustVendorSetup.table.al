table 50373 "GXL Email Cust. & Vendor Setup"
{
    // //-- SR10578 ps.tad PSEM.00
    //      - T: Object Created

    Caption = 'Email Customer & Vendor Setup';

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Customer,Vendor';
            OptionMembers = Customer,Vendor;
        }
        field(2; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = IF (Type = CONST(Customer)) Customer."No." ELSE
            IF (Type = CONST(Vendor)) Vendor."No.";
        }
        field(3; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,Customer Statement,Purchase Quote,Purchase Order,Purchase Blanket Order,Purchase Return Order,Purchase Return Shipment,Purchase CR/Adj Note,Sales Quote,Sales Order,Sales Blanket Order,Sales Shipment,Sales Invoice,Sales Return Order,Sales CR/Adj Note,Service Order,Service Shipment,Service Invoice,Service CR/Adj Note';
            OptionMembers = " ","Customer Statement","Purchase Quote","Purchase Order","Purchase Blanket Order","Purchase Return Order","Purchase Return Shipment","Purchase CR/Adj Note","Sales Quote","Sales Order","Sales Blanket Order","Sales Shipment","Sales Invoice","Sales Return Order","Sales CR/Adj Note","Service Order","Service Shipment","Service Invoice","Service CR/Adj Note";
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
        }
        field(5; Email; Text[250])
        {
            Caption = 'Email';
            ExtendedDatatype = EMail;

            trigger OnValidate()
            begin
                EmailFunctions.CheckValidEmailAddresses(Email);
            end;
        }
    }

    keys
    {
        key(Key1; Type, "Code", "Document Type", "Line No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    var
        EmailFunctions: Codeunit "GXL Email Functions";
}

