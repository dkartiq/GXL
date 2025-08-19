xmlport 50260 "GXL PDA-Transfer Rcpt. Line"
{
    Caption = 'PDA-Transfer Rcpt. Line';
    UseRequestPage = false;
    Direction = Import;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/TransferReceipt';
    Encoding = UTF16;

    schema
    {
        textelement(TransferReceipt)
        {
            tableelement(Line; "GXL PDA-Trans Receipt Line")
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

    procedure GetTempPDATransRcptLine(var TempPDATransRcptLine: Record "GXL PDA-Trans Receipt Line" temporary)
    var
    begin
        TempPDATransRcptLine.Reset();
        TempPDATransRcptLine.DeleteAll();

        Line.Reset();
        if Line.FindSet() then
            repeat
                TempPDATransRcptLine := Line;
                //PS-2046+
                TempPDATransRcptLine."MIM User ID" := UserId();
                //PS-2046-
                TempPDATransRcptLine.Insert();
            until Line.Next() = 0;
    end;
}