tableextension 50033 "GXL Sales Header" extends "Sales Header"
{
    fields
    {
        //PS-2523 VET Clinic transfer order +
        field(50253; "GXL MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        field(50254; "GXL VET Store Code"; Code[20])
        {
            Caption = 'VET Store Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL VET Store";
        }
        //PS-2523 VET Clinic transfer order -

    }

}