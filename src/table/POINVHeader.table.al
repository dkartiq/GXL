table 50363 "GXL PO INV Header"
{
    Caption = 'PO INV Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'Vendor Invoice Number';
            DataClassification = CustomerContent;
        }
        field(2; "Vendor Invoice No."; Code[35])
        {
            Caption = 'Vendor Invoice No.';
            DataClassification = CustomerContent;
        }
        field(3; "Invoice Received Date"; Date)
        {
            Caption = 'Invoice Date';
            DataClassification = CustomerContent;
        }
        field(4; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Buyer ID';
            DataClassification = CustomerContent;
        }
        field(5; "Buyer ABN"; Text[11])
        {
            Caption = 'Buyer ABN';
            DataClassification = CustomerContent;
        }
        field(6; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Supplier ID';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(7; "Supplier ABN"; Text[11])
        {
            Caption = 'Supplier ABN';
            DataClassification = CustomerContent;
        }
        field(8; "Location Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(9; "Ship For"; Code[10])
        {
            Caption = 'Ship For';
            DataClassification = CustomerContent;
        }
        field(10; "Invoice Type"; Option)
        {
            Caption = 'Invoice Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Tax Invoice';
            OptionMembers = " ","Tax Invoice";
        }
        field(11; "ASN Number"; Text[30])
        {
            Caption = 'ASN Number';
            DataClassification = CustomerContent;
        }
        field(12; "Expected Receipt Date"; Date)
        {
            Caption = 'Delivery Date';
            DataClassification = CustomerContent;
        }
        field(13; Amount; Decimal)
        {
            Caption = 'Invoice SubTotal';
            DataClassification = CustomerContent;
        }
        field(14; "Amount Incl. VAT"; Decimal)
        {
            Caption = 'Invoice Total';
            DataClassification = CustomerContent;
        }
        field(15; "Total GST"; Decimal)
        {
            Caption = 'Invoice Total VAT';
            DataClassification = CustomerContent;
        }
        field(16; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            OptionCaption = 'Imported,Validation Error,Validated,Processing Error,Processed,Return Credit Posting Error,Return Credit Posted';
            OptionMembers = Imported,"Validation Error",Validated,"Processing Error",Processed,"Return Credit Posting Error","Return Credit Posted";
        }
        field(17; "EDI File Log Entry No."; Integer)
        {
            Caption = 'EDI File Log Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "GXL EDI File Log"."Entry No.";
        }
        field(18; "Purchase Order No."; Code[20])
        {
            Caption = 'Purchase Order No.';
            DataClassification = CustomerContent;
            TableRelation = "Purchase Header"."No." WHERE("Document Type" = CONST(Order));
        }
        field(19; "On Hold"; Boolean)
        {
            Caption = 'On Hold';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "On Hold From"; DateTime)
        {
            Caption = 'On Hold From';
            DataClassification = CustomerContent;
        }
        field(21; "Allow Manual Acceptance"; Boolean)
        {
            Caption = 'Allow Manual Acceptance';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(22; "No Claim"; Boolean)
        {
            Caption = 'No Claim';
            DataClassification = CustomerContent;
        }
        field(23; "EDI Vendor Type"; Option)
        {
            Caption = 'EDI Vendor Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Point 2 Point,VAN,3PL Supplier,Point 2 Point Contingency';
            OptionMembers = " ","Point 2 Point",VAN,"3PL Supplier","Point 2 Point Contingency";
        }
        field(24; "Supplier Name"; Text[100])
        {
            Caption = 'Supplier Name';
            DataClassification = CustomerContent;
        }
        field(25; "P2P Supplier ABN"; Code[20])
        {
            Caption = 'P2P Supplier ABN';
            DataClassification = CustomerContent;
        }
        field(26; "Manual Processing Status"; Option)
        {
            Caption = 'Manual Processing Status';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Created,Closed';
            OptionMembers = " ",Created,Closed;
        }
        field(27; "Original EDI Document No."; Code[20])
        {
            Caption = 'Original EDI Document No.';
            DataClassification = CustomerContent;
        }
        field(28; "NAV EDI Document No."; Code[45])
        {
            Caption = 'NAV EDI Document No.';
            DataClassification = CustomerContent;
        }
        field(29; "Original ASN No."; Code[20])
        {
            Caption = 'Original ASN No.';
            DataClassification = CustomerContent;
        }
        // >> 001 HAR2-513 28.07.2025 MAY HP2-Sprint2-Changes  
        field(30; "Original Inv No."; Code[20])
        {
            Caption = 'Original Invoice No.';
            DataClassification = CustomerContent;
        }
        // << 001 HAR2-513 28.07.2025 MAY HP2-Sprint2-Changes  
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "EDI File Log Entry No.")
        {
        }
        key(Key3; "Purchase Order No.", Status)
        {
        }
        key(Key4; "Purchase Order No.", Status, "No Claim")
        {
        }
        key(Key5; "EDI Vendor Type")
        {
        }
        key(Key6; "Buy-from Vendor No.", "Original EDI Document No.")
        {
        }
        key(Key7; "Buy-from Vendor No.", "Original EDI Document No.", Status)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        POINVLine: Record "GXL PO INV Line";
    begin
        POINVLine.SETRANGE("INV No.", "No.");
        POINVLine.DELETEALL(TRUE);
    end;

    var
        Text000Msg: Label 'must be %1 or %2';

    procedure ResetError()
    begin
        //TODO: temporarily include Validation Error
        IF Status IN [Status::"Validation Error", Status::"Processing Error", Status::"Return Credit Posting Error"] THEN BEGIN

            CASE Status OF
                Status::"Validation Error":
                    Validate(Status, Status::Imported);
                Status::"Processing Error":
                    VALIDATE(Status, Status::Validated);
                Status::"Return Credit Posting Error":
                    VALIDATE(Status, Status::Processed);
            END;

        END ELSE
            FIELDERROR(Status, STRSUBSTNO(Text000Msg, Status::"Processing Error", Status::"Return Credit Posting Error"));
    end;

    // >> 001 HAR2-513 23.07.2025 MAY HP2-Sprint2-Changes  
    procedure CreateNewVer(EDIInvNo: Code[20]; ShowDialog: boolean)
    var
        InvHeader: Record "GXL PO INV Header";
        InvLine: Record "GXL PO INV Line";
        NewINVHeader: Record "GXL PO INV Header";
        NewInvLine: Record "GXL PO INV Line";
        NewEDIInvNo: Code[20];
    begin
        if ShowDialog then
            if not Confirm('This will create a new version of INV %1.\Do you want to Continue?', true, EDIInvNo) then
                exit;

        if not INVHeader.Get(EDIInvNo) then
            exit;

        if INVHeader."Original Inv No." = '' then begin
            INVHeader."Original Inv No." := INVHeader."No.";
            INVHeader.Modify();
        end;

        NewEDIInvNo := GetNextVer(INVHeader."Original Inv No.");

        //create INV Header
        NewINVHeader := INVHeader;
        NewINVHeader."No." := NewEDIInvNo;
        NewINVHeader.Insert();

        //create INV Line
        InvLine.SetRange("INV No.", INVHeader."No.");
        if InvLine.FindSet() then
            repeat
                NewInvLine := InvLine;
                NewInvLine."INV No." := NewINVHeader."No.";
                // NewINVHeader."Original Inv No." := InvHeader."Original Inv No.";
                NewInvLine.Insert();
            until InvLine.Next() = 0;
        Commit();

        if ShowDialog then
            OpenCard(NewINVHeader."No.");
    end;

    procedure ShowVersions(OrgInvNo: Code[20])
    var
        InvHdr: Record "GXL PO INV Header";
    begin
        InvHdr.SetRange("Original Inv No.", OrgInvNo);
        Page.Run(Page::"GXL EDI Invoice List", InvHdr);
    end;

    local procedure GetNextVer(OrgInvNo: Code[20]): Code[20]
    var
        INVHdr: Record "GXL PO INV Header";
        VerNo: Integer;
        LatestNo: Code[20];
        VerSuffix: Text[10];
    begin
        INVHdr.SetCurrentKey("Original Inv No.");
        INVHdr.SetRange("Original Inv No.", OrgInvNo);
        if INVHdr.FindLast() then begin
            LatestNo := INVHdr."No.";
            if StrPos(LatestNo, '-') > 0 then begin
                VerSuffix := CopyStr(LatestNo, StrPos(LatestNo, '-') + 1);
                Evaluate(VerNo, VerSuffix);
                if VerNo >= 99 then Error('Maximum version limit reached.');
                VerSuffix := IncStr(VerSuffix);
                exit(StrSubstNo('%1-%2', OrgInvNo, VerSuffix));
            end;
        end;
        exit(OrgInvNo + '-01');
    end;

    procedure OpenCard(InvNo: Code[20])
    var
        INVHdr: Record "GXL PO INV Header";
    begin
        INVHdr.SetRange("No.", InvNo);
        if (Rec."Original Inv No." = '') or (Rec."Original Inv No." = Rec."No.") then
            Page.RunModal(Page::"GXL EDI Invoice", INVHdr)
        else
            Page.Run(Page::"GXL EDI Invoice", INVHdr);
    end;
    // << 001 HAR2-513 23.07.2025 MAY HP2-Sprint2-Changes  
}