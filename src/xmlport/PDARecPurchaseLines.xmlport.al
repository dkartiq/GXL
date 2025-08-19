xmlport 50257 "GXL PDA-Rec Purchase Lines"
{
    Caption = 'PDA-Rec Purchase Lines';
    UseRequestPage = false;
    Format = Xml;
    FormatEvaluate = Xml;
    Direction = Both;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/RecPurchaseLines';
    Encoding = UTF16;

    schema
    {
        textelement(Root)
        {
            MinOccurs = Once;
            MaxOccurs = Once;
            tableelement(PurchaseLines; "GXL PDA-Purchase Lines")
            {
                MinOccurs = Once;
                MaxOccurs = Unbounded;
                UseTemporary = true;

                fieldelement(PONumber; PurchaseLines."Document No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnAfterAssignField()
                    begin
                        PurchaseLines."Document No." := StoreCode + PurchaseLines."Document No.";
                    end;
                }
                fieldelement(LineNo; PurchaseLines."Line No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ItemNumber; PurchaseLines."Item No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(UOM; PurchaseLines."Unit of Measure Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(Description; PurchaseLines.Description)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(OrderQuantity; PurchaseLines.QtyOrdered)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ReceiveQuantity; PurchaseLines.QtyToReceive)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                fieldelement(ReasonCode; PurchaseLines.ReasonCode)
                {
                    MinOccurs = Zero;
                    MaxOccurs = Once;
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    var
        StoreCode: Code[10];

    procedure SetStoreCode(NewStoreCode: Code[10])
    begin
        StoreCode := NewStoreCode;
    end;

    procedure GetTempPDAPurchaseLines(var TempPDAPurchaseLines: Record "GXL PDA-Purchase Lines" temporary)
    begin
        TempPDAPurchaseLines.Reset();
        TempPDAPurchaseLines.DeleteAll();

        if PurchaseLines.FindSet() then
            repeat
                TempPDAPurchaseLines := PurchaseLines;
                //PS-2046+
                TempPDAPurchaseLines."MIM User ID" := UserId();
                //PS-2046-
                TempPDAPurchaseLines.Insert();
            until PurchaseLines.Next() = 0;
    end;
}