tableextension 50271 "GXL Store Inv Worksheet Buffer" extends "LSC Store Inv. Wrksh. Buffer"
{
    fields
    {
        field(50270; "GXL Open"; Boolean)
        {
            Caption = 'Open';
            DataClassification = CustomerContent;
        }
        field(50271; "GXL StockTake Description"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'StockTake Description';
        }
        field(50272; "GXL Date Opened"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Date Opened';
        }
        field(50273; "GXL No. of Stock Take Lines"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'No. of Stock Take Lines';
        }
        field(50274; "GXL User ID"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'User ID';
        }

    }

}