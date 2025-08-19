codeunit 50170 "GXL Bloyal Integration Helpers"
{
    //Bloyal integration
    //The Bloyal helpers will push the data in json format to web services 
    //Json data is created via other related Bloyal codeunits which are run via job queue

    Permissions = tabledata "GXL Bloyal Azure Log" = rimd;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        // >> Upgrade
        //ZipBlob: Record TempBlob;
        ZipBlob: Codeunit "Temp Blob";
        // << Upgrade
        FileMgt: Codeunit "File Management";
        ZipFile: OutStream;
        SetupRead: Boolean;
        WSType: Enum "GXL Bloyal Web Service Name";
        Url: Text;
        MaxNoTry: Integer;


    procedure PushToAzure(var BloyalAzureLog: Record "GXL Bloyal Azure Log"; var InS: InStream)
    var
        Client: HttpClient;
        ContentHeaders: HttpHeaders;
        Content: HttpContent;
        Response: HttpResponseMessage;
        AuthString: Text;
        i: Integer;
    begin
        GetSetup();
        WSType := BloyalAzureLog."Web Service Name";
        GetConnectionSetup();

        AuthString := StrSubstNo('%1', IntegrationSetup."Bloyal Access Token");
        Client.DefaultRequestHeaders().Add('Ocp-Apim-Subscription-Key', AuthString);
        Content.GetHeaders(ContentHeaders);
        Content.WriteFrom(InS);
        if ContentHeaders.Contains('content-type') then
            ContentHeaders.Remove('content-type');
        ContentHeaders.Add('content-type', 'application/json');

        i := 1;
        while (i <= MaxNoTry) do begin
            BloyalAzureLog.Status := BloyalAzureLog.Status::Failed;
            if Client.Post(Url, Content, Response) then begin
                if Response.IsSuccessStatusCode() then begin
                    BloyalAzureLog.Status := BloyalAzureLog.Status::Success;
                    BloyalAzureLog."Error Message" := '';
                    exit;
                end else begin
                    BloyalAzureLog.Status := BloyalAzureLog.Status::Failed;
                    BloyalAzureLog."Error Message" := CopyStr(Response.ReasonPhrase(), 1, MaxStrLen(BloyalAzureLog."Error Message"));
                end;

                //retry    
                i := i + 1;
            end else
                //retry
                i := i + 1;
        end;

        //reaching this stage, means errors occured
        //send notification
        SendEmailNotification(BloyalAzureLog, Response.ReasonPhrase());

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
            WSType::"Sales & Payment":
                begin
                    IntegrationSetup.TestField("Bloyal Sales Payment Endpoint");
                    Url := IntegrationSetup."Bloyal Sales Payment Endpoint";
                end;

            WSType::SOH:
                begin
                    IntegrationSetup.TestField("Bloyal SOH Endpoint");
                    Url := IntegrationSetup."Bloyal SOH Endpoint";
                end;
            WSType::Product:
                begin
                    IntegrationSetup.TestField("Bloyal Product Endpoint");
                    Url := IntegrationSetup."Bloyal Product Endpoint";
                end;
            WSType::Division:
                begin
                    IntegrationSetup.TestField("Bloyal Division Endpoint");
                    Url := IntegrationSetup."Bloyal Division Endpoint";
                end;
            WSType::"Item Category":
                begin
                    IntegrationSetup.TestField("Bloyal Item Category Endpoint");
                    Url := IntegrationSetup."Bloyal Item Category Endpoint";
                end;
            WSType::"Retail Product Group":
                begin
                    IntegrationSetup.TestField("Bloyal Retail Product Endpoint");
                    Url := IntegrationSetup."Bloyal Retail Product Endpoint";
                end;

        end;
    end;

    local procedure SendEmailNotification(var BloyalAzureLog: Record "GXL Bloyal Azure Log"; ErrMsg: Text)
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
        // << Upgrade

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
        SMTP.AppendToBody(StrSubstNo('  <td>%1</td>', BloyalAzureLog."Web Service Name"));
        SMTP.AppendToBody(StrSubstNo('  <td>%1</td>', BloyalAzureLog."Batch ID"));
        SMTP.AppendToBody(StrSubstNo('  <td>%1</td>', ErrMsg));
        SMTP.AppendToBody(' </tr>');
        SMTP.AppendToBody('</table>');
        SMTP.AppendToBody('<BR>');

        compName := CompanyName();
        dbName := MySession."Database Name";
        userName := UserId();
        SMTP.AppendToBody(StrSubstNo(
            '<p style="font-family:Verdana,Arial;font-size:9pt">' +
            '<b>Company:</b> %1<BR><b>Database:</b> %2<BR><b>Sent By:</b> %3</p>',
            TypeHelper.HtmlEncode(compName), TypeHelper.HtmlEncode(dbName), TypeHelper.HtmlEncode(userName)));

        SMTP.AppendToBody('</body>');
        SMTP.AppendToBody('</html>');
        // >> Upgrade
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
        DotNetStr.Set(JsonText);
        JsonText := DotNetStr.Replace('/', '');
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
        // >> Upgrade
        DataCompression: Codeunit "Data Compression";
        OutStr: OutStream;
    // << Upgrade
    begin
        // << Upgrade
        //FileMgt.AddStreamToZipStream(ZipFile, FileStream, FileName);
        CopyStream(OutStr, FileStream);
        DataCompression.SaveZipArchive(OutStr);
        // << Upgrade
    end;

    procedure DownloadZipFiles(ZipName: Text)
    var
        ZipStream: InStream;
    begin
        // >> Upgrade
        //ZipBlob.Blob.CreateInStream(ZipStream);
        ZipBlob.CreateInStream(ZipStream);
        // << Upgrade
        DownloadFromStream(ZipStream, '', '', '', ZipName);
    end;
    //#end region "Zip files"
}