// LCB-3   25-09-2022  PREM pass Order No. as blank in parameter
codeunit 50269 "GXL Stock Adj. Process Handler"
{
    TableNo = "GXL PDA-StAdjProcessing Buffer";

    //This codeunit is used to handle claimable PDA stock adjustment
    //ProcessWhich= ,Create Claim Document,Apply Return Order,Post Return Shipment,Post Return Credit,Ship Transfer,Receive Transfer,Post Journal

    trigger OnRun()
    begin

        case ProcessWhich of
            ProcessWhich::"Create Claim Document":
                CreateClaimDocument(Rec);
            ProcessWhich::"Apply Return Order":
                ApplyClaimDocument(Rec);
            ProcessWhich::"Post Return Shipment":
                PostReturnShipment(Rec);
            ProcessWhich::"Post Return Credit":
                PostReturnCredit(Rec);

            ProcessWhich::"Ship Transfer":
                ShipTransfer(Rec);
            ProcessWhich::"Receive Transfer":
                ReceiveTransfer(Rec);
            ProcessWhich::"Post Journal":
                PostJournal(Rec);
        end;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        IntegrationSetup: Record "GXL Integration Setup";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        ClaimMgt: Codeunit "GXL Claim Management";
        SetupRead: Boolean;
        ProcessWhich: Option " ","Create Claim Document","Apply Return Order","Post Return Shipment","Post Return Credit","Ship Transfer","Receive Transfer","Post Journal";
        NotValidMsg: Label 'Not a valid %1';
        IsNotValidMsg: Label '%1 is not a valid %2';

    procedure SetOptions(NewProcessWhich: Option " ","Create Claim Document","Apply Return Order","Post Return Shipment","Post Return Credit","Ship Transfer","Receive Transfer","Post Journal")
    begin
        // 0
        // 1 Create Claim Document
        // 2 Apply Return Order
        // 3 Post Return Shipment
        // 4 Post Return Credit
        // 5 Ship Transfer
        // 6 Receive Transfer
        // 7 Post Journal

        ProcessWhich := NewProcessWhich;
    end;

    ///<Summary>
    ///Create a purchase return order or credit note for purchase claim or inventory adjustment for transfer claim
    ///</Summary>
    local procedure CreateClaimDocument(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    begin
        // Function creates either a purchase return order, a purchase credit, or a transfer order

        GetSetup();

        case PDAStAdjProcessingBuffer."Claim-to Document Type" of
            PDAStAdjProcessingBuffer."Claim-to Document Type"::PO,
            PDAStAdjProcessingBuffer."Claim-to Document Type"::PI:
                CreatePOClaimDocument(PDAStAdjProcessingBuffer);

            PDAStAdjProcessingBuffer."Claim-to Document Type"::"STO-SHIP",
            PDAStAdjProcessingBuffer."Claim-to Document Type"::"STO-REC":
                CreateSTOClaimDocument(PDAStAdjProcessingBuffer); //Post inventory adjustment journal

            else
                Error(StrSubstNo(IsNotValidMsg, Format(PDAStAdjProcessingBuffer."Claim-to Document Type"), PDAStAdjProcessingBuffer.FieldCaption("Claim-to Document Type")));
        end;
    end;

    ///<Summary>
    ///Create a purchase return order for ullaged vendor or purchase credit note for non-ullaged vendor
    ///</Summary>
    local procedure CreatePOClaimDocument(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        ClaimMgt.SetMIMUserID(PDAStAdjProcessingBuffer."MIM User ID"); //PS-2565 Missing MIM User ID +
        if IsUllaged(PDAStAdjProcessingBuffer."Vendor Ullaged Status") then
            ClaimMgt.CreatePurchaseHeader(
              PurchaseHeader,
              PurchaseHeader."Document Type"::"Return Order",
              IntegrationSetup."EDI Return Order No. Series",
              IntegrationSetup."EDI Return Order Vendor No.",
              PDAStAdjProcessingBuffer."Store Code",
              DT2DATE(PDAStAdjProcessingBuffer."Created Date Time"),     // posting date,
              PDAStAdjProcessingBuffer."Claim-to Document No.",  // may be blank, if so populate before posting Credit
              IntegrationSetup."EDI Ret. Order Bal. Acc. Type",
              IntegrationSetup."EDI Ret. Order Bal. Acc. No.",
              IntegrationSetup."EDI Return Order Reason Code", '')//IntegrationSetup."EDI Return Order Reason Code") // >> LCB-3 <<
        else
            ClaimMgt.CreatePurchaseHeader(
              PurchaseHeader,
              //PurchaseHeader."Document Type"::"Credit Memo", //ERP-340 -
              //IntegrationSetup."EDI Credit Memo No. Series", //ERP-340 -
              PurchaseHeader."Document Type"::"Return Order", //ERP-340 +
              IntegrationSetup."EDI Return Order No. Series", //ERP-340 +
              PDAStAdjProcessingBuffer."Claim-to Vendor No.",
              PDAStAdjProcessingBuffer."Store Code",
              DT2DATE(PDAStAdjProcessingBuffer."Created Date Time"),     // posting date,
              PDAStAdjProcessingBuffer."Claim-to Document No.",  // may be blank, if so populate before posting Credit
              0,  // Bal Acc type, leave as default zero
              '', // Bal Acc no, leave as default blank
              PDAStAdjProcessingBuffer."Reason Code", '');//PDAStAdjProcessingBuffer."Reason Code"); // >> LCB-3 <<

        ClaimMgt.CreatePurchaseLine(
          PurchaseLine,                                         // >> var
          PurchaseHeader,
          10000,
          PDAStAdjProcessingBuffer."Item No.",
          PDAStAdjProcessingBuffer."Unit of Measure Code",
          PDAStAdjProcessingBuffer."Stock on Hand",
          PDAStAdjProcessingBuffer."Claim Document Type",       // >> var
          PDAStAdjProcessingBuffer."Claim Document No.",        // >> var
          PDAStAdjProcessingBuffer."Claim Document Line No.");  // >> var

    end;

    ///<Summary>
    ///No functionality as claimable transfer order is via inventory adjustment journal
    ///</Summary>
    local procedure CreateSTOClaimDocument(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    var
    begin
        exit;

        /*
        if PDAStAdjProcessingBuffer."Claim-to Document Type" = PDAStAdjProcessingBuffer."Claim-to Document Type"::"STO-SHIP" then
            TransferReceiptHeader.Get(GetTransferReceiptHeader(PDAStAdjProcessingBuffer."Claim-to Order No.", PDAStAdjProcessingBuffer."Store Code"))
        else
            TransferReceiptHeader.Get(PDAStAdjProcessingBuffer."Claim-to Document No.");  // Get original document to be reversed

        CreateTransferHeader(PDAStAdjProcessingBuffer, TransferHeader, TransferReceiptHeader);
        CreateTransferLine(PDAStAdjProcessingBuffer, TransferHeader, 10000);
        */
    end;

    ///<Summary>
    ///Apply the claim purchase return order or credit note
    ///</Summary>
    local procedure ApplyClaimDocument(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    begin
        if ClaimAppliesToPurchase(PDAStAdjProcessingBuffer."Claim-to Document Type") then
            case PDAStAdjProcessingBuffer.Status of
                PDAStAdjProcessingBuffer.Status::"Return Order Created":
                    ApplyReturnOrder(PDAStAdjProcessingBuffer);
                PDAStAdjProcessingBuffer.Status::"Credit Created":
                    ApplyCreditNote(PDAStAdjProcessingBuffer);
            end;

    end;

    ///<Summary>
    ///Apply the claim purchase return order 
    ///</Summary>
    local procedure ApplyReturnOrder(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    var
        PurchaseLine: Record "Purchase Line";
        AppliesToItemLedgerEntryNo: Integer;
    begin
        exit; // >> LCB-225 <<

        PurchaseLine.Get(PurchaseLine."Document Type"::"Return Order", PDAStAdjProcessingBuffer."Claim Document No.", PDAStAdjProcessingBuffer."Claim Document Line No.");

        AppliesToItemLedgerEntryNo :=
          ClaimMgt.GetAppliesToItemLedgerEntryNo(
            PDAStAdjProcessingBuffer."Claim-to Receipt No.",  // << var
            PDAStAdjProcessingBuffer."Claim-to Order No.",
            PDAStAdjProcessingBuffer."Claim-to Vendor No.",
            PDAStAdjProcessingBuffer."Item No.");

        PurchaseLine.Validate("Appl.-to Item Entry", AppliesToItemLedgerEntryNo);

        PurchaseLine.Modify(true);
    end;

    ///<Summary>
    ///Apply the claim purchase credit note to the original invoice
    ///</Summary>
    local procedure ApplyCreditNote(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    begin
        ClaimMgt.ApplyCreditNote(PDAStAdjProcessingBuffer."Claim Document No.", PDAStAdjProcessingBuffer."Claim-to Document No.");
    end;

    ///<Summary>
    ///Post the return shipment for claim purchase return order
    ///</Summary>
    local procedure PostReturnShipment(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    var
        PurchaseHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        PurchaseHeader.Get(PurchaseHeader."Document Type"::"Return Order", PDAStAdjProcessingBuffer."Claim Document No.");
        PurchaseHeader.Ship := true;
        PurchaseHeader.Invoice := false; //ERP-340 +
        //PS-2046+
        PurchaseHeader."GXL MIM User ID" := PDAStAdjProcessingBuffer."MIM User ID";
        //PS-2046-

        //PS-2640 +
        if PurchaseHeader."Last Return Shipment No." <> '' then begin
            PurchLine.SetRange("Document Type", PurchaseHeader."Document Type");
            PurchLine.SetRange("Document No.", PurchaseHeader."No.");
            PurchLine.SetFilter("Outstanding Quantity", '<>0');
            if PurchLine.IsEmpty then begin
                PDAStAdjProcessingBuffer.Validate("Posted Return Shipment No.", PurchaseHeader."Last Return Shipment No.");
                exit;
            end;
        end;
        //PS-2640 -

        CODEUNIT.RUN(CODEUNIT::"Purch.-Post", PurchaseHeader);

        PDAStAdjProcessingBuffer.Validate("Posted Return Shipment No.", PurchaseHeader."Last Return Shipment No.");
    end;

    ///<Summary>
    ///Post the claim purchase credit note or return order
    ///</Summary>
    local procedure PostReturnCredit(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    var
        PurchaseHeader: Record "Purchase Header";
        VLE: Record "Vendor Ledger Entry";
        ClaimMgt: Codeunit "GXL Claim Management";
        ModifyHeader: Boolean;
        VendCrMemoNo: Code[35];
    begin
        case PDAStAdjProcessingBuffer."Claim Document Type" of
            PDAStAdjProcessingBuffer."Claim Document Type"::"Credit Memo":
                PurchaseHeader.Get(PurchaseHeader."Document Type"::"Credit Memo", PDAStAdjProcessingBuffer."Claim Document No.");
            PDAStAdjProcessingBuffer."Claim Document Type"::"Return Order":
                begin
                    PurchaseHeader.Get(PurchaseHeader."Document Type"::"Return Order", PDAStAdjProcessingBuffer."Claim Document No.");
                    //PS-2638 +
                    // if PurchaseHeader."Vendor Cr. Memo No." = '' then
                    //     PurchaseHeader.Validate("Vendor Cr. Memo No.", PDAStAdjProcessingBuffer."Claim-to Document No.");
                    //PS-2638 -
                end;
            else
                Error(StrSubstNo(NotValidMsg, PDAStAdjProcessingBuffer.FieldCaption("Claim Document Type")));
        end;

        //PS-2638 +
        ClaimMgt.UpdatePurchaseCrMemoNo(PurchaseHeader, PDAStAdjProcessingBuffer."Claim-to Document No.", PDAStAdjProcessingBuffer."Claim-to Order No.", ModifyHeader);
        //PS-2638 -

        //ERP-340 +
        if PDAStAdjProcessingBuffer."Claim-to Document No." <> '' then begin
            if (PurchaseHeader."Applies-to Doc. No." = '') and (PurchaseHeader."Bal. Account No." = '') then begin
                PurchaseHeader."Applies-to Doc. Type" := PurchaseHeader."Applies-to Doc. Type"::Invoice;
                PurchaseHeader.Validate("Applies-to Doc. No.", PDAStAdjProcessingBuffer."Claim-to Document No.");
                ModifyHeader := true;
            end;
        end;
        //ERP-340 -

        if (PurchaseHeader."Applies-to Doc. Type" = PurchaseHeader."Applies-to Doc. Type"::Invoice) and
           (PurchaseHeader."Applies-to Doc. No." <> '')
        then begin
            VLE.SetCurrentKey("Document No.", "Document Type", "Vendor No.");
            VLE.SetRange("Document No.", PurchaseHeader."Applies-to Doc. No.");
            VLE.SetRange("Document Type", VLE."Document Type"::Invoice);
            VLE.SetRange("Vendor No.", PurchaseHeader."Pay-to Vendor No.");
            if (VLE.FindFirst()) and
               (not VLE.Open)
            then begin
                PurchaseHeader."Applies-to Doc. Type" := 0;
                PurchaseHeader."Applies-to Doc. No." := '';
                //PS-2638 +
                //PurchaseHeader.Modify();
                //Commit();
                ModifyHeader := true;
                //PS-2638 -
            end;
        end;

        //PS-2638 +
        if ModifyHeader then begin
            PurchaseHeader.Modify();
            Commit();
        end;
        //PS-2638 -

        if PDAStAdjProcessingBuffer.Status = PDAStAdjProcessingBuffer.Status::"Credit Applied" then
            PurchaseHeader.Ship := true;

        PurchaseHeader.Invoice := true;
        //PS-2046+
        PurchaseHeader."GXL MIM User ID" := PDAStAdjProcessingBuffer."MIM User ID";
        //PS-2046-

        CODEUNIT.RUN(CODEUNIT::"Purch.-Post", PurchaseHeader);

        if PurchaseHeader."Last Posting No." = '' then begin
            if (PDAStAdjProcessingBuffer."Claim Document Type" = PDAStAdjProcessingBuffer."Claim Document Type"::"Credit Memo") and
               (PDAStAdjProcessingBuffer."Claim Document No." <> '') and
               (PDAStAdjProcessingBuffer."Posted Credit Memo No." = '')
            then
                PDAStAdjProcessingBuffer.Validate("Posted Credit Memo No.", PDAStAdjProcessingBuffer."Claim Document No.");
        end else
            PDAStAdjProcessingBuffer.Validate("Posted Credit Memo No.", PurchaseHeader."Last Posting No.");
    end;

    /*
    local procedure CreateTransferHeader(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer"; var TransferHeader: Record "Transfer Header"; TransferReceiptHeader: Record "Transfer Receipt Header")
    begin
        GetSetup();
        IntegrationSetup.TESTFIELD("St Adj Transfer In-Trans Code");

        TransferHeader.Init();
        TransferHeader.Insert(true);
        TransferHeader.Validate("Transfer-from Code", TransferReceiptHeader."Transfer-to Code");
        TransferHeader.Validate("Transfer-to Code", TransferReceiptHeader."Transfer-from Code");
        TransferHeader.Validate("In-Transit Code", IntegrationSetup."St Adj Transfer In-Trans Code");
        TransferHeader.Validate("Posting Date", DT2DATE(PDAStAdjProcessingBuffer."Created Date Time"));
        TransferHeader.Modify(true);
    end;

    local procedure CreateTransferLine(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer"; TransferHeader: Record "Transfer Header"; LineNo: Integer)
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.Init();
        TransferLine.Validate("Document No.", TransferHeader."No.");
        TransferLine.Validate("Line No.", LineNo);
        TransferLine.Validate("Item No.", PDAStAdjProcessingBuffer."Item No.");
        TransferLine.Validate(Quantity, PDAStAdjProcessingBuffer."Stock on Hand");
        TransferLine.Insert(true);

        PDAStAdjProcessingBuffer."Claim Document Type" := PDAStAdjProcessingBuffer."Claim Document Type"::"Transfer Order";
        PDAStAdjProcessingBuffer."Claim Document No." := TransferLine."Document No.";
        PDAStAdjProcessingBuffer."Claim Document Line No." := TransferLine."Line No.";
    end;
    */

    local procedure IsUllaged(UllagedStatus: Enum "GXL Vendor Ullaged Status"): Boolean
    begin
        exit(UllagedStatus = UllagedStatus::Ullaged);
    end;

    ///<Summary>
    ///If the claim is related to purchase
    ///</Summary>
    local procedure ClaimAppliesToPurchase(ClaimToDocumentType: Option " ",PO,PI,STO,"STO-SHIP","STO-REC"): Boolean
    var
        StockAdjProcessMgt: Codeunit "GXL Stock Adj. Process Mgt.";
    begin
        exit(StockAdjProcessMgt.ClaimAppliesToPurchase(ClaimToDocumentType));
    end;

    ///<Summary>
    ///No functionality as claimable transfer order is via inventory adjustment journal
    ///</Summary>
    local procedure ShipTransfer(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    begin
        exit;
        /*
        TransferHeader.Get(PDAStAdjProcessingBuffer."Claim Document No.");
        ReleaseTransferDocument.RUN(TransferHeader);

        CODEUNIT.RUN(CODEUNIT::"TransferOrder-Post Shipment", TransferHeader);
        */
    end;

    ///<Summary>
    ///No functionality as claimable transfer order is via inventory adjustment journal
    ///</Summary>
    local procedure ReceiveTransfer(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    begin
        exit;
        /*
        TransferHeader.Get(PDAStAdjProcessingBuffer."Claim Document No.");

        CODEUNIT.RUN(CODEUNIT::"TransferOrder-Post Receipt", TransferHeader);
        */
    end;

    ///<Summary>
    ///Create and post negative inventory adjustment journal for stock damaged during transfer
    ///</Summary>
    local procedure PostJournal(var PDAStAdjProcessingBuffer: Record "GXL PDA-StAdjProcessing Buffer")
    var
        ItemJournalLine: Record "Item Journal Line";
        Item: Record Item;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        PDAStockAdjBuffProcess: Codeunit "GXL PDA Stock Adj Buff Process";
        DocNo: Code[20];
        DimValCode: Code[20];
    begin
        //This function is actually an adjustment of inventory for damaged stocks on transfer orders

        //PS-2210+
        PDAStockAdjBuffProcess.CheckUOM(PDAStAdjProcessingBuffer);
        //PS-2210-

        GetSetup();

        ItemJournalLine.Init();
        ItemJournalLine.Validate("Posting Date", DT2DATE(PDAStAdjProcessingBuffer."Created Date Time"));
        ItemJournalLine.Validate("Entry Type", ItemJournalLine."Entry Type"::"Negative Adjmt.");
        DocNo := GetJnlDocumentNo(PDAStAdjProcessingBuffer);
        ItemJournalLine.Validate("Document No.", DocNo);
        ItemJournalLine.Validate("Item No.", PDAStAdjProcessingBuffer."Item No.");
        if PDAStAdjProcessingBuffer."Unit of Measure Code" <> '' then
            ItemJournalLine.Validate("Unit of Measure Code", PDAStAdjProcessingBuffer."Unit of Measure Code")
        else
            if ItemJournalLine."Unit of Measure Code" = '' then begin
                Item.Get(ItemJournalLine."Item No.");
                ItemJournalLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
            end;
        ItemJournalLine.Validate("Location Code", PDAStAdjProcessingBuffer."Store Code");
        ItemJournalLine.Validate(Quantity, ABS(PDAStAdjProcessingBuffer."Stock on Hand"));
        ItemJournalLine.Validate("Reason Code", PDAStAdjProcessingBuffer."Reason Code");
        ItemJournalLine.Validate(Description, StrSubstNo('%1 STO: %2', PDAStAdjProcessingBuffer."Store Code", PDAStAdjProcessingBuffer."Claim-to Document No."));

        if IntegrationSetup."Store Dimension Code" <> '' then begin
            DimValCode := MiscUtilities.GetStoreDimensionValue(ItemJournalLine."Location Code", IntegrationSetup."Store Dimension Code");
            if DimValCode <> '' then begin
                case true of
                    IntegrationSetup."Store Dimension Code" = GLSetup."Global Dimension 1 Code":
                        ItemJournalLine.Validate("Shortcut Dimension 1 Code", DimValCode);
                    IntegrationSetup."Store Dimension Code" = GLSetup."Global Dimension 2 Code":
                        ItemJournalLine.Validate("Shortcut Dimension 2 Code", DimValCode);
                end;
            end;
        end;
        //PS-2046+
        ItemJournalLine."GXL MIM User ID" := PDAStAdjProcessingBuffer."MIM User ID";
        //PS-2046-
        ItemJnlPostLine.RUN(ItemJournalLine);
    end;

    local procedure GetSetup()
    begin
        if not SetupRead then begin
            GLSetup.Get();
            IntegrationSetup.Get();
            SetupRead := true;
        end;
    end;

    procedure GetTransferReceiptHeader(OrderNo: Code[20]; TransferToCode: Code[10]): Code[20]
    var
        TransferReceiptLine: Record "Transfer Receipt Line";
    begin
        TransferReceiptLine.SetCurrentKey("Transfer Order No.");
        TransferReceiptLine.SetRange("Transfer Order No.", OrderNo);
        TransferReceiptLine.SetRange("Transfer-to Code", TransferToCode);
        TransferReceiptLine.FindFirst();
        exit(TransferReceiptLine."Document No.");
    end;

    local procedure GetJnlDocumentNo(PDAStockAdjProcessingBuffer2: Record "GXL PDA-StAdjProcessing Buffer"): Code[20]
    begin
        exit(CopyStr(StrSubstNo('PDA-%1-%2', PDAStockAdjProcessingBuffer2."Store Code", PDAStockAdjProcessingBuffer2."Entry No."), 1, 20));
    end;

}