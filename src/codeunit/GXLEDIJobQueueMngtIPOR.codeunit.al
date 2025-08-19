codeunit 50389 "GXL GXLEDI Job Queue Mngt IPOR"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ImportIPOResponse();
        ValidateIPOResponse();
        ProcessIPOResponse();
    end;

    local procedure ImportIPOResponse()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(8, 1);
        EDIProcessMgt.RUN();
    end;

    local procedure ValidateIPOResponse()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(8, 2);
        EDIProcessMgt.RUN();
    end;

    local procedure ProcessIPOResponse()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(8, 3);
        EDIProcessMgt.RUN();
    end;
}

