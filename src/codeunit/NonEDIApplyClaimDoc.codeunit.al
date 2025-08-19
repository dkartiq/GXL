codeunit 50284 "GXL Non-EDI Apply Claim Doc"
{
    trigger OnRun()
    var
        ClaimMgt: Codeunit "GXL Claim Management";
    begin
        CASE VendorUllagedStatus OF
            VendorUllagedStatus::Ullaged:
                ApplyReturnOrder();
            VendorUllagedStatus::"Non-Ullaged":
                begin
                    //ERP-340 +
                    // ApplyCreditNote();
                    if ClaimDocType = ClaimDocType::"Return Order" then
                        ApplyReturnOrder()
                    else
                        ApplyCreditNote();
                    //ERP-340 -
                end;
            ELSE
                ERROR(ClaimMgt.MissingVendorUllagedStatusErrorText());
        END;
    end;

    var
        DocumentNo: Code[20];
        VendorUllagedStatus: Enum "GXL Vendor Ullaged Status";
        MustApplyToILEErr: Label 'Applies-to Item Ledger Entry No. must not be 0.';
        ClaimDocType: Option "  ","Transfer Order","Credit Memo","Return Order";

    //ERP-340 +
    procedure SetClaimDocType(NewClaimDocType: Option "  ","Transfer Order","Credit Memo","Return Order")
    begin
        ClaimDocType := NewClaimDocType;
    end;
    //ERP-340 -

    procedure SetDocument(InputDocumentNo: Code[20]; InputVendorUllagedStatus: enum "GXL Vendor Ullaged Status")
    begin
        DocumentNo := InputDocumentNo;
        VendorUllagedStatus := InputVendorUllagedStatus;
    end;

    local procedure ApplyReturnOrder()
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        PurchaseLine: Record "Purchase Line";
        ClaimMgt: Codeunit "GXL Claim Management";
        AppliesToItemLedgerEntryNo: Integer;
    begin
        FilterBuffer(PDAPLReceiveBuffer, DocumentNo);
        PDAPLReceiveBuffer.SetFilter("Claim Document No.", '<>%1', '');
        PDAPLReceiveBuffer.FindSet(true);
        repeat

            PurchaseLine.GET(PurchaseLine."Document Type"::"Return Order", PDAPLReceiveBuffer."Claim Document No.", PDAPLReceiveBuffer."Claim Document Line No.");

            //ERP-340 +
            // AppliesToItemLedgerEntryNo :=
            //   ClaimMgt.GetAppliesToItemLedgerEntryNo(
            //     PDAPLReceiveBuffer."Purchase Receipt No.",  // << var
            //     PDAPLReceiveBuffer."Document No.",
            //     PDAPLReceiveBuffer."Vendor No.",
            //     PDAPLReceiveBuffer."No.");

            // if AppliesToItemLedgerEntryNo = 0 then
            //     ERROR(MustApplyToILEErr);

            // PurchaseLine.VALIDATE("Appl.-to Item Entry", AppliesToItemLedgerEntryNo);
            // PurchaseLine.Modify(true);

            AppliesToItemLedgerEntryNo :=
              ClaimMgt.GetAppliesToItemLedgerEntryNo(
                PDAPLReceiveBuffer."Purchase Receipt No.",  // << var - receipt number returned
                PDAPLReceiveBuffer."Document No.",
                PDAPLReceiveBuffer."Vendor No.",
                PDAPLReceiveBuffer."No.",
                PDAPLReceiveBuffer."Line No.");

            if VendorUllagedStatus = VendorUllagedStatus::Ullaged then
                if AppliesToItemLedgerEntryNo = 0 then
                    Error(MustApplyToILEErr);

            if AppliesToItemLedgerEntryNo <> 0 then begin
                PurchaseLine.VALIDATE("Appl.-to Item Entry", AppliesToItemLedgerEntryNo);
                PurchaseLine.Modify(true);
            end;
        //ERP-340 -

        until PDAPLReceiveBuffer.Next() = 0;
    end;

    local procedure ApplyCreditNote()
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        ClaimMgt: Codeunit "GXL Claim Management";
    begin
        FilterBuffer(PDAPLReceiveBuffer, DocumentNo);
        PDAPLReceiveBuffer.SetFilter("Claim Document No.", '<>%1', '');
        PDAPLReceiveBuffer.FindFirst();

        ClaimMgt.ApplyCreditNote(PDAPLReceiveBuffer."Claim Document No.", PDAPLReceiveBuffer."Purchase Invoice No.");
    end;

    local procedure PrccessEachLine(PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"): Boolean
    begin
        EXIT(PDAPLReceiveBuffer.Status = PDAPLReceiveBuffer.Status::"Return Order Created");
    end;

    local procedure FilterBuffer(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; DocumentNo: Code[20])
    begin
        PDAPLReceiveBuffer.SetCurrentKey("Document No.");
        PDAPLReceiveBuffer.SetRange("Document No.", DocumentNo);
    end;

}