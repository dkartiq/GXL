xmlport 50265 "GXL PDA-EDI ASN Export"
{
    Caption = 'PDA-EDI ASN Export';
    UseRequestPage = false;
    Direction = Export;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/EDIASNExport';
    Encoding = UTF16;

    schema
    {
        textelement(OutboundASN)
        {
            MinOccurs = Once;
            MaxOccurs = Once;
            tableelement(ASNHeader; "GXL ASN Header")
            {
                MinOccurs = Zero;
                MaxOccurs = Unbounded;
                fieldelement(ASNNumber; ASNHeader."No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ASNDate; ASNHeader."Supplier Reference Date")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(SupplierID; ASNHeader."Supplier No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ShipToCode; ASNHeader."Ship-to Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(PurchaseOrderNumber; ASNHeader."Purchase Order No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ExpectedReceiptDate; ASNHeader."Expected Receipt Date")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(ShipFor; ASNHeader."Ship-for Code")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(PalletCount; ASNHeader."Total Pallets")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                fieldelement(CartonCount; ASNHeader."Total Boxes")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                textelement(ASNAudit)
                {
                    XmlName = 'Audit';
                    MaxOccurs = Once;
                    MinOccurs = Once;
                }
                tableelement(ASNPalletLines; "GXL ASN Level 1 Line")
                {
                    SourceTableView = sorting("Document Type", "Document No.", "Line No.") order(ascending);
                    LinkTable = ASNHeader;
                    LinkFields = "Document Type" = field("Document Type"), "Document No." = field("No.");
                    MinOccurs = Zero;
                    MaxOccurs = Unbounded;

                    fieldelement(LineNo; ASNPalletLines."Line No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(SSCC; ASNPalletLines."Level 1 Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(Quantity; ASNPalletLines.Quantity)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    fieldelement(QuantityReceived; ASNPalletLines."Quantity Received")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    textelement(PalletAudit)
                    {
                        XmlName = 'Audit';
                        MaxOccurs = Once;
                        MinOccurs = Once;
                    }
                    tableelement(ASNBoxLines; "GXL ASN Level 2 Line")
                    {
                        SourceTableView = sorting("Document Type", "Document No.", "Line No.") order(ascending);
                        LinkTable = ASNPalletLines;
                        LinkFields = "Document Type" = field("Document Type"), "Document No." = field("Document No."), "Level 1 Line No." = field("Line No.");
                        MinOccurs = Zero;
                        MaxOccurs = Unbounded;

                        fieldelement(BoxLineNo; ASNBoxLines."Line No.")
                        {
                            XmlName = 'LineNo';
                            MaxOccurs = Once;
                            MinOccurs = Once;
                        }
                        fieldelement(BoxSSCC; ASNBoxLines."Level 2 Code")
                        {
                            XmlName = 'SSCC';
                            MaxOccurs = Once;
                            MinOccurs = Once;
                        }
                        fieldelement(ILC; ASNBoxLines.ILC)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Once;
                        }
                        fieldelement(BoxQuantity; ASNBoxLines.Quantity)
                        {
                            XmlName = 'Quantity';
                            MaxOccurs = Once;
                            MinOccurs = Once;
                        }
                        fieldelement(BoxQuantityReceived; ASNBoxLines."Quantity Received")
                        {
                            XmlName = 'QuantityReceived';
                            MaxOccurs = Once;
                            MinOccurs = Once;
                        }
                        textelement(BoxAudit)
                        {
                            XmlName = 'Audit';
                            MaxOccurs = Once;
                            MinOccurs = Once;
                        }
                        tableelement(ASNItemLines; "GXL ASN Level 3 Line")
                        {
                            SourceTableView = sorting("Document Type", "Document No.", "Line No.", "Level 2 Line No.") order(ascending);
                            LinkTable = ASNBoxLines;
                            LinkFields = "Document Type" = field("Document Type"), "Document No." = field("Document No.");
                            MinOccurs = Zero;
                            MaxOccurs = Unbounded;

                            fieldelement(ItemLineNo; ASNItemLines."Line No.")
                            {
                                XmlName = 'LineNo';
                                MaxOccurs = Once;
                                MinOccurs = Once;
                            }
                            fieldelement(ItemILC; ASNItemLines."Level 3 Code")
                            {
                                XmlName = 'ILC';
                                MaxOccurs = Once;
                                MinOccurs = Once;
                            }
                            fieldelement(ItemNumber; ASNItemLines."Item No.")
                            {
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }
                            fieldelement(UOM; ASNItemLines."Unit of Measure Code")
                            {
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }
                            textelement(ItemDescription)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Once;
                            }
                            fieldelement(GTIN; ASNItemLines.GTIN)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Once;
                            }
                            fieldelement(ItemQuantity; ASNItemLines.Quantity)
                            {
                                XmlName = 'Quantity';
                                MaxOccurs = Once;
                                MinOccurs = Once;
                            }
                            fieldelement(ItemQuantityReceived; ASNItemLines."Quantity Received")
                            {
                                XmlName = 'QuantityReceived';
                                MaxOccurs = Once;
                                MinOccurs = Once;
                            }
                            textelement(ItemAudit)
                            {
                                XmlName = 'Audit';
                                MaxOccurs = Once;
                                MinOccurs = Once;
                            }
                            textelement(CostPrice)
                            {
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }

                            trigger OnPreXmlItem()
                            begin
                                ASNItemLines.SetRange("Level 2 Line No.");
                                ASNItemLines.SetRange("Loose Item Box Line");
                                if ASNBoxLines."Level 2 Code" = '' then
                                    ASNItemLines.SetRange("Loose Item Box Line", ASNBoxLines."Line No.")
                                else
                                    ASNItemLines.SetRange("Level 2 Line No.", ASNBoxLines."Line No.");
                            end;

                            trigger OnAfterGetRecord()
                            begin
                                //Legacy Item
                                //Item.Get(ASNItemLines."Level 3 Code");
                                if (ASNItemLines."Level 3 Type" = ASNItemLines."Level 3 Type"::Item) and (ASNItemLines."Level 3 Code" <> '') and (ASNItemLines."Item No." = '') then
                                    LegacyItemHelpers.GetItemNoForPurchase(ASNItemLines."Level 3 Code", ASNItemLines."Item No.", ASNItemLines."Unit of Measure Code");
                                if ASNItemLines."Item No." <> '' then
                                    Item.Get(ASNItemLines."Item No.")
                                else
                                    Item.Get(ASNItemLines."Level 3 Code");

                                ItemDescription := TypeHelpers.HtmlEncode(Item.Description);

                                ItemAudit := Format(ASNLevel3LineTemp.Get(ASNItemLines."Document Type", ASNItemLines."Document No.", ASNItemLines."Line No."), 0, 9);
                                CostPrice := Format(PDAItemIntegration.GetItemCostPrice(Item), 0, 9);

                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            ASNLevel2LineTemp.Reset();
                            ASNLevel2LineTemp.SetCurrentKey("Level 2 Code", "Document No.", Status, "Document Type");
                            ASNLevel2LineTemp.SetRange("Level 2 Code", ASNBoxLines."Level 2 Code");
                            ASNLevel2LineTemp.SetRange("Document No.", ASNBoxLines."Document No.");
                            ASNLevel2LineTemp.SetRange("Document Type", ASNBoxLines."Document Type");
                            BoxAudit := Format((not ASNLevel2LineTemp.IsEmpty()), 0, 9);

                            if (ASNBoxLines.ILC <> '') and (ASNBoxLines."Item No." = '') then
                                LegacyItemHelpers.GetItemNoForPurchase(ASNBoxLines.ILC, ASNBoxLines."Item No.", ASNBoxLines."Unit of Measure Code");
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        PalletAudit := Format(ASNLevel1LineTemp.Get(ASNPalletLines."Document Type", ASNPalletLines."Document No.", ASNPalletLines."Line No."), 0, 9);
                    end;
                }

                trigger OnPreXmlItem()
                begin
                    ASNHeader.SetRange("Document Type", ASNDocumentType);
                    ASNHeader.SetRange("No.", ASNNo);
                end;

                trigger OnAfterGetRecord()
                var
                    ASNLevel1Line: Record "GXL ASN Level 1 Line";
                    ASNLevel2Line: Record "GXL ASN Level 2 Line";
                    ASNLevel3Line: Record "GXL ASN Level 3 Line";
                    PalletLineAudited: Boolean;
                begin
                    ASNAudit := Format(PDAudit, 0, 9);
                    if PDAudit then begin
                        ClearAllTempRecords();

                        ASNLevel1Line.SetCurrentKey("Level 1 Code", "Document No.", Status, "Document Type");
                        ASNLevel1Line.SetRange("Document No.", ASNHeader."No.");
                        ASNLevel1Line.SetRange("Document Type", ASNHeader."Document Type");
                        if ASNLevel1Line.FindSet() then
                            repeat
                                PalletLineAudited := false;

                                //mixed boxes
                                ASNLevel2Line.Reset();
                                ASNLevel2Line.SetCurrentKey("Level 2 Code", "Document No.", Status, "Document Type");

                                //non-ghost boxes only
                                ASNLevel2Line.SetFilter("Level 2 Code", '<>%1', '');
                                ASNLevel2Line.SetRange("Document No.", ASNLevel1Line."Document No.");
                                ASNLevel2Line.SetRange("Document Type", ASNLevel1Line."Document Type");
                                ASNLevel2Line.SetRange("Level 1 Line No.", ASNLevel1Line."Line No.");
                                if ASNLevel2Line.FindSet() then begin
                                    repeat
                                        InsertBoxAuditBuffer(ASNLevel2Line);
                                        InsertPalletAuditBuffer(ASNLevel1Line);
                                        PalletLineAudited := true;
                                    until ASNLevel2Line.Next() = 0;
                                end;

                                //loose items in non-ghost pallet
                                if ASNLevel1Line."Level 1 Code" <> '' then begin
                                    ASNLevel3Line.Reset();
                                    ASNLevel3Line.SetCurrentKey("Level 3 Code", "Document No.", "Level 1 Line No.", "Level 2 Line No.", Status, "Document Type");
                                    ASNLevel3Line.SetRange("Document No.", ASNLevel1Line."Document No.");
                                    ASNLevel3Line.SetRange("Document Type", ASNLevel1Line."Document Type");
                                    ASNLevel3Line.SetRange("Level 1 Line No.", ASNLevel1Line."Line No.");
                                    if ASNLevel3Line.FindSet() then begin
                                        repeat
                                            InsertItemAuditBuffer(ASNLevel3Line);
                                        until ASNLevel3Line.Next() = 0;

                                        if not PalletLineAudited then begin
                                            InsertPalletAuditBuffer(ASNLevel1Line);
                                            PalletLineAudited := true;
                                        end;
                                    end;
                                end;
                            until ASNLevel1Line.Next() = 0;
                    end;
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    trigger OnPostXmlPort()
    begin
        ClearAllTempRecords();
    end;

    var
        Item: Record Item;
        ASNLevel1LineTemp: Record "GXL ASN Level 1 Line" temporary;
        ASNLevel2LineTemp: Record "GXL ASN Level 2 Line" temporary;
        ASNLevel3LineTemp: Record "GXL ASN Level 3 Line" temporary;
        TypeHelpers: Codeunit "Type Helper";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
        ASNDocumentType: Option Purchase,Transfer;
        ASNNo: Code[20];
        PDAudit: Boolean;

    procedure SetOptions(ASNDocumentTypeNew: Option Purchase,Transfer; ASNNumberNew: Code[20]; PDAuditNew: Boolean)
    begin
        ASNDocumentType := ASNDocumentTypeNew;
        ASNNo := ASNNumberNew;
        PDAudit := PDAuditNew;
    end;

    local procedure InsertPalletAuditBuffer(InputASNLevel1Line: Record "GXL ASN Level 1 Line")
    begin
        if not ASNLevel1LineTemp.Get(InputASNLevel1Line."Document Type", InputASNLevel1Line."Document No.", InputASNLevel1Line."Line No.") then begin
            ASNLevel1LineTemp.Init();
            ASNLevel1LineTemp.TransferFields(InputASNLevel1Line);
            ASNLevel1LineTemp.Insert();
        end;
    end;

    local procedure InsertBoxAuditBuffer(InputASNLevel2Line: Record "GXL ASN Level 2 Line")
    var
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
    begin

        ASNLevel2LineTemp.Reset();
        ASNLevel2LineTemp.SetCurrentKey("Level 2 Code", "Document No.", Status, "Document Type");
        ASNLevel2LineTemp.SetRange("Level 2 Code", InputASNLevel2Line."Level 2 Code");
        ASNLevel2LineTemp.SetRange("Document No.", InputASNLevel2Line."Document No.");
        ASNLevel2LineTemp.SetRange("Document Type", InputASNLevel2Line."Document Type");
        if ASNLevel2LineTemp.IsEMpty() then begin

            ASNLevel2LineTemp.Init();
            ASNLevel2LineTemp.TransferFields(InputASNLevel2Line);
            ASNLevel2LineTemp.Insert();

            //all the items within the same box (same SSCC on box line) need to be audited
            ASNLevel2Line.SetCurrentKey("Level 2 Code", "Document No.", Status, "Document Type");
            ASNLevel2Line.SetRange("Level 2 Code", InputASNLevel2Line."Level 2 Code");
            ASNLevel2Line.SetRange("Document No.", InputASNLevel2Line."Document No.");
            ASNLevel2Line.SetRange("Document Type", InputASNLevel2Line."Document Type");
            if ASNLevel2Line.FindSet() then
                repeat
                    if CheckMixedCarton(ASNLevel2Line) then begin
                        ASNLevel3Line.Reset();
                        ASNLevel3Line.SetCurrentKey("Level 3 Code", "Document No.", "Level 1 Line No.", "Level 2 Line No.", Status, "Document Type");
                        ASNLevel3Line.SetRange("Document No.", ASNLevel2Line."Document No.");
                        ASNLevel3Line.SetRange("Level 2 Line No.", ASNLevel2Line."Line No.");
                        ASNLevel3Line.SetRange("Document Type", ASNLevel2Line."Document Type");
                        if ASNLevel3Line.FindSet() then
                            repeat
                                InsertItemAuditBuffer(ASNLevel3Line);
                            until ASNLevel3Line.Next() = 0;
                    end;

                until ASNLevel2Line.Next() = 0;

        end;
    end;

    local procedure InsertItemAuditBuffer(InputASNLevel3Line: Record "GXL ASN Level 3 Line")
    begin
        if not ASNLevel3LineTemp.Get(InputASNLevel3Line."Document Type", InputASNLevel3Line."Document No.", InputASNLevel3Line."Line No.") then begin
            ASNLevel3LineTemp.Init();
            ASNLevel3LineTemp.TransferFields(InputASNLevel3Line);
            ASNLevel3LineTemp.Insert();
        end;
    end;

    local procedure CheckMixedCarton(InputASNLevel2Line: Record "GXL ASN Level 2 Line"): Boolean
    var
        ASNLine2Level: Record "GXL ASN Level 2 Line";
    begin
        ASNLine2Level.SetRange("Document Type", InputASNLevel2Line."Document Type");
        ASNLine2Level.SetRange("Document No.", InputASNLevel2Line."Document No.");
        ASNLine2Level.SetRange("Level 2 Type", ASNLine2Level."Level 2 Type"::Box);
        ASNLine2Level.SetFilter("Level 2 Code", InputASNLevel2Line."Level 2 Code");
        ASNLine2Level.SetFilter(ILC, '<>%1', InputASNLevel2Line.ILC);
        exit(not ASNLine2Level.IsEmpty());
    end;

    local procedure ClearAllTempRecords()
    begin
        ASNLevel1LineTemp.Reset();
        ASNLevel1LineTemp.DeleteAll();

        ASNLevel2LineTemp.Reset();
        ASNLevel2LineTemp.DeleteAll();

        ASNLevel3LineTemp.Reset();
        ASNLevel3LineTemp.DeleteAll();
    end;

}