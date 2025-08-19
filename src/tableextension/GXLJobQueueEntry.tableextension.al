tableextension 50351 "GXL GXLJobQueueEntry" extends "Job Queue Entry"
{
    fields
    {
        field(50350; "GXL No Email on Error Log"; Boolean)
        {
            Caption = 'No Email on Error Log';
            DataClassification = CustomerContent;
        }
        field(50351; "GXL Error Notif. Email Address"; Text[250])
        {
            Caption = 'Error Notification Email Address';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                MailManagement.ValidateEmailAddressField("GXL Error Notif. Email Address");
            end;
        }
    }
}