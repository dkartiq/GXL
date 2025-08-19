xmlport 50256 "GXL PDA-Items"
{
    /*Change Log
        PS-2137 28-09-2020 LP
            Include element QtyPerUOM
    */

    Caption = 'PDA-Items';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/Items';
    Encoding = UTF16;

    schema
    {
        textelement(ItemUOMs)
        {
            tableelement(ItemUOM; "Item Unit of Measure")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;

                fieldelement(ItemNumber; ItemUOM."Item No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(UOM; ItemUOM.Code)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(LegacyItemNumber; ItemUOM."GXL Legacy Item No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                //PS-2137+
                fieldelement(QtyPerUOM; ItemUOM."Qty. per Unit of Measure")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                //PS-2137-
            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    var

    procedure SetXMLFilter(Input: Code[20]; UOMCode: Code[10])
    var
        Item: Record Item;
        Barcodes: Record "LSC Barcodes";
    begin
        ItemUOM.Reset();
        if UOMCode = '' then begin
            ItemUOM.SetCurrentKey("GXL Legacy Item No.");
            ItemUOM.SetRange("GXL Legacy Item No.", Input);
        end else begin
            ItemUOM.SetRange("Item No.", Input);
            ItemUOM.SetRange(Code, UOMCode);
        end;
        if not ItemUOM.FindFirst() then begin
            if Item.Get(Input) then begin
                ItemUOM.Reset();
                ItemUOM.SetRange("Item No.", Input);
                if UOMCode <> '' then begin
                    ItemUOM.SetRange(Code, UOMCode);
                    if ItemUOM.IsEmpty() then
                        Error('ItemNumber=%1, UOM=%2 does not exist', Input, UOMCode);
                end;
            end else begin
                if Barcodes.Get(Input) then begin
                    ItemUOM.Reset();
                    ItemUOM.SetRange("Item No.", Barcodes."Item No.");
                    ItemUOM.SetRange(Code, Barcodes."Unit of Measure Code");
                end else
                    Error('Item/Barcode %1 does not exist', Input);
            end;
        end;
    end;
}