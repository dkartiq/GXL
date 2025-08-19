// 001 23.06.2025 KDU HP2-Sprint1-Changes
codeunit 50368 "GXL EDI Email Management"
{
    trigger OnRun()
    begin
    end;

    var
        //SMTPMailSetup: Record "SMTP Mail Setup"; // >> Upgrade <<
        IntegrationSetup: Record "GXL Integration Setup";
        EDIEmailSetup: Record "GXL EDI Email Setup";
        ProcessAreaOfEmailing: Option "PO Exp.","GTIN Valid.","POR Imp.","POR Valid.","POR Proc.","ASN Imp.","ASN Valid.","ASN Proc.","ASN Scan Valid.","ASN Scan Proc.","ASN Receive","ASN Rec. Discr.","ASN Ret. Or. Creation","ASN Ret. Or. Appl.","ASN Ret. Ship Post","INV Imp.","INV Valid.","INV Proc.","INV Cr. Post","INV Credit Notifi.","P2P POR Imp.","P2P POR Valid.","P2P POR Proc.","P2P ASN Imp.","P2P INV Imp.","P2P INV Valid.","P2P INV Proc.","P2P INV Cr. Post","P2P INV Cr. Notifi.","PO Scan Proc.","PO Rec.","PO Rec. Discr.","PO Ret. Or. Creation","PO Ret. Appl.","PO Ret. Ship Post","PO INV Post","PO Cr. Creation","PO Cr. Appl.","PO Cr. Post","PO Cr. Post Notifi.","PO Cr. Creation Notifi.","Stk Adj. Valid.","Stk Adj. Creation","Stk Adj. App","Stk Adj. Post","Manual Inv","ASN Exp.","3PL Imp.","EDI PDA Rec. B. Cl","NEDI PDA Rec. B. Cl","P2P PDA Rec. B. CL";
        Text000Msg: Label 'GTIN%1Validation';
        Text001Msg: Label 'ASN%1ScanDiscrepancy';
        Text002Msg: Label 'PO%1ReceivingDiscrepancy';
        Text003Msg: Label 'CRN%1Notification';


    [Scope('OnPrem')]
    procedure SendPOExportFailureEmail(PurchaseHeader: Record "Purchase Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(0, GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(PurchaseHeader."Buy-from Vendor No.");

        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, PurchaseHeader."No.", '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, PurchaseHeader."No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPORGTINValidationEmail(POResponseHeader: Record "GXL PO Response Header"; var ItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary; LastErrorText: Text): Boolean
    var
        StagingDocRecRef: RecordRef;
        TargetFileName: Text;
        EmailSent: Boolean;
        EmailSent2: Boolean;
    begin
        StagingDocRecRef.GETTABLE(POResponseHeader);
        EmailSent := SendGTINValidationEmail(POResponseHeader."Response Number", ItemSupplierGTINBuffer, POResponseHeader."Buy-from Vendor No.", FALSE, LastErrorText, TargetFileName);

        IF TargetFileName <> '' THEN
            LogEmail(
              1, POResponseHeader."Order No.", 3, POResponseHeader."Response Number", POResponseHeader."Buy-from Vendor No.", 1, EmailSent, TargetFileName, StagingDocRecRef.RecordId(), POResponseHeader."EDI File Log Entry No.", FALSE);

        Commit();

        EmailSent2 := SendGTINValidationEmail(POResponseHeader."Response Number", ItemSupplierGTINBuffer, POResponseHeader."Buy-from Vendor No.", TRUE, LastErrorText, TargetFileName);

        IF TargetFileName <> '' THEN
            LogEmail(
              1, POResponseHeader."Order No.", 3, POResponseHeader."Response Number", POResponseHeader."Buy-from Vendor No.", 1, EmailSent2, TargetFileName, StagingDocRecRef.RecordId(), POResponseHeader."EDI File Log Entry No.", TRUE);

        Commit();
    end;

    [Scope('OnPrem')]
    procedure SendASNGTINValidationEmail(ASNHeader: Record "GXL ASN Header"; var ItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary; LastErrorText: Text): Boolean
    var
        StagingDocRecRef: RecordRef;
        EmailSent: Boolean;
        EmailSent2: Boolean;
        TargetFileName: Text;
    begin
        StagingDocRecRef.GETTABLE(ASNHeader);

        EmailSent := SendGTINValidationEmail(ASNHeader."No.", ItemSupplierGTINBuffer, ASNHeader."Supplier No.", FALSE, LastErrorText, TargetFileName);

        IF TargetFileName <> '' THEN
            LogEmail(
              1, ASNHeader."Purchase Order No.", 4, ASNHeader."No.", ASNHeader."Supplier No.", 1, EmailSent, TargetFileName, StagingDocRecRef.RecordId(), ASNHeader."EDI File Log Entry No.", FALSE);

        Commit();

        EmailSent2 := SendGTINValidationEmail(ASNHeader."No.", ItemSupplierGTINBuffer, ASNHeader."Supplier No.", TRUE, LastErrorText, TargetFileName);

        IF TargetFileName <> '' THEN
            LogEmail(
              1, ASNHeader."Purchase Order No.", 4, ASNHeader."No.", ASNHeader."Supplier No.", 1, EmailSent2, TargetFileName, StagingDocRecRef.RecordId(), ASNHeader."EDI File Log Entry No.", TRUE);

        Commit();
    end;

    [Scope('OnPrem')]
    procedure SendGTINValidationEmail(DocumentNo: Code[50]; var ItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary; VendorNo: Code[20]; ChangedOnly: Boolean; LastErrorText: Text; var TargetFileName: Text): Boolean
    var
        GTINNotification: Report "GXL GTIN Notification";
        FileManagement: Codeunit "File Management";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        FileMngt: Codeunit "File Management";
        EmailSent: Boolean;
        ServerFileName: Text;
        VendorEmail: Text;
        TempPath: Text;
        TargetFileName2: Text;
        FileSize: BigInteger;
        FileModifyDate: Date;
        FileModifyTime: Time;
    begin
        CLEAR(TargetFileName);

        IF NOT GetEDIEmailSetup(1, GuiAllowed()) THEN
            EXIT;

        ItemSupplierGTINBuffer.Reset();

        IF ChangedOnly THEN BEGIN

            IF NOT EDIEmailSetup."Email Supplier" THEN
                EXIT;

            VendorEmail := GetVendorEmail(VendorNo);

            IF VendorEmail = '' THEN
                EXIT;

            ItemSupplierGTINBuffer.SETCURRENTKEY(Change);
            ItemSupplierGTINBuffer.SETRANGE(Change, TRUE);

        END;

        IF ItemSupplierGTINBuffer.IsEMpty() THEN
            EXIT;

        ServerFileName := CreateTempFile();

        GTINNotification.SetGTINBuffer(ItemSupplierGTINBuffer);
        IF GuiAllowed() THEN
            GTINNotification.SAVEASPDF(ServerFileName)
        ELSE
            IF NOT GTINNotification.SAVEASPDF(ServerFileName) THEN
                EXIT;

        TempPath := FileManagement.GetDirectoryName(FileManagement.ServerTempFileName('GTIN'));

        TargetFileName2 := FileMngt.CombinePath(TempPath, GetFileName(1, DocumentNo) + '.' + GetFileExtension());

        DeleteServerFile(TargetFileName2);

        EDIFunctionsLibrary.MoveFile(ServerFileName, TargetFileName2, TRUE);

        TargetFileName := TargetFileName2;
        FileMngt.GetServerFileProperties(TargetFileName, FileModifyDate, FileModifyTime, FileSize);
        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, DocumentNo, '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, DocumentNo, LastErrorText, 0), TargetFileName, FileSize, ChangedOnly);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendImportFailureEmail(ImportWhich: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS; FullFileName: Text; FileName: Text; FileSize: Integer; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
    begin
        IF NOT GetEDIEmailSetup(GetEmailingAreaFromImportWhich(ImportWhich), GuiAllowed()) THEN
            EXIT;

        //this doesn't get sent to the supplier as multiple supplier could use the same import directory
        //and without reading the file we can't determine the supplier number
        EmailSent := SendEmail('', ConvertPlaceHolder(0, EDIEmailSetup.Subject, FileName, '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, FileName, LastErrorText, 0), FullFileName, FileSize, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPORValidationFailureEmail(POResponseHeader: Record "GXL PO Response Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(3, GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(POResponseHeader."Buy-from Vendor No.");
        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, AddOriginalDocNo(POResponseHeader."Response Number", POResponseHeader."Original EDI Document No."), '', 0),
                      ConvertPlaceHolder(1, EDIEmailSetup.Body, POResponseHeader."Response Number", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPORProcessingFailureEmail(POResponseHeader: Record "GXL PO Response Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(4, GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(POResponseHeader."Buy-from Vendor No.");
        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, AddOriginalDocNo(POResponseHeader."Response Number", POResponseHeader."Original EDI Document No."), '', 0),
                               ConvertPlaceHolder(1, EDIEmailSetup.Body, POResponseHeader."Response Number", LastErrorText, 0), '', 0, FALSE);
        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendASNValidationFailureEmail(ASNHeader: Record "GXL ASN Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(6, GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(ASNHeader."Supplier No.");
        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, AddOriginalDocNo(ASNHeader."No.", ASNHeader."Original EDI Document No."), '', 0),
                                                    ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."No.", LastErrorText, 0), '', 0, FALSE);
        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendASNProcessingFailureEmail(ASNHeader: Record "GXL ASN Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(7, GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(ASNHeader."Supplier No.");
        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, AddOriginalDocNo(ASNHeader."No.", ASNHeader."Original EDI Document No."), '', 0),
                               ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."No.", LastErrorText, 0), '', 0, FALSE);
        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendASNScanValidationEmail(ASNHeader: Record "GXL ASN Header"; var TempASNScanningDiscrepancy: Record "GXL ASN Scanning Discrepancy" temporary; LastErrorText: Text): Boolean
    var
        ASNScanningDiscrepancy: Report "GXL ASN Scanning Discrepancy";
        FileManagement: Codeunit "File Management";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        StagingDocRecRef: RecordRef;
        EmailSent: Boolean;
        VendorEmail: Text;
        ServerFileName: Text;
        TargetFileName: Text;
        TempPath: Text;
        FileSize: BigInteger;
        FileModifyDate: Date;
        FileModifyTime: Time;
    begin
        IF NOT GetEDIEmailSetup(8, GuiAllowed()) THEN
            EXIT;

        TempASNScanningDiscrepancy.Reset();
        IF TempASNScanningDiscrepancy.IsEMpty() THEN
            EXIT;

        ServerFileName := CreateTempFile();

        ASNScanningDiscrepancy.SetASNScanningDiscrepancy(TempASNScanningDiscrepancy);
        IF GuiAllowed() THEN
            ASNScanningDiscrepancy.SAVEASPDF(ServerFileName)
        ELSE
            IF NOT ASNScanningDiscrepancy.SAVEASPDF(ServerFileName) THEN
                EXIT;

        TempPath := FileManagement.GetDirectoryName(FileManagement.ServerTempFileName('scan'));

        TargetFileName := FileManagement.CombinePath(TempPath, GetFileName(2, AddOriginalDocNo(ASNHeader."No.", ASNHeader."Original EDI Document No.")) + '.' + GetFileExtension());

        DeleteServerFile(TargetFileName);

        EDIFunctionsLibrary.MoveFile(ServerFileName, TargetFileName, TRUE);
        FileManagement.GetServerFileProperties(TargetFileName, FileModifyDate, FileModifyTime, FileSize);

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(ASNHeader."Supplier No.");
        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, AddOriginalDocNo(ASNHeader."No.", ASNHeader."Original EDI Document No."), '', 0),
                                           ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."No.", LastErrorText, 0), TargetFileName, FileSize, FALSE);
        StagingDocRecRef.GETTABLE(ASNHeader);

        LogEmail(
          1, ASNHeader."Purchase Order No.", 4, ASNHeader."No.", ASNHeader."Supplier No.", 2, EmailSent, TargetFileName, StagingDocRecRef.RecordId(), ASNHeader."EDI File Log Entry No.", (VendorEmail <> ''));

        Commit();

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendASNScanPocessFailureEmail(ASNHeader: Record "GXL ASN Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(9, GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(ASNHeader."Supplier No.");
        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, AddOriginalDocNo(ASNHeader."No.", ASNHeader."Original EDI Document No."), '', 0),
                                           ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."No.", LastErrorText, 0), '', 0, FALSE);
        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendASNReceivingFailureEmail(ASNHeader: Record "GXL ASN Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(10, GuiAllowed()) THEN
            EXIT;
        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(ASNHeader."Supplier No.");
        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, AddOriginalDocNo(ASNHeader."No.", ASNHeader."Original EDI Document No."), '', 0),
                                           ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."No.", LastErrorText, 0), '', 0, FALSE);
        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendASNReceivingDiscrepancyEmail(ASNHeader: Record "GXL ASN Header"; LastErrorText: Text): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        EDIReceivingDiscrepancy: Report "GXL EDI Receiving Discrepancy";
        FileManagement: Codeunit "File Management";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        StagingDocRecRef: RecordRef;
        EmailSent: Boolean;
        VendorEmail: Text;
        ServerFileName: Text;
        TargetFileName: Text;
        TempPath: Text;
        FileSize: BigInteger;
        FileModifyDate: Date;
        FileModifyTime: Time;
    begin
        IF NOT ASNHeader."Receiving Discrepancy" THEN
            EXIT;

        IF NOT GetEDIEmailSetup(11, GuiAllowed()) THEN
            EXIT;

        IF GuiAllowed() THEN BEGIN

            CASE ASNHeader."Document Type" OF

                ASNHeader."Document Type"::Purchase:
                    PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, ASNHeader."Purchase Order No.");

                ASNHeader."Document Type"::Transfer:
                    TransferHeader.GET(ASNHeader."Transfer Order No.");

            END;

        END ELSE BEGIN

            CASE ASNHeader."Document Type" OF

                ASNHeader."Document Type"::Purchase:
                    BEGIN
                        IF NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, ASNHeader."Purchase Order No.") THEN
                            EXIT;
                    END;

                ASNHeader."Document Type"::Transfer:
                    BEGIN
                        IF NOT TransferHeader.GET(ASNHeader."Transfer Order No.") THEN
                            EXIT;
                    END;

            END;

        END;

        ServerFileName := CreateTempFile();

        PurchaseHeader.SetRecFilter();

        EDIReceivingDiscrepancy.SETTABLEVIEW(PurchaseHeader);
        IF GuiAllowed() THEN
            EDIReceivingDiscrepancy.SAVEASPDF(ServerFileName)
        ELSE
            IF NOT EDIReceivingDiscrepancy.SAVEASPDF(ServerFileName) THEN
                EXIT;

        TempPath := FileManagement.GetDirectoryName(FileManagement.ServerTempFileName('receiving'));

        TargetFileName := FileManagement.CombinePath(TempPath, GetFileName(3, ASNHeader."Purchase Order No.") + '.' + GetFileExtension());

        DeleteServerFile(TargetFileName);

        EDIFunctionsLibrary.MoveFile(ServerFileName, TargetFileName, TRUE);

        FileManagement.GetServerFileProperties(TargetFileName, FileModifyDate, FileModifyTime, FileSize);
        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(ASNHeader."Supplier No.");
        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, AddOriginalDocNo(ASNHeader."No.", ASNHeader."Original EDI Document No."), '', 0),
                                           ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."Purchase Order No.", LastErrorText, 0), TargetFileName, FileSize, FALSE);

        StagingDocRecRef.GETTABLE(ASNHeader);

        LogEmail(
          1, ASNHeader."Purchase Order No.", 4, ASNHeader."No.", ASNHeader."Supplier No.", 3, EmailSent, TargetFileName, StagingDocRecRef.RecordId(), ASNHeader."EDI File Log Entry No.", (VendorEmail <> ''));

        Commit();

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendASNReturnOrderCreationFailureEmail(ASNHeader: Record "GXL ASN Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(12, GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(ASNHeader."Supplier No.");
        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, AddOriginalDocNo(ASNHeader."No.", ASNHeader."Original EDI Document No."), '', 0),
                                           ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."Claim Document No.", LastErrorText, 0), '', 0, FALSE);
        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendASNReturnOrderApplicationFailureEmail(ASNHeader: Record "GXL ASN Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(13, GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(ASNHeader."Supplier No.");

        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, AddOriginalDocNo(ASNHeader."No.", ASNHeader."Original EDI Document No."), '', 0),
                                           ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."Claim Document No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendASNReturnOrderReturnShipmentFailureEmail(ASNHeader: Record "GXL ASN Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(14, GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(ASNHeader."Supplier No.");

        EmailSent :=
          SendEmail(VendorEmail,
            ConvertPlaceHolder2(0, EDIEmailSetup.Subject, AddOriginalDocNo(ASNHeader."No.", ASNHeader."Original EDI Document No."), ASNHeader."Supplier No.", ASNHeader."Supplier Name", '', 0),
            ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."Claim Document No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);

    end;

    [Scope('OnPrem')]
    procedure SendINVValidationFailureEmail(POINVHeader: Record "GXL PO INV Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF POINVHeader."EDI Vendor Type" <> POINVHeader."EDI Vendor Type"::VAN THEN BEGIN
            EXIT(SendP2PINVValidationFailureEmail(POINVHeader, LastErrorText));
        END ELSE BEGIN

            IF NOT GetEDIEmailSetup(16, GuiAllowed()) THEN
                EXIT;
            IF EDIEmailSetup."Email Supplier" THEN
                VendorEmail := GetVendorEmail(POINVHeader."Buy-from Vendor No.");

            EmailSent :=
              SendEmail(VendorEmail,
                ConvertPlaceHolder2(0, EDIEmailSetup.Subject, AddOriginalDocNo(POINVHeader."No.", POINVHeader."Original EDI Document No."), POINVHeader."Buy-from Vendor No.", POINVHeader."Supplier Name", '', 0),
                ConvertPlaceHolder(1, EDIEmailSetup.Body, POINVHeader."No.", LastErrorText, 0), '', 0, FALSE);

            EXIT(EmailSent);
        END;
    end;

    [Scope('OnPrem')]
    procedure SendINVProcessingFailureEmail(POINVHeader: Record "GXL PO INV Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF POINVHeader."EDI Vendor Type" IN [POINVHeader."EDI Vendor Type"::"Point 2 Point", POINVHeader."EDI Vendor Type"::"Point 2 Point Contingency"] THEN BEGIN
            EXIT(SendP2PINVProcessingFailureEmail(POINVHeader, LastErrorText));
        END ELSE BEGIN
            IF NOT GetEDIEmailSetup(17, GuiAllowed()) THEN
                EXIT;

            IF EDIEmailSetup."Email Supplier" THEN
                VendorEmail := GetVendorEmail(POINVHeader."Buy-from Vendor No.");
            EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, AddOriginalDocNo(POINVHeader."No.", POINVHeader."Original EDI Document No."), '', 0),
                                               ConvertPlaceHolder(1, EDIEmailSetup.Body, POINVHeader."No.", LastErrorText, 0), '', 0, FALSE);
            EXIT(EmailSent);
        END;
    end;

    [Scope('OnPrem')]
    procedure SendINVReturnCreditFailureEmail(POINVHeader: Record "GXL PO INV Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF POINVHeader."EDI Vendor Type" <> POINVHeader."EDI Vendor Type"::VAN THEN BEGIN
            EXIT(SendP2PINVReturnCreditFailureEmail(POINVHeader, LastErrorText));
        END ELSE BEGIN

            IF NOT GetEDIEmailSetup(18, GuiAllowed()) THEN
                EXIT;

            IF EDIEmailSetup."Email Supplier" THEN
                VendorEmail := GetVendorEmail(POINVHeader."Buy-from Vendor No.");

            EmailSent :=
              SendEmail(VendorEmail,
                ConvertPlaceHolder2(0, EDIEmailSetup.Subject, AddOriginalDocNo(POINVHeader."No.", POINVHeader."Original EDI Document No."), POINVHeader."Buy-from Vendor No.", POINVHeader."Supplier Name", '', 0),
                ConvertPlaceHolder(1, EDIEmailSetup.Body, POINVHeader."No.", LastErrorText, 0), '', 0, FALSE);

            EXIT(EmailSent);

        END;
    end;

    [Scope('OnPrem')]
    procedure SendINVCreditNotificationEmail(POINVHeader: Record "GXL PO INV Header"; LastErrorText: Text): Boolean
    var
        ASNHeader: Record "GXL ASN Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(19, GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(POINVHeader."Buy-from Vendor No.");

        IF GuiAllowed() THEN
            ASNHeader.GET(ASNHeader."Document Type"::Purchase, POINVHeader."ASN Number")
        ELSE
            IF NOT ASNHeader.GET(ASNHeader."Document Type"::Purchase, POINVHeader."ASN Number") THEN
                EXIT;

        IF GuiAllowed() THEN
            PurchCrMemoHdr.GET(ASNHeader."Claim Credit Memo No.")
        ELSE
            IF NOT PurchCrMemoHdr.GET(ASNHeader."Claim Credit Memo No.") THEN
                EXIT;

        PurchCrMemoHdr.CALCFIELDS(PurchCrMemoHdr."Amount Including VAT");

        EmailSent :=
          SendEmail(VendorEmail,
            ConvertPlaceHolder2(0, EDIEmailSetup.Subject, AddOriginalDocNo(ASNHeader."No.", ASNHeader."Original EDI Document No."), ASNHeader."Supplier No.", ASNHeader."Supplier Name", '', 0),
            ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."No.", LastErrorText, PurchCrMemoHdr."Amount Including VAT"), '', 0, FALSE);

        EXIT(EmailSent);

    end;

    [Scope('OnPrem')]
    procedure SendEmail(VendorEmail: Text; Subject: Text; Body: Text; FileName: Text; FileSize: Integer; EmailVendorOnly: Boolean): Boolean
    var
        // >> Upgrade
        //SMTPMail: Codeunit "SMTP Mail";
        SMTPMail: Codeunit "Email Message";
        FileMgt: Codeunit "File Management";
        RecipientType: Enum "Email Recipient Type";
        Email: Codeunit Email;
        EmailScenario: enum "Email Scenario";
        Files: File;
        Instr: InStream;

        // << Upgrade
        SendSMTPMail: Boolean;
    begin
        IF NOT CheckSMTPSetup(GuiAllowed()) THEN
            EXIT;
        // >> Upgrade
        //SMTPMail.CreateMessage('', SMTPMailSetup."User ID", GetEmailTo(EDIEmailSetup."Email To", VendorEmail, EmailVendorOnly), Subject, Body, TRUE);
        SMTPMail.Create(GetEmailTo(EDIEmailSetup."Email To", VendorEmail, EmailVendorOnly), Subject, Body, TRUE);
        // << Upgrade
        IF EDIEmailSetup."Email CC" <> '' THEN BEGIN
            IF GuiAllowed() THEN
                //SMTPMail.AddCC(EDIEmailSetup."Email CC")
                SMTPMail.SetRecipients(RecipientType::Cc, EDIEmailSetup."Email CC")
            ELSE
                //SMTPMail.AddCC(EDIEmailSetup."Email CC"); //TODO This line should not raise an error.
                SMTPMail.SetRecipients(RecipientType::Cc, EDIEmailSetup."Email CC"); //TODO This line should not raise an error.
                                                                                     //IF SMTPMail.AddCC2(EDIEmailSetup."Email CC") THEN;
        END;

        IF FileName <> '' THEN BEGIN
            IF FileSizeAllowed(FileSize) THEN BEGIN
                // >> Upgrade
                Files.Open(FileName);
                Files.CreateInStream(Instr);
                // << Upgrade
                IF GuiAllowed() THEN
                    // >> Upgrade
                    //SMTPMail.AddAttachment(FileName, GetFileNameFromAttachment(FileName))
                    SMTPMail.AddAttachment(GetFileNameFromAttachment(FileName), FileMgt.GetExtension(FileName), Instr)
                // << Upgrade
                ELSE
                    // >> Upgrade
                    //SMTPMail.AddAttachment(FileName, GetFileNameFromAttachment(FileName)); //TODO this line should not raise an error
                    SMTPMail.AddAttachment(GetFileNameFromAttachment(FileName), FileMgt.GetExtension(FileName), Instr) //TODO this line should not raise an error
                                                                                                                       // << Upgrade                                                                                                  // IF SMTPMail.AddAttachment2(FileName) THEN; //this function doesn't error
            END;
        END;

        // >> Upgrade
        //SendSMTPMail := SMTPMail.TrySend();
        SendSMTPMail := Email.Send(SMTPMail, EmailScenario);
        //IF SMTPMail.GetLastSendMailErrorText() <> '' THEN
        //MESSAGE('EDI Email Management Last Email Error Text:\ ' + SMTPMail.GetLastSendMailErrorText());
        if GetLastErrorText() <> '' then
            MESSAGE('EDI Email Management Last Email Error Text:\ ' + GetLastErrorText());
        // << Upgrade
        EXIT(SendSMTPMail);
    end;

    local procedure CheckSMTPSetup(ShowErrors: Boolean): Boolean
    var
        EmailFunctions: Codeunit "GXL Email Functions";
        AutoImport: Codeunit "GXL Auto Import IC Trans";
        SMTPError: Label 'SMTP Setup does not exist';
    begin
        IF ShowErrors THEN BEGIN
            // >> Upgrade
            // SMTPMailSetup.Get();
            // SMTPMailSetup.TESTFIELD("SMTP Server");
            // SMTPMailSetup.TESTFIELD("User ID");
            // EmailFunctions.CheckValidEmailAddresses(SMTPMailSetup."User ID");
            // >> 001
            // if not AutoImport.CheckSMTPSetup() then
            //     Error(SMTPError);
            if AutoImport.CheckSMTPSetup() then
                exit(true)
            else
                Error(SMTPError);
            // << 001
            // << Upgrade
        END ELSE BEGIN
            // >> Upgrade
            // IF SMTPMailSetup.Get() THEN BEGIN
            //     IF (SMTPMailSetup."SMTP Server" = '') THEN
            //         EXIT(FALSE);
            //     IF (SMTPMailSetup."User ID" = '') THEN
            //         EXIT(FALSE);
            //     IF NOT EmailFunctions.CheckValidEmailAddresses2(SMTPMailSetup."User ID") THEN
            //         EXIT(FALSE);
            // END ELSE
            //     EXIT(FALSE);
            exit(AutoImport.CheckSMTPSetup());
            // << Upgrade
        END;

        //EXIT(TRUE); // >> Upgrade <<
    end;

    local procedure GetEDISetup(ShowErrors: Boolean): Boolean
    begin
        IF ShowErrors THEN BEGIN
            IntegrationSetup.Get();
        END ELSE BEGIN
            IF NOT IntegrationSetup.Get() THEN
                EXIT(FALSE);
        END;

        EXIT(TRUE);
    end;

    local procedure GetEDIEmailSetup(AreaOfEmailing: Option "PO Exp","GTIN Valid","POR Imp","POR Valid","POR Proc","ASN Imp","ASN Valid","ASN Proc","ASN Scan Valid","ASN Scan Proc","ASN Receive","ASN Rec Discr","ASN Ret Ord Creation","ASN Ret Ord Appl","ASN Ret Ship Post","INV Imp","INV Valid","INV ProcINV Cr Post","INV Credit Notif","P2P POR Imp","P2P POR Valid","P2P POR Proc","P2P ASN Imp","P2P INV Imp","P2P INV Valid","P2P INV Proc","P2P INV Cr Post","P2P INV Cr Notif","PO Scan Proc","PO Rec","PO Rec Discr","PO Ret Ord Creation","PO Ret Appl","PO Ret Ship Post","PO INV Post","PO Cr Creation","PO Cr Appl","PO Cr Post","PO Cr Post Notifi","PO Cr Creation Notif","Stk Adj Valid","StkAdj Creation","Stk Adj App","Stk Adj Post","Manual Inv","ASN Exp","3PL Imp","EDI PDA Rec B. Cl","NEDI PDA Rec B. Cl","P2P PDA Rec B. CL","ShipAdv Imp","ShipAdv Valid","ShipAdv Proc"; ShowErrors: Boolean): Boolean
    begin
        IF ShowErrors THEN BEGIN
            EDIEmailSetup.GET(AreaOfEmailing);
        END ELSE BEGIN
            IF NOT EDIEmailSetup.GET(AreaOfEmailing) THEN
                EXIT(FALSE);
        END;

        EXIT(TRUE);
    end;

    local procedure GetEmailTo(EDIEmailSetupEmailTo: Text; VendorEmail: Text; EmailVendorOnly: Boolean): Text
    begin
        IF EmailVendorOnly THEN
            EXIT(VendorEmail);

        IF (EDIEmailSetupEmailTo = '') AND (VendorEmail = '') THEN
            EXIT;

        IF VendorEmail = '' THEN
            EXIT(EDIEmailSetupEmailTo);

        IF EDIEmailSetupEmailTo = '' THEN
            EXIT(VendorEmail)
        ELSE
            EXIT(EDIEmailSetupEmailTo + ';' + VendorEmail);
    end;

    local procedure GetEmailingAreaFromImportWhich(ImportWhich: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS): Integer
    begin
        CASE ImportWhich OF

            ImportWhich::PO, ImportWhich::POX:
                ;

            ImportWhich::POR:
                EXIT(2);

            ImportWhich::ASN:
                EXIT(ProcessAreaOfEmailing::"ASN Imp.");

            ImportWhich::INV:
                EXIT(15);

            ImportWhich::SHIPSTATUS:
                EXIT(50);
        END;
    end;

    local procedure GetFileExtension(): Text
    begin
        EXIT('pdf');
    end;

    local procedure GetFileName(Which: Option " ","GTIN Validation","ASN Scan Validation","ASN Receiving Discrepancy","INV Credit Notification"; DocumentNo: Code[50]): Text
    begin
        // ,GTIN Validation,ASN Scan Validation,ASN Receiving Discrepancy,INV Credit Notification
        CASE Which OF

            Which::"GTIN Validation":
                EXIT(STRSUBSTNO(Text000Msg, DocumentNo));

            Which::"ASN Scan Validation":
                EXIT(STRSUBSTNO(Text001Msg, DocumentNo));

            Which::"ASN Receiving Discrepancy":
                EXIT(STRSUBSTNO(Text002Msg, DocumentNo));

            Which::"INV Credit Notification":
                EXIT(STRSUBSTNO(Text003Msg, DocumentNo));

            ELSE
                EXIT;

        END;
    end;

    local procedure GetVendorEmail(VendorNo: Code[20]): Text
    var
        Vendor: Record Vendor;
    begin
        IF VendorNo = '' THEN
            EXIT;

        IF GuiAllowed() THEN
            Vendor.GET(VendorNo)
        ELSE
            IF Vendor.GET(VendorNo) THEN;

        EXIT(Vendor."GXL EDI Email Address");
    end;

    local procedure ConvertPlaceHolder(InputType: Option Subject,Body; InputText: Text; ReplacementText: Text; ErrorText: Text; Amount: Decimal): Text
    begin
        CASE InputType OF

            InputType::Subject:
                EXIT(STRSUBSTNO(InputText, ReplacementText));

            InputType::Body:
                EXIT(STRSUBSTNO(InputText, ReplacementText, ErrorText, Amount));

        END;
    end;

    local procedure CreateTempFile(): Text
    var
        FileManagement: Codeunit "File Management";
    begin
        EXIT(FileManagement.ServerTempFileName(GetFileExtension()));
    end;

    local procedure DeleteServerFile(FilePath: Text): Boolean
    var
        // >> Upgrade
        //ServerFileHelper: DotNet File;
        ServerFileHelper: DotNet File1;
    // << Upgrade
    begin
        IF NOT ServerFileHelper.Exists(FilePath) THEN
            EXIT(FALSE);

        ServerFileHelper.Delete(FilePath);
        EXIT(TRUE);
    end;

    local procedure FileSizeAllowed(FileSize: Decimal): Boolean
    var
        SizeInBytes: Integer;
        AllowedSizeInBytes: Integer;
        // >> Upgrade
        IntSetup: Record "GXL Integration Setup";
    // << Upgrade
    begin
        // >> Upgrade
        // IF (SMTPMailSetup."GXL Maximum Message Size in MB" = 0) THEN
        //     EXIT(TRUE);

        // SizeInBytes := SMTPMailSetup."GXL Maximum Message Size in MB" * 1000000;
        if IntSetup."GXL Maximum Message Size in MB" = 0 then
            exit(true);
        SizeInBytes := IntSetup."GXL Maximum Message Size in MB" * 1000000;
        // << Upgrade
        AllowedSizeInBytes := SizeInBytes - 200000; //200KB for message text

        EXIT(AllowedSizeInBytes >= FileSize);
    end;

    local procedure LogEmail(OrderType: Option " ",PO,STO; OrderNo: Code[20]; DocumentType: Option " ",PO,POX,POR,ASN,INV; DocumentNo: Code[50]; VendorNo: Code[20]; ReportType: Option " ","GTIN Validation","ASN Scan Validation","ASN Receiving Discrepancy","INV Credit Notification"; EmailSent: Boolean; AttachmentFileName: Text; StagingRecordID: RecordID; EDIFileLogEntryNo: Integer; EmailSentToVendor: Boolean)
    var
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        EDIReportLog: Record "GXL EDI Report Log";
        // >> Upgrade
        //TempBlob: Record TempBlob temporary;
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        FldRef: FieldRef;
        // << Upgrade
        FileManagement: Codeunit "File Management";
        DocRecRef: RecordRef;
    begin
        ClearLog();

        CASE OrderType OF

            OrderType::PO:
                BEGIN

                    IF GuiAllowed() THEN
                        PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, OrderNo)
                    ELSE
                        IF NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, OrderNo) THEN
                            EXIT;

                    DocRecRef.GETTABLE(PurchaseHeader);

                END;

            OrderType::STO:
                BEGIN

                    IF GuiAllowed() THEN
                        TransferHeader.GET(OrderNo)
                    ELSE
                        IF NOT TransferHeader.GET(OrderNo) THEN
                            EXIT;

                    DocRecRef.GETTABLE(TransferHeader);

                END;

        END;

        EDIReportLog.Init();
        EDIReportLog."Entry No." := 0;
        EDIReportLog."Order Type" := OrderType;
        EDIReportLog."Order No." := OrderNo;
        EDIReportLog."Document Type" := DocumentType;
        EDIReportLog."Document No." := DocumentNo;
        EDIReportLog."Vendor No." := VendorNo;
        EDIReportLog."Report Type" := ReportType;
        // >> Upgrade
        //CLEAR(TempBlob.Blob);
        CLEAR(TempBlob);
        // << Upgrade
        FileManagement.BLOBImportFromServerFile(TempBlob, AttachmentFileName);
        // >> Upgrade
        //EDIReportLog.Attachment := TempBlob.Blob;
        RecRef.GetTable(EDIReportLog);
        FldRef := RecRef.Field(EDIReportLog.FieldNo(Attachment));
        TempBlob.ToFieldRef(FldRef);
        // << Upgrade
        EDIReportLog."Attachment File Name" := FileManagement.GetFileName(AttachmentFileName);

        EDIReportLog."Email Sent" := EmailSent;
        EDIReportLog."Record ID" := DocRecRef.RecordId();
        EDIReportLog."Staging Record ID" := StagingRecordID;
        EDIReportLog."EDI File Log Entry No." := EDIFileLogEntryNo;
        EDIReportLog."Email Sent to Vendor" := EmailSentToVendor;

        EDIReportLog.INSERT(TRUE);
    end;

    local procedure ClearLog()
    var
        EDIReportLog: Record "GXL EDI Report Log";
        DummyDateFormula: DateFormula;
        ClearLogDateTime: DateTime;
    begin
        IF NOT GetEDISetup(GuiAllowed()) THEN
            EXIT;

        IF (IntegrationSetup."Log Age for Deletion" <> DummyDateFormula) THEN BEGIN

            ClearLogDateTime := CREATEDATETIME(CALCDATE(IntegrationSetup."Log Age for Deletion", Today()), 0T);

            EDIReportLog.SETCURRENTKEY("Date/Time");
            EDIReportLog.SETFILTER("Date/Time", '<=%1', ClearLogDateTime);
            EDIReportLog.DELETEALL(TRUE);

        END;
    end;

    [Scope('OnPrem')]
    procedure SendP2PImportFailureEmail(ImportWhich: Option PO,POX,POR,ASN,INV; FullFileName: Text; FileName: Text; FileSize: Integer; LastErrorText: Text; VendorNo: Code[20]): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(GetP2PEmailingAreaFromImportWhich(ImportWhich), GuiAllowed()) THEN
            EXIT;

        // Email Supplier
        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(VendorNo);

        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, FileName, '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, FileName, LastErrorText, 0), FullFileName, FileSize, FALSE);

        EXIT(EmailSent);
    end;

    local procedure GetP2PEmailingAreaFromImportWhich(ImportWhich: Option PO,POX,POR,ASN,INV): Integer
    begin
        CASE ImportWhich OF

            ImportWhich::PO, ImportWhich::POX:
                ;

            ImportWhich::POR:
                EXIT(ProcessAreaOfEmailing::"P2P POR Imp.");

            ImportWhich::ASN:
                EXIT(ProcessAreaOfEmailing::"P2P ASN Imp.");

            ImportWhich::INV:
                EXIT(ProcessAreaOfEmailing::"P2P INV Imp.");
        END;
    end;

    [Scope('OnPrem')]
    procedure SendP2PPORGTINValidationEmail(EDIPurchaseMessages: Record "GXL EDI-Purchase Messages"; var ItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary; LastErrorText: Text): Boolean
    var
        StagingDocRecRef: RecordRef;
        TargetFileName: Text;
        EmailSent: Boolean;
        EmailSent2: Boolean;
    begin
        StagingDocRecRef.GETTABLE(EDIPurchaseMessages);

        EmailSent := SendGTINValidationEmail(EDIPurchaseMessages.DocumentNumber, ItemSupplierGTINBuffer, EDIPurchaseMessages."Vendor No.", FALSE, LastErrorText, TargetFileName);

        IF TargetFileName <> '' THEN
            LogEmail(
              1, EDIPurchaseMessages.DocumentNumber, 3, EDIPurchaseMessages.DocumentNumber, EDIPurchaseMessages."Vendor No.", 1, EmailSent, TargetFileName, StagingDocRecRef.RecordId(), EDIPurchaseMessages."EDI File Log Entry No.", FALSE);

        Commit();

        EmailSent2 := SendGTINValidationEmail(EDIPurchaseMessages.DocumentNumber, ItemSupplierGTINBuffer, EDIPurchaseMessages."Vendor No.", TRUE, LastErrorText, TargetFileName);

        IF TargetFileName <> '' THEN
            LogEmail(
              1, EDIPurchaseMessages.DocumentNumber, 3, EDIPurchaseMessages.DocumentNumber, EDIPurchaseMessages."Vendor No.", 1, EmailSent2, TargetFileName, StagingDocRecRef.RecordId(), EDIPurchaseMessages."EDI File Log Entry No.", TRUE);

        Commit();
    end;

    [Scope('OnPrem')]
    procedure SendP2PPORValidationFailureEmail(EDIPurchaseMessage: Record "GXL EDI-Purchase Messages"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"P2P POR Valid.", GuiAllowed()) THEN
            EXIT;
        // Email Supplier
        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(EDIPurchaseMessage."Vendor No.");

        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, EDIPurchaseMessage.DocumentNumber, '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, EDIPurchaseMessage.DocumentNumber, LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendP2PPORProcessingFailureEmail(EDIPurchaseMessage: Record "GXL EDI-Purchase Messages"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"P2P POR Proc.", GuiAllowed()) THEN
            EXIT;
        // Do not Email Supplier
        EmailSent := SendEmail('', ConvertPlaceHolder(0, EDIEmailSetup.Subject, EDIPurchaseMessage.DocumentNumber, '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, EDIPurchaseMessage.DocumentNumber, LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendP2PINVValidationFailureEmail(POINVHeader: Record "GXL PO INV Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"P2P INV Valid.", GuiAllowed()) THEN
            EXIT;
        // Email Supplier
        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(POINVHeader."Buy-from Vendor No.");

        EmailSent :=
          SendEmail(VendorEmail,
            ConvertPlaceHolder2(0, EDIEmailSetup.Subject, POINVHeader."Purchase Order No.", POINVHeader."Buy-from Vendor No.", POINVHeader."Supplier Name", '', 0),
            ConvertPlaceHolder(1, EDIEmailSetup.Body, POINVHeader."Purchase Order No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);

    end;

    [Scope('OnPrem')]
    procedure SendP2PINVProcessingFailureEmail(POINVHeader: Record "GXL PO INV Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"P2P INV Proc.", GuiAllowed()) THEN
            EXIT;

        EmailSent := SendEmail('', ConvertPlaceHolder(0, EDIEmailSetup.Subject, POINVHeader."Purchase Order No.", '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, POINVHeader."Purchase Order No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendP2PINVReturnCreditFailureEmail(POINVHeader: Record "GXL PO INV Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"P2P INV Cr. Post", GuiAllowed()) THEN
            EXIT;

        // Email Supplier
        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(POINVHeader."Buy-from Vendor No.");

        EmailSent :=
          SendEmail(VendorEmail,
            ConvertPlaceHolder2(0, EDIEmailSetup.Subject, POINVHeader."Purchase Order No.", POINVHeader."Buy-from Vendor No.", POINVHeader."Supplier Name", '', 0),
            ConvertPlaceHolder(1, EDIEmailSetup.Body, POINVHeader."Purchase Order No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendP2PINVCreditNotificationEmail(POINVHeader: Record "GXL PO INV Header"; LastErrorText: Text): Boolean
    var
        ASNHeader: Record "GXL ASN Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"P2P INV Cr. Notifi.", GuiAllowed()) THEN
            EXIT;

        // Email Supplier
        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(POINVHeader."Buy-from Vendor No.");

        IF GuiAllowed() THEN
            ASNHeader.GET(ASNHeader."Document Type"::Purchase, POINVHeader."ASN Number")
        ELSE
            IF NOT ASNHeader.GET(ASNHeader."Document Type"::Purchase, POINVHeader."ASN Number") THEN
                EXIT;

        IF GuiAllowed() THEN
            PurchCrMemoHdr.GET(ASNHeader."Claim Credit Memo No.")
        ELSE
            IF NOT PurchCrMemoHdr.GET(ASNHeader."Claim Credit Memo No.") THEN
                EXIT;

        PurchCrMemoHdr.CALCFIELDS(PurchCrMemoHdr."Amount Including VAT");

        EmailSent :=
          SendEmail(VendorEmail,
            ConvertPlaceHolder2(0, EDIEmailSetup.Subject, ASNHeader."Purchase Order No.", ASNHeader."Supplier No.", ASNHeader."Supplier Name", '', 0),
            ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."Purchase Order No.", LastErrorText, PurchCrMemoHdr."Amount Including VAT"), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPOScanPocessFailureEmail(DocumentNo: Code[20]; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Scan Proc.", GuiAllowed()) THEN
            EXIT;

        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, DocumentNo, '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, DocumentNo, LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPOReceivingFailureEmail(PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Rec.", GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(PDAPLReceiveBuffer."Vendor No.");

        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, PDAPLReceiveBuffer."Document No.", '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, PDAPLReceiveBuffer."Document No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPOReceivingDiscrepancyEmail(PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        POReceivingDiscrepancy: Report "GXL PO Receiving Discrepancy";
        FileManagement: Codeunit "File Management";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        StagingDocRecRef: RecordRef;
        EmailSent: Boolean;
        VendorEmail: Text;
        ServerFileName: Text;
        TargetFileName: Text;
        TempPath: Text;
        FileSize: BigInteger;
        FileModifyDate: Date;
        FileModifyTime: Time;
    begin

        IF NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, PDAPLReceiveBuffer."Document No.") THEN
            EXIT;

        PurchaseHeader.CALCFIELDS("GXL Receiving Discrepancy");
        IF NOT PurchaseHeader."GXL Receiving Discrepancy" THEN
            EXIT;
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Rec. Discr.", GuiAllowed()) THEN
            EXIT;


        ServerFileName := CreateTempFile();

        PurchaseHeader.SetRecFilter();

        POReceivingDiscrepancy.SETTABLEVIEW(PurchaseHeader);
        IF GuiAllowed() THEN
            POReceivingDiscrepancy.SAVEASPDF(ServerFileName)
        ELSE
            IF NOT POReceivingDiscrepancy.SAVEASPDF(ServerFileName) THEN
                EXIT;

        TempPath := FileManagement.GetDirectoryName(FileManagement.ServerTempFileName('Receiving'));

        TargetFileName := FileManagement.CombinePath(TempPath, GetFileName(3, PurchaseHeader."No.") + '.' + GetFileExtension());

        DeleteServerFile(TargetFileName);

        EDIFunctionsLibrary.MoveFile(ServerFileName, TargetFileName, TRUE);

        FileManagement.GetServerFileProperties(TargetFileName, FileModifyDate, FileModifyTime, FileSize);
        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(PurchaseHeader."Buy-from Vendor No.");

        EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, PurchaseHeader."No.", '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, PurchaseHeader."No.", '', 0), TargetFileName, FileSize, FALSE);

        StagingDocRecRef.GETTABLE(PDAPLReceiveBuffer);

        LogEmail(
          1, PurchaseHeader."No.", 4, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No.", 3, EmailSent, TargetFileName, StagingDocRecRef.RecordId(), PDAPLReceiveBuffer."EDI File Log Entry No.", (VendorEmail <> ''));

        Commit();

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPOClaimApplicationFailureEmail(PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; LastErrorText: Text): Boolean
    var
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF PDAPLReceiveBuffer."Vendor Ullaged Status" = PDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged THEN BEGIN
            IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Ret. Appl.", GuiAllowed()) THEN
                EXIT;
            PDAPLReceiveBuffer2.GET(PDAPLReceiveBuffer."Entry No.");
            EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, PDAPLReceiveBuffer."Document No.", '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, PDAPLReceiveBuffer2."Claim Document No.", LastErrorText, 0), '', 0, FALSE);
        END ELSE BEGIN
            IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Cr. Appl.", GuiAllowed()) THEN
                EXIT;
            PDAPLReceiveBuffer2.GET(PDAPLReceiveBuffer."Entry No.");
            EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, PDAPLReceiveBuffer."Document No.", '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, PDAPLReceiveBuffer2."Claim Document No.", LastErrorText, 0), '', 0, FALSE);
        END;
        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPOReturnOrderReturnShipmentFailureEmail(PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; LastErrorText: Text): Boolean
    var
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        Vendor: Record Vendor;
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Ret. Ship Post", GuiAllowed()) THEN
            EXIT;

        PDAPLReceiveBuffer2.GET(PDAPLReceiveBuffer."Entry No.");

        IF Vendor.GET(PDAPLReceiveBuffer."Vendor No.") THEN;

        EmailSent :=
          SendEmail(VendorEmail,
            ConvertPlaceHolder2(0, EDIEmailSetup.Subject, PDAPLReceiveBuffer."Document No.", Vendor."No.", Vendor.Name, '', 0),
            ConvertPlaceHolder(1, EDIEmailSetup.Body, PDAPLReceiveBuffer2."Claim Document No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPOINVPostingFailureEmail(PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
    begin
        EmailSent := false;
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO INV Post", GuiAllowed()) THEN
            EXIT;

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPOReturnCreditPostingFailureEmail(PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; LastErrorText: Text): Boolean
    var
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        Vendor: Record Vendor;
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Cr. Post", GuiAllowed()) THEN
            EXIT;

        PDAPLReceiveBuffer2.GET(PDAPLReceiveBuffer."Entry No.");

        IF Vendor.GET(PDAPLReceiveBuffer."Vendor No.") THEN;

        EmailSent :=
          SendEmail(VendorEmail,
            ConvertPlaceHolder2(0, EDIEmailSetup.Subject, PDAPLReceiveBuffer."Document No.", Vendor."No.", Vendor.Name, '', 0),
            ConvertPlaceHolder(1, EDIEmailSetup.Body, PDAPLReceiveBuffer2."Claim Document No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPOCreditCreationNotificationEmail(PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"): Boolean
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Cr. Creation Notifi.", GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(PDAPLReceiveBuffer."Vendor No.");

        PDAPLReceiveBuffer2.GET(PDAPLReceiveBuffer."Entry No.");

        IF PurchCrMemoHdr.GET(PDAPLReceiveBuffer2."Purchase Credit Memo No.") THEN;

        EmailSent :=
          SendEmail(VendorEmail,
            ConvertPlaceHolder2(0, EDIEmailSetup.Subject, PDAPLReceiveBuffer2."Document No.", PurchCrMemoHdr."Pay-to Vendor No.", PurchCrMemoHdr."Pay-to Name", '', 0),
            ConvertPlaceHolder(1, EDIEmailSetup.Body, PDAPLReceiveBuffer2."Claim Document No.", PDAPLReceiveBuffer2."Document No.", 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendPOCreditPostingNotificationEmail(PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"): Boolean
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        StagingDocRecRef: RecordRef;
        EmailSent: Boolean;
        VendorEmail: Text;
        FileSize: BigInteger;
        FileName: Text;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Cr. Post Notifi.", GuiAllowed()) THEN
            EXIT;

        IF EDIEmailSetup."Email Supplier" THEN
            VendorEmail := GetVendorEmail(PDAPLReceiveBuffer."Vendor No.");

        PDAPLReceiveBuffer2.GET(PDAPLReceiveBuffer."Entry No.");

        PrintPurchaseCreditNote(PDAPLReceiveBuffer2."Purchase Credit Memo No.", FileName, FileSize);

        IF PurchCrMemoHdr.GET(PDAPLReceiveBuffer2."Purchase Credit Memo No.") THEN BEGIN
            PurchCrMemoHdr.CALCFIELDS("Amount Including VAT");

            IF EDIEmailSetup."Email Supplier" THEN
                VendorEmail := GetVendorEmail(PurchCrMemoHdr."Buy-from Vendor No.");

            EmailSent :=
              SendEmail(VendorEmail,
                ConvertPlaceHolder2(0, EDIEmailSetup.Subject, PDAPLReceiveBuffer."Document No.", PurchCrMemoHdr."Pay-to Vendor No.", PurchCrMemoHdr."Pay-to Name", '', 0),
                ConvertPlaceHolder(1, EDIEmailSetup.Body, PDAPLReceiveBuffer2."Purchase Credit Memo No.", PDAPLReceiveBuffer."Document No.", 0), FileName, FileSize, FALSE);

            StagingDocRecRef.GETTABLE(PDAPLReceiveBuffer);

            LogEmail(
               1, PDAPLReceiveBuffer."Document No.", 4, PDAPLReceiveBuffer."Document No.",
                   PDAPLReceiveBuffer."Vendor No.", 3, EmailSent, FileName, StagingDocRecRef.RecordId(), PDAPLReceiveBuffer2."EDI File Log Entry No.", (VendorEmail <> ''));

            Commit();
        END;
        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendStockAdjustmentFailureEmail(ProcessWhat: Option "Validate and Export",Import,Validate,Process,Scan,Receive,"Create Claim Document","Apply Return Order","Post Return Shipment","Post Return Credit","Complete without Posting Return Credit","Clear Buffer","Move To Processing Buffer","Create Transfer","Ship Transfer","Receive Transfer","Post Journal"; PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        SubjectText: Text;
    begin
        IF NOT GetEDIEmailSetup(GetStockAdjustmentEmailingAreaFromProcessWhat(ProcessWhat), GuiAllowed()) THEN
            EXIT;

        SubjectText := '';
        IF ProcessWhat <> ProcessWhat::Validate THEN
            SubjectText := ' ' + FORMAT(ProcessWhat);

        EmailSent :=
          //PDA Batch ID is no longer applicable
          //SendEmail('', ConvertPlaceHolder(0, EDIEmailSetup.Subject, FORMAT(PDAStAdjProcessingBuffer."PDA Batch ID") + SubjectText, '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, '', LastErrorText, 0), '', 0, FALSE);
          SendEmail('', ConvertPlaceHolder(0, EDIEmailSetup.Subject, FORMAT(PDAStAdjProcessingBuffer."Entry No.") + SubjectText, '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, '', LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    local procedure GetStockAdjustmentEmailingAreaFromProcessWhat(ProcessWhat: Option "Validate and Export",Import,Validate,Process,Scan,Receive,"Create Claim Document","Apply Return Order","Post Return Shipment","Post Return Credit","Complete without Posting Return Credit","Clear Buffer","Move To Processing Buffer","Create Transfer","Ship Transfer","Receive Transfer","Post Journal"): Integer
    begin
        // 00 Validate and Export
        // 01 Import
        // 02 Validate
        // 03 Process
        // 04 Scan
        // 05 Receive
        // 06 Create Claim Document
        // 07 Apply Return Order
        // 08 Post Return Shipment
        // 09 Post Return Credit
        // 10 Complete without Posting Return Credit
        // 11 Clear Buffer
        // 12 Move To Process Buffer
        // 13 Create Transfer
        // 14 Ship Transfer
        // 15 Receive Transfer
        // 16 Post Journal
        // 17 Manually Invoice

        CASE ProcessWhat OF
            ProcessWhat::Validate:
                EXIT(ProcessAreaOfEmailing::"Stk Adj. Valid.");
            ProcessWhat::"Create Claim Document",
          ProcessWhat::"Create Transfer":
                EXIT(ProcessAreaOfEmailing::"Stk Adj. Creation");
            ProcessWhat::"Apply Return Order":
                EXIT(ProcessAreaOfEmailing::"Stk Adj. App");
            ProcessWhat::"Post Return Shipment",
          ProcessWhat::"Post Return Credit",
          ProcessWhat::"Ship Transfer",
          ProcessWhat::"Receive Transfer",
          ProcessWhat::"Post Journal":
                EXIT(ProcessAreaOfEmailing::"Stk Adj. Post");
            ELSE
                EXIT;
        END;
    end;

    [Scope('OnPrem')]
    procedure SendPOClaimCreationFailureEmail(PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        VendorEmail: Text;
    begin
        IF PDAPLReceiveBuffer."Vendor Ullaged Status" = PDAPLReceiveBuffer."Vendor Ullaged Status"::Ullaged THEN BEGIN

            IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Ret. Or. Creation", GuiAllowed()) THEN
                EXIT;
            EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, PDAPLReceiveBuffer."Document No.", '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, PDAPLReceiveBuffer."Document No.", LastErrorText, 0), '', 0, FALSE);

        END ELSE BEGIN

            IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Cr. Creation", GuiAllowed()) THEN
                EXIT;
            EmailSent := SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, PDAPLReceiveBuffer."Document No.", '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, PDAPLReceiveBuffer."Document No.", LastErrorText, 0), '', 0, FALSE);
        END;

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendStockAdjustmentCreditNotificationEmail(PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer"): Boolean
    var
        PDAStAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        StagingDocRecRef: RecordRef;
        EmailSent: Boolean;
        VendorEmail: Text;
        FileSize: BigInteger;
        FileName: Text;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"PO Cr. Post Notifi.", GuiAllowed()) THEN
            EXIT;

        PDAStAdjProcessingBuffer2.GET(PDAStAdjProcessingBuffer."Entry No.");

        IF PDAStAdjProcessingBuffer2.Status <> PDAStAdjProcessingBuffer2.Status::"Credit Posted" THEN
            EXIT;
        IF GuiAllowed() THEN
            PurchCrMemoHdr.GET(PDAStAdjProcessingBuffer2."Posted Credit Memo No.")
        ELSE
            IF NOT PurchCrMemoHdr.GET(PDAStAdjProcessingBuffer2."Posted Credit Memo No.") THEN
                EXIT;

        PurchCrMemoHdr.CALCFIELDS(PurchCrMemoHdr."Amount Including VAT");

        IF PDAStAdjProcessingBuffer."Vendor Ullaged Status" = PDAStAdjProcessingBuffer."Vendor Ullaged Status"::Ullaged THEN BEGIN

            IF EDIEmailSetup."Email Supplier" THEN
                VendorEmail := GetVendorEmail(PDAStAdjProcessingBuffer2."Claim-to Vendor No.");

            EmailSent :=
              SendEmail(VendorEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, PDAStAdjProcessingBuffer2."Claim-to Order No.", '', 0),
              ConvertPlaceHolder(1, EDIEmailSetup.Body, PurchCrMemoHdr."No.", PDAStAdjProcessingBuffer2."Claim-to Order No.", PurchCrMemoHdr."Amount Including VAT"), '', 0, FALSE);

            EXIT(EmailSent);
        END;

        IF PDAStAdjProcessingBuffer."Vendor Ullaged Status" = PDAStAdjProcessingBuffer."Vendor Ullaged Status"::"Non-Ullaged" THEN BEGIN

            PrintPurchaseCreditNote(PurchCrMemoHdr."No.", FileName, FileSize);

            IF EDIEmailSetup."Email Supplier" THEN
                VendorEmail := GetVendorEmail(PurchCrMemoHdr."Buy-from Vendor No.");

            EmailSent := SendEmail(VendorEmail,
                                    ConvertPlaceHolder(0, EDIEmailSetup.Subject, PDAStAdjProcessingBuffer2."Claim-to Order No.", '', 0),
                                    ConvertPlaceHolder(1, EDIEmailSetup.Body, PurchCrMemoHdr."No.", PDAStAdjProcessingBuffer2."Claim-to Order No.", 0), FileName, FileSize, FALSE);

            StagingDocRecRef.GETTABLE(PDAStAdjProcessingBuffer2);

            LogEmail(
               1, PDAStAdjProcessingBuffer2."Claim-to Order No.", 4, PDAStAdjProcessingBuffer2."Claim-to Order No.",
                  PurchCrMemoHdr."Buy-from Vendor No.", 3, EmailSent, FileName, StagingDocRecRef.RecordId(), PDAStAdjProcessingBuffer2."EDI File Log Entry No.", (VendorEmail <> ''));
            Commit();
        END;

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure PrintPurchaseCreditNote(PurchCrMemoNo: Code[20]; var FileName: Text; var FileSize: BigInteger)
    var
        ReportSelection: Record "Report Selections";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        FileManagement: Codeunit "File Management";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        // >> Upgrade
        //PathHelper: DotNet Path;
        PathHelper: DotNet Path1;
        // << Upgrade
        ServerFileName: Text;
        TargetFileName: Text;
        TempPath: Text;
        FileModifyDate: Date;
        FileModifyTime: Time;
    begin

        ServerFileName := CreateTempFile();
        PurchCrMemoHdr.SETRANGE("No.", PurchCrMemoNo);
        IF GuiAllowed() THEN
            PurchCrMemoHdr.FINDFIRST()
        ELSE
            IF NOT PurchCrMemoHdr.FINDFIRST() THEN
                EXIT;

        IF PurchCrMemoHdr.FINDFIRST() THEN BEGIN
            ReportSelection.SETRANGE(Usage, ReportSelection.Usage::"P.Cr.Memo");
            ReportSelection.SETFILTER("Report ID", '<>0');
            IF ReportSelection.FIND('-') THEN BEGIN
                IF GuiAllowed() THEN
                    REPORT.SAVEASPDF(ReportSelection."Report ID", ServerFileName, PurchCrMemoHdr)
                ELSE
                    IF NOT REPORT.SAVEASPDF(ReportSelection."Report ID", ServerFileName, PurchCrMemoHdr) THEN
                        EXIT;
            END;

            TempPath := FileManagement.GetDirectoryName(FileManagement.ServerTempFileName('CLAIM'));

            TargetFileName := PathHelper.Combine(TempPath, GetFileName(4, PurchCrMemoHdr."No.") + '.' + GetFileExtension());

            DeleteServerFile(TargetFileName);

            EDIFunctionsLibrary.MoveFile(ServerFileName, TargetFileName, TRUE);
            FileManagement.GetServerFileProperties(TargetFileName, FileModifyDate, FileModifyTime, FileSize);
            FileName := GetFileNameFromAttachment(TargetFileName);
        END;
    end;

    [Scope('OnPrem')]
    procedure SendINVManuallyPostedEmail(POINVHeader: Record "GXL PO INV Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"Manual Inv", GuiAllowed()) THEN
            EXIT;

        EmailSent := SendEmail('', ConvertPlaceHolder(0, EDIEmailSetup.Subject, POINVHeader."Purchase Order No.", '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, POINVHeader."No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendASNScanImportFailureEmail(Location: Record Location; FullFileName: Text; FileName: Text; FileSize: Integer; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"3PL Imp.", GuiAllowed()) THEN
            EXIT;
        EmailSent := SendEmail(Location."GXL File Exchange Email Addr.", ConvertPlaceHolder(0, EDIEmailSetup.Subject, FileName, '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, FileName, LastErrorText, 0), FullFileName, FileSize, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendASNExmportFailureEmail(ASNHeader: Record "GXL ASN Header"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
    begin
        IF NOT GetEDIEmailSetup(ProcessAreaOfEmailing::"ASN Exp.", GuiAllowed()) THEN
            EXIT;

        EmailSent := SendEmail('', ConvertPlaceHolder(0, EDIEmailSetup.Subject, ASNHeader."No.", '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, ASNHeader."No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure AddOriginalDocNo(InputDocumentNo: Text; OriginalDocumentNo: Text): Text
    var
        GXLMiscUtilities: Codeunit "GXL Misc. Utilities";
    begin
        EXIT(GXLMiscUtilities.AddOriginalDocNo(InputDocumentNo, OriginalDocumentNo));
    end;



    [Scope('OnPrem')]
    procedure SendNonEDIPDAReceivingBufferClearingEmail(DocumentNo: Code[20]; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
    begin
        IF NOT GetEDIEmailSetup(49, GuiAllowed()) THEN // 49 = NEDI PDA Rec. B. Cl
            EXIT;

        EmailSent := SendEmail('', ConvertPlaceHolder(0, EDIEmailSetup.Subject, DocumentNo, '', 0), ConvertPlaceHolder(1, EDIEmailSetup.Body, DocumentNo, LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;



    [Scope('OnPrem')]
    procedure "-- MCS1.07 --"()
    begin
    end;

    local procedure ConvertPlaceHolder2(InputType: Option Subject,Body; InputText: Text; ReplacementText1: Text; ReplacementText2: Text; ReplacementText3: Text; ErrorText: Text; Amount: Decimal): Text
    begin
        CASE InputType OF
            InputType::Subject:
                EXIT(STRSUBSTNO(InputText, ReplacementText1, ReplacementText2, ReplacementText3));

            InputType::Body:
                EXIT(STRSUBSTNO(InputText, ReplacementText1, ReplacementText2, ReplacementText3, ErrorText, Amount));
        END;
    end;

    [Scope('OnPrem')]
    procedure "-- MCS1.76"()
    begin
    end;

    [Scope('OnPrem')]
    procedure SendShipAdviceImportFailureEmail(FreightAgent: Record "GXL Freight Forwarder"; FullFileName: Text; FileName: Text; FileSize: Integer; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        ForwardingAgentEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(50, GuiAllowed()) THEN
            EXIT;

        ForwardingAgentEmail := GetForwardingAgentEmail(FreightAgent.Code);

        EmailSent := SendEmail(ForwardingAgentEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject, FileName, '', 0),
                         ConvertPlaceHolder(1, EDIEmailSetup.Body, FileName, LastErrorText, 0),
                         FullFileName, FileSize, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendShipAdviceValidationFailureEmail(ShippingAdviceHeader: Record "GXL Intl. Shipping Advice Head"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        ForwardingAgentEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(51, GuiAllowed()) THEN
            EXIT;

        ForwardingAgentEmail := GetForwardingAgentEmail(ShippingAdviceHeader."Freight Forwarding Agent Code");

        EmailSent := SendEmail(ForwardingAgentEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject,
                         AddOriginalDocNo(ShippingAdviceHeader."No.", ShippingAdviceHeader."Order No."), '', 0),
                         ConvertPlaceHolder(1, EDIEmailSetup.Body, ShippingAdviceHeader."No.", LastErrorText, 0),
                         '', 0, FALSE);

        EXIT(EmailSent);
    end;

    [Scope('OnPrem')]
    procedure SendShipAdviceProcessFailureEmail(ShippingAdviceHeader: Record "GXL Intl. Shipping Advice Head"; LastErrorText: Text): Boolean
    var
        EmailSent: Boolean;
        ForwardingAgentEmail: Text;
    begin
        IF NOT GetEDIEmailSetup(52, GuiAllowed()) THEN
            EXIT;

        ForwardingAgentEmail := GetForwardingAgentEmail(ShippingAdviceHeader."Freight Forwarding Agent Code");

        EmailSent := SendEmail(ForwardingAgentEmail, ConvertPlaceHolder(0, EDIEmailSetup.Subject,
                         AddOriginalDocNo(ShippingAdviceHeader."No.", ShippingAdviceHeader."Order No."), '', 0),
                         ConvertPlaceHolder(1, EDIEmailSetup.Body, ShippingAdviceHeader."No.", LastErrorText, 0), '', 0, FALSE);

        EXIT(EmailSent);
    end;

    local procedure GetForwardingAgentEmail(AgentNo: Code[20]): Text
    var
        ForwardingAgent: Record "GXL Freight Forwarder";
    begin
        IF AgentNo = '' THEN
            EXIT;

        IF GuiAllowed() THEN
            ForwardingAgent.GET(AgentNo)
        ELSE
            IF ForwardingAgent.GET(AgentNo) THEN;

        EXIT(ForwardingAgent."EDI Notifications E-Mail");
    end;

    local procedure GetFileNameFromAttachment(Attachment: Text) AttachRet: Text
    var
        LastSlashPos: Integer;
    begin
        AttachRet := Attachment;
        REPEAT
            LastSlashPos := STRPOS(AttachRet, '\');
            IF LastSlashPos > 0 THEN
                AttachRet := COPYSTR(AttachRet, LastSlashPos + 1);
        UNTIL LastSlashPos = 0;
        MESSAGE(AttachRet);
    end;
}

