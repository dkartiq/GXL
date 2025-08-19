// 11.08.2025 HP2-Sprint2 Changed the Xmlport number form 50250 to 50075.In Nav 50253 was used for this XMLPort
// >> HP2-Sprint2
// xmlport 50075 "GXL PDA-Store List"
xmlport 50075 "GXL PDA-Store List"
// << Hp2-Sprint2
{
    Caption = 'PDA-Store List';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/StoreList';
    Encoding = UTF16;

    schema
    {
        textelement(Stores)
        {
            tableelement(Store; "LSC Store")
            {
                //PS-2192 Added filter for Live Stores only
                SourceTableView = where("GXL Location Type" = filter("6"), "GXL LS Live Store" = const(true));
                MinOccurs = Zero;
                MaxOccurs = Unbounded;

                fieldelement(StoreCode; Store."No.")
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                fieldelement(StoreName; Store.Name)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
                //PS-2523 VET Clinic transfer order +
                fieldelement(VETStore; Store."GXL VET Store")
                {
                    MinOccurs = Zero;
                    MaxOccurs = Once;
                }
                //PS-2523 VET Clinic transfer order -
            }
        }
    }

}