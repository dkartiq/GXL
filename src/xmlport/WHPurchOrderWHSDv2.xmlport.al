// 001 9.07.2025 KDU HP2-SPRINT2
/*
 MCS1.89 08-02-19 JM
#CASE0001170
#New XMLport based on XMLport 50250
#Added element <ReceivingWarehouseCode> to identify the warehouse location receiving the PO
*/
xmlport 50074 "WH-Purchase Order -WH-SD v2"
{
    Caption = 'WH-Purchase Order -WH-SD v2';
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseRequestPage = false;
    // UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/x50074';
    Encoding = UTF16;

    schema
    {
        textelement(WHPurchaseOrder)
        {
            tableelement(PurchaseOrderHeader; "Purchase Header")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                XmlName = 'PurchaseOrderHeader';
                SourceTableView = where("Document Type" = const(Order), "GXL Source of Supply" = filter(1));
                RequestFilterFields = "Buy-from Vendor No.";
                fieldelement(PONumber; PurchaseOrderHeader."No.") { }
                fieldelement(VendorNo; PurchaseOrderHeader."Buy-from Vendor No.") { }
                fieldelement(VendorName; PurchaseOrderHeader."Buy-from Vendor Name") { }

                // >> HP2-SPRINT2
                //  fieldelement(OrderDate; PurchaseOrderHeader."Order Date") { }
                // fieldelement(ExpecteRecDate; PurchaseOrderHeader."Expected Receipt Date") { }
                // fieldelement(OrderStatus; PurchaseOrderHeader."GXL Order Status") { }
                // fieldelement(SourceOfSupply; PurchaseOrderHeader."GXL Source of Supply") { }
                textelement(OrderDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        OrderDate := Format(PurchaseOrderHeader."Order Date", 0, '<Day,2>/<Month,2>/<Year,2>')
                    end;
                }
                textelement(ExpecteRecDate)
                {
                    trigger OnBeforePassVariable()
                    begin
                        ExpecteRecDate := Format(PurchaseOrderHeader."Expected Receipt Date", 0, '<Day,2>/<Month,2>/<Year,2>')
                    end;
                }
                textelement(OrderStatus)
                {
                    trigger OnBeforePassVariable()
                    begin
                        OrderStatus := Format(PurchaseOrderHeader."GXL Order Status");
                    end;
                }
                textelement(SourceOfSupply)
                {
                    trigger OnBeforePassVariable()
                    begin
                        SourceOfSupply := Format(PurchaseOrderHeader."GXL Source of Supply");
                    end;
                }
                // << HP2-SPRINT2

                fieldelement(DeliveryLocation; PurchaseOrderHeader."Ship-to Code") { }
                fieldelement(DeliveryName; PurchaseOrderHeader."Ship-to Name") { }
                fieldelement(DeliveryAddress; PurchaseOrderHeader."Ship-to Address") { }
                fieldelement(DeliverCity; PurchaseOrderHeader."Ship-to City") { }
                fieldelement(DeliveryPostCode; PurchaseOrderHeader."Ship-to Post Code") { }
                fieldelement(ReceivingWarehouseCode; PurchaseOrderHeader."Location Code") { }
                tableelement(PurchaseOrderLine; "Purchase Line")
                {
                    XmlName = 'PurchaseOrderLine';
                    SourceTableView = where(Type = const(Item), "Qty. to Receive" = filter(<> 0));
                    LinkTable = PurchaseOrderHeader;
                    LinkFields = "Document Type" = field("Document Type"), "Document No." = field("No.");
                    MinOccurs = Zero;
                    MaxOccurs = Unbounded;
                    fieldelement(PoNumberLine; PurchaseOrderLine."Document No.") { }
                    fieldelement(LineNo; PurchaseOrderLine."Line No.") { }
                    fieldelement(ILC; PurchaseOrderLine."No.") { }
                    fieldelement(Description; PurchaseOrderLine."Description") { }

                    textelement(OrderQuantity)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            OrderQuantity := Format(PurchaseOrderLine."Quantity", 0, '<Integer><Decimals>');
                        end;
                    }

                    textelement(QtyToReceive)
                    {
                        trigger OnBeforePassVariable()
                        begin
                            QtyToReceive := Format(PurchaseOrderLine."Qty. to Receive", 0, '<Integer><Decimals>');
                        end;
                    }

                    fieldelement(UOMCode; PurchaseOrderLine."Unit of Measure Code") { }
                }
            }
        }
    }

    PROCEDURE SetXmlFilter(StoreCode: Code[10]);
    BEGIN
        PurchaseOrderHeader.SETRANGE("Location Code", StoreCode);
        PurchaseOrderHeader.SETRANGE("Order Date", WORKDATE);
    END;

    PROCEDURE ShowNewPO(StoreCode: Code[10]);
    BEGIN
        PurchaseOrderHeader.SETRANGE("Location Code", StoreCode);
        PurchaseOrderHeader.SETFILTER("GXL Order Status", '%1|%2', PurchaseOrderHeader."GXL Order Status"::New, PurchaseOrderHeader."GXL Order Status"::Created);
    END;

    PROCEDURE ShowBatchPO(StoreCode: Code[10]; BatchId: Integer);
    BEGIN
        PurchaseOrderHeader.SETRANGE("Location Code", StoreCode);
        //   PurchaseOrderHeader.SETRANGE("PDA Integer",BatchId);
    END;
}