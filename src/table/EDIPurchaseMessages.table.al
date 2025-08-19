table 50362 "GXL EDI-Purchase Messages"
{
    Caption = 'EDI-Purchase Messages';

    fields
    {
        field(1; ImportDoc; Option)
        {
            Caption = 'ImportDoc';
            OptionCaption = ' ,Confirmation,Invoice,ASN';
            OptionMembers = " ","1","2","3";
        }
        field(2; DocumentNumber; Code[20])
        {
        }
        field(3; LineReference; Integer)
        {
        }
        field(4; Items; Code[20])
        {
        }
        field(5; GTIN; Code[14])
        {
            Description = 'pv00.02';
        }
        field(6; SupplierNo; Code[20])
        {
            Description = 'pv00.02';
        }
        field(7; Description; Text[100])
        {
        }
        field(8; OMQty; Decimal)
        {
        }
        field(9; OPQty; Decimal)
        {
        }
        field(10; ConfirmedOrderQtyOM; Decimal)
        {
        }
        field(11; ConfirmedOrderQtyOP; Decimal)
        {
        }
        field(12; ConfirmedReceiptDate; Date)
        {
        }
        field(13; QtyToInvoice; Decimal)
        {
        }
        field(14; UnitCostExcl; Decimal)
        {
        }
        field(15; LineAmountExcl; Decimal)
        {
        }
        field(16; LineAmountIncl; Decimal)
        {
        }
        field(17; VendorInvoiceNumber; Code[20])
        {
        }
        field(18; InvoiceDate; Date)
        {
        }
        field(19; Processed; Boolean)
        {
        }
        field(20; "Error Found"; Boolean)
        {
        }
        field(21; "Error Description"; Text[250])
        {
        }
        field(22; QtyToRec; Decimal)
        {
        }
        field(23; "ASN Qty Variance"; Decimal)
        {
        }
        field(24; "Supplier Name"; Text[80])
        {
        }
        field(25; "Supplier ABN"; Code[20])
        {
        }
        field(26; Status; Option)
        {
            Caption = 'Status';
            Description = 'pv00.02';
            OptionCaption = 'Imported,Validation Error,Validated,Processing Error,Processed';
            OptionMembers = Imported,"Validation Error",Validated,"Processing Error",Processed;
        }
        field(27; "EDI File Log Entry No."; Integer)
        {
            Caption = 'EDI File Log Entry No.';
            Description = 'pv00.02';
            TableRelation = "GXL EDI File Log";
        }
        field(28; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            Description = 'pv00.02';
        }
        field(30; "Unit of Measure Code"; Code[10])
        {
            Caption = 'UOM';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
        field(31; ILC; Code[20])
        {
            Caption = 'ILC';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; ImportDoc, DocumentNumber, Items)
        {
            Clustered = true;
        }
        key(Key2; Processed, "Error Found")
        {
        }
        key(Key3; Status, ImportDoc, DocumentNumber)
        {
        }
        key(Key4; "EDI File Log Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

