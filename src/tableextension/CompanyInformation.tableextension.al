// 001 07.07.2025 BY HP2-Sprint2-Changes
tableextension 50617 "GXL Company Info" extends "Company Information"
{
    fields
    {
        field(50002; "Short Name"; Text[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50003; "Accounts Payable E-Mail"; Text[80])
        {
            DataClassification = ToBeClassified;
        }
    }
}