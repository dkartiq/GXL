tableextension 50101 "GXL Trans. Sales Entry" extends "LSC Trans. Sales Entry"
{
    /* Change Log
        PS-1951 2020-09-22 LP
            Added flowfield and flowfilter fields
    */

    fields
    {
        field(50000; "GXL Legacy Item No."; Code[20])
        {
            Caption = 'Legacy Item No.';
            DataClassification = CustomerContent;
        }
        field(50001; "GXL Cost Amount"; Decimal)
        {
            Caption = 'GXL Cost Amount';
            Description = 'It is a GXL Standard Cost per UOM';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
        }
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
                "Line No." = field("Line No."), Infocode = field("GXL Infocode Filter")));
            Editable = false;
        }
        field(50004; "GXL Item Description"; Text[100])
        {
            Caption = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            Editable = false;
        }
        //PS-1951-
    }

}