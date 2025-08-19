tableextension 50022 "GXL Purch. Receipt Line" extends "Purch. Rcpt. Line"
{
    fields
    {
        //ERP-NAV Master Data Management +
        field(50300; "GXL Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50301; "GXL Cubage"; Decimal)
        {
            Caption = 'Cubage';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        //ERP-NAV Master Data Management +
    }

}