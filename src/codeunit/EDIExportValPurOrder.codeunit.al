// 001 02.07.2025 KDU HP2-Sprint2
codeunit 50367 "GXL EDI-Export+Val. Pur. Order"
{
    //TODO: Domestic and Internaltional Order is not in scope, need to be re-visited when it is back in-scope
    TableNo = "Purchase Header";

    trigger OnRun()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader := Rec;

        ValidateFinalDestination(FinalDestination);

        ValidatePurchaseHeader(PurchaseHeader);
        IF ExportWhich IN [ExportWhich::PO, ExportWhich::IPO] THEN
            ValidatePurchaseLines(PurchaseHeader);

        IF ExportWhich IN [ExportWhich::IPO, ExportWhich::IPOX] THEN
            ExportIntlPO(PurchaseHeader, FinalDestination)
        ELSE
            RunDataport(PurchaseHeader, FinalDestination);

    end;

    var
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        ExportWhich: Option PO,POX,POR,ASN,INV,IPO,IPOX,SHIPSTATUS;
        FinalDestination: Text;
        Text000Msg: Label 'File already exists.';
        Text001Msg: Label '%1 must have a value. It cannot be zero or blank.';
        Text003Msg: Label '%1 must have at least one line.';
        Text004Msg: Label '%1 cannot be less than zero.';
        Text005Msg: Label '%1 not found: %2 %3 - %4 %5.';
        Text006Msg: Label '%1 (%2 %3 - %4 %5) %6 must have a value. It cannot be zero or blank.';

    local procedure ValidateFinalDestination(FinalDestination: Text)
    var
        FileMngt: Codeunit "File Management";
    begin
        IF FileMngt.ServerFileExists(FinalDestination) then begin
            EDIErrorMgt.SetErrorMessage(Text000Msg);
            EDIErrorMgt.ThrowErrorMessage();
        END;
    end;

    local procedure ValidatePurchaseHeader(PurchaseHeader: Record "Purchase Header")
    begin
        PurchaseHeader.TESTFIELD("Document Type", PurchaseHeader."Document Type"::Order);

        IF PurchaseHeader."Buy-from Vendor No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("Buy-from Vendor No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseHeader."Buy-from Vendor Name" = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("Buy-from Vendor Name")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF ExportWhich = ExportWhich::PO THEN
            IF PurchaseHeader."Buy-from Address" = '' THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("Buy-from Address")));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        IF PurchaseHeader."Location Code" = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("Location Code")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF ExportWhich = ExportWhich::PO THEN
            IF PurchaseHeader."Ship-to Address" = '' THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("Ship-to Address")));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        IF PurchaseHeader."Ship-to City" = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("Ship-to City")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF ExportWhich = ExportWhich::PO THEN
            IF PurchaseHeader."Ship-to Post Code" = '' THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("Ship-to Post Code")));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        IF ExportWhich = ExportWhich::PO THEN
            IF PurchaseHeader."Ship-to County" = '' THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("Ship-to County")));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        IF PurchaseHeader."No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseHeader."Order Date" = 0D THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("Order Date")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseHeader."Expected Receipt Date" = 0D THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("Expected Receipt Date")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseHeader."GXL Created By User ID" = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("GXL Created By User ID")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        // Following validations do not apply to PO Cancellations (where ExportWhich = POX or IPOX)
        IF ExportWhich IN [ExportWhich::PO, ExportWhich::IPO] THEN BEGIN
            PurchaseHeader.CALCFIELDS("GXL Total Order Qty", "GXL Total Order Value", "GXL Total Value");

            IF PurchaseHeader."GXL Total Order Qty" = 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("GXL Total Order Qty")));
                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF PurchaseHeader."GXL Total Order Value" = 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("GXL Total Order Value")));
                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF PurchaseHeader."GXL Total Value" = 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("GXL Total Value")));
                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF ExportWhich = ExportWhich::PO THEN
                IF PurchaseHeader."GXL Transport Type" = '' THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseHeader.FIELDCAPTION("GXL Transport Type")));
                    EDIErrorMgt.ThrowErrorMessage();
                END;

        END;

    end;

    local procedure ValidatePurchaseLines(PurchaseHeader: Record "Purchase Header")
    var
        PurchaseLine: Record "Purchase Line";
        Vendor: Record Vendor;
    begin
        PurchaseLine.Reset();
        PurchaseLine.SETCURRENTKEY("Document Type", "Document No.", "Line No.");
        PurchaseLine.SETRANGE("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
        PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
        IF PurchaseLine.FindSet() THEN BEGIN
            REPEAT
                ValidatePurchaseLine(PurchaseLine);
                Vendor.GET(PurchaseHeader."Buy-from Vendor No.");
                IF Vendor."GXL EDI Order in Out. Pack UoM" THEN
                    ValidatePurchaseLine2(PurchaseLine);
            UNTIL PurchaseLine.Next() = 0;
        END ELSE BEGIN
            EDIErrorMgt.SetErrorMessage(Text003Msg);
            EDIErrorMgt.ThrowErrorMessage();
        END;
    end;

    [Scope('OnPrem')]
    procedure ValidatePurchaseLine(PurchaseLine: Record "Purchase Line")
    var
        SKU: Record "Stockkeeping Unit";
        TotalGSTValue: Decimal;
    begin
        IF PurchaseLine."Line No." = 0 THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("Line No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseLine."No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseLine."GXL Primary EAN" = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("GXL Primary EAN")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseLine."GXL Vendor Reorder No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("GXL Vendor Reorder No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseLine.Description = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION(Description)));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        SKU.Reset();
        SKU.SETCURRENTKEY("Location Code", "Item No.");
        SKU.SETRANGE("Location Code", PurchaseLine."Location Code");
        SKU.SETRANGE("Item No.", PurchaseLine."No.");
        IF NOT SKU.FindFirst() THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(Text005Msg,
                SKU.TABLECAPTION(),
                SKU.FIELDCAPTION("Location Code"),
                PurchaseLine."Location Code",
                SKU.FIELDCAPTION("Item No."),
                PurchaseLine."No."));
            EDIErrorMgt.ThrowErrorMessage();
        END;


        IF SKU."GXL Order Multiple (OM)" = 0 THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(Text006Msg,
                SKU.TABLECAPTION(),
                SKU.FIELDCAPTION("Location Code"),
                PurchaseLine."Location Code",
                SKU.FIELDCAPTION("Item No."),
                PurchaseLine."No.",
                SKU.FIELDCAPTION("GXL Order Multiple (OM)")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF SKU."GXL Order Pack (OP)" = 0 THEN BEGIN
            EDIErrorMgt.SetErrorMessage(
              STRSUBSTNO(Text006Msg,
                SKU.TABLECAPTION(),
                SKU.FIELDCAPTION("Location Code"),
                PurchaseLine."Location Code",
                SKU.FIELDCAPTION("Item No."),
                PurchaseLine."No.",
                SKU.FIELDCAPTION("GXL Order Pack (OP)")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF ExportWhich = ExportWhich::IPO THEN BEGIN
            IF PurchaseLine.Quantity < 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text004Msg, PurchaseLine.FIELDCAPTION(Quantity)));
                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF (PurchaseLine.Quantity > 0) AND
               (PurchaseLine."GXL Carton-Qty" = 0)
            THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("GXL Carton-Qty")));
                EDIErrorMgt.ThrowErrorMessage();
            END;
        END ELSE BEGIN
            IF PurchaseLine.Quantity <= 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION(Quantity)));
                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF PurchaseLine."GXL Carton-Qty" = 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("GXL Carton-Qty")));
                EDIErrorMgt.ThrowErrorMessage();
            END;
        END;

        IF PurchaseLine."Direct Unit Cost" = 0 THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("Direct Unit Cost")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF ExportWhich = ExportWhich::IPO THEN BEGIN
            IF PurchaseLine.Quantity > 0 THEN
                IF PurchaseLine."Line Amount" = 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("Line Amount")));
                    EDIErrorMgt.ThrowErrorMessage();
                END;
        END ELSE
            IF PurchaseLine."Line Amount" = 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("Line Amount")));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        TotalGSTValue := PurchaseLine."Amount Including VAT" - PurchaseLine."Line Amount";
        IF TotalGSTValue < 0 THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text004Msg, 'Total GST'));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        //>> MCS1.76
        IF ExportWhich <> ExportWhich::IPO THEN
            //<< MCS1.76
            IF PurchaseLine."VAT %" = 0 THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("VAT %")));
                EDIErrorMgt.ThrowErrorMessage();
            END;

        IF PurchaseLine."Line Discount %" < 0 THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text004Msg, PurchaseLine.FIELDCAPTION("Line Discount %")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseLine."Unit of Measure" = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("Unit of Measure")));
            EDIErrorMgt.ThrowErrorMessage();
        END;
    end;

    local procedure RunDataport(PurchaseHeader: Record "Purchase Header"; FinalDestination: Text)
    var
        FileManagement: Codeunit "File Management";
        PurchaseOrderXmlPort: XMLport "GXL Vendor-FT Order";
        FileVar: File;
        OutStreamVar: OutStream;
        ServerTempXmlFile: Text;
    begin
        ServerTempXmlFile := FileManagement.ServerTempFileName('xml');

        FileVar.CREATE(ServerTempXmlFile);
        FileVar.CREATEOUTSTREAM(OutStreamVar);

        PurchaseHeader.SETRECFILTER();

        CLEAR(PurchaseOrderXmlPort);

        PurchaseOrderXmlPort.SetEDIOptions(ExportWhich);
        PurchaseOrderXmlPort.SETDESTINATION(OutStreamVar);
        PurchaseOrderXmlPort.SETTABLEVIEW(PurchaseHeader);
        PurchaseOrderXmlPort.EXPORT();

        FileVar.CLOSE();

        MoveFile(ServerTempXmlFile, FinalDestination, TRUE);
    end;

    [Scope('OnPrem')]
    procedure SetOptions(ExportWhichNew: Option PO,POX,POR,ASN,INV,IPO,IPOX,SHIPSTATUS; FinalDestinationNew: Text)
    begin
        ExportWhich := ExportWhichNew;
        FinalDestination := FinalDestinationNew;
    end;

    local procedure MoveFile(SourceFileName: Text; TargetFileName: Text; DeleteSourceFile: Boolean)
    var
        FileMgt: Codeunit "File Management";
        // >> Upgrade
        //ServerFileHelper: DotNet File;
        ServerFileHelper: DotNet File1;
    // << Upgrade
    begin
        // >> 001
        // IF GUIALLOWED() THEN
        //     // >> Upgrade
        //     //FileMgt.DownloadToFile(SourceFileName, TargetFileName)'
        //     FileMgt.DownloadHandler(SourceFileName, '', '', '', TargetFileName)
        // // << Upgrade
        // ELSE
        // << 001
        ServerFileHelper.Copy(SourceFileName, TargetFileName);

        IF DeleteSourceFile THEN
            ServerFileHelper.Delete(SourceFileName);
    end;


    [Scope('OnPrem')]
    procedure ValidatePurchaseLine2(PurchaseLine: Record "Purchase Line")
    var
    begin
        IF PurchaseLine."GXL OP GTIN" = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("GXL OP GTIN")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseLine."GXL Vendor Reorder No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("GXL Vendor OP Reorder No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseLine."GXL OP Unit of Measure Code" = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Msg, PurchaseLine.FIELDCAPTION("GXL OP Unit of Measure Code")));
            EDIErrorMgt.ThrowErrorMessage();
        END;
    end;

    local procedure ExportIntlPO(PurchaseHeader: Record "Purchase Header"; FinalDestination: Text)
    var
        FileManagement: Codeunit "File Management";
        IntlPurchaseOrderXmlPort: XMLport "GXL International Purch. Order";
        FileVar: File;
        OutStreamVar: OutStream;
        ServerTempXmlFile: Text;
    begin
        ServerTempXmlFile := FileManagement.ServerTempFileName('xml');

        FileVar.CREATE(ServerTempXmlFile);
        FileVar.CREATEOUTSTREAM(OutStreamVar);

        PurchaseHeader.SETRECFILTER();

        CLEAR(IntlPurchaseOrderXmlPort);

        IntlPurchaseOrderXmlPort.SetEDIOptions(ExportWhich);
        IntlPurchaseOrderXmlPort.SETDESTINATION(OutStreamVar);
        IntlPurchaseOrderXmlPort.SETTABLEVIEW(PurchaseHeader);
        IntlPurchaseOrderXmlPort.EXPORT();

        FileVar.CLOSE();

        MoveFile(ServerTempXmlFile, FinalDestination, TRUE);
    end;
}

