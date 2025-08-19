xmlport 50252 "GXL PDA-Item Check"
{
    /*Change Log
        PS-2683 2021-10-15 LP: Add integration events
    */

    Caption = 'PDA-Item Check';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/ItemCheck';
    Encoding = UTF16;

    schema
    {
        textelement(ItemCheck)
        {
            MinOccurs = Once;
            MaxOccurs = Once;
            tableelement(NAVItemSku; "Stockkeeping Unit")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(ItemNumber; NAVItemSku."Item No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                textelement(UOM)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        GetItem(NAVItemSku."Item No.");
                        UOM := Item."Base Unit of Measure";
                    end;
                }
                fieldelement(OP; NAVItemSku."GXL Order Pack (OP)")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(MPL; NAVItemSku."GXL Minimum Presentation Level")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(Facings; NAVItemSku."GXL Facing")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ShelfCap; NAVItemSku."GXL Shelf Capacity")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                textelement(SOO)
                {
                    //stock on order
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        SOO := Format(PDAItemIntegration.FindStockOnOrderQty(NAVItemSku), 0, 9);
                    end;
                }
                textelement(LastDelivDate)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                    end;
                }
                fieldelement(OOSReason; NAVItemSku."GXL OOS Reason Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                textelement(DelivQty)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                    end;
                }
                textelement(DelivDate)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        FindNextDeliveryDate(NAVItemSku);
                    end;
                }
                textelement(LastOrderDate)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        FindLastOrderDate(NAVItemSku);
                    end;
                }
                textelement(NextOrdDate)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        FindNextOrderDate(NAVItemSku);
                    end;
                }
                fieldelement(PackSize; NAVItemSku."GXL Order Pack (OP)")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                textelement(Ranged)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        //TODO: Product ranging
                        if PDAItemIntegration.IsProductRanged(NAVItemSku) then
                            Ranged := 'TRUE'
                        else
                            Ranged := 'FALSE';
                    end;
                }
                textelement(VendorNumber)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                    end;
                }
                textelement(VendorName)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                    end;
                }
                textelement(ProductStatus)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        ProductStatus := Format(NAVItemSku."GXL Product Status");
                    end;
                }
                textelement(Description)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        Description := Item.Description;
                    end;
                }

                textelement(Alias)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        FindItemBarcode(NAVItemSku);
                    end;
                }
                textelement(Quantity)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        NAVItemSku.CalcFields(Inventory);

                        //PS-2683 +
                        OnBeforePassQuantity(NAVItemSku);
                        //PS-2683 -

                        Quantity := Format(NAVItemSku.Inventory);
                    end;
                }

                textelement(QtyCommitted)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        //PS-1772+
                        //Excluded Qty not posted from POS
                        //QtyCommitted := Format(PDAItemIntegration.GetCommittedQty(NAVItemSku), 0, 9);
                        QtyCommitted := Format(PDAItemIntegration.GetCommittedQtyItemCheck(NAVItemSku), 0, 9);
                        //PS-1772-
                    end;
                }
                textelement(MPQ)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                    end;
                }
                textelement(Price)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        Price := Format(GetPrice(NAVItemSku), 0, 9);
                    end;
                }
                textelement(DivisionDesc)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                textelement(ItemCategoryDesc)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                textelement(DistributorNumber)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                    end;
                }
                textelement(DistributorName)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                    end;
                }

                textelement(CostPrice)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        CostPrice := Format(GetCostPrice(NAVItemSku), 0, 9);
                    end;
                }
                //PS-2218+
                tableelement(ItemUOMList; "Item Unit of Measure")
                {
                    LinkTable = NAVItemSku;
                    LinkFields = "Item No." = field("Item No.");
                    MinOccurs = Zero;
                    SourceTableView = sorting("Item No.", Code);

                    fieldelement(Code; ItemUOMList.Code)
                    { }
                    fieldelement(LegacyItemNo; ItemUOMList."GXL Legacy Item No.")
                    { }
                }
                //PS-2218-
                trigger OnAfterGetRecord()
                begin
                    GetItem(NAVItemSku."Item No.");
                    GetDivision(NAVItemSku);
                    GetItemCategory(NAVItemSku);
                    FindLastPostedOrder(NAVItemSku);
                    VendorNumber := GetVendorFromItem(NAVItemSku);
                    VendorName := GetVendorName(VendorNumber);
                    DistributorNumber := GetDistributorFromItem(NAVItemSku);
                    DistributorName := GetVendorName(DistributorNumber);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    var
        Item: Record Item;
        Division: Record "LSC Division";
        ItemCategory: Record "Item Category";
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
        ItemNo: Code[20];

    procedure SetXMLFilters(NewStoreNo: Code[10]; NewItemCode: Code[20])
    begin
        ItemNo := NewItemCode;

        NAVItemSku.Reset();
        NAVItemSku.SetRange("Location Code", NewStoreNo);
        NAVItemSku.SetRange("Item No.", ItemNo);
        GetItem(ItemNo);
    end;

    local procedure FindNextDeliveryDate(var SKU: Record "Stockkeeping Unit")
    var
        RcptDate: Date;
    begin
        DelivDate := '';
        RcptDate := PDAItemIntegration.FindNextDeliveryDate(SKU);
        if RcptDate <> 0D then
            DelivDate := Format(RcptDate, 0, 9);
    end;

    local procedure FindLastPostedOrder(var SKU: Record "Stockkeeping Unit")
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        LastDate: Date;
        ILEQty: Decimal;
    begin
        if PDAItemIntegration.FindLastReceipLedgerEntry(NAVItemSku, ItemLedgEntry) then begin
            LastDate := ItemLedgEntry."Posting Date";
            ItemLedgEntry.SetRange("Posting Date", ItemLedgEntry."Posting Date");
            if ItemLedgEntry.FindSet() then
                repeat
                    ILEQty += ItemLedgEntry.Quantity;
                until ItemLedgEntry.Next() = 0;
        end;

        LastDelivDate := '';
        if LastDate <> 0D then
            LastDelivDate := Format(LastDate, 0, 9);
        DelivQty := Format(ILEQty, 0, 9);
    end;

    local procedure FindLastOrderDate(var SKU: Record "Stockkeeping Unit")
    var
        LastDate: Date;
    begin
        LastOrderDate := '';
        LastDate := PDAItemIntegration.FindLastOrderDate(SKU, Today());
        if LastDate <> 0D then
            LastOrderDate := Format(LastDate, 0, 9);

    end;

    local procedure FindNextOrderDate(var SKU: Record "Stockkeeping Unit")
    var
        NextDate: Date;
    begin
        NextOrdDate := '';
        NextDate := PDAItemIntegration.FindNextOrderDate(SKU, Today());
        if NextDate <> 0D then
            NextOrdDate := Format(NextDate, 0, 9);
    end;

    local procedure GetDistributorFromItem(SKU: Record "Stockkeeping Unit") VendorNo: Code[20]
    begin
        VendorNo := '';
        //PS-2399+
        //Returned back to use Distributor to be consistent with ItemCheckSimple and NAV13 ItemCheck        
        if SKU."GXL Distributor Number" <> '' then
            VendorNo := SKU."GXL Distributor Number"
        else begin
            GetItem(SKU."Item No.");
            //Item.TestField("GXL Distributor Number");
            VendorNo := Item."GXL Distributor Number";
        end;
        /*
        if SKU."GXL Supplier Number" <> '' then
            VendorNo := SKU."GXL Supplier Number"
        else begin
            GetItem(SKU."Item No.");
            VendorNo := Item."GXL Supplier Number";
        end;
        */
        //PS-2399-
    end;

    local procedure GetVendorFromItem(SKU: Record "Stockkeeping Unit") VendorNo: Code[20]
    begin
        VendorNo := '';
        //PS-2258+
        //if SKU."Vendor No." = '' then
        if SKU."Vendor No." <> '' then
            //PS-2258-
            VendorNo := SKU."Vendor No."
        else begin
            GetItem(SKU."Item No.");
            VendorNo := Item."Vendor No.";
        end;
    end;

    local procedure GetVendorName(VendNo: Code[20]): Text;
    var
        Vend: Record Vendor;
    begin
        if VendNo = '' then
            exit('')
        else begin
            if Vend.Get(VendNo) then
                exit(Vend.Name)
            else
                exit('');
        end;
    end;


    local procedure GetItem(ItemCode: Code[20])
    begin
        if Item."No." <> ItemCode then
            Item.Get(ItemCode);
    end;

    local procedure FindItemBarcode(SKU: Record "Stockkeeping Unit")
    begin
        GetItem(SKU."Item No.");
        Alias := PDAItemIntegration.FindItemBarcode(SKU."Item No.", item."Base Unit of Measure");
    end;

    local procedure GetPrice(SKU: Record "Stockkeeping Unit"): Decimal
    begin
        GetItem(SKU."Item No.");
        exit(PDAItemIntegration.GetRetailPrice(Item, SKU."Location Code"));
    end;

    local procedure GetDivision(SKU: Record "Stockkeeping Unit")
    begin
        GetItem(SKU."Item No.");
        if Item."LSC Division Code" <> '' then begin
            if Item."LSC Division Code" <> Division.Code then
                if Division.Get(Item."LSC Division Code") then;
        end else
            Clear(Division);
        DivisionDesc := Division.Description;
    end;

    local procedure GetItemCategory(SKU: Record "Stockkeeping Unit")
    begin
        GetItem(SKU."Item No.");
        if Item."Item Category Code" <> '' then begin
            if Item."Item Category Code" <> ItemCategory.Code then
                if ItemCategory.Get(Item."Item Category Code") then;
        end else
            Clear(ItemCategory);
        ItemCategoryDesc := ItemCategory.Description;
    end;

    local procedure GetCostPrice(SKU: Record "Stockkeeping Unit"): Decimal
    begin
        GetItem(SKU."Item No.");
        exit(PDAItemIntegration.GetItemGXLCostPrice(Item));
    end;

    //PS-2683 +
    [IntegrationEvent(false, false)]
    local procedure OnBeforePassQuantity(var StockkeepingUnit: Record "Stockkeeping Unit")
    begin
    end;
    //PS-2683 -
}