codeunit 50282 "GXL Non-EDI Receive PurchOrder"
{
    /*Change Log
        PS-2304 30-09-20 LP
            Removed VendorClaimClassification as it is removed from NAV13
            Use Ullaged Supplier from Vendor table
    */

    trigger OnRun()
    var
        LineErrorCount: Integer;
        LockErrorCount: Integer;
    begin

        ValidateLines(DocumentNo, LineErrorCount, LockErrorCount);

        Commit();

        // Error if any line has a non-locking error
        IF LineErrorCount > LockErrorCount THEN
            ERROR(AtLeastOneLineHasErrorMsg);
    end;

    var
        DocumentNo: Code[20];
        AtLeastOneLineHasErrorMsg: Label 'At least one line has an error. See page PDA Receiving Buffer for details.';

    procedure SetDocument(InputDocumentNo: Code[20])
    begin
        DocumentNo := InputDocumentNo;
    end;

    //Validate all the Scanned records
    local procedure ValidateLines(DocumentNo: Code[20]; var LineErrorCount: Integer; var LockErrorCount: Integer) Success: Boolean
    var
        PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
        PDAPLReceiveBuffer2: Record "GXL PDA-PL Receive Buffer";
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        NonEDIProcessScannedQtys: Codeunit "GXL Non-EDI Process Scan Qtys";
        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
        ProcessWasSuccess: Boolean;
    begin
        PDAPLReceiveBuffer.SetCurrentKey("Document No.");
        PDAPLReceiveBuffer.SetRange("Document No.", DocumentNo);
        PDAPLReceiveBuffer.SetRange(Status, PDAPLReceiveBuffer.Status::Scanned);
        if PDAPLReceiveBuffer.FindSet(true, true) then begin

            if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, PDAPLReceiveBuffer."Document No.") then begin
                Vendor.Get(PurchaseHeader."Buy-from Vendor No.");
                Vendor.TestField("GXL Ullaged Supplier");

                repeat
                    PDAPLReceiveBuffer2.Get(PDAPLReceiveBuffer."Entry No.");
                    Commit();

                    //Check if over receiving, then set Quantity on Purchase Line
                    ProcessWasSuccess := NonEDIProcessScannedQtys.ValidatePDALine(PDAPLReceiveBuffer2, 3); //3=Validate purchase line, use invoice qty
                    PDAPLReceiveBuffer2.Get(PDAPLReceiveBuffer2."Entry No.");
                    if ProcessWasSuccess then
                        UpdateLine(PDAPLReceiveBuffer2,
                            ProcessWasSuccess,
                            '',
                            PDAPLReceiveBuffer2.Status::Processed,
                            Vendor."No.",
                            //PS-2304+
                            //VendorUllageClaimClassification(Vendor, PDAPLReceiveBuffer2."Reason Code"),
                            Vendor."GXL Ullaged Supplier",
                            //PS-2304-
                            PurchaseHeader."GXL EDI PO File Log Entry No.",
                            PDAPLReceiveBuffer2."Claim Quantity",
                            '')
                    else begin

                        LineErrorCount += 1;
                        if not NonEDIProcessMgt.IsLockingError(GetLastErrorCode()) then
                            UpdateLine(PDAPLReceiveBuffer2,
                                ProcessWasSuccess,
                                CopyStr(GetLastErrorText(), 1, MaxStrLen(PDAPLReceiveBuffer2."Error Message")),
                                PDAPLReceiveBuffer2.Status::"Processing Error",
                                Vendor."No.",
                                //PS-2304+
                                //VendorUllageClaimClassification(Vendor, PDAPLReceiveBuffer2."Reason Code"),
                                Vendor."GXL Ullaged Supplier",
                                //PS-2304-
                                PurchaseHeader."GXL EDI PO File Log Entry No.",
                                PDAPLReceiveBuffer2."Claim Quantity",
                                GetLastErrorCode())
                        else
                            LockErrorCount += 1;
                    end;

                    Commit();
                until PDAPLReceiveBuffer.Next() = 0;

            end else begin

                // handle Transfer Order (out of scope)

            end;

        end;
    end;

    //Update the PDA-PL Receive Buffer Status
    local procedure UpdateLine(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; ProcessWasSuccess: Boolean; ErrorMessage: Text; NewStatus: Option; VendorNo: Code[20]; VendorUllagedStatus: Enum "GXL Vendor Ullaged Status"; EDIFileLogEntryNo: Integer; ClaimQuantity: Decimal; ErrorCode: Text)
    begin
        PDAPLReceiveBuffer.Errored := not ProcessWasSuccess;
        PDAPLReceiveBuffer."Error Code" := CopyStr(ErrorCode, 1, MaxStrLen(PDAPLReceiveBuffer."Error Code"));
        PDAPLReceiveBuffer."Error Message" := ErrorMessage;
        PDAPLReceiveBuffer.Status := NewStatus;
        PDAPLReceiveBuffer."Vendor No." := VendorNo;
        PDAPLReceiveBuffer."Vendor Ullaged Status" := VendorUllagedStatus;
        if PDAPLReceiveBuffer."EDI File Log Entry No." = 0 then
            PDAPLReceiveBuffer."EDI File Log Entry No." := EDIFileLogEntryNo;
        PDAPLReceiveBuffer."Claim Quantity" := ClaimQuantity;
        PDAPLReceiveBuffer.Modify();
    end;

    //PS-2304+
    //Removed
    /*
    procedure VendorUllageClaimClassification(Vendor: Record Vendor; ClaimReasonCode: Code[10]): Integer
    var
        VendorClaimClassification: Record "GXL Vend. Claim Classification";
    begin
        if (VendorClaimClassification.Get(Vendor."No.", ClaimReasonCode)) AND
           (VendorClaimClassification."Ullage Claim Classification" <> VendorClaimClassification."Ullage Claim Classification"::" ")
        then
            EXIT(VendorClaimClassification."Ullage Claim Classification")
        else begin
            Vendor.TestField("GXL Ullaged Supplier");
            EXIT(Vendor."GXL Ullaged Supplier");
        end;
    end;
    */
    //PS-2304-
}