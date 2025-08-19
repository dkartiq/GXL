// 001 19.06.2024 KDU LCB-298 https://petbarnjira.atlassian.net/browse/LCB-298 - Fix the negative adj creation process.
codeunit 50037 "TO Stock Adjustment"
{
    // >> GX202316 << 
    trigger OnRun()
    var
        WhMessageLines: Record "GXL WH Message Lines";
        IntegrationSetup: Record "GXL Integration Setup";
    begin
        IntegrationSetup.get;
        IF IntegrationSetup."TOR Auto Decrease Enable" then
            WhMessageLines.DecreaseStock();
    end;
}
