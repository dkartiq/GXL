// 001 23.06.2025 KDU HP2-Sprint1-Changes
codeunit 50385 "GXL 3PL EDI - Export"
{
    TableNo = "GXL ASN Header";

    trigger OnRun()
    var
        ASNHeader: Record "GXL ASN Header";
    begin
        ASNHeader := Rec;

        Location.GET(ASNHeader."Ship-To Code");
        ValidateFinalDestination(FinalDestination);
        RunDataport(ASNHeader, FinalDestination);

        //TODO: EDI File Log
        if ASNHeader."EDI File Log Entry No." = 0 then
            ASNHeader.AddEDIFileLog();

        ASNHeader.VALIDATE(Status, ASNHeader.Status::"3PL ASN Sent");
        ASNHeader.Modify();
        Rec := ASNHeader;
    end;

    var
        Location: Record Location;
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        FinalDestination: Text;
        Text000Txt: Label 'File already exists.';

    local procedure ValidateFinalDestination(FinalDestination: Text)
    var
        FileMngt: Codeunit "File Management";
    begin
        if FinalDestination = '' then
            exit;

        IF FileMngt.ServerFileExists(FinalDestination) THEN BEGIN
            EDIErrorMgt.SetErrorMessage(Text000Txt);
            EDIErrorMgt.ThrowErrorMessage();
        END;
    end;

    local procedure RunDataport(ASN: Record "GXL ASN Header"; FinalDestination: Text)
    var
        FileManagement: Codeunit "File Management";
        ASNXmlPort: XMLport "GXL 3PL ASN Export";
        FileVar: File;
        OutStreamVar: OutStream;
        ServerTempFile: Text;
    begin
        if FinalDestination <> '' then begin
            ServerTempFile := '';
            CASE Location."GXL Send File Format" OF
                Location."GXL Send File Format"::XML:
                    ServerTempFile := FileManagement.ServerTempFileName('xml');
                Location."GXL Send File Format"::CSV:
                    ServerTempFile := FileManagement.ServerTempFileName('csv');
            END;

            FileVar.CREATE(ServerTempFile);
            FileVar.CREATEOUTSTREAM(OutStreamVar);
            CLEAR(ASNXmlPort);
            ASNXmlPort.SetOptions(ASN."Document Type", ASN."No.", FALSE);
            ASNXmlPort.SETDESTINATION(OutStreamVar);
            ASNXmlPort.EXPORT();
            FileVar.CLOSE();
            MoveFile(ServerTempFile, FinalDestination, TRUE);
        end;
    end;

    procedure SetOptions(FinalDestinationNew: Text)
    begin
        FinalDestination := FinalDestinationNew;
    end;

    // >> Upgrade
    //local procedure MoveFile(SourceFileName: Text; TargetFileName: Text; DeleteSourceFile: Boolean)
    procedure MoveFile(SourceFileName: Text; TargetFileName: Text; DeleteSourceFile: Boolean)
    // << Upgrade
    var
        FileMgt: Codeunit "File Management";
        // >> Upgrade
        //ServerFileHelper: DotNet File;
        ServerFileHelper: DotNet File1;
    // << Upgrade
    begin
        // >> 001
        // IF GUIALLOWED() THEN
        //     FileMgt.DownloadHandler(SourceFileName, '', '', '', TargetFileName)
        // ELSE
        // << 001
        ServerFileHelper.Copy(SourceFileName, TargetFileName);

        IF DeleteSourceFile THEN
            ServerFileHelper.Delete(SourceFileName);
    end;
}

