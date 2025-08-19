///<Summary>
///This codeunit is mainly run from job queue
///It will process all PDA-PL Receive Buffer records for purchase orders which Vendor EDI Type is not blank or Vendor Exchange File
///From MIM logic, MIM will create an entry for only purchase orders that "EDI Vendor Type" is "Point to Point Contingency"
///To receive purchase/transfer orders
///</Summary>
codeunit 50262 "GXL PDA-Process Receive Buffer"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        NonEDIProcessScannedQtys: Codeunit "GXL Non-EDI Process Scan Qtys";
    begin
        GlobalJobQueueEntry := Rec;
        GlobalNoOfErrors := 0;

        //Transfer the records from PDA-Purchase Lines which are created from PDA (MIM) to PDA-PL Receive Buffer for receive by lines
        //  (Note receive full has already been created straight into table PDA-PL Receive Line)
        NonEDIProcessScannedQtys.CopyPDABuffer();

        FilterAndReceiveAll(GlobalPDARecBuff, true);
        FilterAndReceiveAll(GlobalPDARecBuff, false);

        Commit();
        if GlobalNoOfErrors <> 0 then
            SendError(GlobalNoOfErrors);
    end;

    var
        GlobalPDARecBuff: Record "GXL PDA-PL Receive Buffer";
        GlobalJobQueueEntry: Record "Job Queue Entry";
        GXLMiscUtilities: Codeunit "GXL Misc. Utilities";
        GlobalNoOfErrors: Integer;


    ///<Summary>
    ///Process PDA-PL Receive Buffer to receive (post) purchase order or transfer order
    ///</Summary>
    local procedure ReceiveAll()
    var
        DummyPurchHeader: Record "Purchase Header" temporary;
        DummyTransHeader: Record "Transfer Header" temporary;
        PurchHead: Record "Purchase Header";
        TransHead: Record "Transfer Header";
        PurchPost: Codeunit "Purch.-Post";
        TransOrdPostRcpt: Codeunit "TransferOrder-Post Receipt";
        AtLeastOneError: Boolean;
        DocNo: Code[20];
        ErrMsg: Text;
        ToProcess: Boolean;
    begin
        if GlobalPDARecBuff.FindSet() then
            repeat
                if (DocNo <> GlobalPDARecBuff."Document No.") then begin
                    DocNo := GlobalPDARecBuff."Document No.";
                    if PurchHead.Get(PurchHead."Document Type"::Order, GlobalPDARecBuff."Document No.") then begin
                        //If it is EDI or vendor file exchange
                        if ((PurchHead."GXL EDI Vendor Type" <> PurchHead."GXL EDI Vendor Type"::" ") or PurchHead."GXL Vendor File Exchange") then begin
                            //PS-2428+
                            //If the purchase order has already been validated qty. to receive from xmlport 50047
                            //P2P Contingency will be processed via EDI ASN codeunits
                            ToProcess := true;
                            if (PurchHead."GXL EDI Vendor Type" = PurchHead."GXL EDI Vendor Type"::"Point 2 Point Contingency") and
                                PurchHead."GXL P2P Conting ASN Imported" then
                                ToProcess := false;
                            if ToProcess then
                                //PS-2428-
                                if CheckOrderStatus(0, PurchHead, DummyTransHeader) then begin
                                    PurchHead.Get(PurchHead."Document Type"::Order, DocNo);
                                    PurchHead.Receive := true;
                                    PurchHead.Invoice := false;
                                    //TODO: PO was created from NAV13, 3PL File Sent was assumed to be done in NAV13, temporarily set it to true
                                    if not PurchHead."GXL 3PL File Sent" then begin
                                        PurchHead."GXL 3PL File Sent" := true;
                                        PurchHead."GXL 3PL File Sent Date" := Today();
                                    end;
                                    if PurchHead."GXL 3PL File Sent" then
                                        PurchHead."GXL 3PL File Receive" := true;
                                    if DT2Date(GlobalPDARecBuff."Entry Date Time") = 0D then
                                        PurchHead.Validate("Posting Date", DT2Date(GlobalPDARecBuff."Received from PDA"))
                                    else
                                        PurchHead.Validate("Posting Date", DT2Date(GlobalPDARecBuff."Entry Date Time"));
                                    //PS-2046+
                                    PurchHead."GXL MIM User ID" := GlobalPDARecBuff."MIM User ID";
                                    //PS-2046-
                                    PurchHead.Modify(true);
                                    Commit();

                                    AtLeastOneError := false;
                                    ProcessNonEDIScanQtys(0, AtLeastOneError);
                                    if not AtLeastOneError then begin
                                        Commit();
                                        Clear(PurchPost);
                                        ClearLastError();
                                        //TODO: PurchPost.SetPDAReceiving(); 
                                        if not PurchPost.Run(PurchHead) then begin
                                            ErrMsg := GetLastErrorText();
                                            SetPDARecBufferError(DocNo, GetLastErrorCode(), ErrMsg);
                                            if not IsSkipError(GetLastErrorCode(), ErrMsg) then
                                                GlobalNoOfErrors += 1;
                                        end else
                                            SetPDARecBufferClosed(DocNo);
                                    end else
                                        GlobalNoOfErrors += 1;
                                end;
                        end;
                    end else begin
                        if TransHead.Get(GlobalPDARecBuff."Document No.") then begin
                            if CheckOrderStatus(1, DummyPurchHeader, TransHead) then begin
                                //TODO: 3PL File Sent is from NAV13, temporary set to TRUE
                                if not TransHead."GXL 3PL File Sent" then begin
                                    TransHead."GXL 3PL File Sent" := true;
                                    TransHead."GXL 3PL File Sent Date" := Today();
                                end;
                                if TransHead."GXL 3PL File Sent" then
                                    TransHead."GXL 3PL File Receive" := true;
                                if DT2Date(GlobalPDARecBuff."Entry Date Time") = 0D then
                                    TransHead.Validate("Posting Date", DT2Date(GlobalPDARecBuff."Received from PDA"))
                                else
                                    TransHead.Validate("Posting Date", DT2Date(GlobalPDARecBuff."Entry Date Time"));
                                //PS-2046+
                                TransHead."GXL MIM User ID" := GlobalPDARecBuff."MIM User ID";
                                //PS-2046-
                                TransHead.Modify();
                                Commit();

                                AtLeastOneError := false;
                                ProcessNonEDIScanQtys(1, AtLeastOneError);
                                if not AtLeastOneError then begin
                                    Clear(TransOrdPostRcpt);
                                    ClearLastError();
                                    Commit();
                                    TransOrdPostRcpt.SetHideValidationDialog(true);
                                    if not TransOrdPostRcpt.Run(TransHead) then begin
                                        ErrMsg := GetLastErrorText();
                                        SetPDARecBufferError(DocNo, GetLastErrorCode(), ErrMsg);
                                    end else
                                        SetPDARecBufferClosed(DocNo);

                                end;
                            end;
                        end;
                    end;
                end;
            until GlobalPDARecBuff.Next() = 0;

    end;


    local procedure ReceivePerDoc(DocNo: Code[20])
    begin
        GlobalPDARecBuff.Reset();
        GlobalPDARecBuff.SetCurrentKey("Document No.", "Line No.");
        GlobalPDARecBuff.SetRange("Document No.", DocNo);
        GlobalPDARecBuff.SetRange(Processed, false);
        GlobalPDARecBuff.SetRange(Errored, false);

        ReceiveAll();
    end;

    ///<Summary>
    ///</Summary>
    local procedure FilterAndReceiveAll(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; ErrorOnly: Boolean)
    var
        TempDocumentSearchResult: Record "Document Search Result" temporary;
    begin
        PDAPLReceiveBuffer.Reset();
        //PS-2634 +
        //PDAPLReceiveBuffer.SetCurrentKey(Processed, Errored, "Document No.", "Line No.");
        PDAPLReceiveBuffer.SetCurrentKey(Processed, Status, "Document No.");
        //PS-2634 -
        PDAPLReceiveBuffer.SetRange(Processed, false);
        PDAPLReceiveBuffer.SetRange(Status, PDAPLReceiveBuffer.Status::Scanned); //PS-2634 +
        PDAPLReceiveBuffer.SetRange(Errored, false);
        if ErrorOnly then
            PDAPLReceiveBuffer.SetFilter("Error Message", '<>%1', '');

        GetUniqueDocumentNos(PDAPLReceiveBuffer, TempDocumentSearchResult);

        TempDocumentSearchResult.Reset();
        if TempDocumentSearchResult.FindSet() then
            repeat
                ReceivePerDoc(TempDocumentSearchResult."Doc. No.");
                Commit();
            until TempDocumentSearchResult.Next() = 0;
        TempDocumentSearchResult.DeleteAll();
    end;

    local procedure GetUniqueDocumentNos(var PDAPLReceiveBuffer: Record "GXL PDA-PL Receive Buffer"; var TempDocumentSearchResult: Record "Document Search Result" temporary)
    begin
        if PDAPLReceiveBuffer.FindSet() then
            repeat
                if not TempDocumentSearchResult.Get(0, PDAPLReceiveBuffer."Document No.", 0) then begin
                    TempDocumentSearchResult.Init();
                    TempDocumentSearchResult."Doc. Type" := 0;
                    TempDocumentSearchResult."Doc. No." := PDAPLReceiveBuffer."Document No.";
                    TempDocumentSearchResult."Table ID" := 0;
                    TempDocumentSearchResult.Insert();
                end;
                PDAPLReceiveBuffer.SetRange("Document No.", PDAPLReceiveBuffer."Document No.");
                PDAPLReceiveBuffer.FindLast();
                PDAPLReceiveBuffer.SetRange("Document No.");
            until PDAPLReceiveBuffer.Next() = 0;
    end;

    local procedure CheckOrderStatus(DocType: Option PO,"TO"; var PurchaseHeader: Record "Purchase Header"; var TransferHeader: Record "Transfer Header"): Boolean
    var
        PDACheckOrderStatus: Codeunit "GXL PDA-Check Order Status";
    begin
        Commit();
        PDACheckOrderStatus.SetOptions(DocType, PurchaseHeader, TransferHeader);
        if PDACheckOrderStatus.Run() then
            exit(PDACheckOrderStatus.GetResult())
        else
            exit(false);
    end;

    local procedure IsSkipError(CodeError: Text; StringError: Text): Boolean
    var
        SkipError: Boolean;
    begin
        if not GXLMiscUtilities.IsLockingError(CodeError) then begin
            SkipError :=
                (StrPos(StringError, 'already exists') <> 0) or (StrPos(StringError, 'does not exist') <> 0) or
                (StrPos(StringError, 'another user has modified') <> 0) or (StrPos(StringError, 'Another user has modified') <> 0);
            exit(SkipError);
        end else
            exit(true);
    end;

    local procedure SetPDARecBufferError(DocNo: Code[20]; ErrorCode: Text; ErrorText: Text)
    var
        PDARecBuff2: Record "GXL PDA-PL Receive Buffer";
        LockError: Boolean;
    begin
        LockError := IsSkipError(ErrorCode, ErrorText);

        PDARecBuff2.Reset();
        PDARecBuff2.SetCurrentKey("Document No.", "Line No.");
        PDARecBuff2.SetRange("Document No.", DocNo); //GlobalPDARecBuff."Document No.");
        if PDARecBuff2.FindSet() then
            repeat
                PDARecBuff2.Errored := not LockError;
                if PDARecBuff2.Errored then
                    PDARecBuff2.Status := PDARecBuff2.Status::"Processing Error";
                PDARecBuff2."Error Code" := CopyStr(ErrorCode, 1, MaxStrLen(PDARecBuff2."Error Code"));
                PDARecBuff2."Error Message" := CopyStr(ErrorText, 1, MaxStrLen(PDARecBuff2."Error Message"));
                PDARecBuff2.Modify();
            until PDARecBuff2.Next() = 0;

    end;

    local procedure SetPDARecBufferClosed(DocNo: Code[20])
    var
        PDARecBuff2: Record "GXL PDA-PL Receive Buffer";
    begin
        PDARecBuff2.Reset();
        PDARecBuff2.SetCurrentKey("Document No.", "Line No.");
        PDARecBuff2.SetRange("Document No.", DocNo); //GlobalPDARecBuff."Document No.");
        if PDARecBuff2.FindSet() then
            repeat
                PDARecBuff2.Errored := false;
                PDARecBuff2.Status := PDARecBuff2.Status::Closed;
                PDARecBuff2."Error Code" := '';
                PDARecBuff2."Error Message" := '';
                PDARecBuff2.Processed := true;
                PDARecBuff2."Processing Date Time" := CurrentDateTime();
                PDARecBuff2.Modify();
            until PDARecBuff2.Next() = 0;

    end;

    local procedure ProcessNonEDIScanQtys(DocType: Option PO,"TO"; var AtLeastOneError: Boolean)
    var
        PDARecBuff2: Record "GXL PDA-PL Receive Buffer";
        NonEDIProcessScannerQtys: Codeunit "GXL Non-EDI Process Scan Qtys";
    begin
        AtLeastOneError := false;
        PDARecBuff2.Reset();
        PDARecBuff2.SetCurrentKey("Document No.", "Line No.");
        PDARecBuff2.SetRange("Document No.", GlobalPDARecBuff."Document No.");
        if PDARecBuff2.FindSet() then
            repeat
                if PDARecBuff2."Receipt Type" = PDARecBuff2."Receipt Type"::Lines then begin
                    Commit();
                    ClearLastError();
                    if not NonEDIProcessScannerQtys.ValidatePDALine(PDARecBuff2, DocType) then begin
                        PDARecBuff2.Errored := not GXLMiscUtilities.IsLockingError(GetLastErrorCode());
                        PDARecBuff2.Status := PDARecBuff2.Status::"Processing Error";
                        PDARecBuff2."Error Code" := CopyStr(GetLastErrorCode(), 1, MaxStrLen(PDARecBuff2."Error Code"));
                        PDARecBuff2."Error Message" := CopyStr(GetLastErrorText(), 1, MaxStrLen(PDARecBuff2."Error Message"));
                        PDARecBuff2.Modify();
                        AtLeastOneError := true;
                    end;

                end;
            until PDARecBuff2.Next() = 0;

    end;

    local procedure SendError(NoOfErrors: Integer)
    var
        JobQueueEntrySendEnail: Codeunit "GXL Job Queue Entry-Send Email";
        ErrMsg: Text;
    begin
        if not IsNullGuid(GlobalJobQueueEntry.ID) then
            if GlobalJobQueueEntry."GXL Error Notif. Email Address" <> '' then begin
                ErrMsg := StrSubstNo('There are %1 orders could not be posted. Please check "Error Message" on the %2 for details',
                    NoOfErrors, GlobalPDARecBuff.TableCaption());
                // >> Upgrade
                //GlobalJobQueueEntry.SetErrorMessage(ErrMsg);
                GlobalJobQueueEntry.SetError(ErrMsg);
                // << Upgrade
                JobQueueEntrySendEnail.SetOptions(1, '', 0); //Error
                JobQueueEntrySendEnail.SendEmail(GlobalJobQueueEntry);
            end;
    end;

}