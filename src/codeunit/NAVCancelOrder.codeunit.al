codeunit 50026 "GXL NAV Cancel Order"
{
    /*Change Log
        PS-2270: Sync cancelled orders from NAV13 over
        ERP-397 26-10-21 LP: Exflow and Purchase Order Creation
    */

    TableNo = "GXL NAV Cancelled Order";

    trigger OnRun()
    var
    begin
        ClearAll();
        NAVCancelledOrder := Rec;
        if NAVCancelledOrder."Process Status" = NAVCancelledOrder."Process Status"::Processed then
            Error(AlreadyProcessedMsg, Rec."No.");

        if OrderCanBeProcessed() then
            CancellOrder();
        Rec := NAVCancelledOrder;
    end;

    var
        NAVCancelledOrder: Record "GXL NAV Cancelled Order";
        AlreadyProcessedMsg: Label 'Cancelled Order %1 has already been processed';

    local procedure OrderCanBeProcessed(): Boolean
    var
        NAVConfirmedOrd: Record "GXL NAV Confirmed Order";
    begin
        //ERP-328 +
        // //NAV Confirmed Order has not been synced, do not process it now
        // if not NAVConfirmedOrd.Get(NAVCancelledOrder."Document Type", NAVCancelledOrder."No.") then
        //     exit(false);

        // //NAV Confirmed Order has been synced but not processed or errored, do not process it now
        // if NAVConfirmedOrd."Process Status" <> NAVConfirmedOrd."Process Status"::Created then
        //     exit(false);

        NAVConfirmedOrd.SetRange("Document Type", NAVCancelledOrder."Document Type");
        NAVConfirmedOrd.SetRange("No.", NAVCancelledOrder."No.");
        if NAVConfirmedOrd.IsEmpty() then
            exit(false);

        NAVConfirmedOrd.SetFilter("Process Status", '<>%1', NAVConfirmedOrd."Process Status"::Created);
        if not NAVConfirmedOrd.IsEmpty() then
            exit(false);
        //ERP-328 -

        exit(true);
    end;

    local procedure CancellOrder()
    var
        NAVProcessCancelledOrders: Codeunit "GXL NAV Process Cancelled Ords";
    begin
        case NAVCancelledOrder."Document Type" of
            NAVCancelledOrder."Document Type"::Purchase:
                CancelPurchaseHeader(NAVCancelledOrder);
            NAVCancelledOrder."Document Type"::Transfer:
                CancelTransferHeader(NAVCancelledOrder);
        end;
        NAVProcessCancelledOrders.SetProcessed(NAVCancelledOrder);
        NAVCancelledOrder.Modify();
    end;

    local procedure CancelPurchaseHeader(var _NAVCancelledOrder: Record "GXL NAV Cancelled Order")
    var
        PurchHead: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        PurchRcptHead: Record "Purch. Rcpt. Header";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        ExDocLineApprover: Record "Ex Document Line Approver";
    begin
        if PurchHead.Get(PurchHead."Document Type"::Order, _NAVCancelledOrder."No.") then begin
            PurchLine.SetRange("Document Type", PurchHead."Document Type");
            PurchLine.SetRange("Document No.", PurchHead."No.");
            PurchLine.SetFilter("Quantity Received", '<>0');
            if not PurchLine.IsEmpty then
                Error('Order cannot be cancelled as there at least one item has been received');

            //ERP-397 +
            if PurchHead.Status <> PurchHead.Status::Open then
                ReleasePurchDoc.PerformManualReopen(PurchHead);
            //ERP-397 -

            PurchHead.SetHideValidationDialog(true);
            PurchHead.SuspendStatusCheck(true);
            PurchHead."Posting No." := '';
            PurchHead."Receiving No." := '';
            // >> Upgrade
            ExDocLineApprover.SetCurrentKey("Document No.");
            ExDocLineApprover.SetRange("Document No.", PurchHead."No.");
            ExDocLineApprover.SetRange("Document Type", ExDocLineApprover."Document Type"::Order);
            IF NOT ExDocLineApprover.IsEmpty then
                ExDocLineApprover.DeleteAll();
            // << Upgrade
            PurchHead.Delete(true);
        end else begin
            PurchRcptHead.SetCurrentKey("Order No.");
            PurchRcptHead.SetRange("Order No.", _NAVCancelledOrder."No.");
            if not PurchRcptHead.IsEmpty then
                Error('Order cannot be cancelled as it has already been posted (received)');
        end;

    end;

    local procedure CancelTransferHeader(var _NAVCancelledOrder: Record "GXL NAV Cancelled Order")
    var
        TransHead: Record "Transfer Header";
        TransLine: Record "Transfer Line";
        TransShptLine: Record "Transfer Shipment Line";
    begin
        if TransHead.Get(_NAVCancelledOrder."No.") then begin
            TransLine.SetRange("Document No.", TransHead."No.");
            TransLine.SetFilter("Quantity Shipped", '<>0');
            if not TransLine.IsEmpty then
                Error('Order cannot be cancelled as there at least one item has been shipped');


            TransLine.Reset();
            TransLine.SetRange("Document No.", TransHead."No.");
            TransHead.SetHideValidationDialog(true);
            TransHead.DeleteOneTransferOrder(TransHead, TransLine);
        end else begin
            TransShptLine.SetCurrentKey("Transfer Order No.");
            TransShptLine.SetRange("Transfer Order No.", _NAVCancelledOrder."No.");
            if not TransShptLine.IsEmpty then
                Error('Order cannot be cancelled as it has already been posted (shipped)');
        end;
    end;


}