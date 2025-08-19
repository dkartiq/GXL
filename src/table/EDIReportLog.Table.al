table 50388 "GXL EDI Report Log"
{
    Caption = 'EDI Report Log';
    DrillDownPageID = "GXL EDI Report Log";
    LookupPageID = "GXL EDI Report Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            AutoIncrement = true;
            Caption = 'Entry No.';
        }
        field(2; "Order Type"; Option)
        {
            Caption = 'Order Type';
            OptionCaption = ' ,Purchase Order,Site Transfer Order';
            OptionMembers = " ",PO,STO;
        }
        field(3; "Order No."; Code[20])
        {
            Caption = 'Order No.';
            TableRelation = IF ("Order Type" = CONST(PO)) "Purchase Header"."No." ELSE
            IF ("Order Type" = CONST(STO)) "Transfer Header"."No.";
        }
        field(4; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = ' ,Purchase Order,Purchase Order Cancellation,Purchase Order Response,Advance Shipping Notice,Invoice';
            OptionMembers = " ",PO,POX,POR,ASN,INV;
        }
        field(5; "Document No."; Code[50])
        {
            Caption = 'Document No.';
            TableRelation = IF ("Document Type" = CONST(PO)) "Purchase Header"."No." ELSE
            IF ("Document Type" = CONST(POX)) "Purchase Header"."No." ELSE
            IF ("Document Type" = CONST(POR)) "GXL PO Response Header"."Response Number" ELSE
            IF ("Document Type" = CONST(ASN)) "GXL ASN Header"."No." ELSE
            IF ("Document Type" = CONST(INV)) "GXL PO INV Header"."No.";
        }
        field(6; "Report Type"; Option)
        {
            Caption = 'Report Type';
            OptionCaption = ' ,GTIN Validation,Advance Shipping Notice Scan Validation,Advance Shipping Notice Receiving Discrepancy,Invoice Credit Notification';
            OptionMembers = " ","GTIN Validation","ASN Scan Validation","ASN Receiving Discrepancy","INV Credit Notification";
        }
        field(7; Attachment; BLOB)
        {
            Caption = 'Attachment';
        }
        field(8; "Email Sent"; Boolean)
        {
            Caption = 'Email Sent';
        }
        field(9; "Date/Time"; DateTime)
        {
            Caption = 'Date/Time';
        }
        field(10; "Attachment File Name"; Text[250])
        {
            Caption = 'Attachment File Name';
        }
        field(11; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
        }
        field(12; "Staging Record ID"; RecordID)
        {
            Caption = 'Staging Record ID';
        }
        field(13; "EDI File Log Entry No."; Integer)
        {
            Caption = 'EDI File Log Entry No.';
            TableRelation = "GXL EDI File Log";
        }
        field(14; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
        }
        field(15; "Email Sent to Vendor"; Boolean)
        {
            Caption = 'Email Sent to Vendor';
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Date/Time")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Date/Time" := CURRENTDATETIME();
    end;

    [Scope('OnPrem')]
    procedure ShowAttachment(Open: Boolean)
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
        CALCFIELDS(Attachment);
        IF Attachment.HASVALUE() THEN BEGIN
            // >> Upgrade
            //TempBlob.Blob := Attachment;
            RecRef.GetTable(Rec);
            FldRef := RecRef.Field(FieldNo(Attachment));
            TempBlob.FromFieldRef(FldRef);
            // << Upgrade
            FileName := FileManagement.BLOBExport(TempBlob, "Attachment File Name", NOT Open);
            IF Open THEN
                HYPERLINK(FileName);
        END;
    end;

    [Scope('OnPrem')]
    procedure OpenNavDocument()
    var
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        DocRecRef: RecordRef;
    begin
        DocRecRef.GET("Record ID");

        CASE "Order Type" OF

            "Order Type"::PO:
                BEGIN
                    DocRecRef.SETTABLE(PurchaseHeader);
                    PAGE.RUN(50, PurchaseHeader);
                END;

            "Order Type"::STO:
                BEGIN
                    DocRecRef.SETTABLE(TransferHeader);
                    PAGE.RUN(5740, TransferHeader);
                END;

        END;
    end;

    [Scope('OnPrem')]
    procedure OpenNavStagingDocument()
    var
        POResponseHeader: Record "GXL PO Response Header";
        ASNHeader: Record "GXL ASN Header";
        POINVHeader: Record "GXL PO INV Header";
        DocRecRef: RecordRef;
    begin
        DocRecRef.GET("Staging Record ID");

        CASE "Document Type" OF

            "Document Type"::PO, "Document Type"::POX:
                ;

            "Document Type"::POR:
                BEGIN
                    DocRecRef.SETTABLE(POResponseHeader);
                    PAGE.RUN(50078, POResponseHeader);
                END;

            "Document Type"::ASN:
                BEGIN
                    DocRecRef.SETTABLE(ASNHeader);
                    PAGE.RUN(50407, ASNHeader);
                END;

            "Document Type"::INV:
                BEGIN
                    DocRecRef.SETTABLE(POINVHeader);
                    PAGE.RUN(50375, POINVHeader);
                END;
        END;
    end;
}

