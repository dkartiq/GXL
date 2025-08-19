//WMSVD-002-Boomi API Sales Order integration
codeunit 50017 "WH Msg. Sales Order Processor"
{
    TableNo = "GXL WH Message Lines";
    trigger OnRun()
    begin
        Clear(CreatedSalesHeader);
        CreatedSalesHeader := CreateSalesOrder(Rec);
        CreatedSalesHeader.Ship := true;
        CreatedSalesHeader.Invoice := true;
        PostSalesDocument(CreatedSalesHeader, true);
    end;

    var
        DifferentCustomerError: Label 'Customer and/or Ship-to Code of all lines that are related to %1: "%2" must be same.';
        ExternalDocNoAlreadyUsedError: Label '%1: "%2" is alerady used in %3 (%4).';
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        CreatedSalesHeader: Record "Sales Header";


    local procedure CreateSalesOrder(GXLWHMeessageLine: Record "GXL WH Message Lines") SalesHeader: Record "Sales Header";
    var
        SalesLine: Record "Sales Line";
        GXLWHMeessageLine2: Record "GXL WH Message Lines";
        UserMgt: Codeunit "User Setup Management";
        ItemNo: Code[20];
        UOM: Code[10];
        CustomerNo: Code[20];
    begin
        GXLWHMeessageLine.TestField("Import Type", GXLWHMeessageLine."Import Type"::"Sales Order");
        GXLWHMeessageLine.TestField("Document No.");
        TestExternalDocNoAlreadyUsed(GXLWHMeessageLine."Document No.");
        GXLWHMeessageLine2.SetCurrentKey("Document No.", "Import Type");
        GXLWHMeessageLine2.SetRange("Document No.", GXLWHMeessageLine."Document No.");
        GXLWHMeessageLine2.SetRange("Import Type", GXLWHMeessageLine."Import Type");
        if not GXLWHMeessageLine2.FindSet(true) then
            exit;

        GXLWHMeessageLine2.TestField("Source No.");

        // Get Customer No From the Source no
        CustomerNo := GetCutomerNoFromSourceNo(GXLWHMeessageLine2."Source No.");

        SalesHeader.Init();
        SalesHeader."Document Type" := SalesHeader."Document Type"::Order;
        SalesHeader."Responsibility Center" := UserMgt.GetSalesFilter();
        SalesHeader.SetDefaultPaymentServices();
        SalesHeader.Insert(true);
        SalesHeader.Validate("Sell-to Customer No.", CustomerNo);
        SalesHeader.Validate("External Document No.", GXLWHMeessageLine2."Document No.");
        SalesHeader.Validate("Ship-to Code", GXLWHMeessageLine2."Source No.");
        SalesHeader.Modify(true);
        repeat
            if GXLWHMeessageLine."Source No." <> GXLWHMeessageLine2."Source No." then
                Error(DifferentCustomerError, GXLWHMeessageLine2.FieldCaption("Document No."), GXLWHMeessageLine2."Document No.");
            GXLWHMeessageLine2.TestField("Item No.");
            LegacyItemHelpers.GetItemNoForPurchase(GXLWHMeessageLine2."Item No.", ItemNo, UOM, true);
            SalesLine.Init();
            SalesLine."Document Type" := SalesHeader."Document Type";
            SalesLine."Document No." := SalesHeader."No.";
            SalesLine."Line No." := GXLWHMeessageLine2."Line No.";
            SalesLine.Validate(Type, SalesLine.Type::Item);
            SalesLine.Validate("No.", ItemNo);
            SalesLine.Validate("Location Code", GXLWHMeessageLine2."Location Code");
            SalesLine.Validate("Unit of Measure Code", UOM);
            // Changes based on Reques from PedB / Chandra
            //SalesLine.Validate(Quantity, GXLWHMeessageLine2."Qty. To Receive" + GXLWHMeessageLine2."Qty. Variance");
            SalesLine.Validate(Quantity, GXLWHMeessageLine2."Qty. To Receive");
            SalesLine.Validate("Qty. to Ship", GXLWHMeessageLine2."Qty. To Receive");
            SalesLine.Validate("Qty. to Invoice", GXLWHMeessageLine2."Qty. To Receive");
            SalesLine.Insert(true);
        until GXLWHMeessageLine2.Next() = 0;
    end;

    local procedure PostSalesDocument(SalesHeader: Record "Sales Header"; SuppressCommit: Boolean)
    var
        SalesPost: Codeunit "Sales-Post";
    begin
        SalesPost.SetSuppressCommit(SuppressCommit);
        SalesPost.Run(SalesHeader);
    end;

    local procedure TestExternalDocNoAlreadyUsed(ExtDocNo: Code[20])
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesShipmentHeader: Record "Sales Shipment Header";
    begin
        if ExtDocNo = '' then
            exit;
        SalesHeader.SetCurrentKey("External Document No.");
        SalesHeader.SetRange("External Document No.", ExtDocNo);
        if SalesHeader.FindFirst() then
            Error(ExternalDocNoAlreadyUsedError, SalesHeader.FieldCaption("External Document No."), ExtDocNo, SalesHeader.TableCaption,
            StrSubstNo('%1: "%2", %3: "%4"', SalesHeader.FieldCaption("Document Type"), SalesHeader."Document Type", SalesHeader.FieldCaption("No."), SalesHeader."No."));
        SalesInvoiceHeader.SetCurrentKey("External Document No.");
        SalesInvoiceHeader.SetRange("External Document No.", ExtDocNo);
        if SalesInvoiceHeader.FindFirst() then
            Error(ExternalDocNoAlreadyUsedError, SalesInvoiceHeader.FieldCaption("External Document No."), ExtDocNo, SalesInvoiceHeader.TableCaption,
            StrSubstNo('%1: "%2"', SalesInvoiceHeader.FieldCaption("No."), SalesInvoiceHeader."No."));
        SalesShipmentHeader.SetCurrentKey("External Document No.");
        SalesShipmentHeader.SetRange("External Document No.", ExtDocNo);
        if SalesShipmentHeader.FindFirst() then
            Error(ExternalDocNoAlreadyUsedError, SalesShipmentHeader.FieldCaption("External Document No."), ExtDocNo, SalesShipmentHeader.TableCaption,
            StrSubstNo('%1: "%2"', SalesShipmentHeader.FieldCaption("No."), SalesShipmentHeader."No."));
    end;

    procedure GetCreatedSalesDocument(): Record "Sales Header";
    begin
        exit(CreatedSalesHeader);
    end;

    procedure RunAndLog(GXLWHMeessageLine: Record "GXL WH Message Lines") Success: Boolean
    var
        WHSalesOrderProcessor: Codeunit "WH Msg. Sales Order Processor";
        GXLWHMeessageLine2: Record "GXL WH Message Lines";
        SalesHeader: Record "Sales Header";
    begin
        Success := WHSalesOrderProcessor.Run(GXLWHMeessageLine);
        GXLWHMeessageLine2.SetCurrentKey("Import Type", "Document No.");
        GXLWHMeessageLine2.SetRange("Document No.", GXLWHMeessageLine."Document No.");
        GXLWHMeessageLine2.SetRange("Import Type", GXLWHMeessageLine."Import Type");
        if Success then begin
            SalesHeader := WHSalesOrderProcessor.GetCreatedSalesDocument();
            if GXLWHMeessageLine2.FindSet(true) then
                repeat
                    GXLWHMeessageLine2."Error Found" := false;
                    GXLWHMeessageLine2."Error Description" := '';
                    GXLWHMeessageLine2.Processed := true;
                    GXLWHMeessageLine2."Created Document No." := SalesHeader."No.";
                    GXLWHMeessageLine2.Modify();
                until GXLWHMeessageLine2.Next() = 0;
        end
        else begin
            if GXLWHMeessageLine2.FindSet(true) then
                repeat
                    GXLWHMeessageLine2."Error Found" := true;
                    GXLWHMeessageLine2."Error Description" := CopyStr(GetLastErrorText(), 1, MaxStrLen(GXLWHMeessageLine2."Error Description"));
                    GXLWHMeessageLine2.Processed := false;
                    GXLWHMeessageLine2."Created Document No." := '';
                    GXLWHMeessageLine2.Modify();
                until GXLWHMeessageLine2.Next() = 0;
        end;
    end;

    procedure GetCutomerNoFromSourceNo(inShipToCode: Code[20]) outCustomerNo: Code[20]
    var
        Customer: Record Customer;
        ShipToAddress: Record "Ship-to Address";
    begin
        outCustomerNo := '';

        ShipToAddress.SetRange(Code, inShipToCode);
        ShipToAddress.FindFirst();

        Customer.Get(ShipToAddress."Customer No.");

        outCustomerNo := Customer."No.";
    end;
}