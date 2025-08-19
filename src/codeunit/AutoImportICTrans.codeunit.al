/// <summary>
/// ERP-NAV Master Data Management: Automate IC Transctions
/// </summary>
codeunit 50032 "GXL Auto Import IC Trans"
{
    trigger OnRun()
    var
        InboxTransaction2: Record "IC Inbox Transaction";
        HandledInboxTransaction2: Record "Handled IC Inbox Trans.";
        ICInboxTransaction: Record "IC Inbox Transaction";
        AutoICProcess: Codeunit "GXL AutoImportICTrans-Process";
    begin
        GLSetup.Get();
        if not GLSetup."GXL Automate IC Transactions" then
            exit;

        ICInboxTransaction.Reset();
        ICInboxTransaction.SetCurrentKey("Document No.");
        ICInboxTransaction.SetRange("Transaction Source", ICInboxTransaction."Transaction Source"::"Created by Partner");
        if ICInboxTransaction.FindSet() then
            repeat
                if ICInboxTransaction."Line Action" = ICInboxTransaction."Line Action"::"No Action" then begin

                    //Update line action
                    ICInboxTransaction.Validate("Line Action", ICInboxTransaction."Line Action"::Accept);
                    if not ICInboxTransaction.Modify() then begin
                        HandleErrorException(ICInboxTransaction);
                        exit;
                    end;
                    Commit();
                    InboxTransaction2 := ICInboxTransaction;

                    //Process incoming transactions
                    CLEAR(AutoICProcess);
                    if AutoICProcess.RUN(ICInboxTransaction) then
                        EmailNotification(ICInboxTransaction, false)
                    else begin
                        HandleErrorException(ICInboxTransaction);
                        ICInboxTransaction.Validate("Line Action", ICInboxTransaction."Line Action"::"No Action");
                        ICInboxTransaction.Modify();
                        exit;
                    end;
                end;
            until ICInboxTransaction.Next() = 0;
    end;

    var
        EmailAccount: Record "Email Account";
        GLSetup: Record "General Ledger Setup";


    procedure HandleErrorException(ICInboxEntry: Record "IC Inbox Transaction")
    var
        ErrorLog: Record "GXL IC Automation Error Log";
        EntryNo: Integer;
    begin
        ErrorLog.Reset();
        ErrorLog.SetCurrentKey("Transaction No.");
        ErrorLog.SetRange("Transaction No.", ICInboxEntry."Transaction No.");
        ErrorLog.SetRange("IC Partner Code", ICInboxEntry."IC Partner Code");
        ErrorLog.SetRange("Source Type", ICInboxEntry."Source Type");
        ErrorLog.SetRange("Error Message", COPYSTR(GetLastErrorText(), 1, 250));
        ErrorLog.SetRange("Document Type", ICInboxEntry."Document Type");
        ErrorLog.SetRange("Document No.", ICInboxEntry."Document No.");
        if not ErrorLog.IsEmpty() then
            exit;

        ErrorLog.Reset();
        if ErrorLog.FindLast() then
            EntryNo := ErrorLog."Entry No."
        else
            EntryNo := 0;
        ErrorLog.Init();
        ErrorLog."Entry No." := EntryNo + 1;
        ErrorLog."Transaction No." := ICInboxEntry."Transaction No.";
        ErrorLog."IC Partner Code" := ICInboxEntry."IC Partner Code";
        ErrorLog."Source Type" := ICInboxEntry."Source Type";
        ErrorLog."Document Type" := ICInboxEntry."Document Type";
        ErrorLog."Document No." := ICInboxEntry."Document No.";
        ErrorLog."Error Message" := COPYSTR(GetLastErrorText(), 1, 250);
        ErrorLog.Insert();
        EmailNotification(ICInboxEntry, TRUE);
    end;
    // >> Upgrade
    // procedure CheckSMTPSetup(): Boolean
    // begin
    //     EmailAccount.Reset();
    //     // >> Upgrade
    //     //EmailAccount.SetFilter(Connector, 'SMTP');
    //     EmailAccount.SetRange(Connector, EmailAccount.Connector::SMTP);
    //     // << Upgrade
    //     if EmailAccount.FindLast() then
    //         exit(TRUE);
    // end;
    // procedure CheckSMTPSetup(): Boolean
    // var
    //     TempEmailAccount: Record "Email Account" temporary;
    // begin

    //     TempEmailAccount.Reset();
    //     TempEmailAccount.SetRange(Connector, TempEmailAccount.Connector::SMTP);
    //     if TempEmailAccount.FindLast() then
    //         exit(TRUE);
    // end;

    procedure CheckSMTPSetup(): Boolean
    var
        EmailAccounts: Record "Email Account";
        IEmailConnector: Interface "Email Connector";
        Connector: Enum "Email Connector";
    begin

        foreach Connector in Connector.Ordinals do begin
            IEmailConnector := Connector;

            EmailAccounts.DeleteAll();
            IEmailConnector.GetAccounts(EmailAccounts);

            if EmailAccounts.FindSet() then
                repeat
                    if EmailAccounts.Connector = EmailAccounts.Connector::SMTP then
                        exit(true);
                until EmailAccounts.Next() = 0;
        end;

    end;
    // << Upgrade


    procedure EmailNotification(ICInboxEntry: Record "IC Inbox Transaction"; HasError: Boolean): Boolean
    var
        EmailMessage: Codeunit "Email Message";
        EmailSend: Codeunit Email;
        SendSMTPMail: Boolean;
        EmailSubject: Text[250];
        EmailBody: Text[250];
    begin
        if not CheckSMTPSetup then
            exit;

        if HasError then
            EmailSubject := FORMAT(ICInboxEntry."Source Type") + ' ' + ICInboxEntry."Document No." +
                            ' created by partner ' + ICInboxEntry."IC Partner Code" + ' cannot be processed. Please review the error from IC Inbox Transactions page.'
        else
            EmailSubject := FORMAT(ICInboxEntry."Source Type") + ' ' + ICInboxEntry."Document No." +
                            ' created by partner ' + ICInboxEntry."IC Partner Code" + ' is ready for review';

        EmailMessage.Create(GLSetup."GXL Automate IC E-Mail", EmailSubject, EmailBody, true);
        exit(EmailSend.Send(EmailMessage, Enum::"Email Scenario"::Default));
    end;
}

