xmlport 50251 "GXL PDA-Store User"
{
    Caption = 'PDA-Store User';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/StoreUser';
    Encoding = UTF16;

    schema
    {
        textelement(StoreUsers)
        {
            MinOccurs = Once;
            MaxOccurs = Once;
            tableelement(StoreUser; "GXL PDA-Store User")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(UserID; StoreUser."User ID")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(StoreCode; StoreUser."Store Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(StoreName; StoreUser."Store Name")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(Default; StoreUser.Default)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    var

    procedure SetXMLFilters(NewUserCode: Code[50]; NewStoreNo: Code[10])
    begin
        if NewUserCode <> '' then
            StoreUser.SetRange("User ID", NewUserCode);
        if NewStoreNo <> '' then
            StoreUser.SetRange("Store Code", NewStoreNo);
    end;


}