xmlport 50087 "GXL International Shipping Adv"
{
    Direction = Both;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Caption = 'International Shipping Advice';
    schema
    {
        textelement(ShippingStatus)
        {
            MaxOccurs = Once;
            tableelement("Intl. Shipping Advice Header"; "GXL Intl. Shipping Advice Head")
            {
                XmlName = 'OrderHeader';
                fieldelement(OrderNumber; "Intl. Shipping Advice Header"."Order No.")
                {
                }
                fieldelement(Status; "Intl. Shipping Advice Header"."Order Shipping Status")
                {
                }
                fieldelement(SupplierID; "Intl. Shipping Advice Header"."Buy-from Vendor No.")
                {
                }
                fieldelement(SupplierOrderNumber; "Intl. Shipping Advice Header"."Vendor Order No.")
                {
                }
                fieldelement(VendorShipmentNo; "Intl. Shipping Advice Header"."Vendor Shipment No.")
                {
                }
                fieldelement(DeliveryMode; "Intl. Shipping Advice Header"."Delivery Mode")
                {
                }
                fieldelement(ShipmentMethod; "Intl. Shipping Advice Header"."Shipment Method Code")
                {
                }
                fieldelement(DeparturePort; "Intl. Shipping Advice Header"."Departure Port")
                {
                }
                fieldelement(VesselName; "Intl. Shipping Advice Header"."Vessel Name")
                {
                }
                fieldelement(ContainerCarrier; "Intl. Shipping Advice Header"."Container Carrier")
                {
                }
                fieldelement(ContainerType; "Intl. Shipping Advice Header"."Container Type")
                {
                }
                fieldelement(ContainerID; "Intl. Shipping Advice Header"."Container No.")
                {
                }
                fieldelement(CFSReceiptDate; "Intl. Shipping Advice Header"."CFS Receipt Date")
                {
                }
                fieldelement(ShippingDate; "Intl. Shipping Advice Header"."Shipping Date")
                {
                }
                fieldelement(ArrivalDate; "Intl. Shipping Advice Header"."Arrival Date")
                {
                }
                tableelement("Intl. Shipping Advice Line"; "GXL Intl. Shipping Advice Line")
                {
                    LinkFields = "Shipping Advice No." = FIELD("No.");
                    LinkTable = "Intl. Shipping Advice Header";
                    MinOccurs = Zero;
                    XmlName = 'OrderItemDetails';
                    fieldelement(LineReference; "Intl. Shipping Advice Line"."Order Line No.")
                    {
                    }
                    //ERP-NAV Master Data Management +
                    //Item No. is legacy item number
                    //There is no where this field "Item No." to validate actual item number in the purchase line, 
                    //so it is ok to not convert to actual item no.
                    // textelement(Items)
                    // {
                    //     trigger OnBeforePassVariable()
                    //     var
                    //         LegacyItemHelper: Codeunit "GXL Legacy Item Helpers";
                    //         LegacyItemNo: Code[20];
                    //     begin
                    //         LegacyItemHelper.GetLegacyItemNo("Intl. Shipping Advice Line"."Item No.", "Intl. Shipping Advice Line"."Unit of Measure Code", LegacyItemNo);
                    //         Items := LegacyItemNo;
                    //     end;

                    // }
                    fieldelement(Items; "Intl. Shipping Advice Line"."Item No.")
                    {
                    }
                    //ERP-NAV Master Data Management -
                    fieldelement(QtyShippedInOP; "Intl. Shipping Advice Line"."Carton-Quantity Shipped")
                    {
                    }
                    fieldelement(QtyShippedInUnit; "Intl. Shipping Advice Line"."Quantity Shipped")
                    {
                    }
                    fieldelement(UOM; "Intl. Shipping Advice Line"."Unit of Measure Code")
                    {
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        LineNo += 1;
                        "Intl. Shipping Advice Line"."Line No." := LineNo;
                    end;
                }

                trigger OnAfterInitRecord()
                begin
                    "Intl. Shipping Advice Header"."No." := ShipAdviceNo;

                    LineNo := 0;
                end;

                trigger OnBeforeInsertRecord()
                var
                begin
                    "Intl. Shipping Advice Header".Status := "Intl. Shipping Advice Header".Status::Imported;
                    "Intl. Shipping Advice Header"."EDI File Log Entry No." := EDIFileLogEntryNo;
                end;
            }
        }
    }


    trigger OnPreXmlPort()
    begin
        ShipAdviceNo := NoSeriesMgt.GetNextNo(GetNoSeriesCode(), Today(), true);
    end;

    var
        EDISetup: Record "GXL Integration Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        EDIFileLogEntryNo: Integer;
        LineNo: Integer;
        ShipAdviceNo: Code[20];

    [Scope('OnPrem')]
    procedure SetEDIFileLogEntryNo(EDIFileLogEntryNoNew: Integer)
    begin
        EDIFileLogEntryNo := EDIFileLogEntryNoNew;
    end;

    local procedure GetNoSeriesCode(): Code[20]
    begin
        EDISetup.Get();
        exit(EDISetup."Intl. Ship. Advice No. Series");
    end;
}

