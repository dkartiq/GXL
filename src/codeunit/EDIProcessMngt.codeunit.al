// 003 23.06.2025 KDU HAR2-397
// 002 LCB-505 Error fix
codeunit 50362 "GXL EDI Process Mngt"
{
    // 001 LCB-1    PREM    Skip Invoice validation if receipt is not yet created.
    trigger OnRun()
    var
        ConfirmStatusReport: Report "Batch Confirm Purchase Order"; // >> HP2-Sprint2 <<
    begin
        CASE ProcessWhich OF

            ProcessWhich::PO, ProcessWhich::POX:
                BEGIN
                    IF ProcessWhat <> ProcessWhat::"Validate and Export" THEN
                        EXIT;

                    ValidateExportPurchaseOrder(ProcessWhich);

                    ValidateExportPurchaseOrdersP2PNonEDI(ProcessWhich);

                    Report.Run(Report::"Batch Confirm Purchase Order", false, false) // >> HP2-SPRINT2 <<
                END;

            ProcessWhich::POR:
                BEGIN
                    CASE ProcessWhat OF
                        ProcessWhat::Import:
                            BEGIN
                                ImportPurchaseOrderResponse();
                                ImportPurchaseOrderResponseP2PNonEDI();
                            END;
                        ProcessWhat::Validate:
                            BEGIN
                                ValidatePurchaseOrderResponse();

                                ValidatePurchaseOrderResponseP2PNonEDI();

                            END;
                        ProcessWhat::Process:
                            BEGIN
                                ProcessPurchaseOrderResponse();

                                ProcessPurchaseOrderResponseP2PNonEDI();

                            END;
                        ELSE
                            EXIT;
                    END;
                END;

            ProcessWhich::ASN:
                BEGIN
                    //Status in ASN Header will be updated
                    CASE ProcessWhat OF
                        //applied to "3PL EDI" only (i.e. EDI purchase order and ordered from 3PL EDI location)
                        //Status from Processed => 3PL Sent                  
                        ProcessWhat::"Validate and Export":
                            ValidateExportASN();

                        //import into ASN Header/Line Level
                        //status => Imported
                        ProcessWhat::Import:
                            BEGIN
                                //for EDI Vendor Type = VAN
                                //xml port 50049
                                //create ASN Header/Line Level 
                                ImportAdvanceShippingNotice(); //VAN

                                //for EDI Vendor Type = P2P or P2P Contingency
                                //XML file must be configured in "3PL File Setup"
                                //file name must be prefix with the XML port number
                                //xml port 50047:
                                //PDA-Purchase Lines are created and used to validate purchase qty. to receive and receive variance 
                                //  and PDA-Purchase Lines are deleted at the end of importing process
                                ImportAdvanceShippingNoticeP2PNonEDI(); //P2P

                            END;

                        //Check ASN Header and Line Level
                        //status => Validated
                        ProcessWhat::Validate:
                            BEGIN
                                ValidateAdvanceShippingNotice();
                            END;

                        //Process ASN Header/Line
                        //Status => Processed
                        ProcessWhat::Process:
                            BEGIN
                                ProcessAdvanceShippingNotice();
                            END;

                        //Create/Import ASN Scan Log Header/Lines
                        //Status => Scanned
                        ProcessWhat::Scan:
                            BEGIN
                                //For POs that are "P2P Contingency" and PDA-PL Receive Buffer created from MIM
                                //It will create ASN Header/Lines and ASN Scan Log Header/Lines
                                InsertP2PContingencyASN();

                                //Import ASN Scan Log (XML Port 50069)
                                if isAPI then
                                    Import3PLEDIFileForAPI()
                                else
                                    Import3PLEDIFile();

                                //Process and validate ASN scan log to update qty. to receive in the ASN Line Level 3
                                CopyScannedAdvanceShippingNotice();
                            END;

                        //Receive the PO
                        //Status => Received
                        ProcessWhat::Receive:
                            BEGIN
                                //For Ullaged vendor, create EDI claim entry if QuantityReceived is less than Quantity
                                //Post the purchase order as Receive
                                ReceiveAdvanceShippingNotice();
                            END;

                        //Basing on EDI claim entry
                        //Create the purchase return
                        ProcessWhat::"Create Return Order":
                            BEGIN
                                CreateReturnOrder();
                            END;

                        //Basing on EDI claim entry
                        //Apply the return order to original purchase receipt
                        ProcessWhat::"Apply Return Order":
                            BEGIN
                                ApplyReturnOrder();
                            END;

                        //Basing on EDI claim entry
                        //ship the return order
                        ProcessWhat::"Post Return Shipment":
                            BEGIN
                                PostReturnShipment();
                            END;
                        ELSE
                            EXIT;
                    END;
                END;

            ProcessWhich::INV:
                BEGIN
                    CASE ProcessWhat OF
                        ProcessWhat::Import:
                            BEGIN
                                //Import invoice files for "EDI Vendor Type" = VAN
                                //xmlport = GXL EDI-Invoice
                                //Entries will be created in tables PO INV Header/Line
                                //Status = Imported
                                ImportInvoice();

                                //Import invoice files for "EDI Vendor Type" = P2P or P2P Contingency
                                //xmlport = 50356 (file name must start with XML port number)
                                //Entries will be created in tables "EDI-Purchase Messages", Status=Imported 
                                //then transferred into tables PO INV Header/Line
                                //Status in EDI-Purchase Messages => Processed
                                //Status in PO INV Header = Imported
                                ImportInvoiceP2PNonEDI();
                            END;

                        ProcessWhat::Validate:
                            BEGIN
                                //Validate then information from PO INV Header/Line
                                //Status => Validated
                                ValidateInvoice();
                            END;
                        ProcessWhat::Process:
                            BEGIN
                                //Post the purchase order as Invoice
                                //Status => Processed
                                ProcessInvoice();
                            END;
                        ProcessWhat::"Post Return Credit":
                            BEGIN
                                //Post the return order for the claimed quantity
                                //Status => Return Credit Posted 
                                PostReturnCredit();
                            END;
                        ELSE
                            EXIT;
                    END;
                END;

            ProcessWhich::IPO, ProcessWhich::IPOX:
                BEGIN
                    IF ProcessWhat <> ProcessWhat::"Validate and Export" THEN
                        EXIT;

                    ValidateExportIntlPO(ProcessWhich);
                END;

            ProcessWhich::IPOR:
                BEGIN
                    CASE ProcessWhat OF
                        ProcessWhat::Import:
                            ImportIntlPOAck(7);
                        ProcessWhat::Validate:
                            ValidateIntlPOAck();
                        ProcessWhat::Process:
                            ProcessIntlPOAck();
                        ELSE
                            EXIT;
                    END;
                END;

            ProcessWhich::SHIPSTATUS:
                BEGIN
                    CASE ProcessWhat OF
                        ProcessWhat::Import:
                            ImportIntlPOShippingAdvice(6);
                        ProcessWhat::Validate:
                            ValidateIntlPOShippingAdvice();
                        ProcessWhat::Process:
                            ProcessIntlPOShippingAdvice();
                        ELSE
                            EXIT;
                    END;
                END;

            ELSE
                EXIT;
        END;
    end;

    var
        EDISetup: Record "GXL Integration Setup";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        EDISetupRead: Boolean;
        //ProcessWhich: Option x,y,z,xx,yy,zz,xxx,SHIPSTATUS,yyy;
        ProcessWhich: Option PO,POX,POR,ASN,INV,IPO,IPOX,SHIPSTATUS,IPOR;
        ProcessWhat: Option "Validate and Export",Import,Validate,Process,Scan,Receive,"Create Return Order","Apply Return Order","Post Return Shipment","Post Return Credit";
        ProcessEDIVendorType: Option " ","Point 2 Point",VAN,"3PL Supplier";
        Text50001Msg: Label 'An EDI invoice %1 has been received for a PO %2 already invoiced manually.';
        XMLBlob: Codeunit "Temp Blob";
        APIMessageLogEntryNo: Integer;
        isAPI: Boolean;

    procedure SetOptions(NewProcessWhich: Option PO,POX,POR,ASN,INV,IPO,IPOX,SHIPSTATUS,IPOR; NewProcessWhat: Option "Validate and Export",Import,Validate,Process,Scan,Receive,"Create Return Order","Apply Return Order","Post Return Shipment","Post Return Credit")
    begin
        ProcessWhich := NewProcessWhich;
        ProcessWhat := NewProcessWhat;
    end;

    local procedure ValidateExportPurchaseOrder(ExportWhich: Option PO,POX,POR,ASN,INV)
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeader2: Record "Purchase Header";
        EDIExportValidatePurchOrder: Codeunit "GXL EDI-Export+Val. Pur. Order";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        FileMgt: Codeunit "File Management";
        ExportWasSuccess: Boolean;
        ForCancellation: Boolean;
        EDIFileLogEntryNo: Integer;
        FileName: Text;
        FinalDestination: Text;
        FilePrefix: Text;
    begin
        GetEDISetup();

        EDISetup.TESTFIELD("PO File Name Prefix");
        EDISetup.TESTFIELD("POX File Name Prefix");

        //TODO: Order Status - EDI export purchase order, only Created or Cancelled are exported
        PurchaseHeader.Reset();
        PurchaseHeader.SETCURRENTKEY("GXL Order Status");
        PurchaseHeader.SETFILTER("GXL Order Status", ' %1|%2', PurchaseHeader."GXL Order Status"::Created, PurchaseHeader."GXL Order Status"::Cancelled);
        PurchaseHeader.SETRANGE("GXL EDI Order", TRUE);
        IF PurchaseHeader.FindSet() THEN
            REPEAT

                IF PurchaseOrderQualifiesForExport(PurchaseHeader, ForCancellation) THEN BEGIN

                    Vendor.GET(PurchaseHeader."Buy-from Vendor No.");

                    PurchaseHeader2 := PurchaseHeader;
                    Vendor."GXL EDI Outbound Directory" := GetDirectory(Vendor."GXL EDI Outbound Directory", 1, Vendor."GXL EDI Vendor Type");
                    Vendor."GXL EDI Archive Directory" := GetDirectory(Vendor."GXL EDI Archive Directory", 2, Vendor."GXL EDI Vendor Type");

                    IF ForCancellation THEN BEGIN
                        ExportWhich := ExportWhich::POX;
                        FilePrefix := EDISetup."POX File Name Prefix";
                    END ELSE
                        FilePrefix := EDISetup."PO File Name Prefix";

                    FileName := STRSUBSTNO('%1%2.%3',
                      FilePrefix,
                      PurchaseHeader2."No.",
                      GetXmlFileExtension());

                    FinalDestination := FileMgt.CombinePath(Vendor."GXL EDI Outbound Directory", FileName);

                    EDIFileLogEntryNo := InsertEDIFileLog2(FinalDestination, ExportWhich, 0, '', PurchaseHeader2."GXL EDI Vendor Type");

                    EDIExportValidatePurchOrder.SetOptions(ExportWhich, FinalDestination);

                    Commit();

                    ExportWasSuccess := EDIExportValidatePurchOrder.RUN(PurchaseHeader2);

                    IF ExportWasSuccess THEN BEGIN

                        //copy file to archive directory
                        MoveFile(FinalDestination, GetFileName(FileMgt.CombinePath(Vendor."GXL EDI Archive Directory", FileName)), FALSE);

                        //update log 1
                        UpdateEDIFileLog(EDIFileLogEntryNo, ExportWasSuccess);

                        // Update Purchase Header
                        // ,PO,POX,POR,ASN,INV,Cancelled
                        IF ForCancellation THEN
                            UpdatePurchaseHeader(PurchaseHeader2, EDIFileLogEntryNo, 2)
                        ELSE
                            UpdatePurchaseHeader(PurchaseHeader2, EDIFileLogEntryNo, 1);

                        //update log 2
                        InsertEDIDocumentLog(EDIFileLogEntryNo, ExportWhich, ProcessWhat, ExportWasSuccess);

                    END ELSE BEGIN

                        //update log 1
                        UpdateEDIFileLog(EDIFileLogEntryNo, ExportWasSuccess);

                        //update log 2
                        InsertEDIDocumentLog(EDIFileLogEntryNo, ExportWhich, ProcessWhat, ExportWasSuccess);

                    END;

                    Commit();

                    IF NOT ExportWasSuccess THEN
                        EDIEmailMgt.SendPOExportFailureEmail(PurchaseHeader2, GetLastErrorText());
                END;

            UNTIL PurchaseHeader.Next() = 0;
    end;

    local procedure ImportFile(ImportWhich: Option PO,POX,POR,ASN,INV,SHIPSTATUS,IPOR; EDIVendorType: Option " ","Point 2 Point",VAN,"3PL Supplier")
    var
        Vendor: Record Vendor;
        NameValueBuffer: Record "Name/Value Buffer" temporary;
        EDIImportFile: Codeunit "GXL EDI-Import File";
        FileMgt: Codeunit "File Management";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        SingleInstance: Codeunit "GXL WMS Single Instance";
        ImportWasSuccess: Boolean;
        EDIFileLogEntryNo: Integer;
        StoredFileName: Text;
        FilePrefix: Text;
        FileFormat: Text;
        PrefixFits: Boolean;
        ExtFits: Boolean;
        FileSize: BigInteger;
        FileModifyDate: Date;
        FileModifyTime: Time;
        CurrFileName: Text;
        CurrFileExt: Text;
        FileSetupFound: Boolean;
    begin
        GetEDISetup();

        Vendor.SETCURRENTKEY("GXL EDI Flag", "GXL EDI Vendor Type");
        //Vendor.SetFilter("GXL EDI Inbound Directory", '<>%1', ''); //ERP-247 <<
        IF EDIVendorType = EDIVendorType::VAN THEN BEGIN

            CASE ImportWhich OF
                ImportWhich::POR:
                    BEGIN
                        EDISetup.TESTFIELD("POR File Name Prefix");
                        FilePrefix := EDISetup."POR File Name Prefix";
                    END;
                ImportWhich::ASN:
                    BEGIN
                        EDISetup.TESTFIELD("ASN File Name Prefix");
                        FilePrefix := EDISetup."ASN File Name Prefix";
                    END;
                ImportWhich::INV:
                    BEGIN
                        EDISetup.TESTFIELD("INV File Name Prefix");
                        FilePrefix := EDISetup."INV File Name Prefix";
                    END;
            END;

            FileFormat := GetXmlFileExtension();
            Vendor.SETRANGE("GXL EDI Flag", TRUE);
            Vendor.SETRANGE("GXL EDI Vendor Type", Vendor."GXL EDI Vendor Type"::VAN);

        END ELSE
            IF EDIVendorType = EDIVendorType::"Point 2 Point" THEN BEGIN
                // Vendor.SETRANGE("GXL EDI Flag", FALSE);
                Vendor.SETFILTER("GXL EDI Vendor Type", '%1|%2', Vendor."GXL EDI Vendor Type"::"Point 2 Point", Vendor."GXL EDI Vendor Type"::"Point 2 Point Contingency");
            END;

        IF Vendor.FindSet() THEN
            REPEAT

                Vendor."GXL EDI Inbound Directory" := GetDirectory(Vendor."GXL EDI Inbound Directory", 0, EDIVendorType);
                Vendor."GXL EDI Archive Directory" := GetDirectory(Vendor."GXL EDI Archive Directory", 2, EDIVendorType);
                Vendor."GXL EDI Error Directory" := GetDirectory(Vendor."GXL EDI Error Directory", 3, EDIVendorType);

                IF Vendor."GXL EDI Inbound Directory" <> '' THEN BEGIN
                    FileSetupFound := true; //ERP-247 <<
                    IF EDIVendorType = EDIVendorType::"Point 2 Point" THEN
                        //ERP-247 >>
                        //GetP2PInboundFilePrefix(Vendor."No.", FilePrefix, FileFormat);
                        if not GetP2PInboundFilePrefix(Vendor."No.", FilePrefix, FileFormat) then
                            FileSetupFound := false;
                    //ERP-247 <<
                    if FileSetupFound then begin //ERP-247 <<
                        FileMgt.GetServerDirectoryFilesList(NameValueBuffer, Vendor."GXL EDI Inbound Directory");
                        if NameValueBuffer.Find('-') then
                            repeat
                                CurrFileName := FileMgt.GetFileName(NameValueBuffer.Name);
                                CurrFileExt := FileMgt.GetExtension(NameValueBuffer.Name);

                                PrefixFits := true;
                                ExtFits := true;
                                if (FilePrefix <> '') then
                                    PrefixFits := StrPos(UpperCase(CurrFileName), UpperCase(FilePrefix)) = 1;
                                if (FileFormat <> '') then
                                    ExtFits := UpperCase(FileFormat) = UpperCase(CurrFileExt);

                                if (PrefixFits AND ExtFits) then begin
                                    EDIFileLogEntryNo := InsertEDIFileLog2(NameValueBuffer.Name, ImportWhich, 0, '', Vendor."GXL EDI Vendor Type");
                                    Commit();
                                    CLEAR(EDIImportFile);
                                    CASE EDIVendorType OF
                                        EDIVendorType::VAN:
                                            BEGIN
                                                EDIImportFile.SetOptions(ImportWhich, NameValueBuffer.Name, EDIFileLogEntryNo);
                                                ImportWasSuccess := EDIImportFile.Run();
                                            END;
                                        EDIVendorType::"Point 2 Point":
                                            BEGIN
                                                SingleInstance.SetEDIFileLogEntryNo(EDIFileLogEntryNo);
                                                SingleInstance.SetEDIPartnerNo(Vendor."No.");
                                                EDIImportFile.SetP2POptions(EDIVendorType::"Point 2 Point", FilePrefix, NameValueBuffer.Name);
                                                ImportWasSuccess := EDIImportFile.Run();
                                                SingleInstance.SetEDIPartnerNo('');
                                                SingleInstance.SetEDIFileLogEntryNo(0);
                                            END;
                                    END;
                                    IF ImportWasSuccess THEN BEGIN

                                        //move file to archive directory                                                                       
                                        MoveFile(NameValueBuffer.Name, GetFileName(FileMgt.CombinePath(Vendor."GXL EDI Archive Directory", CurrFileName)), TRUE);

                                        //update log 1
                                        UpdateEDIFileLog(EDIFileLogEntryNo, ImportWasSuccess);

                                        //update log 2
                                        InsertEDIDocumentLog(EDIFileLogEntryNo, ImportWhich, ProcessWhat, ImportWasSuccess);

                                    END ELSE BEGIN

                                        FileMgt.GetServerFileProperties(NameValueBuffer.Name, FileModifyDate, FileModifyTime, FileSize);

                                        //move file to error directory
                                        //MoveFile(FileInfo.FullName,GetFileName(FileMgt.CombinePath(Vendor."GXL EDI Error Directory",FileInfo.Name)),TRUE);
                                        IF NOT IsLockingError(GetLastErrorCode()) THEN BEGIN
                                            StoredFileName := GetFileName(FileMgt.CombinePath(Vendor."GXL EDI Error Directory", CurrFileName));
                                            MoveFile(NameValueBuffer.Name, StoredFileName, TRUE);
                                        END;

                                        //update log 1
                                        UpdateEDIFileLog(EDIFileLogEntryNo, ImportWasSuccess);

                                    END;
                                    Commit();
                                    IF (NOT ImportWasSuccess) AND NOT (IsLockingError(GetLastErrorCode())) THEN
                                        IF EDIVendorType = EDIVendorType::"Point 2 Point" THEN
                                            EDIEmailMgt.SendP2PImportFailureEmail(ImportWhich, StoredFileName, CurrFileName, FileSize, GetLastErrorText(), Vendor."No.")
                                        ELSE
                                            EDIEmailMgt.SendImportFailureEmail(ImportWhich, StoredFileName, CurrFileName, FileSize, GetLastErrorText());

                                end;
                            until NameValueBuffer.Next() = 0;
                    end; //ERP-247 <<
                END;
            UNTIL Vendor.Next() = 0;
    end;

    local procedure ImportPurchaseOrderResponse()
    begin
        ImportFile(2, ProcessEDIVendorType::VAN);
    end;

    local procedure ValidatePurchaseOrderResponse()
    var
        POResponseHeader: Record "GXL PO Response Header";
        POResponseHeader2: Record "GXL PO Response Header";
        TempItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary;
        EDIValidatePurchOrderResp: Codeunit "GXL EDI-Valid Pur. Order Resp.";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ValidationWasSuccess: Boolean;
    begin
        POResponseHeader.SETCURRENTKEY(Status);
        POResponseHeader.SETRANGE(Status, POResponseHeader.Status::Imported);

        IF POResponseHeader.FindSet() THEN
            REPEAT
                IF CheckNAVDocumentNo(POResponseHeader."Original EDI Document No.", POResponseHeader."NAV EDI Document No.") THEN
                    EDIFunctionsLibrary.UpdatePORNAVEDIDocumentNo(POResponseHeader);

                Commit();
                ClearLastError();
                POResponseHeader2.GET(POResponseHeader."Response Number");
                ValidationWasSuccess := EDIValidatePurchOrderResp.RUN(POResponseHeader2);

                IF (NOT ValidationWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN BEGIN

                    POResponseHeader2.GET(POResponseHeader."Response Number");
                    POResponseHeader2.Status := POResponseHeader2.Status::"Validation Error";
                    POResponseHeader2.Modify();

                END;

                //PO,POX,POR,ASN,INV
                InsertEDIDocumentLog(POResponseHeader."EDI File Log Entry No.", 2, ProcessWhat, ValidationWasSuccess);

                Commit();

                IF ValidationWasSuccess THEN BEGIN

                    TempItemSupplierGTINBuffer.Reset();
                    TempItemSupplierGTINBuffer.DeleteAll();

                    EDIValidatePurchOrderResp.GetGTINChanges(TempItemSupplierGTINBuffer);
                    EDIEmailMgt.SendPORGTINValidationEmail(POResponseHeader2, TempItemSupplierGTINBuffer, GetLastErrorText());

                    TempItemSupplierGTINBuffer.Reset();
                    TempItemSupplierGTINBuffer.DeleteAll();

                END ELSE BEGIN

                    IF NOT IsLockingError(GetLastErrorCode()) THEN
                        EDIEmailMgt.SendPORValidationFailureEmail(POResponseHeader2, GetLastErrorText());

                END;

            UNTIL POResponseHeader.Next() = 0;
    end;

    local procedure ProcessPurchaseOrderResponse()
    var
        PORHeader: Record "GXL PO Response Header";
        PORHeader2: Record "GXL PO Response Header";
        PurchaseHeaderL: Record "Purchase Header"; // >> 003 <<
        EDIProcessPurchOrderResp: Codeunit "GXL EDI-Proc Purch Order Resp.";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
    begin
        PORHeader.SETCURRENTKEY(Status);
        PORHeader.SETRANGE(Status, PORHeader.Status::Validated);

        IF PORHeader.FindSet() THEN
            REPEAT
                Commit();
                ClearLastError();
                PORHeader2.GET(PORHeader."Response Number");
                ProcessWasSuccess := EDIProcessPurchOrderResp.RUN(PORHeader2);
                IF NOT ProcessWasSuccess THEN
                    IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                        PORHeader2.GET(PORHeader."Response Number");
                        PORHeader2.VALIDATE(Status, PORHeader2.Status::"Processing Error");
                        PORHeader2.MODIFY(TRUE);
                    END;
                // >> 003
                if (ProcessWasSuccess) and PurchaseHeaderL.Get(PurchaseHeaderL."Document Type"::Order, PORHeader2."Order No.") then begin
                    PurchaseHeaderL."GXL Order Conf. Received" := true;
                    PurchaseHeaderL."GXL Order Confirmation Date" := Today;
                    PurchaseHeaderL.Modify(true);
                end;
                // << 003

                //PO,POX,POR,ASN,INV
                InsertEDIDocumentLog(PORHeader."EDI File Log Entry No.", 2, ProcessWhat, ProcessWasSuccess);

                Commit();

                IF (NOT ProcessWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                    EDIEmailMgt.SendPORProcessingFailureEmail(PORHeader2, GetLastErrorText());

            UNTIL PORHeader.Next() = 0;
    end;


    ///#region "ASN"
    local procedure ValidateExportASN()
    var
        ASNHeader: Record "GXL ASN Header";
        ASNHeader2: Record "GXL ASN Header";
        Location: Record Location;
        "3PLEDIExport": Codeunit "GXL 3PL EDI - Export";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        FileMgt: Codeunit "File Management";
        ExportWasSuccess: Boolean;
        EDIFileLogEntryNo: Integer;
        FileName: Text;
        FinalDestination: Text;
    begin
        GetEDISetup();

        ASNHeader.Reset();
        ASNHeader.SETCURRENTKEY("3PL EDI", Status);
        ASNHeader.SETRANGE("3PL EDI", TRUE);
        ASNHeader.SETRANGE(Status, ASNHeader.Status::Processed);
        IF ASNHeader.FindSet() THEN
            REPEAT

                ASNHeader2 := ASNHeader;

                Location.GET(ASNHeader."Ship-To Code");
                if Location."GXL Outbound File Path" <> '' then begin
                    Location.TESTFIELD("GXL 3PL Archive File Path");
                    Location.TESTFIELD("GXL 3PL Error File Path");
                    Location.TESTFIELD("GXL Outbound File Path");

                    FileName := STRSUBSTNO('%1.%2',
                      ASNHeader2."No.",
                      GetXmlFileExtension());

                    FinalDestination := FileMgt.CombinePath(Location."GXL Outbound File Path", FileName);

                    Commit();
                    "3PLEDIExport".SetOptions(FinalDestination);
                    ExportWasSuccess := "3PLEDIExport".RUN(ASNHeader2);
                    EDIFileLogEntryNo := ASNHeader2."EDI File Log Entry No.";
                    //TODO: EDI File Log
                    if EDIFileLogEntryNo = 0 then begin
                        if ASNHeader2.AddEDIFileLog() then
                            ASNHeader2.Modify();
                        EDIFileLogEntryNo := ASNHeader2."EDI File Log Entry No.";
                    end;

                    IF ExportWasSuccess THEN BEGIN

                        //copy file to archive directory
                        MoveFile(FinalDestination, GetFileName(FileMgt.CombinePath(Location."GXL 3PL Archive File Path", FileName)), FALSE);

                        //update log 1
                        Update3PLEDIFileLog(EDIFileLogEntryNo, FinalDestination);

                        //update log 2
                        //TODO: EDI File Log
                        if EDIFileLogEntryNo <> 0 then
                            InsertEDIDocumentLog(EDIFileLogEntryNo, 0, ProcessWhat, ExportWasSuccess);

                    END ELSE BEGIN

                        //update log 2
                        //TODO: EDI File Log
                        if EDIFileLogEntryNo <> 0 then
                            InsertEDIDocumentLog(EDIFileLogEntryNo, 0, ProcessWhat, ExportWasSuccess);
                        IF NOT IsLockingError(GetLastErrorCode()) THEN BEGIN
                            ASNHeader2.GET(ASNHeader."Document Type", ASNHeader."No.");
                            ASNHeader2.VALIDATE(Status, ASNHeader2.Status::"3PL ASN Sending Error");
                            ASNHeader2.MODIFY(TRUE);
                        END;
                    END;
                end else begin
                    ASNHeader2.Validate(Status, ASNHeader.Status::"3PL ASN Sent");
                    ASNHeader2.Modify();
                end;

                Commit();
                IF (NOT ExportWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                    EDIEmailMgt.SendASNExmportFailureEmail(ASNHeader2, GetLastErrorText());

            UNTIL ASNHeader.Next() = 0;
    end;

    ///<Summary>
    ///Import ASN files for EDI Vendor Type = VAN
    ///Create ASN Header/Line Levels
    ///</Summary>
    local procedure ImportAdvanceShippingNotice()
    begin
        ImportFile(3, ProcessEDIVendorType::VAN);
    end;


    ///<Summary>
    ///Validate ASN Header/Line Levels
    ///Status on ASN Header is changed to Validated
    ///</Summary>
    local procedure ValidateAdvanceShippingNotice()
    var
        ASNHeader: Record "GXL ASN Header";
        ASNHeader2: Record "GXL ASN Header";
        TempItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary;
        EDIFileLog: Record "GXL EDI File Log";
        EDIValidateAdvanceShippingNotice: Codeunit "GXL EDI-Valid Adv Ship. Notice";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ValidationWasSuccess: Boolean;
        UpdateDocLog: Boolean;
    begin
        ASNHeader.SETCURRENTKEY(Status);
        ASNHeader.SETRANGE(Status, ASNHeader.Status::Imported);
        IF ASNHeader.FindSet() THEN
            REPEAT
                IF CheckNAVDocumentNo(ASNHeader."Original EDI Document No.", ASNHeader."NAV EDI Document No.") THEN
                    EDIFunctionsLibrary.UpdateASNNAVEDIDocumentNo(ASNHeader);
                Commit();
                ClearLastError();
                ASNHeader2.GET(ASNHeader."Document Type", ASNHeader."No.");
                ValidationWasSuccess := EDIValidateAdvanceShippingNotice.RUN(ASNHeader2);

                IF (NOT ValidationWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN BEGIN
                    ASNHeader2.GET(ASNHeader."Document Type", ASNHeader."No.");
                    //TODO: EDI File Log
                    //Temporarily insert as ASN Header and Lines are imported from NAV13                    
                    if ASNHeader2."EDI File Log Entry No." = 0 then
                        ASNHeader2.AddEDIFileLog();

                    ASNHeader2.VALIDATE(Status, ASNHeader2.Status::"Validation Error");
                    ASNHeader2.MODIFY(TRUE);
                end else begin
                    //TODO: EDI File Log
                    //Temporarily insert as ASN Header and Lines are imported from NAV13                    
                    if ASNHeader2."EDI File Log Entry No." = 0 then begin
                        ASNHeader2.Get(ASNHeader."Document Type", ASNHeader."No.");
                        if ASNHeader2.AddEDIFileLog() then
                            ASNHeader2.Modify();
                    end;

                end;

                UpdateDocLog := true;

                //ERP-247 +
                if ASNHeader2."EDI Type" = ASNHeader2."EDI Type"::"P2P Contingency" then
                    if ASNHeader2."EDI File Log Entry No." <> 0 then
                        if not EDIFileLog.Get(ASNHeader2."EDI File Log Entry No.") then
                            UpdateDocLog := false;
                //ERP-247 -

                //PO,POX,POR,ASN,INV
                //TODO: EDI File Log
                if UpdateDocLog and (ASNHeader2."EDI File Log Entry No." <> 0) then
                    InsertEDIDocumentLog(ASNHeader2."EDI File Log Entry No.", 3, ProcessWhat, ValidationWasSuccess);

                Commit();

                IF ValidationWasSuccess THEN BEGIN

                    TempItemSupplierGTINBuffer.Reset();
                    TempItemSupplierGTINBuffer.DeleteAll();

                    EDIValidateAdvanceShippingNotice.GetGTINChanges(TempItemSupplierGTINBuffer);
                    EDIEmailMgt.SendASNGTINValidationEmail(ASNHeader2, TempItemSupplierGTINBuffer, GetLastErrorText());

                    TempItemSupplierGTINBuffer.Reset();
                    TempItemSupplierGTINBuffer.DeleteAll();


                END ELSE BEGIN

                    IF NOT IsLockingError(GetLastErrorCode()) THEN
                        EDIEmailMgt.SendASNValidationFailureEmail(ASNHeader2, GetLastErrorText());

                END;

            UNTIL ASNHeader.Next() = 0;
    end;

    ///<Summary>
    ///Process Validated ASN Header/Line Levels
    ///Status on ASN Header is changed to Processed
    ///</Summary>
    local procedure ProcessAdvanceShippingNotice()
    var
        ASNHeader: Record "GXL ASN Header";
        ASNHeader2: Record "GXL ASN Header";
        EDIProcessAdvanceShippingNotice: Codeunit "GXL EDI-Proc Adv. Ship. Notice";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
    begin
        ASNHeader.SETCURRENTKEY(Status);
        ASNHeader.SETRANGE(Status, ASNHeader.Status::Validated);
        IF ASNHeader.FindSet() THEN
            REPEAT
                Commit();
                ClearLastError();
                ASNHeader2.GET(ASNHeader."Document Type", ASNHeader."No.");
                ProcessWasSuccess := EDIProcessAdvanceShippingNotice.RUN(ASNHeader2);
                IF NOT ProcessWasSuccess THEN
                    IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                        ASNHeader2.GET(ASNHeader."Document Type", ASNHeader."No.");

                        //TODO: EDI File Log
                        if ASNHeader2."EDI File Log Entry No." = 0 then
                            ASNHeader2.AddEDIFileLog();

                        ASNHeader2.VALIDATE(Status, ASNHeader2.Status::"Processing Error");
                        ASNHeader2.MODIFY(TRUE);

                    end else begin
                        //TODO: EDI File Log
                        if ASNHeader2."EDI File Log Entry No." = 0 then begin
                            ASNHeader2.Get(ASNHeader."Document Type", ASNHeader."No.");
                            if ASNHeader2.AddEDIFileLog() then
                                ASNHeader2.Modify();
                        end;

                    END;

                //PO,POX,POR,ASN,INV
                //TODO: EDI File Log
                if ASNHeader2."EDI File Log Entry No." <> 0 then
                    InsertEDIDocumentLog(ASNHeader2."EDI File Log Entry No.", 3, ProcessWhat, ProcessWasSuccess);

                Commit();

                IF (NOT ProcessWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                    EDIEmailMgt.SendASNProcessingFailureEmail(ASNHeader2, GetLastErrorText());

            UNTIL ASNHeader.Next() = 0;
    end;

    ///<Summary>
    ///Process ASN Header/Lines Scan Log to update quantity received is ASN Lines
    ///Status on ASN Header is changed to Scanned
    ///</Summary>    
    local procedure CopyScannedAdvanceShippingNotice()
    var
        ASNScanLog: Record "GXL ASN Header Scan Log";
        ASNScanLog2: Record "GXL ASN Header Scan Log";
        ASNHeader: Record "GXL ASN Header";
        EDICopyScannedASN: Codeunit "GXL EDI-Update ASN Scanned Qty";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        CopyScannedASNWasSuccess: Boolean;
    begin
        ASNScanLog.Reset();
        ASNScanLog.SETCURRENTKEY("Copied to ASN");
        ASNScanLog.SETRANGE("Copied to ASN", FALSE);
        IF ASNScanLog.FindSet() THEN
            REPEAT
                ClearLastError();
                ASNScanLog2.GET(ASNScanLog."Entry No.");
                IF ASNHeader.GET(ASNScanLog."Document Type", ASNScanLog."No.") THEN
                    IF ((ASNHeader.Status = ASNHeader.Status::Processed) AND (NOT ASNHeader."3PL EDI")) OR
                       ((ASNHeader.Status = ASNHeader.Status::"3PL ASN Sent") AND ASNHeader."3PL EDI") THEN BEGIN
                        Commit();
                        CopyScannedASNWasSuccess := EDICopyScannedASN.RUN(ASNScanLog2);
                        IF NOT CopyScannedASNWasSuccess THEN
                            IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                                //TODO: EDI File Log
                                if ASNHeader."EDI File Log Entry No." = 0 then
                                    ASNHeader.AddEDIFileLog();

                                ASNHeader.VALIDATE(Status, ASNHeader.Status::"Scan Process Error");
                                ASNHeader.MODIFY(TRUE);
                            end else begin
                                //TODO: EDI File Log
                                if ASNHeader."EDI File Log Entry No." = 0 then begin
                                    if ASNHeader.AddEDIFileLog() then
                                        ASNHeader.Modify();
                                end;
                            END;

                        //PO,POX,POR,ASN,INV
                        //TODO: EDI File Log
                        if ASNHeader."EDI File Log Entry No." <> 0 then
                            InsertEDIDocumentLog(ASNHeader."EDI File Log Entry No.", 3, ProcessWhat, CopyScannedASNWasSuccess);
                        Commit();

                        IF (NOT CopyScannedASNWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                            EDIEmailMgt.SendASNScanPocessFailureEmail(ASNHeader, GetLastErrorText());
                    END;
            UNTIL ASNScanLog.Next() = 0;
    end;

    ///<Summary>
    ///Process scanned ASN Header/Lines to receive the purchase order
    ///Status is changed to Received
    ///</Summary>
    local procedure ReceiveAdvanceShippingNotice()
    var
        ASNHeader: Record "GXL ASN Header";
        ASNHeader2: Record "GXL ASN Header";
        EDIReceiveASN: Codeunit "GXL EDI-Receive Adv. Ship. Not";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ReceiveASNWasSuccess: Boolean;
    begin
        ASNHeader.SETCURRENTKEY(Status);
        ASNHeader.SETRANGE(Status, ASNHeader.Status::Scanned);
        IF ASNHeader.FindSet() THEN
            REPEAT
                ClearLastError();
                ASNHeader2.GET(ASNHeader."Document Type", ASNHeader."No.");
                Commit();
                ReceiveASNWasSuccess := EDIReceiveASN.RUN(ASNHeader2);
                IF NOT ReceiveASNWasSuccess THEN
                    IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                        ASNHeader2.GET(ASNHeader."Document Type", ASNHeader."No.");
                        //TODO: EDI File Log
                        if ASNHeader2."EDI File Log Entry No." = 0 then
                            ASNHeader2.AddEDIFileLog();

                        ASNHeader2.VALIDATE(Status, ASNHeader2.Status::"Receiving Error");
                        ASNHeader2.MODIFY(TRUE);
                    end else begin
                        //TODO: EDI File Log
                        if ASNHeader2."EDI File Log Entry No." = 0 then begin
                            ASNHeader2.Get(ASNHeader."Document Type", ASNHeader."No.");
                            if ASNHeader2.AddEDIFileLog() then
                                ASNHeader2.Modify();
                        end;

                    END;

                //PO,POX,POR,ASN,INV
                //TODO: EDI File Log
                if ASNHeader2."EDI File Log Entry No." <> 0 then
                    InsertEDIDocumentLog(ASNHeader2."EDI File Log Entry No.", 3, ProcessWhat, ReceiveASNWasSuccess);

                Commit();

                IF ReceiveASNWasSuccess THEN BEGIN

                    EDIEmailMgt.SendASNReceivingDiscrepancyEmail(ASNHeader2, GetLastErrorText());

                END ELSE BEGIN

                    IF NOT IsLockingError(GetLastErrorCode()) THEN
                        EDIEmailMgt.SendASNReceivingFailureEmail(ASNHeader2, GetLastErrorText());

                END;

            UNTIL ASNHeader.Next() = 0;
    end;

    //#end region "ASN"

    //#region "ASN P2P"

    ///<Summary>
    ///Import ASN for P2P vendors
    ///</Summary>
    local procedure ImportAdvanceShippingNoticeP2PNonEDI()
    begin
        ImportFile(3, ProcessEDIVendorType::"Point 2 Point");
    end;

    ///<Summary>
    ///Process for PO which EDI Vendor Type is P2P contingency and PO Receive must be performed in MIM
    ///ASN Header/Lines and ASN Scan Log Heder/Lines will be created
    ///</Summary>
    local procedure InsertP2PContingencyASN()
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        PDACheckOrderStatus: Codeunit "GXL PDA-Check Order Status";
        P2PCreateASN: Codeunit "GXL P2P-Create ASN";
        ProcessWasSuccess: Boolean;
        DocumentNo: Code[20];
        EDIFileLogEntryNo: Integer;
        ImportWhich: Option PO,POX,POR,ASN,INV;
    begin
        DocumentNo := '';
        PDAPLReceiveBuffer.Reset();
        PDAPLReceiveBuffer.SETCURRENTKEY(Processed, Status, "Document No.");
        PDAPLReceiveBuffer.SETRANGE(Processed, FALSE);
        PDAPLReceiveBuffer.SETRANGE(Status, PDAPLReceiveBuffer.Status::Scanned);
        IF PDAPLReceiveBuffer.FindSet(TRUE, TRUE) THEN
            REPEAT
                IF IsNewDocument(PDAPLReceiveBuffer."Document No.", DocumentNo) THEN BEGIN
                    DocumentNo := PDAPLReceiveBuffer."Document No.";
                    IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, DocumentNo) THEN
                        IF (PurchaseHeader."GXL EDI Vendor Type" = PurchaseHeader."GXL EDI Vendor Type"::"Point 2 Point Contingency") THEN BEGIN
                            ClearLastError();
                            Commit();
                            CLEAR(PDACheckOrderStatus);
                            PDACheckOrderStatus.SetOptions(0, PurchaseHeader, TransferHeader);
                            IF PDACheckOrderStatus.RUN() THEN
                                IF PDACheckOrderStatus.GetResult() THEN BEGIN
                                    EDIFileLogEntryNo := InsertEDIFileLog2('', ImportWhich::ASN, 0, '', PurchaseHeader."GXL EDI Vendor Type");
                                    ClearLastError();
                                    CLEAR(P2PCreateASN);
                                    Commit();
                                    P2PCreateASN.SetOption(EDIFileLogEntryNo);
                                    ProcessWasSuccess := P2PCreateASN.RUN(PDAPLReceiveBuffer);
                                    UpdateEDIFileLog(EDIFileLogEntryNo, ProcessWasSuccess);
                                    IF (NOT ProcessWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                                        P2PCreateASN.UpdateLine(PDAPLReceiveBuffer, PDAPLReceiveBuffer.Status::"Processing Error", GetLastErrorText(), PurchaseHeader."Buy-from Vendor No.", EDIFileLogEntryNo, GetLastErrorCode());

                                    InsertEDIDocumentLog(EDIFileLogEntryNo, 3, ProcessWhat, ProcessWasSuccess);
                                    Commit();
                                    IF (NOT ProcessWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                                        EDIEmailMgt.SendPOScanPocessFailureEmail(PDAPLReceiveBuffer."Document No.", GetLastErrorText());
                                END;
                        END;
                END;
            UNTIL PDAPLReceiveBuffer.Next() = 0;
    end;

    //#end region "ASN P2P"

    //#region "ASN 3PL-EDI"

    ///<Summary>
    ///Import the ASN scan log files for "3PL EDI" locations and DC location only
    ///XML Port 50069 will be used for XML format
    ///</Summary>
    local procedure Import3PLEDIFile()
    var
        Location: Record Location;
        ASNHeaderScan: Record "GXL ASN Header Scan Log";
        ASNHeader: Record "GXL ASN Header";
        NameValueBuffer: Record "Name/Value Buffer" temporary;
        UnfilteredNameBuffer: Record "Name/Value Buffer" temporary;
        EDIImportFile: Codeunit "GXL EDI-Import File";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        FileManagement: Codeunit "File Management";
        MiscUtils: Codeunit "GXL Misc. Utilities";
        ImportWasSuccess: Boolean;
        EDIFileLogEntryNo: Integer;
        StoredFileName: Text;
        FilePrefix: Text;
        FileFormat: Text;
        FileSize: BigInteger;
        FileModifiedDate: Date;
        FileModifiedTime: Time;
        CurrFileName: Text;
    begin
        GetEDISetup();
        EDISetup.TESTFIELD("ASN File Name Prefix");
        FilePrefix := EDISetup."ASN File Name Prefix";
        Location.SETCURRENTKEY("GXL 3PL Warehouse", "GXL EDI Type");
        Location.SETRANGE("GXL 3PL Warehouse", TRUE);
        Location.SETRANGE("GXL EDI Type", Location."GXL EDI Type"::"3PL EDI");
        Location.SetFilter("GXL Inbound File Path", '<>%1', '');
        Location.SetAutoCalcFields("GXL Location Type");
        IF Location.FindSet() THEN
            REPEAT
                if (Location."GXL Location Type" = Location."GXL Location Type"::"3") then begin //DC
                    FileFormat := FORMAT(Location."GXL Receive File Format");
                    FileManagement.GetServerDirectoryFilesList(UnfilteredNameBuffer, Location."GXL Inbound File Path");
                    MiscUtils.FilterNameValueBuffer(UnfilteredNameBuffer, NameValueBuffer, EDISetup."ASN File Name Prefix", FileFormat);
                    IF NameValueBuffer.Find('-') then
                        repeat
                            CurrFileName := FileManagement.GetFileName(NameValueBuffer.Name);

                            ClearLastError();
                            EDIFileLogEntryNo := InsertEDIFileLog2(NameValueBuffer.Name, ProcessWhich, 0, '', ProcessEDIVendorType::VAN);
                            Commit();
                            CLEAR(EDIImportFile);
                            EDIImportFile.Set3PLOptions(NameValueBuffer.Name, Location."GXL Receive File Format", EDIFileLogEntryNo);
                            ImportWasSuccess := EDIImportFile.Run();
                            UpdateEDIFileLog(EDIFileLogEntryNo, ImportWasSuccess);

                            IF ImportWasSuccess THEN BEGIN
                                ImportWasSuccess := FALSE;
                                ASNHeaderScan.Reset();
                                ASNHeaderScan.SETCURRENTKEY("EDI File Log Entry No.");
                                ASNHeaderScan.SETRANGE("EDI File Log Entry No.", EDIFileLogEntryNo);
                                IF ASNHeaderScan.FindFirst() THEN BEGIN
                                    ASNHeader.GET(ASNHeader."Document Type"::Purchase, ASNHeaderScan."No.");
                                    MoveFile(NameValueBuffer.Name, GetFileName(FileManagement.CombinePath(Location."GXL 3PL Archive File Path", CurrFileName)), TRUE);
                                    ImportWasSuccess := TRUE;
                                    Update3PLEDIFileLog(ASNHeader."EDI File Log Entry No.", NameValueBuffer.Name);
                                    InsertEDIDocumentLog(ASNHeader."EDI File Log Entry No.", ProcessWhich, ProcessWhat, ImportWasSuccess);
                                END;
                            END;
                            IF (NOT ImportWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN BEGIN
                                FileManagement.GetServerFileProperties(NameValueBuffer.Name, FileModifiedDate, FileModifiedTime, FileSize);
                                StoredFileName := GetFileName(FileManagement.CombinePath(Location."GXL 3PL Error File Path", CurrFileName));
                                MoveFile(NameValueBuffer.Name, StoredFileName, TRUE);
                                Commit();
                                EDIEmailMgt.SendASNScanImportFailureEmail(Location, StoredFileName, CurrFileName, FileSize, GetLastErrorText());
                            END;
                        until NameValueBuffer.Next() = 0;
                end;
            UNTIL Location.Next() = 0;
    end;

    procedure SetAPILogEntry(InAPILog: Record "API Message Log")
    var
        outStm: OutStream;
    begin
        isAPI := true;

        APIMessageLogEntryNo := InAPILog."Entry No.";

        InAPILog.CalcFields("API Payload");

        XMLBlob.CreateOutStream(outStm);
        outStm.WriteText(InAPILog.PayloadToTextAsDecoded());

        if not XMLBlob.HasValue() then
            Error('API Message Log Payload Blob has no Value');
    end;

    local procedure Import3PLEDIFileForAPI()
    var
        APIMessageLog: Record "API Message Log";
        Location: Record Location;
        ASNHeaderScan: Record "GXL ASN Header Scan Log";
        ASNHeader: Record "GXL ASN Header";
        EDIImportFile: Codeunit "GXL EDI-Import File";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        FileManagement: Codeunit "File Management";
        MiscUtils: Codeunit "GXL Misc. Utilities";
        ImportWasSuccess: Boolean;
        EDIFileLogEntryNo: Integer;
        DummyFileName: Text;
    begin
        ClearLastError();

        GetEDISetup();

        APIMessageLog.Get(APIMessageLogEntryNo);
        APIMessageLog.SetRecFilter();
        APIMessageLog.FindFirst();

        APIMessageLog.TestField("Location Code");

        Location.get(APIMessageLog."Location Code");

        Location.SetRange(Code, APIMessageLog."Location Code");
        Location.SETCURRENTKEY("GXL 3PL Warehouse", "GXL EDI Type");
        Location.SETRANGE("GXL 3PL Warehouse", TRUE);
        Location.SETRANGE("GXL EDI Type", Location."GXL EDI Type"::"3PL EDI");
        Location.SetAutoCalcFields("GXL Location Type");
        Location.FindFirst();

        Location.TestField("GXL Location Type", Location."GXL Location Type"::"3"); // DC

        DummyFileName := StrSubstNo('API Message Log: %1', APIMessageLog."Entry No.");

        EDIFileLogEntryNo := InsertEDIFileLog2(DummyFileName, ProcessWhich, 0, '', ProcessEDIVendorType::VAN);
        Commit();
        CLEAR(EDIImportFile);

        EDIImportFile.Set3PLOptions(DummyFileName, Location."GXL Receive File Format", EDIFileLogEntryNo);
        EDIImportFile.SetAPILogEntry(APIMessageLog);
        ImportWasSuccess := EDIImportFile.Run();

        UpdateEDIFileLog(EDIFileLogEntryNo, ImportWasSuccess);

        IF ImportWasSuccess THEN BEGIN
            ImportWasSuccess := FALSE;
            ASNHeaderScan.Reset();
            ASNHeaderScan.SETCURRENTKEY("EDI File Log Entry No.");
            ASNHeaderScan.SETRANGE("EDI File Log Entry No.", EDIFileLogEntryNo);
            IF ASNHeaderScan.FindFirst() THEN BEGIN
                ASNHeader.GET(ASNHeader."Document Type"::Purchase, ASNHeaderScan."No.");
                ImportWasSuccess := TRUE;
                Update3PLEDIFileLog(ASNHeader."EDI File Log Entry No.", DummyFileName);
                InsertEDIDocumentLog(ASNHeader."EDI File Log Entry No.", ProcessWhich, ProcessWhat, ImportWasSuccess);
            END;
        END;
        IF (NOT ImportWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN BEGIN
            Commit();
            // COMMENTED FOR TESTING
            //EDIEmailMgt.SendASNScanImportFailureEmail(Location, DummyFileName, DummyFileName, 0, GetLastErrorText());
        END;
    end;
    //#end region "ASN 3PL-EDI"


    //#region "Invoice"

    ///<Summary>
    ///Import the invoice for VAN vendors
    ///INV Header/Lines will be created 
    ///</Summary>
    local procedure ImportInvoice()
    begin
        ImportFile(4, ProcessEDIVendorType::VAN);
    end;

    ///<Summary>
    ///Validate imported INV Header/Lines
    ///Status is changed to Validated
    ///</Summary>
    local procedure ValidateInvoice()
    var
        POINVHeader: Record "GXL PO INV Header";
        POINVHeader2: Record "GXL PO INV Header";
        EDIValidateInvoice: Codeunit "GXL EDI-Validate Invoice";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        P2PValidateInvoice: Codeunit "GXL P2P-Validate Invoice";
        ValidationWasSuccess: Boolean;
        PurchLine: Record "Purchase Line"; // >> 001 <<
    begin
        POINVHeader.SETCURRENTKEY("Purchase Order No.", Status);
        POINVHeader.SETRANGE(Status, POINVHeader.Status::Imported);
        IF POINVHeader.FindSet() THEN
            REPEAT
                // >> 001 LCB-1
                PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
                PurchLine.SetRange("Document No.", POINVHeader."Purchase Order No.");
                PurchLine.SetFilter("Quantity Received", '>%1', 0);
                IF NOT PurchLine.IsEmpty then begin
                    // << 001
                    IF CheckIfManualInvoiceExist(POINVHeader."No.") THEN BEGIN
                        EDIEmailMgt.SendINVManuallyPostedEmail(POINVHeader, STRSUBSTNO(Text50001Msg, POINVHeader."No.", POINVHeader."Purchase Order No."));
                    END ELSE
                        IF CheckIfValidateInvoice(POINVHeader) THEN BEGIN
                            IF CheckNAVDocumentNo(POINVHeader."Original EDI Document No.", POINVHeader."NAV EDI Document No.") THEN
                                EDIFunctionsLibrary.UpdateInvNAVEDIDocumentNo(POINVHeader);

                            ClearLastError();
                            Commit();
                            ClearLastError();
                            POINVHeader2.GET(POINVHeader."No.");

                            // >> 002
                            Clear(EDIValidateInvoice);
                            Clear(P2PValidateInvoice);
                            // << 002
                            IF POINVHeader."EDI Vendor Type" <> POINVHeader."EDI Vendor Type"::VAN THEN
                                ValidationWasSuccess := P2PValidateInvoice.RUN(POINVHeader2)
                            ELSE
                                ValidationWasSuccess := EDIValidateInvoice.RUN(POINVHeader2);

                            IF (NOT ValidationWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN BEGIN
                                POINVHeader2.GET(POINVHeader."No.");
                                ValidateInvoiceError(POINVHeader2);
                            END;

                            InsertEDIDocumentLog(POINVHeader."EDI File Log Entry No.", 4, ProcessWhat, ValidationWasSuccess);
                            Commit();

                            IF (NOT ValidationWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                                EDIEmailMgt.SendINVValidationFailureEmail(POINVHeader2, GetLastErrorText());
                        END;
                END;    // >> 001 <<
            UNTIL POINVHeader.Next() = 0;

    end;

    ///<Summary>
    ///Process validated INV Header/Lines
    ///Status is changed to Processed
    ///</Summary>
    local procedure ProcessInvoice()
    var
        POINVHeader: Record "GXL PO INV Header";
        POINVHeader2: Record "GXL PO INV Header";
        EDIProcessInvoice: Codeunit "GXL EDI-Process Invoice";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        P2PProcessInvoice: Codeunit "GXL P2P-Process Invoice";
        ProcessWasSuccess: Boolean;
    begin
        POINVHeader.SETCURRENTKEY(Status);
        POINVHeader.SETRANGE(Status, POINVHeader.Status::Validated);

        IF POINVHeader.FindSet() THEN
            REPEAT
                Commit();
                ClearLastError();
                POINVHeader2.GET(POINVHeader."No.");
                IF POINVHeader."EDI Vendor Type" <> POINVHeader."EDI Vendor Type"::VAN THEN
                    ProcessWasSuccess := P2PProcessInvoice.RUN(POINVHeader2)
                ELSE
                    ProcessWasSuccess := EDIProcessInvoice.RUN(POINVHeader2);
                IF NOT ProcessWasSuccess THEN
                    IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                        POINVHeader2.GET(POINVHeader."No.");
                        POINVHeader2.VALIDATE(Status, POINVHeader2.Status::"Processing Error");
                        POINVHeader2.MODIFY(TRUE);
                    END;
                //PO,POX,POR,ASN,INV
                InsertEDIDocumentLog(POINVHeader."EDI File Log Entry No.", 4, ProcessWhat, ProcessWasSuccess);

                Commit();

                IF (NOT ProcessWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                    EDIEmailMgt.SendINVProcessingFailureEmail(POINVHeader2, GetLastErrorText());

            UNTIL POINVHeader.Next() = 0;
    end;

    ///<Summary>
    ///Post return credit for claimable EDI
    ///Status is changed to Return Credit Posted
    ///</Summary>
    local procedure PostReturnCredit()
    var
        POINVHeader: Record "GXL PO INV Header";
        POINVHeader2: Record "GXL PO INV Header";
        EDIClaimEntry: Record "GXL EDI Claim Entry";
        ASNHeader: Record "GXL ASN Header";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        EDICreatePostPurchRet: Codeunit "GXL EDI-Cr+Post Pur. Ret. Ord.";
        ProcessWasSuccess: Boolean;
    begin
        POINVHeader.SETCURRENTKEY(Status, "No Claim");
        POINVHeader.SETRANGE(Status, POINVHeader.Status::Processed);
        POINVHeader.SETRANGE("No Claim", FALSE);

        IF POINVHeader.FindSet() THEN
            REPEAT

                ClearLastError();
                EDIClaimEntry.SETRANGE("ASN Document Type", EDIClaimEntry."ASN Document Type"::Purchase);
                EDIClaimEntry.SETRANGE("ASN Document No.", POINVHeader."ASN Number");
                IF EDIClaimEntry.FindFirst() THEN BEGIN
                    IF EDIClaimEntry."Posted Return Shipment No." = '' THEN
                        EXIT;
                    ASNHeader.SETRANGE("Document Type", ASNHeader."Document Type"::Purchase);
                    ASNHeader.SETRANGE("No.", POINVHeader."ASN Number");
                    IF ASNHeader.FindFirst() THEN BEGIN
                        Commit();
                        EDICreatePostPurchRet.SetEDIOptions(4);
                        ProcessWasSuccess := EDICreatePostPurchRet.RUN(ASNHeader);
                        IF NOT ProcessWasSuccess THEN BEGIN
                            IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                                POINVHeader2.GET(POINVHeader."No.");
                                POINVHeader2.VALIDATE(Status, POINVHeader2.Status::"Return Credit Posting Error");
                                POINVHeader2.MODIFY(TRUE);
                            END;
                        END ELSE BEGIN
                            POINVHeader2.GET(POINVHeader."No.");
                            POINVHeader2.VALIDATE(Status, POINVHeader2.Status::"Return Credit Posted");
                            IF POINVHeader2."Manual Processing Status" = POINVHeader2."Manual Processing Status"::Created THEN
                                POINVHeader2."Manual Processing Status" := POINVHeader2."Manual Processing Status"::Closed;
                            POINVHeader2.MODIFY(TRUE);
                        END;

                        //PO,POX,POR,ASN,INV
                        InsertEDIDocumentLog(POINVHeader."EDI File Log Entry No.", 4, ProcessWhat, ProcessWasSuccess);

                        Commit();

                        IF ProcessWasSuccess THEN BEGIN

                            EDIEmailMgt.SendINVCreditNotificationEmail(POINVHeader2, GetLastErrorText());

                        END ELSE BEGIN

                            IF NOT IsLockingError(GetLastErrorCode()) THEN
                                EDIEmailMgt.SendINVCreditNotificationEmail(POINVHeader2, GetLastErrorText());

                        END;
                    END;
                END;
            UNTIL POINVHeader.Next() = 0;
    end;
    //#end region "Invoice"

    //#region "Invoice P2P"

    ///<Summary>
    ///Import the invoice for P2P vendors
    ///XML Port 50356 will be used
    ///EDI-Purchase Messages will be created
    ///</Summary>
    local procedure ImportInvoiceP2PNonEDI()
    begin
        ImportFile(4, ProcessEDIVendorType::"Point 2 Point");
        InsertInvoiceP2PNonEDI(4);
    end;

    ///<Summary>
    ///Import the invoice for P2P vendors
    ///create INV Header/Lines basing on EDI-Purchase Messages
    ///</Summary>
    local procedure InsertInvoiceP2PNonEDI(ImportWhich: Integer)
    var
        EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
        EDIPurchaseMessages2: Record "GXL EDI-Purchase Messages";
        EDIFileLog: Record "GXL EDI File Log";
        P2PCreateInvoice: Codeunit "GXL P2P-Create Invoice";
        InsertWasSuccess: Boolean;
        LastDocumentNo: Code[20];
        EDIFileLogEntryNo: Integer;
    begin
        EDIPurchaseMessages.SETCURRENTKEY(Status, ImportDoc, DocumentNumber);
        EDIPurchaseMessages.SETRANGE(Status, EDIPurchaseMessages.Status::Imported);
        EDIPurchaseMessages.SETRANGE(ImportDoc, EDIPurchaseMessages.ImportDoc::"2"); //Invoice
        IF EDIPurchaseMessages.FindSet(TRUE, TRUE) THEN
            REPEAT
                IF LastDocumentNo <> EDIPurchaseMessages.DocumentNumber THEN BEGIN
                    EDIFileLog.GET(EDIPurchaseMessages."EDI File Log Entry No.");
                    EDIFileLogEntryNo := InsertEDIFileLog2(EDIFileLog."File Name", ImportWhich, 0, '', GetPOEDIVendorType(EDIPurchaseMessages.DocumentNumber, EDIPurchaseMessages."Vendor No."));
                    LastDocumentNo := EDIPurchaseMessages.DocumentNumber;
                    EDIPurchaseMessages2 := EDIPurchaseMessages;
                    ClearLastError();
                    Commit();
                    P2PCreateInvoice.SetOption(EDIFileLogEntryNo);
                    InsertWasSuccess := P2PCreateInvoice.RUN(EDIPurchaseMessages2);
                    IF (NOT InsertWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN BEGIN
                        UpdateEDIFileLog(EDIFileLogEntryNo, InsertWasSuccess);
                    END ELSE BEGIN
                        //update log 1
                        UpdateEDIFileLog(EDIFileLogEntryNo, InsertWasSuccess);
                        InsertEDIDocumentLog(EDIFileLogEntryNo, 4, ProcessWhat, InsertWasSuccess);
                    END;
                    Commit();
                END;
            UNTIL EDIPurchaseMessages.Next() = 0;
    end;
    //#end region "Invoice P2P"


    local procedure InsertEDIFileLog(FullFileName: Text; Which: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS,IPOR): Integer
    begin
        EXIT(InsertEDIFileLog2(FullFileName, Which, 0, '', 0));
    end;

    procedure UpdateEDIFileLog(EDILogEntryNo: Integer; ImportWasSuccess: Boolean)
    begin
        UpdateEDIFileLog2(EDILogEntryNo, ImportWasSuccess, '');
    end;

    procedure InsertEDIDocumentLog(EDIFileLogEntryNo: Integer; InputProcessWhich: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS,IPOR; InputProcessWhat: Option "Validate and Export",Import,Validate,Process,Scan,Receive,"Create Return Order","Apply Return Order","Post Return Shipment","Post Return Credit"; ImportExportWasSuccess: Boolean)
    begin
        InsertEDIDocumentLog2(EDIFileLogEntryNo, InputProcessWhich, InputProcessWhat, ImportExportWasSuccess, 1);
    end;

    local procedure GetEDIFileLogDocumentType(Which: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS,IPOR): Integer
    begin
        CASE Which OF

            Which::PO:
                EXIT(1);

            Which::POX:
                EXIT(2);

            Which::POR:
                EXIT(3);

            Which::ASN:
                EXIT(4);

            Which::INV:
                EXIT(5);

            Which::STKADJ:
                EXIT(6);

            Which::SHIPSTATUS:
                EXIT(7);

            Which::IPOR:
                EXIT(2);
            ELSE
                EXIT(0);

        END;
    end;

    local procedure GetPurchaseOrder(EDIFileLogEntryNo: Integer; var PurchaseHeader: Record "Purchase Header")
    var
        EDIFileLog: Record "GXL EDI File Log";
        PurchaseHeader2: Record "Purchase Header";
        FileManagement: Codeunit "File Management";
        DocumentNo: Code[20];
        DotPosition: Integer;
        StartAtPosition: Integer;
        DocumentNoLength: Integer;
        FileName: Text;
    begin
        PurchaseHeader2.SETCURRENTKEY("GXL EDI PO File Log Entry No.");
        PurchaseHeader2.SETRANGE("GXL EDI PO File Log Entry No.", EDIFileLogEntryNo);
        IF PurchaseHeader2.FindFirst() THEN
            PurchaseHeader := PurchaseHeader2
        ELSE
            IF EDIFileLog.GET(EDIFileLogEntryNo) THEN
                IF EDIFileLog."File Name" <> '' THEN BEGIN
                    GetEDISetup();

                    FileName := FileManagement.GetFileName(EDIFileLog."File Name");
                    DotPosition := STRPOS(FileName, '.');
                    IF DotPosition > 0 THEN BEGIN
                        StartAtPosition := STRLEN(EDISetup."PO File Name Prefix") + 1;
                        DocumentNoLength := DotPosition - StartAtPosition;
                        IF DocumentNoLength > 0 THEN
                            DocumentNo := COPYSTR(FileName, StartAtPosition, DotPosition - StartAtPosition);
                    END;

                    IF DocumentNo <> '' THEN
                        IF PurchaseHeader2.GET(PurchaseHeader2."Document Type"::Order, DocumentNo) THEN
                            PurchaseHeader := PurchaseHeader2;
                END;
    end;

    local procedure GetPurchaseOrderResponse(EDIFileLogEntryNo: Integer; var POResponseHeader: Record "GXL PO Response Header")
    var
        POResponseHeader2: Record "GXL PO Response Header";
    begin
        POResponseHeader2.SETCURRENTKEY("EDI File Log Entry No.");
        POResponseHeader2.SETRANGE("EDI File Log Entry No.", EDIFileLogEntryNo);
        IF POResponseHeader2.FindFirst() THEN
            POResponseHeader := POResponseHeader2;
    end;

    local procedure GetAdvanceShippingNotice(EDIFileLogEntryNo: Integer; var ASNHeader: Record "GXL ASN Header")
    var
        ASNHeader2: Record "GXL ASN Header";
    begin
        ASNHeader2.SETCURRENTKEY("EDI File Log Entry No.");
        ASNHeader2.SETRANGE("EDI File Log Entry No.", EDIFileLogEntryNo);
        IF ASNHeader2.FindFirst() THEN
            ASNHeader := ASNHeader2;
    end;

    local procedure GetInvoice(EDIFileLogEntryNo: Integer; var POINVHeader: Record "GXL PO INV Header")
    var
        POINVHeader2: Record "GXL PO INV Header";
    begin
        POINVHeader2.SETCURRENTKEY("EDI File Log Entry No.");
        POINVHeader2.SETRANGE("EDI File Log Entry No.", EDIFileLogEntryNo);
        IF POINVHeader2.FindFirst() THEN
            POINVHeader := POINVHeader2;
    end;

    local procedure ClearEDIFileLog()
    var
        EDIFileLog: Record "GXL EDI File Log";
        EDILib: Codeunit "GXL EDI Functions Library";
        EmptyDateFormula: DateFormula;
        DeletionDateFormula: DateFormula;
        OK: Boolean;
    begin
        GetEDISetup();
        IF EDISetup."Staging Table Age for Deletion" <> EmptyDateFormula THEN BEGIN

            DeletionDateFormula := EDISetup."Staging Table Age for Deletion";
            EDILib.NegateDateFormula(DeletionDateFormula);  // VAR

            EDIFileLog.SETCURRENTKEY("Date/Time");
            EDIFileLog.SETRANGE("Date/Time", 0DT, CREATEDATETIME(CALCDATE(DeletionDateFormula, Today()), 0T));
            IF EDIFileLog.FindSet() THEN
                REPEAT
                    OK := EDIFileLog.Delete();
                UNTIL EDIFileLog.Next() = 0;

        END;
    end;

    local procedure ClearEDIDocumentLog()
    var
        EDIDocumentLog: Record "GXL EDI Document Log";
        EDILib: Codeunit "GXL EDI Functions Library";
        EmptyDateFormula: DateFormula;
        DeletionDateFormula: DateFormula;
        OK: Boolean;
    begin
        GetEDISetup();
        IF EDISetup."Staging Table Age for Deletion" <> EmptyDateFormula THEN BEGIN

            DeletionDateFormula := EDISetup."Staging Table Age for Deletion";
            EDILib.NegateDateFormula(DeletionDateFormula);  // VAR

            EDIDocumentLog.SETCURRENTKEY(Status, "Date/Time");
            EDIDocumentLog.SETFILTER(Status, '%1|%2|%3',
              EDIDocumentLog.Status::"Return Credit Posted",
              EDIDocumentLog.Status::"Completed without Posting Return Credit",
              EDIDocumentLog.Status::"Journal Posted");
            EDIDocumentLog.SETRANGE("Date/Time", 0DT, CREATEDATETIME(CALCDATE(DeletionDateFormula, Today()), 0T));
            IF EDIDocumentLog.FindSet() THEN
                REPEAT
                    OK := EDIDocumentLog.Delete();
                UNTIL EDIDocumentLog.Next() = 0;

        END;
    end;

    local procedure PurchaseOrderQualifiesForExport(PurchaseHeader: Record "Purchase Header"; var ForCancellation: Boolean) PurchaseHeaderQualifies: Boolean
    var
        IsManualOrder: Boolean;
        IsJDAOrder: Boolean;
        Vendor: Record Vendor;
    begin
        ForCancellation := FALSE;
        IsJDAOrder := PurchaseHeader."GXL Order Type" = PurchaseHeader."GXL Order Type"::JDA; // >> HP2-SPRINT2 <<
        IsManualOrder := PurchaseHeader."GXL Manual PO" AND (PurchaseHeader."GXL Order Type" = PurchaseHeader."GXL Order Type"::Manual);

        if Vendor.Get(PurchaseHeader."Buy-from Vendor No.") then; // >> HP2-SPRINT2 <<
        //TODO: Order Status - Check purchase order is qulified for export, only Created or Cancelled are exported
        IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Created THEN
            // >> HPH 2-SPRINT2
            // PurchaseHeaderQualifieslifies :=  IsJDAOrder OR IsManualOrder
            PurchaseHeaderQualifies := IsJDAOrder OR IsManualOrder
        // << HP2-SPRINT2 
        ELSE BEGIN
            PurchaseHeaderQualifies :=
                // >> HP2-SPRINT2 - SPR
                //   IsManualOrder AND
                (IsManualOrder or IsJDAOrder) AND
               // << HP2-SPRINT2
               (PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Cancelled) AND
               (NOT PurchaseHeader."GXL Cancelled via EDI") AND
               (not Vendor."GXL EDI Cancel") AND // >> HP2-SPRINT2 <<
               (PurchaseHeader."GXL Last EDI Document Status" = PurchaseHeader."GXL Last EDI Document Status"::" ") OR
               (PurchaseHeader."GXL Last EDI Document Status" = PurchaseHeader."GXL Last EDI Document Status"::PO) OR
               (PurchaseHeader."GXL Last EDI Document Status" = PurchaseHeader."GXL Last EDI Document Status"::POR) AND
             (PurchaseHeader."GXL EDI PO File Log Entry No." > 0);
            ForCancellation := PurchaseHeaderQualifies;
        END;
    end;

    local procedure UpdatePurchaseHeader(var PurchaseHeader: Record "Purchase Header"; EDIFileLogEntryNo: Integer; NewStatus: Option " ",PO,POX,POR,ASN,INV,Cancelled)
    var
        SCPurchaseOrderStatusMgt: Codeunit "GXL SC-Purch. Order Status Mgt";
    begin
        IF NewStatus = NewStatus::PO THEN BEGIN
            PurchaseHeader.VALIDATE("GXL EDI PO File Log Entry No.", EDIFileLogEntryNo);
            SCPurchaseOrderStatusMgt.Place(PurchaseHeader);
        END;

        PurchaseHeader.VALIDATE("GXL Last EDI Document Status", NewStatus);
        PurchaseHeader.MODIFY(TRUE);
    end;

    local procedure GetXmlFileExtension(): Text
    begin
        EXIT('xml');
    end;

    local procedure GetFileName(ArchiveFileName: Text) NewArchiveFileName: Text
    var
        FileMgt: Codeunit "File Management";
    begin
        NewArchiveFileName := ArchiveFileName;
        IF FIleMgt.ServerFileExists(ArchiveFileName) THEN begin
            NewArchiveFileName :=
              FileMgt.CombinePath(
                FileMgt.GetDirectoryName(ArchiveFileName),
                STRSUBSTNO('%1_%2.%3',
                  FileMgt.GetFileNameWithoutExtension(ArchiveFileName),
                  FORMAT(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>T<Hours24,2><Minutes,2><Seconds,2><Thousands>'),
                  FileMgt.GetExtension(ArchiveFileName)));
        end;
    end;

    local procedure GetSourceFileName(InputEDIFileLogEntryNo: Integer): Text
    var
        EDIFileLog: Record "GXL EDI File Log";
    begin
        EDIFileLog.GET(InputEDIFileLogEntryNo);

        EXIT(EDIFileLog."File Name");
    end;

    local procedure MoveFile(SourceFileName: Text; TargetFileName: Text; DeleteSourceFile: Boolean)
    var
    begin
        EDIFunctionsLibrary.MoveFile(SourceFileName, TargetFileName, DeleteSourceFile);
    end;

    procedure IsLockingError(LockStr: Text): Boolean
    var
        PrismMiscUtils: Codeunit "GXL Misc. Utilities";
    begin
        EXIT(PrismMiscUtils.IsLockingError(LockStr));
    end;

    local procedure ValidateInvoiceError(var POINVHeader: Record "GXL PO INV Header")
    var
        EDIFunctions: Codeunit "GXL EDI Functions Library";
    begin
        IF STRPOS(GetLastErrorText(), EDIFunctions.GetOnHoldErrorCode()) <> 0 THEN BEGIN
            POINVHeader."On Hold" := TRUE;
            POINVHeader."On Hold From" := CurrentDateTime();
        END ELSE BEGIN
            IF STRPOS(GetLastErrorText(), EDIFunctions.GetPriceDiscrepancyErrorCode()) <> 0 THEN
                POINVHeader."Allow Manual Acceptance" := TRUE;
            POINVHeader."On Hold" := FALSE;
            POINVHeader."On Hold From" := 0DT;
        END;
        POINVHeader.Status := POINVHeader.Status::"Validation Error";
        POINVHeader.Modify();
    end;

    //#region "Claimable"
    local procedure CreateReturnOrder()
    var
        ASNHeader: Record "GXL ASN Header";
        ASNHeader2: Record "GXL ASN Header";
        EDIClaimEntry: Record "GXL EDI Claim Entry";
        EDICreatePostPurRetOrd: Codeunit "GXL EDI-Cr+Post Pur. Ret. Ord.";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
    begin
        ASNHeader.SETCURRENTKEY(Status, "No Claim");
        ASNHeader.SETRANGE(Status, ASNHeader.Status::Received);
        ASNHeader.SETRANGE("No Claim", FALSE);
        IF ASNHeader.FindSet() THEN
            REPEAT
                ClearLastError();
                ASNHeader2.GET(ASNHeader."Document Type", ASNHeader."No.");
                EDIClaimEntry.Reset();
                EDIClaimEntry.SETRANGE("ASN Document No.", ASNHeader."No.");
                EDIClaimEntry.SETRANGE("ASN Document Type", ASNHeader."Document Type");
                IF not EDIClaimEntry.IsEmpty() THEN BEGIN
                    //',Create Return Order,Apply Return Order,Post Return Shipment,Post Return Credit'
                    EDICreatePostPurRetOrd.SetEDIOptions(1);
                    ProcessWasSuccess := EDICreatePostPurRetOrd.RUN(ASNHeader2);
                    IF NOT ProcessWasSuccess THEN
                        IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                            ASNHeader2.GET(ASNHeader."Document Type", ASNHeader."No.");
                            //TODO: EDI File Log
                            if ASNHeader2."EDI File Log Entry No." = 0 then
                                ASNHeader2.AddEDIFileLog();

                            ASNHeader2.VALIDATE(Status, ASNHeader2.Status::"Return Order Creation Error");
                            ASNHeader2.MODIFY(TRUE);
                        END;

                    //PO,POX,POR,ASN,INV
                    //TODO: EDI File Log
                    if ASNHeader2."EDI File Log Entry No." <> 0 then
                        InsertEDIDocumentLog(ASNHeader2."EDI File Log Entry No.", 3, ProcessWhat, ProcessWasSuccess);

                    IF (NOT ProcessWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN BEGIN
                        Commit();
                        EDIEmailMgt.SendASNReturnOrderCreationFailureEmail(ASNHeader2, GetLastErrorText());
                    END;
                END ELSE BEGIN
                    ASNHeader2."No Claim" := TRUE;
                    ASNHeader2.Modify();
                END;
                Commit();
            UNTIL ASNHeader.Next() = 0;
    end;

    local procedure ApplyReturnOrder()
    var
        ASNHeader: Record "GXL ASN Header";
        ASNHeader2: Record "GXL ASN Header";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        EDICreatePostPurRetOrd: Codeunit "GXL EDI-Cr+Post Pur. Ret. Ord.";
        ProcessWasSuccess: Boolean;
    begin
        ASNHeader.SETCURRENTKEY(Status);
        ASNHeader.SETRANGE(Status, ASNHeader.Status::"Return Order Created");
        IF ASNHeader.FindSet() THEN
            REPEAT

                // >> Issue with runmodal error
                Commit;
                // << Issue with runmodal error

                ClearLastError();

                ASNHeader2.GET(ASNHeader."Document Type", ASNHeader."No.");
                EDICreatePostPurRetOrd.SetEDIOptions(2);
                ProcessWasSuccess := EDICreatePostPurRetOrd.RUN(ASNHeader2);
                IF NOT ProcessWasSuccess THEN
                    IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                        ASNHeader2.GET(ASNHeader."Document Type", ASNHeader."No.");
                        //TODO: EDI File Log
                        if ASNHeader2."EDI File Log Entry No." = 0 then
                            ASNHeader2.AddEDIFileLog();

                        ASNHeader2.VALIDATE(Status, ASNHeader2.Status::"Return Order Application Error");
                        ASNHeader2.MODIFY(TRUE);
                    END;

                //PO,POX,POR,ASN,INV
                //TODO: EDI File Log
                if ASNHeader2."EDI File Log Entry No." <> 0 then
                    InsertEDIDocumentLog(ASNHeader2."EDI File Log Entry No.", 3, ProcessWhat, ProcessWasSuccess);

                Commit();

                IF (NOT ProcessWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                    EDIEmailMgt.SendASNReturnOrderApplicationFailureEmail(ASNHeader2, GetLastErrorText());

            UNTIL ASNHeader.Next() = 0;
    end;

    local procedure PostReturnShipment()
    var
        ASNHeader: Record "GXL ASN Header";
        ASNHeader2: Record "GXL ASN Header";
        TempASNHeader: Record "GXL ASN Header" temporary;
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        EDICreatePostPurRetOrd: Codeunit "GXL EDI-Cr+Post Pur. Ret. Ord.";
        ProcessWasSuccess: Boolean;
    begin
        //Loop [ASN Header] records where "Status" = Return Order Created AND "Manual Application" = TRUE
        ASNHeader.SETCURRENTKEY(Status);
        ASNHeader.SETRANGE(Status, ASNHeader.Status::"Return Order Application Error");
        ASNHeader.SETRANGE("Manual Application", TRUE);
        IF ASNHeader.FindSet() THEN
            REPEAT
                TempASNHeader.Reset();
                TempASNHeader.TRANSFERFIELDS(ASNHeader);
                TempASNHeader.Insert();
            UNTIL ASNHeader.Next() = 0;

        //Loop [ASN Header] records where "Status" = Return Order Applied

        ASNHeader.Reset();
        ASNHeader.SETCURRENTKEY(Status);
        ASNHeader.SETRANGE(Status, ASNHeader.Status::"Return Order Applied");
        IF ASNHeader.FindSet() THEN
            REPEAT
                TempASNHeader.Reset();
                TempASNHeader.TRANSFERFIELDS(ASNHeader);
                TempASNHeader.Insert();
            UNTIL ASNHeader.Next() = 0;

        TempASNHeader.Reset();
        IF TempASNHeader.FindSet() THEN
            REPEAT
                ClearLastError();
                Commit();
                ASNHeader.Reset();
                ASNHeader.GET(TempASNHeader."Document Type", TempASNHeader."No.");
                EDICreatePostPurRetOrd.SetEDIOptions(3);
                ProcessWasSuccess := EDICreatePostPurRetOrd.RUN(ASNHeader);
                IF NOT ProcessWasSuccess THEN
                    IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                        ASNHeader2.Reset();
                        ASNHeader2.GET(TempASNHeader."Document Type", TempASNHeader."No.");
                        //TODO: EDI File Log
                        if ASNHeader2."EDI File Log Entry No." = 0 then
                            ASNHeader2.AddEDIFileLog();
                        ASNHeader2.VALIDATE(Status, ASNHeader2.Status::"Return Shipment Posting Error");
                        ASNHeader2.MODIFY(TRUE);
                    END;

                //PO,POX,POR,ASN,INV
                //TODO: EDI File Log
                if ASNHeader2."EDI File Log Entry No." <> 0 then
                    InsertEDIDocumentLog(ASNHeader2."EDI File Log Entry No.", 3, ProcessWhat, ProcessWasSuccess);

                Commit();

                IF (NOT ProcessWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                    EDIEmailMgt.SendASNReturnOrderReturnShipmentFailureEmail(ASNHeader2, GetLastErrorText());

            UNTIL TempASNHeader.Next() = 0;
    end;
    //#end region "Claimable"

    local procedure ValidateExportPurchaseOrdersP2PNonEDI(ExportWhich: Option PO,POX,POR,ASN,INV)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeader2: Record "Purchase Header";
    begin
        //TODO: Order Status - Export non-EDI orders with status=Created
        PurchaseHeader.SETCURRENTKEY("GXL EDI Order", "GXL Vendor File Exchange", "GXL Order Status");
        PurchaseHeader.SETRANGE("GXL EDI Order", FALSE);
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SETRANGE("GXL Order Status", PurchaseHeader."GXL Order Status"::Created);
        IF PurchaseHeader.FindSet() THEN
            REPEAT
                PurchaseHeader2 := PurchaseHeader;
                ValidateExportPurchaseOrderP2PNonEDI(PurchaseHeader2, ExportWhich, FALSE, FALSE);
            UNTIL PurchaseHeader.Next() = 0;
    end;

    local procedure ValidateExportPurchaseOrderP2PNonEDI(var PurchaseHeader: Record "Purchase Header"; ExportWhich: Option PO,POX,POR,ASN,INV; Manual: Boolean; CalledFromPage: Boolean): Boolean
    var
        Vendor: Record Vendor;
        P2PExportValidatePurOrder: Codeunit "GXL P2P-Export+Val. Pur. Order";
        FileMgt: Codeunit "File Management";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ValueRetention: Codeunit "GXL WMS Single Instance";
        NonEDI: Boolean;
        ExportWasSuccess: Boolean;
        IsLogged: Boolean;
        InsertLog: Boolean;
        EDIFileLogEntryNo: Integer;
        FilePath: Text;
        ArchiveFilePath: Text;
    begin
        IF Vendor.GET(PurchaseHeader."Buy-from Vendor No.") THEN BEGIN

            ClearLastError();

            NonEDI := (Vendor."GXL PO Email Address" <> '') OR (Vendor."E-Mail" <> '');

            IsLogged := (PurchaseHeader."GXL EDI PO File Log Entry No." <> 0);

            InsertLog := NOT (NonEDI AND IsLogged AND Manual);//if it's non edi and manual and already logged - don't log again

            IF InsertLog THEN
                EDIFileLogEntryNo := InsertEDIFileLog2('', ExportWhich, 0, '', PurchaseHeader."GXL EDI Vendor Type");
            Commit();

            CLEAR(P2PExportValidatePurOrder);
            P2PExportValidatePurOrder.SetOptions(NonEDI, EDIFileLogEntryNo, Manual, IsLogged, CalledFromPage);
            // >> HP2-SPRINT2
            //ValueRetention.SetFilePath('');
            ValueRetention.SetVendorExportFileName('');
            // << HP2-SPRINT2
            ExportWasSuccess := P2PExportValidatePurOrder.RUN(PurchaseHeader);
            // >> HP2-SPRINT2
            // FilePath := ValueRetention.GetFilePath();
            //  ValueRetention.SetFilePath('');
            FilePath := ValueRetention.GetVendorExportFileName();
            ValueRetention.SetVendorExportFileName('');
            // << HP2-SPRINT2 
            IF ExportWasSuccess AND
              (Vendor."GXL EDI Vendor Type" IN [Vendor."GXL EDI Vendor Type"::"Point 2 Point", Vendor."GXL EDI Vendor Type"::"Point 2 Point Contingency"])
            THEN BEGIN
                Vendor."GXL EDI Archive Directory" := GetDirectory(Vendor."GXL EDI Archive Directory", 2, Vendor."GXL EDI Vendor Type");
                ArchiveFilePath := GetFileName(FileMgt.CombinePath(Vendor."GXL EDI Archive Directory", FileMgt.GetFileName(FilePath)));
                MoveFile(FilePath, ArchiveFilePath, FALSE);
            END;

            //update log 1
            IF InsertLog THEN
                UpdateEDIFileLog2(EDIFileLogEntryNo, ExportWasSuccess, ArchiveFilePath);

            //update log 2
            IF InsertLog THEN
                InsertEDIDocumentLog(EDIFileLogEntryNo, ExportWhich, ProcessWhat, ExportWasSuccess);

            Commit();

            IF NOT ExportWasSuccess THEN
                EDIEmailMgt.SendPOExportFailureEmail(PurchaseHeader, GetLastErrorText());

            EXIT(ExportWasSuccess);

        END;
    end;

    local procedure UpdateEDIFileLog2(EDILogEntryNo: Integer; ImportWasSuccess: Boolean; FileName: Text)
    var
        EDIFileLog: Record "GXL EDI File Log";
    begin
        IF EDIFileLog.GET(EDILogEntryNo) THEN BEGIN

            EDIFileLog."Date/Time" := CurrentDateTime();
            IF FileName <> '' THEN
                EDIFileLog."File Name" := FileName;

            IF NOT ImportWasSuccess THEN BEGIN

                EDIFileLog.Status := EDIFileLog.Status::Error;
                EDIFileLog."Error Code" := COPYSTR(GetLastErrorCode(), 1, MAXSTRLEN(EDIFileLog."Error Code"));
                EDIFileLog.SetErrorMessage(GetLastErrorText());

            END ELSE
                EDIFileLog.Status := EDIFileLog.Status::Success;

            EDIFileLog.Modify();

        END;
    end;

    //Force create EDI File Log
    procedure InsertEDIFileLog3(FullFileName: Text; Which: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS,IPOR; StockAdjustmentClaimDocumentType: Option " ",PO,PI,STO,"STO-SHIP","STO-REC"; StockAdjustmentClaimDocumentNo: Code[20]; EDIVendorType: Option " ","Point 2 Point",VAN,"3PL Supplier"): Integer
    var
        EDIFileLog: Record "GXL EDI File Log";
    begin
        ClearEDIFileLog();

        EDIFileLog.Init();
        EDIFileLog."Entry No." := 0;
        EDIFileLog."Date/Time" := CurrentDateTime();
        EDIFileLog."Document Type" := GetEDIFileLogDocumentType(Which);
        EDIFileLog."File Name" := CopyStr(FullFileName, 1, MaxStrLen(EDIFileLog."File Name"));
        EDIFileLog.Status := EDIFileLog.Status::Success;
        EDIFileLog."Stock Adj. Claim Document Type" := StockAdjustmentClaimDocumentType;
        EDIFileLog."Stock Adj. Claim Order No." := StockAdjustmentClaimDocumentNo;
        EDIFileLog."EDI Vendor Type" := EDIVendorType;

        EDIFileLog.INSERT(TRUE);

        EXIT(EDIFileLog."Entry No.");

    end;

    procedure InsertEDIFileLog2(FullFileName: Text; Which: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS,IPOR; StockAdjustmentClaimDocumentType: Option " ",PO,PI,STO,"STO-SHIP","STO-REC"; StockAdjustmentClaimDocumentNo: Code[20]; EDIVendorType: Option " ","Point 2 Point",VAN,"3PL Supplier"): Integer
    var
        EDIFileLog: Record "GXL EDI File Log";
        ExistingEDIFileLogEntryNo: Integer;
    begin
        ClearEDIFileLog();

        ExistingEDIFileLogEntryNo :=
          FindOpenLogEntry(FullFileName, Which, StockAdjustmentClaimDocumentType, StockAdjustmentClaimDocumentNo, EDIVendorType);

        IF ExistingEDIFileLogEntryNo > 0 THEN
            EXIT(ExistingEDIFileLogEntryNo);

        EDIFileLog.Init();
        EDIFileLog."Entry No." := 0;
        EDIFileLog."Date/Time" := CurrentDateTime();
        EDIFileLog."Document Type" := GetEDIFileLogDocumentType(Which);
        EDIFileLog."File Name" := CopyStr(FullFileName, 1, MaxStrLen(EDIFileLog."File Name"));
        EDIFileLog.Status := EDIFileLog.Status::"In Process";
        EDIFileLog."Stock Adj. Claim Document Type" := StockAdjustmentClaimDocumentType;
        EDIFileLog."Stock Adj. Claim Order No." := StockAdjustmentClaimDocumentNo;
        EDIFileLog."EDI Vendor Type" := EDIVendorType;

        EDIFileLog.INSERT(TRUE);

        EXIT(EDIFileLog."Entry No.");
    end;

    procedure InsertEDIDocumentLog2(EDIFileLogEntryNo: Integer; InputProcessWhich: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS,IPOR; InputProcessWhat: Option "Validate and Export",Import,Validate,Process,Scan,Receive,"Create Return Order","Apply Return Order","Post Return Shipment","Post Return Credit","Complete without Posting Return Credit",,,"Create Transfer","Ship Transfer","Receive Transfer","Post Journal"; ImportExportWasSuccess: Boolean; OrderType: Option " ",PO,PI,STO,"STO-SHIP","STO-REC")
    var
        EDIFileLog: Record "GXL EDI File Log";
        EDIDocumentLog: Record "GXL EDI Document Log";
        PurchaseHeader: Record "Purchase Header";
        POResponseHeader: Record "GXL PO Response Header";
        ASNHeader: Record "GXL ASN Header";
        POINVHeader: Record "GXL PO INV Header";
        EDIPurchaseMessage: Record "GXL EDI-Purchase Messages";
        ShipAdvice: Record "GXL Intl. Shipping Advice Head";
        IPOAck: Record "GXL International PO Acknowld";
    begin
        IF IsLockingError(GetLastErrorCode()) THEN
            EXIT;
        ClearEDIDocumentLog();

        EDIFileLog.GET(EDIFileLogEntryNo);

        EDIDocumentLog.Init();
        EDIDocumentLog."Date/Time" := CurrentDateTime();
        EDIDocumentLog."Order Type" := OrderType;
        EDIDocumentLog."Document Type" := EDIFileLog."Document Type";
        EDIDocumentLog."EDI Vendor Type" := EDIFileLog."EDI Vendor Type";

        CASE InputProcessWhat OF

            InputProcessWhat::Import:
                EDIDocumentLog.Status := EDIDocumentLog.Status::Imported;

            InputProcessWhat::Validate:
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::Validated
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Validation Error";


            InputProcessWhat::Process:
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::Processed
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Processing Error";
            InputProcessWhat::"Validate and Export":
                IF InputProcessWhich = InputProcessWhich::ASN THEN BEGIN
                    IF ImportExportWasSuccess THEN
                        EDIDocumentLog.Status := EDIDocumentLog.Status::"3PL ASN Sent"
                    ELSE
                        EDIDocumentLog.Status := EDIDocumentLog.Status::"3PL ASN Sending Error";
                END ELSE BEGIN
                    IF ImportExportWasSuccess THEN
                        EDIDocumentLog.Status := EDIDocumentLog.Status::Processed
                    ELSE
                        EDIDocumentLog.Status := EDIDocumentLog.Status::"Processing Error";
                END;

            InputProcessWhat::Scan:
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::Scanned
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Scan Process Error";

            InputProcessWhat::Receive:
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::Received
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Receiving Error";

            InputProcessWhat::"Create Return Order":
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Return Order Created"
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Return Order Creation Error";

            InputProcessWhat::"Apply Return Order":
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Return Order Applied"
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Return Order Application Error";

            InputProcessWhat::"Post Return Shipment":
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Return Shipment Posted"
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Return Shipment Posting Error";

            InputProcessWhat::"Post Return Credit":
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Return Credit Posted"
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Return Shipment Posting Error";

            InputProcessWhat::"Complete without Posting Return Credit":
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Completed without Posting Return Credit";

            InputProcessWhat::"Create Transfer":
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Transfer Created"
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Transfer Creation Error";

            InputProcessWhat::"Ship Transfer":
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Transfer Shipped"
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Transfer Shipping Error";

            InputProcessWhat::"Receive Transfer":
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Transfer Received"
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Transfer Receiving Error";

            InputProcessWhat::"Post Journal":
                IF ImportExportWasSuccess THEN
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Journal Posted"
                ELSE
                    EDIDocumentLog.Status := EDIDocumentLog.Status::"Journal Posting Error";

        END;

        CASE InputProcessWhich OF
            InputProcessWhich::PO, InputProcessWhich::POX:
                BEGIN
                    GetPurchaseOrder(EDIFileLogEntryNo, PurchaseHeader);
                    UpdateEDIDocumentLogDocumentNo(EDIDocumentLog, PurchaseHeader."No.", PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No.", '')
                END;

            InputProcessWhich::POR:
                BEGIN
                    IF EDIDocumentLog."EDI Vendor Type" IN [EDIDocumentLog."EDI Vendor Type"::"Point 2 Point", EDIDocumentLog."EDI Vendor Type"::"Point 2 Point Contingency"] THEN BEGIN
                        GetP2PPurchaseOrder(EDIFileLogEntryNo, EDIPurchaseMessage);
                        UpdateEDIDocumentLogDocumentNo(EDIDocumentLog, EDIPurchaseMessage.DocumentNumber, EDIPurchaseMessage.DocumentNumber, EDIPurchaseMessage."Vendor No.", '')
                    END ELSE BEGIN
                        GetPurchaseOrderResponse(EDIFileLogEntryNo, POResponseHeader);
                        UpdateEDIDocumentLogDocumentNo(EDIDocumentLog, POResponseHeader."Response Number", POResponseHeader."Order No.", POResponseHeader."Buy-from Vendor No.", POResponseHeader."Original EDI Document No.");
                    END;
                END;
            InputProcessWhich::ASN:
                BEGIN
                    IF EDIDocumentLog."EDI Vendor Type" <> EDIDocumentLog."EDI Vendor Type"::" " THEN BEGIN
                        GetAdvanceShippingNotice(EDIFileLogEntryNo, ASNHeader);
                        UpdateEDIDocumentLogDocumentNo(EDIDocumentLog, ASNHeader."No.", ASNHeader."Purchase Order No.", ASNHeader."Supplier No.", ASNHeader."Original EDI Document No.")
                    END ELSE BEGIN
                        GetPurchaseOrder(EDIFileLogEntryNo, PurchaseHeader);
                        UpdateEDIDocumentLogDocumentNo(EDIDocumentLog, PurchaseHeader."No.", PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No.", '')
                    END;
                END;
            InputProcessWhich::INV:
                BEGIN
                    GetInvoice(EDIFileLogEntryNo, POINVHeader);
                    UpdateEDIDocumentLogDocumentNo(EDIDocumentLog, POINVHeader."No.", POINVHeader."Purchase Order No.", POINVHeader."Buy-from Vendor No.", POINVHeader."Original EDI Document No.");
                    EDIDocumentLog."Invoice On Hold" := POINVHeader."On Hold";
                    EDIDocumentLog."Invoice On Hold From" := POINVHeader."On Hold From";
                END;

            InputProcessWhich::SHIPSTATUS:
                BEGIN
                    GetIPOShippingAdvice(EDIFileLogEntryNo, ShipAdvice);
                    UpdateEDIDocumentLogDocumentNo(EDIDocumentLog, ShipAdvice."No.", ShipAdvice."Order No.", '', '');
                END;

            InputProcessWhich::IPOR:
                BEGIN
                    GetIPOAcknowledgement(EDIFileLogEntryNo, IPOAck);
                    UpdateEDIDocumentLogDocumentNo(EDIDocumentLog, IPOAck."No.", IPOAck."Purchase Order No.", '', '');
                END;

            InputProcessWhich::STKADJ:
                ;
            // No action required, stops early exit

            ELSE
                EXIT;
        END;

        IF NOT ImportExportWasSuccess THEN
            EDIDocumentLog.SetErrorMessage(GetLastErrorText());

        EDIDocumentLog."File Name" := EDIFileLog."File Name";
        EDIDocumentLog."EDI File Log Entry No." := EDIFileLog."Entry No.";
        EDIDocumentLog.INSERT(TRUE);
    end;

    local procedure GetEDIVendorType(VendorNo: Code[20]): Integer
    var
    begin
        EXIT(EDIFunctionsLibrary.GetEDIVendorType(VendorNo));
    end;

    local procedure FindOpenLogEntry(FullFileName: Text; Which: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS,IPOR; StockAdjustmentClaimDocumentType: Option " ",PO,PI,STO,"STO-SHIP","STO-REC"; StockAdjustmentClaimDocumentNo: Code[20]; EDIVendorType: Option " ","Point 2 Point",VAN,"3PL Supplier","Point 2 Point Contingency") EDIFileLogEntryNo: Integer
    var
        EDIFileLog: Record "GXL EDI File Log";
    begin
        IF Which = Which::STKADJ THEN BEGIN
            EDIFileLog.SETCURRENTKEY("Stock Adj. Claim Order No.");
            EDIFileLog.SETRANGE("Stock Adj. Claim Order No.", StockAdjustmentClaimDocumentNo);
            EDIFileLog.SETRANGE("Stock Adj. Claim Document Type", StockAdjustmentClaimDocumentType);
        END ELSE
            IF Which IN [Which::SHIPSTATUS, Which::IPOR] THEN BEGIN
                EDIFileLog.SETCURRENTKEY("File Name");
                EDIFileLog.SETRANGE("File Name", FullFileName);
            END ELSE
                CASE EDIVendorType OF
                    EDIVendorType::" ":
                        BEGIN
                            EDIFileLog.SETCURRENTKEY("File Name");
                            EDIFileLog.SETRANGE("File Name", '');
                        END;
                    EDIVendorType::"Point 2 Point",
                    EDIVendorType::"Point 2 Point Contingency",
                    EDIVendorType::VAN:
                        BEGIN
                            EDIFileLog.SETCURRENTKEY("File Name");
                            EDIFileLog.SETRANGE("File Name", FullFileName);
                        END;
                    EDIVendorType::"3PL Supplier":
                        BEGIN
                            // to be designed
                        END;
                END;

        EDIFileLog.SETRANGE(Status, EDIFileLog.Status::"In Process");

        IF EDIFileLog.FindFirst() THEN
            EDIFileLogEntryNo := EDIFileLog."Entry No."
        ELSE
            EDIFileLogEntryNo := 0;
    end;

    local procedure ImportPurchaseOrderResponseP2PNonEDI()
    begin
        ImportFile(2, ProcessEDIVendorType::"Point 2 Point");
    end;

    local procedure ValidatePurchaseOrderResponseP2PNonEDI()
    var
        EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
        EDIPurchaseMessages2: Record "GXL EDI-Purchase Messages";
        TempItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary;
        P2PValidatePurchOrderResp: Codeunit "GXL P2P-Valid Pur. Order Resp.";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        EDIValidatePurOrderResp: Codeunit "GXL EDI-Valid Pur. Order Resp.";
        ValidationWasSuccess: Boolean;
        LastDocumentNo: Code[20];
    begin
        EDIPurchaseMessages.SETCURRENTKEY(Status, ImportDoc, DocumentNumber);
        EDIPurchaseMessages.SETRANGE(Status, EDIPurchaseMessages.Status::Imported);
        EDIPurchaseMessages.SETRANGE(ImportDoc, EDIPurchaseMessages.ImportDoc::"1");
        IF EDIPurchaseMessages.FindSet(TRUE, TRUE) THEN
            REPEAT
                IF LastDocumentNo <> EDIPurchaseMessages.DocumentNumber THEN BEGIN
                    LastDocumentNo := EDIPurchaseMessages.DocumentNumber;
                    ClearLastError();
                    Commit();
                    EDIPurchaseMessages2 := EDIPurchaseMessages;
                    ValidationWasSuccess := P2PValidatePurchOrderResp.RUN(EDIPurchaseMessages2);

                    IF (NOT ValidationWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN BEGIN
                        UpdateEDIPurchaseMessageStatus(EDIPurchaseMessages.ImportDoc, EDIPurchaseMessages.DocumentNumber, EDIPurchaseMessages.Status::"Validation Error")
                    END;
                    //PO,POX,POR,ASN,INV
                    InsertEDIDocumentLog(EDIPurchaseMessages."EDI File Log Entry No.", 2, ProcessWhat, ValidationWasSuccess);

                    Commit();
                    IF ValidationWasSuccess THEN BEGIN

                        TempItemSupplierGTINBuffer.Reset();
                        TempItemSupplierGTINBuffer.DeleteAll();

                        EDIValidatePurOrderResp.GetGTINChanges(TempItemSupplierGTINBuffer);
                        EDIEmailMgt.SendP2PPORGTINValidationEmail(EDIPurchaseMessages, TempItemSupplierGTINBuffer, GetLastErrorText());

                        TempItemSupplierGTINBuffer.Reset();
                        TempItemSupplierGTINBuffer.DeleteAll();

                    END ELSE BEGIN
                        IF NOT IsLockingError(GetLastErrorCode()) THEN
                            EDIEmailMgt.SendP2PPORValidationFailureEmail(EDIPurchaseMessages, GetLastErrorText());
                    END;

                END;
            UNTIL EDIPurchaseMessages.Next() = 0;
    end;

    local procedure ProcessPurchaseOrderResponseP2PNonEDI()
    var
        EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
        EDIPurchaseMessages2: Record "GXL EDI-Purchase Messages";
        P2PProcessPurchOrderResp: Codeunit "GXL P2P-Proc Purch. Ord. Resp.";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessWasSuccess: Boolean;
        LastDocumentNo: Code[20];
    begin
        EDIPurchaseMessages.SETCURRENTKEY(Status, ImportDoc, DocumentNumber);
        EDIPurchaseMessages.SETRANGE(Status, EDIPurchaseMessages.Status::Validated);
        EDIPurchaseMessages.SETRANGE(ImportDoc, EDIPurchaseMessages.ImportDoc::"1");
        IF EDIPurchaseMessages.FindSet(TRUE, TRUE) THEN
            REPEAT
                IF LastDocumentNo <> EDIPurchaseMessages.DocumentNumber THEN BEGIN

                    LastDocumentNo := EDIPurchaseMessages.DocumentNumber;
                    ClearLastError();
                    EDIPurchaseMessages2 := EDIPurchaseMessages;
                    Commit();
                    ProcessWasSuccess := P2PProcessPurchOrderResp.RUN(EDIPurchaseMessages2);
                    IF (NOT ProcessWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                        UpdateEDIPurchaseMessageStatus(EDIPurchaseMessages.ImportDoc, EDIPurchaseMessages.DocumentNumber, EDIPurchaseMessages.Status::"Processing Error");

                    //PO,POX,POR,ASN,INV
                    InsertEDIDocumentLog(EDIPurchaseMessages."EDI File Log Entry No.", 2, ProcessWhat, ProcessWasSuccess);
                    Commit();

                    IF (NOT ProcessWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                        EDIEmailMgt.SendP2PPORProcessingFailureEmail(EDIPurchaseMessages, GetLastErrorText());
                END;
            UNTIL EDIPurchaseMessages.Next() = 0;
    end;

    procedure UpdateEDIPurchaseMessageStatus(DocumentType: Option " ","1","2","3"; InputDocumentNumber: Code[20]; InputStatus: Option Imported,"Validation Error",Validated,"Processing Error","Processed ")
    var
        EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
    begin
        EDIPurchaseMessages.SETCURRENTKEY(ImportDoc, DocumentNumber);
        EDIPurchaseMessages.SETRANGE(ImportDoc, DocumentType);
        EDIPurchaseMessages.SETRANGE(DocumentNumber, InputDocumentNumber);
        IF EDIPurchaseMessages.FindSet(TRUE) THEN
            REPEAT
                EDIPurchaseMessages.Status := InputStatus;
                IF InputStatus IN [InputStatus::"Validation Error", InputStatus::"Processing Error"] THEN BEGIN
                    IF NOT EDIPurchaseMessages."Error Found" THEN BEGIN
                        EDIPurchaseMessages."Error Found" := TRUE;
                        EDIPurchaseMessages."Error Description" := GetLastErrorText();
                    END;
                END ELSE
                    IF InputStatus = InputStatus::"Processed " THEN
                        EDIPurchaseMessages.Processed := TRUE;
                EDIPurchaseMessages.Modify();
            UNTIL EDIPurchaseMessages.Next() = 0;
    end;


    local procedure GetP2PInboundFilePrefix(VendorNo: Code[20]; var P2PFilePrefix: Text; var P2PFileFormat: Text): Boolean
    var
        VendorFileSetup: Record "GXL 3Pl File Setup";
    begin
        P2PFilePrefix := '';
        P2PFileFormat := '';

        VendorFileSetup.SETRANGE(Code, VendorNo);
        VendorFileSetup.SETRANGE(Direction, VendorFileSetup.Direction::Inbound);
        CASE ProcessWhich OF
            ProcessWhich::POR:
                VendorFileSetup.SETRANGE(Type, VendorFileSetup.Type::Confirmation);
            ProcessWhich::ASN:
                VendorFileSetup.SETRANGE(Type, VendorFileSetup.Type::ASN);
            ProcessWhich::INV:
                VendorFileSetup.SETRANGE(Type, VendorFileSetup.Type::Invoice);
        END;
        VendorFileSetup.SETFILTER("XML Port", '<>%1', 0);
        //ERP-247 >>
        //VendorFileSetup.FindFirst();
        if not VendorFileSetup.FindFirst() then
            exit(false);
        //ERP-247 <<    
        P2PFilePrefix := FORMAT(VendorFileSetup."XML Port") + '_';
        P2PFileFormat := FORMAT(VendorFileSetup."File Format");
        exit(true); //ERP-247 <<
    end;

    local procedure GetP2PPurchaseOrder(EDIFileLogEntryNo: Integer; var EDIPurchaseMessages: Record "GXL EDI-Purchase Messages")
    begin
        EDIPurchaseMessages.Reset();
        EDIPurchaseMessages.SETCURRENTKEY("EDI File Log Entry No.");
        EDIPurchaseMessages.SETRANGE("EDI File Log Entry No.", EDIFileLogEntryNo);
        IF EDIPurchaseMessages.FindFirst() THEN;
    end;

    local procedure UpdateEDIDocumentLogDocumentNo(var EDIDocumentLog: Record "GXL EDI Document Log"; InputDocumentNo: Code[35]; InputOrderNo: Code[20]; InputSupplierNo: Code[20]; InputOriginalDocumentNo: Code[35])
    begin
        EDIDocumentLog."Document No." := InputDocumentNo;
        EDIDocumentLog."Order No." := InputOrderNo;
        EDIDocumentLog."Supplier No." := InputSupplierNo;
        EDIDocumentLog."Original Document No." := InputOriginalDocumentNo;
    end;

    local procedure GetEDISetup()
    begin
        IF NOT EDISetupRead THEN BEGIN
            EDISetup.GET();
            EDISetupRead := TRUE;
        END;
    end;

    local procedure GetDirectory(CurrentDirectory: Text; DirectoryType: Option Inbound,Outbound,Archive,Error; EDIType: Option " ","Point 2 Point",VAN,"3PL Supplier"): Text
    begin
        IF CurrentDirectory <> '' THEN
            EXIT(CurrentDirectory);

        GetEDISetup();
        CASE EDIType OF
            EDIType::"Point 2 Point":
                CASE DirectoryType OF
                    DirectoryType::Inbound:
                        BEGIN
                            EDISetup.TESTFIELD("Default Inbound Dir. P2P");
                            EXIT(EDISetup."Default Inbound Dir. P2P");
                        END;
                    DirectoryType::Outbound:
                        BEGIN
                            EDISetup.TESTFIELD("Default Outbound Dir. P2P");
                            EXIT(EDISetup."Default Outbound Dir. P2P");
                        END;
                    DirectoryType::Archive:
                        BEGIN
                            EDISetup.TESTFIELD("Default Archive Dir. P2P");
                            EXIT(EDISetup."Default Archive Dir. P2P");
                        END;
                    DirectoryType::Error:
                        BEGIN
                            EDISetup.TESTFIELD("Default Error Dir. P2P");
                            EXIT(EDISetup."Default Error Dir. P2P");
                        END;
                END;

            EDIType::VAN:
                CASE DirectoryType OF
                    DirectoryType::Inbound:
                        BEGIN
                            EDISetup.TESTFIELD("Default Inbound Dir. VAN");
                            EXIT(EDISetup."Default Inbound Dir. VAN");
                        END;
                    DirectoryType::Outbound:
                        BEGIN
                            EDISetup.TESTFIELD("Default Outbound Dir. VAN");
                            EXIT(EDISetup."Default Outbound Dir. VAN");
                        END;
                    DirectoryType::Archive:
                        BEGIN
                            EDISetup.TESTFIELD("Default Archive Dir. VAN");
                            EXIT(EDISetup."Default Archive Dir. VAN");
                        END;
                    DirectoryType::Error:
                        BEGIN
                            EDISetup.TESTFIELD("Default Error Dir. VAN");
                            EXIT(EDISetup."Default Error Dir. VAN");
                        END;
                END;

            EDIType::" ":
                CASE DirectoryType OF
                    DirectoryType::Inbound:
                        BEGIN
                            EDISetup.TESTFIELD("Default Inbound Dir. Non-EDI");
                            EXIT(EDISetup."Default Inbound Dir. Non-EDI");
                        END;
                    DirectoryType::Outbound:
                        BEGIN
                            EDISetup.TESTFIELD("Default Outbound Dir. Non-EDI");
                            EXIT(EDISetup."Default Outbound Dir. Non-EDI");
                        END;
                    DirectoryType::Archive:
                        BEGIN
                            EDISetup.TESTFIELD("Default Archive Dir. Non-EDI");
                            EXIT(EDISetup."Default Archive Dir. Non-EDI");
                        END;
                    DirectoryType::Error:
                        BEGIN
                            EDISetup.TESTFIELD("Default Error Dir. Non-EDI");
                            EXIT(EDISetup."Default Error Dir. Non-EDI");
                        END;
                END;

        END;
    end;

    local procedure CheckIfValidateInvoice(EDIInvHeader: Record "GXL PO INV Header"): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        //TODO: Order Status - check PO INV Header and purchase order is qualifiled for invoice, i.e. Status must be Closed
        GetEDISetup();
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, EDIInvHeader."Purchase Order No.") THEN
            IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Closed THEN
                EXIT(TRUE);
        IF EDISetup."Invoice On Hold Duration" > 0 THEN BEGIN
            EDIInvHeader.TESTFIELD("Invoice Received Date");
            IF Today() - EDIInvHeader."Invoice Received Date" > EDISetup."Invoice On Hold Duration" THEN
                EXIT(TRUE);
        END;
        EXIT(FALSE);
    end;

    local procedure CheckNAVDocumentNo(OrigianlEDIDocNo: Code[35]; NAVEDIDocNo: Code[60]): Boolean
    begin
        EXIT((OrigianlEDIDocNo <> '') AND (NAVEDIDocNo = ''));
    end;

    local procedure IsNewDocument(ThisDocumentNo: Code[20]; PreviousDocumentNo: Code[20]): Boolean
    begin
        EXIT(ThisDocumentNo <> PreviousDocumentNo);
    end;

    local procedure CheckIfManualInvoiceExist(EDIInvNo: Code[20]): Boolean
    var
        POINVHeader: Record "GXL PO INV Header";
        POINVHeader2: Record "GXL PO INV Header";
    begin
        POINVHeader2.GET(EDIInvNo);
        POINVHeader.Reset();
        POINVHeader.SETCURRENTKEY("Purchase Order No.");
        POINVHeader.SETRANGE("Purchase Order No.", POINVHeader2."Purchase Order No.");
        POINVHeader.SETFILTER("Manual Processing Status", '>%1', POINVHeader."Manual Processing Status"::" ");
        IF POINVHeader.FindFirst() THEN BEGIN
            POINVHeader2.Status := POINVHeader.Status;
            POINVHeader2."No Claim" := TRUE;
            POINVHeader2.Modify();
            EXIT(TRUE);
        END;

        EXIT(FALSE)
    end;


    local procedure Update3PLEDIFileLog(EDILogEntryNo: Integer; FileName: Text)
    var
        EDIFileLog: Record "GXL EDI File Log";
    begin
        IF EDIFileLog.GET(EDILogEntryNo) THEN BEGIN
            IF ProcessWhat = ProcessWhat::Scan THEN
                EDIFileLog."3PL ASN Received" := FileName;
            IF ProcessWhat = ProcessWhat::"Validate and Export" THEN
                EDIFileLog."3PL ASN Sent" := FileName;
            EDIFileLog.Modify();
        END;
    end;


    local procedure GetPOEDIVendorType(DocumentNo: Code[20]; VendorNo: Code[20]): Integer
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, DocumentNo) THEN
            EXIT(PurchaseHeader."GXL EDI Vendor Type");
        EXIT(EDIFunctionsLibrary.GetEDIVendorType(VendorNo));
    end;

    local procedure ValidateExportIntlPO(ExportWhich: Option PO,POX,POR,ASN,INV,IPO,IPOX,SHIPSTATUS)
    var

        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseHeader2: Record "Purchase Header";
        FreightAgent: Record "GXL Freight Forwarder";
        EDIExportValidatePurchOrder: Codeunit "GXL EDI-Export+Val. Pur. Order";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        FileMgt: Codeunit "File Management";
        LogExportWhich: Option PO,POX,POR,ASN,INV;
        ExportWasSuccess: Boolean;
        EDIFileLogEntryNo: Integer;
        FileName: Text;
        FinalDestination: Text;
        FilePrefix: Text;
        FileFormat: Text;
    begin

        FileFormat := GetXmlFileExtension();

        PurchaseHeader.Reset();
        // TODO International/Domestic PO - Not needed for now
        PurchaseHeader.SETCURRENTKEY("GXL International Order", "GXL Order Status", "GXL Send to Freight Forwarder");
        PurchaseHeader.SETCURRENTKEY("GXL International Order", "GXL Order Status");
        PurchaseHeader.SETRANGE("GXL International Order", TRUE);
        PurchaseHeader.SETFILTER("GXL Order Status", '%1|%2|%3', PurchaseHeader."GXL Order Status"::Confirmed, PurchaseHeader."GXL Order Status"::"Booked to Ship", PurchaseHeader."GXL Order Status"::Cancelled);
        // TODO International/Domestic PO - Not needed for now
        PurchaseHeader.SETRANGE("GXL Send to Freight Forwarder", TRUE);
        IF PurchaseHeader.FindSet() THEN
            REPEAT
                IF (FreightAgent.GET(PurchaseHeader."GXL Freight Forwarder Code")) AND
                   (FreightAgent.Status = FreightAgent.Status::Active)
                THEN BEGIN
                    FreightAgent.TESTFIELD("PO Filename Prefix");
                    FilePrefix := FreightAgent."PO Filename Prefix";

                    Vendor.GET(PurchaseHeader."Buy-from Vendor No.");

                    PurchaseHeader2 := PurchaseHeader;

                    IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Cancelled THEN BEGIN
                        ExportWhich := ExportWhich::IPOX;
                        LogExportWhich := LogExportWhich::POX;
                    END ELSE
                        LogExportWhich := LogExportWhich::PO;

                    FileName := STRSUBSTNO('%1_%2.%3',
                                  FilePrefix,
                                  PurchaseHeader2."No.",
                                  FileFormat);

                    FinalDestination := FileMgt.CombinePath(FreightAgent."Outbound FTP Folder", FileName);

                    EDIFileLogEntryNo := InsertEDIFileLog2(FinalDestination, LogExportWhich, 0, '', PurchaseHeader2."GXL EDI Vendor Type");

                    EDIExportValidatePurchOrder.SetOptions(ExportWhich, FinalDestination);

                    Commit();

                    ExportWasSuccess := EDIExportValidatePurchOrder.RUN(PurchaseHeader2);

                    IF ExportWasSuccess THEN BEGIN
                        //copy file to archive directory
                        MoveFile(FinalDestination, GetFileName(FileMgt.CombinePath(FreightAgent."Archive Folder", FileName)), FALSE);

                        //update file log
                        UpdateEDIFileLog(EDIFileLogEntryNo, ExportWasSuccess);

                        // Update Purchase Header
                        UpdateIntlPurchaseHeader(PurchaseHeader2, EDIFileLogEntryNo);

                        //update document log
                        InsertEDIDocumentLog(EDIFileLogEntryNo, LogExportWhich, ProcessWhat, ExportWasSuccess);
                    END ELSE BEGIN
                        //update file log
                        UpdateEDIFileLog(EDIFileLogEntryNo, ExportWasSuccess);

                        //update document log
                        InsertEDIDocumentLog(EDIFileLogEntryNo, LogExportWhich, ProcessWhat, ExportWasSuccess);
                    END;

                    Commit();

                    IF NOT ExportWasSuccess THEN
                        EDIEmailMgt.SendPOExportFailureEmail(PurchaseHeader2, GetLastErrorText());
                END;
            UNTIL PurchaseHeader.Next() = 0;

    end;

    local procedure ImportIntlPOShippingAdvice(ImportWhich: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS)
    var
        FreightAgent: Record "GXL Freight Forwarder";
        NameValueBuffer: Record "Name/Value Buffer" temporary;
        UnfilteredNameValueBuffer: Record "Name/Value Buffer" temporary;
        EDIImportFile: Codeunit "GXL EDI-Import File";
        MiscUtils: Codeunit "GXL Misc. Utilities";
        FileMgt: Codeunit "File Management";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ImportWasSuccess: Boolean;
        EDIFileLogEntryNo: Integer;
        StoredFileName: Text;
        FilePrefix: Text;
        FileFormat: Text;
        FileSize: BigInteger;
        FileModifyDate: Date;
        FileModifyTime: Time;
        CurrFileName: Text;
    begin
        FileFormat := GetXmlFileExtension();

        FreightAgent.SETRANGE(Status, FreightAgent.Status::Active);
        IF FreightAgent.FindSet() THEN
            REPEAT
                IF (FreightAgent."Inbound FTP Folder" <> '') AND
                   (FreightAgent."Archive Folder" <> '') AND
                   (FreightAgent."Error Folder" <> '') AND
                   (FreightAgent."Ship. Advice Filename Prefix" <> '')
                THEN BEGIN
                    FilePrefix := FreightAgent."Ship. Advice Filename Prefix";
                    // FileMgt.GetServerDirectoryFilesList(NameValueBuffer, FreightAgent."Inbound FTP Folder");
                    // MiscUtils.FilterNameValueBuffer(UnfilteredNameValueBuffer, NameValueBuffer, FilePrefix, FileFormat);
                    FileMgt.GetServerDirectoryFilesList(UnfilteredNameValueBuffer, FreightAgent."Inbound FTP Folder");
                    MiscUtils.FilterNameValueBuffer(UnfilteredNameValueBuffer, NameValueBuffer, FilePrefix, FileFormat);
                    if NameValueBuffer.FindSet() then
                        repeat
                            ClearLastError();
                            CurrFileName := FileMgt.GetFileName(NameValueBuffer.Name);

                            EDIFileLogEntryNo := InsertEDIFileLog2(NameValueBuffer.Name, ImportWhich, 0, '', 0);

                            Commit();

                            EDIImportFile.SetOptions(ImportWhich, NameValueBuffer.Name, EDIFileLogEntryNo);
                            ImportWasSuccess := EDIImportFile.Run();

                            IF ImportWasSuccess THEN BEGIN
                                //move file to archive directory
                                MoveFile(NameValueBuffer.Name, GetFileName(FileMgt.CombinePath(FreightAgent."Archive Folder", CurrFileName)), TRUE);

                                //update log 1
                                UpdateEDIFileLog(EDIFileLogEntryNo, ImportWasSuccess);

                                //update log 2
                                InsertEDIDocumentLog(EDIFileLogEntryNo, ImportWhich, ProcessWhat, ImportWasSuccess);
                            END ELSE BEGIN
                                //move file to error directory
                                FileMgt.GetServerFileProperties(NameValueBuffer.Name, FileModifyDate, FileModifyTime, FileSize);
                                IF NOT IsLockingError(GetLastErrorCode()) THEN BEGIN
                                    StoredFileName := GetFileName(FileMgt.CombinePath(FreightAgent."Error Folder", CurrFileName));
                                    MoveFile(NameValueBuffer.Name, StoredFileName, TRUE);
                                END;

                                //update log 1
                                UpdateEDIFileLog(EDIFileLogEntryNo, ImportWasSuccess);
                            END;

                            Commit();
                            IF (NOT ImportWasSuccess) AND NOT (IsLockingError(GetLastErrorCode())) THEN
                                EDIEmailMgt.SendShipAdviceImportFailureEmail(FreightAgent, StoredFileName, CurrFileName, FileSize, GetLastErrorText());

                        until NameValueBuffer.Next() = 0;

                END;
            UNTIL FreightAgent.Next() = 0;
    end;

    local procedure ValidateIntlPOShippingAdvice()
    var
        ShipAdviceHeader: Record "GXL Intl. Shipping Advice Head";
        ShipAdviceHeader2: Record "GXL Intl. Shipping Advice Head";
        ValidateShippingAdvice: Codeunit "GXL Validate Intl. Ship Advice";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ValidationWasSuccess: Boolean;
    begin
        ShipAdviceHeader.SETCURRENTKEY(Status);
        ShipAdviceHeader.SETRANGE(Status, ShipAdviceHeader.Status::Imported);
        IF ShipAdviceHeader.FindSet() THEN
            REPEAT
                Commit();
                ClearLastError();
                ShipAdviceHeader2.GET(ShipAdviceHeader."No.");
                ValidationWasSuccess := ValidateShippingAdvice.RUN(ShipAdviceHeader2);

                IF (NOT ValidationWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN BEGIN
                    ShipAdviceHeader2.GET(ShipAdviceHeader."No.");
                    //TODO: temporarily insert as shipment is imported from NAV
                    //ERP-NAV Master Data Management +
                    if ShipAdviceHeader2."EDI File Log Entry No." = 0 then
                        ShipAdviceHeader2.AddEDIFileLog();
                    //ERP-NAV Master Data Management -

                    ShipAdviceHeader2.VALIDATE(Status, ShipAdviceHeader2.Status::"Validation Error");
                    ShipAdviceHeader2.MODIFY(TRUE);
                end else begin
                    //TODO: temporarily insert as shipment is imported from NAV
                    //ERP-NAV Master Data Management +
                    if ShipAdviceHeader2."EDI File Log Entry No." = 0 then begin
                        ShipAdviceHeader2.Get(ShipAdviceHeader."No.");
                        if ShipAdviceHeader2.AddEDIFileLog() then
                            ShipAdviceHeader2.Modify();
                    end;
                    //ERP-NAV Master Data Management -
                end;


                //PO,POX,POR,ASN,INV,SHIPSTATUS
                InsertEDIDocumentLog(ShipAdviceHeader2."EDI File Log Entry No.", 6, ProcessWhat, ValidationWasSuccess);

                Commit();

                IF NOT ValidationWasSuccess THEN
                    IF NOT IsLockingError(GetLastErrorCode()) THEN
                        EDIEmailMgt.SendShipAdviceValidationFailureEmail(ShipAdviceHeader2, GetLastErrorText());
            UNTIL ShipAdviceHeader.Next() = 0;
    end;

    local procedure ProcessIntlPOShippingAdvice()
    var
        PurchHeader: Record "Purchase Header";
        ShipAdviceHeader: Record "GXL Intl. Shipping Advice Head";
        ShipAdviceHeader2: Record "GXL Intl. Shipping Advice Head";
        ProcessShippingAdvice: Codeunit "GXL Process Intl. Ship. Advice";
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
        ProcessShipAdvice: Boolean;
        ProcessWasSuccess: Boolean;
    begin
        ShipAdviceHeader.SETCURRENTKEY(Status);
        ShipAdviceHeader.SETRANGE(Status, ShipAdviceHeader.Status::Validated);
        IF ShipAdviceHeader.FindSet() THEN
            REPEAT
                Commit();
                ClearLastError();
                ShipAdviceHeader2.GET(ShipAdviceHeader."No.");

                ProcessShipAdvice := TRUE;

                //TODO: Order Status - process ASN for internaltional order to see if order status on purchase order and shipping advice is consistent
                IF (PurchHeader.GET(PurchHeader."Document Type"::Order, ShipAdviceHeader2."Order No.")) AND
                   (PurchHeader."GXL Order Status" <= ShipAdviceHeader2."Order Shipping Status")
                THEN
                    CASE ShipAdviceHeader."Order Shipping Status" OF
                        ShipAdviceHeader2."Order Shipping Status"::"Booked to Ship":
                            IF (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::Confirmed) AND
                               (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::"Booked to Ship")
                            THEN
                                ProcessShipAdvice := FALSE;
                        ShipAdviceHeader2."Order Shipping Status"::"At CFS":
                            IF PurchHeader."GXL Order Status" < PurchHeader."GXL Order Status"::"Booked to Ship" THEN
                                ProcessShipAdvice := FALSE;
                        ShipAdviceHeader2."Order Shipping Status"::Shipped:
                            IF (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::"Booked to Ship") AND
                               (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::Shipped)
                            THEN
                                ProcessShipAdvice := FALSE;
                        ShipAdviceHeader2."Order Shipping Status"::Arrived:
                            IF (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::Shipped) AND
                               (PurchHeader."GXL Order Status" <> PurchHeader."GXL Order Status"::Arrived)
                            THEN
                                ProcessShipAdvice := FALSE;
                    END;

                IF ProcessShipAdvice THEN BEGIN
                    ProcessWasSuccess := ProcessShippingAdvice.RUN(ShipAdviceHeader2);

                    IF NOT ProcessWasSuccess THEN
                        IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                            ShipAdviceHeader2.GET(ShipAdviceHeader."No.");
                            ShipAdviceHeader2.VALIDATE(Status, ShipAdviceHeader2.Status::"Processing Error");
                            //TODO: temporarily insert as shipment is imported from NAV
                            //ERP-NAV Master Data Management +
                            if ShipAdviceHeader2."EDI File Log Entry No." = 0 then
                                ShipAdviceHeader2.AddEDIFileLog();
                            //ERP-NAV Master Data Management -
                            ShipAdviceHeader2.MODIFY(TRUE);
                        END;

                    //TODO: temporarily insert as shipment is imported from NAV
                    //ERP-NAV Master Data Management +
                    if ShipAdviceHeader2."EDI File Log Entry No." = 0 then begin
                        ShipAdviceHeader2.Get(ShipAdviceHeader."No.");
                        if ShipAdviceHeader2.AddEDIFileLog() then
                            ShipAdviceHeader2.Modify();
                    end;
                    //ERP-NAV Master Data Management -

                    //PO,POX,POR,ASN,INV,SHIPSTATUS
                    InsertEDIDocumentLog(ShipAdviceHeader2."EDI File Log Entry No.", 6, ProcessWhat, ProcessWasSuccess);

                    Commit();
                END;

                IF (NOT ProcessWasSuccess) AND (NOT IsLockingError(GetLastErrorCode())) THEN
                    EDIEmailMgt.SendShipAdviceProcessFailureEmail(ShipAdviceHeader2, GetLastErrorText());
            UNTIL ShipAdviceHeader.Next() = 0;
    end;

    local procedure ImportIntlPOAck(ImportWhich: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS,IPOR)
    var
        FreightAgent: Record "GXL Freight Forwarder";
        UnfilteredNameValueBuffer: Record "Name/Value Buffer" temporary;
        NameValueBuffer: Record "Name/Value Buffer" temporary;
        EDIImportFile: Codeunit "GXL EDI-Import File";
        FileMgt: Codeunit "File Management";
        MiscUtils: Codeunit "GXL Misc. Utilities";
        ImportWasSuccess: Boolean;
        EDIFileLogEntryNo: Integer;
        StoredFileName: Text;
        FilePrefix: Text;
        FileFormat: Text;
        LogImportWhich: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS,IPOR;
        FileNameOnly: Text;
    begin
        FileFormat := GetXmlFileExtension();

        FreightAgent.SETRANGE(Status, FreightAgent.Status::Active);
        IF FreightAgent.FindSet() THEN
            REPEAT
                IF (FreightAgent."Inbound FTP Folder" <> '') AND
                   (FreightAgent."Archive Folder" <> '') AND
                   (FreightAgent."Error Folder" <> '') AND
                   (FreightAgent."PO Response Filename Prefix" <> '')
                THEN BEGIN
                    FilePrefix := FreightAgent."PO Response Filename Prefix";
                    FileMgt.GetServerDirectoryFilesList(UnfilteredNameValueBuffer, FreightAgent."Inbound FTP Folder");
                    MiscUtils.FilterNameValueBuffer(UnfilteredNameValueBuffer, NameValueBuffer, FilePrefix, FileFormat);
                    if NameValueBuffer.Find('-') then
                        repeat
                            ClearLastError();
                            FileNameOnly := FileMgt.GetFileName(NameValueBuffer.Name);
                            LogImportWhich := 2;  // Use POR as the document type on the file log
                            EDIFileLogEntryNo := InsertEDIFileLog2(NameValueBuffer.Name, LogImportWhich, 0, '', 0);

                            Commit();

                            EDIImportFile.SetOptions(ImportWhich, NameValueBuffer.Name, EDIFileLogEntryNo);
                            ImportWasSuccess := EDIImportFile.Run();

                            IF ImportWasSuccess THEN BEGIN
                                //move file to archive directory
                                MoveFile(NameValueBuffer.Name, GetFileName(FileMgt.CombinePath(FreightAgent."Archive Folder", FileNameOnly)), TRUE);

                                //update log 1
                                UpdateEDIFileLog(EDIFileLogEntryNo, ImportWasSuccess);

                                //update log 2
                                InsertEDIDocumentLog(EDIFileLogEntryNo, ImportWhich, ProcessWhat, ImportWasSuccess);
                            END ELSE BEGIN
                                //move file to error directory
                                IF NOT IsLockingError(GetLastErrorCode()) THEN BEGIN
                                    StoredFileName := GetFileName(FileMgt.CombinePath(FreightAgent."Error Folder", FileNameOnly));
                                    MoveFile(NameValueBuffer.Name, StoredFileName, TRUE);
                                END;

                                //update log 1
                                UpdateEDIFileLog(EDIFileLogEntryNo, ImportWasSuccess);
                            END;

                            Commit();
                        until NameValueBuffer.Next() = 0;
                END;
            UNTIL FreightAgent.Next() = 0;

    end;

    local procedure ValidateIntlPOAck()
    var
        POAck: Record "GXL International PO Acknowld";
        POAck2: Record "GXL International PO Acknowld";
        PurchHeader: Record "Purchase Header";
        ProcessWasSuccess: Boolean;
        ErrMsg: Text[250];
        Err1Txt: Label 'Purchase Order not found.';
        Err2Txt: Label 'Acknlowledgement version does not match Purchase Order Version.'; // >> HP2-Spriny2 <<
    begin
        POAck.SETCURRENTKEY(Status);
        POAck.SETRANGE(Status, POAck.Status::Imported);
        IF POAck.FindSet() THEN
            REPEAT
                Commit();
                ClearLastError();
                POAck2.GET(POAck."No.");

                ErrMsg := '';

                IF NOT PurchHeader.GET(PurchHeader."Document Type"::Order, POAck."Purchase Order No.") THEN
                    ErrMsg := Err1Txt
                ELSE
                    // TODO International/Domestic PO - Not needed for now
                    // >> HP2-Spriny2
                    IF PurchHeader."GXL Freight Forwarder File Ver" <> POAck."Order Version No." THEN
                        ErrMsg := Err2Txt;
                // << HP2-Spriny2
                ProcessWasSuccess := ErrMsg = '';

                IF NOT ProcessWasSuccess THEN BEGIN
                    IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                        POAck2.GET(POAck."No.");
                        POAck2.VALIDATE(Status, POAck2.Status::"Validation Error");
                        POAck2."Status Message" := ErrMsg;
                        POAck2.MODIFY(TRUE);
                    END;
                END ELSE BEGIN
                    POAck2.VALIDATE(Status, POAck2.Status::Validated);
                    POAck2.MODIFY(TRUE);
                END;

                InsertEDIDocumentLog(POAck."EDI File Log Entry No.", 7, ProcessWhat, ProcessWasSuccess); // IPOR (7)

                Commit();

            UNTIL POAck.Next() = 0;
    end;

    local procedure ProcessIntlPOAck()
    var
        POAck: Record "GXL International PO Acknowld";
        POAck2: Record "GXL International PO Acknowld";
        PurchHeader: Record "Purchase Header";
        ProcessWasSuccess: Boolean;
        ErrMsg: Text[250];
        Err1Txt: Label 'Purchase Order not found.';
        Err2Txt: Label 'Acknlowledgement version does not match Purchase Order Version.'; // >> HP2-Spriny2 <<
    begin
        POAck.SETCURRENTKEY(Status);
        POAck.SETRANGE(Status, POAck.Status::Validated);
        IF POAck.FindSet() THEN
            REPEAT
                Commit();
                ClearLastError();
                POAck2.GET(POAck."No.");

                ErrMsg := '';
                IF NOT PurchHeader.GET(PurchHeader."Document Type"::Order, POAck."Purchase Order No.") THEN
                    ErrMsg := Err1Txt
                // TODO International/Domestic PO - Not needed for now
                // >> HP2-Spriny2
                ELSE
                    IF PurchHeader."GXL Freight Forwarder File Ver" <> POAck."Order Version No." THEN
                        ErrMsg := Err2Txt
                    ELSE BEGIN
                        PurchHeader."GXL Freight Forwarder File Ack" := TRUE;
                        PurchHeader."GXL Freight Forwarder Ack Date" := POAck."Order Processing Date";
                        IF NOT PurchHeader.Modify() THEN
                            EXIT;
                    END;
                // << HP2-Spriny2

                ProcessWasSuccess := ErrMsg = '';

                IF NOT ProcessWasSuccess THEN BEGIN
                    IF IsLockingError(GetLastErrorCode()) = FALSE THEN BEGIN
                        POAck2.GET(POAck."No.");
                        POAck2.VALIDATE(Status, POAck2.Status::"Processing Error");
                        POAck2."Status Message" := ErrMsg;
                        POAck2.MODIFY(TRUE);
                    END;
                END ELSE BEGIN
                    POAck2.VALIDATE(Status, POAck2.Status::Processed);
                    POAck2.MODIFY(TRUE);
                END;

                InsertEDIDocumentLog(POAck."EDI File Log Entry No.", 7, ProcessWhat, ProcessWasSuccess);  // IPOR (7)

                Commit();
            UNTIL POAck.Next() = 0;
    end;

    local procedure UpdateIntlPurchaseHeader(var PurchaseHeader: Record "Purchase Header"; EDIFileLogEntryNo: Integer)
    var
    begin
        // TODO International/Domestic PO - Not needed for now
        PurchaseHeader.VALIDATE("GXL Send to Freight Forwarder", FALSE);
        PurchaseHeader.VALIDATE("GXL Freight Forward. File Sent", TRUE);
        PurchaseHeader.VALIDATE("GXL Freight Forw. File Sent DT", CurrentDateTime());
        PurchaseHeader.VALIDATE("GXL Freight Forwarder File Ver", PurchaseHeader."GXL Freight Forwarder File Ver" + 1);
        PurchaseHeader."GXL Freight Forwarder File Ack" := FALSE;
        PurchaseHeader."GXL Freight Forwarder Ack Date" := 0D;
        PurchaseHeader.VALIDATE("GXL EDI PO File Log Entry No.", EDIFileLogEntryNo);
        PurchaseHeader.MODIFY(TRUE);
    end;

    local procedure GetIPOShippingAdvice(EDIFileLogEntryNo: Integer; var Shipadvice: Record "GXL Intl. Shipping Advice Head")
    var
        ShipAdvice2: Record "GXL Intl. Shipping Advice Head";
    begin
        ShipAdvice2.SETCURRENTKEY("EDI File Log Entry No.");
        ShipAdvice2.SETRANGE("EDI File Log Entry No.", EDIFileLogEntryNo);
        IF ShipAdvice2.FindFirst() THEN
            Shipadvice := ShipAdvice2;
    end;

    local procedure GetIPOAcknowledgement(EDIFileLogEntryNo: Integer; var IPOAck: Record "GXL International PO Acknowld")
    var
        IPOAck2: Record "GXL International PO Acknowld";
    begin
        IPOAck2.SETCURRENTKEY("EDI File Log Entry No.");
        IPOAck2.SETRANGE("EDI File Log Entry No.", EDIFileLogEntryNo);
        IF IPOAck2.FindFirst() THEN
            IPOAck := IPOAck2;
    end;
}

