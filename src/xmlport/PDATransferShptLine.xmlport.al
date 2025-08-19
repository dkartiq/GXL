xmlport 50259 "GXL PDA-Transfer Shpt. Line"
{
    Caption = 'PDA-Transfer Shpt. Line';
    UseRequestPage = false;
    Direction = Import;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/TransferShipment';
    Encoding = UTF16;

    schema
    {
        textelement(TransferShipment)
        {
            tableelement(Line; "GXL PDA-Trans Shipment Line")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                UseTemporary = true;

                fieldelement(TransferNo; Line."No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(LineNo; Line."Line No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ItemNumber; Line."Item No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(UOM; Line."Unit of Measure Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(Quantity; Line.Quantity)
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

    procedure GetTempPDATransShptLine(var TempPDATransShptLine: Record "GXL PDA-Trans Shipment Line" temporary)
    var
    begin
        TempPDATransShptLine.Reset();
        TempPDATransShptLine.DeleteAll();

        Line.Reset();
        if Line.FindSet() then
            repeat
                TempPDATransShptLine := Line;
                //PS-2046+
                TempPDATransShptLine."MIM User ID" := UserId();
                //PS-2046-
                TempPDATransShptLine.Insert();
            until Line.Next() = 0;
    end;
}