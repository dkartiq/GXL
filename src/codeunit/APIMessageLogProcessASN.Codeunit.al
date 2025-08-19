codeunit 50046 "API Message Log Process ASN"
{
    //** BASED on COPY of Codeunit 50391 "GXL GXLEDI Job Queue Mngt ASN" **

    trigger OnRun()
    begin
        //ValidateExportASN();
        //ImportAdvanceShippingNotice();
        ValidateAdvanceShippingNotice();
        ProcessAdvanceShippingNotice();
        CopyScannedAdvanceShippingNotice();
        ReceiveAdvanceShippingNotice();
        CreateReturnOrder();
        ApplyReturnOrder();
        PostReturnShipment();
    end;

    var
        APIMessageLog: Record "API Message Log";

    procedure SetAPILogEntry(InAPILog: Record "API Message Log")
    var
        outStm: OutStream;
    begin
        APIMessageLog.Get(InAPILog."Entry No.");
        APIMessageLog.SetRecFilter();
        APIMessageLog.FindFirst();
    end;

    local procedure ImportAdvanceShippingNotice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 1);
        EDIProcessMgt.SetAPILogEntry(APIMessageLog);
        EDIProcessMgt.RUN();
    end;

    local procedure ValidateAdvanceShippingNotice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 2);
        EDIProcessMgt.SetAPILogEntry(APIMessageLog);
        EDIProcessMgt.RUN();
    end;

    local procedure ProcessAdvanceShippingNotice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 3);
        EDIProcessMgt.SetAPILogEntry(APIMessageLog);
        EDIProcessMgt.RUN();
    end;


    local procedure CopyScannedAdvanceShippingNotice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 4);
        EDIProcessMgt.SetAPILogEntry(APIMessageLog);
        EDIProcessMgt.RUN();
    end;

    [Scope('OnPrem')]
    procedure ReceiveAdvanceShippingNotice()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 5);
        EDIProcessMgt.SetAPILogEntry(APIMessageLog);
        EDIProcessMgt.RUN();
    end;

    [Scope('OnPrem')]
    procedure CreateReturnOrder()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 6);
        EDIProcessMgt.SetAPILogEntry(APIMessageLog);
        EDIProcessMgt.RUN();
    end;

    [Scope('OnPrem')]
    procedure ApplyReturnOrder()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 7);
        EDIProcessMgt.SetAPILogEntry(APIMessageLog);
        EDIProcessMgt.RUN();
    end;

    [Scope('OnPrem')]
    procedure PostReturnShipment()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 8);
        EDIProcessMgt.SetAPILogEntry(APIMessageLog);
        EDIProcessMgt.RUN();
    end;

    local procedure ValidateExportASN()
    var
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        EDIProcessMgt.SetOptions(3, 0);
        EDIProcessMgt.SetAPILogEntry(APIMessageLog);
        EDIProcessMgt.RUN();
    end;
}
