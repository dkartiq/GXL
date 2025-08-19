xmlport 50351 "GXL Vendor-FT Order"
{
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

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
                textelement(SupplierFax)
                {

                    trigger OnBeforePassVariable()
                    begin
                        GetVendor();
                        SupplierFax := _recVendor."Fax No.";
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
                textelement(Fax)
                {

                    trigger OnBeforePassVariable()
                    begin
                        if _recLocation.Get("Purchase Header"."Location Code") then begin
                            Fax := _recLocation."Fax No.";
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
                fieldelement(OrderDate; "Purchase Header"."Order Date")
                {
                }
                fieldelement(RequiredDate; "Purchase Header"."Expected Receipt Date")
                {
                }
                fieldelement(TotalOrderQty; "Purchase Header"."GXL Total Order Qty")
                {
                }
                fieldelement(TotalOrderAmount; "Purchase Header"."GXL Total Order Value")
                {
                }
                fieldelement(ReplContact; "Purchase Header"."GXL Created By User ID")
                {
                }
                // >> HP2-SPRINT2
                // fieldelement(OrderType; "Purchase Header"."GXL Source of Supply")
                textelement(OrderType)
                {
                    trigger OnBeforePassVariable()
                    begin
                        OrderType := Format("Purchase Header"."GXL Source of Supply");
                    end;
                }
                // << HP2-SPRINT2
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
                textelement(CancellationFlag)
                {

                    trigger OnBeforePassVariable()
                    begin
                        CancellationFlag := '';
                        if ExportWhich = ExportWhich::POX then
                            CancellationFlag := 'C';
                    end;
                }
                fieldelement(OrderInstruction; "Purchase Header"."GXL Transport Type")
                {
                }
                textelement(OrderTerms)
                {
                }
                fieldelement(TotalOrderAmountGSTExcl; "Purchase Header"."GXL Total Value")
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
                    // fieldelement(Items; "Purchase Line"."No.")
                    // {
                    // }
                    fieldelement(GTIN; "Purchase Line"."GXL Primary EAN")
                    {

                        trigger OnBeforePassField()
                        begin
                            GetVendor();
                            if _recVendor."GXL EDI Order in Out. Pack UoM" then
                                "Purchase Line"."GXL Primary EAN" := "Purchase Line"."GXL OP GTIN";
                        end;
                    }
                    fieldelement(SupplierNo; "Purchase Line"."GXL Vendor Reorder No.")
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
                            GetSKu();
                            GetVendor();
                            OMQTY := Format(EDIFunctions.GetSkuOMQty(_recVendor, _recSKU), 0, '<Standard Format,1>');

                        end;
                    }
                    textelement(OPQTY)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            GetSKu();
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
                        end;
                    }
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
                    textelement(TotalGSTVaue)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            TotalGSTVaue := Format("Purchase Line"."Amount Including VAT" - "Purchase Line"."Line Amount", 0, '<Standard Format,1>');
                        end;
                    }
                    fieldelement(GSTPercentage; "Purchase Line"."VAT %")
                    {
                    }
                    fieldelement(ItemDiscount; "Purchase Line"."Line Discount %")
                    {
                    }
                    fieldelement(UOM; "Purchase Line"."Unit of Measure Code")
                    {

                        trigger OnBeforePassField()
                        begin
                            GetVendor();
                            if _recVendor."GXL EDI Order in Out. Pack UoM" then
                                "Purchase Line"."Unit of Measure Code" := "Purchase Line"."GXL OP Unit of Measure Code";
                        end;
                    }
                }
            }
        }
    }


    var
        _recSKU: Record "Stockkeeping Unit";
        _recLocation: Record Location;
        _recVendor: Record Vendor;
        EDIFunctions: Codeunit "GXL EDI Functions Library";
        ExportWhich: Option PO,POX,POR,ASN,INV;

    [Scope('OnPrem')]
    procedure GetSKu()
    begin
        _recSKU.Reset();
        _recSKU.SetRange(_recSKU."Location Code", "Purchase Line"."Location Code");
        _recSKU.SetRange(_recSKU."Item No.", "Purchase Line"."No.");
        if _recSKU.FindFirst() then;
    end;

    [Scope('OnPrem')]
    procedure GetVendor()
    begin
        if _recVendor.Get("Purchase Header"."Buy-from Vendor No.") then begin
        end;
    end;

    [Scope('OnPrem')]
    procedure SetFilters()
    begin
    end;

    [Scope('OnPrem')]
    procedure SetEDIOptions(ExportWhichNew: Option PO,POX,POR,ASN,INV)
    begin
        ExportWhich := ExportWhichNew;
    end;
}

