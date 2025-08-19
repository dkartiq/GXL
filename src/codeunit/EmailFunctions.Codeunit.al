codeunit 50361 "GXL Email Functions"
{
    trigger OnRun()
    begin
    end;

    var
        Text001Txt: Label 'The email address "%1" is invalid.';


    [Scope('OnPrem')]
    procedure CreateBaseSetup()
    var
        i: Integer;
    begin
        FOR i := 0 TO 17 DO BEGIN
            CreateBaseDocSetup(i);
        END;
    end;

    local procedure CreateBaseDocSetup(InputDocType: Option "Customer Statement","Purchase Quote","Purchase Order","Purchase Blanket Order","Purchase Return Order","Purchase Return Shipment","Purchase CR/Adj Note","Sales Quote","Sales Order","Sales Blanket Order","Sales Shipment","Sales Invoice","Sales Return Order","Sales CR/Adj Note","Service Order","Service Shipment","Service Invoice","Service CR/Adj Note")
    var
        DocumentEmailSetup: Record "GXL Document Email Setup";
    begin
        DocumentEmailSetup."Document Type" := InputDocType;
        IF DocumentEmailSetup.INSERT(TRUE) THEN;
    end;

    [Scope('OnPrem')]
    procedure CheckValidEmailAddresses(Recipients: Text)
    var
        TmpRecipients: Text;
    begin
        IF Recipients = '' THEN
            EXIT;

        TmpRecipients := Recipients;
        WHILE STRPOS(TmpRecipients, ';') > 1 DO BEGIN
            CheckValidEmailAddress(COPYSTR(TmpRecipients, 1, STRPOS(TmpRecipients, ';') - 1));
            TmpRecipients := COPYSTR(TmpRecipients, STRPOS(TmpRecipients, ';') + 1);
        END;
        CheckValidEmailAddress(TmpRecipients);
    end;

    local procedure CheckValidEmailAddress(EmailAddress: Text)
    var
        i: Integer;
        NoOfAtSigns: Integer;
    begin
        IF EmailAddress = '' THEN
            ERROR(Text001Txt, EmailAddress);

        IF (EmailAddress[1] = '@') OR (EmailAddress[STRLEN(EmailAddress)] = '@') THEN
            ERROR(Text001Txt, EmailAddress);

        FOR i := 1 TO STRLEN(EmailAddress) DO BEGIN
            IF EmailAddress[i] = '@' THEN
                NoOfAtSigns := NoOfAtSigns + 1;
            IF NOT (
                    ((EmailAddress[i] >= 'a') AND (EmailAddress[i] <= 'z')) OR
                    ((EmailAddress[i] >= 'A') AND (EmailAddress[i] <= 'Z')) OR
                    ((EmailAddress[i] >= '0') AND (EmailAddress[i] <= '9')) OR
                    ((NoOfAtSigns = 0) AND (EmailAddress[i] IN ['!', '#', '$', '%', '&', '''',
                                                                '*', '+', '-', '/', '=', '?',
                                                                '^', '_', '`', '.', '{', '|',
                                                                '}', '~'])) OR
                    ((NoOfAtSigns > 0) AND (EmailAddress[i] IN ['@', '.', '-', '[', ']'])))
            THEN
                ERROR(Text001Txt, EmailAddress);
        END;

        IF NoOfAtSigns <> 1 THEN
            ERROR(Text001Txt, EmailAddress);
    end;

    [Scope('OnPrem')]
    procedure LookUpSentSalesInvoice(SalesInvHeader: Record "Sales Invoice Header")
    var
        DocRecRef: RecordRef;
    begin
        DocRecRef.GETTABLE(SalesInvHeader);
        RunEmailDocLog(DocRecRef.RecordId());
    end;

    [Scope('OnPrem')]
    procedure LookUpSentSalesHeader(SalesHeader: Record "Sales Header")
    var
        DocRecRef: RecordRef;
    begin
        DocRecRef.GETTABLE(SalesHeader);
        RunEmailDocLog(DocRecRef.RecordId());
    end;

    [Scope('OnPrem')]
    procedure LookUpSentSalesShipment(SalesShipmentHeader: Record "Sales Shipment Header")
    var
        DocRecRef: RecordRef;
    begin
        DocRecRef.GETTABLE(SalesShipmentHeader);
        RunEmailDocLog(DocRecRef.RecordId());
    end;

    [Scope('OnPrem')]
    procedure LookUpSentSalesCRADJNote(SalesCrMemoHeader: Record "Sales Cr.Memo Header")
    var
        DocRecRef: RecordRef;
    begin
        DocRecRef.GETTABLE(SalesCrMemoHeader);
        RunEmailDocLog(DocRecRef.RecordId());
    end;

    [Scope('OnPrem')]
    procedure LookUpSentPurchaseHeader(PurchaseHeader: Record "Purchase Header")
    var
        DocRecRef: RecordRef;
    begin
        DocRecRef.GETTABLE(PurchaseHeader);
        RunEmailDocLog(DocRecRef.RecordId());
    end;

    [Scope('OnPrem')]
    procedure LookUpSentPurchReturnShipment(ReturnShipmentHeader: Record "Return Shipment Header")
    var
        DocRecRef: RecordRef;
    begin
        DocRecRef.GETTABLE(ReturnShipmentHeader);
        RunEmailDocLog(DocRecRef.RecordId());
    end;

    [Scope('OnPrem')]
    procedure LookUpSentPurchCRADJNote(PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.")
    var
        DocRecRef: RecordRef;
    begin
        DocRecRef.GETTABLE(PurchCrMemoHdr);
        RunEmailDocLog(DocRecRef.RecordId());
    end;

    [Scope('OnPrem')]
    procedure LookUpSentServiceOrder(ServiceHeader: Record "Service Header")
    var
        DocRecRef: RecordRef;
    begin
        DocRecRef.GETTABLE(ServiceHeader);
        RunEmailDocLog(DocRecRef.RecordId());
    end;

    [Scope('OnPrem')]
    procedure LookUpSentServiceShipment(ServiceShipHeader: Record "Service Shipment Header")
    var
        DocRecRef: RecordRef;
    begin
        DocRecRef.GETTABLE(ServiceShipHeader);
        RunEmailDocLog(DocRecRef.RecordId());
    end;

    [Scope('OnPrem')]
    procedure LookUpSentServiceInvoice(ServiceInvoiceHeader: Record "Service Invoice Header")
    var
        DocRecRef: RecordRef;
    begin
        DocRecRef.GETTABLE(ServiceInvoiceHeader);
        RunEmailDocLog(DocRecRef.RecordId());
    end;

    [Scope('OnPrem')]
    procedure LookUpSentServiceCRADJNote(ServiceCrMemoHeader: Record "Service Cr.Memo Header")
    var
        DocRecRef: RecordRef;
    begin
        DocRecRef.GETTABLE(ServiceCrMemoHeader);
        RunEmailDocLog(DocRecRef.RecordId());
    end;

    [Scope('OnPrem')]
    procedure RunEmailDocLog(InputRecordID: RecordID)
    var
        EmailDocumentLog: Page "GXL Email Document Log";
    begin
        EmailDocumentLog.SetRecIDFilter(InputRecordID);
        EmailDocumentLog.RUN();
    end;

    [Scope('OnPrem')]
    procedure CheckValidEmailAddresses2(Recipients: Text): Boolean
    var
        TmpRecipients: Text;
    begin
        IF Recipients = '' THEN
            EXIT(FALSE);

        TmpRecipients := Recipients;
        WHILE STRPOS(TmpRecipients, ';') > 1 DO BEGIN
            IF NOT CheckValidEmailAddress2(COPYSTR(TmpRecipients, 1, STRPOS(TmpRecipients, ';') - 1)) THEN
                EXIT(FALSE);
            TmpRecipients := COPYSTR(TmpRecipients, STRPOS(TmpRecipients, ';') + 1);
        END;
        IF NOT CheckValidEmailAddress2(TmpRecipients) THEN
            EXIT(FALSE);

        EXIT(TRUE);
    end;

    local procedure CheckValidEmailAddress2(EmailAddress: Text): Boolean
    var
        i: Integer;
        NoOfAtSigns: Integer;
    begin
        IF EmailAddress = '' THEN
            EXIT(FALSE);

        IF (EmailAddress[1] = '@') OR (EmailAddress[STRLEN(EmailAddress)] = '@') THEN
            EXIT(FALSE);

        FOR i := 1 TO STRLEN(EmailAddress) DO BEGIN
            IF EmailAddress[i] = '@' THEN
                NoOfAtSigns := NoOfAtSigns + 1;
            IF NOT (
                    ((EmailAddress[i] >= 'a') AND (EmailAddress[i] <= 'z')) OR
                    ((EmailAddress[i] >= 'A') AND (EmailAddress[i] <= 'Z')) OR
                    ((EmailAddress[i] >= '0') AND (EmailAddress[i] <= '9')) OR
                    ((NoOfAtSigns = 0) AND (EmailAddress[i] IN ['!', '#', '$', '%', '&', '''',
                                                                '*', '+', '-', '/', '=', '?',
                                                                '^', '_', '`', '.', '{', '|',
                                                                '}', '~'])) OR
                    ((NoOfAtSigns > 0) AND (EmailAddress[i] IN ['@', '.', '-', '[', ']'])))
            THEN
                EXIT(FALSE);
        END;

        IF NoOfAtSigns <> 1 THEN
            EXIT(FALSE);

        EXIT(TRUE);
    end;
}

