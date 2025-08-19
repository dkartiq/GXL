table 50372 "GXL Document Email Setup"
{

    Caption = 'Document Email Setup';
    DrillDownPageID = "GXL Email Template";
    LookupPageID = "GXL Email Template";

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;

            trigger OnValidate()
            var
                UserSelection: Codeunit "User Selection";
            begin
                UserSelection.ValidateUserName("User ID");
            end;
        }
        field(2; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Customer Statement,Purchase Quote,Purchase Order,Purchase Blanket Order,Purchase Return Order,Purchase Return Shipment,Purchase CR/Adj Note,Sales Quote,Sales Order,Sales Blanket Order,Sales Shipment,Sales Invoice,Sales Return Order,Sales CR/Adj Note,Service Order,Service Shipment,Service Invoice,Service CR/Adj Note';
            OptionMembers = "Customer Statement","Purchase Quote","Purchase Order","Purchase Blanket Order","Purchase Return Order","Purchase Return Shipment","Purchase CR/Adj Note","Sales Quote","Sales Order","Sales Blanket Order","Sales Shipment","Sales Invoice","Sales Return Order","Sales CR/Adj Note","Service Order","Service Shipment","Service Invoice","Service CR/Adj Note";
        }
        field(3; "Email Body Template"; BLOB)
        {
            Caption = 'Email Body Template';

            trigger OnValidate()
            begin
                //this is a trick to force the update on the page
                //DO NOT REMOVE
                IF "User ID" <> "User ID" THEN BEGIN
                END;
            end;
        }
        field(4; "Email Body Template HTML"; BLOB)
        {
            Caption = 'Email Body Template HTML';
        }
        field(5; "Document Filename"; Text[250])
        {
            Caption = 'Document Filename';
        }
        field(6; "Document File Type"; Option)
        {
            Caption = 'Document File Type';
            OptionCaption = 'PDF,Word,Excel';
            OptionMembers = PDF,Word,Excel;
        }
        field(7; "Sending Behaviour"; Option)
        {
            Caption = 'Sending Behaviour';
            OptionCaption = 'Do Not Prompt User,Prompt User';
            OptionMembers = "Do Not Prompt User","Prompt User";
        }
        field(8; "Email From / To"; Option)
        {
            Caption = 'Email From / To';
            OptionCaption = 'Sell-to / Buy-from,Bill-to / Pay-to';
            OptionMembers = "Sell-to / Buy-from","Bill-to / Pay-to";
        }
        field(9; "Email Subject"; Text[250])
        {
            Caption = 'Email Subject';
        }
    }

    keys
    {
        key(Key1; "User ID", "Document Type")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        IF "User ID" = '' THEN
            ERROR(Text000Txt);
    end;

    var
        Text000Txt: Label 'This is a Global Setting and cannot be deleted.';

    [Scope('OnPrem')]
    procedure GetEmailBodytHTML() OutputString: Text
    var
        BigTextHTML: BigText;
        StreamIn: InStream;
    begin
        CALCFIELDS("Email Body Template HTML");

        IF "Email Body Template HTML".HASVALUE() THEN BEGIN
            "Email Body Template HTML".CREATEINSTREAM(StreamIn);

            BigTextHTML.READ(StreamIn);

            BigTextHTML.GETSUBTEXT(OutputString, 1);
        END;
    end;

    [Scope('OnPrem')]
    procedure SaveEmailBodyHTML(InputHTMLData: Text)
    var
        BigTextHTML: BigText;
        StreamOut: OutStream;
    begin
        CLEAR("Email Body Template HTML");

        "Email Body Template HTML".CREATEOUTSTREAM(StreamOut);

        BigTextHTML.ADDTEXT(InputHTMLData);
        BigTextHTML.WRITE(StreamOut);

        MODIFY();
    end;

    [Scope('OnPrem')]
    procedure GetEmailBody() OutputString: Text
    var
        // >> Upgrade
        // Convert: DotNet Convert;
        // Bytes: DotNet Array;
        // MemoryStream: DotNet MemoryStream;
        // SysTextEncoding: DotNet Encoding;
        Convert: DotNet Convert1;
        Bytes: DotNet Array1;
        MemoryStream: DotNet MemoryStream1;
        SysTextEncoding: DotNet Encoding1;
        // << Upgrade
        StreamIn: InStream;
    begin
        CALCFIELDS("Email Body Template");

        IF NOT "Email Body Template".HASVALUE() THEN
            EXIT;

        "Email Body Template".CREATEINSTREAM(StreamIn);
        MemoryStream := MemoryStream.MemoryStream();
        COPYSTREAM(MemoryStream, StreamIn);

        Bytes := MemoryStream.ToArray();

        Bytes := Convert.FromBase64String(SysTextEncoding.Unicode().GetString(Bytes));

        EXIT(SysTextEncoding.Unicode().GetString(Bytes));
    end;

    //Wait till SMTP function is checked
    [Scope('OnPrem')]
    procedure SaveEmailBody(InputDetailData: Text)
    var
        // >> Upgrade
        // Convert: DotNet Convert;
        // Bytes: DotNet Array;
        // MemoryStream: DotNet MemoryStream;
        // SysTextEncoding: DotNet Encoding;
        Convert: DotNet Convert1;
        Bytes: DotNet Array1;
        MemoryStream: DotNet MemoryStream1;
        SysTextEncoding: DotNet Encoding1;
        // << Upgrade
        StreamOut: OutStream;
    begin
        CLEAR("Email Body Template");

        Bytes := SysTextEncoding.Unicode().GetBytes(InputDetailData);

        InputDetailData := Convert.ToBase64String(Bytes);

        Bytes := SysTextEncoding.Unicode().GetBytes(InputDetailData);

        MemoryStream := MemoryStream.MemoryStream(Bytes);
        "Email Body Template".CREATEOUTSTREAM(StreamOut);
        MemoryStream.WriteTo(StreamOut);

        MODIFY();
    end;

    //Wait till SMTP function is checked
    procedure SetEmailBodyTemplate(NewEmailBodyTemplate: Text)
    var
        // >> Upgrade
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        OutStrL: OutStream;
        InstrL: InStream;
    // << Upgrade
    begin
        Clear("Email Body Template");
        if NewEmailBodyTemplate = '' then
            exit;
        // >> Upgrade
        // TempBlob.Blob := "Email Body Template";
        // TempBlob.WriteAsText(NewEmailBodyTemplate, TextEncoding::UTF8);
        // "Email Body Template" := TempBlob.Blob;
        "Email Body Template".CreateInStream(InstrL);
        TempBlob.CreateOutStream(OutStrL);
        OutStrL.WriteText(NewEmailBodyTemplate);
        CopyStream(OutStrL, InstrL);
        Modify();
        // << Upgrade
    end;

    procedure GetEmailBodyTemplate(): Text
    begin
        CalcFields("Email Body Template");
        exit(GetEmailBodyTemplateCalculated())
    end;

    procedure GetEmailBodyTemplateCalculated(): Text
    var
        // >> Upgrade
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        Instr: InStream;
        Result: Text;
        // << Upgrade
        CR: Text[1];
    begin
        if not "Email Body Template".HasValue() then
            exit('');

        CR[1] := 10;
        // >> Upgrade
        // TempBlob.Blob := "Email Body Template";
        // exit(TempBlob.ReadAsText(CR, TextEncoding::UTF8));
        "Email Body Template".CreateInStream(Instr);
        Instr.Read(Result);
        exit(Result);
        // << Upgrade
    end;
}

