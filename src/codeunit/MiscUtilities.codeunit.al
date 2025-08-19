// 001 01.08.2024 KDU LCB-298 https://petbarnjira.atlassian.net/browse/LCB-298 - New codeunit created to define general functions
codeunit 50354 "GXL Misc. Utilities"
{
    // >> 001
    procedure GetCurrentInventoryPeriod(DateP: Date): Date
    begin
        // This function checks if the given date is closed in the inventory period. If it is closed, then this function returns First Day of the Current Inventory Period.
        // If the given date is open in the inventory period, then the function returns the same given date.
        if IsInvPeriodClosed(DateP) then
            exit(GetFirstDateOfFirstOpenInvPeriod())
        else
            exit(DateP);
    end;

    local procedure IsInvPeriodClosed(DateP: Date): Boolean
    var
        InventoryPeriodL: Record "Inventory Period";
    begin
        // This function will return true if the given date is falling under the closed inventory period.
        // If there is no record found with the date filter then the given date is considered to be open inventory period and hence the function returns false as default
        InventoryPeriodL.SetFilter("Ending Date", '>=%1', DateP);
        if InventoryPeriodL.FindFirst() then
            exit(InventoryPeriodL.Closed);

    end;

    local procedure GetFirstDateOfFirstOpenInvPeriod(): Date
    var
        InventoryPeriodL: Record "Inventory Period";
        InvEndDateL: Date;
    begin
        // This function will identify the current open inventory period. if there is not open inventory period, it picks the today date.
        // With the help of the Invoentory period date, system calculates and returns the first day of the open inventory period
        InventoryPeriodL.SetRange(Closed, true);
        if InventoryPeriodL.FindLast() then
            InvEndDateL := CalcDate('1D', InventoryPeriodL."Ending Date")
        else
            InvEndDateL := CalcDate('-CM', Today);
        exit(InvEndDateL);
    end;
    // << 001
    procedure IsLockingError(LockStr: Text): Boolean
    begin
        IF (LockStr = 'NDBCS:LockTimeout') OR (LockStr = 'NDBCS:Deadlock') THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    procedure CheckServerDirectory(VAR FilePathName: Text)
    var
        FileManagement: Codeunit "File Management";
        i: Integer;
        BackSlash: Text[1];
    begin
        i := STRLEN(FilePathName);
        BackSlash := COPYSTR(FilePathName, i);

        IF BackSlash <> '\' THEN
            FilePathName := FilePathName + '\';

        IF FilePathName <> '' THEN
            IF NOT FileManagement.ServerDirectoryExists(FilePathName) THEN
                ERROR(Text002Txt);
    end;

    procedure GetFirstDocumentNo(VendorNo: Code[20]; InputDocNo: Code[35]): Code[60]
    var
        IntegrationSetup: Record "GXL Integration Setup";
    begin
        IntegrationSetup.GET();
        IntegrationSetup.TESTFIELD("Suffix for EDI Document");
        EXIT(STRSUBSTNO(IntegrationSetup."NAV EDI Document No. Format", VendorNo, InputDocNo + IntegrationSetup."Suffix for EDI Document"));

    end;

    procedure GetNextVendorCRMemoNoPH(PDAPurchInvoiceNo: Code[35]; VendorNo: Code[20]): Code[35]
    var
        PurchHeader: Record "Purchase Header";

    begin
        PurchHeader.Reset();
        PurchHeader.SETCURRENTKEY("Vendor Cr. Memo No.");
        //PS-2613 +
        //PurchHeader.SETRANGE("Buy-from Vendor No.", VendorNo);
        PurchHeader.SETRANGE("Vendor Cr. Memo No.", PDAPurchInvoiceNo);
        PurchHeader.SetRange("Pay-to Vendor No.", VendorNo);
        //PS-2613 -
        IF PurchHeader.IsEmpty() THEN
            EXIT(PDAPurchInvoiceNo)
        ELSE
            EXIT(GetNextVendorCRMemoNoPH(INCSTR(PDAPurchInvoiceNo), VendorNo));
    end;

    procedure GetNextVendorCRMemoNoVLE(InvoiceNo: Code[35]; VendorNo: Code[20]): Code[35]
    var
        VendLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendLedgerEntry.Reset();
        VendLedgerEntry.SETCURRENTKEY("External Document No.");
        VendLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendLedgerEntry.SETRANGE("External Document No.", InvoiceNo);
        IF VendLedgerEntry.IsEmpty() THEN
            EXIT(InvoiceNo)
        ELSE
            EXIT(GetNextVendorCRMemoNoVLE(INCSTR(InvoiceNo), VendorNo));
    end;

    procedure AddOriginalDocNo(InputDocumentNo: Text; OriginalDocumentNo: Text): Text
    begin
        IF InputDocumentNo = '' THEN
            EXIT('');
        IF OriginalDocumentNo <> '' THEN
            EXIT(STRSUBSTNO(Text003Txt, InputDocumentNo, OriginalDocumentNo))
        ELSE
            EXIT(InputDocumentNo);
    end;

    procedure GetNextEDIDocumentNo(DocumentType: Option POR,ASN,INV) NewDocumentNo: Code[35]
    var
        IntegrationSetup: Record "GXL Integration Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesCode: Code[20];
    begin
        NoSeriesCode := '';
        IntegrationSetup.GET();
        CASE DocumentType OF
            DocumentType::POR:
                NoSeriesCode := IntegrationSetup."EDI POR No. Series";
            DocumentType::ASN:
                NoSeriesCode := IntegrationSetup."EDI ASN No. Series";
            DocumentType::INV:
                NoSeriesCode := IntegrationSetup."EDI Invoice No. Series";
        END;
        NewDocumentNo := '';
        CLEAR(NoSeriesMgt);
        NewDocumentNo := NoSeriesMgt.GetNextNo(NoSeriesCode, TODAY(), TRUE);
    end;

    procedure IsErrorEmailRequired(InputProcessWasSuccess: Boolean; InputLastErrorCode: Text): Boolean
    begin
        IF (NOT InputProcessWasSuccess) AND (NOT IsLockingError(InputLastErrorCode)) THEN
            EXIT(TRUE)
        ELSE
            EXIT(FALSE);
    end;

    procedure GetStoreDimensionValue(StoreCode: Code[10]; StoreDimCode: Code[20]): Code[20]
    var
        DefDim: Record "Default Dimension";
    begin
        if StoreDimCode = '' then
            exit('');

        DefDim.SetRange("Table ID", Database::"LSC Store");
        DefDim.SetRange("No.", StoreCode);
        DefDim.SetRange("Dimension Code", StoreDimCode);
        if DefDim.FindFirst() then
            exit(DefDim."Dimension Value Code")
        else
            exit('');
    end;

    procedure GetXMLFormattedText(InputText: Text): Text
    var
        TypeHelper: Codeunit "Type Helper";
    begin
        //DotNetString := InputText;
        // EXIT(DotNetString.Replace('&', '&amp;'));

        exit(TypeHelper.HtmlEncode(InputText));
    end;

    procedure FilterNameValueBuffer(VAR NameValueBuffer: Record "Name/Value Buffer"; VAR FilteredNameValueBuffer: Record "Name/Value Buffer"; PrefixFilter: Text; SufixFilter: Text)
    var
        FileManagement: Codeunit "File Management";
        Include: Boolean;
    begin
        IF NOT NameValueBuffer.ISTEMPORARY() THEN
            ERROR('NameValueBuffer must be temporary');
        IF NOT FilteredNameValueBuffer.ISTEMPORARY() THEN
            ERROR('FilteredNameValueBuffer must be temporary');
        FilteredNameValueBuffer.DELETEALL(FALSE);
        IF SufixFilter <> '' THEN
            NameValueBuffer.SETFILTER(Name, '*' + SufixFilter);
        IF NameValueBuffer.FIND('-') THEN
            REPEAT
                Include := TRUE;
                IF PrefixFilter <> '' THEN
                    Include := COPYSTR(FileManagement.GetFileName(NameValueBuffer.Name), 1, STRLEN(PrefixFilter)) = PrefixFilter;
                //IF SufixFilter <> '' THEN
                //  Include := COPYSTR(NameValueBuffer.Name,STRLEN(NameValueBuffer.Name) - STRLEN(SufixFilter) + 1) = SufixFilter;
                IF Include THEN BEGIN
                    FilteredNameValueBuffer.INIT();
                    FilteredNameValueBuffer.TRANSFERFIELDS(NameValueBuffer, TRUE);
                    FilteredNameValueBuffer.INSERT(FALSE);
                END;
            UNTIL NameValueBuffer.NEXT() = 0;
    end;

    //PS-2640 +
    procedure IsLockingError(LockErrorCode: Text; LockErrorText: Text): Boolean
    begin
        if IsLockingError(LockErrorCode) then
            exit(true)
        else
            exit(IsItemLedgerEntryExistError(LockErrorText));
    end;

    procedure IsItemLedgerEntryExistError(LockErrorText: Text): Boolean
    begin
        if LockErrorText.Contains('The record in table Item Ledger Entry already exists. Identification fields and values:') then
            exit(true)
        else
            exit(false);
    end;
    //P-2640 -

    var
        Text002Txt: Label 'Invalid file directory.';
        Text003Txt: Label '%1-%2';
}