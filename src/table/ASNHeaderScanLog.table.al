table 50365 "GXL ASN Header Scan Log"
{

    Caption = 'ASN Header Scan Log';
    DataCaptionFields = "Document Type", "No.";
    DrillDownPageID = "GXL ASN Header Scan Logs";
    LookupPageID = "GXL ASN Header Scan Logs";
    PasteIsValid = false;

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
            OptionCaption = 'Purchase,Transfer';
            OptionMembers = Purchase,Transfer;
        }
        field(3; "No."; Code[20])
        {
            Caption = 'ASN Number';
        }
        field(4; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            TableRelation = IF ("Document Type" = CONST(Purchase)) "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(5; "Copied to ASN"; Boolean)
        {
            Caption = 'Copied to ASN';
            Editable = false;

            trigger OnValidate()
            var
                ASNLevel1LineScanLog: Record "GXL ASN Level 1 Line Scan Log";
                ASNLevel2LineScanLog: Record "GXL ASN Level 2 Line Scan Log";
                ASNLevel3LineScanLog: Record "GXL ASN Level 3 Line Scan Log";
            begin
                IF "Copied to ASN" <> xRec."Copied to ASN" THEN BEGIN

                    ASNLevel1LineScanLog.SETCURRENTKEY("Document No.", "Copied to ASN", "Document Type");
                    ASNLevel1LineScanLog.SETRANGE("Document No.", "No.");
                    ASNLevel1LineScanLog.SETRANGE("Document Type", "Document Type");
                    ASNLevel1LineScanLog.MODIFYALL("Copied to ASN", "Copied to ASN");

                    ASNLevel2LineScanLog.SETCURRENTKEY("Document No.", "Copied to ASN", "Document Type");
                    ASNLevel2LineScanLog.SETRANGE("Document No.", "No.");
                    ASNLevel2LineScanLog.SETRANGE("Document Type", "Document Type");
                    ASNLevel2LineScanLog.MODIFYALL("Copied to ASN", "Copied to ASN");

                    ASNLevel3LineScanLog.SETCURRENTKEY("Document No.", "Copied to ASN", "Document Type");
                    ASNLevel3LineScanLog.SETRANGE("Document No.", "No.");
                    ASNLevel3LineScanLog.SETRANGE("Document Type", "Document Type");
                    ASNLevel3LineScanLog.MODIFYALL("Copied to ASN", "Copied to ASN");

                END;
            end;
        }
        field(6; "Transfer Order No."; Code[20])
        {
            Caption = 'Transfer Order No.';
            TableRelation = IF ("Document Type" = CONST(Transfer)) "Transfer Header"."No.";
        }
        field(7; "EDI Type"; Option)
        {
            Caption = 'EDI Type';
            Description = 'pv00.02';
            OptionCaption = ' ,P2P Contingency';
            OptionMembers = " ","P2P Contingency";
        }
        field(8; "EDI File Log Entry No."; Integer)
        {
            Caption = 'EDI File Log Entry No.';
            Description = 'pv00.03';
            TableRelation = "GXL EDI File Log"."Entry No.";
        }
        //PS-2046+
        field(200; "MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "No.", "Copied to ASN", "Document Type")
        {
        }
        key(Key3; "Copied to ASN")
        {
        }
        key(Key4; "EDI File Log Entry No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ASNLevel1LineScanLog: Record "GXL ASN Level 1 Line Scan Log";
        ASNLevel2LineScanLog: Record "GXL ASN Level 2 Line Scan Log";
        ASNLevel3LineScanLog: Record "GXL ASN Level 3 Line Scan Log";
    begin
        ASNLevel1LineScanLog.SETCURRENTKEY("Document No.", "Copied to ASN", "Document Type");
        ASNLevel1LineScanLog.SETRANGE("Document No.", "No.");
        ASNLevel1LineScanLog.SETRANGE("Document Type", "Document Type");
        ASNLevel1LineScanLog.DELETEALL();

        ASNLevel2LineScanLog.SETCURRENTKEY("Document No.", "Copied to ASN", "Document Type");
        ASNLevel2LineScanLog.SETRANGE("Document No.", "No.");
        ASNLevel2LineScanLog.SETRANGE("Document Type", "Document Type");
        ASNLevel2LineScanLog.DELETEALL();

        ASNLevel3LineScanLog.SETCURRENTKEY("Document No.", "Copied to ASN", "Document Type");
        ASNLevel3LineScanLog.SETRANGE("Document No.", "No.");
        ASNLevel3LineScanLog.SETRANGE("Document Type", "Document Type");
        ASNLevel3LineScanLog.DELETEALL();
    end;

    trigger OnInsert()
    var
        ASNHeaderScanLog: Record "GXL ASN Header Scan Log";
    begin
        ASNHeaderScanLog.SETCURRENTKEY("No.", "Copied to ASN", "Document Type");
        ASNHeaderScanLog.SETRANGE("No.", "No.");
        ASNHeaderScanLog.SETRANGE("Document Type", "Document Type");

        IF NOT ASNHeaderScanLog.ISEMPTY() THEN
            ERROR(STRSUBSTNO(Text000Txt, "No.", "Purchase Order No."));
    end;

    var
        Text000Txt: Label 'ASN %1 for Purchase Order %2 has already been scanned.';

    [Scope('OnPrem')]
    procedure ShowPalletLines()
    var
        ASNLevel1LineScanLog: Record "GXL ASN Level 1 Line Scan Log";
    begin
        ASNLevel1LineScanLog.SETCURRENTKEY("Document No.", "Copied to ASN", "Document Type");

        ASNLevel1LineScanLog.FILTERGROUP(2);

        ASNLevel1LineScanLog.SETRANGE("Document No.", "No.");
        ASNLevel1LineScanLog.SETRANGE("Document Type", "Document Type");

        ASNLevel1LineScanLog.FILTERGROUP(0);

        PAGE.RUNMODAL(PAGE::"GXL ASN Pallet Lines Scan Logs", ASNLevel1LineScanLog);
    end;

    [Scope('OnPrem')]
    procedure ShowBoxLines()
    var
        ASNLevel2LineScanLog: Record "GXL ASN Level 2 Line Scan Log";
    begin
        ASNLevel2LineScanLog.SETCURRENTKEY("Document No.", "Copied to ASN", "Document Type");

        ASNLevel2LineScanLog.FILTERGROUP(2);

        ASNLevel2LineScanLog.SETRANGE("Document No.", "No.");
        ASNLevel2LineScanLog.SETRANGE("Document Type", "Document Type");

        ASNLevel2LineScanLog.FILTERGROUP(0);

        PAGE.RUNMODAL(PAGE::"GXL ASN Box Lines Scan Logs", ASNLevel2LineScanLog);
    end;

    [Scope('OnPrem')]
    procedure ShowItemLines()
    var
        ASNLevel3LineScanLog: Record "GXL ASN Level 3 Line Scan Log";
    begin
        ASNLevel3LineScanLog.SETCURRENTKEY("Document No.", "Copied to ASN", "Document Type");

        ASNLevel3LineScanLog.FILTERGROUP(2);

        ASNLevel3LineScanLog.SETRANGE("Document No.", "No.");
        ASNLevel3LineScanLog.SETRANGE("Document Type", "Document Type");

        ASNLevel3LineScanLog.FILTERGROUP(0);

        PAGE.RUNMODAL(PAGE::"GXL ASN Item Lines Scan Logs", ASNLevel3LineScanLog);
    end;
}

