xmlport 50266 "GXL PDA-EDI ASN Import"
{
    Caption = 'PDA-EDI ASN Import';
    UseRequestPage = false;
    Direction = Import;
    Format = Xml;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/EDIASNImport';
    Encoding = UTF16;

    schema
    {
        textelement(InboundASN)
        {
            MaxOccurs = Once;
            tableelement(ASNHeader; "GXL ASN Header Scan Log")
            {
                SourceTableView = sorting("Document Type", "No.");
                MinOccurs = Once;
                MaxOccurs = Once;
                fieldelement(ASNNumber; ASNHeader."No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnAfterAssignField()
                    begin
                        ASNHeader.TestField("No.");
                    end;
                }
                textelement(ASNDate)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(SupplierID)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(ShipToCode)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                fieldelement(PurchaseOrderNumber; ASNHeader."Purchase Order No.")
                {
                    MaxOccurs = Once;
                    MinOccurs = Once;

                    trigger OnAfterAssignField()
                    begin
                        ASNHeader.TestField("Purchase Order No.");
                    end;
                }
                textelement(ExpectedReceiptDate)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(ShipFor)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(PalletCount)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(CartonCount)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(ASNAudit)
                {
                    XmlName = 'Audit';
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                tableelement(ASNPalletLines; "GXL ASN Level 1 Line Scan Log")
                {
                    LinkTable = ASNHeader;
                    SourceTableView = sorting("Document No.", "Line No.", "Document Type");
                    LinkFields = "Document Type" = field("Document Type"), "Document No." = field("No.");
                    MinOccurs = Zero;
                    MaxOccurs = Unbounded;

                    fieldelement(LineNo; ASNPalletLines."Line No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;

                        trigger OnAfterAssignField()
                        begin
                            ASNPalletLines.TestField("Line No.");
                        end;

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
                        MinOccurs = Zero;
                    }
                    tableelement(ASNBoxLines; "GXL ASN Level 2 Line Scan Log")
                    {
                        LinkTable = ASNPalletLines;
                        SourceTableView = sorting("Document No.", "Line No.", "Document Type");
                        LinkFields = "Document Type" = field("Document Type"), "Document No." = field("Document No.");
                        MinOccurs = Zero;
                        MaxOccurs = Unbounded;

                        fieldelement(BoxLineNo; ASNBoxLines."Line No.")
                        {
                            XmlName = 'LineNo';
                            MaxOccurs = Once;
                            MinOccurs = Once;

                            trigger OnAfterAssignField()
                            begin
                                ASNBoxLines.TestField("Line No.");
                            end;
                        }
                        fieldelement(BoxSSCC; ASNBoxLines."Level 2 Code")
                        {
                            XmlName = 'SSCC';
                            MaxOccurs = Once;
                            MinOccurs = Once;
                        }
                        fieldelement(BoxILC; ASNBoxLines.ILC)
                        {
                            XmlName = 'ILC';
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
                            MinOccurs = Zero;
                        }
                        tableelement(ASNItemLines; "GXL ASN Level 3 Line Scan Log")
                        {
                            LinkTable = ASNBoxLines;
                            SourceTableView = sorting("Document No.", "Line No.", "Document Type");
                            LinkFields = "Document Type" = field("Document Type"), "Document No." = field("Document No.");
                            MinOccurs = Zero;
                            MaxOccurs = Unbounded;

                            fieldelement(ItemLineNo; ASNItemLines."Line No.")
                            {
                                XmlName = 'LineNo';
                                MaxOccurs = Once;
                                MinOccurs = Once;

                                trigger OnAfterAssignField()
                                begin
                                    ASNItemLines.TestField("Line No.");
                                end;
                            }
                            fieldelement(ItemILC; ASNItemLines."Level 3 Code")
                            {
                                XmlName = 'ILC';
                                MaxOccurs = Once;
                                MinOccurs = Once;
                            }
                            textelement(ItemDescription)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                            }
                            textelement(GTIN)
                            {
                                MaxOccurs = Once;
                                MinOccurs = Zero;
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

                                trigger OnAfterAssignField()
                                begin
                                    if ASNItemLines."Quantity Received" < 0 then
                                        Error(StrSubstNo(MustBeGreaterThanZeroErr, ASNItemLines.FieldCaption("Quantity Received"), ASNItemLines."Line No."));
                                end;
                            }
                            textelement(ItemAudit)
                            {
                                XmlName = 'Audit';
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                            }

                            trigger OnPreXmlItem()
                            begin
                            end;

                            trigger OnAfterInitRecord()
                            begin
                                ASNItemLines."Document Type" := ASNHeader."Document Type";
                                ASNItemLines."Document No." := ASNHeader."No.";
                            end;

                        }

                        trigger OnAfterInitRecord()
                        begin
                            ASNBoxLines."Document Type" := ASNHeader."Document Type";
                            ASNBoxLines."Document No." := ASNHeader."No.";
                        end;

                    }

                    trigger OnAfterInitRecord()
                    begin
                        ASNPalletLines."Document Type" := ASNHeader."Document Type";
                        ASNPalletLines."Document No." := ASNHeader."No.";
                    end;
                }

                trigger OnPreXmlItem()
                begin
                end;

                trigger OnAfterInitRecord()
                begin
                    ASNHeader."EDI File Log Entry No." := EDIFileLogEntryNo;
                end;

                trigger OnBeforeInsertRecord()
                begin
                    //PS-2046+
                    ASNHeader."MIM User ID" := UserId();
                    //PS-2046-
                end;

            }
        }
    }

    trigger OnPreXmlPort()
    begin
    end;

    trigger OnInitXmlPort()
    begin
    end;

    var
        EDIFileLogEntryNo: Integer;
        MustBeGreaterThanZeroErr: Label '%1 has to be greater than zero in ASN Item Line %2.';


    procedure SetEDIFileLogEntryNo(EDIFileLogEntryNoNew: Integer)
    begin
        EDIFileLogEntryNo := EDIFileLogEntryNoNew;
    end;
}