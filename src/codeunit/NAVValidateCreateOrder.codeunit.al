codeunit 50141 "GXL NAV Validate-Create Order"
{
    /*Change Log
        ERP-NAV Master Data Management: transfer additional fields from NAV13 over
        ERP-397 26-10-21 LP: Exflow and Purchase Order Creation
    */

    TableNo = "GXL NAV Confirmed Order";

    trigger OnRun()
    var
        NAVConfirmedOrder2: Record "GXL NAV Confirmed Order";
    begin
        ClearAll();
        NAVConfirmedOrder := Rec;
        if NAVConfirmedOrder."Process Status" = NAVConfirmedOrder."Process Status"::Created then
            Error(AlreadyCreatedMsg, NAVConfirmedOrder."No.");
        //ERP-328 +
        if NAVConfirmedOrder."Process Status" <> NAVConfirmedOrder."Process Status"::Imported then begin
            NAVConfirmedOrder2."Process Status" := NAVConfirmedOrder2."Process Status"::Imported;
            Error(StatusMustBeMsg, NAVConfirmedOrder."Document Type", NAVConfirmedOrder."No.", NAVConfirmedOrder2."Process Status");
        end;
        //ERP-328 -
        TempNAVConfirmedOrdLine.Reset();
        TempNAVConfirmedOrdLine.DeleteAll();

        CheckHeader();
        CheckLines();
        CheckAndDeleteExistingOrder(); //ERP-328 +
        CreateOrder();
        Rec := NAVConfirmedOrder;
    end;

    var
        NAVConfirmedOrder: Record "GXL NAV Confirmed Order";
        TempNAVConfirmedOrdLine: Record "GXL NAV Confirmed Order Line" temporary;
        PurchHead: Record "Purchase Header";
        TransHead: Record "Transfer Header";
        AlreadyCreatedMsg: Label 'Confirmed Order %1 has already been created';
        StatusMustBeMsg: Label '%1 %2 must be in Status = %3';

    local procedure CheckHeader()
    var
        Vend: Record Vendor;
        Location: Record Location;
        TransferRoute: Record "Transfer Route";
        UseStdInTransitLoc: Boolean;
    begin
        if NAVConfirmedOrder."Document Type" = NAVConfirmedOrder."Document Type"::Purchase then begin
            //Vendor
            NAVConfirmedOrder.TestField("Buy-from Vendor No.");
            Vend.Get(NAVConfirmedOrder."Buy-from Vendor No.");
            Vend.CheckBlockedVendOnDocs(Vend, false);

            //Location
            NAVConfirmedOrder.TestField("Location Code");
            Location.Get(NAVConfirmedOrder."Location Code");
        end else begin
            NAVConfirmedOrder.TestField("Transfer-from Code");
            NAVConfirmedOrder.TestField("Transfer-to Code");
            Location.Get(NAVConfirmedOrder."Transfer-from Code");
            Location.Get(NAVConfirmedOrder."Transfer-to Code");

            UseStdInTransitLoc := true;
            if NAVConfirmedOrder."In-Transit Code" <> '' then begin
                if Location.Get(NAVConfirmedOrder."In-Transit Code") then
                    if Location."Use As In-Transit" then
                        UseStdInTransitLoc := false;
            end;
            if UseStdInTransitLoc then begin
                TransferRoute.Get(NAVConfirmedOrder."Transfer-from Code", NAVConfirmedOrder."Transfer-to Code");
                TransferRoute.TestField("In-Transit Code");
            end;
        end;
    end;

    local procedure CheckLines()
    var
        NAVConfirmedOrderLine: Record "GXL NAV Confirmed Order Line";
        Item: Record Item;
        GLAcc: Record "G/L Account";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        ItemNo: Code[20];
        UOMCode: Code[10];
        FoundQuantity: Boolean;
    begin
        NAVConfirmedOrderLine.Reset();
        NAVConfirmedOrderLine.SetRange("Document Type", NAVConfirmedOrder."Document Type");
        NAVConfirmedOrderLine.SetRange("Document No.", NAVConfirmedOrder."No.");
        NAVConfirmedOrderLine.SetRange("Version No.", NAVConfirmedOrder."Version No."); //ERP-328 +
        if NAVConfirmedOrderLine.FindSet() then
            repeat
                if NAVConfirmedOrderLine."No." <> '' then begin
                    case NAVConfirmedOrderLine.Type of
                        NAVConfirmedOrderLine.Type::"G/L Account":
                            begin
                                GLAcc.Get(NAVConfirmedOrderLine."No.");
                                GLAcc.CheckGLAcc();
                                GLAcc.TestField(Blocked, false);
                            end;
                        NAVConfirmedOrderLine.Type::Item:
                            begin
                                LegacyItemHelpers.GetItemNoForPurchase(NAVConfirmedOrderLine."No.", ItemNo, UOMCode, true);
                                NAVConfirmedOrderLine."Real Item No." := ItemNo;
                                NAVConfirmedOrderLine."Real Item UOM" := UOMCode;
                                Item.Get(ItemNo);
                                Item.TestField(Blocked, false);
                            end;
                        else
                            Error('Line %1, Type = %2 Not Supported!', NAVConfirmedOrderLine."Line No.", NAVConfirmedOrderLine.Type);
                    end;
                    if NAVConfirmedOrderLine.Quantity <> 0 then
                        FoundQuantity := true;
                end;
                TempNAVConfirmedOrdLine := NAVConfirmedOrderLine;
                TempNAVConfirmedOrdLine.Insert();
            until NAVConfirmedOrderLine.Next() = 0;

        if not FoundQuantity then
            Error('There is no line to create');
    end;

    local procedure CreateOrder()
    begin
        TempNAVConfirmedOrdLine.Reset();
        if TempNAVConfirmedOrdLine.FindSet() then begin
            case NAVConfirmedOrder."Document Type" of
                NAVConfirmedOrder."Document Type"::Purchase:
                    CreatePurchaseHeader();
                NAVConfirmedOrder."Document Type"::Transfer:
                    CreateTransferHeader();
            end;

            repeat
                case NAVConfirmedOrder."Document Type" of
                    NAVConfirmedOrder."Document Type"::Purchase:
                        CreatePurchaseLine(TempNAVConfirmedOrdLine);
                    NAVConfirmedOrder."Document Type"::Transfer:
                        CreateTransferLine(TempNAVConfirmedOrdLine);
                end;
            until TempNAVConfirmedOrdLine.Next() = 0;
        end;
    end;

    local procedure CreatePurchaseHeader()
    var
    begin
        PurchHead.Init();
        PurchHead."Document Type" := PurchHead."Document Type"::Order;
        PurchHead."No." := NAVConfirmedOrder."No.";
        PurchHead."GXL International Order" := NAVConfirmedOrder."International Order"; // >> HP2-SPRINT2 <<
        PurchHead.Insert(true);


        if NAVConfirmedOrder."Document Date" <> 0D then
            PurchHead."Posting Date" := NAVConfirmedOrder."Document Date";
        PurchHead.Validate("Buy-from Vendor No.", NAVConfirmedOrder."Buy-from Vendor No.");

        PurchHead."LSC Store No." := ''; //Force it as LS Retail populated Location Code from Store User Setup
        PurchHead.Validate("Location Code", NAVConfirmedOrder."Location Code");

        //Force to Validate Pay-to Vendor No. so that Dimension for Store is populated
        if NAVConfirmedOrder."Pay-to Vendor No." = '' then
            NAVConfirmedOrder."Pay-to Vendor No." := NAVConfirmedOrder."Buy-from Vendor No.";
        PurchHead.Validate("Pay-to Vendor No.", NAVConfirmedOrder."Pay-to Vendor No.");
        // >> HP2-SPRINT2
        // PurchHead."Order Date" := NAVConfirmedOrder."Order Date";
        PurchHead.Validate("Order Date", NAVConfirmedOrder."Order Date");
        // << HP2-SPRINT2
        if NAVConfirmedOrder."Document Date" <> 0D then
            PurchHead.Validate("Document Date", NAVConfirmedOrder."Document Date");
        PurchHead.Validate("Expected Receipt Date", NAVConfirmedOrder."Expected Receipt Date");
        PurchHead."Vendor Order No." := NAVConfirmedOrder."Vendor Order No.";
        PurchHead."Vendor Invoice No." := NAVConfirmedOrder."Vendor Invoice No.";
        PurchHead."Prices Including VAT" := NAVConfirmedOrder."Prices Including VAT";
        PurchHead.Validate("Currency Code", NAVConfirmedOrder."Currency Code");

        PurchHead.GXL_InitSupplyChain();
        // PurchHead."GXL International Order" := NAVConfirmedOrder."International Order";
        PurchHead."GXL Source of Supply" := NAVConfirmedOrder."Source of Supply";
        PurchHead."GXL 3PL" := NAVConfirmedOrder."3PL";
        PurchHead."GXL 3PL EDI" := NAVConfirmedOrder."3PL EDI";
        PurchHead."GXL 3PL File Sent" := NAVConfirmedOrder."3PL File Sent";
        PurchHead."GXL 3PL File Sent Date" := NAVConfirmedOrder."3PL File Sent Date";
        PurchHead."GXL Audit Flag" := NAVConfirmedOrder."Audit Flag";
        PurchHead."GXL EDI Order" := NAVConfirmedOrder."EDI Order";
        PurchHead."GXL EDI Order in Out. Pack UoM" := NAVConfirmedOrder."EDI Order in Outer Pack UoM";
        PurchHead."GXL EDI Vendor Type" := NAVConfirmedOrder."EDI Vendor Type";
        PurchHead."GXL Last EDI Document Status" := NAVConfirmedOrder."Last EDI Document Status";
        // >> HP2-Sprint2
        // if PurchHead."GXL Last EDI Document Status" = PurchHead."GXL Last EDI Document Status"::" " then begin
        //     if PurchHead."GXL EDI Order" or (PurchHead."GXL EDI Vendor Type" = PurchHead."GXL EDI Vendor Type"::VAN) then
        //         PurchHead."GXL Last EDI Document Status" := PurchHead."GXL Last EDI Document Status"::POR
        //     else
        //         if PurchHead."GXL EDI Vendor Type" = PurchHead."GXL EDI Vendor Type"::"Point 2 Point" then
        //             PurchHead."GXL Last EDI Document Status" := PurchHead."GXL Last EDI Document Status"::PO;
        // end;
        PurchHead."GXL Last EDI Document Status" := PurchHead."GXL Last EDI Document Status"::" ";
        // << HP2-Sprint2
        PurchHead."GXL Manual PO" := NAVConfirmedOrder."Manual Document";
        PurchHead."GXL Order Conf. Received" := NAVConfirmedOrder."Order Confirmation Received";
        PurchHead."GXL Order Confirmation Date" := NAVConfirmedOrder."Order Confirmation Date";
        // >> HP2-SPRINT2
        // PurchHead."GXL Order Status" := PurchHead."GXL Order Status"::Placed;
        PurchHead."GXL Order Status" := PurchHead."GXL Order Status"::Created;
        // << HP2-SPRINT2
        PurchHead."GXL Order Type" := NAVConfirmedOrder."Order Type";

        //ERP-NAV Master Data Management +
        PurchHead."GXL Transport Type" := NAVConfirmedOrder."Transport Type";
        PurchHead."GXL Departure Port" := NAVConfirmedOrder."Departure Port";
        PurchHead."GXL Arrival Port" := NAVConfirmedOrder."Arrival Port";
        PurchHead."GXL Incoterms Code" := NAVConfirmedOrder."Incoterms Code";
        PurchHead."GXL Import Agent Number" := NAVConfirmedOrder."Import Agent Number";
        PurchHead."GXL Container No." := NAVConfirmedOrder."Container No.";
        PurchHead."GXL Container Type" := NAVConfirmedOrder."Container Type";
        PurchHead."GXL Container Carrier" := NAVConfirmedOrder."Container Carrier";
        PurchHead."GXL Container Vessel" := NAVConfirmedOrder."Container Vessel";
        PurchHead."GXL Shipment Load Type" := NAVConfirmedOrder."Shipment Load Type";
        // >> HP2-SPRINT2
        // PurchHead."GXL Vendor Shipment Date" := NAVConfirmedOrder."Vendor Shipment Date";
        // PurchHead."GXL Expected Shipment Date" := NAVConfirmedOrder."Expected Shipment Date";
        // PurchHead."GXL Port Arrival Date" := NAVConfirmedOrder."Port Arrival Date";
        // PurchHead."GXL DC Receipt Date" := NAVConfirmedOrder."DC Receipt Date";
        // PurchHead."GXL Into Port Arrival Date" := NAVConfirmedOrder."Into Port Arrival Date";
        // PurchHead."GXL Into DC Delivery Date" := NAVConfirmedOrder."Into DC Delivery Date";

        PurchHead.Validate("GXL Vendor Shipment Date", NAVConfirmedOrder."Vendor Shipment Date");
        PurchHead.Validate("GXL Into Port Arrival Date", NAVConfirmedOrder."Into Port Arrival Date");
        PurchHead.Validate("GXL Into DC Delivery Date", NAVConfirmedOrder."Into DC Delivery Date");
        PurchHead.Validate("GXL Expected Shipment Date", NAVConfirmedOrder."Expected Shipment Date");
        PurchHead.Validate("GXL Port Arrival Date", NAVConfirmedOrder."Port Arrival Date");
        PurchHead.Validate("GXL DC Receipt Date", NAVConfirmedOrder."DC Receipt Date");
        // << HP2-SPRINT2
        //ERP-NAV Master Data Management -

        PurchHead."GXL Created Date" := NAVConfirmedOrder."Created Date";
        PurchHead."GXL Created Time" := NAVConfirmedOrder."Created Time";
        PurchHead."GXL Created By User ID" := NAVConfirmedOrder."Created By User ID";
        PurchHead.Modify(true);

    end;

    local procedure CreatePurchaseLine(TempNAVConfirmedOrdLine: Record "GXL NAV Confirmed Order Line")
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.Init();
        PurchLine."Document Type" := PurchHead."Document Type";
        PurchLine."Document No." := PurchHead."No.";
        PurchLine."Line No." := TempNAVConfirmedOrdLine."Line No.";
        // PurchLine.Insert(true); //ERP-397 -
        PurchLine.Type := TempNAVConfirmedOrdLine.Type;
        if (PurchLine.Type <> PurchLine.Type::" ") and (TempNAVConfirmedOrdLine."No." <> '') then begin
            PurchLine.SuspendOrderStatusCheck(true);
            PurchLine.Validate("No.", TempNAVConfirmedOrdLine."Real Item No.");
            PurchLine.Validate("Unit of Measure Code", TempNAVConfirmedOrdLine."Real Item UOM");
            PurchLine.Description := TempNAVConfirmedOrdLine.Description;
            PurchLine.Validate(Quantity, TempNAVConfirmedOrdLine.Quantity);
            PurchLine.Validate("Direct Unit Cost", TempNAVConfirmedOrdLine."Direct Unit Cost");
            if PurchLine."Line Discount %" <> TempNAVConfirmedOrdLine."Line Discount %" then
                PurchLine.Validate("Line Discount %", TempNAVConfirmedOrdLine."Line Discount %");
            if PurchLine."Line Amount" <> TempNAVConfirmedOrdLine."Line Amount" then
                PurchLine.Validate("Line Amount", TempNAVConfirmedOrdLine."Line Amount");
            if PurchLine."Expected Receipt Date" <> TempNAVConfirmedOrdLine."Expected Receipt Date" then
                PurchLine.Validate("Expected Receipt Date", TempNAVConfirmedOrdLine."Expected Receipt Date");
            PurchLine."GXL Carton-Qty" := TempNAVConfirmedOrdLine."Carton-Qty";
            PurchLine."GXL Confirmed Direct Unit Cost" := TempNAVConfirmedOrdLine."Confirmed Direct Unit Cost";
            PurchLine."GXL Confirmed Quantity" := TempNAVConfirmedOrdLine."Confirmed Quantity";
            PurchLine."GXL ConfirmedQtyVar" := TempNAVConfirmedOrdLine.ConfirmedQtyVar;
            PurchLine."GXL Primary EAN" := TempNAVConfirmedOrdLine."Primary EAN";
            PurchLine."GXL Vendor OP Reorder No." := TempNAVConfirmedOrdLine."Vendor OP Reorder No.";
            PurchLine."GXL Vendor Reorder No." := TempNAVConfirmedOrdLine."Vendor Reorder No";
            PurchLine."GXL OP Unit of Measure Code" := TempNAVConfirmedOrdLine."OP Unit of Measure Code";
            // >> HP2-Sprint2 
            PurchLine."GXL OP GTIN" := TempNAVConfirmedOrdLine."GXL OP GTIN";
            PurchLine."GXL OM GTIN" := TempNAVConfirmedOrdLine."GXL OM GTIN";
            PurchLine."GXL Pallet GTIN" := TempNAVConfirmedOrdLine."GXL Pallet GTIN";
            // << HP2-Sprint2 
            //ERP-NAV Master Data Management +
            PurchLine."GXL Gross Weight" := TempNAVConfirmedOrdLine."Gross Weight";
            PurchLine."GXL Cubage" := TempNAVConfirmedOrdLine.Cubage;
            //ERP-NAV Master Data Management -

            // PurchLine.Modify(true); //ERP-397 -
        end else begin
            PurchLine.Description := TempNAVConfirmedOrdLine.Description;
            // PurchLine.Modify(true); //ERP-397 -
        end;
        PurchLine.Insert(true); //ERP-397 +
    end;

    local procedure CreateTransferHeader()
    var
        Location: Record Location;
    //Store: Record "LSC Store";
    //RetailTransOrdExt: Codeunit "Retail Transfer Order Ext.";
    begin
        TransHead.Init();
        TransHead."No." := NAVConfirmedOrder."No.";
        TransHead.Insert(true);
        TransHead.Validate("Transfer-from Code", NAVConfirmedOrder."Transfer-from Code");
        TransHead.Validate("Transfer-to Code", NAVConfirmedOrder."Transfer-to Code");
        if (NAVConfirmedOrder."In-Transit Code" <> '') and (TransHead."In-Transit Code" <> NAVConfirmedOrder."In-Transit Code") then
            if Location.Get(NAVConfirmedOrder."In-Transit Code") then
                TransHead.Validate("In-Transit Code", NAVConfirmedOrder."In-Transit Code");

        //PS-2143+
        //Removed - will be handled from event trigger in codeunit
        /*
        Location.Code := TransHead."Transfer-from Code";
        if Location.GetAssociatedStore(Store, true) then begin
            TransHead."Store-from" := Store."No.";
            RetailTransOrdExt.SetStoreDimension(TransHead, TransHead.FieldNo("Store-from"));
        end;
        Location.Code := TransHead."Transfer-to Code";
        if Location.GetAssociatedStore(Store, true) then begin
            TransHead."Store-to" := Store."No.";
            RetailTransOrdExt.SetStoreDimension(TransHead, TransHead.FieldNo("Store-to"));
        end;
        */
        //PS-2143-

        TransHead."External Document No." := NAVConfirmedOrder."External Document No.";
        TransHead."Receipt Date" := NAVConfirmedOrder."Expected Receipt Date";
        TransHead."GXL 3PL" := NAVConfirmedOrder."3PL";
        // >> HP2-SPRINT2
        // TransHead."GXL 3PL File Sent" := NAVConfirmedOrder."3PL File Sent";
        // TransHead."GXL 3PL File Sent Date" := NAVConfirmedOrder."3PL File Sent Date";
        TransHead."GXL 3PL File Sent" := false;
        TransHead."GXL 3PL File Sent Date" := 0D;
        // <<   HP2-SPRINT2
        TransHead."GXL Audit Flag" := NAVConfirmedOrder."Audit Flag";
        TransHead."GXL Expected Receipt Date" := NAVConfirmedOrder."Expected Receipt Date";
        TransHead."GXL Delivery Date" := NAVConfirmedOrder."Delivery Date";
        TransHead."GXL Order Date" := NAVConfirmedOrder."Order Date";
        //ERP-328 +
        if TransHead."GXL Order Date" = 0D then
            TransHead."GXL Order Date" := NAVConfirmedOrder."Created Date";
        //ERP-328 -

        //TODO Order Status
        //Need to set to Placed as Confirmed status means transfer order has already been shipped in NAV13
        TransHead."GXL Order Status" := TransHead."GXL Order Status"::Placed;

        TransHead."GXL Created By User ID" := NAVConfirmedOrder."Created By User ID";
        TransHead."GXL Created Date" := NAVConfirmedOrder."Created Date";
        TransHead."GXL Created Time" := NAVConfirmedOrder."Created Time";
        TransHead.Modify(true);
    end;

    local procedure CreateTransferLine(TempNAVConfirmedOrderLine: Record "GXL NAV Confirmed Order Line")
    var
        TransLine: Record "Transfer Line";
    begin
        TransLine.Init();
        TransLine."Document No." := TransHead."No.";
        TransLine."Line No." := TempNAVConfirmedOrderLine."Line No.";
        TransLine.Insert(true);
        TransLine.Validate("Item No.", TempNAVConfirmedOrderLine."Real Item No.");
        TransLine.Validate("Unit of Measure Code", TempNAVConfirmedOrderLine."Real Item UOM");
        TransLine.Validate(Quantity, TempNAVConfirmedOrderLine.Quantity);
        TransLine.Validate("GXL Unit Cost", TempNAVConfirmedOrderLine."Direct Unit Cost");

        //ERP-NAV Master Data Management +
        TransLine."Gross Weight" := TempNAVConfirmedOrderLine."Gross Weight";
        TransLine."Unit Volume" := TempNAVConfirmedOrderLine.Cubage;
        //ERP-NAV Master Data Management -

        TransLine.Modify();
    end;

    procedure GetPurchaseHeader(var NewPurchHead: Record "Purchase Header")
    begin
        NewPurchHead := PurchHead;
    end;

    procedure GetTransferHeader(var NewTransHead: Record "Transfer Header")
    begin
        NewTransHead := TransHead;
    end;

    //ERP-328 +
    /// <summary>
    /// Check if order has been received/shipped if already exists
    /// Delete the existing order if already exists
    /// </summary>
    local procedure CheckAndDeleteExistingOrder()
    var
        PurchHead2: Record "Purchase Header";
        PurchLine2: Record "Purchase Line";
        TransHead2: Record "Transfer Header";
        TransLine2: Record "Transfer Line";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        ReleaseTransDoc: Codeunit "Release Transfer Document";
    begin
        if NAVConfirmedOrder."Document Type" = NAVConfirmedOrder."Document Type"::Purchase then begin
            if PurchHead2.Get(PurchHead2."Document Type"::Order, NAVConfirmedOrder."No.") then begin
                PurchLine2.SetRange("Document Type", PurchHead2."Document Type");
                PurchLine2.SetRange("Document No.", PurchHead2."No.");
                PurchLine2.SetFilter("Quantity Received", '<>0');
                if not PurchLine2.IsEmpty() then
                    Error('Purchase Order has already been received');

                if PurchHead2.Status <> PurchHead2.Status::Open then
                    ReleasePurchDoc.PerformManualReopen(PurchHead2);
                PurchHead2.Delete(true);
            end;
        end;
        if NAVConfirmedOrder."Document Type" = NAVConfirmedOrder."Document Type"::Transfer then begin
            if TransHead2.Get(NAVConfirmedOrder."No.") then begin
                TransLine2.SetRange("Document No.", TransHead2."No.");
                TransLine2.SetFilter("Quantity Shipped", '<>0');
                if not TransLine2.IsEmpty() then
                    Error('Transfer Order has already been shipped');

                if TransHead2.Status = TransHead2.Status::Released then
                    ReleaseTransDoc.Reopen(TransHead2);
                TransHead2.Delete(true);
            end;
        end;
    end;
    //ERP-328 -
}