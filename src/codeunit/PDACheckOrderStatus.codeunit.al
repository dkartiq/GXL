codeunit 50263 "GXL PDA-Check Order Status"
{
    //TODO: Order Status - PDA check order status
    trigger OnRun()
    var
        SCPurchaseOrderStatusMgt: Codeunit "GXL SC-Purch. Order Status Mgt";
        DocumentNo: Code[20];
        OrderClosed: Boolean;
    begin

        //If Order Status is 'Closed', then automatically set "Processed" = True on the buffer entries.
        //If Order Status is 'Cancelled' then automatically run the Report "Reset order status"
        //If all buffer lines for the order have QtytoRcv= zero then automatically Cancel the purchase order and set "Processed" = True on all buffer entries for the order
        OrderClosed := false;

        PassStatusCheck := false;
        if DocType = DocType::PO then begin
            DocumentNo := PurchaseHeader."No.";
            case PurchaseHeader."GXL Order Status" of
                PurchaseHeader."GXL Order Status"::Closed:
                    OrderClosed := true;
                PurchaseHeader."GXL Order Status"::New,
                PurchaseHeader."GXL Order Status"::Created,
                PurchaseHeader."GXL Order Status"::Placed,
                PurchaseHeader."GXL Order Status"::Confirmed:
                    begin
                        if not NilReceivePDA(DocumentNo) then
                            PassStatusCheck := true
                        else begin
                            SCPurchaseOrderStatusMgt.Cancel(PurchaseHeader, 0);
                            OrderClosed := true;
                        end;
                    end;
                PurchaseHeader."GXL Order Status"::Cancelled:
                    begin
                        if ResetPurchaseOrderStatus() then
                            PassStatusCheck := true
                        else
                            OrderClosed := true;
                    end;
            end;
        end else begin
            DocumentNo := TransferHeader."No.";
            if TransferHeader."GXL Order Status" = TransferHeader."GXL Order Status"::Closed then
                OrderClosed := true
            else
                PassStatusCheck := true;
        end;

        if OrderClosed then begin
            PassStatusCheck := false;
            SetPDAReceiveBufferStatus(DocumentNo);
            Commit();
        end;
    end;

    var
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        DocType: Option PO,"TO";
        PassStatusCheck: Boolean;

    procedure SetOptions(InputDocType: Option PO,"TO"; InputPurchaseHeader: Record "Purchase Header"; InputTransferHeader: Record "Transfer Header")
    begin
        PurchaseHeader := InputPurchaseHeader;
        TransferHeader := InputTransferHeader;
        DocType := InputDocType;
    end;

    procedure GetResult(): Boolean
    begin
        exit(PassStatusCheck);
    end;

    local procedure NilReceivePDA(DocumentNo: Code[20]): Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        SCPurchaseOrderStatusMgt: Codeunit "GXL SC-Purch. Order Status Mgt";
    begin
        PDAPLReceiveBuffer.SetCurrentKey("Document No.", "Line No.");
        PDAPLReceiveBuffer.SetRange("Document No.", DocumentNo);
        PDAPLReceiveBuffer.SetRange(Processed, false);
        if PDAPLReceiveBuffer.FindFirst() then
            if PDAPLReceiveBuffer."Receipt Type" = PDAPLReceiveBuffer."Receipt Type"::Full then
                exit(SCPurchaseOrderStatusMgt.NilReceivePurchaseHeader(PurchaseHeader))
            else begin
                PDAPLReceiveBuffer.SetFilter(QtyToReceive, '>0', 0);
                exit(PDAPLReceiveBuffer.IsEmpty());
            end;
        exit(false);
    end;

    local procedure ResetPurchaseOrderStatus(): Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        ResetOrderStatus: Report "GXL Reset Purch. Order Status";
        SCPurchaseOrderStatusMgt: Codeunit "GXL SC-Purch. Order Status Mgt";
    begin

        PDAPLReceiveBuffer.SetCurrentKey("Document No.", "Line No.");
        PDAPLReceiveBuffer.SetRange("Document No.", PurchaseHeader."No.");
        PDAPLReceiveBuffer.SetRange(Processed, false);
        PDAPLReceiveBuffer.SetRange("Receipt Type", PDAPLReceiveBuffer."Receipt Type"::Lines);
        if PDAPLReceiveBuffer.FindFirst() then begin
            PDAPLReceiveBuffer.SetFilter(QtyToReceive, '>%1', 0);
            if PDAPLReceiveBuffer.IsEmpty() then
                exit(false);
        END;

        //PurchaseHeader."GXL Reset Order Status Required" := true; //TODO: order status, is it required?
        //PurchaseHeader.Modify();
        Commit();

        PurchaseHeader.SetRecFilter();
        Clear(ResetOrderStatus);
        ResetOrderStatus.SetTableView(PurchaseHeader);
        ResetOrderStatus.UseRequestPage(false);
        ResetOrderStatus.RunModal();

        if NilReceivePDA(PurchaseHeader."No.") then begin
            SCPurchaseOrderStatusMgt.Cancel(PurchaseHeader, 0);
            exit(false);
        end else
            exit(true);
    end;

    local procedure SetPDAReceiveBufferStatus(DocumentNo: Code[20])
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        PDAPLReceiveBuffer.Reset();
        PDAPLReceiveBuffer.SetCurrentKey("Document No.", "Line No.");
        PDAPLReceiveBuffer.SetRange("Document No.", DocumentNo);
        if PDAPLReceiveBuffer.FindSet() then
            repeat
                PDAPLReceiveBuffer.Errored := false;
                PDAPLReceiveBuffer."Error Code" := '';
                PDAPLReceiveBuffer."Error Message" := '';
                PDAPLReceiveBuffer.Processed := true;
                PDAPLReceiveBuffer."Processing Date Time" := CurrentDateTime();
                PDAPLReceiveBuffer.Status := PDAPLReceiveBuffer.Status::Received;
                PDAPLReceiveBuffer.Modify();
            until PDAPLReceiveBuffer.Next() = 0;

    end;
}