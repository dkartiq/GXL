// Import International PO Shi
// Parameter 'SHIPSTATUS'
codeunit 50388 "EDI Job Queue Mngt SHIPSTATUS"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ImportIPOShipAdvice();
        ValidateIPOShipAdvice();
        ProcessIPOShipAdvice();
    end;

    var

    local procedure ImportIPOShipAdvice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(7, 1);
        EDIProcessMgt.RUN();
    end;

    local procedure ValidateIPOShipAdvice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(7, 2);
        EDIProcessMgt.RUN();
    end;

    local procedure ProcessIPOShipAdvice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(7, 3);
        EDIProcessMgt.RUN();
    end;


}

