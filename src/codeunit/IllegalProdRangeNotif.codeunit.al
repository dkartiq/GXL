codeunit 50009 "GXL Illegal Prod Range Notif."
{
    trigger OnRun()
    var
        IllegalProdRangeLog: Record "GXL Illegal Product Range Log";
    begin
        IllegalProdRangeLog.SetCurrentKey("Sent Date");
        IllegalProdRangeLog.SetRange("Sent Date", 0D);
        SendUnableToRange(IllegalProdRangeLog);

    end;

    var
        SupplyChainSetup: Record "GXL Supply Chain Setup";
        // >> Upgrade
        //SMTPSetup: Record "SMTP Mail Setup";

        //SMTPMail: Codeunit "SMTP Mail";
        SMTPMail: Codeunit "Email Message";
        // << Upgrade
        FileMgt: Codeunit "File Management";
        SetupRead: Boolean;
        SubjectTxt: Label 'Product unable to range.';
        BodyTxt: Label 'Attached report listed products which are unable to range due to legal issues.';


    procedure SendUnableToRange(VAR Rec: Record "GXL Illegal Product Range Log")
    var
        IllegalProdRangeLog: Record "GXL Illegal Product Range Log";
        Email: Text;
        ServerFileName: Text;
        TempPath: Text;
        TargetFileName: Text;
    begin
        GetSetups();
        CheckEmailSetup();
        Email := GetEmail();
        if Email = '' then
            exit;

        IllegalProdRangeLog.COPY(Rec);
        if IllegalProdRangeLog.ISEMPTY then
            exit;

        ServerFileName := CreateTempFile();

        ExportFile(IllegalProdRangeLog, ServerFileName);

        if FileMgt.ServerFileExists(ServerFileName) then begin
            TempPath := FileMgt.GetDirectoryName(ServerFileName);
            TargetFileName := FileMgt.CombinePath(TempPath, StrSubstNo('IllegalItems_%1.csv', Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>T<Hours24,2><Minutes,2>')));

            MoveFile(ServerFileName, TargetFileName, true);
            SendEmail(Email, SubjectTxt, BodyTxt, TargetFileName);
            IllegalProdRangeLog.ModifyAll("Sent Date", WorkDate());
        end;
    end;

    procedure CheckEmailSetup()
    begin
        GetSetups();
        if GuiAllowed() then
            SupplyChainSetup.TestField("Illegal Product Range Email");
    end;

    LOCAL procedure CreateTempFile(): Text
    begin
        exit(FileMgt.ServerTempFileName('tmp'));
    end;

    LOCAL procedure DeleteServerFile(FilePath: Text): Boolean
    begin
        if not FileMgt.ServerFileExists(FilePath) then
            exit(false);

        FileMgt.DeleteServerFile(FilePath);
        exit(true);
    end;

    LOCAL procedure MoveFile(SourceFileName: Text; TargetFileName: Text; DeleteSourceFile: Boolean)
    var
        EDIExport: Codeunit "GXL 3PL EDI - Export";
    begin
        DeleteServerFile(TargetFileName);
        // >> Upgrade
        // FileMgt.MoveFile(SourceFileName, TargetFileName);
        // if DeleteSourceFile then
        //     FileMgt.DeleteServerFile(SourceFileName);
        EDIExport.MoveFile(SourceFileName, TargetFileName, DeleteSourceFile);
        // << Ugrade
    end;

    LOCAL procedure SendEmail(Email: Text; Subject: Text; Body: Text; FileName: Text)
    var
        // >> Upgrade
        EmnailL: Codeunit Email;
        EmailScenario: Enum "Email Scenario";
        Files: File;
        Instr: InStream;
    // << Upgrade
    begin
        // >> Upgrade
        //SMTPMail.CreateMessage('', SMTPSetup."User ID", Email, Subject, Body, true);
        // if FileName <> '' then
        //SMTPMail.AddAttachment(FileName, 'IllegalItems.csv');
        SMTPMail.Create(Email, Subject, Body, true);
        if FileName <> '' then begin
            Files.Open(FileName);
            Files.CreateInStream(Instr);
            SMTPMail.AddAttachment('IllegalItems', '.csv', Instr);
        end;
        // << Upgrade

        //SMTPMail.Send();
        EmnailL.Send(SMTPMail, EmailScenario::Default);
    end;

    LOCAL procedure GetEmail(): Text
    begin
        exit(SupplyChainSetup."Illegal Product Range Email");
    end;

    LOCAL procedure GetSetups()
    begin
        if not SetupRead then begin
            SupplyChainSetup.Get();
            //SMTPSetup.Get(); // >> Upgrade <<
            SetupRead := true;
        end;
    end;

    LOCAL procedure ExportFile(VAR Rec: Record "GXL Illegal Product Range Log"; FileName: Text)
    var
        ExportIllegalProdRangeLog: XmlPort "GXL Export IllegalProdRangeLog";
        OutputFile: File;
        FileOutStream: OutStream;
    begin

        OutputFile.Create(FileName);
        OutputFile.CreateOutStream(FileOutStream);

        ExportIllegalProdRangeLog.SetTableView(Rec);
        ExportIllegalProdRangeLog.SetDestination(FileOutStream);
        ExportIllegalProdRangeLog.Export();

        OutputFile.Close();
    end;
}