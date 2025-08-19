/// <summary>
/// TableExtension GXL Information Subcode (ID 50402) extends Record LSC Information Subcode.
/// </summary>
tableextension 50402 "GXL Information Subcode" extends "LSC Information Subcode"
{
    fields
    {
        //CR007
        field(50400; "GXL Saleable"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'GXL Saleable';
        }
    }
}