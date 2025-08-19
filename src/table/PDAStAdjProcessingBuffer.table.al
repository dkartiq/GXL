table 50253 "GXL PDA-StAdjProcessing Buffer"
{
    Caption = 'PDA-Stock Adj. Processing Buffer';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; Type; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Type';
            OptionMembers = "ADJ","SOH","ALL";
            OptionCaption = 'ADJ,SOH,ALL';
        }
        field(3; "Store Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Code';
            TableRelation = Location;
        }
        field(4; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(5; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
        field(7; "RMS ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'RMS ID';
        }
        field(10; "Stock on Hand"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Stock on Hand';
            DecimalPlaces = 0 : 5;
        }
        field(11; "Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(12; "Created Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date Time';
        }
        field(13; Errored; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Error';
        }
        field(14; "Error Code"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Code';
        }
        field(15; "Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
        }
        field(16; Processed; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed';
        }
        field(17; "Claim-to Document Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Claim-to Document Type';
            OptionMembers = " ",PO,PI,STO,"STO-SHIP","STO-REC";
            OptionCaption = ' ,Purchase Order,Purchase Invoice,Transfer Order,Transfer Shipment,Transfer Receipt';
        }
        field(18; "Claim-to Order No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Claim-to Order No.';
        }
        field(20; Status; Enum "GXL PDA-Stock Adj Buf. Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Status';
        }
        field(21; "Vendor Ullaged Status"; Enum "GXL Vendor Ullaged Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Ullaged Status';
        }
        field(22; "EDI File Log Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'EDI File Log Entry No.';
        }
        field(23; "Claim-to Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Claim-to Document No.';
        }
        field(24; "Claim-to Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Claim-to Vendor No.';
        }
        field(25; "Claim Document Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Claim Document Type';
            OptionMembers = " ","Transfer Order","Credit Memo","Return Order";
            OptionCaption = ' ,Transfer Order,Credit Memo,Return Order';
        }
        field(26; "Claim Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Claim Document No.';
        }
        field(27; "Claim Document Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Claim Document Line No.';
        }
        field(28; "Posted Return Shipment No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Posted Return Shipment No.';
        }
        field(29; "Posted Credit Memo No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Posted Credit Memo No.';
        }
        field(30; "CLaim-to Receipt No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Claim-to Receipt No.';
        }
        field(31; "Manual Application"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Manual Application';
        }
        field(32; "Post / Send Claim"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Post/Send Claim';
        }
        field(33; Closed; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Closed';
        }
        field(34; "EDI Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Type';
            OptionMembers = " ","3PL EDI";
            OptionCaption = ' ,3PL EDI';
        }
        field(35; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(100; "Legacy Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Legacy Item No.';
            Editable = false;
            //It is mainly used for WH Messages Lines transfer for reference purposes
        }
        //PS-2046+
        field(200; "MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
        field(201; Narration; Text[250]) { } // LCB-239 <<
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Status; Status, "Created Date Time") { }
        key(Errored; Errored, Processed, "Claim-to Document Type") { }
        key(ClaimToDocumentType; "Claim-to Document Type") { }
        key(EDIFileLogEntry; "EDI File Log Entry No.") { }
        key(RMSId; "RMS ID") { }
    }

    var
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        StatusMustBeAnErrorStatusErr: Label 'Status must be an error status.';

    trigger OnInsert()
    begin
        "Created Date Time" := CurrentDateTime();
        if ("Legacy Item No." = '') and ("Item No." <> '') then
            LegacyItemHelpers.GetLegacyItemNo("Item No.", "Unit of Measure Code", "Legacy Item No.");
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


    procedure SetReturnOrderManualApplicationFlag(NewValue: Boolean)
    begin
        "Manual Application" := NewValue
    end;

    procedure ResetError()
    begin

        if Status in [Status::"Validation Error", Status::"Return Order Creation Error",
            Status::"Return Order Application Error", Status::"Return Shipment Posting Error",
            Status::"Credit Creation Error", Status::"Credit Application Error", Status::"Credit Posting Error",
            Status::"Transfer Creation Error", Status::"Transfer Shipping Error", Status::"Transfer Receiving Error",
            Status::"Journal Posting Error"] then begin

            case Status of
                Status::"Validation Error":
                    Validate(Status, Status::" ");
                Status::"Return Order Creation Error":
                    Validate(Status, Status::Validated);
                Status::"Return Order Application Error":
                    Validate(Status, Status::"Return Order Created");
                Status::"Return Shipment Posting Error":
                    if "Manual Application" then
                        Validate(Status, Status::"Return Order Created")
                    else
                        Validate(Status, Status::"Return Order Applied");
                Status::"Credit Creation Error":
                    Validate(Status, Status::Validated);
                Status::"Credit Application Error":
                    Validate(Status, Status::"Credit Created");
                Status::"Credit Posting Error":
                    //if "Vendor Ullaged Status" = "Vendor Ullaged Status"::Ullaged then //ERP-340 -
                    if "Claim Document Type" = "Claim Document Type"::"Return Order" then //ERP-340 +
                        Validate(Status, Status::"Return Shipment Posted")
                    else
                        Validate(Status, Status::"Credit Created");
                Status::"Transfer Creation Error":
                    Validate(Status, Status::Validated);
                Status::"Transfer Shipping Error":
                    Validate(Status, Status::"Transfer Created");
                Status::"Transfer Receiving Error":
                    Validate(Status, Status::"Transfer Shipped");
                Status::"Journal Posting Error":
                    Validate(Status, Status::"Transfer Received");
            end;

            Errored := false;
            "Error Code" := '';
            "Error Message" := '';

        end else
            if (Status = Status::" ") and Errored and (Not Processed) then begin
                //For non-claimable
                Errored := false;
                "Error Code" := '';
                "Error Message" := '';
            end else
                Error(StatusMustBeAnErrorStatusErr);

    end;

    procedure OpenClaimDocument()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        case "Claim Document Type" of
            "Claim Document Type"::"Transfer Order":
                ;
            "Claim Document Type"::"Credit Memo":
                if PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", "Claim Document No.") then
                    Page.Run(Page::"Purchase Credit Memo", PurchaseHeader);
            "Claim Document Type"::"Return Order":
                BEGIN
                    if PurchaseHeader.Get(PurchaseHeader."Document Type"::"Return Order", "Claim Document No.") then
                        Page.Run(Page::"Purchase Return Order", PurchaseHeader);
                end;
        end;
    end;

    procedure GetLastRMSID(): Integer
    var
        PDAStAdjProcessingBuff: Record "GXL PDA-StAdjProcessing Buffer";
    begin
        PDAStAdjProcessingBuff.SetCurrentKey("RMS ID");
        if PDAStAdjProcessingBuff.FindLast() then
            exit(PDAStAdjProcessingBuff."RMS ID")
        else
            exit(0);
    end;

    procedure SetRMSID()
    var
        IntegratioNSetup: Record "GXL Integration Setup";
        LastRMSId: Integer;
    begin
        IntegratioNSetup.Get();
        LastRMSId := GetLastRMSID();
        if LastRMSId < IntegratioNSetup."Last RMS ID" then
            LastRMSId := IntegratioNSetup."Last RMS ID";
        "RMS ID" := LastRMSId + 1;
    end;

    //PS-2343 +
    procedure ResetError(var PDAStAdjProcessingBuff: Record "GXL PDA-StAdjProcessing Buffer"; ShowConfirmationMessage: Boolean)
    var
        PDAStAdjProcessingBuff2: Record "GXL PDA-StAdjProcessing Buffer";
        Confirmed: Boolean;
        NoOfDocResetConfirmMsg: Label 'No. of documents that will be reset: %1\OK to continue?';
        NothingToResetMsg: Label 'Nothing to reset.';
    begin
        if PDAStAdjProcessingBuff.FindSet(true) then begin
            if ShowConfirmationMessage then
                Confirmed := Confirm(STRSUBSTNO(NoOfDocResetConfirmMsg, PDAStAdjProcessingBuff.Count()))
            else
                Confirmed := true;

            if Confirmed then begin
                repeat
                    If PDAStAdjProcessingBuff.Status in [
                        PDAStAdjProcessingBuff.Status::"Validation Error",
                        PDAStAdjProcessingBuff.Status::"Return Order Creation Error",
                        PDAStAdjProcessingBuff.Status::"Return Order Application Error",
                        PDAStAdjProcessingBuff.Status::"Return Shipment Posting Error",
                        PDAStAdjProcessingBuff.Status::"Credit Creation Error",
                        PDAStAdjProcessingBuff.Status::"Credit Application Error",
                        PDAStAdjProcessingBuff.Status::"Credit Posting Error",
                        PDAStAdjProcessingBuff.Status::"Transfer Creation Error",
                        PDAStAdjProcessingBuff.Status::"Transfer Shipping Error",
                        PDAStAdjProcessingBuff.Status::"Transfer Receiving Error",
                        PDAStAdjProcessingBuff.Status::"Journal Posting Error"]
                    then begin
                        PDAStAdjProcessingBuff2.Get(PDAStAdjProcessingBuff."Entry No.");
                        PDAStAdjProcessingBuff2.ResetError();
                        PDAStAdjProcessingBuff2.Modify();
                    end;
                until PDAStAdjProcessingBuff.Next() = 0;
            end;

        end else
            if ShowConfirmationMessage then
                Message(NothingToResetMsg);
    end;

    //PS-2343 -
}