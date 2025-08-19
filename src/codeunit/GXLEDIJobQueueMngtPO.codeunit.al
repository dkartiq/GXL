codeunit 50393 "GXL GXLEDI Job Queue Mngt PO"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        ValidateExportPurchaseOrder();
    end;


    local procedure ValidateExportPurchaseOrder()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(0, 0);
        EDIProcessMgt.RUN();
    end;
}

