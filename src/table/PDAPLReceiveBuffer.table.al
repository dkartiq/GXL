table 50255 "GXL PDA-PL Receive Buffer"
{
    DataClassification = CustomerContent;
    Caption = 'PDA-PL Receive Buffer';

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Entry Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry Type';
            OptionMembers = Purchase,Transfer,Adjustment;
            OptionCaption = 'Purchase,Transfer,Adjustment';
        }
        field(3; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(4; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(6; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
        }
        field(7; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(8; QtyOrdered; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'QtyOrdered';
            DecimalPlaces = 0 : 5;
        }
        field(9; QtyToReceive; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'QtyToReceive';
            DecimalPlaces = 0 : 5;
        }
        field(10; "Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Reason Code';
        }
        field(11; InvoiceQuantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'InvoiceQuantity';
            DecimalPlaces = 0 : 5;
        }
        field(12; "Entry Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry Date Time';
            Editable = false;
        }
        field(13; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
        }
        field(28; Errored; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Error';
        }
        field(29; "Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
        }
        field(30; "Receipt Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Receipt Type';
            OptionMembers = Full,Lines;
            OptionCaption = 'Full,Lines';
        }
        field(31; Processed; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed';
            Editable = false;
        }
        field(32; "Processing Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Processing Date Time';
            Editable = false;
        }
        field(33; "Received from PDA"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Received from PDA';
        }
        field(34; Status; Enum "GXL PDA-PL Receive Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
        }
        field(35; "Claim Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Claim Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(36; "Vendor Ullaged Status"; Enum "GXL Vendor Ullaged Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Ullaged Status';
        }
        field(37; "Purchase Receipt No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase Receipt No.';
        }
        field(38; "Purchase Invoice No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase Invoice No.';
        }
        field(39; "Claim Document Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Claim Document Type';
            OptionMembers = "  ","Transfer Order","Credit Memo","Return Order";
            OptionCaption = ' ,Transfer Order,Credit Memo,Return Order';
        }
        field(40; "Claim Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Claim Document No.';
        }
        field(41; "Claim Document Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Claim Document Line No.';
        }
        field(42; "Return Shipment No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Return Shipment No.';
        }
        field(43; "Purchase Credit Memo No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Purchase Credit Memo No.';
        }
        field(44; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor No.';
        }
        field(45; "EDI File Log Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'EDI File Log Entry No.';
        }
        field(46; "Post / Send Claim"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Post/Send Claim';
        }
        field(47; "Manual Application"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Manual Application';
        }
        field(48; "EDI Vendor Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Vendor Type';
            OptionMembers = " ","Point 2 Point",VAN,"3PL Supplier","Point 2 Point Contingency";
            OptionCaption = ' ,Point 2 Point,VAN,3PL Supplier,Point 2 Point Contingency';
        }
        field(49; "Entry Closed"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry Closed';
            OptionMembers = " ","Manuallly","By the System";
            OptionCaption = ' ,Manually,By the System';
        }
        field(50; "Error Code"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Code';
        }
        field(51; Cancelled; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Cancelled';
        }
        field(100; "Legacy Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Legacy Item No.';
            Description = 'To be used only on sending to NAV13';
        }
        //PS-2046+
        field(200; "MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
        // >> LCB-227
        field(210; "Manually Posted"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        // << LCB-227
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Document No.", "Line No.") { }
        key(Key4; Status, "Document No.") { }
        key(Key5; Errored, Processed) { }
        key(Key6; Status, "Entry Date Time") { }
        key(Key8; Processed, Status, "Document No.") { }
        key(Key9; Processed, Errored, "Document No.", "Line No.") { }
    }

    var
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        StatusMustBeErr: Label 'Status must be one of\   %1\   %2\   %3\   %4\   %5\   %6\   %7\   %8';

    trigger OnInsert()
    begin
        "Entry Date Time" := CurrentDateTime();
        if "Receipt Type" = "Receipt Type"::Lines then
            if ("Legacy Item No." = '') and ("No." <> '') then
                LegacyItemHelpers.GetLegacyItemNo("No.", "Unit of Measure Code", "Legacy Item No.");
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure ResetError()
    begin

        if Status in [Status::"Processing Error", Status::"Receiving Error", Status::"Return Order Creation Error",
          Status::"Return Order Application Error", Status::"Return Shipment Posting Error",
          Status::"Credit Creation Error", Status::"Credit Application Error", Status::"Credit Posting Error"] then begin

            case Status of
                Status::"Processing Error":
                    Validate(Status, Status::Scanned);
                Status::"Receiving Error":
                    Validate(Status, Status::Processed);
                Status::"Return Order Creation Error":
                    Validate(Status, Status::Received);
                Status::"Return Order Application Error":
                    Validate(Status, Status::"Return Order Created");
                Status::"Return Shipment Posting Error":
                    Validate(Status, Status::"Return Order Applied");
                Status::"Credit Creation Error":
                    Validate(Status, Status::Received);
                Status::"Credit Application Error":
                    Validate(Status, Status::"Credit Created");
                Status::"Credit Posting Error":
                    // if "Vendor Ullaged Status" = "Vendor Ullaged Status"::Ullaged then //ERP-340 -
                    if "Claim Document Type" = "Claim Document Type"::"Return Order" then //ERP-340 +
                        Validate(Status, Status::"Return Order Applied")
                    else
                        Validate(Status, Status::"Credit Applied");
            end;

            Errored := false;
            "Error Code" := '';
            "Entry Closed" := "Entry Closed"::" ";
            "Error Message" := '';

        end else
            Error(StrSubStNo(StatusMustBeErr,
              Status::"Processing Error",
              Status::"Receiving Error",
              Status::"Return Order Creation Error",
              Status::"Return Order Application Error",
              Status::"Return Shipment Posting Error",
              Status::"Credit Creation Error",
              Status::"Credit Application Error",
              Status::"Credit Posting Error"));

    end;

    procedure OpenDocument()
    var
        PurchHeader: Record "Purchase Header";
        TransHeader: Record "Transfer Header";
    begin
        if PurchHeader.Get(PurchHeader."Document Type"::Order, "Document No.") then
            Page.Run(Page::"Purchase Order", PurchHeader)
        else
            if TransHeader.Get("Document No.") then
                Page.Run(Page::"Transfer Order", TransHeader);
    end;

    procedure OpenClaimDocument()
    var
        PurchHeader: Record "Purchase Header";
    begin
        case "Claim Document Type" of
            "Claim Document Type"::"Transfer Order":
                Message('Not Implemented!');

            "Claim Document Type"::"Credit Memo":
                if "Purchase Credit Memo No." <> '' then
                    OpenPostedClaimDocument()
                else
                    if PurchHeader.Get(PurchHeader."Document Type"::"Credit Memo", "Claim Document No.") then
                        Page.Run(Page::"Purchase Credit Memo", PurchHeader);

            "Claim Document Type"::"Return Order":
                if "Purchase Credit Memo No." <> '' then
                    OpenPostedClaimDocument()
                else
                    if PurchHeader.Get(PurchHeader."Document Type"::"Return Order", "Claim Document No.") then
                        Page.Run(Page::"Purchase Return Order", PurchHeader);
        end;
    end;

    procedure OpenPostedClaimDocument()
    var
        PurchCrMemoHead: Record "Purch. Cr. Memo Hdr.";
    begin
        if "Purchase Credit Memo No." <> '' then
            if PurchCrMemoHead.Get("Purchase Credit Memo No.") then
                Page.Run(Page::"Posted Purchase Credit Memo", PurchCrMemoHead);
    end;

    // >> LCB-227
    procedure UpdateStatus(var PdaReceivingBuffer: Record "GXL PDA-PL Receive Buffer")
    var
        TransferPosted: Boolean;
        POPosted: Boolean;
    begin
        PdaReceivingBuffer.SetFilter("Entry Type", '%1|%2', PdaReceivingBuffer."Entry Type"::Purchase, PdaReceivingBuffer."Entry Type"::Transfer);
        if PdaReceivingBuffer.FindSet() then
            repeat
                if PdaReceivingBuffer.status IN [PdaReceivingBuffer.Status::"Invoice Posting Error", PdaReceivingBuffer.Status::"Processing Error", PdaReceivingBuffer.Status::"Receiving Error"] then begin
                    TransferPosted := false;
                    POPosted := false;
                    case PdaReceivingBuffer."Entry Type" of
                        PdaReceivingBuffer."Entry Type"::Transfer:
                            begin
                                TransferPosted := IsTransferRcptPosted(PdaReceivingBuffer);
                                if TransferPosted then begin
                                    PdaReceivingBuffer.Validate(Status, PdaReceivingBuffer.Status::Received);
                                    PdaReceivingBuffer.Validate(Processed, true);
                                end;
                            end;
                        PdaReceivingBuffer."Entry Type"::Purchase:
                            begin
                                POPosted := IsPOInvoiced(PdaReceivingBuffer);
                                if POPosted then begin
                                    PdaReceivingBuffer.Validate(Status, PdaReceivingBuffer.Status::"Invoice Posted");
                                    PdaReceivingBuffer.Validate(Processed, true);
                                end else begin
                                    POPosted := IsPOReceived(PdaReceivingBuffer);
                                    if POPosted then
                                        PdaReceivingBuffer.Validate(Status, PdaReceivingBuffer.Status::Received)
                                end;
                            end;
                    end;

                    if TransferPosted or POPosted then
                        ClearError(PdaReceivingBuffer);

                end;
            until PdaReceivingBuffer.Next() = 0;

    end;

    procedure ClearError(Var PdaReceivingBufferP: Record "GXL PDA-PL Receive Buffer")
    begin
        PdaReceivingBufferP."Error Code" := '';
        PdaReceivingBufferP."Error Message" := '';
        PdaReceivingBufferP.Errored := false;
        PdaReceivingBufferP."Manually Posted" := TRUE;
        PdaReceivingBufferP.Modify(true);
    end;

    procedure IsTransferRcptPosted(PdaReceivingBuffer: Record "GXL PDA-PL Receive Buffer"): Boolean
    var
        TransferRcptLine: Record "Transfer Receipt Line";
    begin
        TransferRcptLine.SetRange("Transfer Order No.", PdaReceivingBuffer."Document No.");
        IF PdaReceivingBuffer."Receipt Type" = PdaReceivingBuffer."Receipt Type"::Lines then begin
            TransferRcptLine.SetRange("Line No.", PdaReceivingBuffer."Line No.");
            TransferRcptLine.SetRange("Item No.", PdaReceivingBuffer."No.");
        end;
        exit(not TransferRcptLine.IsEmpty());
    end;

    procedure IsPOInvoiced(PdaReceivingBuffer: Record "GXL PDA-PL Receive Buffer"): Boolean
    var
        PurchInvLine: Record "Purch. Inv. Line";
    begin
        PurchInvLine.SetRange("Document No.", PdaReceivingBuffer."Purchase Invoice No.");
        IF PdaReceivingBuffer."Receipt Type" = PdaReceivingBuffer."Receipt Type"::Lines then begin
            PurchInvLine.SetRange("Line No.", PdaReceivingBuffer."Line No.");
            PurchInvLine.SetRange("No.", PdaReceivingBuffer."No.");
        end;
        exit(not PurchInvLine.IsEmpty());
    end;

    procedure IsPOReceived(PdaReceivingBuffer: Record "GXL PDA-PL Receive Buffer"): Boolean
    var
        PurchRecptLine: Record "Purch. Rcpt. Line";
    begin
        PurchRecptLine.SetRange("Document No.", PdaReceivingBuffer."Purchase Receipt No.");
        IF PdaReceivingBuffer."Receipt Type" = PdaReceivingBuffer."Receipt Type"::Lines then begin
            PurchRecptLine.SetRange("Line No.", PdaReceivingBuffer."Line No.");
            PurchRecptLine.SetRange("No.", PdaReceivingBuffer."No.");
        end;
        exit(not PurchRecptLine.IsEmpty());
    end;
    // << LCB-227
}