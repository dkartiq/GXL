codeunit 50369 "GXL EDI-Import File"
{

    trigger OnRun()
    var
        FileVar: File;
    begin
        if IsAPI then begin
            if not XMLBlob.HasValue() then
                Error('API Message Log Payload Blob has no Value');

            XMLBlob.CreateInStream(InStreamVar);

            Import3PLFile();
        end
        else begin
            FileVar.OPEN(FileFullName);
            FileVar.CREATEINSTREAM(InStreamVar);

            IF ProcessEDIVendorType = ProcessEDIVendorType::"Point 2 Point" THEN BEGIN
                XMLPORT.IMPORT(XMLPortID, InStreamVar);
            END ELSE BEGIN
                IF "3PLEDI" THEN
                    Import3PLFile()
                ELSE
                    ImportEDIFile();
            END;
            FileVar.CLOSE();
        end;
    end;

    var
        ImportWhich: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS,IPOR;
        EDIFileLogEntryNo: Integer;
        ProcessEDIVendorType: Option " ","Point 2 Point",VAN,"3PL Supplier";
        XMLPortID: Integer;
        "3PLEDI": Boolean;
        FileFormat: Option " ",CSV,XML;
        InStreamVar: InStream;
        FileFullName: Text;
        XMLBlob: Codeunit "Temp Blob";
        IsAPI: Boolean;

    procedure SetOptions(ImportWhichNew: Option PO,POX,POR,ASN,INV,STKADJ,SHIPSTATUS,IPOR; FileFullNameNew: Text; EDIFileLogEntryNoNew: Integer)
    begin
        ImportWhich := ImportWhichNew;
        FileFullName := FileFullNameNew;
        EDIFileLogEntryNo := EDIFileLogEntryNoNew;
    end;

    procedure SetP2POptions(InputEDIVendorType: Option " ","Point 2 Point",VAN,"3PL Supplier"; FilePrefix: Text; FileFullNameNew: Text)
    var
        XMLPortTxt: Text;
        UnderScorePosition: Integer;
    begin
        XMLPortID := 0;
        ProcessEDIVendorType := InputEDIVendorType;
        UnderScorePosition := STRPOS(FilePrefix, '_');
        XMLPortTxt := COPYSTR(FilePrefix, 1, (UnderScorePosition - 1));
        EVALUATE(XMLPortID, XMLPortTxt);
        FileFullName := FileFullNameNew;
    end;

    procedure Set3PLOptions(FileFullNameNew: Text; InputFileFormat: Option; EDIFileLogEntryNoNew: Integer)
    var
    begin
        FileFormat := InputFileFormat;
        "3PLEDI" := TRUE;
        FileFullName := FileFullNameNew;
        EDIFileLogEntryNo := EDIFileLogEntryNoNew;
    end;

    procedure SetAPILogEntry(InAPILog: Record "API Message Log")
    var
        outStm: OutStream;
    begin
        IsAPI := true;

        FileFormat := FileFormat::XML;

        InAPILog.CalcFields("API Payload");

        XMLBlob.CreateOutStream(outStm);
        outStm.WriteText(InAPILog.PayloadToTextAsDecoded());

        if not XMLBlob.HasValue() then
            Error('API Message Log Payload Blob has no Value');
    end;

    procedure Import3PLFile()
    var
        EDI3PLASNXMLImport: XMLport "GXL EDI-PDA ASN Import";
        EDI3PLASNCSVImport: XMLport "GXLEDI Inbound Scanned ASN CSV";
    begin
        IF FileFormat = FileFormat::XML THEN BEGIN
            EDI3PLASNXMLImport.SetEDIFileLogEntryNo(EDIFileLogEntryNo);
            EDI3PLASNXMLImport.SETSOURCE(InStreamVar);
            EDI3PLASNXMLImport.Import();
        END ELSE BEGIN
            EDI3PLASNCSVImport.SetEDIFileLogEntryNo(EDIFileLogEntryNo);
            EDI3PLASNCSVImport.SETSOURCE(InStreamVar);
            EDI3PLASNCSVImport.Import();
        END;
    end;

    procedure ImportEDIFile()
    var
        EDIOrderResponse: XMLport "GXL EDI-Order Response";
        EDIAdvanceShippingNotice: XMLport "GXL EDI Inbound ASN";
        EDIInvoice: XMLport "GXL EDI-Invoice";
        IntlShipAdvice: XMLport "GXL International Shipping Adv";
        IntlPOAck: XMLport "GXL International PO Acknowldg";
    begin
        CASE ImportWhich OF
            ImportWhich::POR:
                BEGIN
                    EDIOrderResponse.SetEDIFileLogEntryNo(EDIFileLogEntryNo);
                    EDIOrderResponse.SETSOURCE(InStreamVar);
                    EDIOrderResponse.Import();
                END;
            ImportWhich::ASN:
                BEGIN
                    EDIAdvanceShippingNotice.SetEDIFileLogEntryNo(EDIFileLogEntryNo);
                    EDIAdvanceShippingNotice.SETSOURCE(InStreamVar);
                    EDIAdvanceShippingNotice.Import();
                END;
            ImportWhich::INV:
                BEGIN
                    EDIInvoice.SetEDIFileLogEntryNo(EDIFileLogEntryNo);
                    EDIInvoice.SETSOURCE(InStreamVar);
                    EDIInvoice.Import();
                END;
            ImportWhich::SHIPSTATUS:
                BEGIN
                    IntlShipAdvice.SetEDIFileLogEntryNo(EDIFileLogEntryNo);
                    IntlShipAdvice.SETSOURCE(InStreamVar);
                    IntlShipAdvice.Import();
                END;
            ImportWhich::IPOR:
                BEGIN
                    // PO Acknowledgement
                    IntlPOAck.SetEDIFileLogEntryNo(EDIFileLogEntryNo);
                    IntlPOAck.SETSOURCE(InStreamVar);
                    IntlPOAck.Import();
                END;
            ELSE
                EXIT;
        END;
    end;
}

