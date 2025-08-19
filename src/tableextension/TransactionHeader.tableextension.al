// 001 18.11.2024 KDU https://petbarnjira.atlassian.net/browse/LCB-726
tableextension 50401 "GXL Transaction Header" extends "LSC Transaction Header"
{
    /* Change Log
        PS-1951 2020-09-22 LP
            Added flowfield and flowfilter fields
    */

    fields
    {
        //PS-1951+
        field(50002; "GXL Infocode Filter"; Code[20])
        {
            Caption = 'Infocode Filter';
            FieldClass = FlowFilter;
            TableRelation = "LSC Infocode";
        }
        field(50003; "GXL Infocode Exists"; Boolean)
        {
            Caption = 'Infocode Exists';
            FieldClass = FlowField;
            CalcFormula = exist("LSC Trans. Infocode Entry" where("Store No." = field("Store No."),
                "POS Terminal No." = field("POS Terminal No."), "Transaction No." = field("Transaction No."),
                Infocode = field("GXL Infocode Filter")));
            Editable = false;
        }
        //PS-1951-
        // >> 001 
        //field(50100; "GXL Magento WebOrder Trans. ID"; Code[20]) 
        field(50100; "GXL Magento WebOrder Trans. ID"; Code[50])
        // << 001 
        {
            Caption = 'Magento Web Order Trans. ID';
            DataClassification = CustomerContent;
        }
        field(50400; "GXL Auto Stock Posting"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Automatic Stock Posting';
        }

        // >> LCB-463        
        field(66600; "Re-Submit to Bloyal"; Boolean)
        {
            Caption = 'Re-Submit to Bloyal';
            DataClassification = CustomerContent;
        }
        // << LCB-463
    }

    keys
    {
        key(Key66600; "Re-Submit to Bloyal")
        {
        }

    }
}