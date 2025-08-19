xmlport 50082 "GXL 3PL ASN Export"
{
    Caption = '3PL ASN Export';
    Direction = Export;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(OutboundASN)
        {
            MaxOccurs = Once;
            tableelement("ASN Header"; "GXL ASN Header")
            {
                MaxOccurs = Once;
                RequestFilterFields = "Document Type", "No.";
                XmlName = 'ASNHeader';
                SourceTableView = SORTING("Document Type", "No.");
                fieldelement(ASNNumber; "ASN Header"."No.")
                {
                }
                fieldelement(ASNDate; "ASN Header"."Supplier Reference Date")
                {
                }
                fieldelement(SupplierID; "ASN Header"."Supplier No.")
                {
                }
                fieldelement(ShipToCode; "ASN Header"."Ship-To Code")
                {
                }
                fieldelement(PurchaseOrderNumber; "ASN Header"."Purchase Order No.")
                {
                }
                fieldelement(ExpectedReceiptDate; "ASN Header"."Expected Receipt Date")
                {
                }
                fieldelement(ShipFor; "ASN Header"."Ship-for Code")
                {
                }
                fieldelement(PalletCount; "ASN Header"."Total Pallets")
                {
                }
                fieldelement(CartonCount; "ASN Header"."Total Boxes")
                {
                }
                fieldelement(ShipmentGrossWeight; "ASN Header"."Shipment Gross Weight")
                {
                }
                fieldelement(ShipmentTrackingNo; "ASN Header"."Consignment Note No.")
                {
                }
                fieldelement(ShipmentTrackingDocumentDate; "ASN Header"."Consignment Note Date")
                {
                }
                fieldelement(DeliveryProfile; "ASN Header"."Delivery Profile")
                {
                }
                fieldelement(ShipmentNotes; "ASN Header"."Shipment Notes")
                {
                }
                textelement(asnaudit)
                {
                    XmlName = 'Audit';
                }
                tableelement(asnpalletline; "GXL ASN Level 1 Line")
                {
                    LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                    LinkTable = "ASN Header";
                    MinOccurs = Zero;
                    XmlName = 'ASNPalletLines';
                    SourceTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending);
                    fieldelement(LineNo; ASNPalletLine."Line No.")
                    {
                    }
                    fieldelement(SSCC; ASNPalletLine."Level 1 Code")
                    {
                    }
                    fieldelement(Quantity; ASNPalletLine.Quantity)
                    {
                    }
                    fieldelement(QuantityReceived; ASNPalletLine."Quantity Received")
                    {
                    }
                    fieldelement(PackageGrossWeight; ASNPalletLine."Package Gross Weight")
                    {
                    }
                    fieldelement(PackageNetWeight; ASNPalletLine."Package Net Weight")
                    {
                    }
                    fieldelement(NumberOfLayers; ASNPalletLine."Number of Layers")
                    {
                    }
                    fieldelement(UnitsPerLayer; ASNPalletLine."Units Per Layer")
                    {
                    }
                    fieldelement(BatchNo; ASNPalletLine."Batch No.")
                    {
                    }
                    fieldelement(BatchExpiryDate; ASNPalletLine."Batch Expiry Date")
                    {
                    }
                    textelement(palletaudit)
                    {
                        MaxOccurs = Once;
                        XmlName = 'Audit';
                    }
                    tableelement(asnboxline; "GXL ASN Level 2 Line")
                    {
                        LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No."), "Level 1 Line No." = FIELD("Line No.");
                        LinkTable = ASNPalletLine;
                        MinOccurs = Zero;
                        XmlName = 'ASNBoxLines';
                        SourceTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending);
                        fieldelement(LineNo; ASNBoxLine."Line No.")
                        {
                        }
                        fieldelement(SSCC; ASNBoxLine."Level 2 Code")
                        {
                        }

                        fieldelement(ILC; ASNBoxLine.ILC)
                        {
                        }
                        fieldelement(Quantity; ASNBoxLine.Quantity)
                        {
                        }
                        fieldelement(QuantityReceived; ASNBoxLine."Quantity Received")
                        {
                        }
                        fieldelement(CartonGrossWeight; ASNBoxLine."Carton Gross Weight")
                        {
                        }
                        fieldelement(CartonNetWeight; ASNBoxLine."Carton Net Weight")
                        {
                        }
                        fieldelement(BatchNo; ASNBoxLine."Batch No.")
                        {
                        }
                        fieldelement(BatchExpiryDate; ASNBoxLine."Batch Expiry Date")
                        {
                        }
                        textelement(boxaudit)
                        {
                            MaxOccurs = Once;
                            XmlName = 'Audit';
                        }
                        tableelement(asnitemline; "GXL ASN Level 3 Line")
                        {
                            LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No.");
                            LinkTable = ASNBoxLine;
                            MinOccurs = Zero;
                            XmlName = 'ASNItemLines';
                            SourceTableView = SORTING("Document Type", "Document No.", "Line No.", "Level 2 Line No.") ORDER(Ascending);
                            fieldelement(LineNo; ASNItemLine."Line No.")
                            {
                            }
                            fieldelement(ILC; ASNItemLine."Level 3 Code")
                            {
                            }
                            textelement(ItemDescription)
                            {
                                MaxOccurs = Once;
                            }
                            fieldelement(GTIN; ASNItemLine.GTIN)
                            {
                            }
                            fieldelement(Quantity; ASNItemLine.Quantity)
                            {
                            }
                            fieldelement(QuantityReceived; ASNItemLine."Quantity Received")
                            {
                            }
                            fieldelement(BatchNo; ASNItemLine."Batch No.")
                            {
                            }
                            fieldelement(BatchExpiryDate; ASNItemLine."Batch Expiry Date")
                            {
                            }
                            textelement(itemaudit)
                            {
                                MaxOccurs = Once;
                                XmlName = 'Audit';
                            }

                            trigger OnAfterGetRecord()
                            var
                                Item: Record Item;
                                PrismMiscUtilities: Codeunit "GXL Misc. Utilities";
                            begin
                                //Legacy Item
                                //Item.Get(ASNItemLine."Level 3 Code");
                                if asnitemline."Item No." = '' then
                                    LegacyItemHelpers.GetItemNoForPurchase(asnitemline."Level 3 Code", asnitemline."Item No.", asnitemline."Unit of Measure Code");
                                if asnitemline."Item No." <> '' then
                                    Item.Get(asnitemline."Item No.")
                                else
                                    Item.Get(asnitemline."Level 3 Code");
                                ItemDescription := PrismMiscUtilities.GetXMLFormattedText(Item.Description);

                                ItemAudit := Format(ASNLevel3LineTemp.Get(ASNItemLine."Document Type", ASNItemLine."Document No.", ASNItemLine."Line No."), 0, 9);
                            end;

                            trigger OnPreXmlItem()
                            begin
                                ASNItemLine.SetRange("Level 2 Line No.");
                                ASNItemLine.SetRange("Loose Item Box Line");

                                if ASNBoxLine."Level 2 Code" = '' then //ghost box
                                    ASNItemLine.SetRange(ASNItemLine."Loose Item Box Line", ASNBoxLine."Line No.")
                                else
                                    ASNItemLine.SetRange("Level 2 Line No.", ASNBoxLine."Line No.");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            ASNLevel2LineTemp.Reset();
                            ASNLevel2LineTemp.SetCurrentKey("Level 2 Code", "Document No.", Status, "Document Type");
                            ASNLevel2LineTemp.SetRange("Level 2 Code", ASNBoxLine."Level 2 Code");
                            ASNLevel2LineTemp.SetRange("Document No.", ASNBoxLine."Document No.");
                            ASNLevel2LineTemp.SetRange("Document Type", ASNBoxLine."Document Type");

                            BoxAudit := Format(not ASNLevel2LineTemp.IsEmpty(), 0, 9);
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        PalletAudit := Format(ASNLevel1LineTemp.Get(ASNPalletLine."Document Type", ASNPalletLine."Document No.", ASNPalletLine."Line No."), 0, 9);
                    end;
                }

                trigger OnAfterGetRecord()
                var
                    ASNLevel1Line: Record "GXL ASN Level 1 Line";
                    ASNLevel2Line: Record "GXL ASN Level 2 Line";
                    ASNLevel3Line: Record "GXL ASN Level 3 Line";
                    PalletLineAudited: Boolean;
                    LastBoxSSCC: Code[50];
                begin
                    ASNAudit := Format(PDAAudit, 0, 9);

                    if PDAAudit then begin

                        ASNLevel1LineTemp.Reset();
                        ASNLevel1LineTemp.DeleteAll();

                        ASNLevel2LineTemp.Reset();
                        ASNLevel2LineTemp.DeleteAll();

                        ASNLevel3LineTemp.Reset();
                        ASNLevel3LineTemp.DeleteAll();

                        ASNLevel1Line.SetCurrentKey("Level 1 Code", "Document No.", Status, "Document Type");

                        ASNLevel1Line.SetRange("Document No.", "ASN Header"."No.");
                        ASNLevel1Line.SetRange("Document Type", "ASN Header"."Document Type");

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

                                    Clear(LastBoxSSCC);

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

                trigger OnPreXmlItem()
                begin
                    "ASN Header".SetRange("Document Type", ASNDocumentType);
                    "ASN Header".SetRange("No.", ASNumber);
                end;
            }
        }
    }

    trigger OnPostXmlPort()
    begin
        ASNLevel1LineTemp.Reset();
        ASNLevel1LineTemp.DeleteAll();

        ASNLevel2LineTemp.Reset();
        ASNLevel2LineTemp.DeleteAll();

        ASNLevel3LineTemp.Reset();
        ASNLevel3LineTemp.DeleteAll();
    end;

    var
        ASNLevel1LineTemp: Record "GXL ASN Level 1 Line" temporary;
        ASNLevel2LineTemp: Record "GXL ASN Level 2 Line" temporary;
        ASNLevel3LineTemp: Record "GXL ASN Level 3 Line" temporary;
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        ASNDocumentType: Option Purchase,Transfer;
        ASNumber: Code[20];
        PDAAudit: Boolean;

    [Scope('OnPrem')]
    procedure SetOptions(ASNDocumentTypeNew: Option Purchase,Transfer; ASNNumberNew: Code[20]; PDAAuditNew: Boolean)
    begin
        ASNDocumentType := ASNDocumentTypeNew;
        ASNumber := ASNNumberNew;
        PDAAudit := PDAAuditNew;
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

        if ASNLevel2LineTemp.IsEmpty() then begin

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
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
    begin
        ASNLevel2Line.SetRange("Document Type", InputASNLevel2Line."Document Type");
        ASNLevel2Line.SetRange("Document No.", InputASNLevel2Line."Document No.");
        ASNLevel2Line.SetRange("Level 2 Type", ASNLevel2Line."Level 2 Type"::Box);
        ASNLevel2Line.SetFilter("Level 2 Code", InputASNLevel2Line."Level 2 Code");
        ASNLevel2Line.SetFilter(ILC, '<>%1', InputASNLevel2Line.ILC);
        if ASNLevel2Line.IsEmpty() then
            exit(false)
        else
            exit(true);
    end;
}

