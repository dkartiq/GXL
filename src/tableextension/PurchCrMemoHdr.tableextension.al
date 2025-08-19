tableextension 50025 "GXL Purch. Cr. Memo Hdr." extends "Purch. Cr. Memo Hdr."
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
        // >> LCB-13
        field(50400; "Send Email to Vendor"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        // << LCB-13
    }

}