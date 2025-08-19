// 003 05.07.2025 KDU HP2-Sprint2 Uncommented TODO Code
codeunit 50350 "GXL Purchase Events Mgt."
{
    /*Change Log
        NAV9-11 Integrations: Sync to cancel NAV purchase order on purchase receipt
        001  05.04.2022  KDU  GX-202201 ERP-356 Send the order to vendor automatically once the document is released.
    */
    // 002  05.05.2022  PREM LCB-39 Enable multiple goods receipting against a Purchase Order. Non Trade PO only
    // 001  05.04.2022  KDU  GX-202201 ERP-356 Send the order to vendor automatically once the document is released.
    // >> HP2-Sprint2
    [EventSubscriber(ObjectType::Table, database::"Purchase Line", 'OnUpdateVATAmountsOnAfterSetFilters', '', true, true)]
    local procedure OnUpdateVATAmountsOnAfterSetFilters(var PurchaseLine: Record "Purchase Line"; var PurchaseLine2: Record "Purchase Line")
    begin
        PurchaseLine2.SuspendStatusCheck(PurchaseLine.GetSuspendedStatusCheck());
    end;
    // << HP2-Sprint2
    //#region "Purch-Post"
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostPurchaseDoc', '', true, true)]
    local procedure OnBeforePostPurchaseDoc(var PurchaseHeader: Record "Purchase Header")
    var
        PurchPostSingleInstance: Codeunit "GXL Purch-Post Single Instance";
        ExDoc: Record "EX Document"; // >> GX-202201 <<
        ErrTxt: Label 'PO %1 is in status %2.\You can not post against this PO.'; // >> GX-202201 <<
    begin
        // >> GX-202201
        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then begin
            IF NOT PurchaseHeader.IsTradePO(PurchaseHeader."No.") then begin
                PurchaseHeader.TestField(Status, PurchaseHeader.Status::Released);
                ExDoc.SetRange("Document Type", PurchaseHeader."Document Type");
                ExDoc.SetRange("Document No.", PurchaseHeader."No.");
                IF ExDoc.FindFirst() then begin
                    if ExDoc.Status in [ExDoc.Status::Active, ExDoc.Status::Inactive, ExDoc.Status::"Not released", ExDoc.Status::"On hold"] then
                        Error(ErrTxt, PurchaseHeader."No.", ExDoc.Status);
                end;
            end;
        end;
        // << GX-202201
        PurchPostSingleInstance.SetPurchaseHeader(PurchaseHeader);
    end;

    //ERP-NAV Master Data Management +
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterDivideAmount', '', false, false)]
    local procedure OnAfterDivideAmount(PurchHeader: Record "Purchase Header"; PurchLineQty: Decimal; QtyType: Option;
        var PurchLine: Record "Purchase Line"; var TempVATAmountLine: Record "VAT Amount Line"; var TempVATAmountLineRemainder: Record "VAT Amount Line")
    begin
        if PurchLineQty = 0 then begin
            PurchLine."GXL Gross Weight" := 0;
            PurchLine."GXL Cubage" := 0;
        end else begin
            if (PurchLineQty <> PurchLine.Quantity) then begin
                if PurchLine.Quantity <> 0 then begin
                    PurchLine."GXL Gross Weight" := Round(PurchLine."GXL Gross Weight" * PurchLineQty / PurchLine.Quantity, 0.00001);
                    PurchLine."GXL Cubage" := Round(PurchLine."GXL Cubage" * PurchLineQty / PurchLine.Quantity, 0.00001);
                end else begin
                    PurchLine."GXL Gross Weight" := 0;
                    PurchLine."GXL Cubage" := 0;
                end;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnRoundAmountOnBeforeIncrAmount', '', false, false)]
    local procedure OnRoundAmountOnBeforeIncrAmount(PurchaseHeader: Record "Purchase Header"; PurchLineQty: Decimal;
        var PurchaseLine: Record "Purchase Line"; var TotalPurchLine: Record "Purchase Line"; var TotalPurchLineLCY: Record "Purchase Line")
    begin
        Increment(TotalPurchLine."GXL Gross Weight", Round(PurchaseLine."GXL Gross Weight", 0.00001));
        Increment(TotalPurchLine."GXL Cubage", Round(PurchaseLine."GXL Cubage", 0.00001));
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchInvHeaderInsert', '', false, false)]
    local procedure OnBeforePurchInvHeaderInsert(var PurchInvHeader: Record "Purch. Inv. Header"; var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader.CalcFields("GXL Total Order Qty", "GXL Total Order Value");
        PurchInvHeader."GXL Total Order Qty" := PurchHeader."GXL Total Order Qty";
        PurchInvHeader."GXL Total Order Value" := PurchHeader."GXL Total Order Value";
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePurchRcptHeaderInsert', '', false, false)]
    local procedure OnBeforePurchRcptHeaderInsert(var PurchRcptHeader: Record "Purch. Rcpt. Header"; var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader.CalcFields("GXL Total Order Qty", "GXL Total Order Value");
        PurchRcptHeader."GXL Total Order Qty" := PurchaseHeader."GXL Total Order Qty";
        PurchRcptHeader."GXL Total Order Value" := PurchaseHeader."GXL Total Order Value";
    end;
    //ERP-NAV Master Data Management -


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPurchRcptLineInsert', '', true, true)]
    local procedure OnAfterPurchRcptLineInsert(PurchaseLine: Record "Purchase Line"; ItemLedgShptEntryNo: Integer)
    var
        PurchHead: Record "Purchase Header";
        EDIClaimEntry: Record "GXL EDI Claim Entry";
        PurchPostSingleInstance: Codeunit "GXL Purch-Post Single Instance";
    begin
        PurchPostSingleInstance.GetPurchaseHeader(PurchHead);
        if PurchHead."GXL EDI Order" then begin
            EDIClaimEntry.Reset();
            EDIClaimEntry.SetCurrentKey("Purchase Order No.", "Purchase Order Line No.");
            EDIClaimEntry.SetRange("Purchase Order No.", PurchaseLine."Document No.");
            EDIClaimEntry.SetRange("Purchase Order Line No.", PurchaseLine."Line No.");
            if EDIClaimEntry.FindSet() then
                repeat
                    EDIClaimEntry."Receipt Item Ledger Entry No." := ItemLedgShptEntryNo;
                    EDIClaimEntry.Modify();
                until EDIClaimEntry.Next() = 0;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeFinalizePosting', '', true, true)]
    local procedure OnBeforeFinalizePosting(var PurchaseHeader: Record "Purchase Header"; var TempPurchLineGlobal: Record "Purchase Line" temporary; var EverythingInvoiced: Boolean; CommitIsSupressed: Boolean; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        SCOrderStatusMgt: Codeunit "GXL SC-Purch. Order Status Mgt";
    begin
        //PS-1807 +
        if EverythingInvoiced then
            exit;

        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then
            if PurchaseHeader.Invoice then
                if PurchaseHeader.GXL_PurchaseOrderCanBeCompleted(PurchaseHeader) then
                    EverythingInvoiced := true;
        //PS-1807 -

        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then //PS-2565 Missing MIM User ID +
            PurchaseHeader."GXL MIM User ID" := ''; //PS-2046 +

        if (not EverythingInvoiced) and (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order) then begin
            if PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Closed then
                SCOrderStatusMgt.SuspendCheckClosed(true);
            SCOrderStatusMgt.CloseWithoutModify(PurchaseHeader);
        end;

    end;

    // >> Upgrade
    /*
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', true, true)]
    local procedure OnAfterFinalizePostingOnBeforeCommit_PurchPost(var PurchHeader: Record "Purchase Header"; PreviewMode: Boolean)
    var
        InsertCancelNAVOrderLog: Codeunit "GXL Insert Cancel NAVOrder Log";
    begin
        //PS-1807 +
        if PreviewMode then
            exit;

        if PurchHeader."Document Type" = PurchHeader."Document Type"::Order then
            if PurchHeader.Invoice then begin
                if PurchHeader.Get(PurchHeader."Document Type", PurchHeader."No.") then
                    if PurchHeader.GXL_PurchaseOrderCanBeCompleted(PurchHeader) then begin
                        PurchHeader.SetHideValidationDialog(true);
                        PurchHeader.SuspendStatusCheck(true);
                        PurchHeader.Delete(true);
                    end;

            end;
        //PS-1807 -
        */
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterFinalizePostingOnBeforeCommit', '', true, true)]
    local procedure OnAfterFinalizePostingOnBeforeCommit_PurchPost(var PurchHeader: Record "Purchase Header"; PurchRcptHeader: Record "Purch. Rcpt. Header"; PurchInvHeader: Record "Purch. Inv. Header"; PreviewMode: Boolean)
    var
        IncomingDoc: Record "Incoming Document";
        DocumentAttachment: Record "Document Attachment";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        InsertCancelNAVOrderLog: Codeunit "GXL Insert Cancel NAVOrder Log";
        //IncomingDocOverview: Record "Inc. Doc. Attachment Overview";
        IncomingDocEntryNo: Integer;
        InstreamL: InStream;
    begin
        //PS-1807 +
        if PreviewMode then
            exit;

        if PurchHeader."Document Type" = PurchHeader."Document Type"::Order then
            if PurchHeader.Invoice then begin
                if PurchHeader.Get(PurchHeader."Document Type", PurchHeader."No.") then
                    if PurchHeader.GXL_PurchaseOrderCanBeCompleted(PurchHeader) then begin
                        IncomingDocEntryNo := PurchHeader."Incoming Document Entry No.";
                        if IncomingDocEntryNo > 0 then begin
                            if IncomingDoc.get(IncomingDocEntryNo) then begin
                                IncomingDocumentAttachment.SetAutoCalcFields(Content);
                                IncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDoc."Entry No.");
                                //IncomingDocumentAttachment.SetRange("Main Attachment", true);
                                if IncomingDocumentAttachment.FindSet() then
                                    repeat
                                        Clear(InstreamL);
                                        DocumentAttachment.Init();
                                        DocumentAttachment.Validate("Table ID", PurchInvHeader.RecordId.TableNo());
                                        DocumentAttachment.Validate("No.", PurchInvHeader."No.");
                                        DocumentAttachment.Validate("Document Type", DocumentAttachment."Document Type"::Invoice);
                                        DocumentAttachment."Line No." := IncomingDocumentAttachment."Line No.";
                                        DocumentAttachment.ID := 0;
                                        IncomingDocumentAttachment.Content.CreateInStream(InstreamL);
                                        DocumentAttachment."Document Reference ID".ImportStream(InstreamL, IncomingDocumentAttachment.Name);
                                        DocumentAttachment.Insert(true);
                                    until IncomingDocumentAttachment.Next() = 0;

                                IncomingDoc.Posted := false;
                                IncomingDoc.Status := IncomingDoc.Status::New;
                                IncomingDoc.Modify();
                                IncomingDoc.Delete(true);
                            end;
                        end;
                        PurchHeader."Incoming Document Entry No." := 0;
                        PurchHeader.Modify();

                        PurchHeader.SetHideValidationDialog(true);
                        PurchHeader.SuspendStatusCheck(true);
                        PurchHeader.Delete(true);
                    end;
            end;
        // << Upgrade
        //NAV9-11+
        // >> 002
        //if (PurchHeader."Document Type" = PurchHeader."Document Type"::Order) and PurchHeader.Receive then
        if (PurchHeader."Document Type" = PurchHeader."Document Type"::Order) and PurchHeader.Receive AND (PurchHeader.IsTradePO(PurchHeader."No.")) then
            // << 002
            InsertCancelNAVOrderLog.CancelNAVPurchaseOrder(PurchHeader);
        //NAV9-11-
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforePostUpdateOrderLineModifyTempLine', '', true, true)]
    local procedure OnBeforePostUpdateOrderLineModifyTempLine(var TempPurchaseLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header")
    begin
        //reach to this trigger means Not EverythingInvoided
        if (PurchHeader."Document Type" = PurchHeader."Document Type"::Order) then
            if TempPurchaseLine."Qty. to Receive" <> 0 then begin
                TempPurchaseLine."Qty. to Receive" := 0;
                TempPurchaseLine."Qty. to Receive (Base)" := 0;
                TempPurchaseLine.InitQtyToInvoice();
            end;
    end;

    //PS-2046+
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeItemJnlPostLine', '', true, true)]
    local procedure OnBeforeItemJnlPostLine(var ItemJournalLine: Record "Item Journal Line"; PurchaseHeader: Record "Purchase Header")
    begin
        ItemJournalLine."GXL MIM User ID" := PurchaseHeader."GXL MIM User ID";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterRestorePurchaseHeader', '', true, true)]
    local procedure OnAfterRestorePurchaseHeader(PurchaseHeaderCopy: Record "Purchase Header"; var PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader."GXL MIM User ID" := PurchaseHeaderCopy."GXL MIM User ID";
    end;
    //PS-2046-

    // >> LCB-225
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnBeforeValidatePostingAndDocumentDate', '', true, true)]
    local procedure CheckAndCorrectInventoryClosingError(var PurchaseHeader: Record "Purchase Header")
    var
        InventoryPeriod: Record "Inventory Period";
    begin
        if (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo") or
           (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order") then begin
            InventoryPeriod.SetRange(Closed, true);
            if InventoryPeriod.FindLast() then begin
                if PurchaseHeader."Posting Date" > InventoryPeriod."Ending Date" then
                    exit;

                PurchaseHeader.Validate("Posting Date", InventoryPeriod."Ending Date" + 1);
            end;
        end;
    end;
    // << LCB-225

    //ERP-NAV Master Data Management +
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchaseDoc', '', false, false)]
    local procedure OnAfterPostPurchaseDoc(var PurchaseHeader: Record "Purchase Header"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        PurchCrMemoHdrNo: Code[20]; PurchInvHdrNo: Code[20]; PurchRcpHdrNo: Code[20]; RetShptHdrNo: Code[20]; CommitIsSupressed: Boolean)
    var
        GXLPDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        PurchaseLine: Record "Purchase Line";
    begin
        IF GuiAllowed then begin    // >> LCB-308 <<

            if (RetShptHdrNo = '') AND (PurchCrMemoHdrNo = '') then
                exit;

            case PurchaseHeader."Document Type" of
                PurchaseHeader."Document Type"::"Credit Memo":
                    GXLPDAPLReceiveBuffer.SetRange("Claim Document Type", GXLPDAPLReceiveBuffer."Claim Document Type"::"Credit Memo");
                PurchaseHeader."Document Type"::"Return Order":
                    GXLPDAPLReceiveBuffer.SetRange("Claim Document Type", GXLPDAPLReceiveBuffer."Claim Document Type"::"Return Order");
            end;

            PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
            if PurchaseLine.FindSet() then
                repeat
                    GXLPDAPLReceiveBuffer.SetRange("Claim Document No.", PurchaseHeader."No.");
                    GXLPDAPLReceiveBuffer.SetRange("Receipt Type", GXLPDAPLReceiveBuffer."Receipt Type"::Full);
                    if GXLPDAPLReceiveBuffer.IsEmpty then begin
                        GXLPDAPLReceiveBuffer.SetRange("Receipt Type");
                        GXLPDAPLReceiveBuffer.SetRange("Claim Document Line No.", PurchaseLine."Line No.");
                        GXLPDAPLReceiveBuffer.SetRange("No.", PurchaseLine."No.");
                    end;
                    if GXLPDAPLReceiveBuffer.FindSet() then
                        repeat

                            if GXLPDAPLReceiveBuffer.Status IN [GXLPDAPLReceiveBuffer.Status::"Credit Posting Error", GXLPDAPLReceiveBuffer.Status::"Return Shipment Posting Error"] then begin
                                if PurchCrMemoHdrNo > '' then begin
                                    GXLPDAPLReceiveBuffer.Validate(Status, GXLPDAPLReceiveBuffer.Status::"Credit Posted");
                                    GXLPDAPLReceiveBuffer.Validate(Processed, true);
                                end else
                                    if RetShptHdrNo > '' then
                                        GXLPDAPLReceiveBuffer.Validate(Status, GXLPDAPLReceiveBuffer.Status::"Return Shipment Posted");

                                GXLPDAPLReceiveBuffer."Error Code" := '';
                                GXLPDAPLReceiveBuffer."Error Message" := '';
                                GXLPDAPLReceiveBuffer.Modify(true);
                            end;
                        until GXLPDAPLReceiveBuffer.Next() = 0;
                until PurchaseLine.Next() = 0;

        end;    // >> LCB-308 <<
                // << LCB-225
        if not CommitIsSupressed then
            Commit();
        // >> LCB-308
        /*
        if ((RetShptHdrNo <> '') or (PurchCrMemoHdrNo <> '')) and (PurchaseHeader."Send Email to Vendor") then
            EmailPurchaseCreditOrReturnOrder(PurchCrMemoHdrNo, RetShptHdrNo);
        */
        // << LCB-308
        //ERP-NAV Master Data Management: Automate IC Transaction
        AutomateICTransactions(PurchaseHeader, PurchInvHdrNo, PurchCrMemoHdrNo);

    end;
    //ERP-NAV Master Data Management -

    //#end region "Purch-Post"


    //#region "Release Purchase Document"
    [EventSubscriber(ObjectType::Codeunit, CodeUnit::"Release Purchase Document", 'OnAfterReopenPurchaseDoc', '', true, true)]
    local procedure RPDOnAfterReopenPurchaseDoc(VAR PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    var
        Modified: Boolean;
    begin
        if PreviewMode then
            exit;
        if (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order) AND
            (PurchaseHeader."GXL Order Status" <> PurchaseHeader."GXL Order Status"::Closed) then begin
            //TODO: Order Status - Release Purchase Document -> Reopen status is reset to New
            //PS-2590 +
            PurchaseHeader.validate("GXL Order Status", PurchaseHeader."GXL Order Status"::New);
            //PS-2590 -
            PurchaseHeader."GXL Expired Order" := false;
            Modified := true;
            // TODO International/Domestic PO - Not needed for now
            // >> 003
            if (PurchaseHeader."GXL International Order") AND PurchaseHeader."GXL Send to Freight Forwarder" then begin
                PurchaseHeader.Validate("GXL Send to Freight Forwarder", false);
                Modified := true;
            end;
            PurchaseHeader.Validate("GXL 3PL File Sent", false);
            PurchaseHeader.Validate("GXL 3PL File Sent Date", 0D);
            // << 003
        end;
        if Modified then
            PurchaseHeader.Modify(true);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnCodeOnBeforeModifyHeader', '', true, true)]
    local procedure OnCodeOnBeforeModifyHeader_ReleasePurchDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean)
    begin
        if PreviewMode then
            exit;
        if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then begin
            //TODO: Order Status: temporary set to Confirmed as PO is imported from confirmed PO
            // >> 003 TODO code uncommented and commented old code
            if PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::New then
                PurchaseHeader."GXL Order Status" := PurchaseHeader."GXL Order Status"::Created;
            if PurchaseHeader."Vendor Order No." = '' then
                PurchaseHeader."Vendor Order No." := PurchaseHeader."No.";
            // if PurchaseHeader."GXL Order Status" in [PurchaseHeader."GXL Order Status"::New,
            //     PurchaseHeader."GXL Order Status"::Created, PurchaseHeader."GXL Order Status"::Placed] then begin
            //     PurchaseHeader."GXL Order Status" := PurchaseHeader."GXL Order Status"::Confirmed;
            // end;
            // << 003
        end;
    end;
    //#end region "Release Purchase Document"

    //#region "Purchase Header"
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterInitRecord', '', true, true)]
    local procedure OnAfterInitRecord_PurchaseHeader(var PurchHeader: Record "Purchase Header")
    begin
        PurchHeader.GXL_InitSupplyChain();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCopyBuyFromVendorFieldsFromVendor', '', true, true)]
    local procedure PHOnAfterCopyBuyFromVendorFieldsFromVendor(VAR PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor; xPurchaseHeader: Record "Purchase Header")
    begin

        //TODO: International/Domestic PO - Not needed for now - only turn it on if page for international order created 
        // >> 003
        IF PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order THEN
            Vendor.TESTFIELD("GXL Import Flag", PurchaseHeader."GXL International Order");
        // << 003
        PurchaseHeader."GXL International Order" := Vendor."GXL Import Flag";
        // TODO International/Domestic PO - Not needed for now
        PurchaseHeader."GXL Domestic Order" := NOT Vendor."GXL Import Flag"; // >> 003 <<
        // ERP-NAV Master Data Management +
        if PurchaseHeader."GXL International Order" AND (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order) then begin
            PurchaseHeader."GXL Incoterms Code" := Vendor."GXL Incoterms Code";
            PurchaseHeader."GXL Import Agent Number" := Vendor."GXL Agent Number";
            PurchaseHeader."GXL Shipment Load Type" := Vendor."GXL Shipment Load Type";
            PurchaseHeader."GXL Departure Port" := Vendor."GXL Port of Loading";
        end;

        IF (Vendor."GXL Import Flag") AND
            (Vendor."GXL Freight Forwarder Code" <> '')
        THEN
            PurchaseHeader.VALIDATE("GXL Freight Forwarder Code", Vendor."GXL Freight Forwarder Code");
        //ERP-NAV Master Data Management -

        PurchaseHeader."GXL EDI Order in Out. Pack UoM" := Vendor."GXL EDI Order in Out. Pack UoM";

        IF Vendor."GXL EDI Vendor Type" IN [Vendor."GXL EDI Vendor Type"::"Point 2 Point", Vendor."GXL EDI Vendor Type"::"Point 2 Point Contingency"] THEN
            PurchaseHeader."GXL Vendor File Exchange" := TRUE;
        PurchaseHeader."GXL EDI Vendor Type" := Vendor."GXL EDI Vendor Type";
        PurchaseHeader."GXL EDI Order" := Vendor."GXL EDI Flag";

    end;
    //#end region "Purchase Header"

    /// #region "Purchase Line"
    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterInitOutstandingQty', '', true, true)]
    local procedure PLOnAfterInitOutstandingQty(VAR PurchaseLine: Record "Purchase Line")
    begin
        PurchaseLine.InitSupplyChainQuantities();
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemValues', '', true, true)]
    local procedure PLOnAfterAssignItemValues(VAR PurchLine: Record "Purchase Line"; Item: Record Item)
    var
        PurchHeader: Record "Purchase Header";
        ItemSupplier: Record "GXL EDI Item Supplier";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
    begin
        //Legacy Item
        if PurchLine."Unit of Measure Code" = '' then
            PurchLine."GXL Legacy Item No." := PurchLine."No."
        else
            LegacyItemHelpers.GetLegacyItemNo(PurchLine."No.", PurchLine."Unit of Measure Code", PurchLine."GXL Legacy Item No.");

        PurchHeader.Get(PurchLine."Document Type", PurchLine."Document No.");
        IF ((PurchHeader."Buy-from Vendor No." <> '') AND PurchHeader."GXL EDI Order") THEN BEGIN
            //IF ItemSupplier.GET(PurchLine."No.", PurchHeader."Buy-from Vendor No.") THEN
            if ItemSupplier.Get(PurchLine."GXL Legacy Item No.", PurchHeader."Buy-from Vendor No.") then
                PurchLine.VALIDATE("GXL Primary EAN", ItemSupplier.GTIN);
        END;

    end;


    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignItemUOM', '', true, true)]
    local procedure PLOnAfterAssignItemUOM(var PurchLine: Record "Purchase Line"; Item: Record Item)
    var
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
    begin
        //Legacy Item
        if PurchLine."Unit of Measure Code" = '' then
            PurchLine."GXL Legacy Item No." := PurchLine."No."
        else
            LegacyItemHelpers.GetLegacyItemNo(PurchLine."No.", PurchLine."Unit of Measure Code", PurchLine."GXL Legacy Item No.");

        //ERP-NAV Master Data Management +
        PurchLine."GXL Gross Weight" := Item."Gross Weight" * PurchLine."Qty. per Unit of Measure";
        PurchLine."GXL Cubage" := Item."Unit Volume" * PurchLine."Qty. per Unit of Measure";
        //ERP-NAV Master Data Management -
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignHeaderValues', '', true, true)]
    local procedure PLOnAfterAssignHeaderValues(VAR PurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header")
    begin
        PurchLine.UpdateBarCodes();
    end;
    //#end region "Purchase Line"

    //ERP-NAV Master Data Management +
    local procedure Increment(var Number: Decimal; Number2: Decimal)
    begin
        Number := Number + Number2;
    end;

    local procedure EmailPurchaseCreditOrReturnOrder(PurchCrMemoHdrNo: Code[20]; RetShptHdrNo: Code[20])
    var
        //ReturnShptHeader: Record "Return Shipment Header";
        PurchCrMemoHead: Record "Purch. Cr. Memo Hdr.";
        EmailManagement: Codeunit "GXL Email Management";
    begin
        if (RetShptHdrNo = '') and (PurchCrMemoHdrNo = '') then
            exit;

        // >> LCB-13
        // if RetShptHdrNo <> '' then begin
        //     if ReturnShptHeader.Get(RetShptHdrNo) then
        //         if EmailManagement.ISPostingVendorSendEmail(
        //             5, ReturnShptHeader."Buy-from Vendor No.", ReturnShptHeader."Pay-to Vendor No.",
        //             ReturnShptHeader."Buy-from Contact No.", ReturnShptHeader."Pay-to Contact No.", false, 1) then begin
        //             Commit();
        //             EmailManagement.SendPurchReturnShipment(ReturnShptHeader, false, false, 1);
        //         end;
        // end;
        // << LCB-13

        if PurchCrMemoHdrNo <> '' then begin
            if PurchCrMemoHead.Get(PurchCrMemoHdrNo) then
                if EmailManagement.IsPostingVendorSendEmail(
                    6, PurchCrMemoHead."Buy-from Vendor No.", PurchCrMemoHead."Pay-to Vendor No.",
                    PurchCrMemoHead."Buy-from Contact No.", PurchCrMemoHead."Pay-to Contact No.", false, 1) then begin
                    Commit();
                    EmailManagement.SendPurchCRADJNote(PurchCrMemoHead, false, false, 1);
                end;
        end;
    end;
    //ERP-NAV Master Data Management -

    /// <summary>
    /// ERP-NAV Master Data Management: Automate IC Transaction
    /// </summary>
    /// <param name="PurchHeader"></param>
    /// <param name="PurchInvHdrNo"></param>
    /// <param name="PurchCrMemoHdrNo"></param>
    local procedure AutomateICTransactions(var PurchHeader: Record "Purchase Header"; PurchInvHdrNo: Code[20]; PurchCrMemoHdrNo: Code[20])
    var
        AutoExportICTrans: Codeunit "GXL Auto Export IC Trans";
    begin
        case PurchHeader."Document Type" of
            PurchHeader."Document Type"::Order:
                AutoExportICTrans.ProcessPurchDocument(PurchInvHdrNo, PurchHeader."No.");
            PurchHeader."Document Type"::Invoice:
                AutoExportICTrans.ProcessPurchDocument(PurchInvHdrNo, '');
            PurchHeader."Document Type"::"Credit Memo":
                AutoExportICTrans.ProcessPurchDocument(PurchCrMemoHdrNo, '');
            PurchHeader."Document Type"::"Return Order":
                AutoExportICTrans.ProcessPurchDocument(PurchCrMemoHdrNo, PurchHeader."No.");
        end;
    end;
    // >> 001 GX-202201
    /*
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Release Purchase Document", 'OnAfterReleasePurchaseDoc', '', false, false)]
    local procedure OnAfterReleasePurchaseDoc(var PurchaseHeader: Record "Purchase Header"; PreviewMode: Boolean; var LinesWereModified: Boolean)
    var
        ReportSelections: Record "Report Selections";
        DocumentSendingProfile: Record "Document Sending Profile";
        ExDoc: Record "EX Document";
        DocTxt: Text;
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            exit;
        if PurchaseHeader.IsTradePO(PurchaseHeader."No.") then
            exit;
        ExDoc.SetRange("Document Type", PurchaseHeader."Document Type");
        ExDoc.SetRange("Document No.", PurchaseHeader."No.");
        if ExDoc.FindFirst() then begin
            ExDoc.Status := ExDoc.Status::Approved;
            ExDoc.Modify();
        end;
        if PurchaseHeader."GXL No. Emailed" < 1 then begin
            PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchaseHeader.SetRange("No.", PurchaseHeader."No.");
            GetReportSelectionsUsageFromDocumentType(ReportSelections.Usage, DocTxt, PurchaseHeader);
            DocumentSendingProfile.SendVendorRecords(
                ReportSelections.Usage, PurchaseHeader, DocTxt, PurchaseHeader."Buy-from Vendor No.", PurchaseHeader."No.",
                PurchaseHeader.FIELDNO("Buy-from Vendor No."), PurchaseHeader.FIELDNO("No."));
        end;
    end;

    LOCAL procedure GetReportSelectionsUsageFromDocumentType(VAR ReportSelectionsUsage: Option; VAR DocTxt: Text[150]; var PurchHeader: Record "Purchase Header")
    var
        ReportSelections: Record "Report Selections";
    begin
        CASE PurchHeader."Document Type" OF
            PurchHeader."Document Type"::Order:
                BEGIN
                    ReportSelectionsUsage := ReportSelections.Usage::"P.Order";
                    DocTxt := PurchOrderDocTxt;
                END;
            PurchHeader."Document Type"::Quote:
                BEGIN
                    ReportSelectionsUsage := ReportSelections.Usage::"P.Quote";
                    DocTxt := PurchQuoteDocTxt;
                END;
        END;
    end;

    var
        PurchOrderDocTxt: Label 'Purchase Order';
        PurchQuoteDocTxt: Label 'Purchase Quote';
    */
    // >> LCB-50
    /*
        [EventSubscriber(ObjectType::Table, database::"EX Document", 'OnAfterInsertEvent', '', true, true)]
        local procedure EX_Document_OnAfterInsertEvent(var Rec: Record "EX Document"; RunTrigger: Boolean)
        begin
            EXIT;
            CheckAndSendPO(Rec);
        end;

        [EventSubscriber(ObjectType::Table, database::"EX Document", 'OnAfterModifyEvent', '', true, true)]
        local procedure EX_Document_OnAfterModifyEvent(var Rec: Record "EX Document"; var xRec: Record "EX Document"; RunTrigger: Boolean)
        begin
            EXIT;
            CheckAndSendPO(Rec);
        end;
    local procedure CheckAndSendPO(var ExDoc: Record "EX Document")
    var
        PurchHdr: Record "Purchase Header";
    begin
        EXIT;
        if ExDoc."Document Type" <> ExDoc."Document Type"::Order then
            exit;
        if ExDoc.Status <> ExDoc.Status::Approved then
            exit;
        if not PurchHdr.Get(PurchHdr."Document Type"::Order, ExDoc."Document No.") then
            exit;
        if PurchHdr.Status <> PurchHdr.Status::Released then
            exit;
        if PurchHdr.IsTradePO(PurchHdr."No.") then
            exit;
        if PurchHdr."GXL No. Emailed" > 1 then
            exit;
        SendPOEmailOnApproval(ExDoc."Document No.");
    end;

    local procedure SendPOEmailOnApproval(PONo: COde[20])
    var
        PurchaseHeader: Record "Purchase Header";
        ReportSelection: Record "Report Selections";
        GXLDocumentEmailSetup: Record "GXL Document Email Setup";
        ReportLayoutSelection: Record "Report Layout Selection";
        CustomReportLayoutSelection: Record "Custom Report Selection";
        Vendor: Record Vendor;
        SmtpSetup: Record "SMTP Mail Setup";
        TempBlob: Record TempBlob;
        SmtpMail: Codeunit "SMTP Mail";
        FileExt: Text;
        OutStr: OutStream;
        InStr: InStream;
        SubjectTxt: Text;
        EmailBody: Text;
        EmailRecpients: Text[80];
        ReportTitleLbl: Label 'Purchase Order';
        ReportFilterTxt: Label '<?xml version="1.0" standalone="yes"?><ReportParameters name="Order" id="405"><Options><Field name="NoOfCopies">0</Field><Field name="ShowInternalInfo">false</Field><Field name="ArchiveDocument">false</Field><Field name="LogInteraction">false</Field></Options><DataItems><DataItem name="Purchase Header">VERSION(1) SORTING(Field1,Field3) WHERE(Field1=1(1),Field3=1(%1),Field2=1(%2))</DataItem><DataItem name="CopyLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="PageLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="DimensionLoop1">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Purchase Line">VERSION(1) SORTING(Field1,Field3,Field4)</DataItem><DataItem name="RoundLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="DimensionLoop2">VERSION(1) SORTING(Field1)</DataItem><DataItem name="VATCounter">VERSION(1) SORTING(Field1)</DataItem><DataItem name="VATCounterLCY">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Total">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Total2">VERSION(1) SORTING(Field1)</DataItem><DataItem name="Total3">VERSION(1) SORTING(Field1)</DataItem><DataItem name="PrepmtLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="PrepmtDimLoop">VERSION(1) SORTING(Field1)</DataItem><DataItem name="PrepmtVATCounter">VERSION(1) SORTING(Field1)</DataItem><DataItem name="PrepmtTotal">VERSION(1) SORTING(Field1)</DataItem></DataItems></ReportParameters>', Comment = '%1,%2';
    begin
        exit;
        if not PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PONo) then
            exit;

        SmtpSetup.Get();

        if GXLDocumentEmailSetup.Get('', GXLDocumentEmailSetup."Document Type"::"Purchase Order") then begin
            SubjectTxt := GXLDocumentEmailSetup."Email Subject";
            EmailBody := GXLDocumentEmailSetup.GetEmailBody();
            if GXLDocumentEmailSetup."Email From / To" = GXLDocumentEmailSetup."Email From / To"::"Sell-to / Buy-from" then begin
                if not Vendor.Get(PurchaseHeader."Buy-from Vendor No.") then
                    exit;
                EmailRecpients := Vendor."E-Mail";
            end else
                if Vendor.Get(PurchaseHeader."Pay-to Vendor No.") then
                    EmailRecpients := Vendor."E-Mail";
        end else begin
            SubjectTxt := ReportTitleLbl;
            EmailBody := '';
            if Vendor.Get(PurchaseHeader."Buy-from Vendor No.") then
                EmailRecpients := Vendor."E-Mail";
        end;

        CustomReportLayoutSelection.SetRange("Source Type", 23);
        CustomReportLayoutSelection.SetRange("Source No.", Vendor."No.");
        if CustomReportLayoutSelection.FindFirst() then
            if CustomReportLayoutSelection."Report ID" > 0 then begin
                ReportSelection."Report ID" := CustomReportLayoutSelection."Report ID";
                ReportSelection."Custom Report Layout Code" := CustomReportLayoutSelection."Custom Report Layout Code";
                ReportSelection."Email Body Layout Code" := CustomReportLayoutSelection."Email Body Layout Code";
                if CustomReportLayoutSelection."Send To Email" > '' then
                    EmailRecpients := CustomReportLayoutSelection."Send To Email";
            end;
        if ReportSelection."Report ID" = 0 then begin
            ReportSelection.SetRange(Usage, ReportSelection.Usage::"P.Order");
            if not ReportSelection.FindLast() then
                exit;
        end;
        TempBlob.Blob.CreateOutStream(OutStr);
        ReportLayoutSelection.SetTempLayoutSelected(ReportSelection."Email Body Layout Code");
        if not Report.SaveAs(ReportSelection."Report ID", StrSubstNo(ReportFilterTxt, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No."), ReportFormat::Html, OutStr) then
            exit;
        TempBlob.Blob.CreateInStream(InStr);
        InStr.Read(EmailBody);
        Clear(TempBlob);

        FileExt := 'pdf';
        if EmailRecpients = '' then
            exit;

        SmtpMail.CreateMessage(CompanyName, SmtpSetup."User ID", EmailRecpients, SubjectTxt, EmailBody, true);

        TempBlob.Blob.CreateOutStream(OutStr);
        ReportLayoutSelection.SetTempLayoutSelected(ReportSelection."Custom Report Layout Code");
        if not Report.SaveAs(ReportSelection."Report ID", StrSubstNo(ReportFilterTxt, PurchaseHeader."No.", PurchaseHeader."Buy-from Vendor No."), ReportFormat::Pdf, OutStr) then
            exit;

        TempBlob.Blob.CreateInStream(InStr);

        SmtpMail.AddAttachmentStream(InStr, ReportTitleLbl + '.pdf');
        if SmtpMail.TrySend() then begin
            //PurchaseHeader."GXL No. Emailed" += 1;
            //PurchaseHeader.modify();
        end;
    end;
    // << 001
    */
    // << LCB-50
    // >> LCB-13
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterCheckBuyFromVendor', '', false, false)]
    local procedure AssignSendEmailToVendor(var PurchaseHeader: Record "Purchase Header"; Vendor: Record Vendor)
    begin
        if (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo") or (PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Return Order") then
            PurchaseHeader."Send Email to Vendor" := Vendor."GXL Email On Posting";
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Line", 'OnAfterAssignFieldsForNo', '', false, false)]
    local procedure CheckAndUpdateSendEmailToVendor(var PurchLine: Record "Purchase Line"; var xPurchLine: Record "Purchase Line"; PurchHeader: Record "Purchase Header")
    var
        Vendor: Record Vendor;
    begin
        if (PurchLine."Document Type" = PurchLine."Document Type"::"Credit Memo") or (PurchLine."Document Type" = PurchLine."Document Type"::"Return Order") then begin
            if Vendor.Get(PurchHeader."Buy-From Vendor No.") and not Vendor."GXL Email On Posting" then
                exit;

            if PurchLine.Type = PurchLine.Type::"G/L Account" then begin
                if not PurchHeader."Send Email to Vendor" then
                    exit;
                PurchHeader."Send Email to Vendor" := false;
            end else begin
                if PurchHeader."Send Email to Vendor" then
                    exit;
                // if PurchHeader."Send Email to Vendor" = IsNonTradeCreditOrReturn(PurchHeader."No.") then
                //     exit;
                PurchHeader."Send Email to Vendor" := true;
            end;
            PurchHeader.Modify();
        end;
    end;

    procedure CheckAndUpdateSendEmailToVendorOnDeleteLine(PurchaseLine: Record "Purchase Line")
    var
        PurchaseHeader: Record "Purchase Header";
        Result: boolean;
    begin
        if not PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.") then
            exit;

        Result := IsNonTradeCreditOrReturn(PurchaseHeader."No.", PurchaseLine."Line No.");
        if PurchaseHeader."Send Email to Vendor" = Result then
            exit;

        PurchaseHeader."Send Email to Vendor" := Result;
        PurchaseHeader.modify();
    end;

    procedure IsNonTradeCreditOrReturn(DocumentNo: Code[20]; LineNo: Integer): boolean
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SetFilter("Document Type", '%1|%2', PurchaseLine."Document Type"::"Credit Memo", PurchaseLine."Document Type"::"Return Order");
        PurchaseLine.SetRange("Document No.", DocumentNo);
        PurchaseLine.SetFilter("Line No.", '<>%1', LineNo);
        PurchaseLine.SetRange(Type, PurchaseLine.Type::Item);
        if not PurchaseLine.IsEmpty() then
            exit(true);
        exit(false);
    end;
    // << LCB-13

    // >> LCB-227
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Purch.-Post", 'OnAfterPostPurchLine', '', true, true)]
    local procedure OnAfterPostPurchLine(var PurchaseLine: Record "Purchase Line"; var PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLineL: Record "Purchase Line";
        PdaReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        if PurchaseHeader."Document Type" <> PurchaseHeader."Document Type"::Order then
            exit;

        PurchaseLineL.CopyFilters(PurchaseLine);
        if PurchaseLineL.FindSet() then
            repeat
                PdaReceiveBuffer.SetCurrentKey("Entry Type", "Document No.", "Line No.", "No.");
                PdaReceiveBuffer.SetRange("Entry Type", PdaReceiveBuffer."Entry Type"::Purchase);
                PdaReceiveBuffer.SetRange("Document No.", PurchaseLineL."Document No.");
                PdaReceiveBuffer.SetRange("Receipt Type", PdaReceiveBuffer."Receipt Type"::Full);
                IF PdaReceiveBuffer.IsEmpty then begin
                    PdaReceiveBuffer.SetRange("Receipt Type");
                    PdaReceiveBuffer.SetRange("Line No.", PurchaseLineL."Line No.");
                    PdaReceiveBuffer.SetRange("No.", PurchaseLineL."No.");
                end;
                if PdaReceiveBuffer.FindSet() then
                    repeat
                        IF PdaReceiveBuffer.Status IN [PdaReceiveBuffer.Status::"Processing Error", PdaReceiveBuffer.Status::"Receiving Error", PdaReceiveBuffer.Status::"Invoice Posting Error"] then begin
                            if PurchaseHeader.Invoice then begin
                                PdaReceiveBuffer.Validate(Processed, true);
                                PdaReceiveBuffer.Validate(Status, PdaReceiveBuffer.Status::"Invoice Posted")
                            end else begin
                                PdaReceiveBuffer.Validate(Status, PdaReceiveBuffer.Status::Received);
                            end;
                            PdaReceiveBuffer.ClearError(PdaReceiveBuffer);
                        end;
                    until PdaReceiveBuffer.Next() = 0;
            until PurchaseLineL.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Shipment Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure OnAfterCopyFromTransferLine_Ship(var TransferShipmentLine: Record "Transfer Shipment Line"; TransferLine: Record "Transfer Line");
    var
        Status: Enum "GXL PDA-PL Receive Status";

    begin
        UpdatePdaReceivingStatusForTransferOrder(TransferLine, Status::Closed);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Transfer Receipt Line", 'OnAfterCopyFromTransferLine', '', false, false)]
    local procedure OnAfterCopyFromTransferLine_Receive(var TransferReceiptLine: Record "Transfer Receipt Line"; TransferLine: Record "Transfer Line");
    var
        Status: Enum "GXL PDA-PL Receive Status";
    begin
        UpdatePdaReceivingStatusForTransferOrder(TransferLine, Status::Closed);
    end;

    local procedure UpdatePdaReceivingStatusForTransferOrder(TransferLine: Record "Transfer Line"; StatusP: Enum "GXL PDA-PL Receive Status")
    var
        PdaReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
    begin
        PdaReceiveBuffer.SetCurrentKey("Entry Type", "Document No.", "Line No.", "No.");
        PdaReceiveBuffer.SetRange("Entry Type", PdaReceiveBuffer."Entry Type"::Transfer);
        PdaReceiveBuffer.SetRange("Document No.", TransferLine."Document No.");
        PdaReceiveBuffer.SetRange("Line No.", TransferLine."Line No.");
        PdaReceiveBuffer.SetRange("No.", TransferLine."Item No.");
        if PdaReceiveBuffer.FindSet() then
            repeat
                PdaReceiveBuffer.Validate(Status, StatusP);
                PdaReceiveBuffer."Error Code" := '';
                PdaReceiveBuffer."Error Message" := '';
                PdaReceiveBuffer.Errored := false;
                PdaReceiveBuffer.Modify(true);
            until PdaReceiveBuffer.Next() = 0;
    end;
    // << LCB-227
    // >> 003
    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnBeforeValidateOrderDate', '', false, false)]
    local procedure OnBeforeValidateOrderDate(var PurchaseHeader: Record "Purchase Header"; xPurchaseHeader: Record "Purchase Header"; var IsHandled: Boolean)
    begin
        // Onvalidate code was written in table extension.
        IsHandled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"Purchase Header", 'OnAfterGetNoSeriesCode', '', false, false)]
    local procedure OnAfterGetNoSeriesCode(var PurchHeader: Record "Purchase Header"; PurchSetup: Record "Purchases & Payables Setup"; var NoSeriesCode: Code[20])
    begin
        PurchSetup.Get();
        if (PurchHeader."Document Type" = PurchHeader."Document Type"::Order) and (PurchHeader."GXL International Order") then
            NoSeriesCode := PurchSetup."Import Order Nos.";
    end;
    // << 003
}