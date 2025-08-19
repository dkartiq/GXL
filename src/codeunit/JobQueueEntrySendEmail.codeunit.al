codeunit 50357 "GXL Job Queue Entry-Send Email"
{

    trigger OnRun()
    begin
    end;

    var
        // >> Upgrade
        //SMTPMailSetup: Record "SMTP Mail Setup";
        IntegrationSetup: Record "GXL Integration Setup";
        // << Upgrade
        EmailWhich: Option " ",Error,"Long Run";
        FileName: Text;
        FileSize: Integer;
        Text000Msg: Label 'Job Queue Entry ''%1'' Error';
        Text001Msg: Label 'Job Queue Entry ''%1'' Running Long';
        Text002Msg: Label 'Job Queue Entry ''%1'' failed with the following error: ''%2''.';
        Text003Msg: Label 'File which caused the error is: %1';
        Text004Msg: Label 'Job Queue Entry ''%1'' has run longer than it''s ending time ''%2''.';


    procedure SendEmail(JobQueueEntry: Record "Job Queue Entry"): Boolean
    var
        // >> Upgrade
        //SMTPMail: Codeunit "SMTP Mail";
        SMTPMail: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailScenario: Enum "Email Scenario";
        Files: File;
        Instr: InStream;
        FileMgmt: Codeunit "File Management";
        // << Upgrade
        SendSMTPMail: Boolean;
    begin
        if JobQueueEntry."GXL Error Notif. Email Address" = '' then
            exit;
        IF NOT CheckSMTPSetup(GUIALLOWED()) THEN
            EXIT;
        // >> Upgrade
        //SMTPMail.CreateMessage('', SMTPMailSetup."User ID", JobQueueEntry."GXL Error Notif. Email Address", GetEmailSubject(JobQueueEntry), GetEmailBody(JobQueueEntry), TRUE);
        SMTPMail.Create(JobQueueEntry."GXL Error Notif. Email Address", GetEmailSubject(JobQueueEntry), GetEmailBody(JobQueueEntry), TRUE);
        // << Upgrade
        IF FileName <> '' THEN BEGIN
            IF FileSizeAllowed() THEN BEGIN
                // >> Upgrade
                //SMTPMail.AddAttachment(FileName, ReturnFileNameNoPath(FileName));
                Files.Open(FileName);
                Files.CreateInStream(Instr);
                SMTPMail.AddAttachment(ReturnFileNameNoPath(FileName), FileMgmt.GetExtension(FileName), Instr);
                // << pgrade
                // IF GUIALLOWED THEN
                //     SMTPMail.AddAttachment(FileName, ReturnFileNameNoPath(FileName))
                // ELSE
                //     IF SMTPMail.AddAttachment2(FileName) THEN; //this function doesn't error
            END;
        END;
        // >> Upgrade
        //SendSMTPMail := SMTPMail.TrySend();
        SendSMTPMail := Email.Send(SMTPMail, EmailScenario);
        // << Upgrade
        EXIT(SendSMTPMail);
    end;

    procedure SetOptions(NewEmailWhich: Option " ",Error,"Long Run"; NewFileName: Text; NewFileSize: Integer)
    begin
        EmailWhich := NewEmailWhich;
        FileName := NewFileName;
        FileSize := NewFileSize;
    end;

    local procedure CheckSMTPSetup(ShowErrors: Boolean): Boolean
    var
        MailManagement: Codeunit "Mail Management";
        // >> Upgrade
        //SMTPMailSetup: Record "SMTP Mail Setup";
        AutoImport: Codeunit "GXL Auto Import IC Trans";
        SMTPError: Label 'SMTP setup does not exists';
    // << Upgrade
    begin
        IF ShowErrors THEN BEGIN
            // >> Upgrade
            // SMTPMailSetup.GET();
            // SMTPMailSetup.TESTFIELD("SMTP Server");
            // SMTPMailSetup.TESTFIELD("User ID");
            // MailManagement.CheckValidEmailAddresses(SMTPMailSetup."User ID");
            if not AutoImport.CheckSMTPSetup() then
                Error(SMTPError);
            // << Upgrade

        END ELSE BEGIN
            // >> Upgrade
            // IF SMTPMailSetup.GET() THEN BEGIN
            //     IF (SMTPMailSetup."SMTP Server" = '') THEN
            //         EXIT(FALSE);
            //     IF (SMTPMailSetup."User ID" = '') THEN
            //         EXIT(FALSE);
            //     IF NOT MailManagement.ValidateEmailAddressField(SMTPMailSetup."User ID") THEN
            //         EXIT(FALSE);
            // END ELSE
            //     EXIT(FALSE);
            exit(AutoImport.CheckSMTPSetup());
            // << Upgrade
        END;

        EXIT(TRUE);
    end;

    local procedure GetEmailSubject(InputJobQueueEntry: Record "Job Queue Entry"): Text
    begin
        CASE EmailWhich OF

            EmailWhich::Error:
                EXIT(STRSUBSTNO(Text000Msg, InputJobQueueEntry.Description));

            EmailWhich::"Long Run":
                EXIT(STRSUBSTNO(Text001Msg, InputJobQueueEntry.Description));

            ELSE
                EXIT;
        END;
    end;

    local procedure GetEmailBody(InputJobQueueEntry: Record "Job Queue Entry"): Text
    var
        EmailBody: Text;
    begin
        CASE EmailWhich OF

            EmailWhich::Error:
                BEGIN
                    // >> Upgrade
                    //EmailBody := '<p>' + STRSUBSTNO(Text002Msg, InputJobQueueEntry.Description, InputJobQueueEntry.GetErrorMessage()) + '</p>';
                    EmailBody := '<p>' + STRSUBSTNO(Text002Msg, InputJobQueueEntry.Description, InputJobQueueEntry."Error Message") + '</p>';
                    // << Upgrade
                    IF FileName <> '' THEN BEGIN

                        IF EXISTS(FileName) THEN
                            EmailBody := EmailBody + '<p>' + STRSUBSTNO(Text003Msg, FileName) + '</p>';

                    END;
                END;

            EmailWhich::"Long Run":
                BEGIN
                    EmailBody := '<p>' + STRSUBSTNO(Text004Msg, InputJobQueueEntry.Description, InputJobQueueEntry."Ending Time") + '</p>';
                END;

            ELSE
                EXIT;
        END;

        EXIT(EmailBody);
    end;

    local procedure FileSizeAllowed(): Boolean
    var
        SizeInBytes: Integer;
        AllowedSizeInBytes: Integer;
        IntegrationSetup: Record "GXL Integration Setup"; // >> Upgrade <<
    begin
        // >> Upgrade
        // IF (SMTPMailSetup."GXL Maximum Message Size in MB" = 0) THEN
        //     EXIT(TRUE);

        // SizeInBytes := SMTPMailSetup."GXL Maximum Message Size in MB" * 1000000;
        IF (IntegrationSetup."GXL Maximum Message Size in MB" = 0) THEN
            EXIT(TRUE);

        SizeInBytes := IntegrationSetup."GXL Maximum Message Size in MB" * 1000000;
        AllowedSizeInBytes := SizeInBytes - 200000; //200KB for message text
        // << Upgrade

        EXIT(AllowedSizeInBytes >= FileSize);
    end;

    local procedure ReturnFileNameNoPath(FileNameAndPath: Text): Text
    var
        FNAP: Text;
        BackslashPos: Integer;
        BackslashTxt: Label '\';
    begin
        FNAP := FileNameAndPath;
        repeat
            BackslashPos := StrPos(FNAP, BackslashTxt);
            if BackslashPos = 0 then
                exit(FNAP);
            FNAP := CopyStr(FNAP, BackslashPos + 1);
        until StrLen(FNAP) = 0;
        exit(FNAP);
    end;

}

