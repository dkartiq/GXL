xmlport 50273 "GXL WH-Daily-SOH"
{
    ///<Summary>
    //Update Total SOH, Available SOH and Stock Held quantity in SKU
    //WMSVD-001 - Prevent insert data to the integer table.
    ///</Summary>

    Caption = 'WH Daily SOH';
    Direction = Import;
    Format = VariableText;
    TextEncoding = MSDOS;

    schema
    {
        textelement(DailyStock)
        {
            tableelement(DailyStockOH; Integer)
            {
                textelement(Linenumber) { }
                textelement(ILC) { }
                textelement(TotalSOH) { }
                textelement(AvailableSOH) { }
                textelement(StockHeld) { }
                textelement(LocationCode) { }
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
        IF _recTempSKU.FindFirst() THEN BEGIN
            gStoreCode := _recTempSKU."Location Code";
            InitialiseSKUStock();
            UpdateSKU();
        END;
    end;

    procedure SetXmlFilter(StoreCode: Code[10])
    begin
        gStoreCode := StoreCode;
    end;

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
        CLEAR(dec1);
        CLEAR(dec2);
        CLEAR(dec3);

        LegacyItemHelper.GetItemNo(ILC, ItemNo, UOMCode);
        IF _recItemRec.GET(ItemNo) THEN BEGIN
            EVALUATE(dec1, TotalSOH);
            EVALUATE(dec2, AvailableSOH);
            EVALUATE(dec3, StockHeld);

            ItemUOM.SetRange("Item No.", ItemNo);
            ItemUOM.SetRange(Code, UOMCode);
            ItemUOM.FindFirst();

            _recTempSKU."Location Code" := LocationCode;
            _recTempSKU."Item No." := ItemNo;
            // IF NOT _recItemRec.Find() then begin //Commented OLD by WMSVD-003
            //     _recItemRec.Init();
            //     _recItemRec.Insert();
            // end;
            //WMSVD-003>> Issue correcting--------------------------------
            IF NOT _recTempSKU.Find() then begin
                _recTempSKU.Init();
                _recTempSKU.Insert();
            end;
            //<<WMSVD-003- Issue correcting--------------------------------
            _recTempSKU."GXL Total SOH" += dec1 * ItemUOM."Qty. per Unit of Measure";
            _recTempSKU."GXL Availabile SOH" += dec2 * ItemUOM."Qty. per Unit of Measure";
            _recTempSKU."GXL Stock Held" += dec3 * ItemUOM."Qty. per Unit of Measure";
            _recTempSKU.Modify();
        END;
    end;

    procedure UpdateSKU()
    begin
        _recSKU.RESET();
        IF _recTempSKU.FINDSET() THEN
            REPEAT
                _recSKU.SETRANGE("Location Code", _recTempSKU."Location Code");
                _recSKU.SETRANGE("Item No.", _recTempSKU."Item No.");
                IF _recSKU.FINDFIRST() THEN BEGIN
                    _recSKU.VALIDATE("GXL Total SOH", _recTempSKU."GXL Total SOH");
                    _recSKU."GXL Availabile SOH" := _recTempSKU."GXL Availabile SOH";
                    _recSKU."GXL Stock Held" := _recTempSKU."GXL Stock Held";
                    _recSKU.MODIFY(TRUE);
                END;
            UNTIL _recTempSKU.NEXT() = 0;
    end;

    LOCAL procedure InitialiseSKUStock()
    begin
        _recSKU.RESET();
        _recSKU.SETRANGE("Location Code", gStoreCode);
        IF _recSKU.FINDSET(TRUE) THEN
            REPEAT
                IF (_recSKU."GXL Total SOH" <> 0) OR
                   (_recSKU."GXL Availabile SOH" <> 0) OR
                   (_recSKU."GXL Stock Held" <> 0)
                THEN BEGIN
                    _recSKU.VALIDATE("GXL Total SOH", 0);
                    _recSKU."GXL Availabile SOH" := 0;
                    _recSKU."GXL Stock Held" := 0;
                    _recSKU.MODIFY(TRUE);
                END;
            UNTIL _recSKU.NEXT() = 0;
    end;

    var
        _recSKU: Record "Stockkeeping Unit";
        _recTempSKU: Record "Stockkeeping Unit" temporary;
        LegacyItemHelper: Codeunit "GXL Legacy Item Helpers";
        gStoreCode: Code[10];

}