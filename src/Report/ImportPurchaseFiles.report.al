///<Summary>
//This report is to be put in the job queue
//Import purchase files for vendors that are file exchange (i.e. EDI vendor Type is P2P or P2P Contingency)
//The import will create the EDI-Purchase Messages for Confirmation or Invoice
//
//  Currently thare are 2 xmlports will be used by this report
//  50047: create or update PDA-Purchase Lines qty to receive
//  50356: vendor invoice: create entries in EDI-Purchase Messages
//
//After import, it then process the "EDI-Purchase Messages" to post (invoice) the purchase order
///</Summary>

report 50350 "GXL Import Purchase Files"
{
    ProcessingOnly = true;
    Caption = 'Import Purchase Files';
    ApplicationArea = All;
    UsageCategory = Administration;

    dataset
    {
        //Import vendor files that are linked to existing purchase orders for Vendor File Excchange and Vendor File Sent but not Invoiced
        //Mainly for P2P or P2P Contingency EDI Vendor Type
        dataitem("Purchase Header"; "Purchase Header")
        {
            //TODO: Remove filter "GXL Vendor File Sent" = CONST(true) as the PO is created in NAV13 and is not part of this phase
            DataItemTableView = SORTING("Document Type", "Buy-from Vendor No.") ORDER(Ascending) WHERE("Document Type" = CONST(Order), "GXL Vendor File Exchange" = CONST(true), "GXL Invoice Received" = FILTER(false));
            RequestFilterFields = "No.", "Buy-from Vendor No.";

            trigger OnAfterGetRecord()
            var
                JobQueueEntryMgt: Codeunit "GXL Job Queue Entry Management";
                JobQueueEntrySendEmail: Codeunit "GXL Job Queue Entry-Send Email";
                RecRef: RecordRef;
                NewFileName: Text;

            begin
                IF "Purchase Header"."Buy-from Vendor No." = VendorNo THEN
                    CurrReport.SKIP();

                VendorNo := "Purchase Header"."Buy-from Vendor No.";
                IntegrationSetup.GET();
                _recvendor.RESET();
                IF _recvendor.GET("Purchase Header"."Buy-from Vendor No.") THEN BEGIN
                    _recvendor.TESTFIELD("GXL EDI Inbound Directory");
                END;

                CheckDirectory(IntegrationSetup."Vendor Archive Directory");
                CheckDirectory(_recvendor."GXL EDI Inbound Directory");
                _FileDirectory.RESET();
                _FileDirectory.SETRANGE(_FileDirectory.Path, IntegrationSetup."Vendor Archive Directory");
                _FileDirectory.SETRANGE(_FileDirectory."Is a file", TRUE);
                IF _FileDirectory.FINDFIRST() THEN;

                _FileDirectory.RESET();
                _FileDirectory.SETRANGE(_FileDirectory.Path, _recvendor."GXL EDI Inbound Directory");
                _FileDirectory.SETRANGE(_FileDirectory."Is a file", TRUE);
                IF _FileDirectory.FINDSET() THEN
                    REPEAT
                        CLEARLASTERROR();

                        NewFileName := cuWHDATAMGMT.AddSuffixes(_FileDirectory.Name);

                        RecRef.GETTABLE(_recvendor);

                        //Vendor files (EDI)
                        JobQueueEntryMgt.SetOptions(2, RecRef, _FileDirectory.Path, _FileDirectory.Name);

                        IF NOT JobQueueEntryMgt.RUN() THEN BEGIN
                            MoveFile(_recvendor."GXL EDI Inbound Directory" + _FileDirectory.Name, IntegrationSetup."Vendor Error Directory" + NewFileName);

                            IF NOT ISNULLGUID(JobQueueEntry.ID) THEN BEGIN

                                //>>upgrade
                                //JobQueueEntry.SetErrorMessage(GETLASTERRORTEXT());
                                JobQueueEntry.SetError(GETLASTERRORTEXT());
                                //<<upgrade

                                JobQueueEntrySendEmail.SetOptions(1, IntegrationSetup."Vendor Error Directory" + NewFileName, _FileDirectory.Size);

                                IF JobQueueEntrySendEmail.SendEmail(JobQueueEntry) THEN;

                            END;
                            ERROR(GETLASTERRORTEXT());

                        END ELSE BEGIN
                            MoveFile(_recvendor."GXL EDI Inbound Directory" + _FileDirectory.Name, IntegrationSetup."Vendor Archive Directory" + NewFileName);
                        END;

                    UNTIL _FileDirectory.NEXT() = 0;
            end;

            trigger OnPostDataItem()
            var
                JobQueueEntry2: Record "Job Queue Entry";
            begin
                IF JobQueueEntry2.GET(JobQueueEntry.ID) THEN BEGIN
                    JobQueueEntry2."GXL No Email on Error Log" := FALSE;
                    JobQueueEntry2.MODIFY();
                    COMMIT();
                END;
            end;

            trigger OnPreDataItem()
            var
                JobQueueEntry2: Record "Job Queue Entry";
            begin
                VendorNo := '';

                IF JobQueueEntry2.GET(JobQueueEntry.ID) THEN BEGIN
                    JobQueueEntry2."GXL No Email on Error Log" := TRUE;
                    JobQueueEntry2.MODIFY();
                    COMMIT();
                END;
            end;
        }
        //Process EDI-Purchase Messages for Confirmation
        dataitem("EDI-Purchase Messages"; "GXL EDI-Purchase Messages")
        {
            DataItemTableView = SORTING(ImportDoc, DocumentNumber) ORDER(Ascending) WHERE(ImportDoc = CONST("1"), Processed = FILTER(false), "Error Found" = FILTER(false));
            RequestFilterFields = DocumentNumber;

            trigger OnAfterGetRecord()
            var
                //_recLines: Record "Purchase Line";
                //SCPurchaseOrderStatusMgt: Codeunit "SC-Purchase Order Status Mgt";
                L_PurchaseMessages: Record "GXL EDI-Purchase Messages";
                _OrgOrderStatus: Option New,Created,Placed,Confirmed,"Booked to Ship",Shipped,Arrived,Cancelled,Closed;
            begin
                L_PurchaseMessages := "EDI-Purchase Messages";
                //TODO: Order Status- Import purchase file => process EDI Purchase Messages, only Placed and New is accepted
                _recPH.RESET();
                _recPH.SETRANGE("Document Type", _recPH."Document Type"::Order);
                _recPH.SETRANGE("No.", "EDI-Purchase Messages".DocumentNumber);
                _recPH.SETFILTER("GXL Order Status", '%1|%2', _recPH."GXL Order Status"::Placed, _recPH."GXL Order Status"::New);

                IF _recPH.FINDFIRST() THEN BEGIN
                    _OrgOrderStatus := _recPH."GXL Order Status";
                    CLEAR(cuRPD);
                    cuRPD.PerformManualReopen(_recPH);
                    IF _OrgOrderStatus <> _recPH."GXL Order Status" THEN BEGIN
                        _recPH.VALIDATE("GXL Order Status", _OrgOrderStatus);
                        _recPH.MODIFY(TRUE);
                    END;
                    _recPL.RESET();
                    _recPL.SETRANGE(_recPL."Document Type", _recPL."Document Type"::Order);
                    _recPL.SETRANGE(_recPL."Document No.", _recPH."No.");
                    _recPL.SETRANGE(_recPL.Type, _recPL.Type::Item);
                    _recPL.SETRANGE(_recPL."No.", "EDI-Purchase Messages".Items);
                    IF _recPL.FINDFIRST() THEN BEGIN

                        _recPL.VALIDATE(_recPL."GXL Confirmed Quantity", "EDI-Purchase Messages".ConfirmedOrderQtyOM);


                        // IF _recPL."Direct Unit Cost" <> "EDI-Purchase Messages".UnitCostExcl THEN BEGIN
                        //    "EDI-Purchase Messages"."Error Found" := TRUE;
                        //   "EDI-Purchase Messages"."Error Description" := error1;
                        // END;
                        // _recPL.VALIDATE(_recPL."Confirmed Quantity",0);
                        IF _recPL.MODIFY(TRUE) THEN BEGIN
                            L_PurchaseMessages.Processed := TRUE;
                            L_PurchaseMessages.MODIFY();
                            _TempPh.RESET();
                            _TempPh.SETRANGE(_TempPh."Document Type", _recPH."Document Type");
                            _TempPh.SETRANGE(_TempPh."No.", _recPH."No.");
                            IF NOT _TempPh.FINDFIRST() THEN BEGIN
                                _TempPh.INIT();
                                _TempPh.TRANSFERFIELDS(_recPH);
                                _TempPh.INSERT();
                            END;
                        END;

                    END ELSE BEGIN
                        L_PurchaseMessages."Error Found" := TRUE;
                        L_PurchaseMessages."Error Description" := STRSUBSTNO(error3Err, "EDI-Purchase Messages".Items, "EDI-Purchase Messages".DocumentNumber);
                        L_PurchaseMessages.MODIFY();
                    END;
                END ELSE BEGIN
                    L_PurchaseMessages."Error Found" := TRUE;
                    L_PurchaseMessages."Error Description" := STRSUBSTNO(error2Err, "EDI-Purchase Messages".DocumentNumber);
                    L_PurchaseMessages.MODIFY();
                END;
                COMMIT();
            end;

            trigger OnPreDataItem()
            begin
                _TempPh.RESET();
                _TempPh.DELETEALL();
            end;
        }
        //Confirm the purchase orders
        dataitem("Integer"; "Integer")
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord()
            var
                EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
            begin
                IF Integer.Number = 1 THEN
                    _TempPh.FINDFIRST()
                ELSE
                    _TempPh.NEXT(1);
                _recPH.RESET();
                _recPH.SETRANGE("Document Type", _TempPh."Document Type");
                _recPH.SETRANGE("No.", _TempPh."No.");
                IF _recPH.FINDFIRST() THEN BEGIN
                    _recPH."GXL Order Conf. Received" := TRUE;
                    _recPH."GXL Order Confirmation Date" := TODAY();
                    CLEAR(cuStatusMgmt);
                    CLEARLASTERROR();
                    //TODO: Order Status- Import purchase file => process EDI Purchase Messages, perform confirm order
                    cuStatusMgmt.SetPurchOptions(0);
                    IF NOT cuStatusMgmt.RUN(_recPH) THEN BEGIN
                        EDIPurchaseMessages.SETRANGE(DocumentNumber, _recPH."No.");
                        IF EDIPurchaseMessages.FINDLAST() THEN BEGIN
                            EDIPurchaseMessages."Error Found" := TRUE;
                            EDIPurchaseMessages."Error Description" := COPYSTR(GETLASTERRORTEXT(), 1, 249);
                            EDIPurchaseMessages.MODIFY(TRUE);
                        END;
                    END;
                    COMMIT();
                END;
            end;

            trigger OnPreDataItem()
            begin
                _TempPh.RESET();
                IF _TempPh.FINDFIRST() THEN
                    Integer.SETRANGE(Integer.Number, 1, _TempPh.COUNT())
                ELSE
                    CurrReport.BREAK();
            end;
        }
        //Process EDI-Purchase Messages for Invoice
        //Validate the purchase orders to be ready for invoice
        dataitem(EDIInvoice; "GXL EDI-Purchase Messages")
        {
            DataItemTableView = SORTING(ImportDoc, DocumentNumber) ORDER(Ascending) WHERE(ImportDoc = const("2"), "Error Found" = FILTER(false), Processed = FILTER(false));
            RequestFilterFields = DocumentNumber;

            trigger OnAfterGetRecord()
            var
                Vendor: Record Vendor;
                PurchRcptHdr: Record "Purch. Rcpt. Header";
                L_EDIInvoice: Record "GXL EDI-Purchase Messages";
                BoolErrInv: Boolean;
            begin
                BoolErrInv := FALSE;
                TempInvoiceMessage.RESET();
                TempInvoiceMessage.SETRANGE(ImportDoc, ImportDoc);
                TempInvoiceMessage.SETFILTER(DocumentNumber, DocumentNumber);
                IF NOT TempInvoiceMessage.FINDSET() THEN BEGIN
                    TempInvoiceMessage.RESET();
                    TempInvoiceMessage.INIT();
                    TempInvoiceMessage.TRANSFERFIELDS(EDIInvoice);
                    TempInvoiceMessage.INSERT();


                    //Purchase order exists?
                    _recPH.RESET();
                    _recPH.SETRANGE("Document Type", _recPH."Document Type"::Order);
                    _recPH.SETRANGE("No.", DocumentNumber);
                    IF NOT _recPH.FINDFIRST() THEN BEGIN
                        L_EDIInvoice.RESET();
                        L_EDIInvoice.SETRANGE(ImportDoc, ImportDoc);
                        L_EDIInvoice.SETFILTER(DocumentNumber, DocumentNumber);
                        L_EDIInvoice.MODIFYALL("Error Found", TRUE);
                        L_EDIInvoice.MODIFYALL("Error Description", STRSUBSTNO(error2Err, DocumentNumber));
                        CurrReport.SKIP();
                    END;

                    //Supplier ABN?
                    L_EDIInvoice.RESET();
                    L_EDIInvoice.SETRANGE(ImportDoc, ImportDoc);
                    L_EDIInvoice.SETFILTER(DocumentNumber, DocumentNumber);
                    L_EDIInvoice.SETFILTER("Supplier ABN", '=%1', '');
                    IF L_EDIInvoice.FINDFIRST() THEN BEGIN
                        L_EDIInvoice.RESET();
                        L_EDIInvoice.SETRANGE(ImportDoc, ImportDoc);
                        L_EDIInvoice.SETFILTER(DocumentNumber, DocumentNumber);
                        L_EDIInvoice.MODIFYALL("Error Found", TRUE);
                        L_EDIInvoice.MODIFYALL("Error Description", 'Supplier ABN can not be blank for PO ' + DocumentNumber);
                        CurrReport.SKIP();
                    END;

                    //Vendor Invoice Number?
                    IF (VendorInvoiceNumber = '') OR CheckVendInvoice(VendorInvoiceNumber, _recPH."Pay-to Vendor No.") THEN BEGIN
                        L_EDIInvoice.RESET();
                        L_EDIInvoice.SETRANGE(ImportDoc, ImportDoc);
                        L_EDIInvoice.SETFILTER(DocumentNumber, DocumentNumber);
                        L_EDIInvoice.MODIFYALL("Error Found", TRUE);
                        L_EDIInvoice.MODIFYALL("Error Description", 'Vendor Invoice Number can not be blank or already used for this vendor');
                        CurrReport.SKIP();
                    END;

                    //TODO: Order Status- Import purchase file => process EDI Purchase Messages for invoice, only Closed is accepted
                    IF NOT ((_recPH."GXL Order Status" = _recPH."GXL Order Status"::Closed)) then //AND (_recPH."GXL Last JDA Date Modified" < TODAY())) THEN
                        CurrReport.SKIP();

                    //Not to continue if no receipts posted                    
                    PurchRcptHdr.RESET();
                    PurchRcptHdr.SetCurrentKey("Order No.");
                    PurchRcptHdr.SETFILTER(PurchRcptHdr."Order No.", _recPH."No.");
                    IF PurchRcptHdr.IsEmpty() then
                        CurrReport.SKIP();
                END ELSE
                    CurrReport.SKIP();

                BoolErrInv := FALSE;
                Vendor.RESET();
                IF Vendor.GET(_recPH."Pay-to Vendor No.") THEN;


                L_EDIInvoice.RESET();
                L_EDIInvoice.SETRANGE(ImportDoc, ImportDoc);
                L_EDIInvoice.SETFILTER(DocumentNumber, DocumentNumber);
                IF L_EDIInvoice.FINDSET() THEN BEGIN
                    REPEAT
                        _recPL.RESET();
                        _recPL.SETRANGE(_recPL."Document Type", _recPL."Document Type"::Order);
                        _recPL.SETRANGE(_recPL."Document No.", _recPH."No.");
                        _recPL.SETRANGE(_recPL.Type, _recPL.Type::Item);
                        //Note: 
                        //  field Items has already been converted/poulated during import
                        //  It is the real item number
                        _recPL.SETRANGE(_recPL."No.", L_EDIInvoice.Items);
                        IF _recPL.FINDFIRST() THEN BEGIN
                            _recPL."GXL Confirmed Invoice Qty" := QtyToInvoice;
                            _recPL."GXL Confirmed Direct Unit Cost" := L_EDIInvoice.UnitCostExcl;
                            _recPL.MODIFY();
                            IF L_EDIInvoice.QtyToInvoice <> _recPL."Qty. to Invoice" THEN BEGIN
                                L_EDIInvoice."Error Found" := TRUE;
                                L_EDIInvoice."Error Description" := error4Err;
                                L_EDIInvoice.MODIFY();
                                BoolErrInv := TRUE;
                            END;
                            IF L_EDIInvoice.QtyToInvoice <> 0 THEN BEGIN
                                IF ((_recPL."GXL Confirmed Direct Unit Cost" > _recPL."Direct Unit Cost") OR
                                   ((Vendor."GXL Acc. Lower Cost Purch. Inv" = FALSE) AND (_recPL."GXL Confirmed Direct Unit Cost" < _recPL."Direct Unit Cost"))) THEN BEGIN
                                    BoolErrInv := TRUE;
                                    IF L_EDIInvoice."Error Found" = FALSE THEN BEGIN
                                        L_EDIInvoice."Error Found" := TRUE;
                                        L_EDIInvoice."Error Description" := STRSUBSTNO(error5Err, _recPL."GXL Confirmed Direct Unit Cost", _recPL."Direct Unit Cost");
                                    END ELSE
                                        L_EDIInvoice."Error Description" += ' ' + STRSUBSTNO(error5Err, _recPL."GXL Confirmed Direct Unit Cost", _recPL."Direct Unit Cost");

                                    L_EDIInvoice.MODIFY();
                                END;
                                IF ((Vendor."GXL Acc. Lower Cost Purch. Inv" = TRUE) AND (_recPL."GXL Confirmed Direct Unit Cost" < _recPL."Direct Unit Cost")) THEN BEGIN
                                    _recPL.SuspendStatusCheck(TRUE);
                                    _recPL.VALIDATE("Direct Unit Cost", _recPL."GXL Confirmed Direct Unit Cost");
                                    _recPL.MODIFY();
                                END;
                            END;
                        END ELSE BEGIN
                            L_EDIInvoice."Error Found" := TRUE;
                            L_EDIInvoice."Error Description" := STRSUBSTNO(error3Err, Items, DocumentNumber);
                            L_EDIInvoice.MODIFY();
                            BoolErrInv := TRUE;
                        END;

                    UNTIL L_EDIInvoice.NEXT() = 0;
                    IF BoolErrInv = TRUE THEN BEGIN
                        L_EDIInvoice.RESET();
                        L_EDIInvoice.SETRANGE(ImportDoc, ImportDoc);
                        L_EDIInvoice.SETFILTER(DocumentNumber, DocumentNumber);
                        L_EDIInvoice.MODIFYALL("Error Found", TRUE);
                    END ELSE BEGIN

                        _TempPh.RESET();
                        _TempPh.SETRANGE(_TempPh."Document Type", _recPH."Document Type");
                        _TempPh.SETRANGE(_TempPh."No.", _recPH."No.");
                        IF NOT _TempPh.FINDFIRST() THEN BEGIN
                            _TempPh.INIT();
                            _TempPh.TRANSFERFIELDS(_recPH);
                            _TempPh."Vendor Invoice No." := VendorInvoiceNumber;
                            _TempPh."GXL Invoice Received Date" := InvoiceDate;
                            _TempPh."GXL Invoice Received" := TRUE;
                            _TempPh.INSERT();
                        END;
                        L_EDIInvoice.RESET();
                        L_EDIInvoice.SETRANGE(ImportDoc, ImportDoc);
                        L_EDIInvoice.SETFILTER(DocumentNumber, DocumentNumber);
                        L_EDIInvoice.MODIFYALL(Processed, TRUE);

                    END;
                END;
            end;

            trigger OnPreDataItem()
            begin
                _TempPh.RESET();
                _TempPh.DELETEALL();
                IntegrationSetup.GET();
            end;
        }
        //Set the purchase orders that are ready to be invoiced
        dataitem(PostInv; "Integer")
        {
            DataItemTableView = SORTING(Number);

            trigger OnAfterGetRecord()
            begin
                IF Number = 1 THEN
                    FINDFIRST()
                ELSE
                    NEXT(1);
                _recPH.RESET();
                _recPH.SETRANGE("Document Type", _TempPh."Document Type");
                _recPH.SETRANGE("No.", _TempPh."No.");
                IF _recPH.FINDFIRST() THEN BEGIN
                    _recPH."Vendor Invoice No." := _TempPh."Vendor Invoice No.";
                    _recPH."GXL Invoice Received Date" := _TempPh."GXL Invoice Received Date";
                    IF _recPH."Posting Date" = 0D THEN BEGIN
                        _recPH.SetHideValidationDialog(TRUE);
                        _recPH.VALIDATE("Posting Date", TODAY());
                    END;
                    _recPH."GXL Invoice Received" := TRUE;
                    _recPH.Receive := FALSE;
                    _recPH.Invoice := TRUE;
                    _recPH.MODIFY();
                END;
            end;

            trigger OnPreDataItem()
            begin
                _TempPh.RESET();
                IF _TempPh.FINDSET() THEN
                    SETRANGE(Number, 1, _TempPh.COUNT())
                ELSE
                    CurrReport.BREAK();
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        _FileDirectory: Record File;
        JobQueueEntry: Record "Job Queue Entry";
        IntegrationSetup: Record "GXL Integration Setup";
        _recvendor: Record Vendor;
        _recPL: Record "Purchase Line";
        _TempPh: Record "Purchase Header" temporary;
        TempInvoiceMessage: Record "GXL EDI-Purchase Messages" temporary;
        _recPH: Record "Purchase Header";
        cuWHDATAMGMT: Codeunit "GXL WH Data Management";
        cuRPD: Codeunit "Release Purchase Document";
        cuStatusMgmt: Codeunit "GXL SC-Purch. Order Status Mgt";
        VendorNo: Code[20];
        error2Err: Label 'PO %1 Not found';
        error3Err: Label 'Item %1 Not found in PO %2';
        error4Err: Label 'Invoice qty is not matching';
        error5Err: Label 'Confirmed Direct Unit Cost %1 is not matching purchase line direct unit cost %2';

    local procedure CheckDirectory(var FilePathName: Text)
    var
        i: Integer;
        BackSlash: Text[1];
    begin
        i := STRLEN(FilePathName);
        BackSlash := COPYSTR(FilePathName, i);

        IF BackSlash <> '\' THEN
            FilePathName := FilePathName + '\';
    end;

    local procedure CheckVendInvoice(VendInvNumber: Code[20]; PaytoVend: Code[20]): Boolean
    var
        PurchSetup: Record "Purchases & Payables Setup";
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        // Check External Document number
        PurchSetup.RESET();
        PurchSetup.GET();

        IF PurchSetup."Ext. Doc. No. Mandatory" OR
           (VendInvNumber <> '')
        THEN BEGIN
            VendLedgEntry.RESET();
            VendLedgEntry.SETCURRENTKEY("External Document No.");
            VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Invoice);
            VendLedgEntry.SETRANGE("External Document No.", VendInvNumber);
            VendLedgEntry.SETRANGE("Vendor No.", PaytoVend);
            IF not VendLedgEntry.IsEmpty() then
                EXIT(TRUE)
        END;

        EXIT(FALSE)
    end;

    local procedure InboundFileCheck(p_Code: Code[20]; XmlPortID: Integer; Type: Option ,SD,WH,XD,FT,Confirmation,Invoice,"3pl",ASN): Boolean
    var
        _recFileSetup: Record "GXL 3Pl File Setup";
    begin
        _recFileSetup.RESET();
        _recFileSetup.SETRANGE(Code, p_Code);
        _recFileSetup.SETRANGE(Direction, _recFileSetup.Direction::Inbound);
        _recFileSetup.SETRANGE("XML Port", XmlPortID);
        IF not _recFileSetup.IsEmpty() THEN
            EXIT(TRUE);

        EXIT(FALSE);
    end;

    procedure SetJobQueueEntry(NewJobQueueEntry: Record "Job Queue Entry")
    begin
        JobQueueEntry := NewJobQueueEntry;
    end;

    local procedure MoveFile(FromFileName: Text; ToFileName: Text)
    var
        FileManagement: Codeunit "File Management";
        // >> Upgrade
        //ServerFileHelper: DotNet File;
        ServerFileHelper: DotNet File1;
    // << Upgrade
    begin
        IF GUIALLOWED() THEN
            // >> Upgrade
            //FileManagement.DownloadToFile(FromFileName, ToFileName)
            FileManagement.DownloadHandler(FromFileName, '', '', '', ToFileName)
        // << Upgrade
        ELSE BEGIN

            IF ServerFileHelper.Exists(ToFileName) THEN
                ServerFileHelper.Delete(ToFileName);

            ServerFileHelper.Copy(FromFileName, ToFileName);

        END;

        ServerFileHelper.Delete(FromFileName);
    end;
}

