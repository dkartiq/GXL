/*
Change Log:
    PS-2411: New xmlport to send result back to MIM
*/
xmlport 50268 "GXL PDA-TransferShptResult"
{
    Caption = 'PDA-Transfer Shipment Result';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/TransferShipmentResult';
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
                fieldelement(Comment; Line.Comment)
                {
                    MinOccurs = Once;
                    MaxOccurs = Once;
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    var

    procedure SetResultTransShptLine(var TempPDATransShptLine: Record "GXL PDA-Trans Shipment Line" temporary)
    var
    begin
        Line.Reset();
        Line.DeleteAll();
        if TempPDATransShptLine.FindSet() then
            repeat
                Line := TempPDATransShptLine;
                Line.Insert();
            until TempPDATransShptLine.Next() = 0;
    end;
}