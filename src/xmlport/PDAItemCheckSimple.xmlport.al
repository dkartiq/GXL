xmlport 50261 "GXL PDA-Item Check Simple"
{
    /*Change Log
        PS-2683 2021-10-15 LP: Add integration events
    */

    Caption = 'PDA-Item Check Simple';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/ItemCheckSimple';
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
                        UOM := UOMCode;
                    end;
                }
                fieldelement(PackSize; NAVItemSku."GXL Order Pack (OP)")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
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
                textelement(Description)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        Description := Item.Description;
                    end;
                }

                textelement(Barcode)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        FindItemBarcode(NAVItemSku);
                    end;
                }
                textelement(SOH)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    var
                        QtyOH: Decimal;
                    begin
                        NAVItemSku.CalcFields(Inventory);
                        QtyOH := LegacyItemHelpers.CalculateLegacyItemQty(ItemUOM, NAVItemSku.Inventory);

                        //PS-2683 +
                        OnBeforePassQuantity(NAVItemSku, QtyOH);
                        //PS-2683 -

                        SOH := Format(QtyOH, 0, 9);
                    end;
                }
                textelement(SOO)
                {
                    //stock on order
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    var
                        SOOQty: Decimal;
                    begin
                        SOOQty := PDAItemIntegration.FindStockOnOrderQty(NAVItemSku);
                        SOOQty := LegacyItemHelpers.CalculateLegacyItemQty(ItemUOM, SOOQty);
                        SOO := Format(SOOQty, 0, 9);
                    end;
                }
                textelement(Last12WeeksSales)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        FindLastSalesQty(NAVItemSku);
                    end;
                }
                textelement(ILC)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        ILC := LegacyItemNo;
                    end;
                }
                //PS-2258+
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
                //PS-2258-


                trigger OnAfterGetRecord()
                begin
                    GetItem(NAVItemSku."Item No.");
                    LegacyItemHelpers.GetLegacyItemNo(ItemUOM, LegacyItemNo);
                    VendorNumber := GetVendorFromItem(NAVItemSku);
                    VendorName := GetVendorName(VendorNumber);
                    //PS-2258+
                    DistributorNumber := GetDistributorFromItem(NAVItemSku);
                    DistributorName := GetVendorName(DistributorNumber);
                    //PS-2258-
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        ItemNo: Code[20];
        UOMCode: Code[10];
        LegacyItemNo: Code[20];

    procedure SetXMLFilters(NewStoreNo: Code[10]; NewItemCode: Code[20]; NewUOM: Code[10])
    begin
        ItemNo := NewItemCode;
        UOMCode := NewUOM;

        NAVItemSku.Reset();
        NAVItemSku.SetRange("Location Code", NewStoreNo);
        NAVItemSku.SetRange("Item No.", ItemNo);
        GetItem(ItemNo);
    end;

    local procedure FindLastSalesQty(var SKU: Record "Stockkeeping Unit")
    var
        Period: DateFormula;
        Qty: Decimal;
    begin
        Evaluate(Period, '-12W');
        Qty := PDAItemIntegration.FindLastSalesQty(SKU, Period, WorkDate());
        Qty := LegacyItemHelpers.CalculateLegacyItemQty(ItemUOM, Qty);
        Last12WeeksSales := Format(Qty, 0, 9);
    end;

    local procedure GetVendorFromItem(SKU: Record "Stockkeeping Unit") VendorNo: Code[20]
    begin
        VendorNo := '';
        if SKU."Vendor No." <> '' then
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
        if Item."No." <> ItemCode then begin
            Item.Get(ItemCode);
            if UOMCode = '' then
                UOMCode := Item."Base Unit of Measure";
            ItemUOM.Get(ItemCode, UOMCode);
        end;

    end;

    local procedure FindItemBarcode(SKU: Record "Stockkeeping Unit")
    begin
        GetItem(SKU."Item No.");
        Barcode := PDAItemIntegration.FindItemBarcode(SKU."Item No.", UOMCode);
    end;

    //PS-2258+
    local procedure GetDistributorFromItem(SKU: Record "Stockkeeping Unit") VendorNo: Code[20]
    begin
        VendorNo := '';
        if SKU."GXL Distributor Number" <> '' then
            VendorNo := sku."GXL Distributor Number"
        else begin
            GetItem(SKU."Item No.");
            VendorNo := Item."GXL Distributor Number";
        end;
    end;
    //PS-2258-

    //PS-2683 +
    [IntegrationEvent(false, false)]
    local procedure OnBeforePassQuantity(var StockkeepingUnit: Record "Stockkeeping Unit"; var QtyOH: Decimal)
    begin
    end;
    //PS-2683 -

}