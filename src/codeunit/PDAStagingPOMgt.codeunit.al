codeunit 50258 "GXL PDA-Staging PO Mgt."
{
    Permissions = tabledata "GXL PDA-Staging Purch. Header" = imd,
         tabledata "GXL PDA-Staging Purch. Line" = imd;

    trigger OnRun()
    begin

    end;

    var
        TempPDAPurchaseLines: Record "GXL PDA-Purchase Lines" temporary;
        TempPurchHead: Record "Purchase Header" temporary;
        // >> Upgrade
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        // << Upgrade
        inputStream: InStream;
        outputStream: OutStream;

        OrderCancelledTxt: Label 'Order Cancelled';
        OrderHasAlreadyBeenCancelledTxt: Label 'Order has already been Cancelled';
        OrderCannotBeCancelledErr: Label 'Order cannot be cancelled because Order Status is: %1';
        OrderCannotBeFoundErr: Label 'Order cannot be found';
        NoDistributorErr: Label 'No distibutor is assigned to this location for this item';
        DuplicateItemLineErr: Label 'The purchase order %1 cannot be released because multiple occurrences of item %2.';
        OrderLineCannotBeUpdatedErr: Label 'Purchase order line cannot be updated as Order Status is marked as %1.';
        OrderDoesNotExistErr: Label 'Purchase Order No. %1 does not exist';
        OrderLineDoesNotExistErr: Label 'Line No. %1 does not exist on Purchase Order No. %2';
        OrderValueLessThanMinErr: Label 'Order is less than supplier MOV of %1. Please add additional products to reach MOV.';
        OrderQtyLessThanMinErr: Label 'Order is less than supplier MOQ of %1. Please add additional products to reach MOQ.';


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

    procedure CreatePO(StoreCode: Code[10]; BatchId: Integer; xmlInput: BigText; var outboundXml: XmlPort "GXL PDA-Purchase Order")
    var
        NewTempPDAPurchaseLines: Record "GXL PDA-Purchase Lines" temporary;
        xmlInbound: XmlPort "GXL PDA-Rec Purchase Lines";
    begin
        SaveInputXml(xmlInput);
        xmlInbound.SetSource(inputStream);
        xmlInbound.Import();
        xmlInbound.GetTempPDAPurchaseLines(NewTempPDAPurchaseLines);

        TempPDAPurchaseLines.Reset();
        TempPDAPurchaseLines.DeleteAll();
        if NewTempPDAPurchaseLines.FindSet() then
            repeat
                TempPDAPurchaseLines := NewTempPDAPurchaseLines;
                TempPDAPurchaseLines.Insert();
            until NewTempPDAPurchaseLines.Next() = 0;

        CreatePDAStagingPurchase(StoreCode, BatchId);

        outboundXml.ShowBatchPO(StoreCode, BatchId);
    end;

    procedure UpdatePOLine(PONumber: Code[20]; LineNumber: Integer; OrderQty: Decimal; ReasonCode: Code[10])
    var
        ConfirmedPurchLine: Record "Purchase Line";
        PDAStagingPH: Record "GXL PDA-Staging Purch. Header";
        PDAStagingPL: Record "GXL PDA-Staging Purch. Line";
        TempPDAStagingPH: Record "GXL PDA-Staging Purch. Header" temporary;
        TempPDAStagingPL: Record "GXL PDA-Staging Purch. Line" temporary;
        PurchLine: Record "Purchase Line";
        TempPurchLine: Record "Purchase Line" temporary;
        ErrorText: Text;
    begin
        ConfirmedPurchLine.Reset();
        ConfirmedPurchLine.SetRange("Document Type", ConfirmedPurchLine."Document Type"::Order);
        ConfirmedPurchLine.SetRange("Document No.", PONumber);
        ConfirmedPurchLine.SetRange("Line No.", LineNumber);
        if ConfirmedPurchLine.FindFirst() then begin
            ConfirmedPurchLine.Validate(Quantity, OrderQty);
            ConfirmedPurchLine."GXL Qty. Variance Reason Code" := ReasonCode;
            ConfirmedPurchLine.Modify(true);
        end else begin
            PDAStagingPL.SetRange("Document No.", PONumber);
            PDAStagingPL.SetRange("Line No.", LineNumber);
            if PDAStagingPL.FindFirst() then begin
                PDAStagingPH.Get(PDAStagingPL."Document No.");
                if PDAStagingPH."Order Status" <> PDAStagingPH."Order Status"::Approved then begin
                    ErrorText := StrSubstNo(OrderLineCannotBeUpdatedErr, PDAStagingPH."Order Status");
                    Error(ErrorText);
                end;

                TempPDAStagingPH.Init();
                TempPDAStagingPH."No." := '';
                TempPDAStagingPH."Buy-from Vendor No." := PDAStagingPH."Buy-from Vendor No.";
                TempPDAStagingPH."Order Date" := PDAStagingPH."Order Date";
                TempPDAStagingPH."Posting Date" := PDAStagingPH."Posting Date";
                TempPDAStagingPH."Location Code" := PDAStagingPH."Location Code";
                TempPDAStagingPH."PDA Batch Id" := PDAStagingPH."PDA Batch Id";
                TempPDAStagingPH.PopulateTempPurchaseHeader(TempPurchHead);

                TempPurchHead."No." := PDAStagingPH."No.";
                TempPDAStagingPL.Init();
                TempPDAStagingPL.TransferFields(PDAStagingPL);
                TempPDAStagingPL."Document No." := PDAStagingPL."Document No.";
                TempPDAStagingPL."Line No." := PDAStagingPL."Line No.";
                TempPDAStagingPL.Quantity := OrderQty;
                TempPDAStagingPL."Qty. Variance Reason Code" := ReasonCode;
                TempPDAStagingPL.PopulateTempPurchLine(TempPurchHead, PurchLine, false);

                TempPurchLine.Init();
                TempPurchLine.TransferFields(PurchLine);
                TempPurchLine."Line No." := PDAStagingPL."Line No.";
                TempPurchLine.Insert();

                TempPurchLine.Reset();
                if TempPurchLine.FindFirst() then begin
                    if PDAStagingPL.Get(TempPurchLine."Document No.", TempPurchLine."Line No.") then begin
                        PDAStagingPL.TransferFields(TempPurchLine, false);
                        PDAStagingPL.Modify();
                    end;
                end;
                TempPurchLine.DeleteAll();
            end;
        end;
    end;

    procedure CancelPO(PONumber: Code[20]): Text
    var
        PurchHead: Record "Purchase Header";
        PDAStagingPH: Record "GXL PDA-Staging Purch. Header";
        ReturnText: Text;
    begin
        if PurchHead.Get(PurchHead."Document Type"::Order, PONumber) then begin
            //TODO: Order Status - PDA cancel purchase order -> set status to Cancelled
            if PurchHead."GXL Order Status" in [PurchHead."GXL Order Status"::New, PurchHead."GXL Order Status"::Created] then begin
                PurchHead."GXL Order Status" := PurchHead."GXL Order Status"::Cancelled;
                PurchHead.Modify();
                ReturnText := OrderCancelledTxt;
            end else begin
                ReturnText := StrSubstNo(OrderCannotBeCancelledErr, PurchHead."GXL Order Status");
                Error(ReturnText);
            end;
        end else
            if PDAStagingPH.Get(PONumber) then begin
                if PDAStagingPH."Order Status" in [PDAStagingPH."Order Status"::NotApproved, PDAStagingPH."Order Status"::Approved] then begin
                    PDAStagingPH."Order Status" := PDAStagingPH."Order Status"::Cancelled;
                    PDAStagingPH.Modify();
                    ReturnText := OrderCancelledTxt;
                end else
                    if PDAStagingPH."Order Status" = PDAStagingPH."Order Status"::Cancelled then
                        ReturnText := OrderHasAlreadyBeenCancelledTxt;
            end else begin
                ReturnText := OrderCannotBeFoundErr;
                Error(ReturnText);
            end;

        exit(ReturnText);
    end;

    procedure SendPOToSupplier(PONumber: Code[20])
    var
        PurchHead: Record "Purchase Header";
        PDAStagingPH: Record "GXL PDA-Staging Purch. Header";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
    begin
        if PurchHead.Get(PurchHead."Document Type"::Order, PONumber) then
            ReleasePurchDoc.PerformManualRelease(PurchHead)
        else
            if PDAStagingPH.Get(PONumber) then begin
                if PDAStagingPH."Order Status" <> PDAStagingPH."Order Status"::Approved then begin
                    CheckDuplicateItemLine(PDAStagingPH);
                    CheckVendorMinimumOrderValues(PDAStagingPH);

                    PDAStagingPH."Order Status" := PDAStagingPH."Order Status"::Approved;
                    PDAStagingPH.Modify();
                end;
            end;
    end;

    procedure AddNewPOLine(PONumber: Code[20]; ItemNo: Code[20]; UOM: Code[10]; Description: Text[100]; OrderQty: Decimal)
    var
        PDAStagingPH: Record "GXL PDA-Staging Purch. Header";
        PDAStagingPL: Record "GXL PDA-Staging Purch. Line";
        LastPDAStagingPL: Record "GXL PDA-Staging Purch. Line";
        TempPDAStagingPH: Record "GXL PDA-Staging Purch. Header" temporary;
        TempPDAStagingPL: Record "GXL PDA-Staging Purch. Line" temporary;
        PurchLine: Record "Purchase Line";
        LineNo: Integer;
        ReturnText: Text;
    begin
        if not PDAStagingPH.Get(PONumber) then begin
            ReturnText := StrSubstNo(OrderDoesNotExistErr, PONumber);
            Error(ReturnText);
        end;
        if PDAStagingPH."Order Status" <> PDAStagingPH."Order Status"::NotApproved then begin
            ReturnText := StrSubstNo(OrderLineCannotBeUpdatedErr, PDAStagingPH."Order Status");
            Error(ReturnText);
        end;

        TempPDAStagingPH.Init();
        TempPDAStagingPH."No." := '';
        TempPDAStagingPH."Buy-from Vendor No." := PDAStagingPH."Buy-from Vendor No.";
        TempPDAStagingPH."Order Date" := PDAStagingPH."Order Date";
        TempPDAStagingPH."Posting Date" := PDAStagingPH."Posting Date";
        TempPDAStagingPH."Location Code" := PDAStagingPH."Location Code";
        TempPDAStagingPH."PDA Batch Id" := PDAStagingPH."PDA Batch Id";
        TempPDAStagingPH.PopulateTempPurchaseHeader(TempPurchHead);

        Clear(PurchLine);
        LineNo := 0;
        TempPurchHead."No." := PDAStagingPH."No.";
        TempPDAStagingPL.Init();
        TempPDAStagingPL."Document No." := TempPurchHead."No.";
        TempPDAStagingPL."Line No." := LineNo;
        TempPDAStagingPL.Type := TempPDAStagingPL.Type::Item;
        TempPDAStagingPL."No." := ItemNo;
        TempPDAStagingPL."Unit of Measure Code" := UOM;
        TempPDAStagingPL.Description := Description;
        TempPDAStagingPL."Location Code" := PDAStagingPH."Location Code";
        TempPDAStagingPL.Quantity := OrderQty;
        TempPDAStagingPL.PopulateTempPurchLine(TempPurchHead, PurchLine, true);

        LastPDAStagingPL.SetRange("Document No.", PDAStagingPH."No.");
        if LastPDAStagingPL.FindLast() then
            LineNo := LastPDAStagingPL."Line No." + 1
        else
            LineNo := 1000;

        PDAStagingPL.Init();
        PDAStagingPL.TransferFields(PurchLine);
        PDAStagingPL."Document No." := PDAStagingPH."No.";
        PDAStagingPL."Line No." := LineNo;
        PDAStagingPL.Insert();

    end;

    procedure DeletePOLine(PONumber: Code[20]; LineNo: Integer)
    var
        PDAStagingPH: Record "GXL PDA-Staging Purch. Header";
        PDAStagingPL: Record "GXL PDA-Staging Purch. Line";
        ReturnText: Text;
    begin
        if not PDAStagingPH.Get(PONumber) then begin
            ReturnText := StrSubstNo(OrderDoesNotExistErr, PONumber);
            Error(ReturnText);
        end;
        if PDAStagingPH."Order Status" <> PDAStagingPH."Order Status"::NotApproved then begin
            ReturnText := StrSubstNo(OrderLineCannotBeUpdatedErr, PDAStagingPH."Order Status");
            Error(ReturnText);
        end;

        if not PDAStagingPL.Get(PONumber, LineNo) then begin
            ReturnText := StrSubstNo(OrderLineDoesNotExistErr, LineNo, PONumber);
            Error(ReturnText);
        end;

        PDAStagingPL.Delete();
    end;

    local procedure CreatePDAStagingPurchase(StoreCode: Code[10]; BatchId: Integer)
    var
        PDAStagingPL: Record "GXL PDA-Staging Purch. Line";
        TempPDAStagingPL: Record "GXL PDA-Staging Purch. Line" temporary;
        PurchLine: Record "Purchase Line";
        TempPurchLine: Record "Purchase Line" temporary;
        PONumber: Code[20];
        VendCode: Code[20];
    begin
        TempPDAPurchaseLines.Reset();
        TempPDAPurchaseLines.SetRange("Document No.", StoreCode + Format(BatchId));
        TempPDAPurchaseLines.SetFilter(QtyOrdered, '<>0');
        if TempPDAPurchaseLines.FindSet() then begin
            Clear(TempPurchHead);
            //Assume that all the lines are for one vendor
            VendCode := FindSupplier(StoreCode, TempPDAStagingPL."No.");
            PONumber := CreateStagingPurchHeader(VendCode, StoreCode, BatchId);
            repeat
                Clear(PurchLine);
                TempPurchHead."No." := PONumber;
                TempPDAStagingPL.Init();
                TempPDAStagingPL."Document No." := TempPurchHead."No.";
                TempPDAStagingPL."Line No." := TempPDAPurchaseLines."Line No.";
                TempPDAStagingPL.Type := TempPDAStagingPL.Type::Item;
                TempPDAStagingPL."No." := TempPDAPurchaseLines."Item No.";
                TempPDAStagingPL."Unit of Measure Code" := TempPDAPurchaseLines."Unit of Measure Code";
                TempPDAStagingPL."Location Code" := StoreCode;
                TempPDAStagingPL.Quantity := TempPDAPurchaseLines.QtyOrdered;
                TempPDAStagingPL."Qty. to Receive" := TempPDAPurchaseLines.QtyToReceive;
                TempPDAStagingPL.PopulateTempPurchLine(TempPurchHead, PurchLine, false);

                TempPurchLine.Init();
                TempPurchLine.TransferFields(PurchLine);
                TempPurchLine."Line No." := TempPDAPurchaseLines."Line No.";
                if TempPDAPurchaseLines.Description <> '' then
                    TempPurchLine.Description := TempPDAPurchaseLines.Description;
                TempPurchLine.Insert();
            until TempPDAPurchaseLines.Next() = 0;

            TempPurchLine.Reset();
            if TempPurchLine.FindSet() then
                repeat
                    PDAStagingPL.Init();
                    PDAStagingPL.TransferFields(TempPurchLine);
                    PDAStagingPL.Insert();
                until TempPurchLine.Next() = 0;
            TempPurchLine.DeleteAll();

            TempPDAPurchaseLines.DeleteAll();
        end;
    end;

    local procedure CreateStagingPurchHeader(VendCode: Code[20]; StoreCode: Code[10]; BatchId: Integer): Code[20]
    var
        PDAStagingPH: Record "GXL PDA-Staging Purch. Header";
        TempPDAStagingPH: Record "GXL PDA-Staging Purch. Header" temporary;
        PONumber: Code[20];
    begin
        TempPDAStagingPH.Init();
        TempPDAStagingPH."No." := '';
        TempPDAStagingPH."Buy-from Vendor No." := VendCode;
        TempPDAStagingPH."Order Date" := WorkDate();
        TempPDAStagingPH."Posting Date" := WorkDate();
        TempPDAStagingPH."Location Code" := StoreCode;
        TempPDAStagingPH."PDA Batch Id" := BatchId;
        TempPDAStagingPH.PopulateTempPurchaseHeader(TempPurchHead);

        PDAStagingPH.SetCurrentKey("PDA Batch Id");
        PDAStagingPH.SetRange("PDA Batch Id", BatchId);
        PDAStagingPH.SetRange("Buy-from Vendor No.", VendCode);
        PDAStagingPH.SetRange("Location Code", StoreCode);
        if not PDAStagingPH.FindFirst() then begin
            Clear(PDAStagingPH);
            PDAStagingPH."No." := '';
            PONumber := PDAStagingPH.GetNextPONumber();
            Commit(); //Release lock

            PDAStagingPH.Init();
            PDAStagingPH."No." := PONumber;
            PDAStagingPH.Insert(true);
            PDAStagingPH.TransferFields(TempPurchHead, false);
            PDAStagingPH."Order Status" := PDAStagingPH."Order Status"::NotApproved;
            PDAStagingPH."PDA Batch Id" := BatchId;
            PDAStagingPH.Modify();
        end;
        exit(PDAStagingPH."No.");
    end;

    local procedure FindSupplier(StoreCode: Code[10]; ItemCode: Code[20]): Code[20]
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.SetRange("Location Code", StoreCode);
        SKU.SetRange("Item No.", ItemCode);
        if SKU.FindFirst() then
            if SKU."GXL Distributor Number" <> '' then
                exit(SKU."GXL Distributor Number");
        Error(NoDistributorErr);
    end;

    local procedure CheckDuplicateItemLine(PDAStagingPH: Record "GXL PDA-Staging Purch. Header")
    var
        PDAStagingPL: Record "GXL PDA-Staging Purch. Line";
        TempPDAStagingPL: Record "GXL PDA-Staging Purch. Line" temporary;
    begin
        PDAStagingPL.SetRange("Document No.", PDAStagingPH."No.");
        if PDAStagingPL.FindSet() then
            repeat
                TempPDAStagingPL.Reset();
                TempPDAStagingPL.SetRange("Document No.", PDAStagingPL."Document No.");
                TempPDAStagingPL.SetRange("No.", PDAStagingPL."No.");
                if TempPDAStagingPL.IsEmpty() then begin
                    TempPDAStagingPL.Init();
                    TempPDAStagingPL.TransferFields(PDAStagingPL);
                    TempPDAStagingPL.Insert();
                end else
                    Error(StrSubstNo(DuplicateItemLineErr, PDAStagingPL."Document No.", PDAStagingPL."No."));
            until PDAStagingPL.Next() = 0;
    end;

    local procedure CheckVendorMinimumOrderValues(var PDAStagingPH: Record "GXL PDA-Staging Purch. Header")
    var
        Vend: Record Vendor;
    begin
        Vend.Get(PDAStagingPH."Buy-from Vendor No.");
        if (Vend."GXL Minimum Order Value" <> 0) or (Vend."GXL Minimum Order Quantity" <> 0) then begin
            PDAStagingPH.CalcFields("Total Order Qty", "Total Order Value");
            if PDAStagingPH."Total Order Value" < Vend."GXL Minimum Order Value" then
                Error(OrderValueLessThanMinErr, Vend."GXL Minimum Order Value");
            if PDAStagingPH."Total Order Qty" < Vend."GXL Minimum Order Quantity" then
                Error(OrderQtyLessThanMinErr, Vend."GXL Minimum Order Quantity");
        end;
    end;

}