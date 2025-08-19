xmlport 50267 "GXL PDA-Active Vendors"
{
    Caption = 'PDA-Items';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/ActiveVendors';
    Encoding = UTF16;

    schema
    {
        textelement(ActiveVendorQuery)
        {
            tableelement(NetworkCapacity; Vendor)
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;

                fieldelement(VendorNo; NetworkCapacity."No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(VendorName; NetworkCapacity.Name)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }

                trigger OnPreXmlItem()
                begin
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    procedure SetXmlFilter(StoreCode: Code[10])
    var
        Store: Record "LSC Store";
        StoreRolledOut: Boolean;
    begin
        NetworkCapacity.SetFilter(Blocked, '<>%1', NetworkCapacity.Blocked::All);

        StoreRolledOut := false;
        if Store.Get(StoreCode) then
            if Store."GXL Rolled-Out" then
                StoreRolledOut := true;
        if StoreRolledOut then
            NetworkCapacity.SetRange("GXL Rolled-Out", true)
        else
            NetworkCapacity.SetRange("GXL Rolled-Out");
    end;
}