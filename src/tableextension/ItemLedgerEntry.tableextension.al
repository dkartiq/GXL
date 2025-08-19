tableextension 50018 "GXL Item Ledger Entry" extends "Item Ledger Entry"
{
    fields
    {
        //PS-2046+
        field(50253; "GXL MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
    }

}