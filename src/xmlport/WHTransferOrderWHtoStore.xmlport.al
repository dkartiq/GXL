// 11.08.2025 HP2-Sprint2 Changed the Xmlport number form 50090 to 50253.In Nav 50253 was used for this XMLPort
// >> HP2-Sprint2
// xmlport 50090 "GXL WH-Transfers-WHtoStore"
xmlport 50253 "GXL WH-Transfers-WHtoStore"
// << HP2-Sprint2
{
    Caption = 'WH Transfers WH to Store';
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseRequestPage = false;
    // UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/x50253';
    Encoding = UTF16;


    schema
    {
        textelement("WH-Transfers-WHtoStore")
        {
            MinOccurs = Once;
            MaxOccurs = Unbounded;
            tableelement(TransferHeader; "Transfer Header")
            {
                MinOccurs = Once;
                MaxOccurs = Once;
                RequestFilterFields = "Transfer-from Code";
                SourceTableView = sorting("No.") order(ascending);

                fieldelement(STONumber;
                TransferHeader."No.")
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

                tableelement(TransferLines; "Transfer Line")
                {
                    MinOccurs = Once;
                    MaxOccurs = unbounded;
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
                        // Since QtyToDeliver is "Text", define its value via trigger
                        trigger OnBeforePassVariable()
                        var
                            QtyBase: Decimal;
                        begin
                            QtyBase := TransferLines."Quantity";
                            QtyToDeliver := Format(QtyBase, 0, 9); // Format with no rounding
                        end;
                    }
                }
            }
        }

    }
}
