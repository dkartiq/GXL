table 50375 "GXL Email Log"
{
    Caption = 'Email Log';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Customer Statement,Purchase Quote,Purchase Order,Purchase Blanket Order,Purchase Return Order,Purchase Return Shipment,Purchase CR/Adj Note,Sales Quote,Sales Order,Sales Blanket Order,Sales Shipment,Sales Invoice,Sales Return Order,Sales CR/Adj Note,Service Order,Service Shipment,Service Invoice,Service CR/Adj Note,GateIn';
            OptionMembers = "Customer Statement","Purchase Quote","Purchase Order","Purchase Blanket Order","Purchase Return Order","Purchase Return Shipment","Purchase CR/Adj Note","Sales Quote","Sales Order","Sales Blanket Order","Sales Shipment","Sales Invoice","Sales Return Order","Sales CR/Adj Note","Service Order","Service Shipment","Service Invoice","Service CR/Adj Note",GateIn;
        }
        field(3; "Created Date Time"; DateTime)
        {
            Caption = 'Created Date Time';
        }
        field(4; "User ID"; Code[50])
        {
            Caption = 'User ID';
            NotBlank = true;
            TableRelation = User."User Name";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                // >> Upgrade
                //UserMgt.LookupUserID("User ID");
                UserMgt.DisplayUserInformation("User ID");
                // << Upgrade
            end;

            trigger OnValidate()
            var
                // >> Upgrade
                //UserMgt: Codeunit "User Management";
                UserSelection: Codeunit "User Selection";
            // << Upgrade
            begin
                // >> Upgrade
                //UserMgt.ValidateUserID("User ID");
                UserSelection.ValidateUserName("User ID");
                // << Upgrade
            end;
        }
        field(5; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
        }
        field(7; "Document File"; BLOB)
        {
            Caption = 'Document File';
        }
        field(8; "Document File Type"; Option)
        {
            Caption = 'Document File Type';
            OptionCaption = 'PDF,Word,Excel';
            OptionMembers = PDF,Word,Excel;
        }
        field(11; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
        }
        field(12; "Error Message 2"; Text[250])
        {
            Caption = 'Error Message 2';
        }
        field(13; "Error Message 3"; Text[250])
        {
            Caption = 'Error Message 3';
        }
        field(14; "Error Message 4"; Text[250])
        {
            Caption = 'Error Message 4';
        }
        field(15; "Email ID"; Code[100])
        {
            Caption = 'Email ID';
        }
        field(16; "Document Filename"; Text[250])
        {
            Caption = 'Document Filename';
        }
        field(17; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Success,Error';
            OptionMembers = Success,Error;
        }
        field(18; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Customer,Vendor,''';
            OptionMembers = Customer,Vendor," ";
        }
        field(19; "Code"; Code[20])
        {
            Caption = 'Code';
            TableRelation = IF (Type = CONST(Customer)) Customer."No." ELSE
            IF (Type = CONST(Vendor)) Vendor."No.";
        }
        field(20; "Sending Behaviour"; Option)
        {
            Caption = 'Sending Behaviour';
            OptionCaption = 'Do Not Prompt User,Prompt User';
            OptionMembers = "Do Not Prompt User","Prompt User";
        }
        field(21; "Email Type"; Option)
        {
            Caption = 'Email Type';
            OptionCaption = 'Outlook,SMTP';
            OptionMembers = Outlook,SMTP;
        }
        field(22; Indentation; Integer)
        {
            Caption = 'Indentation';
            MinValue = 0;
        }
        field(23; "Email Sent To"; Text[250])
        {
            Caption = 'Email Sent To';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Created Date Time", "Record ID", "Email ID")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Created Date Time" := CURRENTDATETIME();
        "User ID" := USERID();
    end;

    var
        Text001Txt: Label 'There is no error message.';

    [Scope('OnPrem')]
    procedure GetErrorMessage(): Text[1000]
    begin
        EXIT("Error Message" + "Error Message 2" + "Error Message 3" + "Error Message 4");
    end;

    [Scope('OnPrem')]
    procedure SetErrorMessage(ErrorText: Text[1024])
    begin
        "Error Message 2" := '';
        "Error Message 3" := '';
        "Error Message 4" := '';
        "Error Message" := COPYSTR(ErrorText, 1, 250);
        IF STRLEN(ErrorText) > 250 THEN
            "Error Message 2" := COPYSTR(ErrorText, 251, 250);
        IF STRLEN(ErrorText) > 500 THEN
            "Error Message 3" := COPYSTR(ErrorText, 501, 250);
        IF STRLEN(ErrorText) > 750 THEN
            "Error Message 4" := COPYSTR(ErrorText, 751, 250);
    end;

    [Scope('OnPrem')]
    procedure ShowErrorMessage()
    var
        e: Text[1000];
    begin
        e := GetErrorMessage();
        IF e = '' THEN
            e := Text001Txt;
        MESSAGE(e);
    end;

    [Scope('OnPrem')]
    procedure ShowDocument(Open: Boolean)
    var
        // >> Upgrade
        //TempBlob: Record TempBlob temporary;
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        FldRef: FieldRef;
        // << Upgrade
        FileManagement: Codeunit "File Management";
        FileName: Text;
    begin
        CALCFIELDS("Document File");
        IF "Document File".HASVALUE() THEN BEGIN
            // >> Upgrade
            //TempBlob.Blob := "Document File";
            RecRef.GetTable(Rec);
            FldRef := RecRef.Field(FieldNo("Document File"));
            TempBlob.FromFieldRef(FldRef);
            // << Upgrade
            FileName := FileManagement.BLOBExport(TempBlob, "Document Filename", NOT Open);
            IF Open THEN
                HYPERLINK(FileName);
        END
    end;

    [Scope('OnPrem')]
    procedure OpenNavDocument()
    var
        PurchaseHeader: Record "Purchase Header";
        ReturnShipmentHeader: Record "Return Shipment Header";
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        SalesHeader: Record "Sales Header";
        SalesShipHdr: Record "Sales Shipment Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        ServiceHeader: Record "Service Header";
        ServiceShipmentHeader: Record "Service Shipment Header";
        ServiceInvoiceHeader: Record "Service Invoice Header";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        DocRecRef: RecordRef;
    begin
        DocRecRef.GET("Record ID");

        CASE "Document Type" OF

            "Document Type"::"Customer Statement":
                ; //There is nothing to open

            "Document Type"::"Purchase Quote":
                BEGIN
                    DocRecRef.SETTABLE(PurchaseHeader);
                    PAGE.RUN(49, PurchaseHeader);
                END;

            "Document Type"::"Purchase Order":
                BEGIN
                    DocRecRef.SETTABLE(PurchaseHeader);
                    PAGE.RUN(50, PurchaseHeader);
                END;

            "Document Type"::"Purchase Blanket Order":
                BEGIN
                    DocRecRef.SETTABLE(PurchaseHeader);
                    PAGE.RUN(509, PurchaseHeader);
                END;

            "Document Type"::"Purchase Return Order":
                BEGIN
                    DocRecRef.SETTABLE(PurchaseHeader);
                    PAGE.RUN(6640, PurchaseHeader);
                END;

            "Document Type"::"Purchase Return Shipment":
                BEGIN
                    DocRecRef.SETTABLE(ReturnShipmentHeader);
                    PAGE.RUN(6650, ReturnShipmentHeader);
                END;

            "Document Type"::"Purchase CR/Adj Note":
                BEGIN
                    DocRecRef.SETTABLE(PurchCrMemoHdr);
                    PAGE.RUN(140, PurchCrMemoHdr);
                END;

            "Document Type"::"Sales Quote":
                BEGIN
                    DocRecRef.SETTABLE(SalesHeader);
                    PAGE.RUN(41, SalesHeader);
                END;

            "Document Type"::"Sales Order":
                BEGIN
                    DocRecRef.SETTABLE(SalesHeader);
                    PAGE.RUN(42, SalesHeader);
                END;

            "Document Type"::"Sales Blanket Order":
                BEGIN
                    DocRecRef.SETTABLE(SalesHeader);
                    PAGE.RUN(507, SalesHeader);
                END;

            "Document Type"::"Sales Shipment":
                BEGIN
                    DocRecRef.SETTABLE(SalesShipHdr);
                    PAGE.RUN(130, SalesShipHdr);
                END;

            "Document Type"::"Sales Invoice":
                BEGIN
                    DocRecRef.SETTABLE(SalesInvoiceHeader);
                    PAGE.RUN(132, SalesInvoiceHeader);
                END;

            "Document Type"::"Sales Return Order":
                BEGIN
                    DocRecRef.SETTABLE(SalesHeader);
                    PAGE.RUN(6630, SalesHeader);
                END;

            "Document Type"::"Sales CR/Adj Note":
                BEGIN
                    DocRecRef.SETTABLE(SalesCrMemoHeader);
                    PAGE.RUN(134, SalesCrMemoHeader);
                END;

            "Document Type"::"Service Order":
                BEGIN
                    DocRecRef.SETTABLE(ServiceHeader);
                    PAGE.RUN(5900, ServiceHeader);
                END;

            "Document Type"::"Service Shipment":
                BEGIN
                    DocRecRef.SETTABLE(ServiceShipmentHeader);
                    PAGE.RUN(5975, ServiceShipmentHeader);
                END;

            "Document Type"::"Service Invoice":
                BEGIN
                    DocRecRef.SETTABLE(ServiceInvoiceHeader);
                    PAGE.RUN(5978, ServiceInvoiceHeader);
                END;

            "Document Type"::"Service CR/Adj Note":
                BEGIN
                    DocRecRef.SETTABLE(ServiceCrMemoHeader);
                    PAGE.RUN(5972, ServiceCrMemoHeader);
                END;

        END;
    end;
}

