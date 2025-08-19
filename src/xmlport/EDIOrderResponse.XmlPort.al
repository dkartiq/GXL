xmlport 50062 "GXL EDI-Order Response"
{
    // Used as import. Maybe export?
    // 20200302 - Updated so import converts. Hae not updated export.
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Caption = 'EDI-Order Response';
    schema
    {
        textelement(InboundOrderResponse)
        {
            MaxOccurs = Once;
            tableelement("PO Response Header"; "GXL PO Response Header")
            {
                XmlName = 'OrderResponseHeader';
                fieldelement(OrderResponseNumber; "PO Response Header"."Original EDI Document No.")
                {
                }
                fieldelement(OrderResponseDate; "PO Response Header"."PO Response Date")
                {
                }
                fieldelement(SupplierID; "PO Response Header"."Buy-from Vendor No.")
                {
                }
                fieldelement(ShipToCode; "PO Response Header"."Location Code")
                {
                }
                fieldelement(PurchaseOrderNumber; "PO Response Header"."Order No.")
                {
                }
                fieldelement(CommittedDeliveryDate; "PO Response Header"."Expected Receipt Date")
                {
                }
                fieldelement(ShipFor; "PO Response Header"."Ship-to Code")
                {
                }
                textelement(OrderResponseType)
                {

                    trigger OnAfterAssignVariable()
                    var
                        TempInt: Integer;
                    begin
                        // >>pv00.05
                        //OrderResponseType := FORMAT(EDIFunctions.GetSPSResponseType("PO Response Header"."Response Type"));
                        if not Evaluate(TempInt, OrderResponseType) then
                            OrderResponseType := Format(EDIFunctions.ConvertP2PPORResponseType(OrderResponseType));
                        // <<pv00.05
                    end;
                }
                tableelement("PO Response Line"; "GXL PO Response Line")
                {
                    LinkFields = "PO Response Number" = FIELD("Response Number");
                    LinkTable = "PO Response Header";
                    MinOccurs = Zero;
                    XmlName = 'OrderResponseItemDetails';
                    fieldelement(LineNumber; "PO Response Line"."Line No.")
                    {
                    }
                    fieldelement(LineReference; "PO Response Line"."PO Line No.")
                    {
                    }
                    fieldelement(ItemResponseIndicator; "PO Response Line"."Item Response Indicator")
                    {
                    }
                    textelement(Items)
                    {
                        trigger OnAfterAssignVariable()
                        var
                            LegacyItemHelper: Codeunit "GXL Legacy Item Helpers";
                            ItemL: Record Item;
                            EDIItemSupplier: Record "GXL EDI Item Supplier";
                            ItemNo: Code[20];
                            UOMCode: Code[10];
                        begin
                            LegacyItemHelper.GetItemNo(Items, ItemNo, UOMCode);
                            "PO Response Line".Validate("Item No.", ItemNo);
                            "PO Response Line".Validate("Unit of Measure Code", UOMCode);
                        end;
                    }
                    // fieldelement(Items; "PO Response Line"."Item No.")
                    // {
                    // }
                    // >> HP2-SPRINT <<
                    // fieldelement(GTIN; "PO Response Line"."Primary EAN")
                    // {
                    //  trigger OnAfterAssignField()
                    //     begin
                    //         GetVendor();
                    //         if _recVendor."GXL EDI Order in Out. Pack UoM" then
                    //             if PurchLine.Get(PurchLine."Document Type"::Order, "PO Response Header"."Order No.", "PO Response Line"."PO Line No.") then
                    //                 // IF GTIN on response matches the SKU OP GTIN
                    //                 //   Then switch to Primary GTIN as items match
                    //                 // Otherwise retain supplier GTIN to determine item mismatch during validation
                    //                 if "PO Response Line"."Primary EAN" = PurchLine."GXL OP GTIN" then
                    //                     "PO Response Line"."Primary EAN" := PurchLine."GXL Primary EAN";
                    //     end;
                    // }
                    textelement(GTIN)
                    {
                        trigger OnAfterAssignVariable()
                        var
                            ItemL: Record Item;
                            EDIItemSupplier: Record "GXL EDI Item Supplier";
                        begin
                            if EDIItemSupplier.Get("PO Response Line"."Item No.", "PO Response Header"."Buy-from Vendor No.") then
                                "PO Response Line".Validate("Primary EAN", EDIItemSupplier.GTIN)
                            else
                                if ItemL.Get("PO Response Line"."Item No.") then
                                    "PO Response Line".Validate("Primary EAN", ItemL.GTIN);

                            GetVendor();
                            if _recVendor."GXL EDI Order in Out. Pack UoM" then
                                if PurchLine.Get(PurchLine."Document Type"::Order, "PO Response Header"."Order No.", "PO Response Line"."PO Line No.") then
                                    // IF GTIN on response matches the SKU OP GTIN
                                    //   Then switch to Primary GTIN as items match
                                    // Otherwise retain supplier GTIN to determine item mismatch during validation
                                    if "PO Response Line"."Primary EAN" = PurchLine."GXL OP GTIN" then
                                        "PO Response Line"."Primary EAN" := PurchLine."GXL Primary EAN";
                        end;
                    }
                    // << HP2-SPRINT2
                    fieldelement(SupplierNo; "PO Response Line"."Vendor Reorder No.")
                    {

                        trigger OnAfterAssignField()
                        begin
                            GetVendor();
                            if _recVendor."GXL EDI Order in Out. Pack UoM" then
                                if PurchLine.Get(PurchLine."Document Type"::Order, "PO Response Header"."Order No.", "PO Response Line"."PO Line No.") then
                                    // IF Reorder No. on response matches the relevant field value on the purchase line (based on vendor setup)
                                    //   Then switch to purchase line vendor reorder no.
                                    // Otherwise retain the received value to determine reorder no. during validation
                                    if _recVendor."GXL EDI Supplier No. Source" = _recVendor."GXL EDI Supplier No. Source"::"Outer Pack GTIN" then begin
                                        if "PO Response Line"."Vendor Reorder No." = PurchLine."GXL OP GTIN" then
                                            "PO Response Line"."Vendor Reorder No." := PurchLine."GXL Vendor Reorder No.";
                                    end else
                                        if "PO Response Line"."Vendor Reorder No." = PurchLine."GXL Vendor OP Reorder No." then
                                            "PO Response Line"."Vendor Reorder No." := PurchLine."GXL Vendor Reorder No.";
                        end;
                    }
                    fieldelement(Description; "PO Response Line".Description)
                    {
                    }
                    fieldelement(OMQTY; "PO Response Line".OMQTY)
                    {

                        trigger OnBeforePassField()
                        begin
                            GetSKu();
                            "PO Response Line".OMQTY := _recSKU."GXL Order Multiple (OM)";
                        end;

                        trigger OnAfterAssignField()
                        begin
                            GetSKu();
                            GetVendor();
                            if _recVendor."GXL EDI Order in Out. Pack UoM" then
                                "PO Response Line".OMQTY := _recSKU."GXL Order Multiple (OM)";
                        end;
                    }
                    fieldelement(OPQTY; "PO Response Line".OPQTY)
                    {

                        trigger OnBeforePassField()
                        begin
                            GetSKu();
                            "PO Response Line".OPQTY := _recSKU."GXL Order Pack (OP)";
                        end;

                        trigger OnAfterAssignField()
                        begin
                            GetSKu();
                            GetVendor();
                            if _recVendor."GXL EDI Order in Out. Pack UoM" then
                                "PO Response Line".OPQTY := _recSKU."GXL Order Pack (OP)";
                        end;
                    }
                    fieldelement(ConfirmedOrderQtyOM; "PO Response Line".Quantity)
                    {

                        trigger OnAfterAssignField()
                        begin
                            GetSKu();
                            GetVendor();
                            "PO Response Line".Quantity := EDIFunctions.ConvertQty_ShippingUnitToOrderUnit_VendorRec(_recVendor, _recSKU, "PO Response Line".Quantity);
                        end;
                    }
                    fieldelement(ConfirmedOrderQtyOP; "PO Response Line"."Carton-Qty")
                    {
                    }
                    fieldelement(ConfirmedOrderQtyUnit; "PO Response Line".Quantity)
                    {

                        trigger OnAfterAssignField()
                        begin
                            GetSKu();
                            GetVendor();
                            "PO Response Line".Quantity := EDIFunctions.ConvertQty_ShippingUnitToOrderUnit_VendorRec(_recVendor, _recSKU, "PO Response Line".Quantity);
                        end;
                    }
                    fieldelement(ItemPrice; "PO Response Line"."Direct Unit Cost")
                    {

                        trigger OnAfterAssignField()
                        begin
                            GetSKu();
                            GetVendor();
                            "PO Response Line"."Direct Unit Cost" := EDIFunctions.ConvertPrice_ShippingUnitToOrderUnit_VendorRec(_recVendor, _recSKU, "PO Response Line"."Direct Unit Cost");
                        end;
                    }
                    // fieldelement(UOM; "PO Response Line"."Unit of Measure Code")
                    textelement(UOM)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            UOMG := UOM;
                        end;

                    }
                }

                trigger OnAfterGetRecord()
                begin
                    OrderResponseType := Format(EDIFunctions.GetSPSResponseType("PO Response Header"."Response Type"));
                end;

                trigger OnBeforeInsertRecord()
                var
                    RespTypeInt: Integer;
                begin
                    "PO Response Header"."Response Number" := OrderResponseNo;

                    "PO Response Header".Status := "PO Response Header".Status::Imported;
                    "PO Response Header"."EDI File Log Entry No." := EDIFileLogEntryNo;

                    Evaluate(RespTypeInt, OrderResponseType);
                    "PO Response Header"."Response Type" := EDIFunctions.GetEDIResponseType(RespTypeInt);
                end;
            }
        }
    }


    trigger OnPreXmlPort()
    begin
        OrderResponseNo := MiscUtilities.GetNextEDIDocumentNo(0);
    end;

    var
        _recSKU: Record "Stockkeeping Unit";
        _recVendor: Record Vendor;
        PurchLine: Record "Purchase Line";
        EDIFunctions: Codeunit "GXL EDI Functions Library";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        OrderResponseNo: Code[35];
        EDIFileLogEntryNo: Integer;
        UOMG: Code[20]; // >> HP2-SPRINT2 <<

    [Scope('OnPrem')]
    procedure GetSKu()
    begin
        _recSKU.Reset();
        _recSKU.SetRange(_recSKU."Location Code", "PO Response Header"."Location Code");
        _recSKU.SetRange(_recSKU."Item No.", "PO Response Line"."Item No.");
        if _recSKU.FindFirst() then;
    end;

    [Scope('OnPrem')]
    procedure GetVendor()
    begin
        if _recVendor.Get("PO Response Header"."Buy-from Vendor No.") then begin
        end;
    end;

    [Scope('OnPrem')]
    procedure SetEDIFileLogEntryNo(EDIFileLogEntryNoNew: Integer)
    begin
        EDIFileLogEntryNo := EDIFileLogEntryNoNew;
    end;

    local procedure ConvertResponseType()
    begin
    end;
}

