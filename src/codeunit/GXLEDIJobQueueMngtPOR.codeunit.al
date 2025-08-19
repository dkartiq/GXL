codeunit 50390 "GXL GXLEDI Job Queue Mngt POR"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ImportPurchaseOrderResponse();
        ValidatePurchaseOrderResponse();
        ProcessPurchaseOrderResponse();
    end;



    local procedure ImportPurchaseOrderResponse()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(2, 1);
        EDIProcessMgt.RUN();
    end;

    local procedure ValidatePurchaseOrderResponse()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(2, 2);
        EDIProcessMgt.RUN();
    end;

    local procedure ProcessPurchaseOrderResponse()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(2, 3);
        EDIProcessMgt.RUN();
    end;
}

