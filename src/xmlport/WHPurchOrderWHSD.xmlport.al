// 001 9.07.2025 KDU HP2-SPRINT2
/*
// -- SR12470 30/04/2015 nao pv00.01
Modified XML format
Remove thousands separator from <OrderQuantity> and <QtyToReceive>
*/
xmlport 50250 "WH-Purchase Order -WH-SD"
{
    Caption = 'WH-Purchase Order -WH-SD';
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseRequestPage = false;
    // UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/x50250';
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