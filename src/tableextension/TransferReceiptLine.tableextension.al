tableextension 50011 "GXL Transfer Receipt Line" extends "Transfer Receipt Line"
{
    fields
    {
        //PS-2523 VET Clinic transfer order +
        field(50003; "GXL Original Order Quantity"; Decimal)
        {
            Caption = 'Original Order Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        //PS-2523 VET Clinic transfer order -
        field(50351; "GXL Qty Variance"; Decimal)
        {
            Caption = 'Qty Variance';
            DataClassification = CustomerContent;
        }
        field(50352; "GXL Qty. Variance Resaon Code"; Code[10])
        {
            Caption = 'Qty. Variance Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
    }
}