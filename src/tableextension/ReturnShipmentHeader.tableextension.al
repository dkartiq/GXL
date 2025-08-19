tableextension 50027 "GXL Return Shipment Header" extends "Return Shipment Header"
{
    fields
    {
        //ERP-NAV Master Data Management +
        field(50000; "GXL No. Emailed"; Integer)
        {
            Caption = 'No. of Emailed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        //ERP-NAV Master Data Management -
    }

}