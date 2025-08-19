// LCB-3   23-09-2022  PREM    Apply credit memo only if Purchase Invoice exist if vendor is enabled for Post Credit Claim On Receipt
codeunit 50271 "GXL Claim Management"
{
    trigger OnRun()
    begin

    end;

    var
        MIMUserID: Code[50];
        VendorUllagedStatusMustBeProvidedMsg: Label 'Vendor Ullaged Status must be provided.';

    procedure CreatePurchaseHeader(var PurchaseHeader: Record "Purchase Header";
        DocumentType: Option Quote,Order,Invoice,"Credit Memo","Blanket Order","Return Order";
        NoSeriesCode: Code[20]; VendorNo: Code[20];
        LocationCode: Code[10]; PostingDate: Date; VendorCrMemoNo: Code[35];
        BalAccountType: Option; BalAccountNo: Code[20]; ReasonCode: Code[10]; OrderNoP: Code[20])  //BalAccountType: Option; BalAccountNo: Code[20]; ReasonCode: Code[10]) // >> LCB-3 <<
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NextCRMemoNo: Code[35];
    begin

        PurchaseHeader.Init();
        PurchaseHeader.Validate("No. Series", NoSeriesCode);
        PurchaseHeader."No." := NoSeriesMgt.GetNextNo(NoSeriesCode, 0D, true);
        PurchaseHeader.Validate("Document Type", DocumentType);
        PurchaseHeader.Insert(true);

        //PS-2613 +
        //Moved to below to use pay-to vendor no. 
        //NextCRMemoNo := GetNextVendorCRMemoNo(VendorCrMemoNo, VendorNo);
        //PS-2613 -

        PurchaseHeader.Validate("Buy-from Vendor No.", VendorNo);
        //PS-2613+
        if VendorCrMemoNo <> '' then //PS-2638 +
            NextCRMemoNo := GetNextVendorCRMemoNo(VendorCrMemoNo, PurchaseHeader."Pay-to Vendor No.");
        //Force so Location Code and Store No. can be populated correctly
        PurchaseHeader."LSc Store No." := '';
        //PS-2613-
        PurchaseHeader.Validate("Location Code", LocationCode);
        PurchaseHeader.Validate("Posting Date", PostingDate);
        PurchaseHeader.Validate("Vendor Cr. Memo No.", NextCRMemoNo);
        //TODO: Order Status - create Claim document - probably it is not required as only purchase return order or credit note is created
        PurchaseHeader.Validate("GXL Order Status", PurchaseHeader."GXL Order Status"::New);
        PurchaseHeader.Validate("Bal. Account Type", BalAccountType);
        PurchaseHeader.Validate("Bal. Account No.", BalAccountNo);
        PurchaseHeader.Validate("Reason Code", ReasonCode);
        // >> HP-2139
        /*
        //PS-2613 +
        //Revalidate dimensions to activate store dimension from LS event subs
        //It is LS bug as it should have called CreateDim on validating Location or Store
        PurchaseHeader.CreateDim(
            Database::Vendor, PurchaseHeader."Pay-to Vendor No.",
            Database::"Salesperson/Purchaser", PurchaseHeader."Purchaser Code",
            Database::Campaign, PurchaseHeader."Campaign No.",
            Database::"Responsibility Center", PurchaseHeader."Responsibility Center");
        //PS-2613 -
        */
        // << HP-2139
        PurchaseHeader."GXL MIM User ID" := MIMUserID; //PS-2565 Missing MIM User ID +
        IF OrderNoP > '' THEN PurchaseHeader."Posting Description" := OrderNoP;  // >> LCB-3 <<
        PurchaseHeader.Modify(true);
    end;

    procedure CreatePurchaseLine(var PurchaseLine: Record "Purchase Line"; PurchaseHeader: Record "Purchase Header";
        LineNo: Integer; ItemNo: Code[20]; UOMCode: Code[10]; Quantity: Decimal;
        var ClaimDocumentType: Option " ","Tranfer Order","Credit Meno","Return Order";
        var ClaimDocumentNo: Code[20]; var ClaimDocumentLineNo: Integer)
    begin
        PurchaseLine.Init();
        PurchaseLine.Validate("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.Validate("Document No.", PurchaseHeader."No.");
        PurchaseLine.Validate("Line No.", LineNo);

        PurchaseLine.Insert(true);

        PurchaseLine.Validate(Type, PurchaseLine.Type::Item);
        PurchaseLine.Validate("No.", ItemNo);
        PurchaseLine.Validate("Unit of Measure Code", UOMCode);
        PurchaseLine.Validate(Quantity, Quantity);
        PurchaseLine.Modify(true);

        // ,Transfer Order,Credit Memo,Return Order
        CASE PurchaseHeader."Document Type" OF
            PurchaseHeader."Document Type"::"Credit Memo":
                ClaimDocumentType := ClaimDocumentType::"Credit Meno";
            PurchaseHeader."Document Type"::"Return Order":
                ClaimDocumentType := ClaimDocumentType::"Return Order";
        end;

        ClaimDocumentNo := PurchaseLine."Document No.";
        ClaimDocumentLineNo := PurchaseLine."Line No.";
    end;

    procedure GetAppliesToItemLedgerEntryNo(var ClaimToReceiptNo: Code[20]; ClaimToOrderNo: Code[20]; ClaimToVendorNo: Code[20]; ItemNo: Code[20]): Integer
    var
        PurchaseReceiptHeaderTemp: Record "Purch. Rcpt. Header" temporary;
        ItemLedgerEntryNo: Integer;
    begin
        if ClaimToReceiptNo = '' then begin

            GetPostedPurchaseReceiptNos(
              PurchaseReceiptHeaderTemp,
              ClaimToOrderNo,
              ClaimToVendorNo);

            if PurchaseReceiptHeaderTemp.FindSet() then
                repeat
                    ItemLedgerEntryNo := GetItemLedgerEntryNo(ClaimToReceiptNo, ItemNo);
                until (ItemLedgerEntryNo > 0) OR (PurchaseReceiptHeaderTemp.Next() = 0);

            ClaimToReceiptNo := PurchaseReceiptHeaderTemp."No.";

        end else
            ItemLedgerEntryNo := GetItemLedgerEntryNo(ClaimToReceiptNo, ItemNo);

        EXIT(ItemLedgerEntryNo);
    end;

    //ERP-340 +
    procedure GetAppliesToItemLedgerEntryNo(var ClaimToReceiptNo: Code[20]; ClaimToOrderNo: Code[20]; ClaimToVendorNo: Code[20]; ItemNo: Code[20]; OrderLineNo: Integer): Integer
    var
        PurchaseReceiptHeaderTemp: Record "Purch. Rcpt. Header" temporary;
        ItemLedgerEntryNo: Integer;
    begin
        if ClaimToReceiptNo = '' then begin

            GetPostedPurchaseReceiptNos(
              PurchaseReceiptHeaderTemp,
              ClaimToOrderNo,
              ClaimToVendorNo);

            if PurchaseReceiptHeaderTemp.FindSet() then
                repeat
                    ItemLedgerEntryNo := GetItemLedgerEntryNo(ClaimToReceiptNo, ItemNo, OrderLineNo);
                until (ItemLedgerEntryNo > 0) OR (PurchaseReceiptHeaderTemp.Next() = 0);

            ClaimToReceiptNo := PurchaseReceiptHeaderTemp."No.";

        end else
            ItemLedgerEntryNo := GetItemLedgerEntryNo(ClaimToReceiptNo, ItemNo, OrderLineNo);

        EXIT(ItemLedgerEntryNo);
    end;

    procedure GetItemLedgerEntryNo(ClaimToReceiptNo: Code[20]; ItemNo: Code[20]; ClaimToReceiptLineNo: Integer): Integer
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetCurrentKey("Document No.", "Document Type", "Document Line No.");
        ItemLedgerEntry.SetRange("Document No.", ClaimToReceiptNo);
        ItemLedgerEntry.SetRange("Document Type", ItemLedgerEntry."Document Type"::"Purchase Receipt");
        if ClaimToReceiptLineNo <> 0 then
            ItemLedgerEntry.SetRange("Document Line No.", ClaimToReceiptLineNo);
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Purchase);
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        if ItemLedgerEntry.FindFirst() then
            exit(ItemLedgerEntry."Entry No.");
    end;
    //ERP-340 -

    procedure GetItemLedgerEntryNo(ClaimToReceiptNo: Code[20]; ItemNo: Code[20]): Integer
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
    begin
        ItemLedgerEntry.SetCurrentKey("Document No.", "Document Type");
        ItemLedgerEntry.SetRange("Document No.", ClaimToReceiptNo);
        ItemLedgerEntry.SetRange("Document Type", ItemLedgerEntry."Document Type"::"Purchase Receipt");
        ItemLedgerEntry.SetRange("Entry Type", ItemLedgerEntry."Entry Type"::Purchase);
        ItemLedgerEntry.SetRange("Item No.", ItemNo);
        if ItemLedgerEntry.FindFirst() then
            EXIT(ItemLedgerEntry."Entry No.");
    end;

    procedure CreatePOClaimPrerequisitesMet(VendorUllagedStatus: Enum "GXL Vendor Ullaged Status"; var ClaimToReceiptNo: Code[20]; ClaimToOrderNo: Code[20]; ClaimToVendorNo: Code[20]) PrerequisitesMet: Boolean
    var
        PurchaseReceiptHeaderTemp: Record "Purch. Rcpt. Header" temporary;
    begin
        if VendorUllagedStatus = VendorUllagedStatus::Ullaged then begin

            if ClaimToReceiptNo = '' then begin

                GetPostedPurchaseReceiptNos(
                  PurchaseReceiptHeaderTemp,
                  ClaimToOrderNo,
                  ClaimToVendorNo);

                if PurchaseReceiptHeaderTemp.FindFirst() then
                    ClaimToReceiptNo := PurchaseReceiptHeaderTemp."No.";  // Caller must Modify

            end;

            PrerequisitesMet := ClaimToReceiptNo <> '';

        end else begin
            //ERP-340 +
            if ClaimToReceiptNo = '' then begin
                GetPostedPurchaseReceiptNos(
                  PurchaseReceiptHeaderTemp,
                  ClaimToOrderNo,
                  ClaimToVendorNo);

                if PurchaseReceiptHeaderTemp.FindFirst() then
                    ClaimToReceiptNo := PurchaseReceiptHeaderTemp."No.";  // Caller must Modify
            end;
            //ERP-340 -
            PrerequisitesMet := true;

        end;
    end;

    procedure CreateSTOClaimPrerequisitesMet(var ClaimToTransferReceiptNo: Code[20]; ClaimToOrderNo: Code[20]; ClaimToStoreCode: Code[20]) PrerequisitesMet: Boolean
    var
        TransferReceiptHeaderTemp: Record "Transfer Receipt Header" temporary;
    begin
        if ClaimToTransferReceiptNo = '' then begin

            GetTransferReceiptNos(
              TransferReceiptHeaderTemp,
              ClaimToOrderNo,
              ClaimToStoreCode);

            if TransferReceiptHeaderTemp.FindFirst() then
                ClaimToTransferReceiptNo := TransferReceiptHeaderTemp."No.";
            // Caller must Modify

        end;

        PrerequisitesMet := ClaimToTransferReceiptNo <> '';
    end;

    procedure ApplyClaimPrerequisitesMet(VendorUllagedStatus: Enum "GXL Vendor Ullaged Status"; var ClaimToDocumentNo: Code[20]; ClaimToOrderNo: Code[20]; ClaimToVendorNo: Code[20]) PrerequisitesMet: Boolean
    begin
        if VendorUllagedStatus = VendorUllagedStatus::"Non-Ullaged" then begin

            if ClaimToDocumentNo = '' then
                ClaimToDocumentNo :=
                  GetPostedPurchaseInvoiceNo(
                    ClaimToOrderNo,
                    ClaimToVendorNo);

            PrerequisitesMet := ClaimToDocumentNo <> '';  // Caller must Modify

        end else
            PrerequisitesMet := true;
    end;

    //ERP-340 +
    procedure ApplyClaimPrerequisitesMet(ClaimDocType: Option " ","Transfer Order","Credit Memo","Return Order";
        var ClaimToDocumentNo: Code[20]; ClaimToOrderNo: Code[20]; ClaimToVendorNo: Code[20]) PrerequisitesMet: Boolean
    var
        // >> LCB-3
        Vend: Record Vendor;
        PurchInvHdr: Record "Purch. Inv. Header";
    // << LCB-3
    begin
        //Non-ullaged vendors
        //To handle the Pre ERP and Exflow go live
        //Post ERP and Exflow, always create return order
        if ClaimDocType = ClaimDocType::"Return Order" then
            PrerequisitesMet := true
        else begin
            if ClaimToDocumentNo = '' then
                ClaimToDocumentNo :=
                  GetPostedPurchaseInvoiceNo(
                    ClaimToOrderNo,
                    ClaimToVendorNo);

            PrerequisitesMet := ClaimToDocumentNo <> '';  // Caller must Modify
            // >> LCB-3
            IF ClaimDocType = ClaimDocType::"Credit Memo" then begin
                IF Vend.Get(ClaimToVendorNo) THEN begin
                    if not Vend."GXL Disable Auto Invoice" THEN
                        IF NOT PurchInvHdr.Get(ClaimToDocumentNo) then
                            PrerequisitesMet := FALSE;
                    if Vend."GXL Post Credit ClaimOnReceipt" then
                        PrerequisitesMet := true;
                end;
            end;
            // << LCB-3
        end;

    end;
    //ERP-340 -

    procedure PostReturnCreditPrerequisitesMet(VendorUllagedStatus: Enum "GXL Vendor Ullaged Status"; var ClaimToDocumentNo: Code[20]; ClaimToOrderNo: Code[20]; VendorNo: Code[20]) PrerequisitesMet: Boolean
    begin
        if VendorUllagedStatus = VendorUllagedStatus::Ullaged then begin

            if ClaimToDocumentNo = '' then
                ClaimToDocumentNo :=
                  GetPostedPurchaseInvoiceNo(
                    ClaimToOrderNo,
                    VendorNo);

            PrerequisitesMet := ClaimToDocumentNo <> '';  // Caller must Modify

        end else
            PrerequisitesMet := true;
    end;

    //ERP-340 +
    procedure PostReturnCreditPrerequisitesMet(ClaimDocType: Option " ","Transfer Order","Credit Memo","Return Order";
        var ClaimToDocumentNo: Code[20]; ClaimToOrderNo: Code[20]; VendorNo: Code[20]) PrerequisitesMet: Boolean
    begin
        //Non-ullaged vendors
        //To handle the Pre ERP and Exflow go live
        //Post ERP and Exflow, always create return order
        if ClaimDocType = ClaimDocType::"Return Order" then begin
            if ClaimToDocumentNo = '' then
                ClaimToDocumentNo :=
                  GetPostedPurchaseInvoiceNo(
                    ClaimToOrderNo,
                    VendorNo);

            PrerequisitesMet := ClaimToDocumentNo <> '';
        end else
            PrerequisitesMet := true;
    end;
    //ERP-340 -

    LOCAL procedure GetPostedPurchaseReceiptNos(var PurchaseReceiptHeaderTemp: Record "Purch. Rcpt. Header" temporary; OrderNo: Code[20]; VendorNo: Code[20]): Code[20]
    var
        PurchaseReceiptHeader: Record "Purch. Rcpt. Header";
    begin
        PurchaseReceiptHeader.SetCurrentKey("Order No.");
        PurchaseReceiptHeader.SetRange("Order No.", OrderNo);
        PurchaseReceiptHeader.SetRange("Buy-from Vendor No.", VendorNo);
        if PurchaseReceiptHeader.FindSet() then
            repeat
                PurchaseReceiptHeaderTemp.Init();
                PurchaseReceiptHeaderTemp."No." := PurchaseReceiptHeader."No.";
                PurchaseReceiptHeaderTemp.Insert();
            until PurchaseReceiptHeader.Next() = 0;
    end;

    LOCAL procedure GetPostedPurchaseInvoiceNo(OrderNo: Code[20]; VendorNo: Code[20]) PurchaseInvoiceNo: Code[20]
    var
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
    begin
        PurchaseInvoiceHeader.SetCurrentKey("Order No.");
        PurchaseInvoiceHeader.SetRange("Order No.", OrderNo);
        PurchaseInvoiceHeader.SetRange("Buy-from Vendor No.", VendorNo);
        if PurchaseInvoiceHeader.FindFirst() then
            PurchaseInvoiceNo := PurchaseInvoiceHeader."No.";
    end;

    LOCAL procedure GetTransferReceiptNos(var TransferReceiptHeaderTemp: Record "Transfer Receipt Header" temporary; OrderNo: Code[20]; TransferToCode: Code[10])
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        TransferReceiptLine.SetCurrentKey("Transfer Order No.");
        TransferReceiptLine.SetRange("Transfer Order No.", OrderNo);
        TransferReceiptLine.SetRange("Transfer-to Code", TransferToCode);
        if TransferReceiptLine.FindSet() then
            repeat
                if not TransferReceiptHeaderTemp.Get(TransferReceiptLine."Document No.") then begin
                    TransferReceiptHeaderTemp.Init();
                    TransferReceiptHeaderTemp."No." := TransferReceiptLine."Document No.";
                    TransferReceiptHeaderTemp.Insert();
                end;
            until TransferReceiptLine.Next() = 0;
    end;

    procedure ApplyCreditNote(ClaimDocumentNo: Code[20]; PurchaseInvoiceNo: Code[20])
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", ClaimDocumentNo);

        if PurchaseHeader."Vendor Cr. Memo No." = '' then //PS-2638 +: It is the case when invoice has not been created when the entry was added
            //PurchaseHeader.Validate("Vendor Cr. Memo No.", GetNextVendorCRMemoNo(PurchaseInvoiceNo, PurchaseHeader."Buy-from Vendor No.")); //PS-2613 -
            PurchaseHeader.Validate("Vendor Cr. Memo No.", GetNextVendorCRMemoNo(PurchaseInvoiceNo, PurchaseHeader."Pay-to Vendor No.")); //PS-2613 +
        PurchaseHeader.Validate("Applies-to Doc. Type", PurchaseHeader."Applies-to Doc. Type"::Invoice);
        PurchaseHeader.Validate("Applies-to Doc. No.", PurchaseInvoiceNo);
        PurchaseHeader.Modify(true);

        // Commit to ensure the "Vendor Cr. Memo No." is committed to the purchase header
        Commit();
    end;

    procedure MissingVendorUllagedStatusErrorText(): Text
    begin
        EXIT(VendorUllagedStatusMustBeProvidedMsg);
    end;

    procedure PostSendClaims(VendorNo: Code[20]) DoPostSendClaims: Boolean
    var
        Vendor: Record Vendor;
        IntegrationSetup: Record "GXL Integration Setup";
    begin
        Vendor.Get(VendorNo);

        CASE Vendor."GXL Post / Send Claims" OF
            Vendor."GXL Post / Send Claims"::Default:
                begin
                    IntegrationSetup.Get();
                    DoPostSendClaims := IntegrationSetup."Post / Send Claims" = IntegrationSetup."Post / Send Claims"::Enabled;
                end;
            Vendor."GXL Post / Send Claims"::Disabled:
                DoPostSendClaims := false;
            Vendor."GXL Post / Send Claims"::Enabled:
                DoPostSendClaims := true;
        end;
    end;

    //PS-2638 + Set global access
    procedure GetNextVendorCRMemoNo(VendorCreditMemoNo: Code[35]; VendorNo: Code[20]) NextCrMemoNo: Code[35]
    var
        //MiscUtils: Codeunit "GXL Misc. Utilities";
        PurchHeadTemp: Record "Purchase Header" temporary;
        LastCrMemoNo: Code[35];
        i: Integer;
    begin
        //PS-2638 +
        //It won't work if the credit/return order was not posted in sequence
        // NextCrMemoNo := VendorCreditMemoNo + '_000';
        // NextCrMemoNo := MiscUtils.GetNextVendorCRMemoNoPH(NextCrMemoNo, VendorNo);
        // NextCrMemoNo := MiscUtils.GetNextVendorCRMemoNoVLE(NextCrMemoNo, VendorNo);

        PurchHeadTemp.Reset();
        PurchHeadTemp.DeleteAll();

        LastCrMemoNo := GetLastCrMemoNoVLE(VendorNo, VendorCreditMemoNo);
        if LastCrMemoNo <> '' then begin
            i += 1;
            PurchHeadTemp.Init();
            PurchHeadTemp."No." := Format(i);
            PurchHeadTemp."Vendor Cr. Memo No." := LastCrMemoNo;
            PurchHeadTemp.Insert();
        end;
        LastCrMemoNo := GetLastCrMemoNoPH(VendorNo, VendorCreditMemoNo, 0); //Credit Memo
        if LastCrMemoNo <> '' then begin
            i += 1;
            PurchHeadTemp.Init();
            PurchHeadTemp."No." := Format(i);
            PurchHeadTemp."Vendor Cr. Memo No." := LastCrMemoNo;
            PurchHeadTemp.Insert();
        end;
        LastCrMemoNo := GetLastCrMemoNoPH(VendorNo, VendorCreditMemoNo, 1); //Return Order
        if LastCrMemoNo <> '' then begin
            i += 1;
            PurchHeadTemp.Init();
            PurchHeadTemp."No." := Format(i);
            PurchHeadTemp."Vendor Cr. Memo No." := LastCrMemoNo;
            PurchHeadTemp.Insert();
        end;

        PurchHeadTemp.Reset();
        PurchHeadTemp.SetCurrentKey("Vendor Cr. Memo No.");
        if PurchHeadTemp.FindLast() then
            NextCrMemoNo := PurchHeadTemp."Vendor Cr. Memo No."
        else
            NextCrMemoNo := VendorCreditMemoNo + '_000';
        NextCrMemoNo := IncStr(NextCrMemoNo);
        PurchHeadTemp.DeleteAll();
        //PS-2638 -

    end;

    //PS-2638 +
    procedure VendCrMemoNoExist(VendorNo: Code[20]; CreditMemoNo: Code[35]): Boolean
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.SetCurrentKey("External Document No.");
        VendLedgEntry.SetRange("External Document No.", CreditMemoNo);
        VendLedgEntry.SetRange("Vendor No.", VendorNo);
        VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");
        if VendLedgEntry.IsEmpty then
            exit(false)
        else
            exit(true);
    end;

    procedure GetLastCrMemoNoVLE(VendorNo: Code[20]; PurchInvoiceNo: Code[20]): Code[35]
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgEntry.SetCurrentKey("External Document No.");
        VendLedgEntry.SetFilter("External Document No.", PurchInvoiceNo + '_' + '*');
        VendLedgEntry.SetRange("Vendor No.", VendorNo);
        VendLedgEntry.SetRange("Document Type", VendLedgEntry."Document Type"::"Credit Memo");
        VendLedgEntry.SetRange(Reversed, false);
        if VendLedgEntry.FindLast() then
            exit(VendLedgEntry."External Document No.")
        else
            exit('');
    end;

    procedure GetLastCrMemoNoPH(VendorNo: Code[20]; PurchInvoiceNo: Code[20]; DocType: Option "Credit Memo","Return Order"): Code[35]
    var
        PurchHead: Record "Purchase Header";
    begin
        PurchHead.SetCurrentKey("Vendor Cr. Memo No.");
        PurchHead.SetFilter("Vendor Cr. Memo No.", PurchInvoiceNo + '_' + '*');
        PurchHead.SetRange("Pay-to Vendor No.", VendorNo);
        if DocType = DocType::"Credit Memo" then
            PurchHead.SetRange("Document Type", PurchHead."Document Type"::"Credit Memo");
        if DocType = DocType::"Return Order" then
            PurchHead.SetRange("Document Type", PurchHead."Document Type"::"Return Order");
        if PurchHead.FindLast() then
            exit(PurchHead."Vendor Cr. Memo No.")
        else
            exit('');
    end;

    procedure UpdatePurchaseCrMemoNo(var PurchaseHeader: Record "Purchase Header"; PurchInvoiceNo: Code[20]; OrderNo: Code[20]; var ModifyHeader: Boolean)
    var
        VendCrMemoNo: Code[35];
        UpdateCrMemoNo: Boolean;
    begin
        UpdateCrMemoNo := false;
        if PurchaseHeader."Vendor Cr. Memo No." <> '' then begin
            VendCrMemoNo := PurchaseHeader."Vendor Cr. Memo No.";
            if VendCrMemoNoExist(PurchaseHeader."Pay-to Vendor No.", VendCrMemoNo) then
                UpdateCrMemoNo := true;
        end else
            UpdateCrMemoNo := true;
        if UpdateCrMemoNo then begin
            VendCrMemoNo := PurchInvoiceNo;
            if VendCrMemoNo = '' then
                VendCrMemoNo := OrderNo;
            VendCrMemoNo := GetNextVendorCRMemoNo(VendCrMemoNo, PurchaseHeader."Pay-to Vendor No.");
            PurchaseHeader."Vendor Cr. Memo No." := VendCrMemoNo;
            ModifyHeader := true;
        end;
    end;
    //PS-2638 -

    //PS-2565 Missing MIM User ID +
    procedure SetMIMUserID(NewMIMUserID: Code[50])
    begin
        MIMUserID := NewMIMUserID;
    end;
    //PS-2565 Missing MIM User ID -

}