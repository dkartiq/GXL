codeunit 50381 "GXL P2P-Valid Pur. Order Resp."
{
    TableNo = "GXL EDI-Purchase Messages";

    trigger OnRun()
    var
        EDIProcessManagement: Codeunit "GXL EDI Process Mngt";
    begin
        PurchaseHeader.RESET();
        IF NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec.DocumentNumber) THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text003Txt, Rec.DocumentNumber));
            EDIErrorMgt.ThrowErrorMessage();
        END;
        CLEAR(EDIFunctions);
        ValidateP2PAllPORLinesExist(Rec.DocumentNumber);
        ValidateP2PPORLines(Rec.DocumentNumber);
        EDIProcessManagement.UpdateEDIPurchaseMessageStatus(Rec.ImportDoc, Rec.DocumentNumber, Rec.Status::Validated);
        COMMIT();

    end;

    var
        PurchaseHeader: Record "Purchase Header";
        EDIFunctions: Codeunit "GXL EDI Functions Library";
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        //Text000Txt: Label '%1 must have a value. It cannot be zero or blank.';
        //Text002Txt: Label '%1 cannot be less than %2.';
        Text003Txt: Label 'Purchase Order for DocumentNumber %1 doesn''t exist.';
        //Text004Txt: Label 'Line No. %1 not found on Purchase Order %2.';
        Text005Txt: Label '%1 on PO Response Item Line must be less than or equal to %2 on %5. PO Response Item Line value: %3. Purchase Line value: %4.';
        Text006Txt: Label 'Item %1 doesn''t exist in Purchase Order %2.';
        //Text007Txt: Label 'Purchase Order %1 has been cancelled.';
        //Text008Txt: Label 'There is already a valid PO Response %1 %2 for Purchase Order %3.';
        Text009Txt: Label '%1 or %2 must have a value.';
        Text010Txt: Label 'Vendor Reorder Number %1 doesn''t exist in Purchase Order %2.';
        //Text011Txt: Label '%1 on PO Response Item Line must be equal to %2 on %5. PO Response Item Line value: %3. Purchase Line value: %4.';
        Text012Txt: Label '%1 must have a value on %2 for item %3. ';
    //Text020Txt: Label 'EDI File Log Entry No. %1 does not exist.';

    local procedure ValidateP2PAllPORLinesExist(InputDocumentNumber: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
        EDIPurchaseMessages2: Record "GXL EDI-Purchase Messages";
        ErrorFound: Boolean;
        ErrorText: Text;
    begin
        EDIPurchaseMessages.SETCURRENTKEY(ImportDoc, DocumentNumber);
        EDIPurchaseMessages.SETRANGE(ImportDoc, EDIPurchaseMessages.ImportDoc::"1"); //Confiirmation POR
        EDIPurchaseMessages.SETRANGE(DocumentNumber, InputDocumentNumber);
        IF EDIPurchaseMessages.FINDSET(TRUE) THEN BEGIN
            REPEAT
                EDIPurchaseMessages2 := EDIPurchaseMessages;
                IF (EDIPurchaseMessages.Items = '') AND (EDIPurchaseMessages.SupplierNo = '') THEN BEGIN
                    ErrorFound := TRUE;
                    EDIPurchaseMessages2."Error Found" := TRUE;
                    EDIPurchaseMessages2."Error Description" := STRSUBSTNO(Text009Txt, EDIPurchaseMessages.FIELDCAPTION(SupplierNo), EDIPurchaseMessages.FIELDCAPTION(Items));
                    EDIPurchaseMessages2.Modify();
                END ELSE BEGIN
                    PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
                    PurchaseLine.SETRANGE("Document No.", EDIPurchaseMessages.DocumentNumber);
                    IF EDIPurchaseMessages.Items <> '' THEN BEGIN
                        PurchaseLine.SETRANGE("No.", EDIPurchaseMessages.Items);
                        IF PurchaseLine.FindFirst() THEN BEGIN
                            EDIPurchaseMessages2.LineReference := PurchaseLine."Line No.";
                            EDIPurchaseMessages2."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
                            EDIPurchaseMessages2.ILC := PurchaseLine."GXL Legacy Item No.";
                            EDIPurchaseMessages2.Modify();
                        END ELSE BEGIN
                            EDIPurchaseMessages2."Error Found" := TRUE;
                            EDIPurchaseMessages2."Error Description" := STRSUBSTNO(Text006Txt, EDIPurchaseMessages.Items, EDIPurchaseMessages.DocumentNumber);
                            EDIPurchaseMessages2.Modify();
                        END;
                    END ELSE
                        IF EDIPurchaseMessages.SupplierNo <> '' THEN BEGIN
                            PurchaseLine.SETFILTER("GXL Vendor Reorder No.", EDIPurchaseMessages.SupplierNo);
                            IF PurchaseLine.FindFirst() THEN BEGIN
                                EDIPurchaseMessages2.LineReference := PurchaseLine."Line No.";
                                EDIPurchaseMessages2.Items := PurchaseLine."No.";
                                EDIPurchaseMessages2."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
                                EDIPurchaseMessages2.ILC := PurchaseLine."GXL Legacy Item No.";
                                EDIPurchaseMessages2.Modify();
                            END ELSE BEGIN
                                EDIPurchaseMessages2."Error Found" := TRUE;
                                EDIPurchaseMessages2."Error Description" := STRSUBSTNO(Text010Txt, EDIPurchaseMessages.SupplierNo, EDIPurchaseMessages.DocumentNumber);
                                EDIPurchaseMessages2.Modify();
                            END;
                        END;
                END;
                IF EDIPurchaseMessages2."Error Found" THEN BEGIN
                    ErrorFound := TRUE;
                    ErrorText := EDIPurchaseMessages2."Error Description";
                END;
                COMMIT();
            UNTIL EDIPurchaseMessages.NEXT() = 0;
        END;

        IF ErrorFound THEN BEGIN
            EDIErrorMgt.SetErrorMessage(ErrorText);
            EDIErrorMgt.ThrowErrorMessage();
        END;
    end;

    local procedure ValidateP2PPORLines(InputDocumentNumber: Code[20])
    var
        EDIPurchaseMessages: Record "GXL EDI-Purchase Messages";
    begin
        EDIPurchaseMessages.SETCURRENTKEY(ImportDoc, DocumentNumber);
        EDIPurchaseMessages.SETRANGE(ImportDoc, EDIPurchaseMessages.ImportDoc::"1"); //Confirmation POR
        EDIPurchaseMessages.SETRANGE(DocumentNumber, InputDocumentNumber);
        IF EDIPurchaseMessages.FINDSET(TRUE) THEN BEGIN
            REPEAT
                ValidateP2PPORLine(EDIPurchaseMessages, InputDocumentNumber, PurchaseHeader."Buy-from Vendor No.");
            UNTIL EDIPurchaseMessages.NEXT() = 0;
        END;
    end;

    local procedure ValidateP2PPORLine(EDIPurchaseMessages: Record "GXL EDI-Purchase Messages"; PurchOrderNo: Code[20]; VendorNo: Code[20])
    var
        PurchaseLine: Record "Purchase Line";
        EDIFileLog: Record "GXL EDI File Log";
        OldGTIN: Code[50];
    begin
        IF EDIPurchaseMessages.OMQty = 0 THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                 Text012Txt,
                EDIPurchaseMessages.FIELDCAPTION(OMQty),
                EDIPurchaseMessages.DocumentNumber,
                EDIPurchaseMessages.Items));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF EDIPurchaseMessages.OPQty = 0 THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text012Txt,
                EDIPurchaseMessages.FIELDCAPTION(OPQty),
                EDIPurchaseMessages.DocumentNumber,
                EDIPurchaseMessages.Items));

            EDIErrorMgt.ThrowErrorMessage();
        END;

        PurchaseLine.GET(PurchaseLine."Document Type"::Order, PurchOrderNo, EDIPurchaseMessages.LineReference);

        IF EDIPurchaseMessages.ConfirmedOrderQtyOM > PurchaseLine.Quantity THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(
                Text005Txt,
                EDIPurchaseMessages.FIELDCAPTION(ConfirmedOrderQtyOM),
                PurchaseLine.FIELDCAPTION(Quantity),
                EDIPurchaseMessages.ConfirmedOrderQtyOM,
                PurchaseLine.Quantity,
                PurchaseLine.TABLECAPTION()));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF EDIPurchaseMessages.GTIN <> '' THEN BEGIN
            //OldGTIN := EDIFunctions.ValidateGTIN(EDIPurchaseMessages.Items, VendorNo, EDIPurchaseMessages.GTIN);
            OldGTIN := EDIFunctions.ValidateGTIN(EDIPurchaseMessages.ILC, VendorNo, EDIPurchaseMessages.GTIN);
            IF EDIFunctions.GTINIsChangedOrNew() THEN
                EDIFunctions.InsertItemSupplierGTINBuffer(1, PurchaseLine."Document No.", PurchaseLine."Line No.", OldGTIN, EDIPurchaseMessages.GTIN, (OldGTIN <> ''));
        END;

        // This code block will ensure processing and closure of historic POR lines which perpetually remained in "Imported" state for Confirmed or Cancelled POs
        //   and eventually failed when a housekeeing process removed the related EDI File Log Entry
        // Once these historic entries get processed, the situation of missing File Log Entries should not arise as these entries will now get processed even if the
        //   related PO is already confirmed or cancelled and will be closed successfully or flagged with
        IF NOT EDIFileLog.GET(EDIPurchaseMessages."EDI File Log Entry No.") THEN BEGIN
            EDIFileLog.INIT();
            EDIFileLog."Entry No." := EDIPurchaseMessages."EDI File Log Entry No.";
            EDIFileLog."Date/Time" := CREATEDATETIME(EDIPurchaseMessages.ConfirmedReceiptDate, 0T);
            EDIFileLog."Document Type" := EDIFileLog."Document Type"::POR;
            EDIFileLog.Status := EDIFileLog.Status::Success;
            EDIFileLog."EDI Vendor Type" := PurchaseHeader."GXL EDI Vendor Type";
            EDIFileLog."Error Message" := 'Missing file log entry created for PO No. ' + PurchOrderNo;
            EDIFileLog.INSERT();
        END;
    end;
}

