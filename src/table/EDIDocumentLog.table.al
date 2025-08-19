table 50356 "GXL EDI Document Log"
{
    Caption = 'EDI Document Log';
    DataCaptionFields = "Order Type", "Order No.", "Document Type", "Document No.", Status;

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
        field(3; "Order Type"; Option)
        {
            Caption = 'Order Type';
            OptionCaption = ' ,Purchase Order,Purchase Invoice,Transfer Order,Transfer Shipment,Transfer Receipt';
            OptionMembers = " ",PO,PI,STO,"STO-SHIP","STO-REC";
        }
        field(4; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            TableRelation = IF ("Order Type" = CONST(PO)) "Purchase Header"."No." WHERE("Document Type" = CONST(Order), "No." = FIELD("Order No.")) ELSE
            IF ("Order Type" = CONST(PI)) "Purch. Inv. Header"."No." ELSE
            IF ("Order Type" = CONST(STO)) "Transfer Header"."No." ELSE
            IF ("Order Type" = CONST("STO-SHIP")) "Transfer Shipment Header"."No." ELSE
            IF ("Order Type" = CONST("STO-REC")) "Transfer Receipt Header"."No.";
        }
        field(5; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,Purchase Order,Purchase Order Cancellation,Purchase Order Response,Advance Shipping Notice,Invoice,Stock Adjustment,Shipping Advice,IPO Acknowledgement';
            OptionMembers = " ",PO,POX,POR,ASN,INV,STKADJ,SHIPADVICE,IPOR;
        }
        field(6; "Document No."; Code[50])
        {
            Caption = 'Document No.';
            Description = 'pv00.02,MCS1.76';
            TableRelation = IF ("Document Type" = CONST(PO)) "Purchase Header"."No." WHERE("Document Type" = FILTER(Order)) ELSE
            IF ("Document Type" = CONST(SHIPADVICE)) "GXL Intl. Shipping Advice Head"."No." WHERE("Order No." = FIELD("Order No.")) ELSE
            IF ("Document Type" = CONST(POX)) "Purchase Header"."No." WHERE("Document Type" = FILTER(Order)) ELSE
            IF ("Document Type" = CONST(POR), "EDI Vendor Type" = CONST(VAN)) "GXL PO Response Header"."Response Number" ELSE
            IF ("Document Type" = CONST(POR), "EDI Vendor Type" = CONST("Point 2 Point")) "GXL EDI-Purchase Messages".DocumentNumber WHERE(ImportDoc = FILTER(1)) ELSE
            IF ("Document Type" = CONST(ASN)) "GXL ASN Header"."No." ELSE
            IF ("Document Type" = CONST(INV), "EDI Vendor Type" = CONST(VAN)) "GXL PO INV Header"."No." ELSE
            IF ("Document Type" = CONST(INV), "EDI Vendor Type" = CONST("Point 2 Point")) "GXL EDI-Purchase Messages".DocumentNumber WHERE(ImportDoc = FILTER(2));
        }
        field(7; "Supplier No."; Code[20])
        {
            Caption = 'Supplier No.';
            TableRelation = Vendor."No.";
        }
        field(8; "File Name"; Text[250])
        {
            Caption = 'File Name';
        }
        field(9; "EDI File Log Entry No."; Integer)
        {
            Caption = 'EDI File Log Entry No.';
            TableRelation = "GXL EDI File Log"."Entry No.";
        }
        field(10; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Imported,Validation Error,Validated,Processing Error,Processed,Scan Process Error,Scanned,Receiving Error,Receiving,Received,Return Order Creation Error,Return Order Created,Return Order Application Error,Return Order Applied,Return Shipment Posting Error,Return Shipment Posted,Return Credit Posting Error,Return Credit Posted,Completed without Posting Return Credit,Transfer Creation Error,Transfer Created,Transfer Shipping Error,Transfer Shipped,Transfer Receiving Error,Transfer Received,Journal Posting Error,Journal Posted,3PL ASN Sending Error,3PL ASN Sent';
            OptionMembers = Imported,"Validation Error",Validated,"Processing Error",Processed,"Scan Process Error",Scanned,"Receiving Error",Receiving,Received,"Return Order Creation Error","Return Order Created","Return Order Application Error","Return Order Applied","Return Shipment Posting Error","Return Shipment Posted","Return Credit Posting Error","Return Credit Posted","Completed without Posting Return Credit","Transfer Creation Error","Transfer Created","Transfer Shipping Error","Transfer Shipped","Transfer Receiving Error","Transfer Received","Journal Posting Error","Journal Posted","3PL ASN Sending Error","3PL ASN Sent";
        }
        field(11; "Error Code"; Text[250])
        {
            Caption = 'Error Code';
        }
        field(12; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
        }
        field(13; "Error Message 2"; Text[250])
        {
            Caption = 'Error Message 2';
        }
        field(14; "Error Message 3"; Text[250])
        {
            Caption = 'Error Message 2';
        }
        field(15; "Error Message 4"; Text[250])
        {
            Caption = 'Error Message 4';
        }
        field(16; "Invoice On Hold"; Boolean)
        {
            Caption = 'Invoice On Hold';
            Editable = false;
        }
        field(17; "Invoice On Hold From"; DateTime)
        {
            Caption = 'Invoice On Hold From';
        }
        field(18; "EDI Vendor Type"; Option)
        {
            Caption = 'EDI Vendor Type';
            OptionCaption = ' ,Point 2 Point,VAN,3PL Supplier,Point 2 Point Contingency';
            OptionMembers = " ","Point 2 Point",VAN,"3PL Supplier","Point 2 Point Contingency";
        }
        field(19; "EDI File Log 3PL ASN Ref."; Integer)
        {
            Caption = 'EDI File Log 3PL ASN Ref.';
            TableRelation = "GXL EDI File Log"."Entry No.";
        }
        field(20; "Original Document No."; Code[35])
        {
            Caption = 'Original Document No.';
        }
        field(100; "NAV EDI File Log Entry No."; Integer)
        {
            Caption = 'NAV EDI File Log Entry No.';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "EDI File Log Entry No.")
        {
        }
        key(Key3; Status, "Date/Time")
        {
        }
        key(Key4; "NAV EDI File Log Entry No.")
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
    // >> LCB-237
    [Scope('OnPrem')]
    procedure OpenDocument()
    var
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        ASNHeader: Record "GXL ASN Header";
        POINVHeader: Record "GXL PO INV Header";
        POResponseHeader: Record "GXL PO Response Header";
        PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer";
        EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
        ShipAdvice: Record "GXL Intl. Shipping Advice Head";
        "MCS1.76": Integer;
    begin
        // PAGE 50250 Domestic Purchase Order
        // PAGE 50252 International Purchase Order
        // PAGE 50078 PO Response
        // PAGE 50392 Vendor Confirm Messages List
        // PAGE 50407 Advance Shipping Notice
        // PAGE 50375 EDI Invoice
        // PAGE 50379 P2P Invoice
        CASE "Document Type" OF
            "Document Type"::PO, "Document Type"::POX:
                IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, "Document No.") THEN
                    PAGE.RUN(Page::"Purchase Order", PurchaseHeader);

            "Document Type"::POR:
                IF "EDI Vendor Type" = "EDI Vendor Type"::"Point 2 Point" THEN BEGIN
                    EDIPurchaseMessages.SETCURRENTKEY("EDI File Log Entry No.");
                    EDIPurchaseMessages.SETRANGE("EDI File Log Entry No.", "EDI File Log Entry No.");
                    IF EDIPurchaseMessages.FINDSET() THEN
                        PAGE.RUN(Page::"GXL Vendor Invoice Messages", EDIPurchaseMessages);
                END ELSE
                    IF POResponseHeader.GET("Document No.") THEN
                        PAGE.RUN(Page::"GXL PO Response", POResponseHeader);

            "Document Type"::ASN:
                IF ASNHeader.GET(ASNHeader."Document Type"::Purchase, "Document No.") THEN
                    PAGE.RUN(Page::"GXL Advance Shipping Notice", ASNHeader);

            "Document Type"::INV:
                IF POINVHeader.GET("Document No.") THEN
                    IF POINVHeader."EDI Vendor Type" IN [POINVHeader."EDI Vendor Type"::"Point 2 Point", POINVHeader."EDI Vendor Type"::"Point 2 Point Contingency"] THEN
                        PAGE.RUN(Page::"GXL P2P Invoice", POINVHeader)
                    ELSE
                        PAGE.RUN(Page::"GXL EDI Invoice", POINVHeader);

            "Document Type"::STKADJ:
                BEGIN
                    PDAStAdjProcessingBuffer.SETCURRENTKEY("EDI File Log Entry No.");
                    PDAStAdjProcessingBuffer.SETRANGE("EDI File Log Entry No.", "EDI File Log Entry No.");
                    IF PDAStAdjProcessingBuffer.FINDSET THEN
                        PAGE.RUN(Page::"GXL PDA-StAdjProcessing Buffer", PDAStAdjProcessingBuffer);
                END;

            "Document Type"::SHIPADVICE:
                BEGIN
                    IF ShipAdvice.GET("Document No.") THEN
                        PAGE.RUN(PAGE::"GXL Int. Shipping Advice", ShipAdvice);
                END;
        END;
    end;
    // << LCB-237
}

