xmlport 50000 "GXL Export IllegalProdRangeLog"
{
    Caption = 'Export Illegal Product Ranging Log';
    Direction = Export;
    Format = VariableText;
    FormatEvaluate = Legacy;
    TextEncoding = UTF8;

    schema
    {
        textelement(root)
        {
            tableelement(IllegalItemHeader; Integer)
            {
                SourceTableView = sorting(Number) where(Number = const(1));
                textelement(StoreTitle)
                {
                    trigger OnBeforePassVariable()
                    begin
                        StoreTitle := IllegalProdRangeLog.FieldCaption("Store Code");
                    end;
                }
                textelement(StoreNameTitle)
                {
                    trigger OnBeforePassVariable()
                    begin
                        StoreNameTitle := IllegalProdRangeLog.FieldCaption("Store Name");
                    end;
                }
                textelement(ItemTitle)
                {
                    trigger OnBeforePassVariable()
                    begin
                        ItemTitle := IllegalProdRangeLog.FieldCaption("Item No.");
                    end;
                }
                textelement(ItemNameTitle)
                {
                    trigger OnBeforePassVariable()
                    begin
                        ItemNameTitle := IllegalProdRangeLog.FieldCaption("Item Description");
                    end;
                }
            }
            tableelement(IllegalProdRangeLog; "GXL Illegal Product Range Log")
            {
                fieldelement(StoreCode; IllegalProdRangeLog."Store Code")
                { }
                fieldelement(StoreName; IllegalProdRangeLog."Store Name")
                { }
                fieldelement(ItemNo; IllegalProdRangeLog."Item No.")
                { }
                fieldelement(ItemDescription; IllegalProdRangeLog."Item Description")
                { }
            }
        }
    }

}