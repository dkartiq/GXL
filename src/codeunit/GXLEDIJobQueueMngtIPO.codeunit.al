codeunit 50394 "GXL GXLEDI Job Queue Mngt IPO"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ValidateExportIPO();
    end;

    local procedure ValidateExportIPO()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(5, 0);
        EDIProcessMgt.RUN();
    end;
}

