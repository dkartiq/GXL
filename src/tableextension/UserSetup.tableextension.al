tableextension 50001 "GXL User Setup" extends "User Setup"
{
    fields
    {
        field(50350; "GXL Email Type"; Option)
        {
            Caption = 'Email Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Outlook,SMTP;
        }
    }
}