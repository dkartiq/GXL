table 50357 "GXL EDI File Log"
{

    Caption = 'EDI File Log';
    DataCaptionFields = "Document Type", Status;
    DrillDownPageID = "GXL EDI File Log";
    LookupPageID = "GXL EDI File Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Date/Time"; DateTime)
        {
            Caption = 'Date/Time';
        }
        field(3; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,Purchase Order,Purchase Order Cancellation,Purchase Order Response,Advance Shipping Notice,Invoice,Stock Adjustment,Shipping Advice';
            OptionMembers = " ",PO,POX,POR,ASN,INV,STKADJ,SHIPADVICE;
        }
        field(4; "File Name"; Text[250])
        {
            Caption = 'File Name';
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'In Process,Success,Error';
            OptionMembers = "In Process",Success,Error;
        }
        field(6; "Error Code"; Text[250])
        {
            Caption = 'Error Code';
        }
        field(7; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
        }
        field(8; "Error Message 2"; Text[250])
        {
            Caption = 'Error Message 2';
        }
        field(9; "Error Message 3"; Text[250])
        {
            Caption = 'Error Message 2';
        }
        field(10; "Error Message 4"; Text[250])
        {
            Caption = 'Error Message 4';
        }
        field(11; "Stock Adj. Claim Document Type"; Option)
        {
            Caption = 'Stock Adj. Claim Document Type';
            Description = 'pv00.01';
            OptionCaption = ' ,Purchase Order,Purchase Invoice,Transfer Order,Transfer Shipment,Transfer Receipt';
            OptionMembers = " ",PO,PI,STO,"STO-SHIP","STO-REC";
        }
        field(12; "Stock Adj. Claim Order No."; Code[20])
        {
            Caption = 'Stock Adj. Claim Order No.';
            Description = 'pv00.01';
        }
        field(13; "EDI Vendor Type"; Option)
        {
            Caption = 'EDI Vendor Type';
            Description = 'pv00.02';
            OptionCaption = ' ,Point 2 Point,VAN,3PL Supplier,Point 2 Point Contingency';
            OptionMembers = " ","Point 2 Point",VAN,"3PL Supplier","Point 2 Point Contingency";

        }
        field(14; "3PL ASN Sent"; Text[250])
        {
            Caption = '3PL ASN Sent';
        }
        field(15; "3PL ASN Received"; Text[250])
        {
            Caption = '3PL ASN Received';
        }
        field(100; "NAV Entry No."; Integer)
        {
            Caption = 'NAV Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "File Name")
        {
        }
        key(Key3; "Stock Adj. Claim Order No.")
        {
        }
        key(Key4; "Date/Time")
        {
        }
        key(Key5; "NAV Entry No.")
        { }
    }

    fieldgroups
    {
    }

    var
        Text001Txt: Label 'There is no error message.';

    [Scope('OnPrem')]
    procedure GetErrorMessage(): Text
    begin
        EXIT("Error Message" + "Error Message 2" + "Error Message 3" + "Error Message 4");
    end;

    [Scope('OnPrem')]
    procedure SetErrorMessage(ErrorText: Text)
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
}

