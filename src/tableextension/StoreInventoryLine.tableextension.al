tableextension 50019 "GXL Store Inventory Line" extends "LSC Store Inventory Line"
{
    fields
    {
        //PS-2046+
        field(200; "GXL MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
        //PS-2393+
        field(50271; "GXL Stocktake Name"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Stocktake Name';
            Editable = false;
        }
        //PS-2393-
    }

}