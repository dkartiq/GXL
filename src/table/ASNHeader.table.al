table 50351 "GXL ASN Header"
{
    Caption = 'ASN Header';
    DataCaptionFields = "Document Type", "No.", "Supplier Name";
    DrillDownPageID = "GXL Adv. Shipping Notice List";
    LookupPageID = "GXL Adv. Shipping Notice List";
    PasteIsValid = false;

    fields
    {
        field(1; "Document Type"; Option)
        {
            Caption = 'Document Type';
            OptionCaption = 'Purchase,Transfer';
            OptionMembers = Purchase,Transfer;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'ASN Number';
        }
        field(3; "Supplier No."; Code[20])
        {
            Caption = 'Supplier ID';

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                IF "Supplier No." <> '' THEN BEGIN
                    Vendor.GET("Supplier No.");
                    "Supplier Name" := Vendor.Name;
                    "EDI Order in Outer Pack UoM" := Vendor."GXL EDI Order in Out. Pack UoM";
                END;
            end;
        }
        field(4; "Supplier Name"; Text[100])
        {
            Caption = 'Supplier Name';
        }
        field(5; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            TableRelation = IF ("Document Type" = CONST(Purchase)) "Purchase Header"."No." WHERE("Document Type" = CONST(Order));

            trigger OnValidate()
            var
                PurchaseHeader: Record "Purchase Header";
            begin
                IF "Purchase Order No." <> '' THEN
                    IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, "Purchase Order No.") THEN
                        "3PL EDI" := PurchaseHeader."GXL 3PL EDI";
            end;
        }
        field(6; "Transfer Order No."; Code[20])
        {
            Caption = 'Transfer Order No.';
            TableRelation = IF ("Document Type" = CONST(Transfer)) "Transfer Header"."No.";
        }
        field(7; "Order Date"; Date)
        {
            Caption = 'Order Date';
        }
        field(8; "Expected Receipt Date"; Date)
        {
            Caption = 'Expected Receipt Date';
        }
        field(9; "Ship-To Code"; Code[10])
        {
            Caption = 'Ship-To Code';

            trigger OnValidate()
            var
                Location: Record Location;
            begin
                IF "Ship-To Code" <> '' THEN BEGIN
                    Location.GET("Ship-To Code");
                    "Ship-To Name" := Location.Name;
                    "Ship-To Address" := Location.Address;
                    "Ship-To Address 2" := Location."Address 2";
                    "Ship-To Post Code" := Location."Post Code";
                    "Ship-To City" := Location.City;
                END;
            end;
        }
        field(10; "Ship-To Name"; Text[100])
        {
            Caption = 'Ship-To Name';
        }
        field(11; "Ship-To Address"; Text[100])
        {
            Caption = 'Ship-To Address';
        }
        field(12; "Ship-To Address 2"; Text[100])
        {
            Caption = 'Ship-To Address 2';
        }
        field(13; "Ship-To Post Code"; Code[20])
        {
            Caption = 'Ship-To Post Code';
        }
        field(14; "Ship-To City"; Text[50])
        {
            Caption = 'Ship-To City';
        }
        field(15; "Total Containers"; Decimal)
        {
            Caption = 'Total Containers';
        }
        field(16; "Total Pallets"; Decimal)
        {
            Caption = 'Pallet Count';
        }
        field(17; "Total Boxes"; Decimal)
        {
            Caption = 'Carton Count';
        }
        field(18; "Total Items"; Decimal)
        {
            Caption = 'Total Items';
        }
        field(19; "Supplier Reference Date"; Date)
        {
            Caption = 'ASN Date';
        }
        field(20; "Ship-for Code"; Code[10])
        {
            Caption = 'Ship-for Code';
        }
        field(21; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Imported,Validation Error,Validated,Processing Error,Processed,Scan Process Error,Scanned,Receiving Error,Receiving,Received,Return Order Creation Error,Return Order Created,Return Order Application Error,Return Order Applied,Return Shipment Posting Error,Return Shipment Posted,,,,,,,,,,,,3PL ASN Sending Error,3PL ASN Sent';
            OptionMembers = Imported,"Validation Error",Validated,"Processing Error",Processed,"Scan Process Error",Scanned,"Receiving Error",Receiving,Received,"Return Order Creation Error","Return Order Created","Return Order Application Error","Return Order Applied","Return Shipment Posting Error","Return Shipment Posted",,,,,,,,,,,,"3PL ASN Sending Error","3PL ASN Sent";

            trigger OnValidate()
            begin
                IF Status <> xRec.Status THEN BEGIN
                    UpdateASNLineStatus();
                END;
            end;
        }
        field(22; "EDI File Log Entry No."; Integer)
        {
            Caption = 'EDI File Log Entry No.';
            TableRelation = "GXL EDI File Log"."Entry No.";
        }
        field(23; "POR Created"; Boolean)
        {
            CalcFormula = Exist("GXL PO Response Header" WHERE("ASN Document Type" = FIELD("Document Type"), "ASN Document No." = FIELD("No.")));
            Caption = 'POR Created';
            Editable = false;
            FieldClass = FlowField;
        }
        field(24; "Claim Credit Memo No."; Code[20])
        {
            Caption = 'Claim Credit Memo No.';
            TableRelation = "Purch. Cr. Memo Hdr."."No.";
        }
        field(25; "Claim Expense Journal No."; Code[20])
        {
            Caption = 'Claim Expense Journal No.';
        }
        field(26; "PDA Receiving Status"; Option)
        {
            Caption = 'PDA Receiving Status';
            OptionCaption = ' ,Sent to PDA,Received from PDA';
            OptionMembers = " ","Sent to PDA","Received from PDA";
        }
        field(28; Audit; Boolean)
        {
            CalcFormula = Lookup("Purchase Header"."GXL Audit Flag" WHERE("Document Type" = FILTER(Order), "No." = FIELD("Purchase Order No.")));
            Caption = 'Audit';
            Editable = false;
            FieldClass = FlowField;
        }
        field(29; "PDA Audit"; Boolean)
        {
            Caption = 'PDA Audit';
            Editable = false;
        }
        field(30; "Claim Document No."; Code[20])
        {
            Caption = 'Claim Document No.';
            TableRelation = "Purchase Header"."No.";
        }
        field(31; "Manual Application"; Boolean)
        {
        }
        field(32; "No Claim"; Boolean)
        {
            Caption = 'No Claim';
        }
        field(33; "Receiving Discrepancy"; Boolean)
        {
            Caption = 'Receiving Discrepancy';
            Editable = false;
        }
        field(34; "EDI Type"; Option)
        {
            Caption = 'EDI Type';
            OptionCaption = ' ,P2P Contingency';
            OptionMembers = " ","P2P Contingency";
        }
        field(35; "Received from PDA"; DateTime)
        {
            Caption = 'Received from PDA';
        }
        field(36; "3PL EDI"; Boolean)
        {
            Caption = '3PL EDI';
        }
        field(37; "Original EDI Document No."; Code[20])
        {
            Caption = 'Original EDI Document No.';
        }
        field(38; "NAV EDI Document No."; Code[45])
        {
            Caption = 'NAV EDI Document No.';
        }
        field(40; "EDI Order in Outer Pack UoM"; Boolean)
        {
            Editable = false;
        }
        field(50; "Shipment Gross Weight"; Decimal)
        {
        }
        field(51; "Consignment Note No."; Code[50])
        {
        }
        field(52; "Consignment Note Date"; Date)
        {
        }
        field(53; "Delivery Profile"; Integer)
        {
        }
        field(54; "Shipment Notes"; Text[250])
        {
        }
        field(100; "NAV EDI File Log Entry No."; Integer)
        {
            Caption = 'NAV EDI File Log Entry No.';
            DataClassification = CustomerContent;
        }
        //PS-2046+
        field(200; "MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
        field(50000; "Original ASN No."; Code[20])
        {
            Caption = 'Original ASN Number';
        }
    }

    keys
    {
        key(Key1; "Document Type", "No.")
        {
            Clustered = true;
        }
        key(Key2; "Document Type", "Purchase Order No.")
        {
        }
        key(Key3; "Document Type", "Transfer Order No.")
        {
        }
        key(Key4; "EDI File Log Entry No.")
        {
        }
        key(Key5; Status)
        {
        }
        key(Key6; Status, "No Claim")
        {
        }
        key(Key7; "3PL EDI", Status)
        {
        }
        key(Key8; "Original EDI Document No.", "Supplier No.")
        {
        }
        key(Key9; "NAV EDI File Log Entry No.")
        { }
        key(Key10; "Original ASN No.") { }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
    end;


    trigger OnDelete()
    var
        ASNLevel1Line: Record "GXL ASN Level 1 Line";
    begin
        ASNLevel1Line.SETRANGE("Document Type", "Document Type");
        ASNLevel1Line.SETRANGE("Document No.", "No.");
        ASNLevel1Line.DELETEALL(TRUE);
    end;

    procedure UpdateASNLineStatus()
    var
        ASNLevel1: Record "GXL ASN Level 1 Line";
        ASNLevel2: Record "GXL ASN Level 2 Line";
        ASNLevel3: Record "GXL ASN Level 3 Line";
    begin
        ASNLevel1.Reset();
        ASNLevel1.SETRANGE("Document Type", "Document Type");
        ASNLevel1.SETRANGE("Document No.", "No.");
        ASNLevel1.MODIFYALL(Status, Status);

        ASNLevel2.Reset();
        ASNLevel2.SETRANGE("Document Type", "Document Type");
        ASNLevel2.SETRANGE("Document No.", "No.");
        ASNLevel2.MODIFYALL(Status, Status);

        ASNLevel3.Reset();
        ASNLevel3.SETRANGE("Document Type", "Document Type");
        ASNLevel3.SETRANGE("Document No.", "No.");
        ASNLevel3.MODIFYALL(Status, Status);
    end;

    procedure SetReturnOrderManualApplicationFlag(NewValue: Boolean)
    begin
        "Manual Application" := NewValue
    end;

    procedure ResetError()
    begin
        IF Status IN [Status::"Validation Error", Status::"Processing Error", Status::"Receiving Error", Status::"Return Order Creation Error",
                      Status::"Return Order Application Error", Status::"Return Shipment Posting Error", Status::"3PL ASN Sending Error"] THEN BEGIN
            CASE Status OF
                //Include "Validation Error" as the ASN Header are imported from NAV 13
                Status::"Validation Error":
                    Validate(Status, Status::Imported);

                Status::"Processing Error":
                    VALIDATE(Status, Status::Validated);
                Status::"Receiving Error":
                    VALIDATE(Status, Status::Scanned);
                Status::"Return Order Creation Error":
                    VALIDATE(Status, Status::Received);
                Status::"Return Order Application Error":
                    VALIDATE(Status, Status::"Return Order Created");
                Status::"Return Shipment Posting Error":
                    BEGIN
                        IF "Manual Application" = TRUE THEN
                            VALIDATE(Status, Status::"Return Order Created")
                        ELSE
                            VALIDATE(Status, Status::"Return Order Applied")
                    END;
                Status::"3PL ASN Sending Error":
                    VALIDATE(Status, Status::Processed);
            END;
        END ELSE BEGIN
            ERROR('Status must be one of Validation Error, Processing Error, Receiving Error, Return Order Creation Error, Return Order Application Error or Return Shipment Posting Error or 3PL ASN Sending Error');
        END;
    end;

    procedure AddEDIFileLog(): Boolean
    var
        PurchHead: Record "Purchase Header";
        EDIFileLog: Record "GXL EDI File Log";
        EDIDocLog: Record "GXL EDI Document Log";
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        if ("EDI File Log Entry No." = 0) then begin
            if "NAV EDI File Log Entry No." <> 0 then begin
                EDIFileLog.SetCurrentKey("NAV Entry No.");
                EDIFileLog.SetRange("NAV Entry No.", "NAV EDI File Log Entry No.");
                if EDIFileLog.FindFirst() then begin
                    "EDI File Log Entry No." := EDIFileLog."Entry No.";
                    EDIDocLog.SetCurrentKey("NAV EDI File Log Entry No.");
                    EDIDocLog.SetRange("NAV EDI File Log Entry No.", EDIFileLog."NAV Entry No.");
                    if not EDIDocLog.IsEmpty() then
                        EDIDocLog.ModifyAll("EDI File Log Entry No.", EDIFileLog."Entry No.");
                    exit(true);
                end;
            end;

            if PurchHead.Get(PurchHead."Document Type"::Order, "Purchase Order No.") then begin
                "EDI File Log Entry No." := EDIProcessMgt.InsertEDIFileLog3('', 3, 0, '', PurchHead."GXL EDI Vendor Type");
                exit(true);
            end;
        end;
        exit(false);
    end;

    //PS-2343 +
    procedure ResetError(var ASNHead: Record "GXL ASN Header"; ShowConfirmationMessage: Boolean)
    var
        ASNHead2: Record "GXL ASN Header";
        Confirmed: Boolean;
        NoOfDocResetConfirmMsg: Label 'No. of documents that will be reset: %1\OK to continue?';
        NothingToResetMsg: Label 'Nothing to reset.';
    begin
        if ASNHead.FindSet(true) then begin
            if ShowConfirmationMessage then
                Confirmed := Confirm(STRSUBSTNO(NoOfDocResetConfirmMsg, ASNHead.Count()))
            else
                Confirmed := true;

            if Confirmed then begin
                repeat
                    if ASNHead.Status in [
                        ASNHead.Status::"Validation Error",
                        ASNHead.Status::"Processing Error",
                        ASNHead.Status::"Receiving Error",
                        ASNHead.Status::"Return Order Creation Error",
                        ASNHead.Status::"Return Order Application Error",
                        ASNHead.Status::"Return Shipment Posting Error",
                        ASNHead.Status::"3PL ASN Sending Error"]
                    then begin
                        ASNHead2.Get(ASNHead."Document Type", ASNHead."No.");
                        ASNHead2.ResetError();
                        ASNHead2.Modify();
                    end;
                until ASNHead.Next() = 0;
            end;

        end else
            if ShowConfirmationMessage then
                Message(NothingToResetMsg);
    end;
    //PS-2343 -
    procedure ShowVersions(DocType: Integer; OrigDocNo: Code[20])
    var
        ASNHdr: Record "GXL ASN Header";
    begin
        ASNHdr.SetCurrentKey("Original ASN No.");
        ASNHdr.SetFilter("Original ASN No.", OrigDocNo);
        ASNHdr.SetRange("Document Type", DocType);
        Page.Run(Page::"GXL Adv. Shipping Notice List", ASNHdr);
    end;

    procedure EditASN()
    begin
        if IsEditAllowed(Rec, true) then
            Page.Run(Page::"GXL ASN - Edit", Rec);
    end;

    procedure CreateNewVer(DocType: Integer; DocNo: Code[20]; ShowDialog: Boolean)
    var
        ASNHdr: Record "GXL ASN Header";
        ASNLevel1: Record "GXL ASN Level 1 Line";
        ASNLevel2: Record "GXL ASN Level 2 Line";
        ASNLevel3: Record "GXL ASN Level 3 Line";
        ASNLevel4: Record "GXL ASN Level 4 Line";
        ASNHdrNew: Record "GXL ASN Header";
        ASNLevel1New: Record "GXL ASN Level 1 Line";
        ASNLevel2New: Record "GXL ASN Level 2 Line";
        ASNLevel3New: Record "GXL ASN Level 3 Line";
        ASNLevel4New: Record "GXL ASN Level 4 Line";
        NewASNNo: Code[20];
    begin
        if ShowDialog then
            if not Confirm('This will create a new version of ASN %1.\Do you want to Continue?', true, DocNo) then
                exit;

        if not ASNHdr.Get(DocType, DocNo) then
            exit;

        if ASNHdr."Original ASN No." = '' then begin
            ASNHdr."Original ASN No." := ASNHdr."No.";
            ASNHdr.Modify();
        end;

        NewASNNo := GetNextVer(ASNHdr."Document Type", ASNHdr."No.", ASNHdr."Original ASN No.");

        // create ASN Header
        ASNHdrNew := ASNHdr;
        ASNHdrNew."No." := NewASNNo;
        ASNHdrNew.Insert();

        // create ASN Level 1 Line
        ASNLevel1.SetRange("Document Type", ASNHdr."Document Type");
        ASNLevel1.SetRange("Document No.", ASNHdr."No.");
        if ASNLevel1.FindSet() then
            repeat
                ASNLevel1New := ASNLevel1;
                ASNLevel1New."Document No." := ASNHdrNew."No.";
                ASNLevel1New.Insert();
            until ASNLevel1.Next() = 0;

        // create ASN Level 2 Line
        ASNLevel2.SetRange("Document Type", ASNHdr."Document Type");
        ASNLevel2.SetRange("Document No.", ASNHdr."No.");
        if ASNLevel1.FindSet() then
            repeat
                ASNLevel2New := ASNLevel2;
                ASNLevel2New."Document No." := ASNHdrNew."No.";
                ASNLevel2New.Insert();
            until ASNLevel2.Next() = 0;

        // create ASN Level 3 Line
        ASNLevel3.SetRange("Document Type", ASNHdr."Document Type");
        ASNLevel3.SetRange("Document No.", ASNHdr."No.");
        if ASNLevel1.FindSet() then
            repeat
                ASNLevel3New := ASNLevel3;
                ASNLevel3New."Document No." := ASNHdrNew."No.";
                ASNLevel3New.Insert();
            until ASNLevel3.Next() = 0;

        // create ASN Level 4 Line
        ASNLevel4.SetRange("Document Type", ASNHdr."Document Type");
        ASNLevel4.SetRange("Document No.", ASNHdr."No.");
        if ASNLevel4.FindSet() then
            repeat
                ASNLevel4New := ASNLevel4;
                ASNLevel4New."Document No." := ASNHdrNew."No.";
                ASNLevel4New.Insert();
            until ASNLevel4.Next() = 0;

        Commit();

        if ShowDialog then
            Page.Run(Page::"GXL ASN - Edit", ASNHdrNew);
    end;

    local procedure GetNextVer(DocType: Integer; DocNo: Code[20]; OrigDocNo: Code[20]): Code[20]
    var
        ASNHdr: Record "GXL ASN Header";
        VerNo: Integer;
        Ver: Code[5];
    begin
        if OrigDocNo = '' then
            exit(DocNo + '-01');
        ASNHdr.SetCurrentKey("Original ASN No.");
        ASNHdr.SetRange("Original ASN No.", OrigDocNo);
        ASNHdr.FindLast();
        Ver := CopyStr(ASNHdr."No.", StrPos(ASNHdr."No.", '-') + 1);
        Evaluate(VerNo, Ver);
        if VerNo > 98 then begin
            Message('You reached to a limit of 99 versions.\You can not create a new versions');
            exit('');
        end;
        Ver := IncStr(Ver);
        exit(Ver);
    end;

    procedure IsEditAllowed(ASNHdr: Record "GXL ASN Header"; ShowErr: Boolean): Boolean
    var
        MsgTxt: Text;
        IsEditConditionsMet: Boolean;
    begin

        if (ASNHdr."Original ASN No." = '') or (ASNHdr."Original ASN No." = Rec."No.") then begin

            MsgTxt := 'Create a new version if you want to edit ASN %1.';

        end else begin

            if ASNHdr.Status in [ASNHdr.Status::Imported, ASNHdr.Status::Validated, ASNHdr.Status::Processed, ASNHdr.Status::Scanned,
                                 ASNHdr.Status::Receiving, ASNHdr.Status::Received, ASNHdr.Status::"Return Order Created",
                                 ASNHdr.Status::"Return Order Applied", ASNHdr.Status::"Return Shipment Posted", ASNHdr.Status::"3PL ASN Sent"]
            then
                MsgTxt := 'You can edit ASN %1 only if it is in one of Error status.'
            else
                IsEditConditionsMet := true;

        end;

        if ShowErr and (not IsEditConditionsMet) then
            Message(MsgTxt, ASNHdr."No.");

        exit(IsEditConditionsMet);

    end;
}