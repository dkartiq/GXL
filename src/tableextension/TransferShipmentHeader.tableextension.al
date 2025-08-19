tableextension 50031 "GXL Transfer Shipment Header" extends "Transfer Shipment Header"
{
    fields
    {
        //PS-2523 VET Clinic transfer order +
        field(50254; "GXL VET Store Code"; Code[20])
        {
            Caption = 'VET Store Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL VET Store";
        }
        //PS-2523 VET Clinic transfer order -
    }

}