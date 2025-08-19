codeunit 50260 "GXL PDA-Purchase Receipt Int."
{
    Permissions = tabledata "Purchase Header" = m,
        tabledata "GXL PDA-PL Receive Buffer" = i,
        tabledata "GXL PDA-Purchase Lines" = i,
        tabledata "GXL ASN Header" = i,
        tabledata "GXL ASN Level 1 Line" = i,
        tabledata "GXL ASN Level 2 Line" = i,
        tabledata "GXL ASN Level 3 Line" = i,
        tabledata "GXL ASN Header Scan Log" = i,
        tabledata "GXL ASN Level 1 Line Scan Log" = i,
        tabledata "GXL ASN Level 2 Line Scan Log" = i,
        tabledata "GXL ASN Level 3 Line Scan Log" = i
        ;

    trigger OnRun()
    begin

    end;

    var
        // >> Upgrade
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        // << Upgrade
        inputStream: InStream;
        outputStream: OutStream;
        PDAType: Option Full,Lines;
        InvalidParmErr: Label 'Invalid parameter.';
        BarcodeCannotBlankMsg: Label 'Barcode cannot be blank';
        SSCCBarcodedAlreadyReceivedMsg: Label 'Barcode %1 is a SSCC but there is no valid ASN or the ASN has already been received.';
        POBarcodeAlreadyReceivedMsg: Label 'Barcode %1 is a Purchase Order number but the Purchase Order has already been received.';
        POBarcodeNotValidMsg: Label 'Barcode %1 is a Purchase Order number but the Purchase Order does not have a valid ASN.';
        BarcodeNotFoundMsg: Label 'Barcode %1 cannot be found in the system.';
        PONotConfirmedErr: Label 'PO No Confirmed';
        OrderNeedsAuditedErr: Label 'This Orders needs to be Audited';
        ASNFileNotReceivedErr: Label 'ASN File not received';

    local procedure SaveInputXml(xmlInput: BigText)
    begin
        // >> Upgrade
        //TempBlob.Blob.CreateOutStream(outputStream, TextEncoding::UTF16);
        TempBlob.CreateOutStream(outputStream, TextEncoding::UTF16);
        // << Upgrade
        xmlInput.Write(outputStream);
        // >> Upgrade
        //TempBlob.Blob.CreateInStream(inputStream, TextEncoding::UTF16);
        TempBlob.CreateInStream(inputStream, TextEncoding::UTF16);
        // << Upgrade
    end;

    procedure GetDocumentTypeOrNumber(Barcode: Text; GetWhich: Option "Document No.","Document Type"): Text
    begin
        exit(GetDocumentTypeOrNumber(Barcode, '', GetWhich));
    end;

    procedure GetDocumentTypeOrNumber(Barcode: Text; StoreCode: Code[10]; GetWhich: Option "Document No.","Document Type"): Text
    var
        ASNLevel1Line: Record "GXL ASN Level 1 Line";
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
        ASNHeader: Record "GXL ASN Header";
        PurchaseHeader: Record "Purchase Header";
        TransferHeader: Record "Transfer Header";
        DocumentType: Option ASN,"PO-CONTING","PO-MR",STO;
    begin
        //PS-1974: Added StoreCode
        if Barcode = '' then
            Error(BarcodeCannotBlankMsg);

        //The length of the Barcode must be less than or equal to 50, error otherwise
        if StrLen(Barcode) > MaxStrLen(ASNLevel1Line."Level 1 Code") then
            Error(BarcodeNotFoundMsg, Barcode);

        //Pallet
        ASNLevel1Line.SetCurrentKey("Level 1 Code", "Document No.", Status, "Document Type");
        ASNLevel1Line.SetRange("Level 1 Code", Barcode);
        ASNLevel1Line.SetRange(Status, ASNLevel1Line.Status::Processed);
        if not ASNLevel1Line.FindFirst() then begin
            ASNLevel1Line.SetRange(Status);
            if not ASNLevel1Line.IsEmpty() then
                Error(StrSubstNo(SSCCBarcodedAlreadyReceivedMsg, Barcode));

            //Box
            ASNLevel2Line.SetCurrentKey("Level 2 Code", "Document No.", Status, "Document Type");
            ASNLevel2Line.SetRange("Level 2 Code", Barcode);
            ASNLevel2Line.SetRange(Status, ASNLevel2Line.Status::Processed);
            if not ASNLevel2Line.FindFirst() then begin
                ASNLevel2Line.SetRange(Status);
                if not ASNLevel2Line.IsEmpty() then
                    Error(StrSubstNo(SSCCBarcodedAlreadyReceivedMsg, Barcode));
            end else begin
                //PS-1974+
                if StoreCode <> '' then begin
                    ASNHeader.Get(ASNHeader."Document Type"::Purchase, ASNLevel2Line."Document No.");
                    if ASNHeader."Ship-for Code" <> StoreCode then
                        Error('%1 does not belong to store %2', Barcode, StoreCode);
                end;
                //PS-1974-
                exit(GetDocumentTypeOrNumberResult(ASNLevel2Line."Document No.", DocumentType::ASN, GetWhich));
            end;
        end else begin
            //PS-1974+
            if StoreCode <> '' then begin
                ASNHeader.Get(ASNHeader."Document Type"::Purchase, ASNLevel1Line."Document No.");
                if ASNHeader."Ship-for Code" <> StoreCode then
                    Error('%1 does not belong to store %2', Barcode, StoreCode);
            end;
            //PS-1974-
            exit(GetDocumentTypeOrNumberResult(ASNLevel1Line."Document No.", DocumentType::ASN, GetWhich));
        end;

        //>> PS-1617
        //Reaching this point, the Barcode is either ASN number or Purchase order number
        //So the length of the Barcode must be less than or equal to 20, error otherwise
        if StrLen(Barcode) > MaxStrLen(ASNHeader."No.") then
            Error(BarcodeNotFoundMsg, Barcode);
        //<< PS-1617

        if ASNHeader.Get(ASNHeader."Document Type"::Purchase, Barcode) then begin
            //PS-1974+
            if StoreCode <> '' then begin
                if ASNHeader."Ship-for Code" <> StoreCode then
                    Error('%1 does not belong to store %2', Barcode, StoreCode);
            end;
            //PS-1974-
            if ASNHeader.Status = ASNHeader.Status::Processed then
                exit(GetDocumentTypeOrNumberResult(ASNHeader."No.", DocumentType::ASN, GetWhich))
            else
                Error(StrSubstNo(SSCCBarcodedAlreadyReceivedMsg, Barcode));
        end;

        if PurchaseHeader.Get(PurchaseHeader."Document Type"::Order, Barcode) then begin
            //PS-1974+
            if StoreCode <> '' then begin
                if PurchaseHeader."Location Code" <> StoreCode then
                    Error('Purchase Order %1 does not belong to store %2', Barcode, StoreCode);
            end;
            //PS-1974-

            //TODO: Order Status - PDA purchase receipt for P2P or EDI, Closed status is NOT accepted
            if PurchaseHeader."GXL Order Status" <> PurchaseHeader."GXL Order Status"::Closed then begin
                if (PurchaseHeader."GXL EDI Vendor Type" in [PurchaseHeader."GXL EDI Vendor Type"::VAN, PurchaseHeader."GXL EDI Vendor Type"::"Point 2 Point"]) or
                    (PurchaseHeader."GXL EDI Order") then begin
                    PurchaseHeader.CalcFields("GXL ASN Number");
                    if PurchaseHeader."GXL ASN Number" = '' then
                        Error(StrSubstNo(POBarcodeNotValidMsg, Barcode));

                    ASNHeader.Get(ASNHeader."Document Type"::Purchase, PurchaseHeader."GXL ASN Number");
                    if ASNHeader.Status = ASNHeader.Status::Processed then
                        exit(GetDocumentTypeOrNumberResult(ASNHeader."No.", DocumentType::ASN, GetWhich))
                    else
                        Error(StrSubstNo(POBarcodeNotValidMsg, Barcode));
                end else begin
                    if PurchaseHeader."GXL EDI Vendor Type" = PurchaseHeader."GXL EDI Vendor Type"::"Point 2 Point Contingency" then
                        exit(GetDocumentTypeOrNumberResult(PurchaseHeader."No.", DocumentType::"PO-CONTING", GetWhich))
                    else
                        exit(GetDocumentTypeOrNumberResult(PurchaseHeader."No.", DocumentType::"PO-MR", GetWhich));
                end;
            end else
                Error(StrSubstNo(POBarcodeAlreadyReceivedMsg, Barcode));
        end;

        if TransferHeader.Get(Barcode) then
            Error('STO Search Not Implemented');

        Error(StrSubstNo(BarcodeNotFoundMsg, Barcode));
    end;

    local procedure GetDocumentTypeOrNumberResult(DocumentNo: Text; DocumentType: Option ASN,"PO-CONTING","PO-MR",STO; GetWhich: Option "Document No.","Document Type"): Text
    var
    begin
        case GetWhich of
            GetWhich::"Document No.":
                exit(DocumentNo);

            GetWhich::"Document Type":
                exit(Format(DocumentType));

            else
                Error(InvalidParmErr);
        end;
    end;

    procedure ReceiveAll(PONumber: Code[20]): Text
    var
        PurchHead: Record "Purchase Header";
        TransHead: Record "Transfer Header";
        PDALines: Record "GXL PDA-Purchase Lines" temporary;
        DocType: Option Purchase,Transfer,Adjustment;
    begin
        //Changed as number series is different b/w LS and NAV13
        //if StrPos(PONumber, 'TO') <> 1 then begin 
        if StrPos(PONumber, 'TO') = 0 then begin
            if PurchHead.Get(PurchHead."Document Type"::Order, PONumber) then begin
                //TODO: Order Status - PDA Purchase receipt, only Confirmed status is accepted
                if PurchHead."GXL Order Status" = PurchHead."GXL Order Status"::Confirmed then begin
                    if PurchHead."GXL Audit Flag" then
                        Error(OrderNeedsAuditedErr);
                    if PurchHead."GXL Vendor File Exchange" or PurchHead."GXL EDI Order" then
                        PurchHead.TestField("GXL ASN File Received", true);
                end else
                    Error(PONotConfirmedErr);

            end else
                Error(PONotConfirmedErr);

            if AlreadyReceivedFull(PONumber) then
                Error('Purchase Order %1 has already been received', PONumber);

            InsertToPDARecBuffer(PDALines, PDAType::Full, PONumber, DocType::Purchase);
        end else begin
            TransHead.SetRange("No.", PONumber);
            if TransHead.FindFirst() then begin
                if TransHead."Last Shipment No." <> '' then begin
                    if AlreadyReceivedFull(PONumber) then
                        Error('Transfer Order %1 has already been received', PONumber);

                    if TransHead.GXL_CheckStoreToStoreTransfer() then
                        DocType := DocType::Adjustment
                    else
                        DocType := DocType::Transfer;
                    InsertToPDARecBuffer(PDALines, PDAType::Full, PONumber, DocType);

                end else
                    Error(ASNFileNotReceivedErr);
            end else
                Error('STO ' + PONumber + ' does not exist');
        end;
    end;

    procedure ReceiveAllLines(xmlInput: BigText)
    var
        NewTempPDAPurchaseLines: Record "GXL PDA-Purchase Lines" temporary;
        PDAPurchaseLines: Record "GXL PDA-Purchase Lines";
        xmlInbound: XmlPort "GXL PDA-Rec Purchase Lines";
    begin
        SaveInputXml(xmlInput);
        xmlInbound.SetSource(inputStream);
        xmlInbound.Import();
        xmlInbound.GetTempPDAPurchaseLines(NewTempPDAPurchaseLines);

        if NewTempPDAPurchaseLines.FindSet() then
            repeat
                PDAPurchaseLines := NewTempPDAPurchaseLines;
                GetPDAPurchLineDocumentType(PDAPurchaseLines, PDAPurchaseLines."Entry Type");
                PDAPurchaseLines.Insert(true); //PS-1418 - popualte Entry date time
            until NewTempPDAPurchaseLines.Next() = 0;
        NewTempPDAPurchaseLines.DeleteAll();
    end;

    procedure ReceiveAllLinesMR(xmlInput: BigText)
    var
        NewTempPDAPurchaseLines: Record "GXL PDA-Purchase Lines" temporary;
        PDAPurchaseLines: Record "GXL PDA-Purchase Lines";
        xmlInbound: XmlPort "GXL PDA-Rec Purchase Lines MR";
    begin
        SaveInputXml(xmlInput);
        xmlInbound.SetSource(inputStream);
        xmlInbound.Import();
        xmlInbound.GetTempPDAPurchaseLines(NewTempPDAPurchaseLines);

        if NewTempPDAPurchaseLines.FindSet() then
            repeat
                PDAPurchaseLines := NewTempPDAPurchaseLines;
                GetPDAPurchLineDocumentType(PDAPurchaseLines, PDAPurchaseLines."Entry Type");
                PDAPurchaseLines.Insert(true); //PS-1418 populate entry date time
            until NewTempPDAPurchaseLines.Next() = 0;
        NewTempPDAPurchaseLines.DeleteAll();
    end;

    procedure UpdateInvoiceMR(PONumber: Code[20]; InvoiceNumber: Code[35]; InvoiceTotal: Decimal; InvoiceDate: Date)
    var
        PurchHead: Record "Purchase Header";
    begin
        if PurchHead.Get(PurchHead."Document Type"::Order, PONumber) then begin
            PurchHead.Validate("Document Date", InvoiceDate);
            PurchHead."Vendor Invoice No." := InvoiceNumber;
            //PurchHead."GXL Total Value" := InvoiceTotal; //TODO: The "Total Value" is the calcfields, cannot be updated!
            PurchHead.Modify();
        end else
            Error('Not Found');
    end;

    procedure EDIGetASN(Barcode: Code[50]; StoreCode: Code[10]; var ASN: XmlPort "GXL PDA-EDI ASN Export"): Text
    var
        ASNHead: Record "GXL ASN Header";
        MiscUltilities: Codeunit "GXL Misc. Utilities";
        EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
        EDIAuditAdvanceShipNotice: Codeunit "GXL PDA-EDI Audit ASN";
        AuditAllowed: Boolean;
        AuditWasSuccess: Boolean;
        ASNNo: Code[20];
    begin
        //PS-1974: Added StoreCode
        ClearLastError();
        ASNNo := GetDocumentTypeOrNumber(Barcode, StoreCode, 0); //Get number
        ASNHead.Get(ASNHead."Document Type"::Purchase, ASNNo);
        ASNHead.CalcFields(Audit);
        ASNHead."PDA Audit" := ASNHead.Audit;

        if ASNHead.Audit then begin
            AuditAllowed := EDIFunctionsLibrary.IsAuditAllowed();
            if not AuditAllowed then begin
                AuditWasSuccess := EDIAuditAdvanceShipNotice.Run(ASNHead);
                if not AuditWasSuccess then begin
                    if MiscUltilities.IsLockingError(GetLastErrorCode()) then
                        ASNHead."PDA Audit" := false
                    else
                        exit(GetLastErrorText());
                end else
                    ASNHead."PDA Audit" := false;
            end;
        end;

        ASN.SetOptions(ASNHead."Document Type", ASNHead."No.", ASNHead."PDA Audit");
        exit('');
    end;

    procedure ImportASNQuantitesReceived(PDAReceivedASN: BigText)
    var
        inboundXML: XmlPort "GXL PDA-EDI ASN Import";
    begin
        SaveInputXml(PDAReceivedASN);
        inboundXML.SetSource(inputStream);
        inboundXML.Import();
    end;

    local procedure InsertToPDARecBuffer(var PDALines: Record "GXL PDA-Purchase Lines"; Type: Option Full,Lines; DocNo: Code[20]; DocType: Option Purchase,Transfer,Adjustment)
    var
        PDAPLRecBuff: Record "GXL PDA-PL Receive Buffer";
    begin
        PDAPLRecBuff.Init();
        if Type = Type::Lines then
            PDAPLRecBuff.TransferFields(PDALines)
        else begin
            PDAPLRecBuff."Document No." := DocNo;
            PDAPLRecBuff."Line No." := 10000;
        end;
        PDAPLRecBuff."Receipt Type" := Type;
        PDAPLRecBuff."Received from PDA" := CurrentDateTime();
        PDAPLRecBuff."Entry Type" := DocType;
        //PS-2046+
        PDAPLRecBuff."MIM User ID" := UserId();
        //PS-2046-
        if PDAPLRecBuff.Insert(true) then;

        if Type = Type::Lines then
            PDALines.Delete();
    end;

    local procedure AlreadyReceivedFull(DocNo: Code[20]): Boolean
    var
        PDAPLRecBuff: Record "GXL PDA-PL Receive Buffer";
    begin
        PDAPLRecBuff.SetCurrentKey("Document No.");
        PDAPLRecBuff.SetRange("Document No.", DocNo);
        PDAPLRecBuff.SetRange("Receipt Type", PDAPLRecBuff."Receipt Type"::Full);
        exit(not PDAPLRecBuff.IsEmpty());
    end;

    local procedure GetPDAPurchLineDocumentType(PDAPurchLine: Record "GXL PDA-Purchase Lines"; var DocType: Option Purchase,Transfer,Adjustment)
    var
        PurchHead: Record "Purchase Header";
        TransHead: Record "Transfer Header";
    begin
        if PurchHead.Get(PurchHead."Document Type"::Order, PDAPurchLine."Document No.") then
            DocType := DocType::Purchase
        else begin
            if TransHead.Get(PDAPurchLine."Document No.") then
                if TransHead.GXL_CheckStoreToStoreTransfer() then
                    DocType := DocType::Adjustment
                else
                    DocType := DocType::Transfer;
        end;
    end;
}