codeunit 50274 "GXL PDA-Process Trans Shpts"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        GlobalJobQueueEntry := Rec;
        GlobalNoOfErrors := 0;
        CopyTransShipmentToProcessBuffer();
        PostTransferShipments();

        //PS-2523 VET Clinic transfer order +
        PostVETTransferReceipts();
        CreateVETTransferSalesOrders();
        PostVETTransferSalesOrders();
        //PS-2523 VET Clinic transfer order -

        if GlobalNoOfErrors <> 0 then
            SendError(GlobalNoOfErrors);
    end;

    var
        GlobalJobQueueEntry: Record "Job Queue Entry";
        GlobalNoOfErrors: Integer;
        NextProcessStatus: Option " ","Shipment Posting Error","Shipment Posted","Receipt Posting Error","Receipt Posted","Sales Creation Error","Sales Created","Sales Posting Error","Sales Posted","Closed";

    procedure CopyTransShipmentToProcessBuffer()
    var
        PDATransShptLine: Record "GXL PDA-Trans Shipment Line";
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
    begin
        PDATransShptLine.Reset();
        if PDATransShptLine.FindSet() then
            repeat
                PDATransShptProcessBuff.Init();
                PDATransShptProcessBuff.TransferFields(PDATransShptLine);
                PDATransShptProcessBuff."Entry No." := 0;
                PDATransShptProcessBuff.Insert(true);
            until PDATransShptLine.Next() = 0;
        PDATransShptLine.DeleteAll();
        Commit();
    end;

    procedure PostTransferShipments()
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        TempDocumentSearchResult: Record "Document Search Result" temporary;
    begin
        Commit();
        PDATransShptProcessBuff.Reset();
        PDATransShptProcessBuff.SetCurrentKey(Processed, Errored, "No.", "Line No.");
        PDATransShptProcessBuff.SetRange(Processed, false);
        PDATransShptProcessBuff.SetRange(Errored, false);

        GetUniqueShipmentNos(PDATransShptProcessBuff, TempDocumentSearchResult);

        TempDocumentSearchResult.Reset();
        if TempDocumentSearchResult.FindSet() then
            repeat
                PostPerShipment(TempDocumentSearchResult."Doc. No.");
                Commit();
            until TempDocumentSearchResult.Next() = 0;
        TempDocumentSearchResult.DeleteAll();

    end;

    local procedure PostPerShipment(OrderNo: Code[20])
    var
        TransHead: Record "Transfer Header";
        TransShptHead: Record "Transfer Shipment Header";
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        PDAProcessTransShpt: Codeunit "GXL PDA-Post Trans Shipment";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        ProcessWasSuccess: Boolean;
        ShipmentNo: Code[20];
        VETTransfer: Boolean;
    begin
        //Transfer has been posted manually, not via batch job process
        if not TransHead.Get(OrderNo) then begin
            //PS-2523 VET Clinic transfer order +
            //SetShptBufferProcessed(OrderNo);
            TransShptHead.SetCurrentKey("Transfer Order No.");
            TransShptHead.SetRange("Transfer Order No.", OrderNo);
            if TransShptHead.FindLast() then begin
                ShipmentNo := TransShptHead."No.";
                VETTransfer := TransShptHead."GXL VET Store Code" <> '';
            end;
            if VETTransfer then
                NextProcessStatus := NextProcessStatus::"Shipment Posted"
            else
                NextProcessStatus := NextProcessStatus::Closed;
            SetShptBufferProcessed(OrderNo, NextProcessStatus, ShipmentNo);
            //PS-2523 VET Clinic transfer order -
            exit;
        end;

        //PS-2523 VET Clinic transfer order +
        VETTransfer := TransHead."GXL VET Store Code" <> '';
        //PS-2523 VET Clinic transfer order -

        PDATransShptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransShptProcessBuff.SetRange("No.", OrderNo);
        PDATransShptProcessBuff.FindSet();

        Clear(PDAProcessTransShpt);
        ClearLastError();
        ProcessWasSuccess := PDAProcessTransShpt.Run(PDATransShptProcessBuff);
        if not ProcessWasSuccess then begin
            if not MiscUtilities.IsLockingError(GetLastErrorCode()) then begin
                GlobalNoOfErrors += 1;
                NextProcessStatus := NextProcessStatus::"Shipment Posting Error";
                SetShptBufferError(OrderNo, NextProcessStatus, GetLastErrorText())
            end;
        end else begin
            //PS-2523 VET Clinic transfer order +
            //SetShptBufferProcessed(OrderNo);
            PDAProcessTransShpt.GetShipmentNo(ShipmentNo);
            if VETTransfer then
                NextProcessStatus := NextProcessStatus::"Shipment Posted"
            else
                NextProcessStatus := NextProcessStatus::Closed;
            SetShptBufferProcessed(OrderNo, NextProcessStatus, ShipmentNo);
            //PS-2523 VET Clinic transfer order -
        end;
    end;

    local procedure GetUniqueShipmentNos(var PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff"; var TempDocumentSearchResult: Record "Document Search Result" temporary)
    begin
        if PDATransShptProcessBuff.FindSet() then
            repeat
                if not TempDocumentSearchResult.Get(0, PDATransShptProcessBuff."No.", 0) then begin
                    TempDocumentSearchResult.Init();
                    TempDocumentSearchResult."Doc. Type" := 0;
                    TempDocumentSearchResult."Doc. No." := PDATransShptProcessBuff."No.";
                    TempDocumentSearchResult."Table ID" := 0;
                    TempDocumentSearchResult.Insert();
                end;
                PDATransShptProcessBuff.SetRange("No.", PDATransShptProcessBuff."No.");
                PDATransShptProcessBuff.FindLast();
                PDATransShptProcessBuff.SetRange("No.");
            until PDATransShptProcessBuff.Next() = 0;
    end;

    local procedure SetShptBufferError(OrderNo: Code[20];
        NewNextStatus: Option " ","Shipment Posting Error","Shipment Posted","Receipt Posting Error","Receipt Posted","Sales Creation Error","Sales Created","Sales Posting Error","Sales Posted","Closed";
        ErrText: Text)
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
    begin
        PDATransShptProcessBuff.Reset();
        PDATransShptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransShptProcessBuff.SetRange("No.", OrderNo);
        if PDATransShptProcessBuff.FindSet() then
            repeat
                //PS-2523 VET Clinic transfer order +
                PDATransShptProcessBuff."Process Status" := NewNextStatus;
                //PS-2523 VET Clinic transfer order -
                PDATransShptProcessBuff.Errored := true;
                PDATransShptProcessBuff."Error Message" := CopyStr(ErrText, 1, MaxStrLen(PDATransShptProcessBuff."Error Message"));
                PDATransShptProcessBuff.Modify();
            until PDATransShptProcessBuff.Next() = 0;
    end;

    local procedure SetShptBufferProcessed(OrderNo: Code[20];
        NewNextStatus: Option " ","Shipment Posting Error","Shipment Posted","Receipt Posting Error","Receipt Posted","Sales Creation Error","Sales Created","Sales Posting Error","Sales Posted","Closed";
        PostedDocNo: Code[20])
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
    begin
        PDATransShptProcessBuff.Reset();
        PDATransShptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransShptProcessBuff.SetRange("No.", OrderNo);
        if PDATransShptProcessBuff.FindSet() then
            repeat
                //PS-2523 VET Clinic transfer order +
                PDATransShptProcessBuff."Process Status" := NewNextStatus;
                case PDATransShptProcessBuff."Process Status" of
                    PDATransShptProcessBuff."Process Status"::"Shipment Posted":
                        PDATransShptProcessBuff."Transfer Shipment No." := PostedDocNo;
                    PDATransShptProcessBuff."Process Status"::"Receipt Posted":
                        PDATransShptProcessBuff."Transfer Receipt No." := PostedDocNo;
                    PDATransShptProcessBuff."Process Status"::"Sales Created":
                        PDATransShptProcessBuff."Sales Order No." := PostedDocNo;
                    PDATransShptProcessBuff."Process Status"::"Sales Posted":
                        PDATransShptProcessBuff."Posted Sales Invoice No." := PostedDocNo;
                    PDATransShptProcessBuff."Process Status"::Closed:
                        PDATransShptProcessBuff."Transfer Shipment No." := PostedDocNo;
                end;
                //PS-2523 VET Clinic transfer order -
                PDATransShptProcessBuff.Processed := true;
                PDATransShptProcessBuff."Processing Date Time" := CurrentDateTime();
                PDATransShptProcessBuff.Errored := false;
                PDATransShptProcessBuff."Error Message" := '';
                PDATransShptProcessBuff.Modify();
            until PDATransShptProcessBuff.Next() = 0;
    end;

    local procedure ResetShptBufferError(OrderNo: Code[20])
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
    begin
        PDATransShptProcessBuff.Reset();
        PDATransShptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransShptProcessBuff.SetRange("No.", OrderNo);
        PDATransShptProcessBuff.SetRange(Errored, true); //PS-2523 VET Clinic transfer order +
        if PDATransShptProcessBuff.FindSet() then
            repeat
                //PS-2523 VET Clinic transfer order +                
                case PDATransShptProcessBuff."Process Status" of
                    PDATransShptProcessBuff."Process Status"::"Shipment Posting Error":
                        PDATransShptProcessBuff."Process Status" := PDATransShptProcessBuff."Process Status"::" ";
                    PDATransShptProcessBuff."Process Status"::"Receipt Posting Error":
                        PDATransShptProcessBuff."Process Status" := PDATransShptProcessBuff."Process Status"::"Shipment Posted";
                    PDATransShptProcessBuff."Process Status"::"Sales Creation Error":
                        PDATransShptProcessBuff."Process Status" := PDATransShptProcessBuff."Process Status"::"Receipt Posted";
                    PDATransShptProcessBuff."Process Status"::"Sales Posting Error":
                        PDATransShptProcessBuff."Process Status" := PDATransShptProcessBuff."Process Status"::"Sales Created";
                end;
                //PS-2523 VET Clinic transfer order -
                PDATransShptProcessBuff.Errored := false;
                PDATransShptProcessBuff."Error Message" := '';
                PDATransShptProcessBuff.Modify();
            until PDATransShptProcessBuff.Next() = 0;
    end;

    procedure ResetError(var _PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff")
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        PDATransShptProcessBuff2: Record "GXL PDA-TransShpt Process Buff";
        TempDocumentSearchResult: Record "Document Search Result" temporary;
    begin
        PDATransShptProcessBuff.Copy(_PDATransShptProcessBuff);
        PDATransShptProcessBuff.SetCurrentKey(Processed, Errored, "No.", "Line No.");
        //PDATransShptProcessBuff.SetRange(Processed, false); //PS-2523 VET Clinic transfer order +
        PDATransShptProcessBuff.SetRange(Errored, true);

        GetUniqueShipmentNos(PDATransShptProcessBuff, TempDocumentSearchResult);

        TempDocumentSearchResult.Reset();
        if TempDocumentSearchResult.FindSet() then
            repeat
                //PS-2523 VET Clinic transfer order +
                // PDATransShptProcessBuff2.SetCurrentKey("No.", "Line No.");
                // PDATransShptProcessBuff2.SetRange("No.", TempDocumentSearchResult."Doc. No.");
                // PDATransShptProcessBuff2.SetRange(Processed, true); 
                // if PDATransShptProcessBuff2.IsEmpty() then
                //PS-2523 VET Clinic transfer order -
                ResetShptBufferError(TempDocumentSearchResult."Doc. No.");
            until TempDocumentSearchResult.Next() = 0;
    end;

    local procedure SendError(NoOfErrors: Integer)
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        JobQueueEntrySendEnail: Codeunit "GXL Job Queue Entry-Send Email";
        ErrMsg: Text;
    begin
        if not IsNullGuid(GlobalJobQueueEntry.ID) then
            if GlobalJobQueueEntry."GXL Error Notif. Email Address" <> '' then begin
                ErrMsg := StrSubstNo('There are %1 transfer shipments could not be posted. Please check "Error Message" on the %2 for details',
                    NoOfErrors, PDATransShptProcessBuff.TableCaption());
                //GlobalJobQueueEntry.SetErrorMessage(ErrMsg);
                GlobalJobQueueEntry.SetError(ErrMsg);
                JobQueueEntrySendEnail.SetOptions(1, '', 0); //Error
                JobQueueEntrySendEnail.SendEmail(GlobalJobQueueEntry);
            end;
    end;

    //PS-2523 VET Clinic transfer order +
    procedure PostVETTransferReceipts()
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        TempDocumentSearchResult: Record "Document Search Result" temporary;
    begin
        Commit();
        PDATransShptProcessBuff.Reset();
        PDATransShptProcessBuff.SetCurrentKey("Process Status", "No.", "Line No.");
        PDATransShptProcessBuff.SetRange("Process Status", PDATransShptProcessBuff."Process Status"::"Shipment Posted");

        GetUniqueShipmentNos(PDATransShptProcessBuff, TempDocumentSearchResult);

        TempDocumentSearchResult.Reset();
        if TempDocumentSearchResult.FindSet() then
            repeat
                PostPerReceipt(TempDocumentSearchResult."Doc. No.");
                Commit();
            until TempDocumentSearchResult.Next() = 0;
        TempDocumentSearchResult.DeleteAll();

    end;

    local procedure PostPerReceipt(OrderNo: Code[20])
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        VETTransOrderPostRcpt: Codeunit "GXL VET TransferOrder-PostRcpt";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        ProcessWasSuccess: Boolean;
        ReceiptNo: Code[20];
    begin
        PDATransShptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransShptProcessBuff.SetRange("No.", OrderNo);
        PDATransShptProcessBuff.FindSet();

        Clear(VETTransOrderPostRcpt);
        ClearLastError();
        ProcessWasSuccess := VETTransOrderPostRcpt.Run(PDATransShptProcessBuff); //a COMMIT at the end of this codeunit
        if not ProcessWasSuccess then begin
            if not MiscUtilities.IsLockingError(GetLastErrorCode()) then begin
                GlobalNoOfErrors += 1;
                NextProcessStatus := NextProcessStatus::"Receipt Posting Error";
                SetShptBufferError(OrderNo, NextProcessStatus, GetLastErrorText())
            end;
        end else begin
            VETTransOrderPostRcpt.GetReceiptNo(ReceiptNo);
            NextProcessStatus := NextProcessStatus::"Receipt Posted";
            SetShptBufferProcessed(OrderNo, NextProcessStatus, ReceiptNo);
        end;
    end;

    procedure CreateVETTransferSalesOrders()
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        TempDocumentSearchResult: Record "Document Search Result" temporary;
    begin
        Commit();
        PDATransShptProcessBuff.Reset();
        PDATransShptProcessBuff.SetCurrentKey("Process Status", "No.", "Line No.");
        PDATransShptProcessBuff.SetRange("Process Status", PDATransShptProcessBuff."Process Status"::"Receipt Posted");

        GetUniqueShipmentNos(PDATransShptProcessBuff, TempDocumentSearchResult);

        TempDocumentSearchResult.Reset();
        if TempDocumentSearchResult.FindSet() then
            repeat
                CreateVETSalesPerTransfer(TempDocumentSearchResult."Doc. No.");
                Commit();
            until TempDocumentSearchResult.Next() = 0;
        TempDocumentSearchResult.DeleteAll();

    end;

    local procedure CreateVETSalesPerTransfer(OrderNo: Code[20])
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        VETTransOrderSales: Codeunit "GXL VET Transfer Order-Sales";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        ProcessWasSuccess: Boolean;
        SalesOrderNo: Code[20];
    begin
        PDATransShptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransShptProcessBuff.SetRange("No.", OrderNo);
        PDATransShptProcessBuff.FindSet();

        Clear(VETTransOrderSales);
        ClearLastError();
        VETTransOrderSales.SetProcess(1); //Create order
        ProcessWasSuccess := VETTransOrderSales.Run(PDATransShptProcessBuff); //a COMMIT at the end of this codeunit
        if not ProcessWasSuccess then begin
            if not MiscUtilities.IsLockingError(GetLastErrorCode()) then begin
                GlobalNoOfErrors += 1;
                NextProcessStatus := NextProcessStatus::"Sales Creation Error";
                SetShptBufferError(OrderNo, NextProcessStatus, GetLastErrorText())
            end;
        end else begin
            VETTransOrderSales.GetSalesOrderNo(SalesOrderNo);
            NextProcessStatus := NextProcessStatus::"Sales Created";
            SetShptBufferProcessed(OrderNo, NextProcessStatus, SalesOrderNo);
        end;
    end;

    procedure PostVETTransferSalesOrders()
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        TempDocumentSearchResult: Record "Document Search Result" temporary;
    begin
        Commit();
        PDATransShptProcessBuff.Reset();
        PDATransShptProcessBuff.SetCurrentKey("Process Status", "No.", "Line No.");
        PDATransShptProcessBuff.SetRange("Process Status", PDATransShptProcessBuff."Process Status"::"Sales Created");

        GetUniqueShipmentNos(PDATransShptProcessBuff, TempDocumentSearchResult);

        TempDocumentSearchResult.Reset();
        if TempDocumentSearchResult.FindSet() then
            repeat
                PostVETSalesPerTransfer(TempDocumentSearchResult."Doc. No.");
                Commit();
            until TempDocumentSearchResult.Next() = 0;
        TempDocumentSearchResult.DeleteAll();

    end;

    local procedure PostVETSalesPerTransfer(OrderNo: Code[20])
    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        VETTransOrderSales: Codeunit "GXL VET Transfer Order-Sales";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        ProcessWasSuccess: Boolean;
        InvoiceNo: Code[20];
    begin
        PDATransShptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransShptProcessBuff.SetRange("No.", OrderNo);
        PDATransShptProcessBuff.FindSet();

        Clear(VETTransOrderSales);
        ClearLastError();
        VETTransOrderSales.SetProcess(2); //post sales order
        ProcessWasSuccess := VETTransOrderSales.Run(PDATransShptProcessBuff); //a COMMIT at the end of this codeunit
        if not ProcessWasSuccess then begin
            if not MiscUtilities.IsLockingError(GetLastErrorCode()) then begin
                GlobalNoOfErrors += 1;
                NextProcessStatus := NextProcessStatus::"Sales Posting Error";
                SetShptBufferError(OrderNo, NextProcessStatus, GetLastErrorText())
            end;
        end else begin
            VETTransOrderSales.GetPostedInvoiceNo(InvoiceNo);
            NextProcessStatus := NextProcessStatus::"Sales Posted";
            SetShptBufferProcessed(OrderNo, NextProcessStatus, InvoiceNo);
        end;
    end;
    //PS-2523 VET Clinic transfer order -

}