xmlport 50064 "GXLEDI Inbound Scanned ASN CSV"
{
    // SBM - Import
    Caption = 'EDI Inbound Scanned ASN CSV';
    Format = VariableText;
    FormatEvaluate = Legacy;
    UseRequestPage = true;

    schema
    {
        textelement(InboundASN)
        {
            MaxOccurs = Once;
            tableelement(Integer; Integer)
            {
                XmlName = 'ASNHeader';
                textelement(ASNNumber)
                {
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
                textelement(PurchaseOrderNumber) // E
                {
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
                textelement(ASNPalletLineNo) // K
                {
                }
                textelement(ASNPalletLinesSSCC)
                {
                }
                textelement(ASNPalletLinesQuantity)
                {
                }
                textelement(ASNPalletLinesQuantityRec)
                {
                }
                textelement(PalletAudit) // O
                {
                }
                textelement(ASNBoxLineNo)
                {
                }
                textelement(ASNBoxLinesSSCC)
                {
                }
                textelement(ASNBoxLinesItems)
                {
                }
                textelement(ASNBoxLinesQtyShippedInOP)
                {
                }
                textelement(ASNBoxLinesQtyRec)
                {
                }
                textelement(BoxAudit)
                {
                }
                textelement(ASNItemLineNo)
                {
                }
                textelement(ASNItemLinesItems)
                {
                }
                textelement(ASNItemLinesDescription)
                {
                }
                textelement(ASNItemLinesGTIN)
                {
                }
                textelement(ASNItemLinesQtyShippedInUnit)
                {
                }
                textelement(ASNItemLinesQtyRec)
                {
                }
                textelement(ItemAudit)
                {
                    MinOccurs = Zero; //WMSVD-004
                }

                trigger OnBeforeInsertRecord()
                var
                    ASNLevel1Line: Record "GXL ASN Level 1 Line Scan Log";
                    ASNLevel2Line: Record "GXL ASN Level 2 Line Scan Log";
                    ASNLevel3Line: Record "GXL ASN Level 3 Line Scan Log";
                    EDIFunctionsLibrary: Codeunit "GXL EDI Functions Library";
                    DecASNItemLinesQtyShippedInUnit: Decimal;
                begin
                    Counter += 1;

                    DoInsertASN := false;
                    DoInsertPallet := false;

                    PalletLineNo := 0;
                    BoxLineNo := 0;
                    ItemLineNo := 0;

                    //header
                    if Counter = 1 then begin

                        DoInsertASN := true;
                        DoInsertPallet := true;

                        LastASNNumber := ASNNumber;
                        LastPalletSSCC := ASNPalletLinesSSCC;

                    end else begin
                        DoInsertASN := UpperCase(LastASNNumber) <> UpperCase(ASNNumber);
                        DoInsertPallet := UpperCase(LastPalletSSCC) <> UpperCase(ASNPalletLinesSSCC);
                    end;

                    if DoInsertASN then begin
                        ASNSanHeader.Init();
                        ASNSanHeader.Validate("Document Type", ASNSanHeader."Document Type"::Purchase);
                        ASNSanHeader.Validate("No.", ASNNumber);
                        ASNSanHeader.Validate("Purchase Order No.", PurchaseOrderNumber);
                        ASNSanHeader."EDI File Log Entry No." := EDIFileLogEntryNo;
                        ASNSanHeader.Insert(true);
                        LastASNNumber := ASNNumber;

                    end;

                    //pallet lines
                    if DoInsertPallet then begin
                        ASNLevel1Line.Init();
                        ASNLevel1Line.Validate("Document Type", ASNSanHeader."Document Type");
                        ASNLevel1Line.Validate("Document No.", ASNSanHeader."No.");
                        Evaluate(PalletLineNo, ASNPalletLineNo);
                        ASNLevel1Line.Validate("Line No.", PalletLineNo);
                        ASNLevel1Line.Validate("Level 1 Code", ASNPalletLinesSSCC);
                        ASNLevel1Line.Validate(Quantity, EDIFunctionsLibrary.GetDecimalFromText(ASNPalletLinesQuantity));
                        ASNLevel1Line.Validate("Quantity Received", EDIFunctionsLibrary.GetDecimalFromText(ASNPalletLinesQuantity));
                        ASNLevel1Line.Insert(true);
                        LastPalletSSCC := ASNPalletLinesSSCC;

                    end;

                    //box lines
                    ASNLevel2Line.Reset();
                    ASNLevel2Line.Init();
                    ASNLevel2Line.Validate("Document Type", ASNSanHeader."Document Type");
                    ASNLevel2Line.Validate("Document No.", ASNSanHeader."No.");
                    Evaluate(BoxLineNo, ASNBoxLineNo);
                    ASNLevel2Line.Validate("Level 1 Line No.", ASNLevel1Line."Line No.");
                    ASNLevel2Line.Validate("Line No.", BoxLineNo);
                    ASNLevel2Line.Validate("Level 2 Code", ASNBoxLinesSSCC);
                    ASNLevel2Line.Validate(ILC, ASNBoxLinesItems);
                    ASNLevel2Line.Validate(Quantity, EDIFunctionsLibrary.GetDecimalFromText(ASNBoxLinesQtyShippedInOP));
                    ASNLevel2Line.Validate("Quantity Received", EDIFunctionsLibrary.GetDecimalFromText(ASNBoxLinesQtyRec));
                    ASNLevel2Line.Insert(true);

                    //item lines
                    ASNLevel3Line.Init();
                    ASNLevel3Line.Validate("Document Type", ASNSanHeader."Document Type");
                    ASNLevel3Line.Validate("Document No.", ASNSanHeader."No.");
                    Evaluate(ItemLineNo, ASNItemLineNo);

                    ASNLevel3Line.Validate("Level 1 Line No.", PalletLineNo);
                    ASNLevel3Line.Validate("Level 2 Line No.", BoxLineNo);
                    ASNLevel3Line.Validate("Line No.", ItemLineNo);
                    ASNLevel3Line.Validate("Level 3 Code", ASNItemLinesItems);
                    Evaluate(DecASNItemLinesQtyShippedInUnit, ASNItemLinesQtyShippedInUnit);
                    ASNLevel3Line.Validate(Quantity, DecASNItemLinesQtyShippedInUnit);
                    ASNLevel3Line.Validate("Quantity Received", EDIFunctionsLibrary.GetDecimalFromText(ASNItemLinesQtyRec));
                    if ASNLevel3Line."Quantity Received" < 0 then
                        Error(
                          StrSubstNo(
                            Text000Txt, ASNLevel3Line.FieldCaption("Quantity Received"), ASNLevel3Line."Line No."));

                    ASNLevel3Line.Insert(true);
                    currXMLport.Skip();
                end;
            }
        }
    }


    var
        ASNSanHeader: Record "GXL ASN Header Scan Log";
        LastASNNumber: Code[20];
        LastPalletSSCC: Code[50];
        DoInsertASN: Boolean;
        DoInsertPallet: Boolean;
        Counter: Integer;
        PalletLineNo: Integer;
        BoxLineNo: Integer;
        ItemLineNo: Integer;
        EDIFileLogEntryNo: Integer;
        Text000Txt: Label '%1 has to be greater than zero in ASN Item Line %2.';

    [Scope('OnPrem')]
    procedure SetEDIFileLogEntryNo(EDIFileLogEntryNoNew: Integer)
    begin
        EDIFileLogEntryNo := EDIFileLogEntryNoNew;
    end;
}

