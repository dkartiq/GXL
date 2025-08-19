xmlport 50069 "GXL EDI-PDA ASN Import"
{
    Caption = 'EDI-PDA ASN Import';
    Direction = Import;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(InboundASN)
        {
            MaxOccurs = Once;
            tableelement("ASN Header Scan Log"; "GXL ASN Header Scan Log")
            {
                MaxOccurs = Once;
                RequestFilterFields = "Document Type", "No.";
                XmlName = 'ASNHeader';
                SourceTableView = SORTING("Document Type", "No.");
                fieldelement(ASNNumber; "ASN Header Scan Log"."No.")
                {

                    trigger OnAfterAssignField()
                    begin
                        "ASN Header Scan Log".TestField("No.");
                    end;
                }
                textelement(ASNDate)
                {
                }
                textelement(SupplierID)
                {
                }
                textelement(ShipToCode)
                {
                }
                fieldelement(PurchaseOrderNumber; "ASN Header Scan Log"."Purchase Order No.")
                {

                    trigger OnAfterAssignField()
                    begin
                        "ASN Header Scan Log".TestField("Purchase Order No.");
                    end;
                }
                textelement(ExpectedReceiptDate)
                {
                }
                textelement(ShipFor)
                {
                }
                textelement(PalletCount)
                {
                }
                textelement(CartonCount)
                {
                }
                textelement(Audit)
                {
                }
                tableelement("ASN Level 1 Line Scan Log"; "GXL ASN Level 1 Line Scan Log")
                {
                    LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
                    LinkTable = "ASN Header Scan Log";
                    MinOccurs = Zero;
                    XmlName = 'ASNPalletLines';
                    SourceTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending);
                    fieldelement(LineNo; "ASN Level 1 Line Scan Log"."Line No.")
                    {

                        trigger OnAfterAssignField()
                        begin
                            "ASN Level 1 Line Scan Log".TestField("Line No.");
                        end;
                    }
                    fieldelement(SSCC; "ASN Level 1 Line Scan Log"."Level 1 Code")
                    {
                    }
                    fieldelement(Quantity; "ASN Level 1 Line Scan Log".Quantity)
                    {
                    }
                    fieldelement(QuantityReceived; "ASN Level 1 Line Scan Log"."Quantity Received")
                    {
                    }
                    textelement(palletaudit)
                    {
                        MaxOccurs = Once;
                        XmlName = 'Audit';
                    }
                    tableelement("ASN Level 2 Line Scan Log"; "GXL ASN Level 2 Line Scan Log")
                    {
                        LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No.");
                        LinkTable = "ASN Level 1 Line Scan Log";
                        MinOccurs = Zero;
                        XmlName = 'ASNBoxLines';
                        SourceTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending);
                        fieldelement(LineNo; "ASN Level 2 Line Scan Log"."Line No.")
                        {

                            trigger OnAfterAssignField()
                            begin
                                "ASN Level 2 Line Scan Log".TestField("Line No.");
                            end;
                        }
                        fieldelement(SSCC; "ASN Level 2 Line Scan Log"."Level 2 Code")
                        {
                        }
                        fieldelement(ILC; "ASN Level 2 Line Scan Log".ILC)
                        {
                        }
                        fieldelement(Quantity; "ASN Level 2 Line Scan Log".Quantity)
                        {
                        }
                        fieldelement(QuantityReceived; "ASN Level 2 Line Scan Log"."Quantity Received")
                        {
                        }
                        textelement(boxaudit)
                        {
                            MaxOccurs = Once;
                            XmlName = 'Audit';
                        }
                        tableelement("ASN Level 3 Line Scan Log"; "GXL ASN Level 3 Line Scan Log")
                        {
                            LinkFields = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("Document No.");
                            LinkTable = "ASN Level 2 Line Scan Log";
                            MinOccurs = Zero;
                            XmlName = 'ASNItemLines';
                            SourceTableView = SORTING("Document Type", "Document No.", "Line No.") ORDER(Ascending);
                            fieldelement(LineNo; "ASN Level 3 Line Scan Log"."Line No.")
                            {

                                trigger OnAfterAssignField()
                                begin
                                    "ASN Level 3 Line Scan Log".TestField("Line No.");
                                end;
                            }
                            fieldelement(ILC; "ASN Level 3 Line Scan Log"."Level 3 Code")
                            {
                            }
                            textelement("<itemdescription>")
                            {
                                MaxOccurs = Once;
                                XmlName = 'ItemDescription';
                            }
                            textelement(GTIN)
                            {
                            }
                            fieldelement(Quantity; "ASN Level 3 Line Scan Log".Quantity)
                            {
                            }
                            fieldelement(QuantityReceived; "ASN Level 3 Line Scan Log"."Quantity Received")
                            {

                                trigger OnAfterAssignField()
                                begin
                                    if "ASN Level 3 Line Scan Log"."Quantity Received" < 0 then
                                        Error(
                                          StrSubstNo(
                                            Text000Txt, "ASN Level 3 Line Scan Log".FieldCaption("Quantity Received"), "ASN Level 3 Line Scan Log"."Line No."));
                                end;
                            }
                            textelement(itemaudit)
                            {
                                MinOccurs = Zero; //WMSVD-004
                                MaxOccurs = Once;
                                XmlName = 'Audit';
                            }

                            trigger OnAfterGetRecord()
                            var
                            begin
                            end;

                            trigger OnAfterInitRecord()
                            begin
                                "ASN Level 3 Line Scan Log"."Document Type" := "ASN Header Scan Log"."Document Type";
                                "ASN Level 3 Line Scan Log"."Document No." := "ASN Header Scan Log"."No.";
                            end;
                        }

                        trigger OnAfterInitRecord()
                        begin
                            "ASN Level 2 Line Scan Log"."Document Type" := "ASN Header Scan Log"."Document Type";
                            "ASN Level 2 Line Scan Log"."Document No." := "ASN Header Scan Log"."No.";
                        end;
                    }

                    trigger OnAfterInitRecord()
                    begin
                        "ASN Level 1 Line Scan Log"."Document Type" := "ASN Header Scan Log"."Document Type";
                        "ASN Level 1 Line Scan Log"."Document No." := "ASN Header Scan Log"."No.";
                    end;
                }

                trigger OnAfterInitRecord()
                begin
                    "ASN Header Scan Log"."EDI File Log Entry No." := EDIFileLogEntryNo;
                end;
            }
        }
    }


    var
        Text000Txt: Label '%1 has to be greater than zero in ASN Item Line %2.';
        EDIFileLogEntryNo: Integer;

    [Scope('OnPrem')]
    procedure SetEDIFileLogEntryNo(EDIFileLogEntryNoNew: Integer)
    begin
        EDIFileLogEntryNo := EDIFileLogEntryNoNew;
    end;
}

