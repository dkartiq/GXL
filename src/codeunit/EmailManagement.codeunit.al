// 001 02.07.2025 KDU HP2-Sprint2
codeunit 50360 "GXL Email Management"
{
    Permissions =
        tabledata "Purch. Cr. Memo Hdr." = m,
        tabledata "Return Shipment Header" = m;

    var
        EmailSetup: Record "GXL Email Setup";
        DocumentEmailSetup: Record "GXL Document Email Setup";
        Vendor: Record Vendor;
        Contact: Record Contact;
        Customer: Record Customer;
        IntegrationSetup: Record "GXL Integration Setup";
        UserSetup: Record "User Setup";
        FileManagement: Codeunit "File Management";
        DocRecRef: RecordRef;
        FileExtension: Text;

        Text001Txt: Label 'E-Mail Sent';
        Text002Txt: Label 'No valid E-Mail has been found for %1: %2';
        Text005Txt: Label 'No valid E-Mail has been found for %1';
        Text007Txt: Label 'Purchase Order %1 Quantity Variance Notification';
        Text013Txt: Label 'Purchase Order %1 Cancellation Notification';
        Text014Txt: Label 'Quantity Variance %';
        Text015Txt: Label 'Item No.';
        TableCSSTxt: Label '<style>table,th,td{border=1px solid black;text-align:left;}</style>';
        StartTableTxt: Label '<table border="1">';
        EndTableTxt: Label '</table>';
        StartHeaderDataTxt: Label '<th>';
        EndHeaderDataTxt: Label '</th>';
        StratRowTxt: Label '<tr>';
        EndRowTxt: Label '</tr>';
        StartDataTxt: Label '<td>';
        EndDataTxt: Label '</td>';
        ParagraphStartTxt: Label '<p>';
        ParagraphEndTxt: Label '</p>';
        IsManualG: Boolean;// >> HP2-SPRINT2 << 


    procedure SendEmailFromConfirmPurchaseHeader(PurchaseHeader: Record "Purchase Header"; ShowErrors: Boolean; ShowMessages: Boolean; SendingBehaviour: Option " ","Do Not Prompt User","Prompt User") EmailSent: Boolean
    var
        DocumentType: Integer;
    begin
        if NOT GetEmailSetup(ShowErrors) then
            exit;

        if EmailSetup."Allow Email Only for Rel. Doc." then
            if PurchaseHeader.Status <> PurchaseHeader.Status::Released then begin
                if ShowErrors then
                    PurchaseHeader.TESTFIELD(Status, PurchaseHeader.Status::Released)
                else
                    exit;
            end;

        CASE PurchaseHeader."Document Type" OF
            PurchaseHeader."Document Type"::Quote:
                DocumentType := 1;
            PurchaseHeader."Document Type"::Order:
                DocumentType := 2;
            PurchaseHeader."Document Type"::"Blanket Order":
                DocumentType := 3;
            PurchaseHeader."Document Type"::"Return Order":
                DocumentType := 4;
            else
                exit;
        end;

        //if sending behaviour is blank then standard will be used otherwise override behaviour with input parameter
        GetDocumentEmailSetup(DocumentType, SendingBehaviour);

        GetVendor(PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Pay-to Vendor No.",
                  PurchaseHeader."Buy-from Contact No.", PurchaseHeader."Pay-to Contact No.");

        GetSupplyChainEmail(ShowErrors);

        if (GetEmailType(1) = 1) then
            if NOT CheckSMTPSetup(ShowErrors) then
                exit;

        if PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Confirmed then
            EmailSent := SendSupplyChainEmail(GetEmailType(1), DocumentType + 1, 1, STRSUBSTNO(Text007Txt, PurchaseHeader."No."), GetSupplyChainFromConfirmPurchaseHeaderEmailBody(PurchaseHeader, ShowErrors))

        else
            if PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Cancelled then
                EmailSent := SendSupplyChainEmail(GetEmailType(1), DocumentType + 1, 1, STRSUBSTNO(Text013Txt, PurchaseHeader."No."), GetSupplyChainFromConfirmPurchaseHeaderEmailBody(PurchaseHeader, FALSE));

        if GuiAllowed() AND ShowMessages AND EmailSent AND ShowEmailSentMsg(1) then
            MESSAGE(Text001Txt);
    end;

    local procedure GetEmailSetup(ShowErrors: Boolean): Boolean
    begin
        if ShowErrors then begin
            EmailSetup.Get();
        end else begin
            if NOT EmailSetup.Get() then
                exit(FALSE);
        end;

        if (EmailSetup."Email Type" = EmailSetup."Email Type"::" ") then
            exit(FALSE);

        exit(CheckUserSetup(ShowErrors));
    end;

    local procedure GetDocumentEmailSetup(InputDocumentType: Option "Customer Statement","Purchase Quote","Purchase Order","Purchase Blanket Order","Purchase Return Order","Purchase Return Shipment","Purchase CR/Adj Note","Sales Quote","Sales Order","Sales Blanket Order","Sales Shipment","Sales Invoice","Sales Return Order","Sales CR/Adj Note","Service Order","Service Shipment","Service Invoice","Service CR/Adj Note"; SendingBehaviour: Option " ","Do Not Prompt User","Prompt User")
    begin
        if NOT DocumentEmailSetup.Get(USERID(), InputDocumentType) then
            DocumentEmailSetup.Get('', InputDocumentType);

        CASE SendingBehaviour OF
            SendingBehaviour::"Do Not Prompt User":
                DocumentEmailSetup."Sending Behaviour" := DocumentEmailSetup."Sending Behaviour"::"Do Not Prompt User";

            SendingBehaviour::"Prompt User":
                DocumentEmailSetup."Sending Behaviour" := DocumentEmailSetup."Sending Behaviour"::"Prompt User";
        end;

        // if the process is called by a service then override the option not to prompt the user
        if NOT GuiAllowed() then
            DocumentEmailSetup."Sending Behaviour" := DocumentEmailSetup."Sending Behaviour"::"Do Not Prompt User";

    end;

    local procedure GetVendor(InputVendorBuyFrom: Code[20]; InputVendorPayTo: Code[20]; InputContBuyFrom: Code[20]; InputContPayTo: Code[20])
    begin
        CASE DocumentEmailSetup."Email From / To" OF

            DocumentEmailSetup."Email From / To"::"Sell-to / Buy-from":
                Vendor.Get(InputVendorBuyFrom);

            DocumentEmailSetup."Email From / To"::"Bill-to / Pay-to":
                Vendor.Get(InputVendorPayTo);

        end;

        if NOT (Vendor."GXL Email To" IN [Vendor."GXL Email To"::Vendor]) then begin
            CASE DocumentEmailSetup."Email From / To" OF

                DocumentEmailSetup."Email From / To"::"Sell-to / Buy-from":
                    if Contact.Get(InputContBuyFrom) then
                        ;

                DocumentEmailSetup."Email From / To"::"Bill-to / Pay-to":
                    if Contact.Get(InputContPayTo) then
                        ;

            end;
        end;
    end;

    local procedure GetSupplyChainEmail(ShowError: Boolean) Email: Text
    begin
        if NOT GetEmailSetup(ShowError) then
            exit;

        if EmailSetup."Test Mode" then begin

            if ShowError then
                EmailSetup.TESTFIELD("Test Email");

            exit(EmailSetup."Test Email");

        end;

        if NOT GetSupplyChainSetup(ShowError) then
            exit;

        if ShowError then
            IntegrationSetup.TESTFIELD("Replenishment Team Email");

        Email := IntegrationSetup."Replenishment Team Email";

        if ShowError AND (Email = '') then begin
            ERROR(Text005Txt, IntegrationSetup.TABLECAPTION());
        end;
    end;

    local procedure GetSupplyChainSetup(ShowErrors: Boolean): Boolean
    begin
        if ShowErrors then begin
            IntegrationSetup.Get();
        end else begin
            if NOT IntegrationSetup.Get() then
                exit(FALSE);
        end;

        exit(TRUE);
    end;

    local procedure GetEmailType(InputType: Option Customer,Vendor): Integer
    begin
        CASE InputType OF

            InputType::Customer:
                begin
                    Error('EmailManagement.GetEmailType has not been implemented for customers.');
                    // CASE Customer."GXL Email Type" OF
                    //     Customer."Email Type"::Outlook:
                    //         exit(0);

                    //     Customer."Email Type"::SMTP:
                    //         exit(1);

                    //     else
                    //         exit(GetUserEmailType);
                    // end;

                end;

            InputType::Vendor:
                begin

                    CASE Vendor."GXL Email Type" OF
                        Vendor."GXL Email Type"::Outlook:
                            exit(0);

                        Vendor."GXL Email Type"::SMTP:
                            exit(1);

                        else
                            exit(GetUserEmailType());
                    end;

                end;

        end;
    end;

    local procedure GetUserEmailType(): Integer
    begin
        if UserSetup.Get(USERID()) then begin
            CASE UserSetup."GXL Email Type" OF
                UserSetup."GXL Email Type"::Outlook:
                    exit(0);
                UserSetup."GXL Email Type"::SMTP:
                    exit(1);
            end;
        end;

        //The Record has been already retrieved initially otherwise this call wouldn't be possible
        if EmailSetup."Email Type" = EmailSetup."Email Type"::SMTP then
            exit(1)
        else
            //This will be Outlook otherwise the function wouldn't be called at all because already out in the initial call
            exit(0);
    end;

    local procedure CheckSMTPSetup(ShowErrors: Boolean): Boolean
    var
        // >> Upgrade
        //SMTPMailSetup: Record "SMTP Mail Setup";
        AutoImport: Codeunit "GXL Auto Import IC Trans";
        SMTPError: Label 'SMTP setup does not exists';
    // << Upgrade
    begin
        UserSetup.Get(USERID());
        if ShowErrors then begin
            // >> Upgrade
            // SMTPMailSetup.Get();
            // SMTPMailSetup.TESTFIELD("SMTP Server");
            // UserSetup.TESTFIELD("E-Mail");
            // >> 001
            // if not AutoImport.CheckSMTPSetup() then
            //     Error(SMTPError);
            if AutoImport.CheckSMTPSetup() then
                exit(true)
            else
                Error(SMTPError);
            // << 001
            // << Upgrade
        end else begin
            // >> Upgrade
            // if SMTPMailSetup.Get() then begin
            //     if (SMTPMailSetup."SMTP Server" = '') then
            //         exit(FALSE);
            // end else
            //     exit(FALSE);

            // if UserSetup."E-Mail" = '' then
            //     exit(FALSE);
            exit(AutoImport.CheckSMTPSetup());
            // << Upgrade
        end;

        //exit(TRUE); // >> Upgrade <<
    end;

    procedure SendSupplyChainEmail(InputEmailType: Option Outlook,SMTP; InputDocIntType: Integer; InputType: Option Customer,Vendor; EmailSubject: Text; EmailBody: Text): Boolean
    var
        User: Record User;
        TempDocEmailSetup: Record "GXL Document Email Setup" temporary;
        Mail: Codeunit Mail;
        // >> Upgrade
        //SMTPMail: Codeunit "SMTP Mail";
        SMTPMail: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailScenario: Enum "Email Scenario";
        // << Upgrade
        SendSMTPMail: Boolean;
    begin
        SendSMTPMail := TRUE;

        if NOT GuiAllowed() then
            InputEmailType := InputEmailType::SMTP;

        //Outlook
        if (InputEmailType = InputEmailType::Outlook) then begin

            Mail.NewMessage(GetSupplyChainEmail(FALSE), '', '', EmailSubject, EmailBody, '',
                             DocumentEmailSetup."Sending Behaviour" = DocumentEmailSetup."Sending Behaviour"::"Prompt User");


        end else begin
            //SMTP

            //UserSetup is already read from the initial GetEmailSetup
            User.SetCurrentKey("User Name");
            User.SetRange("User Name", USERID());
            User.FindFirst();

            DocumentEmailSetup."Sending Behaviour" := DocumentEmailSetup."Sending Behaviour"::"Do Not Prompt User";

            if (DocumentEmailSetup."Sending Behaviour" = DocumentEmailSetup."Sending Behaviour"::"Prompt User") then begin

                TempDocEmailSetup := DocumentEmailSetup;
                TempDocEmailSetup.Insert();

                TempDocEmailSetup."Email Subject" := COPYSTR(EmailSubject, 1, MAXSTRLEN(TempDocEmailSetup."Email Subject"));

                TempDocEmailSetup.SaveEmailBody(EmailBody);

                TempDocEmailSetup.SaveEmailBodyHTML(EmailBody);

                TempDocEmailSetup.Modify();

                if (PAGE.RUNMODAL(92921, TempDocEmailSetup) = ACTION::LookupOK) then begin
                    // >> Upgrade
                    // SMTPMail.CreateMessage(User."Full Name", UserSetup."E-Mail",
                    //                        GetSupplyChainEmail(FALSE),
                    //                        TempDocEmailSetup."Email Subject",
                    //                        TempDocEmailSetup.GetEmailBodytHTML(), TRUE);
                    SMTPMail.Create(
                GetSupplyChainEmail(FALSE),
                TempDocEmailSetup."Email Subject",
                TempDocEmailSetup.GetEmailBodytHTML(), TRUE);
                    // << Upgrade
                end else begin
                    SendSMTPMail := FALSE;
                end;

            end else begin
                // >> Upgrade
                // SMTPMail.CreateMessage(User."Full Name", UserSetup."E-Mail",
                //                        GetSupplyChainEmail(FALSE), EmailSubject, EmailBody, TRUE);
                SMTPMail.Create(
                GetSupplyChainEmail(FALSE), EmailSubject, EmailBody, TRUE);
                // << Upgrade
            end;

            //SMTPMail.TrySend();
            Email.Send(SMTPMail, EmailScenario::Default);
        end;

        exit(SendSMTPMail);

    end;

    local procedure GetSupplyChainFromConfirmPurchaseHeaderEmailBody(VAR PurchaseHeader: Record "Purchase Header"; ShowErrors: Boolean): Text
    var
        PurchaseLine: Record "Purchase Line";
        WriteRow: Boolean;
        AllowedTolerancePct: Decimal;
        CalculatedDifferencePct: Decimal;
        FromConfirmPurchaseHeaderEmailBody: Text;
    begin
        if NOT GetSupplyChainSetup(ShowErrors) then
            exit;

        FromConfirmPurchaseHeaderEmailBody += TableCSSTxt;
        AllowedTolerancePct := ROUND(IntegrationSetup."Allowable Tolerance %", 0.01);

        if PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Confirmed then
            FromConfirmPurchaseHeaderEmailBody += ParagraphStartTxt + IntegrationSetup.FIELDCAPTION("Allowable Tolerance %") + ': ' + FORMAT(IntegrationSetup."Allowable Tolerance %") + ParagraphEndTxt;

        FromConfirmPurchaseHeaderEmailBody += StartTableTxt;
        FromConfirmPurchaseHeaderEmailBody += StratRowTxt;
        FromConfirmPurchaseHeaderEmailBody += StartHeaderDataTxt + PurchaseHeader.FIELDCAPTION("No.") + EndHeaderDataTxt;
        FromConfirmPurchaseHeaderEmailBody += StartHeaderDataTxt + PurchaseHeader.FIELDCAPTION("Buy-from Vendor No.") + EndHeaderDataTxt;
        FromConfirmPurchaseHeaderEmailBody += StartHeaderDataTxt + PurchaseHeader.FIELDCAPTION("Expected Receipt Date") + EndHeaderDataTxt;
        FromConfirmPurchaseHeaderEmailBody += StartHeaderDataTxt + Text015Txt + EndHeaderDataTxt;
        FromConfirmPurchaseHeaderEmailBody += StartHeaderDataTxt + PurchaseLine.FIELDCAPTION("LSC Original Quantity") + EndHeaderDataTxt;
        FromConfirmPurchaseHeaderEmailBody += StartHeaderDataTxt + PurchaseLine.FIELDCAPTION("GXL Confirmed Quantity") + EndHeaderDataTxt;
        if PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Confirmed then
            FromConfirmPurchaseHeaderEmailBody += StartHeaderDataTxt + Text014Txt + EndHeaderDataTxt;
        FromConfirmPurchaseHeaderEmailBody += EndRowTxt;

        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);

        if PurchaseLine.FindSet() then
            repeat
                WriteRow := TRUE;

                if PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Confirmed then begin

                    CalculatedDifferencePct := ROUND((PurchaseLine."GXL Confirmed Quantity" - PurchaseLine."LSC Original Quantity") / PurchaseLine."LSC Original Quantity" * 100, 0.01);

                    if ABS(CalculatedDifferencePct) <= ABS(AllowedTolerancePct) then
                        WriteRow := FALSE;
                end;

                if WriteRow then begin

                    FromConfirmPurchaseHeaderEmailBody += StratRowTxt;

                    FromConfirmPurchaseHeaderEmailBody += StartDataTxt + PurchaseLine."Document No." + EndDataTxt;
                    FromConfirmPurchaseHeaderEmailBody += StartDataTxt + PurchaseLine."Buy-from Vendor No." + EndDataTxt;
                    FromConfirmPurchaseHeaderEmailBody += StartDataTxt + FORMAT(PurchaseLine."Expected Receipt Date") + EndDataTxt;
                    FromConfirmPurchaseHeaderEmailBody += StartDataTxt + PurchaseLine."No." + ' ' + PurchaseLine.Description + EndDataTxt;
                    FromConfirmPurchaseHeaderEmailBody += StartDataTxt + FORMAT(PurchaseLine."LSC Original Quantity") + EndDataTxt;

                    FromConfirmPurchaseHeaderEmailBody += StartDataTxt + FORMAT(PurchaseLine."GXL Confirmed Quantity") + EndDataTxt;

                    if PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Confirmed then
                        FromConfirmPurchaseHeaderEmailBody += StartDataTxt + FORMAT(CalculatedDifferencePct) + EndDataTxt;

                    FromConfirmPurchaseHeaderEmailBody += EndRowTxt;

                end;

            until PurchaseLine.Next() = 0;

        FromConfirmPurchaseHeaderEmailBody += EndTableTxt;

        exit(FromConfirmPurchaseHeaderEmailBody);

    end;

    local procedure ShowEmailSentMsg(InputType: Option Customer,Vendor): Boolean
    begin
        if (DocumentEmailSetup."Sending Behaviour" = DocumentEmailSetup."Sending Behaviour"::"Do Not Prompt User") OR
           ((GetEmailType(InputType) = 1) AND (DocumentEmailSetup."Sending Behaviour" = DocumentEmailSetup."Sending Behaviour"::"Prompt User")) then
            exit(TRUE);
    end;

    local procedure CheckUserSetup(ShowErrors: Boolean): Boolean
    begin
        if ShowErrors then begin

            UserSetup.Get(USERID());
            if (UserSetup."GXL Email Type" = UserSetup."GXL Email Type"::SMTP) then
                exit(CheckSMTPSetup(ShowErrors));

        end else begin

            if UserSetup.Get(USERID()) then begin
                if (UserSetup."GXL Email Type" = UserSetup."GXL Email Type"::SMTP) then begin
                    exit(CheckSMTPSetup(ShowErrors));
                end;
            end else
                exit(FALSE);

        end;

        exit(TRUE);
    end;

    procedure SendPOEmail(VAR PurchaseHeader: Record "Purchase Header"; ShowErrors: Boolean; ShowMessages: Boolean) EmailSent: Boolean
    var
        TempFileNames: Record "GXL Email Log" temporary;
        WhMgmt: Codeunit "GXL WH Data Management";
        Filename: Text;
        i: Integer;
        DocumentType: Integer;
        DocFileName: Text;
        EmailSubject: Text;
        BoolAttachment: Boolean;
        SendingBehaviour: Option " ","Do Not Prompt User","Prompt User";
        Location: Record Location;// >> 001 <<
        FinalDestination: text;
        FileMgt: codeunit "File Management";
        TempBlob: codeunit "Temp Blob";
    begin
        if NOT GetEmailSetup(ShowErrors) then
            exit;


        if EmailSetup."Allow Email Only for Rel. Doc." then
            if PurchaseHeader.Status <> PurchaseHeader.Status::Released then begin
                if ShowErrors then
                    PurchaseHeader.TESTFIELD(Status, PurchaseHeader.Status::Released)
                else
                    exit;
            end;

        CASE PurchaseHeader."Document Type" OF
            PurchaseHeader."Document Type"::Quote:
                DocumentType := 1;
            PurchaseHeader."Document Type"::Order:
                DocumentType := 2;
            PurchaseHeader."Document Type"::"Blanket Order":
                DocumentType := 3;
            PurchaseHeader."Document Type"::"Return Order":
                DocumentType := 4;
            else
                exit;
        end;

        GetDocumentEmailSetup(DocumentType, SendingBehaviour);

        //if sending behaviour is blank then standard will be used otherwise override behaviour with input parameter
        DocumentEmailSetup."Sending Behaviour" := DocumentEmailSetup."Sending Behaviour"::"Do Not Prompt User";

        GetVendor(PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Pay-to Vendor No.",
                  PurchaseHeader."Buy-from Contact No.", PurchaseHeader."Pay-to Contact No.");


        if (GetUserEmailType() = 1) then
            if NOT CheckSMTPSetup(ShowErrors) then
                exit;
        PurchaseHeader.SetRecFilter();
        Filename := '';
        Filename := WhMgmt.CreateVendorFile(PurchaseHeader, DocFileName);

        if FILE.EXISTS(Filename) then
            FileExtension := FileManagement.GetExtension(Filename);

        if PurchaseHeader."No." <> '' then begin

            i += 1;
            TempFileNames."Entry No." := i;
            TempFileNames."Document Filename" := Filename;
            TempFileNames.Insert();
        end;

        DocRecRef.GETTABLE(PurchaseHeader);

        //MoveRenameFiles(TempFileNames, DocFileName, GetEmailType(1) = 1); // >> HP2-Sprint2 <<

        EmailSubject := 'PO Number: ' + PurchaseHeader."Location Code" + '-' + PurchaseHeader."No." +
                ' Supplier: ' + PurchaseHeader."Buy-from Vendor Name" + ' Deliver to: ' + PurchaseHeader."Ship-to Name";
        BoolAttachment := TRUE;
        // >> HP2-Sprint2
        // if PurchaseHeader."GXL Vendor File Exchange" = TRUE then
        // BoolAttachment := FALSE;
        //EmailSent := EmailPO(GetUserEmailType(), DocumentType + 1, TempFileNames, 1, EmailSubject, BoolAttachment);
        if (PurchaseHeader."GXL Vendor File Exchange") AND (not IsManualG) then
            BoolAttachment := FALSE;
        EmailSent := EmailPO(GetUserEmailType(), DocumentType + 1, TempFileNames, 1, EmailSubject, BoolAttachment, DocFileName);
        IsManualG := false;
        // << HP2-Sprint2
        if EmailSent then begin
            PurchaseHeader.Get(PurchaseHeader."Document Type", PurchaseHeader."No.");
            PurchaseHeader."GXL No. Emailed" += 1;
            PurchaseHeader.Modify();
            Commit();
        end;

        if GuiAllowed() AND ShowMessages AND EmailSent AND ShowEmailSentMsg(1) then
            MESSAGE(Text001Txt);
    end;

    procedure SetManual(IsManualP: Boolean)
    begin
        IsManualG := IsManualP;
    end;
    // >> 001
    procedure MoveFile(SourceFileName: Text; TargetFileName: Text; DeleteSourceFile: Boolean)
    var
        FileMgt: Codeunit "File Management";
        ServerFileHelper: DotNet File1;
    begin
        ServerFileHelper.Copy(SourceFileName, TargetFileName);

        IF DeleteSourceFile THEN
            ServerFileHelper.Delete(SourceFileName);
    end;
    // << 001
    local procedure MoveRenameFiles(VAR InputTempFileNames: Record "GXL Email Log" TEMPORARY; InputFilename: Text; MoveToClient: Boolean)
    var
        TempFile: File;
        TempPath: Text;
        TargetFileName: Text;
        TotalFiles: Integer;
    begin
        InputTempFileNames.Reset();
        TotalFiles := InputTempFileNames.COUNT();
        if InputTempFileNames.FindSet() then begin
            repeat

                if MoveToClient then begin

                    TempFile.CREATETEMPFILE();
                    TargetFileName := TempFile.Name();
                    TempFile.CLOSE();

                    TempFile.CREATE(TargetFileName);
                    TempFile.CLOSE();

                    //Client Temp Path
                    TempPath := FileManagement.GetDirectoryName(FileManagement.DownloadTempFile(TargetFileName));

                    if (TotalFiles = 1) then
                        TargetFileName := TempPath + '\' + InputFilename + '.' + GetFileExtension()
                    else
                        TargetFileName := TempPath + '\' + InputFilename + '-' + FORMAT(InputTempFileNames."Entry No.") + '.' + GetFileExtension();
                    // >> Upgrade
                    //FileManagement.DownloadToFile(InputTempFileNames."Document Filename", TargetFileName);
                    // >> 001
                    // FileManagement.DownloadHandler(InputTempFileNames."Document Filename", '', '', '', TargetFileName);
                    // << Upgrade
                    MoveFile(InputTempFileNames."Document Filename", TargetFileName, true);
                    // << 001
                end else begin

                    //Server Temp Path
                    TempPath := FileManagement.GetDirectoryName(FileManagement.ServerTempFileName('test'));

                    if (TotalFiles = 1) then
                        TargetFileName := TempPath + '\' + InputFilename + '.' + GetFileExtension()
                    else
                        TargetFileName := TempPath + '\' + InputFilename + '-' + FORMAT(InputTempFileNames."Entry No.") + '.' + GetFileExtension();

                    DeleteServerFile(TargetFileName);
                    FileManagement.CopyServerFile(InputTempFileNames."Document Filename", TargetFileName, true);
                    FileManagement.DeleteServerFile(InputTempFileNames."Document Filename");
                end;

                InputTempFileNames."Document Filename" := TargetFileName;
                InputTempFileNames.Modify();

            until InputTempFileNames.Next() = 0;
        end;
    end;

    local procedure GetFileExtension(): Text
    begin
        if FileExtension <> '' then
            exit(FileExtension);
        CASE DocumentEmailSetup."Document File Type" OF
            DocumentEmailSetup."Document File Type"::PDF:
                exit('pdf');
            DocumentEmailSetup."Document File Type"::Word:
                exit('doc');
            DocumentEmailSetup."Document File Type"::Excel:
                exit('xls');
        end;
    end;

    local procedure DeleteServerFile(FilePath: Text): Boolean
    begin
        if NOT FileManagement.ServerFileExists(FilePath) then
            exit(false);
        exit(FileManagement.DeleteServerFile(FilePath));
    end;
    // >> HP2-Sprint2
    //procedure EmailPO(InputEmailType: Option Outlook,SMTP; InputDocIntType: Integer; VAR InputTempFileNames: Record "GXL Email Log" TEMPORARY; InputType: Option Customer,Vendor; EmailSubject: Text; BoolAttachment: Boolean): Boolean
    procedure EmailPO(InputEmailType: Option Outlook,SMTP; InputDocIntType: Integer; VAR InputTempFileNames: Record "GXL Email Log" TEMPORARY; InputType: Option Customer,Vendor; EmailSubject: Text; BoolAttachment: Boolean; DocFileName: Text): Boolean
    // << HP2-Sprint2
    var
        User: Record User;
        Mail: Codeunit Mail;
        // >> Upgrade
        //SMTPMail: Codeunit "SMTP Mail";
        SMTPMail: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailScenario: Enum "Email Scenario";
        Files: File;
        Instr: InStream;
        FileName: Text;
        qwe: Record 5062;
        // << Upgrade
        SendSMTPMail: Boolean;
        IsEmailSent: Boolean; // >> LCB-308 <<
        // >> HP2-Sprint2
        TempBlob: codeunit "Temp Blob";
        ExtnText: Text;
    // << HP2-Speint2
    begin
        SendSMTPMail := TRUE;

        //Outlook
        if (InputEmailType = InputEmailType::Outlook) then begin
            InputTempFileNames.Reset();
            InputTempFileNames.FindSet();
            if BoolAttachment then
                repeat
                    Mail.AttachFile(InputTempFileNames."Document Filename");
                until InputTempFileNames.Next() = 0;
            if Mail.NewMessage(GetCustVendEmail(InputDocIntType, InputType, FALSE), '', '', EmailSubject, GetEmailHTMLBody(), '',
                               DocumentEmailSetup."Sending Behaviour" = DocumentEmailSetup."Sending Behaviour"::"Prompt User") then begin
                LogEmail(InputEmailType, 0, '', InputTempFileNames, InputType, ''); // >> LCB-50 << passing email as additional parameter
                IsEmailSent := true; // > LCB-308 <<
            end else begin
                LogEmail(InputEmailType, 1, Mail.GetErrorDesc(), InputTempFileNames, InputType, ''); // >> LCB-50 << passing email as additional parameter
                IsEmailSent := false; // > LCB-308 <<
            end;

        end else begin
            //SMTP

            //UserSetup is already read from the initial GetEmailSetup
            User.SetCurrentKey("User Name");
            User.SetRange("User Name", USERID());
            User.FindFirst();

            // >> Upgrade
            // SMTPMail.CreateMessage(User."Full Name", UserSetup."E-Mail",
            //                        GetCustVendEmail(InputDocIntType, InputType, FALSE), EmailSubject, GetEmailHTMLBody(), TRUE);
            SMTPMail.Create(
                                 GetCustVendEmail(InputDocIntType, InputType, FALSE), EmailSubject, GetEmailHTMLBody(), TRUE);
            // << Upgrade
            if SendSMTPMail then begin

                InputTempFileNames.Reset();
                InputTempFileNames.FindSet();
                if BoolAttachment then
                    repeat
                        // >> Upgrade
                        //SMTPMail.AddAttachment(InputTempFileNames."Document Filename", FileManagement.GetFileName(InputTempFileNames."Document Filename"));
                        // >> HP2-Sprint2
                        //FileName := FileManagement.GetFileName(InputTempFileNames."Document Filename");
                        // >> 001
                        // Files.Open(FileName);
                        //Files.Open(InputTempFileNames."Document Filename");
                        // << 001
                        //Files.CreateInStream(Instr);
                        //SMTPMail.AddAttachment(FileName, FileManagement.GetExtension(FileName), Instr);
                        // << Upgrade
                        //Files.Close(); // >> 001 <<
                        ExtnText := FileManagement.GetExtension(FileManagement.GetFileName(InputTempFileNames."Document Filename"));
                        FileName := DocFileName;
                        DocFileNameG := DocFileName;
                        FileManagement.BLOBImportFromServerFile(TempBlob, InputTempFileNames."Document Filename");
                        TempBlob.CreateInStream(Instr);
                        SMTPMail.AddAttachment(FileName + '.' + ExtnText, ExtnText, Instr);
                    // << HP2-Sprint2
                    until InputTempFileNames.Next() = 0;

                // >> Upgrade
                //if SMTPMail.TrySend() then begin
                ClearLastError();
                if Email.Send(SMTPMail, EmailScenario) then begin
                    // << Upgrade
                    LogEmail(InputEmailType, 0, '', InputTempFileNames, InputType, ''); // >> LCB-50 << passing email as additional parameter
                    IsEmailSent := true; // > LCB-308 <<
                end else begin
                    // >> Upgrade
                    //LogEmail(InputEmailType, 1, SMTPMail.GetLastSendMailErrorText(), InputTempFileNames, InputType, ''); // >> LCB-50 << passing email as additional parameter
                    LogEmail(InputEmailType, 1, GetLastErrorText(), InputTempFileNames, InputType, ''); // >> LCB-50 << passing email as additional parameter
                    // << Upgrade
                    IsEmailSent := false; // > LCB-308 <<
                end;
            end;

        end;

        InputTempFileNames.Reset();
        InputTempFileNames.FindSet();
        repeat
            CASE InputEmailType OF
                // >> Upgrade
                // Verified that this function has been removed from all the referencing objects in std
                // 0:
                //     FileManagement.DeleteClientFile(InputTempFileNames."Document Filename");
                // << Upgrade
                1:
                    DeleteServerFile(InputTempFileNames."Document Filename");
            end;
        until InputTempFileNames.Next() = 0;
        // >> LCB-308
        //exit(SendSMTPMail);
        exit(IsEmailSent);
        // << LCB-308
    end;

    local procedure GetCustVendEmail(InputDocumentType: Option " ","Customer Statement","Purchase Quote","Purchase Order","Purchase Blanket Order","Purchase Return Order","Purchase Return Shipment","Purchase CR/Adj Note","Sales Quote","Sales Order","Sales Blanket Order","Sales Shipment","Sales Invoice","Sales Return Order","Sales CR/Adj Note","Service Order","Service Shipment","Service Invoice","Service CR/Adj Note"; InputType: Option Customer,Vendor; ShowError: Boolean) Email: Text
    var
        EmailCustVendSetup: Record "GXL Email Cust. & Vendor Setup";
    begin
        if NOT GetEmailSetup(ShowError) then
            exit;

        if EmailSetup."Test Mode" then begin

            if ShowError then
                EmailSetup.TESTFIELD("Test Email");

            exit(EmailSetup."Test Email");

        end;

        if (((InputType = InputType::Customer) AND (Customer."GXL Email To" = Customer."GXL Email To"::Contact))
           OR
           ((InputType = InputType::Vendor) AND (Vendor."GXL Email To" = Vendor."GXL Email To"::Contact))) then
            exit(GetContactEmail(ShowError));

        CASE InputType OF

            InputType::Customer:
                begin
                    EmailCustVendSetup.SetRange(Type, EmailCustVendSetup.Type::Customer);
                    EmailCustVendSetup.SetRange(Code, Customer."No.");
                end;

            InputType::Vendor:
                begin
                    EmailCustVendSetup.SetRange(Type, EmailCustVendSetup.Type::Vendor);
                    EmailCustVendSetup.SetRange(Code, Vendor."No.");
                end;

        end;

        EmailCustVendSetup.SetRange("Document Type", InputDocumentType);

        if EmailCustVendSetup.FindSet() then
            repeat
                Email += EmailCustVendSetup.Email + ';';
            until EmailCustVendSetup.Next() = 0;

        EmailCustVendSetup.SetRange("Document Type", EmailCustVendSetup."Document Type"::" ");

        if EmailCustVendSetup.FindSet() then
            repeat
                Email += EmailCustVendSetup.Email + ';';
            until EmailCustVendSetup.Next() = 0;

        if Email <> '' then
            Email := COPYSTR(Email, 1, STRLEN(Email) - 1);
        if (((InputType = InputType::Customer) AND (Customer."GXL Email To" = Customer."GXL Email To"::"Both Contact & Customer"))
           OR
           ((InputType = InputType::Vendor) AND (Vendor."GXL Email To" = Vendor."GXL Email To"::"Both Contact & Vendor"))) then begin

            if Email <> '' then
                Email += ';' + GetContactEmail(FALSE)
            else
                Email := GetContactEmail(FALSE);

        end;

        if (InputType = InputType::Vendor) AND (Vendor."GXL PO Email Address" <> '') then begin
            if Email <> '' then
                Email += ';' + Vendor."GXL PO Email Address"
            else
                Email := Vendor."GXL PO Email Address";
        end else
            if ((InputType = InputType::Vendor) AND (Vendor."GXL Email To" = Vendor."GXL Email To"::Vendor)) then begin
                if Email <> '' then
                    Email += ';' + Vendor."E-Mail"
                else
                    Email := Vendor."E-Mail";
            end;

        if ((InputType = InputType::Customer) AND (Customer."GXL Email To" = Customer."GXL Email To"::Customer)) then begin
            if Email <> '' then
                Email += ';' + Customer."E-Mail"
            else
                Email := Customer."E-Mail";
        end;


        if (((InputType = InputType::Customer) AND (Customer."GXL Email To" = Customer."GXL Email To"::"Use Contact if no Email"))
           OR
           ((InputType = InputType::Vendor) AND (Vendor."GXL Email To" = Vendor."GXL Email To"::"Use Contact if no Email")))
           AND
           (Email = '') then
            exit(GetContactEmail(ShowError));

        if ShowError AND (Email = '') then begin

            CASE InputType OF
                InputType::Customer:
                    ERROR(Text002Txt, Customer.TABLECAPTION(), Customer."No.");
                InputType::Vendor:
                    ERROR(Text002Txt, Vendor.TABLECAPTION(), Vendor."No.");
            end;
        end;
        // >> LCB-192
        if InputDocumentType = InputDocumentType::"Purchase CR/Adj Note" then
            exit('Purchase CR/Adj Note');
        // << LCB-192

    end;

    local procedure GetEmailHTMLBody(): Text
    begin
        exit(ConvertPlaceHolder(2, DocumentEmailSetup.GetEmailBodytHTML()));
    end;

    procedure ConvertPlaceHolder(InputType: Option " ",Subject,Body,Filename; InputText: Text) OutputText: Text
    var
        EmailDocumentPlaceholder: Record "GXL Email Document Placeholder";
        Field: Record Field;
        DocFieldRef: FieldRef;
        // >> Upgrade
        //String: DotNet String;
        String: DotNet String1;
    // << Upgrade
    begin
        //DocRecRef has already been read
        String := InputText;

        EmailDocumentPlaceholder.SetRange("Document Type", DocumentEmailSetup."Document Type");
        EmailDocumentPlaceholder.SetRange("Placeholder Type", InputType);

        if EmailDocumentPlaceholder.FindSet() then
            repeat
                DocFieldRef := DocRecRef.FIELD(EmailDocumentPlaceholder."Field No.");

                if FORMAT(DocFieldRef.CLASS()) = FORMAT(Field.Class::FlowField) then
                    DocFieldRef.CALCFIELD();

                String := String.Replace(EmailDocumentPlaceholder."Placeholder Free Text", FORMAT(DocFieldRef.VALUE()));
            until EmailDocumentPlaceholder.Next() = 0;

        EmailDocumentPlaceholder.SetRange("Placeholder Type", EmailDocumentPlaceholder."Placeholder Type"::" ");

        if EmailDocumentPlaceholder.FindSet() then
            repeat
                DocFieldRef := DocRecRef.FIELD(EmailDocumentPlaceholder."Field No.");

                if FORMAT(DocFieldRef.CLASS()) = FORMAT(Field.Class::FlowField) then
                    DocFieldRef.CALCFIELD();

                String := String.Replace(EmailDocumentPlaceholder."Placeholder Free Text", FORMAT(DocFieldRef.VALUE()));
            until EmailDocumentPlaceholder.Next() = 0;

        OutputText := String;
    end;

    procedure LogEmail(InputEmailType: Option Outlook,SMTP; InputStatus: Option Success,Error; InputError: Text; VAR InputTempFileNames: Record "GXL Email Log" TEMPORARY; InputType: Option Customer,Vendor; EmailAddr: Text)
    var
        EmailLog: Record "GXL Email Log";
        // >> Upgrade
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        FldRef: FieldRef;
        // << Upgrade
        CurrentGUID: Code[100];
    begin
        ClearLog();

        //DocRecRef has already been read
        CurrentGUID := DELCHR(FORMAT(CREATEGUID()), '=', '{-}');

        InputTempFileNames.Reset();
        InputTempFileNames.FindSet();
        repeat

            EmailLog.INIT();
            EmailLog."Entry No." := 0;
            EmailLog."Document Type" := DocumentEmailSetup."Document Type";
            EmailLog."Record ID" := DocRecRef.RECORDID();
            EmailLog."Document File Type" := DocumentEmailSetup."Document File Type";
            EmailLog.Type := InputType;
            EmailLog."Email Type" := InputEmailType;
            EmailLog."Sending Behaviour" := DocumentEmailSetup."Sending Behaviour";

            if InputType = InputType::Customer then
                EmailLog.Code := Customer."No."
            else
                EmailLog.Code := Vendor."No.";
            // >> Upgrade
            //CLEAR(TempBlob.Blob);
            CLEAR(TempBlob);
            // << Upgrade

            // >> LCB-13
            /*
            CASE InputEmailType OF
                0:
                    FileManagement.BLOBImport(TempBlob, InputTempFileNames."Document Filename");
                1:
                    FileManagement.BLOBImportFromServerFile(TempBlob, InputTempFileNames."Document Filename");
            end;
*/
            CASE InputEmailType OF
                0:
                    begin
                        FileManagement.BLOBImport(TempBlob, InputTempFileNames."Document Filename");
                        // >> Upgrade
                        //EmailLog."Document File" := TempBlob.Blob;
                        RecRef.GetTable(EmailLog);
                        FldRef := RecRef.Field(EmailLog.FieldNo("Document File"));
                        TempBlob.ToFieldRef(FldRef);
                        // << Upgrade
                    end;
                1:
                    EmailLog."Document File" := InputTempFileNames."Document File"

            end;
            // << LCB-13




            EmailLog.SetErrorMessage(InputError);
            EmailLog."Email ID" := CurrentGUID;
            // >> HP2-Sprint2
            if DocFileNameG > '' then
                EmailLog."Document Filename" := DocFileNameG
            else
                // << HP2-Sprint2
                EmailLog."Document Filename" := FileManagement.GetFileName(InputTempFileNames."Document Filename");

            EmailLog.Status := InputStatus;
            // >> LCB-50
            //EmailLog."Email Sent To" := COPYSTR(GetCustVendEmail(DocumentEmailSetup."Document Type" + 1, InputType, FALSE), 1, MAXSTRLEN(EmailLog."Email Sent To"));
            if EmailAddr = '' then
                EmailLog."Email Sent To" := COPYSTR(GetCustVendEmail(DocumentEmailSetup."Document Type" + 1, InputType, FALSE), 1, MAXSTRLEN(EmailLog."Email Sent To"))
            else
                EmailLog."Email Sent To" := CopyStr(EmailAddr, 1, MaxStrLen(EmailLog."Email Sent To"));
            // << LCB-50
            EmailLog.Insert(TRUE);

        until InputTempFileNames.Next() = 0;


    end;

    LOCAL procedure ClearLog()
    var
        EmailLog: Record "GXL Email Log";
        DummyDateFormula: DateFormula;
        ClearLogDateTime: DateTime;
    begin
        if (EmailSetup."Clear Log Date Formula" <> DummyDateFormula) then begin

            ClearLogDateTime := CREATEDATETIME(CALCDATE(EmailSetup."Clear Log Date Formula", TODAY()), 0T);

            EmailLog.SetCurrentKey("Created Date Time", "Record ID", "Email ID");
            EmailLog.SetFilter("Created Date Time", '<=%1', ClearLogDateTime);
            EmailLog.DELETEALL(TRUE);

        end;
    end;

    local procedure GetContactEmail(ShowError: Boolean): Text
    begin
        if (Contact."No." = '') then begin
            if ShowError then
                Contact.TESTFIELD("No.")
            else
                exit;
        end;

        if (Contact."E-Mail" = '') then begin
            if ShowError then
                ERROR(Text002Txt, Contact.TABLECAPTION(), Contact."No.");
        end else
            exit(Contact."E-Mail");
    end;

    //ERP-NAV Master Data Management +
    local procedure IsVendorEmailOnPosting(
        InputDocumentType: Option "Customer Statement","Purchase Quote","Purchase Order","Purchase Blanket Order","Purchase Return Order","Purchase Return Shipment","Purchase CR/Adj Note","Sales Quote","Sales Order","Sales Blanket Order","Sales Shipment","Sales Invoice","Sales Return Order","Sales CR/Adj Note","Service Order","Service Shipment","Service Invoice","Service CR/Adj Note";
        InputVendorBuyFrom: Code[20];
        InputVendorPayTo: Code[20];
        InputContrBuyFrom: Code[20];
        InputContrPayTo: Code[20];
        ShowError: Boolean;
        SendingBehaviour: Option " ","Do Not Prompt User","Prompt User"): Boolean
    begin
        if not (InputDocumentType in [InputDocumentType::"Purchase Return Shipment", InputDocumentType::"Purchase CR/Adj Note"]) then
            exit;

        if not GetEmailSetup(ShowError) then
            exit;

        GetDocumentEmailSetup(InputDocumentType, SendingBehaviour);

        GetVendor(InputVendorBuyFrom, InputVendorPayTo, InputVendorBuyFrom, InputVendorPayTo);

        // >> LCB-13
        //exit(Vendor."GXL Email On Posting");
        exit(true);
        // << LCB-13
    end;


    procedure IsPostingVendorSendEmail(
            InputDocumentType: Option "Customer Statement","Purchase Quote","Purchase Order","Purchase Blanket Order","Purchase Return Order","Purchase Return Shipment","Purchase CR/Adj Note","Sales Quote","Sales Order","Sales Blanket Order","Sales Shipment","Sales Invoice","Sales Return Order","Sales CR/Adj Note","Service Order","Service Shipment","Service Invoice","Service CR/Adj Note";
            InputVendorBuyFrom: Code[20];
            InputVendorPayTo: Code[20];
            InputContrBuyFrom: Code[20];
            InputContrPayTo: Code[20];
            ShowError: Boolean;
            SendingBehaviour: Option " ","Do Not Prompt User","Prompt User"): Boolean
    begin
        if IsVendorEmailOnPosting(InputDocumentType, InputVendorBuyFrom, InputVendorPayTo, InputVendorBuyFrom, InputVendorPayTo, ShowError, SendingBehaviour) then
            if (GetCustVendEmail(InputDocumentType + 1, 1, false) <> '') then
                //SMTP = 1
                if ((GetEmailType(1) = 1) and CheckSMTPSetup(false)) then
                    exit(true);
    end;

    procedure SendPurchReturnShipment(ReturnShipmentHeader: Record "Return Shipment Header"; ShowErrors: Boolean; ShowMessages: Boolean; SendingBehaviour: Option " ","Do Not Prompt User","Prompt User") EmailSent: Boolean
    var
        ReportSelections: Record "Report Selections";
        // >> LCB-13
        //TempFileNames: Record "GXL Email Log"; 
        TempFileNames: Record "GXL Email Log" temporary;
        // << LCB-13
        Filename: Text;
        i: Integer;
        DocumentType: Integer;
        // >> LCB-13
        AssignReportFormat: ReportFormat;
        OutStr: OutStream;
        ReportFilterLbl: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Purchase - Return Shipment" id="6636"><Options><Field name="NoOfCopies">0</Field><Field name="ShowInternalInfo">false</Field><Field name="ShowCorrectionLines">false</Field><Field name="LogInteraction">false</Field></Options><DataItems><DataItem name="Return Shipment Header">VERSION(1) SORTING(Field3) WHERE(Field3=1(%1))</DataItem><DataItem name="CopyLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="PageLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="DimensionLoop1">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Return Shipment Line">VERSION(1) SORTING(Field3,Field4)</DataItem><DataItem name="DimensionLoop2">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Total">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Total2">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>';
    // << LCB-13
    begin
        if NOT GetEmailSetup(ShowErrors) then
            exit;

        DocumentType := 5;

        //if sending behaviour is blank then standard will be used otherwise override behaviour with input parameter
        GetDocumentEmailSetup(DocumentType, SendingBehaviour);

        GetVendor(ReturnShipmentHeader."Buy-from Vendor No.", ReturnShipmentHeader."Pay-to Vendor No.",
                  ReturnShipmentHeader."Buy-from Contact No.", ReturnShipmentHeader."Pay-to Contact No.");

        GetCustVendEmail(DocumentType + 1, 1, ShowErrors);

        if (GetEmailType(1) = 1) then
            if NOT CheckSMTPSetup(ShowErrors) then
                exit;

        ReturnShipmentHeader.SETRECFILTER;

        ReportSelections.SetRange(Usage, ReportSelections.Usage::"P.Ret.Shpt.");

        ReportSelections.SetFilter("Report ID", '<>0');
        if ReportSelections.FindSet() then begin

            repeat

                i += 1;
                TempFileNames."Entry No." := i;
                TempFileNames."Document Filename" := CreateTempFile;
                TempFileNames.Insert();
                // >> LCB-13
                // CASE DocumentEmailSetup."Document File Type" OF
                //     DocumentEmailSetup."Document File Type"::PDF:
                //         REPORT.SAVEASPDF(ReportSelections."Report ID", TempFileNames."Document Filename", ReturnShipmentHeader);

                //     DocumentEmailSetup."Document File Type"::Word:
                //         REPORT.SAVEASWORD(ReportSelections."Report ID", TempFileNames."Document Filename", ReturnShipmentHeader);

                //     DocumentEmailSetup."Document File Type"::Excel:
                //         REPORT.SAVEASEXCEL(ReportSelections."Report ID", TempFileNames."Document Filename", ReturnShipmentHeader);
                // end;

                TempFileNames."Document File".CreateOutStream(OutStr);
                CASE DocumentEmailSetup."Document File Type" OF
                    DocumentEmailSetup."Document File Type"::PDF:
                        Report.SaveAs(ReportSelections."Report ID", StrSubstNo(ReportFilterLbl, ReturnShipmentHeader."No."), AssignReportFormat::Pdf, OutStr);
                    DocumentEmailSetup."Document File Type"::Word:
                        Report.SaveAs(ReportSelections."Report ID", StrSubstNo(ReportFilterLbl, ReturnShipmentHeader."No."), AssignReportFormat::Word, OutStr);
                    DocumentEmailSetup."Document File Type"::Excel:
                        Report.SaveAs(ReportSelections."Report ID", StrSubstNo(ReportFilterLbl, ReturnShipmentHeader."No."), AssignReportFormat::Excel, OutStr);
                end;
                TempFileNames.Modify();
            // << LCB-13
            until ReportSelections.Next() = 0;

            DocRecRef.GETTABLE(ReturnShipmentHeader);

            Filename := GetFilename;
            // >> LCB-13
            //MoveRenameFiles(TempFileNames, Filename, GetEmailType(1) = 0);

            //EmailSent := SendEmail(GetEmailType(1), DocumentType + 1, TempFileNames, 1);
            EmailSent := SendBlobEmail(GetEmailType(1), DocumentType + 1, TempFileNames, 1, Filename);
            // << LCB-13
            if EmailSent then begin
                ReturnShipmentHeader.Get(ReturnShipmentHeader."No.");
                ReturnShipmentHeader."GXL No. Emailed" += 1;
                ReturnShipmentHeader.Modify();
                COMMIT;
            end

        end;

        if GUIALLOWED AND ShowMessages AND EmailSent AND ShowEmailSentMsg(1) then
            MESSAGE(Text001Txt);

    end;


    procedure SendPurchCRADJNote(PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr."; ShowErrors: Boolean; ShowMessages: Boolean; SendingBehaviour: Option " ","Do Not Prompt User","Prompt User") EmailSent: Boolean
    var
        ReportSelections: Record "Report Selections";
        // >> LCB-13
        //TempFileNames: Record "GXL Email Log";
        TempFileNames: Record "GXL Email Log" temporary;
        // << LCB-13
        Filename: Text;
        i: Integer;
        DocumentType: Integer;
        // >> LCB-13
        AssignReportFormat: ReportFormat;
        OutStr: OutStream;
        ReportFilterLbl: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Purchase - Credit Memo - V1" id="10016855"><Options><Field name="NoOfCopies">0</Field><Field name="ShowInternalInfo">false</Field><Field name="LogInteraction">false</Field><Field name="AmountInWords">false</Field><Field name="CurrencyLCY">false</Field><Field name="ShowTHFormatting">false</Field></Options><DataItems><DataItem name="Purch. Cr. Memo Hdr.">VERSION(1) SORTING(Field3) WHERE(Field3=1(%1))</DataItem><DataItem name="CopyLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="PageLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="DimensionLoop1">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Purch. Cr. Memo Line">VERSION(1) SORTING(Field3,Field4)</DataItem><DataItem name="DimensionLoop2">VERSION(1) SORTING(Field1)</DataItem><DataItem name="VATCounter">VERSION(1) SORTING(Field1)</DataItem><DataItem name="VATCounterLCY">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Total">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Total2">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>';
    // << LCB-13
    begin
        if NOT GetEmailSetup(ShowErrors) then
            exit;

        DocumentType := 6;

        //if sending behaviour is blank then standard will be used otherwise override behaviour with input parameter
        GetDocumentEmailSetup(DocumentType, SendingBehaviour);

        GetVendor(PurchCrMemoHdr."Buy-from Vendor No.", PurchCrMemoHdr."Pay-to Vendor No.",
                  PurchCrMemoHdr."Buy-from Contact No.", PurchCrMemoHdr."Pay-to Contact No.");

        GetCustVendEmail(DocumentType + 1, 1, ShowErrors);

        if (GetEmailType(1) = 1) then
            if NOT CheckSMTPSetup(ShowErrors) then
                ; //exit; // >> upgrade << line commented

        PurchCrMemoHdr.SETRECFILTER;

        // >> LCB-192
        CustomReportSelection.SetRange("Source Type", 23);
        CustomReportSelection.SetRange("Source No.", PurchCrMemoHdr."Buy-from Vendor No.");
        CustomReportSelection.SetRange(Usage, CustomReportSelection.Usage::"P.Cr.Memo");
        CustomReportSelection.SetFilter("Report ID", '<>0');
        if CustomReportSelection.FindLast() then begin
            i += 1;
            TempFileNames."Entry No." := i;
            TempFileNames."Document Filename" := CreateTempFile;
            TempFileNames.Insert();

            TempFileNames."Document File".CreateOutStream(OutStr);
            Report.SaveAs(CustomReportSelection."Report ID", StrSubstNo(ReportFilterLbl, PurchCrMemoHdr."No."), AssignReportFormat::Pdf, OutStr);
            TempFileNames.Modify();
        end else begin
            // << LCB-192        
            ReportSelections.SetRange(Usage, ReportSelections.Usage::"P.Cr.Memo");
            ReportSelections.SetFilter("Report ID", '<>0');
            if ReportSelections.FindSet() then begin
                repeat
                    i += 1;
                    TempFileNames."Entry No." := i;
                    TempFileNames."Document Filename" := CreateTempFile;
                    TempFileNames.Insert();

                    // >> LCB-13
                    TempFileNames."Document File".CreateOutStream(OutStr);
                    CASE DocumentEmailSetup."Document File Type" OF
                        // DocumentEmailSetup."Document File Type"::PDF:
                        //     REPORT.SAVEASPDF(ReportSelections."Report ID", TempFileNames."Document Filename", PurchCrMemoHdr);

                        // DocumentEmailSetup."Document File Type"::Word:
                        //     REPORT.SAVEASWORD(ReportSelections."Report ID", TempFileNames."Document Filename", PurchCrMemoHdr);

                        // DocumentEmailSetup."Document File Type"::Excel:
                        //     REPORT.SAVEASEXCEL(ReportSelections."Report ID", TempFileNames."Document Filename", PurchCrMemoHdr);
                        DocumentEmailSetup."Document File Type"::PDF:
                            Report.SaveAs(ReportSelections."Report ID", StrSubstNo(ReportFilterLbl, PurchCrMemoHdr."No."), AssignReportFormat::Pdf, OutStr);
                        DocumentEmailSetup."Document File Type"::Word:
                            Report.SaveAs(ReportSelections."Report ID", StrSubstNo(ReportFilterLbl, PurchCrMemoHdr."No."), AssignReportFormat::Word, OutStr);
                        DocumentEmailSetup."Document File Type"::Excel:
                            Report.SaveAs(ReportSelections."Report ID", StrSubstNo(ReportFilterLbl, PurchCrMemoHdr."No."), AssignReportFormat::Excel, OutStr);
                    end;
                    TempFileNames.Modify();
                // << LCB-13
                until ReportSelections.Next() = 0;
            end;
            // >> LCB-192
        end;
        TempFileNames.CalcFields("Document File");
        if TempFileNames."Document File".Length = 0 then
            exit;
        // << LCB-192 

        DocRecRef.GETTABLE(PurchCrMemoHdr);
        Filename := GetFilename;
        // >> LCB-13
        //MoveRenameFiles(TempFileNames, Filename, GetEmailType(1) = 0);

        //EmailSent := SendEmail(GetEmailType(1), DocumentType + 1, TempFileNames, 1);
        EmailSent := SendBlobEmail(GetEmailType(1), DocumentType + 1, TempFileNames, 1, Filename);
        // << LCB-13
        if EmailSent then begin
            PurchCrMemoHdr.Get(PurchCrMemoHdr."No.");
            PurchCrMemoHdr."GXL No. Emailed" += 1;
            PurchCrMemoHdr.Modify();
            COMMIT;
        end;

        if GUIALLOWED AND ShowMessages AND EmailSent AND ShowEmailSentMsg(1) then
            MESSAGE(Text001Txt);
    end;

    procedure SendEmail(InputEmailType: Option " ",Outlook,SMTP; InputDocIntType: Integer; VAR InputTempFileNames: Record "GXL Email Log" temporary; InputType: Option Customer,Vendor): Boolean
    var
        User: Record User;
        TempDocEmailSetup: Record "GXL Document Email Setup";
        Mail: Codeunit Mail;
        // >> Upgrade
        //SMTPMail: Codeunit "SMTP Mail";
        SMTPMail: Codeunit "Email Message";
        EmailScenario: Enum "Email Scenario";
        Email: Codeunit Email;
        FileName: Text;
        Files: File;
        Instr: InStream;
        // << Upgrade
        SendSMTPMail: Boolean;
    begin
        SendSMTPMail := TRUE;

        //Outlook
        if (InputEmailType = InputEmailType::Outlook) then begin

            InputTempFileNames.Reset();
            InputTempFileNames.FindSet();
            repeat
                Mail.AttachFile(InputTempFileNames."Document Filename");
            until InputTempFileNames.Next() = 0;

            if Mail.NewMessage(GetCustVendEmail(InputDocIntType, InputType, FALSE), '', '', GetEmailSubject, GetEmailHTMLBody, '',
                               DocumentEmailSetup."Sending Behaviour" = DocumentEmailSetup."Sending Behaviour"::"Prompt User") then begin
                LogEmail(InputEmailType, 0, '', InputTempFileNames, InputType, '');  // >> LCB-50 << passing email as additional parameter
            end else begin
                LogEmail(InputEmailType, 1, Mail.GetErrorDesc, InputTempFileNames, InputType, '');  // >> LCB-50 << passing email as additional parameter
            end;

        end else begin
            //SMTP

            //UserSetup is already read from the initial GetEmailSetup
            User.SetCurrentKey("User Name");
            User.SetRange("User Name", USERID);
            User.FindFirst();

            if (DocumentEmailSetup."Sending Behaviour" = DocumentEmailSetup."Sending Behaviour"::"Prompt User") then begin

                TempDocEmailSetup := DocumentEmailSetup;
                TempDocEmailSetup.Insert();

                TempDocEmailSetup."Email Subject" := COPYSTR(GetEmailSubject, 1, MAXSTRLEN(TempDocEmailSetup."Email Subject"));

                TempDocEmailSetup.SaveEmailBody(GetEmailBody);

                TempDocEmailSetup.SaveEmailBodyHTML(GetEmailHTMLBody);

                TempDocEmailSetup.Modify();

                if (PAGE.RUNMODAL(Page::"GXL Email Template", TempDocEmailSetup) = ACTION::LookupOK) then begin
                    // >> Upgrade
                    // SMTPMail.CreateMessage(User."Full Name", UserSetup."E-Mail",
                    //                        GetCustVendEmail(InputDocIntType, InputType, FALSE),
                    //                        TempDocEmailSetup."Email Subject",
                    //                        TempDocEmailSetup.GetEmailBodytHTML, TRUE);
                    SMTPMail.Create(
                                         GetCustVendEmail(InputDocIntType, InputType, FALSE),
                                         TempDocEmailSetup."Email Subject",
                                         TempDocEmailSetup.GetEmailBodytHTML, TRUE);
                    // << Upgrade
                end else begin
                    SendSMTPMail := FALSE;
                end;

            end else begin
                // >> Upgrade
                // SMTPMail.CreateMessage(User."Full Name", UserSetup."E-Mail",
                //                        GetCustVendEmail(InputDocIntType, InputType, FALSE), GetEmailSubject, GetEmailHTMLBody, TRUE);
                SMTPMail.Create(
              GetCustVendEmail(InputDocIntType, InputType, FALSE), GetEmailSubject, GetEmailHTMLBody, TRUE);
                // << Upgrade
            end;

            if SendSMTPMail then begin
                InputTempFileNames.Reset();
                InputTempFileNames.FindSet();
                repeat
                    // >> Upgrade
                    //SMTPMail.AddAttachment(InputTempFileNames."Document Filename", FileManagement.GetFileName(InputTempFileNames."Document Filename"));
                    FileName := FileManagement.GetFileName(InputTempFileNames."Document Filename");
                    Files.Open(FileName);
                    Files.CreateInStream(Instr);
                    SMTPMail.AddAttachment(FileName, FileManagement.GetExtension(FileName), Instr);
                // << Upgrade
                until InputTempFileNames.Next() = 0;
                // >> Upgrade
                ClearLastError();
                //if SMTPMail.TrySend then begin
                if Email.Send(SMTPMail, EmailScenario::Default) then begin
                    // << Upgrade
                    LogEmail(InputEmailType, 0, '', InputTempFileNames, InputType, ''); // >> LCB-50 << passing email as additional parameter
                end else begin
                    // >> Upgrade
                    //LogEmail(InputEmailType, 1, SMTPMail.GetLastSendMailErrorText, InputTempFileNames, InputType, ''); // >> LCB-50 << passing email as additional parameter
                    LogEmail(InputEmailType, 1, GetLastErrorText(), InputTempFileNames, InputType, ''); // >> LCB-50 << passing email as additional parameter
                                                                                                        // << Upgrade
                end;
            end;

        end;

        InputTempFileNames.Reset();
        InputTempFileNames.FindSet();
        repeat
            CASE InputEmailType OF
                // >> Upgrade
                // Verified that this function has been removed from all the referencing objects in std
                // 0:
                //     FileManagement.DeleteClientFile(InputTempFileNames."Document Filename");
                // << Upgrade
                1:
                    DeleteServerFile(InputTempFileNames."Document Filename");
            end;
        until InputTempFileNames.Next() = 0;
        exit(SendSMTPMail);
    end;
    // >> LCB-13
    procedure SendBlobEmail(InputEmailType: Option Outlook,SMTP; InputDocIntType: Integer; VAR InputTempFileNames: Record "GXL Email Log" temporary; InputType: Option Customer,Vendor; FileName: Text): Boolean
    var
        CompanyInformation: Record "Company Information";
        User: Record User;
        TempDocEmailSetup: Record "GXL Document Email Setup";
        Mail: Codeunit Mail;
        // >> Upgrade
        //SMTPMail: Codeunit "SMTP Mail";
        SMTPMail: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailScenario: enum "Email Scenario";
        // << Upgrade
        SendSMTPMail: Boolean;
        i: Integer;
        TotalFile: Integer;
        InStr: Instream;
        TempFileName: Text;
        EmailId: Text;
        IsEmailSent: Boolean; // >> LCB-308 <<
    begin
        SendSMTPMail := TRUE;
        //Outlook
        if (InputEmailType = InputEmailType::Outlook) then begin

            InputTempFileNames.Reset();
            InputTempFileNames.FindSet();
            repeat
                Mail.AttachFile(InputTempFileNames."Document Filename");
            until InputTempFileNames.Next() = 0;

            if Mail.NewMessage(GetCustVendEmail(InputDocIntType, InputType, FALSE), '', '', GetEmailSubject, GetEmailHTMLBody, '',
                               DocumentEmailSetup."Sending Behaviour" = DocumentEmailSetup."Sending Behaviour"::"Prompt User") then begin
                LogEmail(InputEmailType, 0, '', InputTempFileNames, InputType, '');
                IsEmailSent := true; // >> LCB-308 <<
            end else begin
                LogEmail(InputEmailType, 1, Mail.GetErrorDesc, InputTempFileNames, InputType, '');
                IsEmailSent := false; // >> LCB-308 <<
            end;

        end else begin
            //SMTP

            //UserSetup is already read from the initial GetEmailSetup
            User.SetCurrentKey("User Name");
            User.SetRange("User Name", USERID);
            User.FindFirst();

            if (DocumentEmailSetup."Sending Behaviour" = DocumentEmailSetup."Sending Behaviour"::"Prompt User") then begin

                TempDocEmailSetup := DocumentEmailSetup;
                TempDocEmailSetup.Insert();

                TempDocEmailSetup."Email Subject" := COPYSTR(GetEmailSubject, 1, MAXSTRLEN(TempDocEmailSetup."Email Subject"));

                TempDocEmailSetup.SaveEmailBody(GetEmailBody);

                TempDocEmailSetup.SaveEmailBodyHTML(GetEmailHTMLBody);

                TempDocEmailSetup.Modify();

                if (PAGE.RUNMODAL(Page::"GXL Email Template", TempDocEmailSetup) = ACTION::LookupOK) then begin
                    // >> Upgrade
                    // SMTPMail.CreateMessage(User."Full Name", UserSetup."E-Mail",
                    //                        GetCustVendEmail(InputDocIntType, InputType, FALSE),
                    //                        TempDocEmailSetup."Email Subject",
                    //                        TempDocEmailSetup.GetEmailBodytHTML, TRUE);
                    SMTPMail.Create(
                                                            GetCustVendEmail(InputDocIntType, InputType, FALSE),
                                                            TempDocEmailSetup."Email Subject",
                                                            TempDocEmailSetup.GetEmailBodytHTML, TRUE);
                    // << Upgrade
                end else begin
                    SendSMTPMail := FALSE;
                    IsEmailSent := false; // >> LCB-308 <<
                end;

            end else begin
                // >> LCB-13
                CompanyInformation.Get();
                //SMTPMail.CreateMessage(User."Full Name", UserSetup."E-Mail",
                //                       GetCustVendEmail(InputDocIntType, InputType, FALSE), GetEmailSubject, GetEmailHTMLBody, TRUE);
                // >> LCB-192
                //SMTPMail.CreateMessage(CompanyInformation.Name, CompanyInformation."E-Mail",
                //                         GetCustVendEmail(InputDocIntType, InputType, FALSE), GetEmailSubject(), GetEmailBody(), false);

                if CustomReportSelection."Send To Email" > '' then
                    EmailId := CustomReportSelection."Send To Email"
                else
                    EmailId := Vendor."E-Mail";
                // >> Upgrade
                //SMTPMail.CreateMessage(CompanyInformation.Name, CompanyInformation."E-Mail", EmailId, GetEmailSubject(), GetEmailBody(), false);
                SMTPMail.Create(EmailId, GetEmailSubject(), GetEmailBody(), false);
                // << Upgrade
                // >> LCB-192
                // << LCB-13
            end;

            if SendSMTPMail then begin
                InputTempFileNames.Reset();
                InputTempFileNames.FindSet();
                TotalFile := InputTempFileNames.Count;
                repeat
                    InputTempFileNames.CalcFields("Document File");
                    i += 1;
                    InputTempFileNames."Document File".CreateInStream(InStr);
                    if TotalFile = 1 then
                        TempFileName := FileName + '.' + GetFileExtension()
                    else
                        TempFileName := FileName + Format(i) + '.' + GetFileExtension();
                    // >> Upgrade
                    //SMTPMail.AddAttachmentStream(InStr, TempFileName);
                    SMTPMail.AddAttachment(TempFileName, GetFileExtension(), InStr);
                    // << Upgrade
                    InputTempFileNames."Document Filename" := TempFileName;
                    InputTempFileNames.Modify();
                until InputTempFileNames.Next() = 0;
                // >> Ipgrade
                //if SMTPMail.TrySend then begin
                ClearLastError();
                if Email.Send(SMTPMail, EmailScenario) then begin
                    // << Upgrade
                    LogEmail(InputEmailType, 0, '', InputTempFileNames, 1, EmailId); // >> LCB-192 <<
                    IsEmailSent := true; // >> LCB-308 <<
                end else begin
                    // >> Upgrade
                    //LogEmail(InputEmailType, 1, SMTPMail.GetLastSendMailErrorText, InputTempFileNames, 1, EmailId); // >> LCB-192 <<
                    LogEmail(InputEmailType, 1, GetLastErrorText(), InputTempFileNames, 1, EmailId); // >> LCB-192 <<
                                                                                                     // << Upgrade
                    IsEmailSent := false; // >> LCB-308 <<                                                                                                     
                end;
            end;

        end;

        // InputTempFileNames.Reset();
        // InputTempFileNames.FindSet();
        // repeat
        //     CASE InputEmailType OF
        //         0:
        //             FileManagement.DeleteClientFile(InputTempFileNames."Document Filename");
        //         1:
        //             DeleteServerFile(InputTempFileNames."Document Filename");
        //     end;
        // until InputTempFileNames.Next() = 0;
        // >> LCB-308 <<
        //exit(SendSMTPMail);
        exit(IsEmailSent);
        // << LCB-308
    end;
    // << LCB-13
    local procedure GetEmailSubject(): Text
    begin
        exit(ConvertPlaceHolder(1, DocumentEmailSetup."Email Subject"));
    end;

    local procedure GetEmailBody(): Text
    begin
        // >> LCB-13
        //exit(ConvertPlaceHolder(2, DocumentEmailSetup.GetEmailBody));
        exit(ConvertPlaceHolder(2, DocumentEmailSetup.GetEmailBodyTemplate()));
        // << LCB-13
    end;

    local procedure GetFilename() Filename: Text
    begin
        if (DocumentEmailSetup."Document Filename" = '') then begin
            Filename := FORMAT(DocumentEmailSetup."Document Type");
        end else begin
            Filename := ConvertPlaceHolder(3, DocumentEmailSetup."Document Filename");
        end;

        Filename := DELCHR(Filename, '=', '."\/''%][');
    end;

    local procedure CreateTempFile(): Text
    begin
        exit(FileManagement.ServerTempFileName(GetFileExtension));
    end;
    //ERP-NAV Master Data Management -

    // >> LCB-50
    procedure SetTableDataForEmail(RecordIdP: RecordId; DocumentEmailSetupP: Record "GXL Document Email Setup"; VendorP: Record Vendor)
    begin
        case RecordIdP.TableNo of
            Database::"Purchase Header":
                DocRecRef.Get(RecordIdP);
        end;
        DocumentEmailSetup := DocumentEmailSetupP;
        Vendor := VendorP;
    end;
    // << LCB-50
    // >> 001
    procedure SendEmailConfirmPurchaseOrders(ShowErrors: Boolean; ShowMessages: Boolean; SendingBehaviour: Option ,"Do Not Prompt User","Prompt User"; BodyText: Text) EmailSent: Boolean
    var
        DocumentType: Integer;
        TempFileNames: Record "GXL Email Log";
        Expired: Text;
        ReturnText: Text;
        Text001: Label 'E-Mail Sent';
        Text017: Label 'Purchase Orders not cofirmed by supplier by 4PM';
    begin

        // >> PSSC.00 11523
        IF NOT GetEmailSetup(ShowErrors) THEN
            EXIT;
        //If sending behaviour is blank then standard will be used otherwise override behaviour with input parameter
        GetDocumentEmailSetup(DocumentType, SendingBehaviour);

        GetSupplyChainEmail(ShowErrors);

        //IF (GetEmailType(1) = 1) THEN
        //  IF NOT CheckSMTPSetup(ShowErrors) THEN
        //   EXIT;

        ShowMessages := TRUE;
        EmailSent := SendSupplyChainEmail(1, DocumentType + 1, 1, Text017, BodyText);

        IF GUIALLOWED AND ShowMessages AND EmailSent THEN
            MESSAGE(Text001);
        // << PSSC.00 11523

    end;
    // << 001
    var
        CustomReportSelection: Record "Custom Report Selection";
        DocFileNameG: Text; // >> HP2-Sprint2 <<

}