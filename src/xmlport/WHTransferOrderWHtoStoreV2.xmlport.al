xmlport 50089 "GXL WH-Transfers-WHtoStore V2"
{
    Caption = 'WH Transfers WH to Store V2';
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseRequestPage = false;
    // UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/x50089';
    Encoding = UTF16;

    schema
    {
        textelement("WH-Transfers-WHtoStore")
        {
            tableelement(TransferHeader; "Transfer Header")
            {
                fieldelement(STONumber; TransferHeader."No.")
                {
                }
                fieldelement(StoreCode; TransferHeader."Transfer-to Code")
                {
                }
                fieldelement(StoreName; TransferHeader."Transfer-to Name")
                {
                }
                fieldelement(StoreAddress; TransferHeader."Transfer-to Address")
                {
                }
                fieldelement(StorePostCode; TransferHeader."Transfer-to Post Code")
                {
                }
                fieldelement(City; TransferHeader."Transfer-to City")
                {
                }
                fieldelement(State; TransferHeader."Transfer-to County")
                {
                }
                // >> HP2-SPRINT2
                // fieldelement(ShipDate; TransferHeader."Shipment Date")
                //  fieldelement(DeliveryDate; TransferHeader."Receipt Date")
                textelement(ShipDate)
                {
                    trigger OnBeforePassVariable()

                    begin
                        ShipDate := Format(TransferHeader."Shipment Date", 0, '<Day,2>/<Month,2>/<Year,2>')
                    end;
                }
                textelement(DeliveryDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        DeliveryDate := Format(TransferHeader."Receipt Date", 0, '<Day,2>/<Month,2>/<Year,2>')
                    end;
                }
                // << HP2-SPRINT2
                textelement(SourcceOfSupply)
                {
                    trigger OnBeforePassVariable()
                    begin
                        SourcceOfSupply := Format(TransferHeader."GXL Source of Supply");
                    end;
                }

                fieldelement(POReference; TransferHeader."JDA PO No.")
                {
                }
                fieldelement(WarehouseCode; TransferHeader."Transfer-from Code")
                {
                }

                tableelement(TransferLines; "Transfer Line")
                {
                    LinkTable = TransferHeader;
                    LinkFields = "Document No." = field("No.");

                    fieldelement(STONumber; TransferLines."Document No.")
                    {
                    }
                    fieldelement(LineNo; TransferLines."Line No.")
                    {
                    }
                    fieldelement(ILC; TransferLines."Item No.")
                    {
                    }
                    fieldelement(Description; TransferLines."Description")
                    {
                    }

                    textelement(QtyToDeliver)
                    {
                        trigger OnBeforePassVariable()
                        var
                            Qty: Decimal;
                        begin
                            Qty := TransferLines."Quantity";
                            QtyToDeliver := Format(Qty, 0, 9); // convert to string without rounding
                        end;
                    }
                }
            }
        }
    }
}
