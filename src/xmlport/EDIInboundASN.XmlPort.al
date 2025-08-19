xmlport 50049 "GXL EDI Inbound ASN"
{
    Caption = 'EDI Inbound ASN';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(InboundASN)
        {
            MaxOccurs = Once;
            tableelement("GXL ASN Header"; "GXL ASN Header")
            {
                RequestFilterFields = "Document Type", "No.";
                XmlName = 'ASNHeader';
                SourceTableView = SORTING("Document Type", "No.");
                fieldelement(ASNNumber; "GXL ASN Header"."Original EDI Document No.")
                {
                }
                fieldelement(ASNDate; "GXL ASN Header"."Supplier Reference Date")
                {
                }
                fieldelement(SupplierID; "GXL ASN Header"."Supplier No.")
                {
                    FieldValidate = yes;
                }
                fieldelement(ShipToCode; "GXL ASN Header"."Ship-To Code")
                {
                    FieldValidate = yes;
                }
                fieldelement(PurchaseOrderNumber; "GXL ASN Header"."Purchase Order No.")
                {
                }
                fieldelement(ExpectedReceiptDate; "GXL ASN Header"."Expected Receipt Date")
                {
                }
                fieldelement(ShipFor; "GXL ASN Header"."Ship-for Code")
                {
                }
                fieldelement(PalletCount; "GXL ASN Header"."Total Pallets")
                {
                }
                fieldelement(CartonCount; "GXL ASN Header"."Total Boxes")
                {
                }
                fieldelement(ShipmentGrossWeight; "GXL ASN Header"."Shipment Gross Weight")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ShipmentTrackingNo; "GXL ASN Header"."Consignment Note No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ShipmentTrackingDocumentDate; "GXL ASN Header"."Consignment Note Date")
                {
                    MinOccurs = Zero;
                }
                fieldelement(DeliveryProfile; "GXL ASN Header"."Delivery Profile")
                {
                    MinOccurs = Zero;
                }
                fieldelement(ShipmentNotes; "GXL ASN Header"."Shipment Notes")
                {
                    MinOccurs = Zero;
                }
                tableelement("ASN Level 1 Line"; "GXL ASN Level 1 Line")
                {
                    LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                    LinkTable = "GXL ASN Header";
                    MinOccurs = Zero;
                    XmlName = 'ASNPalletLines';
                    SourceTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending);
                    fieldelement(SSCC; "ASN Level 1 Line"."Level 1 Code")
                    {
                    }
                    fieldelement(Quantity; "ASN Level 1 Line".Quantity)
                    {
                    }
                    fieldelement(PackageGrossWeight; "ASN Level 1 Line"."Package Gross Weight")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(PackageNetWeight; "ASN Level 1 Line"."Package Net Weight")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(NumberOfLayers; "ASN Level 1 Line"."Number of Layers")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(UnitsPerLayer; "ASN Level 1 Line"."Units Per Layer")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(BatchNo; "ASN Level 1 Line"."Batch No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(BatchExpiryDate; "ASN Level 1 Line"."Batch Expiry Date")
                    {
                        MinOccurs = Zero;
                    }
                    tableelement("ASN Level 2 Line"; "GXL ASN Level 2 Line")
                    {
                        LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No."), "Level 1 Line No." = FIELD("Line No.");
                        LinkTable = "ASN Level 1 Line";
                        MinOccurs = Zero;
                        XmlName = 'ASNBoxLines';
                        SourceTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending);
                        fieldelement(SSCC; "ASN Level 2 Line"."Level 2 Code")
                        {
                        }
                        fieldelement(Items; "ASN Level 2 Line".ILC)
                        {
                        }
                        fieldelement(QtyShippedInOP; "ASN Level 2 Line".Quantity)
                        {
                        }
                        fieldelement(CartonGrossWeight; "ASN Level 2 Line"."Carton Gross Weight")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(CartonNetWeight; "ASN Level 2 Line"."Carton Net Weight")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(BatchNo; "ASN Level 2 Line"."Batch No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(BatchExpiryDate; "ASN Level 2 Line"."Batch Expiry Date")
                        {
                            MinOccurs = Zero;
                        }
                        tableelement("ASN Level 3 Line"; "GXL ASN Level 3 Line")
                        {
                            LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No.");
                            LinkTable = "ASN Level 2 Line";
                            MinOccurs = Zero;
                            XmlName = 'ASNItemLines';
                            SourceTableView = SORTING("Document Type", "Document No.", "Line No.", "Level 2 Line No.") ORDER(Ascending);
                            // >> HP2-SPRINT2
                            // fieldelement(Items; "ASN Level 3 Line"."Level 3 Code")
                            // {

                            // }
                            //    fieldelement(GTIN; "ASN Level 3 Line".GTIN)
                            // {
                            // }
                            fieldelement(Items; "ASN Level 3 Line"."Level 3 Code")
                            {
                                trigger OnAfterAssignField()
                                var
                                    LegacyItemHelper: Codeunit "GXL Legacy Item Helpers";
                                    ItemL: Record Item;
                                    EDIItemSupplier: Record "GXL EDI Item Supplier";
                                    ItemNo: Code[20];
                                    UOMCode: Code[10];
                                begin
                                    LegacyItemHelper.GetItemNo("ASN Level 3 Line"."Level 3 Code", ItemNo, UOMCode);
                                    if EDIItemSupplier.Get(ItemNo, "GXL ASN Header"."Supplier No.") then
                                        "ASN Level 3 Line".Validate(GTIN, EDIItemSupplier.GTIN)
                                    else
                                        if ItemL.Get(ItemNo) then
                                            "ASN Level 3 Line".Validate(GTIN, ItemL.GTIN);
                                end;
                            }
                            textelement(GTIN)
                            {
                                trigger OnBeforePassVariable()
                                begin
                                    GTING := GTIN;
                                end;
                            }
                            // << HP2-SPRINT 
                            fieldelement(QtyShippedInUnit; "ASN Level 3 Line".Quantity)
                            {
                            }
                            fieldelement(BatchNo; "ASN Level 3 Line"."Batch No.")
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(BatchExpiryDate; "ASN Level 3 Line"."Batch Expiry Date")
                            {
                                MinOccurs = Zero;
                            }

                            trigger OnAfterInitRecord()
                            var
                                EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
                            begin
                                ItemLineNo += 10000;

                                "ASN Level 3 Line"."Document Type" := "GXL ASN Header"."Document Type";
                                "ASN Level 3 Line"."Document No." := "GXL ASN Header"."No.";
                                "ASN Level 3 Line"."Line No." := ItemLineNo;

                                EDIFunctionsLibrary.LinkASNItemLine("ASN Level 1 Line", "ASN Level 2 Line", "ASN Level 3 Line");

                                "ASN Level 3 Line"."Level 3 Type" := "ASN Level 3 Line"."Level 3 Type"::Item;

                                "ASN Level 3 Line".Status := "ASN Level 3 Line".Status::Imported;
                            end;

                            trigger OnBeforeInsertRecord()
                            begin
                                //Legacy Item
                                if "ASN Level 3 Line"."Level 3 Type" = "ASN Level 3 Line"."Level 3 Type"::Item then
                                    if "ASN Level 3 Line"."Level 3 Code" <> '' then
                                        LegacyItemHelpers.GetItemNoForPurchase("ASN Level 3 Line"."Level 3 Code", "ASN Level 3 Line"."Item No.", "ASN Level 3 Line"."Unit of Measure Code");
                            end;
                        }

                        trigger OnAfterInitRecord()
                        begin
                            BoxLineNo += 10000;

                            "ASN Level 2 Line"."Document Type" := "GXL ASN Header"."Document Type";
                            "ASN Level 2 Line"."Document No." := "GXL ASN Header"."No.";
                            "ASN Level 2 Line"."Line No." := BoxLineNo;

                            "ASN Level 2 Line"."Level 1 Line No." := "ASN Level 1 Line"."Line No.";

                            "ASN Level 2 Line"."Level 2 Type" := "ASN Level 2 Line"."Level 2 Type"::Box;

                            "ASN Level 2 Line".Status := "ASN Level 2 Line".Status::Imported;
                            "ASN Level 2 Line"."Supplier No." := "GXL ASN Header"."Supplier No.";
                        end;

                        trigger OnBeforeInsertRecord()
                        begin
                            //Legacy Item
                            if "ASN Level 2 Line".ILC <> '' then
                                LegacyItemHelpers.GetItemNoForPurchase("ASN Level 2 Line".ILC, "ASN Level 2 Line"."Item No.", "ASN Level 2 Line"."Unit of Measure Code");
                        end;
                    }

                    trigger OnAfterInitRecord()
                    begin
                        PalletLineNo += 10000;

                        "ASN Level 1 Line"."Document Type" := "GXL ASN Header"."Document Type";
                        "ASN Level 1 Line"."Document No." := "GXL ASN Header"."No.";
                        "ASN Level 1 Line"."Line No." := PalletLineNo;
                        "ASN Level 1 Line"."Level 1 Type" := "ASN Level 1 Line"."Level 1 Type"::Pallet;

                        "ASN Level 1 Line".Status := "ASN Level 1 Line".Status::Imported;
                        "ASN Level 1 Line"."Supplier No." := "GXL ASN Header"."Supplier No.";
                    end;
                }

                trigger OnAfterInitRecord()
                begin
                    "GXL ASN Header"."No." := ASNNo;

                    "GXL ASN Header"."Document Type" := "GXL ASN Header"."Document Type"::Purchase;
                    "GXL ASN Header".Status := "GXL ASN Header".Status::Imported;
                    if EDIFileLogEntryNo = 0 then
                        EDIFileLogEntryNo := SingleInstance.GetEDIFileLogEntryNo();

                    "GXL ASN Header"."EDI File Log Entry No." := EDIFileLogEntryNo;
                end;
            }
        }
    }


    trigger OnPreXmlPort()
    begin
        ASNNo := MiscUtilities.GetNextEDIDocumentNo(1);
    end;

    var
        SingleInstance: Codeunit "GXL WMS Single Instance";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        EDIFileLogEntryNo: Integer;
        PalletLineNo: Integer;
        BoxLineNo: Integer;
        ItemLineNo: Integer;
        ASNNo: Code[20];
        GTING: Code[50]; // >> HP2-SPRINT2 <<


    [Scope('OnPrem')]
    procedure SetEDIFileLogEntryNo(EDIFileLogEntryNoNew: Integer)
    begin
        EDIFileLogEntryNo := EDIFileLogEntryNoNew;
    end;
}

