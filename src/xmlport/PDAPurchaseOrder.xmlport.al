xmlport 50262 "GXL PDA-Purchase Order"
{
    Caption = 'PDA-Purchase Order';
    UseRequestPage = false;
    Direction = Both;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/PurchaseOrder';
    Encoding = UTF16;

    schema
    {
        textelement(PDAPurchaseOrder)
        {
            tableelement(PurchaseOrderHeader; "Purchase Header")
            {
                UseTemporary = true;
                SourceTableView = sorting("GXL Created Date") order(descending) where("Document Type" = const(Order));
                MinOccurs = Zero;
                MaxOccurs = Unbounded;

                fieldelement(PONumber; PurchaseOrderHeader."No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(VendorNo; PurchaseOrderHeader."Buy-from Vendor No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(VendorName; PurchaseOrderHeader."Buy-from Vendor Name")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(OrderDate; PurchaseOrderHeader."Order Date")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassField()
                    begin
                        if PurchaseOrderHeader."Order Date" = 0D then
                            PurchaseOrderHeader."Order Date" := WorkDate();
                    end;
                }
                fieldelement(ExpectedRecDate; PurchaseOrderHeader."Expected Receipt Date")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassField()
                    begin
                        if PurchaseOrderHeader."Expected Receipt Date" = 0D then
                            PurchaseOrderHeader."Expected Receipt Date" := WorkDate();
                    end;
                }
                fieldelement(TotalOrderValue; PurchaseOrderHeader."GXL Staging Order Value")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(TotalQty; PurchaseOrderHeader."GXL Staging Order Quantity")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(AuditFlag; PurchaseOrderHeader."GXL Audit Flag")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                textelement(OrderStatus)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        OrderStatus := Format(PurchaseOrderHeader."GXL Order Status");
                    end;
                }
                tableelement(PurchaseOrderLine; "Purchase Line")
                {
                    UseTemporary = true;
                    LinkTable = PurchaseOrderHeader;
                    LinkFields = "Document Type" = field("Document Type"), "Document No." = field("No.");
                    MinOccurs = Zero;
                    MaxOccurs = Unbounded;

                    fieldelement(PONumberLine; PurchaseOrderLine."Document No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(LineNo; PurchaseOrderLine."Line No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(ItemNo; PurchaseOrderLine."No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(UOM; PurchaseOrderLine."Unit of Measure Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(Description; PurchaseOrderLine.Description)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(OrderQuantity; PurchaseOrderLine.Quantity)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(QtyToReceive; PurchaseOrderLine."Qty. to Receive")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(UnitCost; PurchaseOrderLine."Direct Unit Cost")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(SellPrice; PurchaseOrderLine."Unit Price (LCY)")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    textelement(PackSize)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;

                        trigger OnBeforePassVariable()
                        begin
                            if Item.Get(PurchaseOrderLine."No.") then
                                PackSize := Format(Item."GXL Order Pack (OP)")
                            else
                                Clear(PackSize);
                        end;
                    }
                    fieldelement(TotalLineValue; PurchaseOrderLine."Amount Including VAT")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(LegacyItemNo; PurchaseOrderLine."GXL Legacy Item No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    textelement(Barcode)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            Barcode := PDAItemIntegration.FindItemBarcode(PurchaseOrderLine."No.", PurchaseOrderLine."Unit of Measure Code");
                        end;
                    }
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    var
        PurchHead: Record "Purchase Header";
        TransHead: Record "Transfer Header";
        Item: Record Item;
        StagingPurchHead: Record "GXL PDA-Staging Purch. Header";
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";

    procedure ShowBatchPO(StoreCode: Code[10]; BatchId: Integer)
    begin
        StagingPurchHead.SetRange("Location Code", StoreCode);
        StagingPurchHead.SetRange("PDA Batch Id", BatchId);

        PopulateRec(true);
    end;

    procedure ShowDocument(DocumentNumber: Code[20])
    begin
        StagingPurchHead.SetRange("No.", DocumentNumber);

        PurchHead.SetRange("Document Type", PurchHead."Document Type"::Order);
        PurchHead.SetRange("No.", DocumentNumber);

        TransHead.SetRange("No.", DocumentNumber);

        PopulateRec(false);

        PurchaseOrderHeader.SetRange("No.", DocumentNumber);
    end;

    procedure ShowNewPOs(StoreCode: Code[10])
    var

    begin
        StagingPurchHead.SetRange("Location Code", StoreCode);
        StagingPurchHead.SetRange("Order Status", StagingPurchHead."Order Status"::Approved);

        PurchHead.SetRange("Document Type", PurchHead."Document Type"::Order);
        PurchHead.SetRange("Location Code", StoreCode);
        PurchHead.SetRange("GXL Order Status", PurchHead."GXL Order Status"::New, PurchHead."GXL Order Status"::Placed);

        TransHead.SetRange("Transfer-to Code", StoreCode);
        TransHead.SetRange("GXL Order Status", TransHead."GXL Order Status"::New, TransHead."GXL Order Status"::Created);
        TransHead.SetRange("GXL Source of Supply", TransHead."GXL Source of Supply"::WH);

        PopulateRec(false);

        PurchaseOrderHeader.SetRange("Location Code", StoreCode);
        PurchaseOrderHeader.SetRange("GXL Order Status", PurchaseOrderHeader."GXL Order Status"::New, PurchaseOrderHeader."GXL Order Status"::Placed);
    end;

    local procedure PopulateRec(StagingOnly: Boolean)
    var
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        StagingPurchLine: Record "GXL PDA-Staging Purch. Line";
    begin
        if not StagingPurchHead.IsEmpty() then begin
            StagingPurchHead.SetAutoCalcFields("Total Order Qty", "Total Order Value");
            if StagingPurchHead.FindSet() then
                repeat
                    StagingPurchLine.SetRange("Document No.", StagingPurchHead."No.");
                    if StagingPurchLine.FindSet() then begin
                        PurchaseOrderHeader.Init();
                        PurchaseOrderHeader.TransferFields(StagingPurchHead);
                        PurchaseOrderHeader."Document Type" := PurchaseOrderHeader."Document Type"::Order;
                        PurchaseOrderHeader."GXL Order Status" := PurchaseOrderHeader."GXL Order Status"::Created;
                        PurchaseOrderHeader."GXL Staging Order Quantity" := StagingPurchHead."Total Order Qty";
                        PurchaseOrderHeader."GXL Staging Order Value" := StagingPurchHead."Total Order Value";
                        PurchaseOrderHeader.Insert();

                        repeat
                            PurchaseOrderLine.Init();
                            PurchaseOrderLine.TransferFields(StagingPurchLine);
                            PurchaseOrderLine."Document Type" := PurchaseOrderHeader."Document Type";
                            CalcPrice();
                            PurchaseOrderLine.Insert();
                        until StagingPurchLine.Next() = 0;
                    end;
                until StagingPurchHead.Next() = 0;
        end;

        if not StagingOnly then begin
            if not PurchHead.IsEmpty() then begin
                PurchHead.SetAutoCalcFields("GXL Total Order Qty", "GXL Total Order Value");
                if PurchHead.FindSet() then
                    repeat
                        PurchLine.SetRange("Document Type", PurchHead."Document Type");
                        PurchLine.SetRange("Document No.", PurchHead."No.");
                        if PurchLine.FindSet() then begin
                            PurchaseOrderHeader.Init();
                            PurchaseOrderHeader.TransferFields(PurchHead);
                            PurchaseOrderHeader."GXL Staging Order Quantity" := PurchHead."GXL Total Order Qty";
                            PurchaseOrderHeader."GXL Staging Order Value" := PurchHead."GXL Total Order Value";
                            PurchaseOrderHeader.Insert();

                            repeat
                                PurchaseOrderLine.Init();
                                PurchaseOrderLine.TransferFields(PurchLine);
                                CalcPrice();
                                PurchaseOrderLine.Insert();
                            until PurchLine.Next() = 0;
                        end;

                    until PurchHead.Next() = 0;
            end;

            if not TransHead.IsEmpty() then begin
                TransHead.SetAutoCalcFields("GXL Total Order Quantity");
                if TransHead.FindSet() then
                    repeat
                        TransLine.SetRange("Document No.", TransHead."No.");
                        TransLine.SetRange("Derived From Line No.", 0);
                        if TransLine.FindSet() then begin
                            PurchaseOrderHeader.Init();
                            PurchaseOrderHeader."Document Type" := PurchaseOrderHeader."Document Type"::Order;
                            PurchaseOrderHeader."No." := TransHead."No.";
                            PurchaseOrderHeader."Buy-from Vendor No." := TransHead."Transfer-from Code";
                            PurchaseOrderHeader."Buy-from Vendor Name" := TransHead."Transfer-from Name";
                            PurchaseOrderHeader."Order Date" := TransHead."Shipment Date";
                            PurchaseOrderHeader."GXL Order Status" := TransHead."GXL Order Status";
                            PurchaseOrderHeader."Location Code" := TransHead."Transfer-to Code";
                            PurchaseOrderHeader."Expected Receipt Date" := TransHead."Receipt Date";
                            PurchaseOrderHeader."Posting Date" := TransHead."Posting Date";
                            PurchaseOrderHeader."GXL Created Date" := TransHead."GXL Created Date";
                            PurchaseOrderHeader."GXL Created Time" := TransHead."GXL Created Time";
                            PurchaseOrderHeader."GXL Created By User ID" := TransHead."GXL Created By User ID";
                            PurchaseOrderHeader."GXL Staging Order Quantity" := TransHead."GXL Total Order Quantity";
                            PurchaseOrderHeader.Insert();

                            repeat
                                PurchaseOrderLine.Init();
                                PurchaseOrderLine."Document Type" := PurchaseOrderHeader."Document Type";
                                PurchaseOrderLine."Document No." := TransLine."Document No.";
                                PurchaseOrderLine."Line No." := TransLine."Line No.";
                                PurchaseOrderLine.Type := PurchaseOrderLine.Type::Item;
                                PurchaseOrderLine."No." := TransLine."Item No.";
                                PurchaseOrderLine.Description := TransLine.Description;
                                PurchaseOrderLine."Location Code" := TransLine."Transfer-to Code";
                                PurchaseOrderLine."Unit of Measure Code" := TransLine."Unit of Measure Code";
                                PurchaseOrderLine.Quantity := TransLine.Quantity;
                                PurchaseOrderLine."Qty. to Receive" := TransLine."Qty. to Receive";
                                PurchaseOrderLine."Direct Unit Cost" := TransLine."GXL Unit Cost";
                                PurchaseOrderLine."Amount Including VAT" := TransLine."GXL Total Cost";
                                PurchaseOrderLine."GXL Legacy Item No." := TransLine."GXL Legacy Item No.";
                                PurchaseOrderLine.Insert();
                            until TransLine.Next() = 0;
                        end;

                    until TransHead.Next() = 0;
            end;
        end;

        PurchaseOrderHeader.Reset();
        PurchaseOrderHeader.SetCurrentKey("GXL Created Date");
        PurchaseOrderHeader.SetRange("Document Type", PurchaseOrderHeader."Document Type"::Order);
        PurchaseOrderHeader.Ascending(false);

    end;

    local procedure GetItem()
    begin
        if PurchaseOrderLine.Type = PurchaseOrderLine.Type::Item then
            if Item."No." <> PurchaseOrderLine."No." then
                Item.Get(PurchaseOrderLine."No.");
    end;

    local procedure CalcCost(LocCode: Code[10]; ItemNo: Code[20])
    var
        SKU: Record "Stockkeeping Unit";
    begin
        SKU.SetRange("Location Code", LocCode);
        SKU.SetRange("Item No.", ItemNo);
        if SKU.FindFirst() then begin
            GetItem();
            PurchaseOrderLine."Unit Cost (LCY)" := PDAItemIntegration.GetSKUCostPrice(Item, SKU);
        end;
    end;

    local procedure CalcPrice()
    begin
        if PurchaseOrderLine.Type = PurchaseOrderLine.Type::Item then begin
            GetItem();
            PurchaseOrderLine."Unit Price (LCY)" := PDAItemIntegration.GetRetailPrice(Item, PurchaseOrderLine."Location Code");
        end;
    end;
}