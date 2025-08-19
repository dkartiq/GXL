tableextension 50039 "GXL Gen. Journal Template" extends "Gen. Journal Template"
{
    fields
    {
        //ERP-162 GL Balance by Entity Code (Dim1) +
        field(50000; "GXL Force Dim 1 Balance"; Boolean)
        {
            Caption = 'Force Shortcut Dim 1 Balance';
            DataClassification = CustomerContent;
        }
        //ERP-162 GL Balance by Entity Code (Dim1) -
    }

}