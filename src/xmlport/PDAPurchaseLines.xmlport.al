xmlport 50263 "GXL PDA-Purchase Lines"
{
    Caption = 'PDA-Purchase Lines';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/PurchaseLines';
    Encoding = UTF16;

    schema
    {
        textelement(Root)
        {
            tableelement(PurchaseLines; "Purchase Line")
            {
                UseTemporary = true;
                MinOccurs = Zero;
                MaxOccurs = Unbounded;

                fieldelement(PONumber; PurchaseLines."Document No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(LineNo; PurchaseLines."Line No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ItemNo; PurchaseLines."No.")
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
                fieldelement(OrderQuantity; PurchaseLines.Quantity)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ReceiveQuantity; PurchaseLines."Qty. to Receive")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(UnitCost; PurchaseLines."Direct Unit Cost")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                textelement(AuditRequired)
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnBeforePassVariable()
                    begin
                        AuditRequired := 'FALSE';
                        if PurchHead."No." <> PurchaseLines."Document No." then
                            if PurchHead.Get(PurchHead."Document Type"::Order, PurchaseLines."Document No.") then
                                if PurchHead."GXL Audit Flag" then
                                    AuditRequired := 'TRUE';
                    end;
                }
                fieldelement(TotalLineValue; PurchaseLines."Amount Including VAT")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(LegacyItemNo; PurchaseLines."GXL Legacy Item No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(Barcode)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;

                    trigger OnBeforePassVariable()
                    begin
                        Barcode := PDAItemIntegration.FindItemBarcode(PurchaseLines."No.", PurchaseLines."Unit of Measure Code");
                    end;
                }

                trigger OnPreXmlItem()
                begin
                    PurchaseLines.Reset();
                    PurchaseLines.FindFirst(); //MIM will handle if no records returned
                end;
            }

        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    var
        PurchHead: Record "Purchase Header";
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";

    procedure SetXmlFilter(PONumber: Code[20]; StoreCode: Code[10])
    var
        PurchLine: Record "Purchase Line";
        TransLine: Record "Transfer Line";
        TransHead: Record "Transfer Header";
        PDAStagingPH: Record "GXL PDA-Staging Purch. Header";
        PDAStagingPL: Record "GXL PDA-Staging Purch. Line";
    begin
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange("Document No.", PONumber);
        if not PurchLine.IsEmpty() then begin
            PurchHead.Get(PurchHead."Document Type"::Order, PONumber);
            //PS-1974+: Storecode check
            if StoreCode <> '' then
                if PurchHead."Location Code" <> StoreCode then
                    Error('Purchase Order %1 does not belong to store %2', PONumber, StoreCode);
            //PS-1974-

            PurchLine.FindSet();
            repeat
                PurchaseLines.Init();
                PurchaseLines.TransferFields(PurchLine);
                PurchaseLines.Insert();
            until PurchLine.Next() = 0;
        end else begin
            PDAStagingPL.SetRange("Document No.", PONumber);
            if not PDAStagingPL.IsEmpty() then begin
                //PS-1974+: Storecode check
                if StoreCode <> '' then begin
                    PDAStagingPH.Get(PONumber);
                    if PDAStagingPH."Location Code" <> StoreCode then
                        Error('Purchase Order %1 does not belong to store %2', PONumber, StoreCode);
                end;
                //PS-1974-
                Clear(PurchHead);
                PurchHead."Document Type" := PurchHead."Document Type"::Order;
                PurchHead."No." := PONumber;
                PurchHead."GXL Audit Flag" := false;

                PDAStagingPL.FindSet();
                repeat
                    PurchaseLines.Init();
                    PurchaseLines.TransferFields(PDAStagingPL);
                    PurchaseLines."Document Type" := PurchaseLines."Document Type"::Order;
                    PurchaseLines.Insert();
                until PDAStagingPL.Next() = 0;
            end;
        end;

        TransLine.SetRange("Document No.", PONumber);
        TransLine.SetRange("Derived From Line No.", 0);
        if not TransLine.IsEmpty() then begin
            //PS-1974+: Storecode check
            if StoreCode <> '' then begin
                TransHead.Get(PONumber);
                if TransHead."Transfer-to Code" <> StoreCode then
                    Error('Transfer Order %1 does not belong to store %2', PONumber, StoreCode);
            end;
            //PS-1974-

            TransLine.FindSet();
            repeat
                PurchaseLines.Init();
                PurchaseLines."Document Type" := PurchaseLines."Document Type"::Order;
                PurchaseLines."Document No." := TransLine."Document No.";
                PurchaseLines."Line No." := TransLine."Line No.";
                PurchaseLines.Type := PurchaseLines.Type::Item;
                PurchaseLines."No." := TransLine."Item No.";
                PurchaseLines.Description := TransLine.Description;
                PurchaseLines."Unit of Measure Code" := TransLine."Unit of Measure Code";
                PurchaseLines.Quantity := TransLine.Quantity;
                PurchaseLines."Qty. to Receive" := TransLine."Qty. to Receive";
                PurchaseLines."GXL Legacy Item No." := TransLine."GXL Legacy Item No.";
                PurchaseLines.Insert();
            until TransLine.Next() = 0;
        end;

        PurchaseLines.Reset();
    end;

}