codeunit 50289 "GXL Non-EDI Job Queue Mgt."
{
    trigger OnRun()
    begin

        ClearOldBufferEntries();
        MoveScannedQuantitiesToProcessingBuffer();
        ValidateScannedQuantities();
        ReceiveAndInvoiceScannedQuantities();
        CreateClaimDocument();
        ApplyClaimDocument();
        PostPurchaseReturnShipment();
        PostPurchaseCreditMemo();
        ClearPDAReceivingBufferErrors();
    end;

    var
        ProcessWhat: Enum "GXL Non-EDI Process Step";

    local procedure ClearOldBufferEntries()
    var
        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
    begin
        ProcessWhat := ProcessWhat::"Clear Buffer";
        NonEDIProcessMgt.SetOptions(ProcessWhat);
        NonEDIProcessMgt.Run();
    end;

    local procedure MoveScannedQuantitiesToProcessingBuffer()
    var
        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
    begin
        ProcessWhat := ProcessWhat::"Move To Processing Buffer";
        NonEDIProcessMgt.SetOptions(ProcessWhat);
        NonEDIProcessMgt.Run();
    end;

    local procedure ValidateScannedQuantities()
    var
        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
    begin
        ProcessWhat := ProcessWhat::Validate;
        NonEDIProcessMgt.SetOptions(ProcessWhat);
        NonEDIProcessMgt.Run();
    end;

    local procedure ReceiveAndInvoiceScannedQuantities()
    var
        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
    begin
        ProcessWhat := ProcessWhat::Receive;
        NonEDIProcessMgt.SetOptions(ProcessWhat);
        NonEDIProcessMgt.Run();
    end;

    local procedure CreateClaimDocument()
    var
        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
    begin
        ProcessWhat := ProcessWhat::"Create Return Order";
        NonEDIProcessMgt.SetOptions(ProcessWhat);
        NonEDIProcessMgt.Run();
    end;

    local procedure ApplyClaimDocument()
    var
        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
    begin
        ProcessWhat := ProcessWhat::"Apply Return Order";
        NonEDIProcessMgt.SetOptions(ProcessWhat);
        NonEDIProcessMgt.Run();
    end;

    local procedure PostPurchaseReturnShipment()
    var
        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
    begin
        ProcessWhat := ProcessWhat::"Post Return Shipment";
        NonEDIProcessMgt.SetOptions(ProcessWhat);
        NonEDIProcessMgt.Run();
    end;

    local procedure PostPurchaseCreditMemo()
    var
        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
    begin
        ProcessWhat := ProcessWhat::"Post Return Credit";
        NonEDIProcessMgt.SetOptions(ProcessWhat);
        NonEDIProcessMgt.Run();
    end;

    local procedure ClearPDAReceivingBufferErrors()
    var
        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
    begin
        ProcessWhat := ProcessWhat::"Clear PDA Receiving Buffer Errors";
        NonEDIProcessMgt.SetOptions(ProcessWhat);
        NonEDIProcessMgt.Run();
    end;
}