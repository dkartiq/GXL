xmlport 50284 "GXL PDA StockTake Update"
{
    Caption = 'PDA StockTake Update';
    Direction = Import;
    FormatEvaluate = Xml;
    Format = Xml;
    UseRequestPage = false;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/StocktakeUpdate';
    Encoding = UTF16;

    schema
    {
        textelement(StockTakeList)
        {
            MaxOccurs = Once;
            tableelement(StockTake1; "GXL PDA StockTake Line")
            {
                AutoUpdate = true;
                UseTemporary = true;
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(StockTakeID; StockTake1."Stock-Take ID")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(lineNo; StockTake1."Line No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(StoreCode; StockTake1."Store Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ItemNo; StockTake1."Item No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ItemDescription; StockTake1."Item Description")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(UOM; StockTake1.UOM)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(Quantity; StockTake1."Physical Quantity")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ResonCode; StockTake1."Reson Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(Barcode; StockTake1.Barcode)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(VendorNo; StockTake1."Vendor No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(VendorName; StockTake1."Vendor Name")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(Overwrite; StockTake1.Overwrite)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }

                trigger OnAfterInsertRecord()
                var
                    StockTakeLinesL: Record "GXL PDA StockTake Line";
                begin
                    IF StockTakeLinesL.Get(StockTake1."Stock-Take ID", StockTake1."Line No.") then begin
                        if StockTake1.Overwrite then
                            StockTakeLinesL."Physical Quantity" := StockTake1."Physical Quantity"
                        else
                            StockTakeLinesL."Physical Quantity" += StockTake1."Physical Quantity";
                        //PS-2046+
                        StockTakeLinesL."MIM User ID" := UserId();
                        //PS-2046-
                        StockTakeLinesL.Modify();
                    end else begin
                        StockTakeLinesL := StockTake1;
                        //PS-2046+
                        StockTakeLinesL."MIM User ID" := UserId();
                        //PS-2046-
                        StockTakeLinesL.Insert();
                    end;
                end;

                trigger OnBeforeInsertRecord()
                var
                    StockTakeLinesL: Record "GXL PDA StockTake Line";
                begin
                    IF StockTake1."Line No." = 0 then begin
                        StockTakeLinesL.Reset();
                        StockTakeLinesL.SetRange("Stock-Take ID", StockTake1."Stock-Take ID");
                        StockTakeLinesL.SetRange("Item No.", StockTake1."Item No.");
                        StockTakeLinesL.SetRange(UOM, StockTake1.UOM);
                        if StockTakeLinesL.FindFirst() then begin
                            StockTake1."Line No." := StockTakeLinesL."Line No.";
                            exit;
                        end;
                        StockTakeLinesL.Reset();
                        StockTakeLinesL.SetRange("Stock-Take ID", StockTake1."Stock-Take ID");
                        IF StockTakeLinesL.FindLast() then
                            StockTake1."Line No." := StockTakeLinesL."Line No." + 10000;
                    end;
                end;
            }

        }

    }
}