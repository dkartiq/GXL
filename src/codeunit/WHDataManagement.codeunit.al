// 001 HP2-Sprint2 Changes
codeunit 50355 "GXL WH Data Management"
{
    var
        IntegrationSetup: Record "GXL Integration Setup";
        _recPHtoExport: Record "Purchase Header";
        _recLocation: Record Location;
        ExportMngt: Codeunit "GXL Export Mngt.";
        SingleInstanceCU: Codeunit "GXL WMS Single Instance"; // >> 001 <<
        IntSetupGot: Boolean;
        gblStore: Code[10];
        varXmlFile: File;
        XMLBlob: Codeunit "Temp Blob";
        varInputStream: InStream;
        varOutputStream: OutStream;
        ErrorText: Text;
        InforFileName: Text;

    local procedure GetIntegrationSetup()
    begin
        if IntSetupGot then
            exit;
        IntegrationSetup.Get();
        IntSetupGot := true;
    end;

    procedure CheckDirectory(VAR FilePathName: Text)
    var
        i: Integer;
        BackSlash: Text[1];
    begin
        i := STRLEN(FilePathName);
        BackSlash := COPYSTR(FilePathName, i);

        IF BackSlash <> '\' THEN
            FilePathName := FilePathName + '\';
    end;

    procedure SetAPILogEntry(InAPILog: Record "API Message Log")
    var
        outStm: OutStream;
    begin
        InAPILog.CalcFields("API Payload");

        XMLBlob.CreateOutStream(outStm);
        outStm.WriteText(InAPILog.PayloadToTextAsDecoded());

        if not XMLBlob.HasValue() then
            Error('API Message Log Payload Blob has no Value');
    end;

    procedure AddSuffixes(FilePathName: Text) newFilePathName: Text
    var
        i: Integer;
        FileName: Text;
        FileExtension: Text;
    begin
        GetIntegrationSetup();
        i := STRLEN(FilePathName);
        newFilePathName := FilePathName;
        FileExtension := COPYSTR(FilePathName, i - 3, i);
        FileName := COPYSTR(FilePathName, 1, i - 4);

        newFilePathName := FileName + '_' + ExportMngt.FormatDateValue(Today(), IntegrationSetup."Date Format", 0) +
                         ExportMngt.FormatTimeValue(TIME(), IntegrationSetup."Time Format", 0) + FileExtension;

        EXIT(newFilePathName);
    end;

    procedure InboundFileCheck(p_Code: Code[20]; XmlPortID: Integer): Boolean
    var
        _recFileSetup: Record "GXL 3Pl File Setup";
    begin
        _recFileSetup.SETRANGE(Code, p_Code);
        _recFileSetup.SETRANGE(Direction, _recFileSetup.Direction::Inbound);
        _recFileSetup.SETRANGE(_recFileSetup."XML Port", XmlPortID);
        IF not _recFileSetup.IsEmpty() THEN
            EXIT(TRUE);

        EXIT(FALSE);
    end;

    procedure SetStorereason(VAR Storew: Code[10])
    begin
        gblStore := Storew;
    end;

    procedure Load3PLFile(XML_ID: Integer; InforFileName: Text[1024])
    var
        XMLPortSOH: XmlPort "GXL WH-Daily-SOH";
        XMLPortAdj: XmlPort "GXL WH-Item Adjsutments";
        XMLPortSOHv2: XmlPort "GXL WH-Daily-SOH v2";
        XMLPortADJv2: XmlPort "GXL WH-Item Adjustments v2";
        XMLSalesOrder: XmlPort "GXL WH Sales Order";
    begin
        ClearLastError();

        varXmlFile.OPEN(InforFileName);
        varXmlFile.CREATEINSTREAM(varInputStream);
        case XML_ID of
            xmlport::"GXL WH-Daily-SOH": //50273
                begin
                    CLEAR(XMLPortSOH);
                    XMLPortSOH.SetXmlFilter(gblStore);
                    XMLPortSOH.SETSOURCE(varInputStream);
                    XMLPortSOH.IMPORT();
                end;
            Xmlport::"GXL WH-Item Adjsutments": //50272
                begin
                    CLEAR(XMLPortAdj);
                    XMLPortAdj.SetXmlFilter(gblStore);
                    XMLPortAdj.SETSOURCE(varInputStream);
                    XMLPortAdj.IMPORT();
                end;
            Xmlport::"GXL WH-Daily-SOH v2": //50097
                begin
                    CLEAR(XMLPortSOHv2);
                    XMLPortSOHv2.SetXmlFilter(gblStore);
                    XMLPortSOHv2.SETSOURCE(varInputStream);
                    XMLPortSOHv2.IMPORT();
                end;
            Xmlport::"GXL WH-Item Adjustments v2": //50094
                begin
                    CLEAR(XMLPortADJv2);
                    XMLPortADJv2.SetXmlFilter(gblStore);
                    XMLPortADJv2.SETSOURCE(varInputStream);
                    XMLPortADJv2.IMPORT();
                end;
            //WMSVD-002->>----------------------------------
            Xmlport::"GXL WH Sales Order": //50006
                begin
                    CLEAR(XMLSalesOrder);
                    XMLSalesOrder.SetLocation(gblStore);
                    XMLSalesOrder.SETSOURCE(varInputStream);
                    XMLSalesOrder.IMPORT();
                end;
            //<<-WMSVD-002---------------------------
            else
                XMLPORT.IMPORT(XML_ID, varInputStream);
        end;

        varXmlFile.CLOSE();
        ErrorText := GetLastErrorText();
    end;

    procedure Load3PLFileForAPIMsgLog(XML_ID: Integer)
    var
        XMLPortSOH: XmlPort "GXL WH-Daily-SOH";
        XMLPortAdj: XmlPort "GXL WH-Item Adjsutments";
        XMLPortSOHv2: XmlPort "GXL WH-Daily-SOH v2";
        XMLPortADJv2: XmlPort "GXL WH-Item Adjustments v2";
        XMLSalesOrder: XmlPort "GXL WH Sales Order";
    begin
        ClearLastError();

        XMLBlob.CREATEINSTREAM(varInputStream);
        case XML_ID of
            xmlport::"GXL WH-Daily-SOH": //50273
                begin
                    CLEAR(XMLPortSOH);
                    XMLPortSOH.SetXmlFilter(gblStore);
                    XMLPortSOH.SETSOURCE(varInputStream);
                    XMLPortSOH.IMPORT();
                end;
            Xmlport::"GXL WH-Item Adjsutments": //50272
                begin
                    CLEAR(XMLPortAdj);
                    XMLPortAdj.SetXmlFilter(gblStore);
                    XMLPortAdj.SETSOURCE(varInputStream);
                    XMLPortAdj.IMPORT();
                end;
            Xmlport::"GXL WH-Daily-SOH v2": //50097
                begin
                    CLEAR(XMLPortSOHv2);
                    XMLPortSOHv2.SetXmlFilter(gblStore);
                    XMLPortSOHv2.SETSOURCE(varInputStream);
                    XMLPortSOHv2.IMPORT();
                end;
            Xmlport::"GXL WH-Item Adjustments v2": //50094
                begin
                    CLEAR(XMLPortADJv2);
                    XMLPortADJv2.SetXmlFilter(gblStore);
                    XMLPortADJv2.SETSOURCE(varInputStream);
                    XMLPortADJv2.IMPORT();
                end;
            //WMSVD-002->>----------------------------------
            Xmlport::"GXL WH Sales Order": //50006
                begin
                    CLEAR(XMLSalesOrder);
                    XMLSalesOrder.SetLocation(gblStore);
                    XMLSalesOrder.SETSOURCE(varInputStream);
                    XMLSalesOrder.IMPORT();
                end;
            //<<-WMSVD-002---------------------------
            else
                XMLPORT.IMPORT(XML_ID, varInputStream);
        end;

        ErrorText := GetLastErrorText();
    end;

    procedure LoadVendorFile(XML_ID: Integer; InforFileName: Text[1024]): Text[1024]
    begin
        ClearLastError();
        varXmlFile.OPEN(InforFileName);
        varXmlFile.CREATEINSTREAM(varInputStream);
        XMLPORT.IMPORT(XML_ID, varInputStream);
        varXmlFile.CLOSE();
        ErrorText := GetLastErrorText();
        EXIT(ErrorText);
    end;

    procedure VendorFileCheck(VAR PH: Record "Purchase Header")
    var
        _recVendor: Record Vendor;
        _recFileSetup: Record "GXL 3Pl File Setup";
    begin
        InforFileName := '';
        IntegrationSetup.Get();
        _recFileSetup.SETRANGE(Code, PH."Buy-from Vendor No.");
        _recFileSetup.SETRANGE(Direction, _recFileSetup.Direction::Outbound);
        IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::SD THEN
            _recFileSetup.SETRANGE(Type, _recFileSetup.Type::SD);
        IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::WH THEN
            _recFileSetup.SETRANGE(Type, _recFileSetup.Type::WH);
        IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::FT THEN
            _recFileSetup.SETRANGE(Type, _recFileSetup.Type::FT);
        IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::XD THEN
            _recFileSetup.SETRANGE(Type, _recFileSetup.Type::XD);
        IF _recFileSetup.FindFirst() THEN BEGIN

            ExportVendorFile(_recFileSetup."XML Port", PH, FORMAT(_recFileSetup."File Format"));
            PH."GXL Supplier File PO No." := PH."Location Code" + '-' + PH."No.";

            PH."GXL Vendor File Sent" := TRUE;
            PH."GXL Vendor File Sent Date" := Today();
        END ELSE BEGIN
            _recVendor.Reset();
            _recVendor.GET(PH."Buy-from Vendor No.");

            CASE _recVendor."GXL PO File Format" OF
                _recVendor."GXL PO File Format"::XML:
                    ExportVendorFile(IntegrationSetup."PO XMLPort ID", PH, 'XML');
                _recVendor."GXL PO File Format"::Excel:
                    BEGIN
                        ExportVendorExcelFile(PH);
                        PH."GXL Supplier File PO No." := PH."Location Code" + '-' + PH."No.";
                        PH."GXL Vendor File Sent" := TRUE;
                        PH."GXL Vendor File Sent Date" := Today();
                    END;
                _recVendor."GXL PO File Format"::"Excel Document":
                    ExportVendorFileExcelDoc(PH);
                _recVendor."GXL PO File Format"::"PDF Document":
                    ExportVendorFilePDFDoc(PH);
            END;
        END;
    end;

    local procedure ExportVendorFile(XML_ID: Integer; PH: Record "Purchase Header"; FileFormat: Text[10])
    var
        Vendor: Record Vendor;
        // >> 001
        Location: Record Location;
        FileMgt: Codeunit "File Management";
        FileName: Text;
        FinalDestination: Text;
    // << 001
    begin
        // >> 001 << Uncomment the function.
        //TODO: Not applicable
        // exit;
        IntegrationSetup.Get();

        IF Vendor.GET(PH."Buy-from Vendor No.") THEN BEGIN

            IF Vendor."GXL EDI Outbound Directory" = '' THEN
                Vendor."GXL EDI Outbound Directory" := IntegrationSetup."Default Error Dir. P2P";
            CheckDirectory(Vendor."GXL EDI Outbound Directory");

            _recPHtoExport.Reset();
            _recPHtoExport.SETRANGE(_recPHtoExport."Document Type", PH."Document Type");
            _recPHtoExport.SETRANGE(_recPHtoExport."No.", PH."No.");
            IF NOT _recPHtoExport.FindFirst() THEN
                EXIT;
            IF InforFileName = '' THEN BEGIN
                InforFileName := Vendor."GXL EDI Outbound Directory" + 'PO-' + _recPHtoExport."Location Code" + '-' + _recPHtoExport."No." + '.' + FileFormat;
                SingleInstanceCU.SetVendorExportFileName(InforFileName);
            END;

            varXmlFile.CREATE(InforFileName);
            varXmlFile.CREATEOUTSTREAM(varOutputStream);
            XMLPORT.EXPORT(XML_ID, varOutputStream, _recPHtoExport);
            varXmlFile.CLOSE();
        END;
    end;

    local procedure ExportVendorExcelFile(PurchaseHeader: Record "Purchase Header")
    var

        _recVendor: Record Vendor;
        TempExcelBuffer: Record "Excel Buffer" temporary;
        PurchaseLine: Record "Purchase Line";
        CompanyInfo: Record "Company Information";
        FileManagement: Codeunit "File Management";

        RowNo: Integer;
        ColumnNo: Integer;
        ServerFileName: Text;

    begin
        //TODO: Not applicable
        // exit;
        // >> 001 << Uncomment the function.
        IntegrationSetup.Get();
        IntegrationSetup.TESTFIELD("Default Error Dir. P2P");

        IF _recVendor.GET(PurchaseHeader."Buy-from Vendor No.") THEN BEGIN

            IF _recVendor."GXL EDI Outbound Directory" = '' THEN
                _recVendor."GXL EDI Outbound Directory" := IntegrationSetup."Default Error Dir. P2P";
            CheckDirectory(_recVendor."GXL EDI Outbound Directory");
            CompanyInfo.GET();

            PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
            PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
            PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
            PurchaseLine.SETFILTER(Quantity, '<>%1', 0);
            IF PurchaseLine.FINDSET() THEN BEGIN

                RowNo := 1;
                ColumnNo := 1;

                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Purchase Order No.', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;

                // >> pv00.03
                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Company Name', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;
                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'ABN', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;
                // << pv00.03

                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Ship to', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;
                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Order Date', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;
                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Required Delivery Date', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;
                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Vendor Invoice No.', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;

                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Qty', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;

                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Supplier Item No.', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;

                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'PB ILC', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;

                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Description', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;

                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Unit Price', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;

                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Total', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                ColumnNo += 1;

                EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'Tax %', TRUE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);

                RowNo := 2;
                PurchaseHeader.CALCFIELDS(Amount, "Amount Including VAT");

                REPEAT
                    ColumnNo := 1;
                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, PurchaseLine."Location Code" + '-' + PurchaseLine."Document No.", FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                    ColumnNo += 1;
                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, CompanyInfo.Name, FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, 'ABN: ' + CompanyInfo.ABN, FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, PurchaseHeader."Ship-to Name" + ' ' + PurchaseHeader."Ship-to Address" + ' ' +
                              PurchaseHeader."Ship-to City" + ', ' + PurchaseHeader."Ship-to Post Code" + ' Phone: ' + ' Fax: ' + ' Contact: ', FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, FORMAT(PurchaseHeader."Order Date"), FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Date);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, FORMAT(PurchaseHeader."Expected Receipt Date"), FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Date);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, PurchaseHeader."Vendor Invoice No.", FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, FORMAT(PurchaseLine.Quantity), FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Number);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, PurchaseLine."GXL Vendor Reorder No.", FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, PurchaseLine."No.", FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, PurchaseLine.Description, FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Text);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, FORMAT(PurchaseLine."Direct Unit Cost"), FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Number);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, FORMAT(PurchaseLine."Line Amount"), FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Number);
                    ColumnNo += 1;

                    EnterCell(TempExcelBuffer, RowNo, ColumnNo, FORMAT(PurchaseLine."VAT %"), FALSE, FALSE, TRUE, '', TempExcelBuffer."Cell Type"::Number);
                    ColumnNo += 1;

                    RowNo += 1;

                UNTIL PurchaseLine.NEXT() = 0;
                ServerFileName := FileManagement.ServerTempFileName('xlsx');
                TempExcelBuffer.CreateBook(ServerFileName, PurchaseHeader."No.");
                TempExcelBuffer.WriteSheet(PurchaseHeader."No.", COMPANYNAME(), USERID());
                TempExcelBuffer.CloseBook();
                // InforFileName := FileManagement.ServerTempFileName(FileManagement.GetExtension(ServerFileName));
                // FileManagement.CopyServerFile(ServerFileName, InforFileName, TRUE);
                // FileManagement.DeleteServerFile(ServerFileName);
                SingleInstanceCU.SetVendorExportFileName(ServerFileName);

            END;

        END;

    end;

    local procedure EnterCell(VAR TempExcelBuffer: Record "Excel Buffer" temporary; RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; Italic: Boolean; UnderLine: Boolean; Format: Text[30]; CellType: Option)
    begin
        TempExcelBuffer.INIT();
        TempExcelBuffer.VALIDATE("Row No.", RowNo);
        TempExcelBuffer.VALIDATE("Column No.", ColumnNo);
        TempExcelBuffer."Cell Value as Text" := CellValue;
        TempExcelBuffer.Formula := '';
        TempExcelBuffer.Bold := Bold;
        TempExcelBuffer.Italic := Italic;
        TempExcelBuffer.Underline := UnderLine;
        TempExcelBuffer.NumberFormat := Format;
        TempExcelBuffer."Cell Type" := CellType;
        TempExcelBuffer.INSERT();
    end;

    local procedure ExportVendorFileExcelDoc(VAR PH: Record "Purchase Header")

    begin
        ExportVendorFileDoc(PH, 0);
    end;

    local procedure ExportVendorFilePDFDoc(VAR PH: Record "Purchase Header")
    begin
        ExportVendorFileDoc(PH, 1);
    end;

    local procedure ExportVendorFileDoc(VAR PH: Record "Purchase Header"; FileType: Option Excel,PDF)
    var

        Vendor: Record Vendor;
        CustomReportSelect: Record "Custom Report Selection";
        ReportSelections: Record "Report Selections";
        ReportLayoutSelection: Record "Report Layout Selection";
        ReportID: Integer;
        LayoutCode: Code[20];
        ExtensionText: Text[10];

    begin
        //TODO: Not applicable
        // PH."GXL Supplier File PO No." := PH."Location Code" + '-' + PH."No.";
        // PH."GXL Vendor File Sent" := TRUE;
        // PH."GXL Vendor File Sent Date" := Today();
        // exit;
        // >> 001 << uncomment the function.
        GetIntegrationSetup();

        IF Vendor.GET(PH."Buy-from Vendor No.") THEN BEGIN

            IF Vendor."GXL EDI Outbound Directory" = '' THEN
                Vendor."GXL EDI Outbound Directory" := IntegrationSetup."Default Error Dir. P2P";

            CheckDirectory(Vendor."GXL EDI Outbound Directory");

            _recPHtoExport.Reset();
            _recPHtoExport.SETRANGE(_recPHtoExport."Document Type", PH."Document Type");
            _recPHtoExport.SETRANGE(_recPHtoExport."No.", PH."No.");
            IF NOT _recPHtoExport.FindFirst() THEN
                EXIT;
            case FileType of
                FileType::Excel:
                    ExtensionText := 'xlsx';
                FileType::PDF:
                    ExtensionText := 'pdf';
            end;

            IF InforFileName = '' THEN BEGIN
                InforFileName := Vendor."GXL EDI Outbound Directory" + 'PO-' + _recPHtoExport."Location Code" + '-' + _recPHtoExport."No." + '.' + ExtensionText;
                SingleInstanceCU.SetVendorExportFileName(InforFileName);
            END;
            // >> HP2-SPRINT2
            // CustomReportSelect.SetRange("Source Type", Database::Vendor);
            // CustomReportSelect.SetRange("Source No.", Vendor."No.");
            // CustomReportSelect.SetRange(Usage, CustomReportSelect.Usage::"P.Order");
            // if CustomReportSelect.FindFirst() then begin
            //     ReportID := CustomReportSelect."Report ID";
            //     LayoutCode := CustomReportSelect."Custom Report Layout Code";
            // end;
            // if ReportID = 0 then begin
            //     ReportSelections.SetRange(Usage, ReportSelections.Usage::"P.Order");
            //     ReportSelections.FindFirst();
            //     ReportSelections.TestField("Report ID");
            //     ReportID := ReportSelections."Report ID";
            //     LayoutCode := ReportSelections."Custom Report Layout Code";
            // end;
            // ReportLayoutSelection.SetTempLayoutSelected(LayoutCode);
            // case FileType of
            //     FileType::Excel:
            //         REPORT.SaveAsExcel(405, InforFileName, PH);
            //     FileType::PDF:
            //         Report.SaveAsPdf(405, InforFileName, PH);
            // end;
            // ReportLayoutSelection.SetTempLayoutSelected('');


            //   IF PH."Domestic Order" THEN BEGIN // TODO After creating a page for domestic order
            case FileType of
                FileType::Excel:
                    begin
                        IF not PH."GXL International Order" THEN BEGIN
                            IF PH."GXL Source of Supply" IN [PH."GXL Source of Supply"::SD, PH."GXL Source of Supply"::FT, PH."GXL Source of Supply"::WH] THEN
                                REPORT.SAVEASEXCEL(Report::"GXL Domestic Purch. Order", InforFileName, PH)
                            ELSE
                                REPORT.SAVEASEXCEL(Report::"GXL Purch Order XD", InforFileName, PH);
                        END ELSE
                            REPORT.SAVEASEXCEL(Report::"International Purchase Order", InforFileName, PH);
                    end;
                FileType::PDF:
                    begin
                        IF not PH."GXL International Order" THEN BEGIN
                            IF PH."GXL Source of Supply" IN [PH."GXL Source of Supply"::SD, PH."GXL Source of Supply"::FT, PH."GXL Source of Supply"::WH] THEN
                                REPORT.SaveAsPdf(Report::"GXL Domestic Purch. Order", InforFileName, PH)
                            ELSE
                                REPORT.SaveAsPdf(Report::"GXL Purch Order XD", InforFileName, PH);
                        END ELSE
                            REPORT.SaveAsPdf(Report::"International Purchase Order", InforFileName, PH);
                    end;
            end;
            // << HP2-SPRINT2

            PH."GXL Supplier File PO No." := PH."Location Code" + '-' + PH."No.";
            PH."GXL Vendor File Sent" := TRUE;
            PH."GXL Vendor File Sent Date" := Today();
        END;

    end;

    procedure "3PLFilePurchaseCheck"(VAR PH: Record "Purchase Header")
    var
        _recFileSetup: Record "GXL 3Pl File Setup";
    begin
        _recFileSetup.Reset();
        _recFileSetup.SETRANGE(Code, PH."Location Code");
        _recFileSetup.SETRANGE("Table ID", Database::"Purchase Header");
        _recFileSetup.SETRANGE(Direction, _recFileSetup.Direction::Outbound);
        IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::SD THEN
            _recFileSetup.SETRANGE("3PL Types", _recFileSetup."3PL Types"::SD);
        IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::WH THEN
            _recFileSetup.SETRANGE("3PL Types", _recFileSetup."3PL Types"::WH);
        IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::FT THEN
            _recFileSetup.SETRANGE("3PL Types", _recFileSetup."3PL Types"::FT);
        IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::XD THEN
            _recFileSetup.SETRANGE("3PL Types", _recFileSetup."3PL Types"::XD);
        IF _recFileSetup.FindFirst() THEN BEGIN
            IF _recLocation.GET(PH."Location Code") THEN
                IF _recLocation."GXL Outbound File Path" <> '' THEN
                    Export3PlFile(_recFileSetup."XML Port", PH, FORMAT(_recFileSetup."File Format"));
            PH."GXL 3PL File Sent" := TRUE;
            PH."GXL 3PL File Sent Date" := Today();
        END ELSE
            PH."GXL 3PL File Sent" := FALSE;

    end;

    local procedure Export3PlFile(XML_ID: Integer; PH: Record "Purchase Header"; FileFormat: Text[10])
    begin
        CheckDirectory(_recLocation."GXL Outbound File Path");
        _recPHtoExport.Reset();
        _recPHtoExport.SETRANGE(_recPHtoExport."Document Type", _recPHtoExport."Document Type"::Order);
        _recPHtoExport.SETRANGE(_recPHtoExport."No.", PH."No.");
        IF NOT _recPHtoExport.FindFirst() THEN
            EXIT;

        InforFileName := _recLocation."GXL Outbound File Path" + FORMAT(XML_ID) + '_' + _recLocation.Code + '_' + _recPHtoExport."No." + '.' + FileFormat;
        varXmlFile.CREATE(InforFileName);
        varXmlFile.CREATEOUTSTREAM(varOutputStream);
        XMLPORT.EXPORT(XML_ID, varOutputStream, _recPHtoExport);
        varXmlFile.CLOSE();
    end;

    procedure "3PLFileTransferCheck"(VAR TH: Record "Transfer Header")
    var
        _recFileSetup: Record "GXL 3Pl File Setup";
    begin
        _recFileSetup.Reset();
        _recFileSetup.SETRANGE(Code, TH."Transfer-from Code");
        _recFileSetup.SETRANGE(_recFileSetup."Table ID", Database::"Transfer Header");

        _recFileSetup.SETRANGE(Direction, _recFileSetup.Direction::Outbound);
        IF TH."GXL Source of Supply" = TH."GXL Source of Supply"::SD THEN
            _recFileSetup.SETRANGE("3PL Types", _recFileSetup."3PL Types"::SD);
        IF TH."GXL Source of Supply" = TH."GXL Source of Supply"::WH THEN
            _recFileSetup.SETRANGE("3PL Types", _recFileSetup."3PL Types"::WH);
        IF TH."GXL Source of Supply" = TH."GXL Source of Supply"::FT THEN
            _recFileSetup.SETRANGE("3PL Types", _recFileSetup."3PL Types"::FT);
        IF TH."GXL Source of Supply" = TH."GXL Source of Supply"::XD THEN
            _recFileSetup.SETRANGE("3PL Types", _recFileSetup."3PL Types"::XD);
        IF _recFileSetup.FindFirst() THEN BEGIN
            IF _recLocation.GET(TH."Transfer-from Code") THEN
                IF _recLocation."GXL Outbound File Path" <> '' THEN
                    Export3PlFileTransfer(_recFileSetup."XML Port", TH, FORMAT(_recFileSetup."File Format"));

            TH."GXL 3PL File Sent" := TRUE;
            TH."GXL 3PL File Sent Date" := Today();
        END ELSE
            TH."GXL 3PL File Sent" := FALSE;
    end;

    local procedure Export3PlFileTransfer(XML_ID: Integer; PH: Record "Transfer Header"; FileFormat: Text[10])
    var
        _recTHExport: Record "Transfer Header";
        Location: Record Location;
    begin
        //TODO: not applicable
        // exit;


        CheckDirectory(_recLocation."GXL Outbound File Path");

        _recTHExport.Reset();
        _recTHExport.SETRANGE("No.", PH."No.");
        IF NOT _recTHExport.FindFirst() THEN
            EXIT;

        Location.GET(PH."Transfer-from Code");
        InforFileName := _recLocation."GXL Outbound File Path" + Location."GXL Send File Name Prefix" + FORMAT(XML_ID) + '_' + _recLocation.Code + '_' + _recTHExport."No." + '.' + FileFormat;

        varXmlFile.CREATE(InforFileName);
        varXmlFile.CREATEOUTSTREAM(varOutputStream);
        XMLPORT.EXPORT(XML_ID, varOutputStream, _recTHExport);
        varXmlFile.CLOSE();

    end;

    procedure CreateVendorFile(VAR PH: Record "Purchase Header"; VAR DocFileName: Text): Text
    var
        _recVendor: Record Vendor;
        _recFileSetup: Record "GXL 3Pl File Setup";
        FileManagement: Codeunit "File Management";
    begin
        DocFileName := '';
        InforFileName := '';
        GetIntegrationSetup();
        _recVendor.Reset();

        IF _recVendor.GET(PH."Buy-from Vendor No.") THEN BEGIN

            IF _recVendor."GXL EDI Outbound Directory" = '' THEN
                _recVendor."GXL EDI Outbound Directory" := IntegrationSetup."Vendor Error Directory";

            CheckDirectory(_recVendor."GXL EDI Outbound Directory");
            _recPHtoExport.Reset();
            _recPHtoExport.SETRANGE(_recPHtoExport."Document Type", PH."Document Type");
            _recPHtoExport.SETRANGE(_recPHtoExport."No.", PH."No.");
            IF NOT _recPHtoExport.FindFirst() THEN
                EXIT;

            DocFileName := 'PO-' + _recPHtoExport."Location Code" + '-' + _recPHtoExport."No.";

            _recFileSetup.Reset();
            _recFileSetup.SETRANGE(Code, _recVendor."No.");
            _recFileSetup.SETRANGE(Direction, _recFileSetup.Direction::Outbound);
            IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::SD THEN
                _recFileSetup.SETRANGE(Type, _recFileSetup.Type::SD);
            IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::WH THEN
                _recFileSetup.SETRANGE(Type, _recFileSetup.Type::WH);
            IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::FT THEN
                _recFileSetup.SETRANGE(Type, _recFileSetup.Type::FT);
            IF PH."GXL Source of Supply" = PH."GXL Source of Supply"::XD THEN
                _recFileSetup.SETRANGE(Type, _recFileSetup.Type::XD);
            IF _recFileSetup.FindFirst() THEN BEGIN
                InforFileName := FileManagement.ServerTempFileName(FORMAT(_recFileSetup."File Format"));

                IF FILE.EXISTS(InforFileName) THEN
                    IF FILE.ERASE(InforFileName) THEN;
                ExportVendorFile(_recFileSetup."XML Port", PH, FORMAT(_recFileSetup."File Format"));
            END ELSE BEGIN


                CASE _recVendor."GXL PO File Format" OF
                    _recVendor."GXL PO File Format"::XML:
                        BEGIN
                            InforFileName := FileManagement.ServerTempFileName('XML');

                            IF FILE.EXISTS(InforFileName) THEN
                                IF FILE.ERASE(InforFileName) THEN;
                            ExportVendorFile(IntegrationSetup."PO XMLPort ID", PH, 'XML');
                        END;
                    _recVendor."GXL PO File Format"::Excel:
                        begin
                            ExportVendorExcelFile(PH);
                            InforFileName := SingleInstanceCU.GetVendorExportFileName(); // >> 001 <<
                        end;
                    _recVendor."GXL PO File Format"::"Excel Document":
                        ExportVendorFileExcelDoc(PH);
                    _recVendor."GXL PO File Format"::"PDF Document":
                        ExportVendorFilePDFDoc(PH);
                END;
            END;
        END;

        IF InforFileName = '' THEN
            EXIT('');

        IF FILE.EXISTS(InforFileName) THEN
            EXIT(InforFileName);

        EXIT('');
    end;

    procedure ReceiveASNLines(DocNo: Code[20])
    var
        _recPDAPL: Record "GXL PDA-Purchase Lines";
        _recPL: Record "Purchase Line";
        _recPH: Record "Purchase Header";
        recPL: Record "Purchase Line";
        recPDAPLine: Record "GXL PDA-Purchase Lines";
        OrderStatusMgmt: Codeunit "GXL SC-Purch. Order Status Mgt";
    begin
        GetIntegrationSetup();
        _recPL.Reset();
        _recPL.SETRANGE(_recPL."Document Type", _recPL."Document Type"::Order);
        _recPL.SETRANGE(_recPL."Document No.", DocNo);
        _recPL.SETRANGE(_recPL.Type, _recPL.Type::Item);
        IF _recPL.FINDSET() THEN BEGIN
            IF _recPH.GET(_recPH."Document Type"::Order, DocNo) THEN
                REPEAT
                    _recPDAPL.Reset();
                    _recPDAPL.SETRANGE("Document No.", DocNo);
                    _recPDAPL.SETRANGE("Line No.", _recPL."Line No.");
                    IF _recPDAPL.FindFirst() THEN BEGIN
                        recPDAPLine.Reset();
                        recPDAPLine := _recPDAPL;
                        IF recPL.Quantity <> _recPDAPL.QtyOrdered THEN BEGIN
                            IF _recPDAPL.ReasonCode = '' THEN BEGIN
                                recPDAPLine.ReasonCode := IntegrationSetup."ASN Variance Reason Code";
                                recPDAPLine.MODIFY();
                            END;
                        END;
                        recPL.Reset();
                        IF recPL.GET(_recPL."Document Type", _recPL."Document No.", _recPL."Line No.") THEN BEGIN
                            recPL.VALIDATE("Qty. to Receive", _recPDAPL.QtyOrdered);
                            recPL."GXL Qty. Variance Reason Code" := _recPDAPL.ReasonCode;
                            recPL."GXL ASN Rec. Variance" := _recPDAPL.QtyToReceive;
                            IF recPL.MODIFY(TRUE) THEN
                                recPDAPLine.DELETE();
                        END;
                        _recPH."GXL ASN File Received" := TRUE;
                        _recPH."GXL Last EDI Document Status" := _recPH."GXL Last EDI Document Status"::ASN;
                    END
                    ELSE BEGIN
                        recPL.Reset();
                        IF recPL.GET(_recPL."Document Type", _recPL."Document No.", _recPL."Line No.") THEN BEGIN
                            recPL."GXL ASN Rec. Variance" := recPL."Qty. to Receive";
                            recPL.VALIDATE("Qty. to Receive", 0);
                            recPL."GXL Qty. Variance Reason Code" := IntegrationSetup."ASN Variance Reason Code";
                            recPL.MODIFY(TRUE);
                        END;
                    END;
                UNTIL _recPL.NEXT() = 0;

            //TODO: Order Status - WH Data Mgt - Receive ASN Lines => Confirm purchase order
            IF _recPH."GXL Order Status" <= _recPH."GXL Order Status"::Confirmed THEN BEGIN
                IF _recPH."GXL Order Status" = _recPH."GXL Order Status"::New THEN
                    _recPH."GXL Order Status" := _recPH."GXL Order Status"::Created;
                OrderStatusMgmt.ConfirmPurchHeader(_recPH);
            END;
            _recPH.MODIFY();
        END;
    end;

    //PS-2428+
    /// <summary>
    /// This function will use the PDA-Purchase Lines as buffer, i.e. temporary, to validate purchase line.qty to receive
    /// </summary>
    /// <param name="DocNo"></param>
    /// <param name="TempPDAPurchaseLines"></param>
    procedure ReceiveASNLines(DocNo: Code[20]; var TempPDAPurchaseLines: Record "GXL PDA-Purchase Lines" temporary)
    var
        PurchLine: Record "Purchase Line";
        PurchHead: Record "Purchase Header";
        PurchLine2: Record "Purchase Line";
        PDAPurchLines: Record "GXL PDA-Purchase Lines";
        OrderStatusMgmt: Codeunit "GXL SC-Purch. Order Status Mgt";
    begin
        GetIntegrationSetup();
        PurchLine.Reset();
        PurchLine.SETRANGE(PurchLine."Document Type", PurchLine."Document Type"::Order);
        PurchLine.SETRANGE(PurchLine."Document No.", DocNo);
        PurchLine.SETRANGE(PurchLine.Type, PurchLine.Type::Item);
        if PurchLine.FindSet() then begin
            if PurchHead.Get(PurchHead."Document Type"::Order, DocNo) then
                repeat
                    TempPDAPurchaseLines.Reset();
                    TempPDAPurchaseLines.SETRANGE("Document No.", DocNo);
                    TempPDAPurchaseLines.SETRANGE("Line No.", PurchLine."Line No.");
                    if TempPDAPurchaseLines.FindFirst() then begin
                        if PurchLine.Quantity <> TempPDAPurchaseLines.QtyOrdered then begin
                            if TempPDAPurchaseLines.ReasonCode = '' then begin
                                TempPDAPurchaseLines.ReasonCode := IntegrationSetup."ASN Variance Reason Code";
                            end;
                        end;

                        PurchLine2.Reset();
                        if PurchLine2.GET(PurchLine."Document Type", PurchLine."Document No.", PurchLine."Line No.") then begin
                            PurchLine2.VALIDATE("Qty. to Receive", TempPDAPurchaseLines.QtyOrdered);
                            PurchLine2."GXL Qty. Variance Reason Code" := TempPDAPurchaseLines.ReasonCode;
                            PurchLine2."GXL ASN Rec. Variance" := TempPDAPurchaseLines.QtyToReceive;
                            IF PurchLine2.Modify(true) then;
                        end;

                        PurchHead."GXL ASN File Received" := TRUE;
                        PurchHead."GXL Last EDI Document Status" := PurchHead."GXL Last EDI Document Status"::ASN;
                    end else begin
                        PurchLine2.Reset();
                        if PurchLine2.GET(PurchLine."Document Type", PurchLine."Document No.", PurchLine."Line No.") then begin
                            PurchLine2."GXL ASN Rec. Variance" := PurchLine2."Qty. to Receive";
                            PurchLine2.VALIDATE("Qty. to Receive", 0);
                            PurchLine2."GXL Qty. Variance Reason Code" := IntegrationSetup."ASN Variance Reason Code";
                            PurchLine2.MODIFY(TRUE);
                        end;
                    end;
                until PurchLine.Next() = 0;

            PurchHead."GXL P2P Conting ASN Imported" := true;

            //TODO: Order Status - WH Data Mgt - Receive ASN Lines => Confirm purchase order
            if PurchHead."GXL Order Status" <= PurchHead."GXL Order Status"::Confirmed then begin
                if PurchHead."GXL Order Status" = PurchHead."GXL Order Status"::New then
                    PurchHead."GXL Order Status" := PurchHead."GXL Order Status"::Created;
                OrderStatusMgmt.ConfirmPurchHeader(PurchHead);
            END;
            PurchHead.Modify();
        END;

    end;
    //PS-2428-
}