codeunit 50053 "GXL API Job Integration"
{
    Subtype = Normal;
    trigger OnRun()
    var
        APIIntegration: Codeunit "GXL API Integration Handler";
    begin
        APIIntegration.ProcessAPIRecords();
    end;
}