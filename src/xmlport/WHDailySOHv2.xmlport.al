xmlport 50097 "GXL WH-Daily-SOH v2"
{
    ///<Summary>
    //Update Total SOH, Available SOH and Stock Held quantity in SKU
    //WMSVD-001 - Prevent insert data to the integer table.
    ///</Summary>

    Direction = Both;
    Format = VariableText;
    FormatEvaluate = Legacy;
    UseRequestPage = true;

    schema
    {
        textelement(DailyStock)
        {
            tableelement(Integer; Integer)
            {
                AutoSave = false;
                XmlName = 'DailyStockOH';
                textelement(Linenumber)
                {
                }
                textelement(ILC)
                {
                }
                textelement(TotalSOH)
                {
                }
                textelement(AvailableSOH)
                {
                }
                textelement(StockHeld)
                {
                }
                textelement(LocationCode)
                {
                }

                trigger OnBeforeInsertRecord()
                begin
                    BufferSOH();
                    currXMLport.Skip(); //WMSVD-001 - Prevent insert data to the integer table.
                end;
            }
        }
    }


    trigger OnPostXmlPort()
    begin
        if _recTempSKU.FindFirst() then begin
            gStoreCode := _recTempSKU."Location Code";
            InitialiseSKUStock();
            UpdateSKU();
        end;
    end;

    var
        _recSKU: Record "Stockkeeping Unit";
        _recTempSKU: Record "Stockkeeping Unit" temporary;
        LegacyItemHelper: Codeunit "GXL Legacy Item Helpers";
        gStoreCode: Code[10];

    [Scope('OnPrem')]
    procedure SetXmlFilter(StoreCode: Code[10])
    begin
        gStoreCode := StoreCode;
    end;

    [Scope('OnPrem')]
    procedure BufferSOH()
    var
        _recItemRec: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        dec1: Decimal;
        dec2: Decimal;
        dec3: Decimal;
        ItemNo: Code[20];
        UOMCode: Code[10];
    begin
        // buffer SOH data to temp table

        Clear(dec1);
        Clear(dec2);
        Clear(dec3);
        LegacyItemHelper.GetItemNo(ILC, ItemNo, UOMCode);
        if _recItemRec.Get(ItemNo) then begin
            Evaluate(dec1, TotalSOH);
            Evaluate(dec2, AvailableSOH);
            Evaluate(dec3, StockHeld);

            ItemUOM.SetRange("Item No.", ItemNo);
            ItemUOM.SetRange(Code, UOMCode);
            ItemUOM.FindFirst();

            _recTempSKU."Location Code" := LocationCode;
            //_recTempSKU."Item No." := ILC;
            _recTempSKU."Item No." := ItemNo;
            IF NOT _recTempSKU.Find() then begin
                _recTempSKU.Init();
                _recTempSKU.Insert();
            end;
            _recTempSKU."GXL Total SOH" += dec1 * ItemUOM."Qty. per Unit of Measure";
            _recTempSKU."GXL Availabile SOH" += dec2 * ItemUOM."Qty. per Unit of Measure";
            _recTempSKU."GXL Stock Held" += dec3 * ItemUOM."Qty. per Unit of Measure";
            _recTempSKU.Modify();
        end;
    end;

    [Scope('OnPrem')]
    procedure UpdateSKU()
    var
    begin
        _recSKU.Reset();
        if _recTempSKU.FindSet() then
            repeat
                _recSKU.SetRange("Location Code", _recTempSKU."Location Code");
                _recSKU.SetRange("Item No.", _recTempSKU."Item No.");
                if _recSKU.FindFirst() then begin
                    _recSKU.Validate("GXL Total SOH", _recTempSKU."GXL Total SOH");
                    _recSKU."GXL Availabile SOH" := _recTempSKU."GXL Availabile SOH";
                    _recSKU."GXL Stock Held" := _recTempSKU."GXL Stock Held";
                    _recSKU.Modify(true);
                end;
            until _recTempSKU.Next() = 0;
    end;

    local procedure InitialiseSKUStock()
    begin
        _recSKU.Reset();
        _recSKU.SetRange("Location Code", gStoreCode);
        if _recSKU.FindSet(true) then
            repeat
                if (_recSKU."GXL Total SOH" <> 0) or
                   (_recSKU."GXL Availabile SOH" <> 0) or
                   (_recSKU."GXL Stock Held" <> 0)
                then begin
                    _recSKU.Validate("GXL Total SOH", 0);
                    _recSKU."GXL Availabile SOH" := 0;
                    _recSKU."GXL Stock Held" := 0;
                    _recSKU.Modify(true);
                end;
            until _recSKU.Next() = 0;
    end;
}

