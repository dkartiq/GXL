// 001 29.10.2024 KDU https://petbarnjira.atlassian.net/browse/LCB-340
xmlport 50076 "GXL P2P-Invoice"
{
    // Import
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(InboundInvoice)
        {
            MaxOccurs = Once;
            tableelement("PO INV Header"; "GXL PO INV Header")
            {
                XmlName = 'InvoiceHeader';
                fieldelement(VendorInvoiceNumber; "PO INV Header"."Original EDI Document No.")
                {
                }
                fieldelement(InvoiceDate; "PO INV Header"."Invoice Received Date")
                {
                }
                fieldelement(PurchaseOrderNumber; "PO INV Header"."Purchase Order No.")
                {
                }
                fieldelement(BuyerID; "PO INV Header"."Pay-to Vendor No.")
                {
                }
                fieldelement(BuyerABN; "PO INV Header"."Buyer ABN")
                {
                }
                fieldelement(SupplierID; "PO INV Header"."Buy-from Vendor No.")
                {
                }
                fieldelement(SupplierABN; "PO INV Header"."P2P Supplier ABN")
                {
                }
                fieldelement(ShipToCode; "PO INV Header"."Location Code")
                {
                }
                fieldelement(ShipFor; "PO INV Header"."Ship For")
                {
                }
                fieldelement(InvoiceType; "PO INV Header"."Invoice Type")
                {
                }
                fieldelement(ASNNumber; "PO INV Header"."Original ASN No.")
                {
                }
                fieldelement(DeliveryDate; "PO INV Header"."Expected Receipt Date")
                {
                }
                fieldelement(InvoiceSubTotal; "PO INV Header".Amount)
                {
                }
                fieldelement(InvoiceTotal; "PO INV Header"."Amount Incl. VAT")
                {
                }
                fieldelement(InvoiceTotalGST; "PO INV Header"."Total GST")
                {
                }
                tableelement("PO INV Line"; "GXL PO INV Line")
                {
                    LinkFields = "INV No." = FIELD("No.");
                    LinkTable = "PO INV Header";
                    XmlName = 'InvoiceItemDetails';
                    fieldelement(LineNumber; "PO INV Line"."Line No.")
                    {
                    }
                    fieldelement(LineReference; "PO INV Line"."PO Line No.")
                    {
                    }
                    fieldelement(Items; "PO INV Line".ILC)
                    {
                        trigger OnAfterAssignField()
                        var
                            LegacyItemHelper: Codeunit "GXL Legacy Item Helpers";
                            ItemNo: Code[20];
                            UOMCode: Code[10];
                        begin
                            LegacyItemHelper.GetItemNo("PO INV Line".ILC, ItemNo, UOMCode);
                            "PO INV Line".Validate("Item No.", ItemNo);
                            "PO INV Line".Validate("Unit of Measure Code", UOMCode);
                        end;
                    }
                    // fieldelement(Items; "PO INV Line"."Item No.")
                    // {
                    // }
                    fieldelement(GTIN; "PO INV Line"."Primary EAN")
                    {

                        trigger OnAfterAssignField()
                        begin
                            GetVendor();
                            if Vendor."GXL EDI Order in Out. Pack UoM" then
                                if PurchLine.Get(PurchLine."Document Type"::Order, "PO INV Header"."Purchase Order No.", "PO INV Line"."PO Line No.") then
                                    // IF Item GTIN on Invoice matches the item OP GTIN
                                    //   Then switch to item's purchase UOM GTIN (stored on the purchase line "Primary EAN" field) as the item on invoice matches the PO
                                    // Otherwise retain supplier GTIN to determine item mismatch during validation
                                    if "PO INV Line"."Primary EAN" = PurchLine."GXL OP GTIN" then
                                        "PO INV Line"."Primary EAN" := PurchLine."GXL Primary EAN";
                        end;
                    }
                    fieldelement(SupplierNo; "PO INV Line"."Vendor Reorder No.")
                    {

                        trigger OnAfterAssignField()
                        begin
                            GetVendor();
                            if Vendor."GXL EDI Order in Out. Pack UoM" then
                                if PurchLine.Get(PurchLine."Document Type"::Order, "PO INV Header"."Purchase Order No.", "PO INV Line"."PO Line No.") then
                                    // IF SupplierNo on Invoice matches the Vendor's OP Reoorder No. in NAV
                                    //   Then switch to the Item's Purchase UOM Vendor Reorder No. as the item on Invoice matches the PO
                                    // Otherwise retain original SupplierNo on ASN to determine item mismatch during validation
                                    if "PO INV Line"."Vendor Reorder No." = PurchLine."GXL Vendor OP Reorder No." then
                                        "PO INV Line"."Vendor Reorder No." := PurchLine."GXL Vendor Reorder No.";
                        end;
                    }
                    fieldelement(Description; "PO INV Line".Description)
                    {
                    }
                    fieldelement(OMQTY; "PO INV Line".OMQTY)
                    {

                        trigger OnAfterAssignField()
                        begin
                            GetSKU();
                            GetVendor();
                            if Vendor."GXL EDI Order in Out. Pack UoM" then
                                "PO INV Line".OMQTY := SKU."GXL Order Multiple (OM)";
                        end;
                    }
                    fieldelement(OPQTY; "PO INV Line".OPQTY)
                    {

                        trigger OnAfterAssignField()
                        begin
                            GetSKU();
                            GetVendor();
                            if Vendor."GXL EDI Order in Out. Pack UoM" then
                                "PO INV Line".OPQTY := SKU."GXL Order Pack (OP)";
                        end;
                    }
                    fieldelement(QTYToInvoice; "PO INV Line"."Qty. to Invoice")
                    {
                    }
                    fieldelement(UnitQTYToInvoice; "PO INV Line"."Unit QTY To Invoice")
                    {

                        trigger OnAfterAssignField()
                        begin
                            GetSKU();
                            GetVendor();

                            // "Qty. to Invoice" represents 1 unit of vendor's shipping UOM in terms of 1 unit of PB purchase UOM
                            // For vendor's shipping in a different UOM to the purchase UOM, these values might not match as the vendor's pack size setup might not match PB
                            // Therefore, for these vendors, "Qty. to Invoice" is replaced with "Unit Qty. to Invoice" to ensure these values match
                            if Vendor."GXL EDI Order in Out. Pack UoM" then
                                "PO INV Line"."Qty. to Invoice" := "PO INV Line"."Unit QTY To Invoice";

                            "PO INV Line"."Unit QTY To Invoice" := EDIFunctions.ConvertQty_ShippingUnitToOrderUnit_VendorRec(Vendor, SKU, "PO INV Line"."Unit QTY To Invoice");

                        end;
                    }
                    fieldelement(ItemPrice; "PO INV Line"."Direct Unit Cost")
                    {

                        trigger OnAfterAssignField()
                        begin
                            GetSKU();
                            GetVendor();
                            "PO INV Line"."Direct Unit Cost" := EDIFunctions.ConvertPrice_ShippingUnitToOrderUnit_VendorRec(Vendor, SKU, "PO INV Line"."Direct Unit Cost");
                        end;
                    }
                    fieldelement(LineAmountExcl; "PO INV Line".Amount)
                    {
                    }
                    fieldelement(LineAmountIncl; "PO INV Line"."Amount Incl. VAT")
                    {
                    }
                    fieldelement(UOM; "PO INV Line"."Unit of Measure Code")
                    {
                    }
                    fieldelement(ItemGSTAmount; "PO INV Line"."Item GST Amount")
                    {

                        trigger OnBeforePassField()
                        begin
                            "PO INV Line"."Item GST Amount" := "PO INV Line"."Amount Incl. VAT" - "PO INV Line".Amount;
                        end;
                    }
                    fieldelement(ItemGSTPercentage; "PO INV Line"."VAT %")
                    {
                    }
                }

                trigger OnBeforeInsertRecord()
                var
                    StaticUnitL: Codeunit "GXL WMS Single Instance";
                begin
                    if StaticUnitL.GetEDIFileLogEntryNo() > 0 then begin
                        EDIFileLogEntryNo := StaticUnitL.GetEDIFileLogEntryNo();
                        StaticUnitL.SetEDIFileLogEntryNo(0);
                        "PO INV Header"."EDI Vendor Type" := "PO INV Header"."EDI Vendor Type"::"Point 2 Point";
                    end;
                    GetVendor();
                    "PO INV Header"."No." := InvNo;
                    "PO INV Header".Status := "PO INV Header".Status::Imported;
                    "PO INV Header"."EDI File Log Entry No." := EDIFileLogEntryNo;
                    "PO INV Header"."Supplier Name" := Vendor.Name;
                end;
            }
        }
    }


    trigger OnPreXmlPort()
    begin
        InvNo := MiscUtilities.GetNextEDIDocumentNo(DocumentType::INV);
    end;

    var
        SKU: Record "Stockkeeping Unit";
        Vendor: Record Vendor;
        PurchLine: Record "Purchase Line";
        EDIFunctions: Codeunit "GXL EDI Functions Library";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        DocumentType: Option POR,ASN,INV;
        InvNo: Code[20];
        EDIFileLogEntryNo: Integer;


    [Scope('OnPrem')]
    procedure SetEDIFileLogEntryNo(EDIFileLogEntryNoNew: Integer)
    begin
        EDIFileLogEntryNo := EDIFileLogEntryNoNew;
    end;


    [Scope('OnPrem')]
    procedure GetSKU()
    begin
        SKU.Reset();
        SKU.SetRange(SKU."Location Code", "PO INV Header"."Location Code");
        SKU.SetRange(SKU."Item No.", "PO INV Line"."Item No.");
        if SKU.FindFirst() then;
    end;

    [Scope('OnPrem')]
    procedure GetVendor()
    begin
        if Vendor.Get("PO INV Header"."Buy-from Vendor No.") then;
    end;
}

