codeunit 50281 "GXL Non-EDI Process Scan Qtys"
{
    trigger OnRun()
    begin

        IntegrationSetup.Get();

        case ProcessWhat of
            ProcessWhat::PurchaseLine: //Use QtyToReceive
                ValidatePurchaseLine(0);

            ProcessWhat::TransferLine:
                ValidateTransferLine();

            ProcessWhat::CopyBuffer:
                CopyPDABuffer();

            ProcessWhat::PurchaseLineUseInvoiceQty:
                ValidatePurchaseLine(1);
        end;

    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        ProcessWhat: Option PurchaseLine,TransferLine,CopyBuffer,PurchaseLineUseInvoiceQty;

    procedure ValidatePDALine(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
                        InputValidationType: Option PurchaseLine,TransferLine,CopyBuffer,PurchaseLineUseInvoiceQty): Boolean
    var
        NonEDIProcessScannedQtys: Codeunit "GXL Non-EDI Process Scan Qtys";
    begin
        ClearLastError();
        Clear(NonEDIProcessScannedQtys);
        NonEDIProcessScannedQtys.SetValidationType(PDAPLReceiveBuffer, InputValidationType);
        exit(NonEDIProcessScannedQtys.Run());
    end;

    ///<Summary>
    //Move the PDA-Purchase Lines to PDA-PL Receive Buffer
    ///</Summary>
    procedure CopyPDABuffer()
    var
        PDAPurchaseLine: Record "GXL PDA-Purchase Lines";
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        if PDAPurchaseLine.FindSet() then begin
            repeat
                if not IsDuplicate(PDAPurchaseLine."Document No.", PDAPurchaseLine."Line No.") then begin
                    PDAPLReceiveBuffer.Init();
                    PDAPLReceiveBuffer.TransferFields(PDAPurchaseLine);
                    PDAPLReceiveBuffer."Receipt Type" := PDAPLReceiveBuffer."Receipt Type"::Lines;
                    PDAPLReceiveBuffer."Received from PDA" := PDAPLReceiveBuffer."Entry Date Time";
                    if PDAPurchaseLine.QtyToReceive < 0 then
                        PDAPLReceiveBuffer.QtyToReceive := 0;
                    if PDAPurchaseLine.InvoiceQuantity < 0 then
                        PDAPLReceiveBuffer.InvoiceQuantity := 0;
                    PDAPLReceiveBuffer."Entry No." := 0;
                    PDAPLReceiveBuffer.Insert(true);
                end;
            until PDAPurchaseLine.Next() = 0;

            PDAPurchaseLine.DeleteAll();

            Commit();
        end;
    end;

    ///<Summary>
    //This function will validate Qty. to Receive basing on the source of call
    //If the source of call is UseInvoiceQty, then validate Qty. to Receive as the InvoiceQuantity
    //Otherwise validate Qty. to Receive as QtyToReceive
    //
    //In the "GXL PDA-PL Receive Buffer"
    //  QtyToReceive = Qty actually received into stock
    //  InvoiceQuantity = Qty arrived to store, may contain defect stocks
    //So in therory, the InvoiceQuantity may be greater than QtyToReceive, the difference is the Claim Qty
    ///</Summary>
    local procedure ValidatePurchaseLine(QtyToReceiveSource: Option UseQtyToReceive,UseInvoiceQty)
    var
        PurchaseLine: Record "Purchase Line";
        Quantity: Decimal;
        DoClaim: Boolean;
        OldUnitCost: Decimal;
        OldDiscPct: Decimal;
    begin
        case QtyToReceiveSource of
            QtyToReceiveSource::UseQtyToReceive:
                Quantity := PDAPLReceiveBuffer2.QtyToReceive;
            QtyToReceiveSource::UseInvoiceQty:
                Quantity := PDAPLReceiveBuffer2.InvoiceQuantity;
        end;

        PurchaseLine.SetRange(PurchaseLine."Document Type", PurchaseLine."Document Type"::Order);
        PurchaseLine.SetRange(PurchaseLine."Document No.", PDAPLReceiveBuffer2."Document No.");
        PurchaseLine.SetRange(PurchaseLine."Line No.", PDAPLReceiveBuffer2."Line No.");
        PurchaseLine.SetRange(PurchaseLine.Type, PurchaseLine.Type::Item);
        if PurchaseLine.FindFirst() then begin
            if QtyToReceiveSource = QtyToReceiveSource::UseInvoiceQty then
                DoClaim := PDAPLReceiveBuffer2.QtyToReceive <> PDAPLReceiveBuffer2.InvoiceQuantity
            else
                DoClaim := PurchaseLine."Qty. to Receive" <> Quantity;
            if DoClaim then begin
                if PDAPLReceiveBuffer2."Reason Code" = '' then
                    PDAPLReceiveBuffer2."Reason Code" := IntegrationSetup."ASN Variance Reason Code";
                if QtyToReceiveSource = QtyToReceiveSource::UseInvoiceQty then begin
                    PDAPLReceiveBuffer2."Claim Quantity" := ABS(PDAPLReceiveBuffer2.QtyToReceive - Quantity);
                    PDAPLReceiveBuffer2.Modify();
                end;
            end;

            if QtyToReceiveSource = QtyToReceiveSource::UseInvoiceQty then
                if Quantity > PurchaseLine.Quantity then begin
                    PurchaseLine.SetPDAOverReceiving(IntegrationSetup."PDA Over Receiving Reason Code");
                    OldUnitCost := PurchaseLine."Direct Unit Cost";
                    OldDiscPct := PurchaseLine."Line Discount %";
                    PurchaseLine.Validate(Quantity, Quantity);
                    if PurchaseLine."Direct Unit Cost" <> OldUnitCost then
                        PurchaseLine.Validate("Direct Unit Cost", OldUnitCost);
                    if PurchaseLine."Line Discount %" <> OldDiscPct then
                        PurchaseLine.Validate("Line Discount %", OldDiscPct);
                end;

            PurchaseLine.Validate("Qty. to Receive", Quantity);
            PurchaseLine."GXL Rec. Variance" := Quantity - PDAPLReceiveBuffer2.QtyOrdered;
            PurchaseLine."GXL Qty. Variance Reason Code" := PDAPLReceiveBuffer2."Reason Code";
            PurchaseLine.Modify(true);
        end;
    end;

    local procedure ValidateTransferLine()
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.SetRange("Document No.", PDAPLReceiveBuffer2."Document No.");
        TransferLine.SetRange("Line No.", PDAPLReceiveBuffer2."Line No.");
        if TransferLine.FindSet(true) then begin

            if (TransferLine."Qty. to Receive" <> PDAPLReceiveBuffer2.QtyToReceive) then begin
                if PDAPLReceiveBuffer2."Reason Code" = '' then
                    PDAPLReceiveBuffer2."Reason Code" := IntegrationSetup."ASN Variance Reason Code";
            end;

            TransferLine.Validate("Qty. to Receive", PDAPLReceiveBuffer2.QtyToReceive);
            TransferLine."GXL Qty Variance" := PDAPLReceiveBuffer2.QtyToReceive - PDAPLReceiveBuffer2.QtyOrdered;
            TransferLine."GXL Qty. Variance Resaon Code" := PDAPLReceiveBuffer2."Reason Code";

            TransferLine.Modify(true);
        end;
    end;

    procedure SetValidationType(var InputPDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; InputValidationType: Option)

    begin
        PDAPLReceiveBuffer2 := InputPDAPLReceiveBuffer;
        ProcessWhat := InputValidationType;
    end;

    local procedure IsDuplicate(DocumentNo: Code[20]; LineNo: Integer): Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        PDAPLReceiveBuffer.SetCurrentKey("Document No.", "Line No.");
        PDAPLReceiveBuffer.SetRange("Document No.", DocumentNo);
        PDAPLReceiveBuffer.SetRange("Line No.", LineNo);
        exit(not PDAPLReceiveBuffer.IsEmpty());
    end;

    procedure SetOptions(InputProcessWhat: Option PurchaseLine,TransferLine,CopyBuffer,PurchaseLineUseInvoiceQty)
    begin
        ProcessWhat := InputProcessWhat;
    end;

}