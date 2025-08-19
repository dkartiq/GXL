dotnet
{
    // >> Upgrade
    // Unused variable commented
    // assembly(System)
    // {
    //     type("System.Net.FtpWebRequest"; FtpRequest) { }
    //     type("System.Net.FtpWebResponse"; FtpResponse) { }
    // }
    // << Upgrade
    assembly(mscorlib)
    {
        type("System.IO.FileStream"; FileStream) { }
    }
    assembly(WinSCPnet)
    {
        Version = '1.14.0.13797';

        type(WinSCP.Session; WinSCPSession) { }
        type(WinSCP.SessionOptions; WinSCPSessionOptions) { }
        type(WinSCP.TransferOptions; WinSCPTransferOptions) { }
        type(WinSCP.TransferOperationResult; WinSCPTransferResult) { }
        type(WinSCP.TransferResumeSupport; WinSCPTransferResumeSupport) { }
        type(WinSCP.TransferResumeSupportState; WinSCPTransferResumeSupportState) { }
        type(WinSCP.Protocol; WinSCPProtocol) { }
        type(WinSCP.TransferMode; WinSCPTransferMode) { }

    }
}
codeunit 50480 "GXL Comestri IntegrationHelper"
{
    //Bloyal integration
    //The Bloyal helpers will push the data in json format to web services 
    //Json data is created via other related Bloyal codeunits which are run via job queue

    /* Change Log
        WRP-287 2020-09-18 LP
            UploadFiletoFTP: Cleanup resource
    */

    Permissions = tabledata "GXL Comestri Azure Log" = rimd;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        ZipBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        ZipFile: OutStream;
        SetupRead: Boolean;
        WSType: Option "Product","SOH";
        Url: Text;
        MaxNoTry: Integer;


    procedure PushToAzure(var ComestriAzureLog: Record "GXL Comestri Azure Log"; var InS: InStream; SFTP: Boolean; PayLoad: Text)
    var
        Client: HttpClient;
        ContentHeaders: HttpHeaders;
        Content: HttpContent;
        Response: HttpResponseMessage;
        AuthString: Text;
        i: Integer;
    begin
        GetSetup();
        WSType := ComestriAzureLog."Web Service Name";
        GetConnectionSetup();

        AuthString := StrSubstNo('%1', IntegrationSetup."Bloyal Access Token");
        Client.DefaultRequestHeaders().Add('Ocp-Apim-Subscription-Key', AuthString);
        Content.GetHeaders(ContentHeaders);
        if SFTP then
            Content.WriteFrom(Payload)
        else
            Content.WriteFrom(InS);
        if ContentHeaders.Contains('content-type') then
            ContentHeaders.Remove('content-type');
        ContentHeaders.Add('content-type', 'application/json');
        ContentHeaders.Add('feedsize', 'full');

        i := 1;
        while (i <= MaxNoTry) do begin
            ComestriAzureLog.Status := ComestriAzureLog.Status::Failed;
            if Client.Post(Url, Content, Response) then begin
                if Response.IsSuccessStatusCode() then begin
                    ComestriAzureLog.Status := ComestriAzureLog.Status::Success;
                    ComestriAzureLog."Error Message" := '';
                    exit;
                end else begin
                    ComestriAzureLog.Status := ComestriAzureLog.Status::Failed;
                    ComestriAzureLog."Error Message" := CopyStr(Response.ReasonPhrase(), 1, MaxStrLen(ComestriAzureLog."Error Message"));
                end;

                //retry    
                i := i + 1;
            end else
                //retry
                i := i + 1;
        end;

        //reaching this stage, means errors occured
        //send notification
        SendEmailNotification(ComestriAzureLog, Response.ReasonPhrase());

    end;

    local procedure GetSetup()
    begin
        if not SetupRead then begin
            IntegrationSetup.Get();
            SetupRead := true;
        end;
    end;

    local procedure GetConnectionSetup()
    begin
        GetSetup();
        MaxNoTry := IntegrationSetup."Bloyal Max. of Try";
        if MaxNoTry <= 0 then
            MaxNoTry := 1;

        case WSType of
            WSType::SOH:
                begin
                    IntegrationSetup.TestField("Comestri SOH End Point");
                    Url := IntegrationSetup."Comestri SOH End Point";
                end;
            WSType::Product:
                begin
                    IntegrationSetup.TestField("Comestri Product End Point");
                    Url := IntegrationSetup."Comestri Product End Point";
                end;
        end;
    end;

    local procedure SendEmailNotification(var ComestriAzureLog: Record "GXL Comestri Azure Log"; ErrMsg: Text)
    var
        MySession: Record "Active Session";
        // >> Upgrade
        //SMTP: Codeunit "SMTP Mail";
        SMTP: Codeunit "Email Message";
        Email: Codeunit Email;
        EmailScenario: Enum "Email Scenario";
        // << Upgrade
        TypeHelper: Codeunit "Type Helper";
        Subject: Text;
        compName: Text;
        dbName: Text;
        userName: Text;
    begin
        GetSetup();
        if IntegrationSetup."Bloyal Notif. Recipient" = '' then
            exit;

        MySession.Get(ServiceInstanceId(), SessionId());
        // >> Upgrade
        // SMTP.CreateMessage(
        //     '',
        //     IntegrationSetup."Bloyal Notif. Sender E-Mail",
        //     IntegrationSetup."Bloyal Notif. Recipient",
        //     Subject,
        //     '',
        //     true
        // );

        SMTP.Create(
            IntegrationSetup."Bloyal Notif. Recipient",
            Subject,
            '',
            true
        );

        SMTP.AppendToBody('<html>');
        SMTP.AppendToBody('<head>');
        SMTP.AppendToBody('<style>');
        SMTP.AppendToBody('table, th, td {');
        SMTP.AppendToBody('   border: thin solid black;');
        SMTP.AppendToBody('   border-collapse: collapse;');
        SMTP.AppendToBody('}');
        SMTP.AppendToBody('th, td {');
        SMTP.AppendToBody('   padding: 5px;');
        SMTP.AppendToBody('   text-align:left;');
        SMTP.AppendToBody('   vertical-align: top;');
        SMTP.AppendToBody('   font-size:9pt;');
        SMTP.AppendToBody('   font-family: Arial;');
        SMTP.AppendToBody('}');
        SMTP.AppendToBody('</style>');
        SMTP.AppendToBody('</head>');

        SMTP.AppendToBody('<body>');

        SMTP.AppendToBody('<table>');
        SMTP.AppendToBody(' <tr>');
        SMTP.AppendToBody(StrSubstNo('  <td colspan="2"><b>%1</b></td>', Subject));
        SMTP.AppendToBody(' </tr>');
        SMTP.AppendToBody(' <tr>');
        SMTP.AppendToBody('  <td style="vertical-align:buttom"><b>Web Service Name</b></td>');
        SMTP.AppendToBody('  <td style="vertical-align:buttom"><b>Batch ID</b></td>');
        SMTP.AppendToBody('  <td style="vertical-align:buttom"><b>Error Message</b></td>');
        SMTP.AppendToBody(' </tr>');
        SMTP.AppendToBody(' <tr>');
        SMTP.AppendToBody(StrSubstNo('  <td>%1</td>', ComestriAzureLog."Web Service Name"));
        SMTP.AppendToBody(StrSubstNo('  <td>%1</td>', ComestriAzureLog."Batch ID"));
        SMTP.AppendToBody(StrSubstNo('  <td>%1</td>', ErrMsg));
        SMTP.AppendToBody(' </tr>');
        SMTP.AppendToBody('</table>');
        SMTP.AppendToBody('<BR>');
        // << Upgrade
        compName := CompanyName();
        dbName := MySession."Database Name";
        userName := UserId();
        SMTP.AppendToBody(StrSubstNo(
            '<p style="font-family:Verdana,Arial;font-size:9pt">' +
            '<b>Company:</b> %1<BR><b>Database:</b> %2<BR><b>Sent By:</b> %3</p>',
            TypeHelper.HtmlEncode(compName), TypeHelper.HtmlEncode(dbName), TypeHelper.HtmlEncode(userName)));
        // >> Upgrade
        SMTP.AppendToBody('</body>');
        SMTP.AppendToBody('</html>');
        //SMTP.Send();
        Email.Send(SMTP, EmailScenario::Default);
        // << Upgrade
    end;

    procedure SetSetup(NewIntegrationSetup: Record "GXL Integration Setup")
    begin
        IntegrationSetup := NewIntegrationSetup;
        SetupRead := true;
    end;

    procedure ConvertFieldCaptionToJsonFormat(fldCaption: Text[250]; var JsonText: Text[250])
    var
        DotNetStr: Codeunit DotNet_String;
    begin
        JsonText := fldCaption;

        DotNetStr.Set(JsonText);
        JsonText := DotNetStr.Replace(' ', '_');
        DotNetStr.Set(JsonText);
        JsonText := DotNetStr.Replace('.', '');
        DotNetStr.Set(JsonText);
        JsonText := DotNetStr.Replace('%', 'Pct');
    end;

    procedure ReplaceFieldRefValueJsonObject(var FldRef: FieldRef; KeyVal: Text; JsonObj: JsonObject)
    var
        IntVal: Integer;
        DecVal: Decimal;
        BigIntVal: BigInteger;
        BoolVal: Boolean;
        DateVal: Date;
        TimeVal: Time;
        DateTimeVal: DateTime;
        DurationVal: Duration;
        GuidVal: Guid;
    begin
        if FldRef.Class() = FieldClass::FlowField then
            FldRef.CalcField();
        case FldRef.Type() of
            FieldType::Decimal:
                begin
                    DecVal := FldRef.Value();
                    JsonObj.Replace(KeyVal, DecVal);
                end;
            FieldType::Integer:
                begin
                    IntVal := FldRef.Value();
                    JsonObj.Replace(KeyVal, IntVal);
                end;
            FieldType::BigInteger:
                begin
                    BigIntVal := FldRef.Value();
                    JsonObj.Replace(KeyVal, BigIntVal);
                end;
            FieldType::Boolean:
                begin
                    BoolVal := FldRef.Value();
                    JsonObj.Replace(KeyVal, BoolVal);
                end;
            FieldType::Date:
                begin
                    DateVal := FldRef.Value();
                    JsonObj.Replace(KeyVal, DateVal);
                end;
            FieldType::Time:
                begin
                    TimeVal := FldRef.Value();
                    JsonObj.Replace(KeyVal, TimeVal);
                end;
            FieldType::DateTime:
                begin
                    DateTimeVal := FldRef.Value();
                    JsonObj.Replace(KeyVal, DateTimeVal);
                end;
            FieldType::Duration:
                begin
                    DurationVal := FldRef.Value();
                    JsonObj.Replace(KeyVal, DurationVal);
                end;
            FieldType::Guid:
                begin
                    GuidVal := FldRef.Value();
                    JsonObj.Replace(KeyVal, GuidVal);
                end;
            else
                JsonObj.Replace(KeyVal, Format(FldRef.Value()));
        end;

    end;

    procedure ReplaceBlankFieldRefJsonObject(TableId: Integer; FldId: Integer; KeyVal: Text; JsonObj: JsonObject)
    var
        Fld: Record Field;
        IntVal: Integer;
        DecVal: Decimal;
        BigIntVal: BigInteger;
        BoolVal: Boolean;
        DateVal: Date;
        TimeVal: Time;
        DateTimeVal: DateTime;
        DurationVal: Duration;
        GuidVal: Guid;
    begin
        Fld.Get(TableId, FldId);
        case Fld.Type of
            Fld.Type::Decimal:
                begin
                    DecVal := 0;
                    JsonObj.Replace(KeyVal, DecVal);
                end;
            Fld.Type::Integer:
                begin
                    IntVal := 0;
                    JsonObj.Replace(KeyVal, IntVal);
                end;
            Fld.Type::BigInteger:
                begin
                    BigIntVal := 0;
                    JsonObj.Replace(KeyVal, BigIntVal);
                end;
            Fld.Type::Boolean:
                begin
                    BoolVal := false;
                    JsonObj.Replace(KeyVal, BoolVal);
                end;
            Fld.Type::Date:
                begin
                    DateVal := 0D;
                    JsonObj.Replace(KeyVal, DateVal);
                end;
            Fld.Type::Time:
                begin
                    TimeVal := 0T;
                    JsonObj.Replace(KeyVal, TimeVal);
                end;
            Fld.Type::DateTime:
                begin
                    DateTimeVal := 0DT;
                    JsonObj.Replace(KeyVal, DateTimeVal);
                end;
            Fld.Type::Duration:
                begin
                    clear(DurationVal);
                    JsonObj.Replace(KeyVal, DurationVal);
                end;
            Fld.Type::Guid:
                begin
                    Clear(GuidVal);
                    JsonObj.Replace(KeyVal, GuidVal);
                end;
            else
                JsonObj.Replace(KeyVal, '');
        end;

    end;

    //#region "Zip files"
    procedure InitialiseZipStream()
    begin
        // >> Upgrade
        //ZipBlob.Blob.CreateOutStream(ZipFile);
        ZipBlob.CreateOutStream(ZipFile);
        // << Upgrade
    end;

    procedure AddFileStreamToZip(var FileStream: InStream; FileName: Text)
    var
        DataCompression: Codeunit "Data Compression";
        OutStr: OutStream;
    begin
        // >> Upgrade
        //FileMgt.AddStreamToZipStream(ZipFile, FileStream, FileName);
        CopyStream(OutStr, FileStream);
        DataCompression.SaveZipArchive(OutStr);
        // << Upgrade
    end;

    procedure DownloadZipFiles(ZipName: Text; FTPLocation: Text)
    var
        ZipStream: InStream;
    begin
        // >> Upgrade
        //ZipBlob.Blob.CreateInStream(ZipStream);
        ZipBlob.CreateInStream(ZipStream);
        // << Upgrade
        DownloadFromStream(ZipStream, '', FTPLocation, '', ZipName);
    end;
    //#end region "Zip files"

    procedure UploadFiletoFTP(InS: InStream; Zip: Boolean; FileName: Text)
    var
        WinSCPSession: DotNet WinSCPSession;
        WinSCPSessionOptions: DotNet WinSCPSessionOptions;
        WinSCPTransferOptions: DotNet WinSCPTransferOptions;
        WinSCPTransferResult: DotNet WinSCPTransferResult;
        WinSCPTransferResumeSupport: DotNet WinSCPTransferResumeSupport;
        WinSCPTransferResumeSupportState: DotNet WinSCPTransferResumeSupportState;
        WinSCPProtocol: DotNet WinSCPProtocol;
        WinSCPTransferMode: DotNet WinSCPTransferMode;
        OutputFile: File;
        OutS: OutStream;
        FilePath: Text;
        ZipStream: InStream;
    begin
        GetSetup();
        FilePath := TEMPORARYPATH + FileName;

        if Zip then
            // >> Upgrder
            //ZipBlob.Blob.CreateInStream(ZipStream);
            ZipBlob.CreateInStream(ZipStream);
        // << Upgrade
        OutputFile.WRITEMODE(TRUE);
        OutputFile.CREATE(FilePath);
        OutputFile.CREATEOUTSTREAM(OutS);
        if Zip then
            COPYSTREAM(OutS, ZipStream)
        else
            COPYSTREAM(OutS, Ins);
        OutputFile.CLOSE();

        WinSCPSessionOptions := WinSCPSessionOptions.SessionOptions();
        WinSCPSessionOptions.HostName := IntegrationSetup."Comestri SFTP Host";
        WinSCPSessionOptions.UserName := IntegrationSetup."Comestri SFTP Username";
        WinSCPSessionOptions.Password := IntegrationSetup."Comestri SFTP Password";
        WinSCPSessionOptions.PortNumber := IntegrationSetup."Comestri SFTP Port";
        WinSCPSessionOptions.SshHostKeyFingerprint := IntegrationSetup."Comestri SFTP Host Key";
        WinSCPSessionOptions.Protocol := WinSCPProtocol.Sftp;
        //WinSCPProtocol := WinSCPProtocol.Sftp;

        WinSCPSession := WinSCPSession.Session();
        WinSCPSession.ExecutablePath('');
        WinSCPSession.Open(WinSCPSessionOptions);
        WinSCPTransferOptions := WinSCPTransferOptions.TransferOptions();
        WinSCPTransferOptions.TransferMode := WinSCPTransferMode.Binary;
        WinSCPTransferResumeSupport := WinSCPTransferOptions.ResumeSupport;
        WinSCPTransferResumeSupport.State(WinSCPTransferResumeSupportState.Off);
        WinSCPTransferResult := WinSCPSession.PutFiles(FilePath, IntegrationSetup."Comestri SFTP Path", FALSE, WinSCPTransferOptions);
        WinSCPTransferResult.Check(); //WRP-1013: Throw error

        //WRP-287+
        WinSCPSession.Dispose();
        //WRP-287-
    end;
}