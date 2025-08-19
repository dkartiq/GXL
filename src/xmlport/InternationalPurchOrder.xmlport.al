xmlport 50086 "GXL International Purch. Order"
{
    Direction = Export;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Caption = 'International Purch. Order';
    schema
    {
        textelement(OutBoundPurchaseOrder)
        {
            MaxOccurs = Once;
            tableelement("Purchase Header"; "Purchase Header")
            {
                RequestFilterFields = "Document Type", "No.";
                XmlName = 'OrderHeader';
                SourceTableView = SORTING("Document Type", "No.") ORDER(Ascending) WHERE("Document Type" = CONST(Order));
                textelement(CustomerID)
                {
                }
                fieldelement(SupplierID; "Purchase Header"."Buy-from Vendor No.")
                {
                }
                fieldelement(SupplierName; "Purchase Header"."Buy-from Vendor Name")
                {
                }
                fieldelement(SupplierAddress; "Purchase Header"."Buy-from Address")
                {
                }
                textelement(SupplierAddress2)
                {

                    trigger OnBeforePassVariable()
                    begin
                        SupplierAddress2 := "Purchase Header"."Buy-from City" + ' ' + "Purchase Header"."Pay-to Post Code" + ' ' + "Purchase Header"."Pay-to County";
                    end;
                }
                fieldelement(SupplierContact; "Purchase Header"."Buy-from Contact")
                {
                }
                textelement(SupplierPhone)
                {

                    trigger OnBeforePassVariable()
                    begin
                        GetVendor();
                        SupplierPhone := _recVendor."Phone No.";
                    end;
                }
                textelement(SupplierEmail)
                {

                    trigger OnBeforePassVariable()
                    begin
                        GetVendor();
                        SupplierEmail := _recVendor."GXL PO Email Address";
                    end;
                }
                fieldelement(IncoTerms; "Purchase Header"."GXL Incoterms Code")
                {
                }
                fieldelement(ShipmentMethod; "Purchase Header"."Shipment Method Code")
                {
                }
                fieldelement(OriginPort; "Purchase Header"."GXL Departure Port")
                {
                }
                fieldelement(DestinationPort; "Purchase Header"."GXL Arrival Port")
                {
                }
                fieldelement(DestinationDC; "Purchase Header"."Location Code")
                {
                }
                textelement(ShipToEntityID)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ShipToEntityID := 'DST';
                    end;
                }
                fieldelement(ShipToCode; "Purchase Header"."Location Code")
                {
                }
                fieldelement(ShiptoAddress; "Purchase Header"."Ship-to Address")
                {
                }
                fieldelement(ShiptoAddress2; "Purchase Header"."Ship-to Address 2")
                {
                }
                fieldelement(ShipToCity; "Purchase Header"."Ship-to City")
                {
                }
                fieldelement(ShipToState; "Purchase Header"."Ship-to County")
                {
                }
                fieldelement(ShipToPostCode; "Purchase Header"."Ship-to Post Code")
                {
                }
                textelement(Phone)
                {

                    trigger OnBeforePassVariable()
                    begin
                        if _recLocation.Get("Purchase Header"."Location Code") then begin
                            Phone := _recLocation."Phone No.";
                        end;
                    end;
                }
                textelement(Email)
                {

                    trigger OnBeforePassVariable()
                    begin
                        if _recLocation.Get("Purchase Header"."Location Code") then begin
                            Email := _recLocation."E-Mail";
                        end;
                    end;
                }
                fieldelement(OrderNumber; "Purchase Header"."No.")
                {
                }
                textelement(OrderVersion)
                {

                    trigger OnBeforePassVariable()
                    begin
                        OrderVersion := Format("Purchase Header"."GXL Freight Forwarder File Ver" + 1); // >> HP2-Sprint2 <<
                    end;
                }
                fieldelement(SupplierOrderNumber; "Purchase Header"."Vendor Order No.")
                {
                }
                fieldelement(OrderDate; "Purchase Header"."Order Date")
                {
                }
                textelement(OrderAction)
                {

                    trigger OnBeforePassVariable()
                    begin
                        case "Purchase Header"."GXL Order Status" of
                            "Purchase Header"."GXL Order Status"::Confirmed:
                                begin
                                    // >> HP2-Sprint2
                                    if "Purchase Header"."GXL Freight Forward. File Sent" then
                                        OrderAction := 'CHG'
                                    else
                                        OrderAction := 'NEW';
                                    // << HP2-Sprint2
                                end;
                            "Purchase Header"."GXL Order Status"::Cancelled:
                                OrderAction := 'CAN';
                        end;
                    end;
                }
                textelement(OrderContent)
                {

                    trigger OnBeforePassVariable()
                    begin
                        OrderContent := 'Complete';
                    end;
                }
                fieldelement(RequiredDate; "Purchase Header"."GXL Vendor Shipment Date")
                {
                }
                fieldelement(ExpectedArrivalDate; "Purchase Header"."GXL Port Arrival Date")
                {
                }
                fieldelement(TotalOrderQty; "Purchase Header"."GXL Total Order Qty")
                {
                }
                // 001 >> 18.08.2025 MAY HP2 SP2 
                fieldelement(TotalOrderAmount; "Purchase Header"."GXL Total Order Value")
                {

                }
                // 001 << 18.08.2025 MAY HP2 SP2 
                textelement(ShipFor)
                {

                    trigger OnBeforePassVariable()
                    begin
                        ShipFor := "Purchase Header"."Location Code";
                    end;
                }
                fieldelement(ShipForAddress; "Purchase Header"."Ship-to Address")
                {
                }
                fieldelement(ShipForAddress2; "Purchase Header"."Ship-to Address 2")
                {
                }
                fieldelement(ShipForCity; "Purchase Header"."Ship-to City")
                {
                }
                fieldelement(ShipForState; "Purchase Header"."Ship-to County")
                {
                }
                fieldelement(ShipForPostCode; "Purchase Header"."Ship-to Post Code")
                {
                }
                fieldelement(OrderInstruction; "Purchase Header"."GXL Transport Type")
                {
                }
                textelement(OrderTerms)
                {
                }
                tableelement("Purchase Line"; "Purchase Line")
                {
                    LinkFields = "Document No." = FIELD("No.");
                    LinkTable = "Purchase Header";
                    MinOccurs = Zero;
                    XmlName = 'OrderItemDetails';
                    SourceTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending) WHERE(Type = CONST(Item));
                    fieldelement(LineReference; "Purchase Line"."Line No.")
                    {
                    }
                    //Legacy Item +
                    // fieldelement(Items; "Purchase Line"."No.")
                    // {
                    // }
                    textelement(Items)
                    {
                        trigger OnBeforePassVariable()
                        var
                            LegacyItemHelper: Codeunit "GXL Legacy Item Helpers";
                            LegacyItemNo: Code[20];
                        begin
                            IF "Purchase Line".Type = "Purchase Line".Type::Item then begin
                                LegacyItemHelper.GetLegacyItemNo("Purchase Line"."No.", "Purchase Line"."Unit of Measure Code", LegacyItemNo);
                                Items := LegacyItemNo;
                            end else begin
                                Items := "Purchase Line"."No.";
                            end;
                        end;

                    }
                    //Legacy Item -
                    fieldelement(GTIN; "Purchase Line"."GXL Primary EAN")
                    {

                        trigger OnBeforePassField()
                        begin
                            GetVendor();
                            if _recVendor."GXL EDI Order in Out. Pack UoM" then
                                "Purchase Line"."GXL Primary EAN" := "Purchase Line"."GXL OP GTIN";
                        end;
                    }
                    fieldelement(SupplierReorderNo; "Purchase Line"."GXL Vendor Reorder No.")
                    {

                        trigger OnBeforePassField()
                        begin
                            GetVendor();
                            if _recVendor."GXL EDI Order in Out. Pack UoM" then
                                if _recVendor."GXL EDI Supplier No. Source" = _recVendor."GXL EDI Supplier No. Source"::"Outer Pack GTIN" then
                                    "Purchase Line"."GXL Primary EAN" := "Purchase Line"."GXL OP GTIN"
                                else
                                    "Purchase Line"."GXL Vendor Reorder No." := "Purchase Line"."GXL Vendor OP Reorder No.";
                        end;
                    }
                    fieldelement(Description; "Purchase Line".Description)
                    {
                    }
                    textelement(OMQTY)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            GetSKU();
                            GetVendor();
                            OMQTY := Format(EDIFunctions.GetSkuOMQty(_recVendor, _recSKU), 0, '<Standard Format,1>');
                        end;
                    }
                    textelement(OPQTY)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            GetSKU();
                            GetVendor();
                            OPQTY := Format(EDIFunctions.GetSkuOPQty(_recVendor, _recSKU), 0, '<Standard Format,1>');
                        end;
                    }
                    textelement(OrderQtyOM)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            GetVendor();
                            OrderQtyOM := Format(EDIFunctions.GetOrderOMQty(_recVendor, "Purchase Line"), 0, '<Standard Format,1>');
                        end;
                    }
                    fieldelement(OrderQtyOP; "Purchase Line"."GXL Carton-Qty")
                    {
                    }
                    textelement(OrderQtyUnit)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            GetVendor();
                            OrderQtyUnit := Format(EDIFunctions.GetOrderUnitQty(_recVendor, "Purchase Line"), 0, '<Standard Format,1>');
                            ;
                        end;
                    }
                    // 001 >> 18.08.2025 MAY HP2 SP2 
                    fieldelement(ItemPrice; "Purchase Line"."Direct Unit Cost")
                    {
                        trigger OnBeforePassField()
                        begin
                            GetVendor();
                            "Purchase Line"."Direct Unit Cost" := EDIFunctions.GetOrderOPItemPrice(_recVendor, "Purchase Line");
                        end;
                    }
                    fieldelement(TotalCostAmountExcl; "Purchase Line"."Line Amount")
                    {

                    }
                    textelement(TotalGSTValue)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            TotalGSTValue := Format("Purchase Line"."Amount Including VAT" - "Purchase Line"."Line Amount", 0, '<Standard Format,1>');
                        end;
                    }
                    fieldelement(GSTPercentage; "Purchase Line"."VAT %")
                    {

                    }
                    // 001 << 18.08.2025 MAY HP2 SP2 
                    fieldelement(UOM; "Purchase Line"."Unit of Measure Code")
                    {

                        trigger OnBeforePassField()
                        begin
                            GetVendor();
                            if _recVendor."GXL EDI Order in Out. Pack UoM" then
                                "Purchase Line"."Unit of Measure Code" := "Purchase Line"."GXL OP Unit of Measure Code";
                        end;
                    }
                    fieldelement(GrossWeight; "Purchase Line"."Gross Weight")
                    {

                        trigger OnBeforePassField()
                        begin
                            GetVendor();
                            "Purchase Line"."Direct Unit Cost" := EDIFunctions.GetOrderOPItemPrice(_recVendor, "Purchase Line");
                        end;
                    }
                    fieldelement(Cubage; "Purchase Line"."Unit Volume")
                    {
                    }

                    trigger OnPreXmlItem()
                    begin
                        if ExportWhich = ExportWhich::IPOX then
                            currXMLport.Skip();
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    FreightAgent: Record "GXL Freight Forwarder";
                begin
                    if "Purchase Header"."GXL Freight Forwarder Code" <> '' then
                        if FreightAgent.Get("Purchase Header"."GXL Freight Forwarder Code") then
                            CustomerID := FreightAgent."GXL Customer ID";
                end;
            }
        }
    }


    var
        _recSKU: Record "Stockkeeping Unit";
        _recLocation: Record Location;
        _recVendor: Record Vendor;
        EDIFunctions: Codeunit "GXL EDI Functions Library";
        ExportWhich: Option PO,POX,POR,ASN,INV,IPO,IPOX,SHIPSTATUS;
    //FreightAgent: Record "GXL Freight Forwarder";

    [Scope('OnPrem')]
    procedure GetSKU()
    begin
        _recSKU.Reset();
        _recSKU.SetRange(_recSKU."Location Code", "Purchase Line"."Location Code");
        _recSKU.SetRange(_recSKU."Item No.", "Purchase Line"."No.");
        if _recSKU.FindFirst() then;
    end;

    [Scope('OnPrem')]
    procedure GetVendor()
    begin
        if _recVendor.Get("Purchase Header"."Buy-from Vendor No.") then;
    end;

    [Scope('OnPrem')]
    procedure SetFilters()
    begin
    end;

    [Scope('OnPrem')]
    procedure SetEDIOptions(ExportWhichNew: Option PO,POX,POR,ASN,INV,IPO,IPOX,SHIPSTATUS)
    begin
        ExportWhich := ExportWhichNew;
    end;
}

