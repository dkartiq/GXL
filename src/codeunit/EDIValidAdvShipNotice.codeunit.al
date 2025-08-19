// 002 23.06.2025 KDU HP2-Sprint1-Changes
// 001 29.11.2024  SKY  LCB-203 https://petbarnjira.atlassian.net/browse/LCB-203 
codeunit 50372 "GXL EDI-Valid Adv Ship. Notice"
{

    TableNo = "GXL ASN Header";

    trigger OnRun()
    var
        ASNLevel3LineTemp: Record "GXL ASN Level 3 Line" temporary;
    begin
        ASNHeader := Rec;

        //PS-2428+
        CheckIfASNIsP2PContingency();
        //PS-2428-

        //ASN Mandatory Fields check (if not blank)
        ValidateMandatoryASNHeader();

        //Missing mandatory fields.
        //level 2 and level 3 lines cannot have mandatory fields per se as they could be carrying blank values to cater for loose items / items only in boxes requirement
        ValidateMandatoryPalletBoxLines();

        ValidateDuplication();
        //ASN Format Check
        ValidateASNItemLines(ASNLevel3LineTemp);

        //TODO: EDI File log
        if ASNHeader."EDI File Log Entry No." = 0 then
            ASNHeader.AddEDIFileLog();

        //Accept | Reject ASN Check
        AcceptRejectASN(ASNLevel3LineTemp);

        //if error happens in validating, trap the error and if it's a lockng error we need to
        //delete the staging POR we created and throw the locking error so that the handler
        //can keep the ASN in Imported status
        //if error happens in processing,trap the error and if it's a lockng error we need to
        //delete the staging POR we created and throw the locking error so that the handler
        //can keep the ASN in Imported status

        //we throw error as 'POR ERROR - lkadjhvfkajsdhf'

        //purchase header Last EDI Document Status set to
        //update ASN header
        ASNHeader.VALIDATE(Status, ASNHeader.Status::Validated);
        ASNHeader.MODIFY();

        Rec := ASNHeader;
    end;

    var
        ASNHeader: Record "GXL ASN Header";
        PurchHeader: Record "Purchase Header";
        SKU: Record "Stockkeeping Unit";
        EDIFunctionLib: Codeunit "GXL EDI Functions Library";
        EDIProcessMgmt: Codeunit "GXL EDI Process Mngt";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        OuterPackShipment: Boolean;
        Text000Txt: Label '%1 must have a value. It cannot be zero or blank.';
        Text001Txt: Label 'ASN must have Item lines.';
        Text002Txt: Label '%1 %2 must be packed in a box or a pallet.';
        Text003Txt: Label '%1 %2 must have a Box line. ';
        Text004Txt: Label 'Carton line %1 must have a %2 because it contains items. ';
        Text005Txt: Label 'Carton line %1 %2 has to be the same as that on the Item line. Carton %2 = %3. Item %4 = %5.';
        Text006Txt: Label '%1 %2 must have a Pallet line.';
        Text007Txt: Label 'Pallet line %1 must have a %2 because it contains items.';
        Text008Txt: Label '%1 cannot be less than %2 on ASN Item Line %3.';
        Text009Txt: Label 'Purchase Order for ASN %1 doesn''t exist.';
        Text010Txt: Label '%1 on %2 must be the same as %3 on Purchase Order. ASN value: %4. Purchase Order value: %5.';
        Text011Txt: Label '%1 on %2 must match the counted value. ASN value: %3. Counted value: %4.';
        Text012Txt: Label '%1 on ASN Item Line must be less than or equal to %2 on Purchase Line. ASN Item Line value: %3. Purchase Line value: %4.';
        Text013Txt: Label 'Item %1 doesn''t exist in Purchase Order %2.';
        Text014Txt: Label 'Purchase Order %1 has been cancelled.';
        Text015Txt: Label 'SSCC %1 is a duplicate.';
        Text016Txt: Label 'ASN file structure must have Box lines.';
        Text017Txt: Label 'ASN file structure must have Pallet lines.';
        Text018Txt: Label 'There is already a valid ASN for Purchase Order %1.';
        Text019Txt: Label '%1 must have a value on ASN Item Line %2.';
        Text020Txt: Label 'ASN cannot be accepted for Purchase Order %3 where %1 = %2.';
        Text021Txt: Label '%1 cannot be less than %2 on ASN Pallet Line %3.';
        Text022Txt: Label '%1 on ASN Pallet Line must match the counted value (boxes + quantity of loose items). Pallet SSCC: %2. ASN value: %3. Counted value: %4.';
        Text023Txt: Label 'There is already a valid ASN Number %1 for supplier %2.';

    local procedure ValidateMandatoryASNHeader()
    begin
        // >> 002
        if ASNHeader."Original EDI Document No." = '' then begin
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ASNHeader.FIELDCAPTION("Original EDI Document No.")));
            EDIErrorMgt.ThrowErrorMessage();
        end;
        // << 002

        IF ASNHeader."No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ASNHeader.FIELDCAPTION("No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;
        //TODO: temporarily removed as ASN Header is imported from NAV 13
        // >> HP2-Spriny2
        IF ASNHeader."Original EDI Document No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ASNHeader.FIELDCAPTION("Original EDI Document No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;
        // << HP2-Spriny2

        IF ASNHeader."Supplier Reference Date" = 0D THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ASNHeader.FIELDCAPTION("Supplier Reference Date")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF ASNHeader."Supplier No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ASNHeader.FIELDCAPTION("Supplier No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END;
        IF ASNHeader."Purchase Order No." = '' THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ASNHeader.FIELDCAPTION("Purchase Order No.")));
            EDIErrorMgt.ThrowErrorMessage();
        END ELSE BEGIN
            IF NOT PurchHeader.GET(PurchHeader."Document Type"::Order, ASNHeader."Purchase Order No.") THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text009Txt, ASNHeader."No."));
                EDIErrorMgt.ThrowErrorMessage();
            END ELSE
                IF PurchHeader."GXL EDI Order in Out. Pack UoM" THEN
                    OuterPackShipment := TRUE;
        END;

        IF ASNHeader."Expected Receipt Date" = 0D THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text000Txt, ASNHeader.FIELDCAPTION("Expected Receipt Date")));
            EDIErrorMgt.ThrowErrorMessage();
        END;

    end;

    local procedure ValidateMandatoryPalletBoxLines()
    var
        ASNLevel1Line: Record "GXL ASN Level 1 Line";
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
    begin
        ASNLevel1Line.SETRANGE("Document Type", ASNHeader."Document Type");
        ASNLevel1Line.SETRANGE("Document No.", ASNHeader."No.");

        IF ASNLevel1Line.ISEMPTY() THEN BEGIN
            EDIErrorMgt.SetErrorMessage(Text017Txt);
            EDIErrorMgt.ThrowErrorMessage()
        END;

        ASNLevel2Line.SETRANGE("Document Type", ASNHeader."Document Type");
        ASNLevel2Line.SETRANGE("Document No.", ASNHeader."No.");

        IF ASNLevel2Line.ISEMPTY() THEN BEGIN
            EDIErrorMgt.SetErrorMessage(Text016Txt);
            EDIErrorMgt.ThrowErrorMessage();
        END;
    end;

    local procedure ValidateASNItemLines(var ASNLevel3LineTemp: Record "GXL ASN Level 3 Line" temporary)
    var
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
        ASNLevel1Line: Record "GXL ASN Level 1 Line";
        PurchLine: Record "Purchase Line";
        OldGTIN: Code[30];
        ASNLevel3LineTempLineNo: Integer;
        DocumentType: Option ,PO,POX,POR,ASN,INV;
        // >> 001
        ASNLevel3Qty: Decimal;
        ASNLevel2Qty: Decimal;
    // << 001
    begin
        //All items contained in the cartons on the pallet - as many item lines are expected as different items in cartons
        //Loose items in an ASN with no pallet line (no SSCC for a pallet in ASN)

        IF OuterPackShipment THEN BEGIN
            PurchLine.SETCURRENTKEY("Document Type", "Document No.", Type, "No.");
            PurchLine.SETRANGE("Document Type", PurchLine."Document Type"::Order);
            PurchLine.SETRANGE("Document No.", PurchHeader."No.");
            PurchLine.SETRANGE(Type, PurchLine.Type::Item);
        END;

        ASNLevel3Line.SETRANGE("Document Type", ASNHeader."Document Type");
        ASNLevel3Line.SETRANGE("Document No.", ASNHeader."No.");

        IF ASNLevel3Line.FINDSET() THEN BEGIN

            ASNLevel3LineTempLineNo := 0;

            REPEAT

                IF ASNLevel3Line."Level 3 Code" = '' THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text019Txt,
                        ASNLevel3Line.FIELDCAPTION("Level 3 Code"),
                        ASNLevel3Line."Line No."));

                    EDIErrorMgt.ThrowErrorMessage();
                END;

                IF ASNLevel3Line.GTIN = '' THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text019Txt,
                        ASNLevel3Line.FIELDCAPTION(GTIN),
                        ASNLevel3Line."Line No."));

                    EDIErrorMgt.ThrowErrorMessage();
                END;

                IF ASNLevel3Line.Quantity < 0 THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(
                        Text008Txt,
                        ASNLevel3Line.FIELDCAPTION(Quantity),
                        0,
                        ASNLevel3Line."Line No."));

                    EDIErrorMgt.ThrowErrorMessage();
                END;

                //item not linked to a box nor a pallet
                IF (ASNLevel3Line."Level 2 Line No." = 0) AND (ASNLevel3Line."Level 1 Line No." = 0) THEN BEGIN
                    EDIErrorMgt.SetErrorMessage(
                      STRSUBSTNO(Text002Txt, ASNLevel3Line.FIELDCAPTION("Level 3 Code"), ASNLevel3Line."Level 3 Code"));

                    EDIErrorMgt.ThrowErrorMessage();
                END;

                if ASNLevel3Line."Carton Quantity" = 0 then //ERP-247 <<
                    ASNLevel3Line."Carton Quantity" := ASNLevel3Line.Quantity;

                //Legacy Item
                //Will populate Item No. and Unit of Measure Code from Legacy Item No. which is Level 3 Code
                if (ASNLevel3Line."Level 3 Code" <> '') and (ASNLevel3Line."Item No." = '') then
                    LegacyItemHelpers.GetItemNoForPurchase(ASNLevel3Line."Level 3 Code", ASNLevel3Line."Item No.", ASNLevel3Line."Unit of Measure Code");

                IF OuterPackShipment THEN BEGIN
                    // Convert Quantity on ASN Item Line to Ordering UoM
                    //Legacy Item
                    //IF SKU.GET(ASNHeader."Ship-To Code", ASNLevel3Line."Level 3 Code", '') THEN
                    if SKU.Get(ASNHeader."Ship-To Code", ASNLevel3Line."Item No.", '') then
                        // >> LCB-203   
                        //ASNLevel3Line.Quantity := EDIFunctionLib.ConvertQty_ShippingUnitToOrderUnit_VendorOPFlag(PurchHeader."GXL EDI Order in Out. Pack UoM", SKU, ASNLevel3Line."Carton Quantity");
                        // >> 001 
                        //ASNLevel3Line.Quantity := EDIFunctionLib.ConvertQty_ShippingUnitToOrderUnit_VendorOPFlag(PurchHeader."GXL EDI Order in Out. Pack UoM", SKU, ASNLevel3Line."Carton Quantity", PurchHeader."Buy-from Vendor No.");

                        ASNLevel3Qty := EDIFunctionLib.ConvertQty_ShippingUnitToOrderUnit_VendorOPFlag(PurchHeader."GXL EDI Order in Out. Pack UoM", SKU, ASNLevel3Line."Carton Quantity", PurchHeader."Buy-from Vendor No.");
                    IF ASNLevel3Qty <> 0 THEN
                        ASNLevel3Line.Quantity := ASNLevel3Qty;
                    // << 001
                    // << LCB-203

                    // Update vendor's GTIN with the Primary EAN
                    //Legacy Item
                    //PurchLine.SETRANGE("No.", ASNLevel3Line."Level 3 Code");
                    PurchLine.SetRange("GXL Legacy Item No.", ASNLevel3Line."Level 3 Code");
                    IF PurchLine.FINDFIRST() THEN
                        ASNLevel3Line.GTIN := PurchLine."GXL Primary EAN";
                END;
                ASNLevel3Line.MODIFY();

                // Update carton quantity on loose item virtual Box Line (Box without an SSCC No. to denote that a physical box doesn't exist)
                IF ASNLevel3Line."Loose Item Box Line" <> 0 THEN
                    IF ASNLevel2Line.GET(ASNLevel3Line."Document Type", ASNLevel3Line."Document No.", ASNLevel3Line."Loose Item Box Line") THEN BEGIN
                        ASNLevel2Line."Carton Quantity" := ASNLevel2Line.Quantity;
                        IF (OuterPackShipment) //AND
                                               //(SKU.GET(ASNHeader."Ship-To Code", ASNLevel2Line.ILC, ''))
                        THEN begin
                            //Legacy Item                            
                            if (ASNLevel2Line.ILC <> '') and (ASNLevel2Line."Item No." = '') then
                                LegacyItemHelpers.GetItemNoForPurchase(ASNLevel2Line.ILC, ASNLevel2Line."Item No.", ASNLevel2Line."Unit of Measure Code");
                            if SKU.Get(ASNHeader."Ship-To Code", ASNLevel2Line."Item No.", '') then
                                // >> LCB-203 
                                //ASNLevel2Line.Quantity := EDIFunctionLib.ConvertQty_ShippingUnitToOrderUnit_VendorOPFlag(PurchHeader."GXL EDI Order in Out. Pack UoM", SKU, ASNLevel2Line."Carton Quantity");
                                // >> 001
                                //ASNLevel2Line.Quantity := EDIFunctionLib.ConvertQty_ShippingUnitToOrderUnit_VendorOPFlag(PurchHeader."GXL EDI Order in Out. Pack UoM", SKU, ASNLevel2Line."Carton Quantity", PurchHeader."Buy-from Vendor No.");
                                ASNLevel2Qty := EDIFunctionLib.ConvertQty_ShippingUnitToOrderUnit_VendorOPFlag(PurchHeader."GXL EDI Order in Out. Pack UoM", SKU, ASNLevel2Line."Carton Quantity", PurchHeader."Buy-from Vendor No.");
                            IF ASNLevel2Qty <> 0 then
                                ASNLevel2Line.Quantity := ASNLevel2Qty;
                            // << 001
                            // << LCB-203 
                        end;
                        ASNLevel2Line.MODIFY();
                    END;

                //if item's in a box, then the box must have mandatory fields
                IF ASNLevel3Line."Level 2 Line No." <> 0 THEN BEGIN
                    IF NOT ASNLevel2Line.GET(ASNLevel3Line."Document Type", ASNLevel3Line."Document No.", ASNLevel3Line."Level 2 Line No.") THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(Text003Txt, ASNLevel3Line.FIELDCAPTION("Level 3 Code"), ASNLevel3Line."Level 3 Code"));

                        EDIErrorMgt.ThrowErrorMessage();
                    END ELSE BEGIN
                        //box must have SSCC
                        IF ASNLevel2Line."Level 2 Code" = '' THEN BEGIN
                            EDIErrorMgt.SetErrorMessage(
                              STRSUBSTNO(Text004Txt, ASNLevel2Line."Line No.", ASNLevel2Line.FIELDCAPTION("Level 2 Code")));

                            EDIErrorMgt.ThrowErrorMessage();
                        END;

                        //box must have ILC and it must be the item no. in the box and in NAV
                        IF (ASNLevel2Line.ILC = '') OR (ASNLevel2Line.ILC <> ASNLevel3Line."Level 3 Code") THEN BEGIN
                            EDIErrorMgt.SetErrorMessage(
                              STRSUBSTNO(
                                Text005Txt,
                                ASNLevel2Line."Line No.",
                                ASNLevel2Line.FIELDCAPTION(ILC),
                                ASNLevel2Line.ILC,
                                ASNLevel3Line.FIELDCAPTION("Level 3 Code"),
                                ASNLevel3Line."Level 3 Code"));

                            EDIErrorMgt.ThrowErrorMessage();
                        END;

                        ASNLevel2Line."Carton Quantity" := ASNLevel2Line.Quantity;
                        IF (OuterPackShipment) //AND
                                               //(SKU.GET(ASNHeader."Ship-To Code", ASNLevel2Line.ILC, ''))
                        THEN begin
                            //Legacy Item
                            if (ASNLevel2Line.ILC <> '') and (ASNLevel2Line."Item No." = '') then
                                if (ASNLevel2Line.ILC = ASNLevel3Line."Level 3 Code") then begin
                                    ASNLevel2Line."Item No." := ASNLevel3Line."Item No.";
                                    ASNLevel2Line."Unit of Measure Code" := ASNLevel3Line."Unit of Measure Code";
                                end else
                                    LegacyItemHelpers.GetItemNoForPurchase(ASNLevel2Line.ILC, ASNLevel2Line."Item No.", ASNLevel2Line."Unit of Measure Code");
                            if SKU.Get(ASNHeader."Ship-To Code", ASNLevel2Line."Item No.", '') then
                                // >> LCB-203  
                                //ASNLevel2Line.Quantity := EDIFunctionLib.ConvertQty_ShippingUnitToOrderUnit_VendorOPFlag(PurchHeader."GXL EDI Order in Out. Pack UoM", SKU, ASNLevel2Line."Carton Quantity");
                                // >> 001
                                //ASNLevel2Line.Quantity := EDIFunctionLib.ConvertQty_ShippingUnitToOrderUnit_VendorOPFlag(PurchHeader."GXL EDI Order in Out. Pack UoM", SKU, ASNLevel2Line."Carton Quantity", PurchHeader."Buy-from Vendor No.");

                                ASNLevel2Qty := EDIFunctionLib.ConvertQty_ShippingUnitToOrderUnit_VendorOPFlag(PurchHeader."GXL EDI Order in Out. Pack UoM", SKU, ASNLevel2Line."Carton Quantity", PurchHeader."Buy-from Vendor No.");

                            IF ASNLevel2Qty <> 0 then
                                ASNLevel2Line.Quantity := ASNLevel2Qty;
                            // << 001
                            // << LCB-203
                        end;
                        ASNLevel2Line.MODIFY();

                        //box must have quantity equal to the quantity if the item in the box

                        IF ASNLevel2Line."Carton Quantity" <> ASNLevel3Line."Carton Quantity" THEN BEGIN
                            EDIErrorMgt.SetErrorMessage(
                              STRSUBSTNO(
                                Text005Txt,
                                ASNLevel2Line."Line No.",
                                ASNLevel2Line.FIELDCAPTION(Quantity),
                                ASNLevel2Line."Carton Quantity",
                                ASNLevel3Line.FIELDCAPTION(Quantity),
                                ASNLevel3Line."Carton Quantity"));

                            EDIErrorMgt.ThrowErrorMessage();
                        END;
                    END;
                END;

                //if item's loose in a pallet, then pallet line must have mandatory fields
                IF ASNLevel3Line."Level 1 Line No." <> 0 THEN BEGIN
                    IF NOT ASNLevel1Line.GET(ASNLevel3Line."Document Type", ASNLevel3Line."Document No.", ASNLevel3Line."Level 1 Line No.") THEN BEGIN

                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(Text006Txt, ASNLevel3Line.FIELDCAPTION("Level 3 Code"), ASNLevel3Line."Level 3 Code"));

                        EDIErrorMgt.ThrowErrorMessage();
                    END ELSE BEGIN
                        //pallet line must have SSCC if it contains loose items
                        IF ASNLevel1Line."Level 1 Code" = '' THEN BEGIN
                            EDIErrorMgt.SetErrorMessage(
                              STRSUBSTNO(Text007Txt, ASNLevel1Line."Line No.", ASNLevel1Line.FIELDCAPTION("Level 1 Code")));

                            EDIErrorMgt.ThrowErrorMessage();
                        END;

                        //pallet line must have quantity if it contains loose items - doesn't have to be equal to item quantity as it may contain other boxes
                        IF ASNLevel1Line.Quantity < 0 THEN BEGIN
                            EDIErrorMgt.SetErrorMessage(
                              STRSUBSTNO(Text007Txt, ASNLevel1Line."Line No.", ASNLevel1Line.FIELDCAPTION(Quantity)));

                            EDIErrorMgt.ThrowErrorMessage();
                        END;

                    END;

                END;

                UpdateASNItemLineBuffer(ASNLevel3LineTemp, ASNLevel3Line, ASNLevel3LineTempLineNo);
                OldGTIN := '';
                OldGTIN := EDIFunctionLib.ValidateGTIN(ASNLevel3Line."Level 3 Code", ASNHeader."Supplier No.", ASNLevel3Line.GTIN);

                IF EDIFunctionLib.GTINIsChangedOrNew() THEN //GTINisChangedOrNew means its either a new gtin or an overwritten one
                    IF OldGTIN <> '' THEN
                        EDIFunctionLib.InsertItemSupplierGTINBuffer(DocumentType::ASN, ASNLevel3Line."Document No.", ASNLevel3Line."Line No.", OldGTIN, ASNLevel3Line.GTIN, TRUE)
                    ELSE
                        EDIFunctionLib.InsertItemSupplierGTINBuffer(DocumentType::ASN, ASNLevel3Line."Document No.", ASNLevel3Line."Line No.", OldGTIN, ASNLevel3Line.GTIN, FALSE);

            UNTIL ASNLevel3Line.NEXT() = 0;

        END ELSE BEGIN
            EDIErrorMgt.SetErrorMessage(Text001Txt);
            EDIErrorMgt.ThrowErrorMessage();
        END;

    end;

    local procedure UpdateASNItemLineBuffer(var ASNLevel3LineTemp: Record "GXL ASN Level 3 Line" temporary; InputASNLevel3Line: Record "GXL ASN Level 3 Line"; var ASNLevel3LineTempLineNo: Integer)
    begin
        ASNLevel3LineTemp.RESET();
        ASNLevel3LineTemp.SETRANGE("Document Type", InputASNLevel3Line."Document Type");
        ASNLevel3LineTemp.SETRANGE("Document No.", InputASNLevel3Line."Document No.");
        ASNLevel3LineTemp.SETRANGE("Level 3 Type", InputASNLevel3Line."Level 3 Type");
        ASNLevel3LineTemp.SETRANGE("Level 3 Code", InputASNLevel3Line."Level 3 Code");

        IF ASNLevel3LineTemp.FINDFIRST() THEN BEGIN

            ASNLevel3LineTemp.Quantity += InputASNLevel3Line.Quantity;
            ASNLevel3LineTemp."Carton Quantity" += InputASNLevel3Line."Carton Quantity";
            ASNLevel3LineTemp.MODIFY();

        END ELSE BEGIN

            ASNLevel3LineTempLineNo += 10000;

            ASNLevel3LineTemp.INIT();

            ASNLevel3LineTemp."Document Type" := InputASNLevel3Line."Document Type";
            ASNLevel3LineTemp."Document No." := InputASNLevel3Line."Document No.";
            ASNLevel3LineTemp."Line No." := ASNLevel3LineTempLineNo;
            ASNLevel3LineTemp."Level 3 Type" := InputASNLevel3Line."Level 3 Type";
            ASNLevel3LineTemp."Level 3 Code" := InputASNLevel3Line."Level 3 Code";
            ASNLevel3LineTemp.Quantity := InputASNLevel3Line.Quantity;
            ASNLevel3LineTemp."Carton Quantity" := InputASNLevel3Line."Carton Quantity";
            ASNLevel3LineTemp.GTIN := InputASNLevel3Line.GTIN;

            //Legacy item
            ASNLevel3LineTemp."Item No." := InputASNLevel3Line."Item No.";
            ASNLevel3LineTemp."Unit of Measure Code" := InputASNLevel3Line."Unit of Measure Code";

            ASNLevel3LineTemp.INSERT();

        END;
    end;

    local procedure AcceptRejectASN(var ASNLevel3LineTemp: Record "GXL ASN Level 3 Line" temporary)
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        ASNLevel1Line: Record "GXL ASN Level 1 Line";
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
        OrderStatusMgmt: Codeunit "GXL SC-Purch. Order Status Mgt";
        PalletCount: Integer;
        CartonCount: Integer;
        CalculatedPalletQuantity: Decimal;
    begin
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, ASNHeader."Purchase Order No.") THEN BEGIN

            //TODO: Order Status - EDI Validate ASN, accept or reject ASN
            //ASN received for a cancelled PO will be rejected. (ASN received after the cancellation of the PO)
            IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Cancelled THEN BEGIN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text014Txt, PurchaseHeader."No."));

                EDIErrorMgt.ThrowErrorMessage();
            END;

            //reject if subsequent to a valid ASN
            PurchaseHeader.CALCFIELDS("GXL ASN Created", "GXL ASN Number");
            IF PurchaseHeader."GXL ASN Created" AND (ASNHeader."No." <> PurchaseHeader."GXL ASN Number") THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text018Txt,
                    PurchaseHeader."No."));

                EDIErrorMgt.ThrowErrorMessage();
            END;

            //reject if PO or POX hasn't been sent or if it's coming after INV has been received
            //TODO: PO,POX,POR - Temporary comment out the condition as PO and POR are not applicable in this phase
            IF (PurchaseHeader."GXL Last EDI Document Status" = PurchaseHeader."GXL Last EDI Document Status"::" ") OR // >> HP2-Spriny2 <<
             (PurchaseHeader."GXL Last EDI Document Status" >= PurchaseHeader."GXL Last EDI Document Status"::ASN)
            THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text020Txt,
                    PurchaseHeader.FIELDCAPTION("GXL Last EDI Document Status"),
                    PurchaseHeader."GXL Last EDI Document Status",
                    PurchaseHeader."No."));

                EDIErrorMgt.ThrowErrorMessage();
            END;
            //ASN mandatory fields not matching the PO lines
            //Any other mandatory fields not matching the PO (other than quantities)

            IF ASNHeader."Supplier No." <> PurchaseHeader."Buy-from Vendor No." THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text010Txt,
                    ASNHeader.FIELDCAPTION("Supplier No."),
                    ASNHeader.TABLECAPTION(),
                    PurchaseHeader.FIELDCAPTION("Buy-from Vendor No."),
                    ASNHeader."Supplier No.",
                    PurchaseHeader."Buy-from Vendor No."));

                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF ASNHeader."Ship-To Code" <> PurchaseHeader."Location Code" THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text010Txt,
                    ASNHeader.FIELDCAPTION("Ship-To Code"),
                    ASNHeader.TABLECAPTION(),
                    PurchaseHeader.FIELDCAPTION("Location Code"),
                    ASNHeader."Ship-To Code",
                    PurchaseHeader."Location Code"));

                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF ASNHeader."Ship-for Code" <> PurchaseHeader."Location Code" THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text010Txt,
                    ASNHeader.FIELDCAPTION("Ship-for Code"),
                    ASNHeader.TABLECAPTION(),
                    PurchaseHeader.FIELDCAPTION("Location Code"),
                    ASNHeader."Ship-for Code",
                    PurchaseHeader."Location Code"));

                EDIErrorMgt.ThrowErrorMessage();
            END;

            PalletCount := GetPalletCount();
            CartonCount := GetCartonCount();

            //%1 on %2 must match the counted value. ASN value: %3. Counted value: %4.
            IF ASNHeader."Total Pallets" <> PalletCount THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text011Txt,
                    ASNHeader.FIELDCAPTION("Total Pallets"),
                    ASNHeader.TABLECAPTION(),
                    ASNHeader."Total Pallets",
                    PalletCount));

                EDIErrorMgt.ThrowErrorMessage();
            END;

            IF ASNHeader."Total Boxes" <> CartonCount THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text011Txt,
                    ASNHeader.FIELDCAPTION("Total Boxes"),
                    ASNHeader.TABLECAPTION(),
                    ASNHeader."Total Boxes",
                    CartonCount));

                EDIErrorMgt.ThrowErrorMessage();
            END;

            //ASN with duplicate SSCC labels. An SSCC label will be checked against SSCC labels received in the past for POs which are still in the system and not Closed.
            ASNLevel1Line.SETRANGE("Document Type", ASNHeader."Document Type");
            ASNLevel1Line.SETRANGE("Document No.", ASNHeader."No.");

            IF ASNLevel1Line.FINDSET() THEN
                REPEAT

                    //check count on the Pallet line: has to be equal to count of boxes + quantity of loose items
                    IF ASNLevel1Line."Level 1 Code" <> '' THEN BEGIN
                        IF ASNLevel1Line.Quantity < 0 THEN BEGIN
                            EDIErrorMgt.SetErrorMessage(
                              STRSUBSTNO(
                                Text021Txt,
                                ASNLevel1Line.FIELDCAPTION(Quantity),
                                0,
                                ASNLevel1Line."Line No."));

                            EDIErrorMgt.ThrowErrorMessage();
                        END ELSE BEGIN
                            CalculatedPalletQuantity := GetCalculatedPalletQuantity(ASNLevel1Line);

                            IF ASNLevel1Line."Carton Quantity" <> CalculatedPalletQuantity THEN BEGIN
                                EDIErrorMgt.SetErrorMessage(
                                  STRSUBSTNO(
                                    Text022Txt,
                                    ASNLevel1Line.FIELDCAPTION(Quantity),
                                    ASNLevel1Line."Level 1 Code",
                                    ASNLevel1Line."Carton Quantity",
                                    CalculatedPalletQuantity));

                                EDIErrorMgt.ThrowErrorMessage();
                            END;
                        END;
                    END;

                    IF PalletSCCCDuplicate(ASNLevel1Line) THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text015Txt, ASNLevel1Line."Level 1 Code"));
                        EDIErrorMgt.ThrowErrorMessage();
                    END;

                UNTIL ASNLevel1Line.NEXT() = 0;

            ASNLevel2Line.SETRANGE("Document Type", ASNHeader."Document Type");
            ASNLevel2Line.SETRANGE("Document No.", ASNHeader."No.");

            IF ASNLevel2Line.FINDSET() THEN
                REPEAT

                    IF BoxSCCCDuplicate(ASNLevel2Line) THEN BEGIN
                        EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text015Txt, ASNLevel2Line."Level 2 Code"));
                        EDIErrorMgt.ThrowErrorMessage();
                    END;

                UNTIL ASNLevel2Line.NEXT() = 0;


            //Quantity on ASN can be changed - may be equal or less than quantity on PO.
            //cannot be grater than that on the PO
            ASNLevel3LineTemp.RESET();
            IF ASNLevel3LineTemp.FINDSET() THEN
                REPEAT

                    PurchaseLine.RESET();

                    PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
                    PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
                    PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
                    //Legacy item
                    //PurchaseLine.SETRANGE("No.", ASNLevel3LineTemp."Level 3 Code");
                    PurchaseLine.SetRange("GXL Legacy Item No.", ASNLevel3LineTemp."Level 3 Code");
                    IF PurchaseLine.FINDFIRST() THEN BEGIN

                        //Quantity on ASN can be changed - may be equal or less than quantity on PO.
                        //cannot be grater than that on the PO
                        IF ASNLevel3LineTemp.Quantity > PurchaseLine.Quantity THEN BEGIN
                            EDIErrorMgt.SetErrorMessage(
                              STRSUBSTNO(
                                Text012Txt,
                                ASNLevel3LineTemp.FIELDCAPTION(Quantity),
                                PurchaseLine.FIELDCAPTION(Quantity),
                                ASNLevel3LineTemp.Quantity,
                                PurchaseLine.Quantity));

                            EDIErrorMgt.ThrowErrorMessage();
                        END;

                    END ELSE BEGIN
                        //Less item lines in ASN than PO lines are accepted: missing lines means those lines have not been shipped
                        //this one check if there is any item on ASN which is not on PO
                        EDIErrorMgt.SetErrorMessage(
                          STRSUBSTNO(Text013Txt, ASNLevel3LineTemp."Level 3 Code", PurchaseHeader."No."));

                        EDIErrorMgt.ThrowErrorMessage();
                    END;

                UNTIL ASNLevel3LineTemp.NEXT() = 0;

            //create POR if no POR is there
            IF PurchaseHeader."GXL EDI Order" THEN
                CreatePOR();      // Calls ConfirmPurchHeader function which sets Order Status = Confirmed and has a COMMIT
            PurchaseHeader.RESET();
            IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, ASNHeader."Purchase Order No.") THEN BEGIN
                //TODO: Order Status - EDI validate ASN, confirm the order
                IF PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Placed THEN BEGIN // >> HP2-Spriny2 <<
                                                                                                            //TODO: temporarily do confirm when status is less than confirmed
                    if PurchaseHeader."GXL Order Status" < PurchaseHeader."GXL Order Status"::Confirmed then begin
                        OrderStatusMgmt.ConfirmPurchHeader(PurchaseHeader);      //ConfirmPurchHeader function has a COMMIT
                        PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, ASNHeader."Purchase Order No.");  // Read record again as previous function call has a COMMIT
                    END;

                    PurchaseHeader."GXL Last EDI Document Status" := PurchaseHeader."GXL Last EDI Document Status"::ASN;
                    PurchaseHeader.MODIFY();
                END;
            end;
            //this needs to be moved into the Run trigger after the POR handling has finished
        END ELSE BEGIN

            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text009Txt, ASNHeader."No."));
            EDIErrorMgt.ThrowErrorMessage();

        END;

    end;

    local procedure GetPalletCount(): Integer
    var
        ASNLevel1Line: Record "GXL ASN Level 1 Line";
        TempASNLevel1Line: Record "GXL ASN Level 1 Line" temporary;
    begin
        ASNLevel1Line.SETRANGE("Document Type", ASNHeader."Document Type");
        ASNLevel1Line.SETRANGE("Document No.", ASNHeader."No.");
        ASNLevel1Line.SETRANGE("Level 1 Type", ASNLevel1Line."Level 1 Type"::Pallet);
        ASNLevel1Line.SETFILTER("Level 1 Code", '<>%1', '');
        IF ASNLevel1Line.FINDSET() THEN
            REPEAT
                TempASNLevel1Line.RESET();
                TempASNLevel1Line.SETRANGE("Document Type", ASNHeader."Document Type");
                TempASNLevel1Line.SETRANGE("Document No.", ASNHeader."No.");
                TempASNLevel1Line.SETRANGE("Level 1 Type", TempASNLevel1Line."Level 1 Type"::Pallet);
                TempASNLevel1Line.SETRANGE("Level 1 Code", ASNLevel1Line."Level 1 Code");
                IF TempASNLevel1Line.ISEMPTY() THEN BEGIN
                    TempASNLevel1Line.RESET();
                    TempASNLevel1Line.INIT();
                    TempASNLevel1Line.TRANSFERFIELDS(ASNLevel1Line);
                    TempASNLevel1Line.INSERT();
                END;
            UNTIL ASNLevel1Line.NEXT() = 0;

        TempASNLevel1Line.RESET();
        EXIT(TempASNLevel1Line.COUNT());
    end;

    local procedure GetCartonCount(): Integer
    var
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
        TempASNLevel2Line: Record "GXL ASN Level 2 Line" temporary;
    begin
        ASNLevel2Line.SETRANGE("Document Type", ASNHeader."Document Type");
        ASNLevel2Line.SETRANGE("Document No.", ASNHeader."No.");
        ASNLevel2Line.SETRANGE("Level 2 Type", ASNLevel2Line."Level 2 Type"::Box);
        ASNLevel2Line.SETFILTER("Level 2 Code", '<>%1', '');
        IF ASNLevel2Line.FINDSET() THEN
            REPEAT
                TempASNLevel2Line.RESET();
                TempASNLevel2Line.SETRANGE("Document Type", ASNHeader."Document Type");
                TempASNLevel2Line.SETRANGE("Document No.", ASNHeader."No.");
                TempASNLevel2Line.SETRANGE("Level 2 Type", ASNLevel2Line."Level 2 Type"::Box);
                TempASNLevel2Line.SETRANGE("Level 2 Code", ASNLevel2Line."Level 2 Code");
                IF TempASNLevel2Line.ISEMPTY() THEN BEGIN
                    TempASNLevel2Line.RESET();
                    TempASNLevel2Line.INIT();
                    TempASNLevel2Line.TRANSFERFIELDS(ASNLevel2Line);
                    TempASNLevel2Line.INSERT();
                END;
            UNTIL ASNLevel2Line.NEXT() = 0;

        TempASNLevel2Line.RESET();
        EXIT(TempASNLevel2Line.COUNT());
    end;

    local procedure GetCalculatedPalletQuantity(var InputASNLevel1Line: Record "GXL ASN Level 1 Line"): Decimal
    var
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
        BoxCount: Decimal;
        LooseItemQuantity: Decimal;
        OldSSCC: Code[50];
        LooseItemQtyInShippingUoM: Decimal;
    begin
        ASNLevel2Line.SETRANGE("Document Type", InputASNLevel1Line."Document Type");
        ASNLevel2Line.SETRANGE("Document No.", InputASNLevel1Line."Document No.");
        ASNLevel2Line.SETRANGE("Level 1 Line No.", InputASNLevel1Line."Line No.");
        ASNLevel2Line.SETFILTER("Level 2 Code", '<>%1', '');

        ASNLevel2Line.SETCURRENTKEY("Level 2 Code", "Document No.", Status, "Document Type");
        OldSSCC := '';
        BoxCount := 0;
        IF ASNLevel2Line.FINDSET() THEN
            REPEAT
                IF ASNLevel2Line."Level 2 Code" <> OldSSCC THEN BEGIN
                    BoxCount += 1;
                    OldSSCC := ASNLevel2Line."Level 2 Code"
                END;
            UNTIL ASNLevel2Line.NEXT() = 0;

        ASNLevel3Line.SETRANGE("Document Type", InputASNLevel1Line."Document Type");
        ASNLevel3Line.SETRANGE("Document No.", InputASNLevel1Line."Document No.");
        ASNLevel3Line.SETRANGE("Level 1 Line No.", InputASNLevel1Line."Line No.");

        IF ASNLevel3Line.FINDSET() THEN
            REPEAT
                LooseItemQuantity += ASNLevel3Line.Quantity;
                LooseItemQtyInShippingUoM += ASNLevel3Line."Carton Quantity";
            UNTIL ASNLevel3Line.NEXT() = 0;

        if InputASNLevel1Line."Carton Quantity" = 0 then //ERP-247 <<
            InputASNLevel1Line."Carton Quantity" := InputASNLevel1Line.Quantity;
        InputASNLevel1Line.Quantity := BoxCount + LooseItemQuantity;
        InputASNLevel1Line.MODIFY();
        EXIT(BoxCount + LooseItemQtyInShippingUoM);
    end;

    local procedure PalletSCCCDuplicate(InputASNLevel1Line: Record "GXL ASN Level 1 Line"): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        ASNHeader2: Record "GXL ASN Header";
        ASNLevel1Line: Record "GXL ASN Level 1 Line";
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
    begin
        IF InputASNLevel1Line."Level 1 Code" = '' THEN
            EXIT(FALSE);

        ASNLevel1Line.SETRANGE("Document Type", InputASNLevel1Line."Document Type");
        ASNLevel1Line.SETRANGE("Document No.", InputASNLevel1Line."Document No.");
        ASNLevel1Line.SETFILTER("Line No.", '<>%1', InputASNLevel1Line."Line No.");
        ASNLevel1Line.SETRANGE("Level 1 Code", InputASNLevel1Line."Level 1 Code");

        IF NOT ASNLevel1Line.ISEMPTY() THEN
            EXIT(TRUE);

        ASNLevel1Line.SETRANGE("Document No.");
        ASNLevel1Line.SETRANGE("Line No.");

        ASNLevel1Line.SETFILTER("Supplier No.", ASNHeader."Supplier No.");
        ASNLevel1Line.SETFILTER(Status, '%1..%2', ASNLevel1Line.Status::Validated, ASNLevel1Line.Status::Receiving);
        ASNLevel1Line.SETFILTER("Document No.", '<>%1', InputASNLevel1Line."Document No.");
        IF ASNLevel1Line.FINDSET() THEN BEGIN
            ASNHeader2.RESET();
            PurchaseHeader.RESET();
            REPEAT

                IF ASNHeader2."No." <> ASNLevel1Line."Document No." THEN BEGIN
                    IF ASNHeader2.GET(ASNLevel1Line."Document Type", ASNLevel1Line."Document No.") THEN BEGIN
                        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, ASNHeader2."Purchase Order No.") THEN BEGIN //if deleted means it's been received and invoiced

                            //TODO: Order Status - EDI Validate ASN, check Pallet duplication
                            IF PurchaseHeader."GXL Order Status" < PurchaseHeader."GXL Order Status"::Closed THEN
                                EXIT(TRUE);
                        END;
                    END;
                END;

            UNTIL ASNLevel1Line.NEXT() = 0;

        END;

        ASNLevel2Line.SETRANGE("Document Type", InputASNLevel1Line."Document Type");
        ASNLevel2Line.SETRANGE("Document No.", InputASNLevel1Line."Document No.");
        ASNLevel2Line.SETRANGE("Level 2 Code", InputASNLevel1Line."Level 1 Code");

        IF NOT ASNLevel2Line.ISEMPTY() THEN
            EXIT(TRUE);

        ASNLevel2Line.SETRANGE("Document No.");
        ASNLevel2Line.SETFILTER("Document No.", '<>%1', InputASNLevel1Line."Document No.");
        ASNLevel2Line.SETFILTER("Supplier No.", ASNHeader."Supplier No.");
        ASNLevel2Line.SETFILTER(Status, '%1..%2', ASNLevel1Line.Status::Validated, ASNLevel2Line.Status::Receiving);

        IF ASNLevel2Line.FINDSET() THEN BEGIN

            ASNHeader2.RESET();
            PurchaseHeader.RESET();
            REPEAT

                IF ASNHeader2."No." <> ASNLevel2Line."Document No." THEN BEGIN

                    IF ASNHeader2.GET(ASNLevel2Line."Document Type", ASNLevel2Line."Document No.") THEN BEGIN

                        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, ASNHeader2."Purchase Order No.") THEN BEGIN

                            //TODO: Order Status - EDI Validate ASN, check Pallet duplication
                            IF PurchaseHeader."GXL Order Status" < PurchaseHeader."GXL Order Status"::Closed THEN
                                EXIT(TRUE);

                        END;

                    END;

                END;

            UNTIL ASNLevel2Line.NEXT() = 0;

        END;
    end;

    local procedure BoxSCCCDuplicate(InputASNLevel2Line: Record "GXL ASN Level 2 Line"): Boolean
    var
        PurchaseHeader: Record "Purchase Header";
        ASNHeader2: Record "GXL ASN Header";
        ASNLevel1Line: Record "GXL ASN Level 1 Line";
        ASNLevel2Line: Record "GXL ASN Level 2 Line";
    begin
        IF InputASNLevel2Line."Level 2 Code" = '' THEN
            EXIT(FALSE);

        ASNLevel2Line.SETCURRENTKEY("Document Type", "Supplier No.", "Level 2 Code", "Document No.", Status);
        ASNLevel2Line.SETRANGE("Document Type", InputASNLevel2Line."Document Type");
        ASNLevel2Line.SETFILTER("Supplier No.", ASNHeader."Supplier No.");

        ASNLevel2Line.SETRANGE("Level 2 Code", InputASNLevel2Line."Level 2 Code");

        ASNLevel2Line.SETFILTER("Document No.", '<>%1', InputASNLevel2Line."Document No.");
        ASNLevel2Line.SETFILTER(Status, '%1..%2', ASNLevel2Line.Status::Validated, ASNLevel2Line.Status::Receiving);
        IF ASNLevel2Line.FINDSET() THEN BEGIN

            ASNHeader2.RESET();
            PurchaseHeader.RESET();

            REPEAT

                IF ASNHeader2."No." <> ASNLevel2Line."Document No." THEN BEGIN

                    IF ASNHeader2.GET(ASNLevel2Line."Document Type", ASNLevel2Line."Document No.") THEN BEGIN

                        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, ASNHeader2."Purchase Order No.") THEN BEGIN

                            //TODO: Order Status - EDI Validate ASN, check Box duplication
                            IF PurchaseHeader."GXL Order Status" < PurchaseHeader."GXL Order Status"::Closed THEN
                                EXIT(TRUE);

                        END;

                    END;

                END;

            UNTIL ASNLevel2Line.NEXT() = 0;

        END;


        ASNLevel1Line.SETRANGE("Document Type", InputASNLevel2Line."Document Type");
        ASNLevel1Line.SETRANGE("Document No.", InputASNLevel2Line."Document No.");
        ASNLevel1Line.SETRANGE("Level 1 Code", InputASNLevel2Line."Level 2 Code");

        IF NOT ASNLevel1Line.ISEMPTY() THEN
            EXIT(TRUE);
        ASNLevel1Line.SETRANGE("Document No.");
        ASNLevel1Line.SETFILTER("Document No.", '<>%1', InputASNLevel2Line."Document No.");
        ASNLevel1Line.SETFILTER("Supplier No.", ASNHeader."Supplier No.");
        ASNLevel1Line.SETFILTER(Status, '%1..%2', ASNLevel1Line.Status::Validated, ASNLevel1Line.Status::Receiving);

        IF ASNLevel1Line.FINDSET() THEN BEGIN

            ASNHeader2.RESET();
            PurchaseHeader.RESET();

            REPEAT

                IF ASNHeader2."No." <> ASNLevel1Line."Document No." THEN BEGIN

                    IF ASNHeader2.GET(ASNLevel1Line."Document Type", ASNLevel1Line."Document No.") THEN BEGIN

                        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, ASNHeader2."Purchase Order No.") THEN BEGIN

                            //TODO: Order Status - EDI Validate ASN, check Box duplication
                            IF PurchaseHeader."GXL Order Status" < PurchaseHeader."GXL Order Status"::Closed THEN
                                EXIT(TRUE);

                        END;

                    END;

                END;

            UNTIL ASNLevel1Line.NEXT() = 0;

        END;
    end;

    local procedure CreatePOR()
    var
        PurchaseHeader: Record "Purchase Header";
        POResponseHeader: Record "GXL PO Response Header";
        POResponseLine: Record "GXL PO Response Line";
        PurchaseLine: Record "Purchase Line";
        EDIProcessPurchOrderResp: Codeunit "GXL EDI-Proc Purch Order Resp.";
        POResponseLineNo: Integer;
        ProcessPORWasSuccess: Boolean;
    begin

        POResponseHeader.RESET();
        POResponseHeader.SETRANGE("Order No.", ASNHeader."Purchase Order No.");
        IF POResponseHeader.FINDFIRST() THEN
            PurchaseHeader.RESET();
        IF PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, ASNHeader."Purchase Order No.") THEN BEGIN
            //TODO: Order Status - EDI Validate ASN, create POR, only Placed status is accepted
            IF (PurchaseHeader."GXL Order Status" = PurchaseHeader."GXL Order Status"::Placed) THEN BEGIN
                POResponseHeader.RESET();
                EVALUATE(POResponseHeader."Response Number", 'POR' + FORMAT(ASNHeader."Document Type") + ASNHeader."No.");
                POResponseHeader."PO Response Date" := ASNHeader."Supplier Reference Date";
                POResponseHeader."Buy-from Vendor No." := ASNHeader."Supplier No.";
                POResponseHeader."Location Code" := ASNHeader."Ship-To Code";
                POResponseHeader."Order No." := ASNHeader."Purchase Order No.";
                POResponseHeader."Expected Receipt Date" := ASNHeader."Expected Receipt Date";
                POResponseHeader."Ship-to Code" := ASNHeader."Ship-for Code";
                POResponseHeader."Response Type" := POResponseHeader."Response Type"::Changed;
                POResponseHeader."ASN Document Type" := ASNHeader."Document Type";
                POResponseHeader."ASN Document No." := ASNHeader."No.";
                POResponseHeader.Status := POResponseHeader.Status::Validated;
                POResponseHeader."EDI File Log Entry No." := ASNHeader."EDI File Log Entry No.";
                POResponseHeader.INSERT();

                PurchaseLine.RESET();
                PurchaseLine.SETRANGE("Document Type", PurchaseLine."Document Type"::Order);
                PurchaseLine.SETRANGE("Document No.", PurchaseHeader."No.");
                PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
                PurchaseLine.SETFILTER("No.", '<>%1', '');
                IF PurchaseLine.FINDSET() THEN BEGIN
                    POResponseLineNo := 0;
                    REPEAT
                        POResponseLineNo += 10000;
                        POResponseLine.RESET();
                        POResponseLine.INIT();
                        POResponseLine."PO Response Number" := POResponseHeader."Response Number";
                        POResponseLine."Line No." := POResponseLineNo;
                        POResponseLine."PO Line No." := PurchaseLine."Line No.";
                        POResponseLine."Item Response Indicator" := 'BP';
                        POResponseLine."Item No." := PurchaseLine."No."; //TODO: Check if it is item or legacy item to be returned
                        POResponseLine."Primary EAN" := PurchaseLine."GXL Primary EAN";
                        POResponseLine."Vendor Reorder No." := PurchaseLine."GXL Vendor Reorder No.";
                        POResponseLine.Description := PurchaseLine.Description;

                        SKU.GET(PurchaseLine."Location Code", PurchaseLine."No.");
                        POResponseLine.OMQTY := SKU."GXL Order Multiple (OM)";
                        POResponseLine.OPQTY := SKU."GXL Order Pack (OP)";
                        GetASNItemQty(PurchaseLine, POResponseLine.Quantity, POResponseLine."Carton-Qty");

                        POResponseLine."Direct Unit Cost" := PurchaseLine."Direct Unit Cost";
                        POResponseLine."Unit of Measure Code" := PurchaseLine."Unit of Measure Code";
                        POResponseLine.INSERT();
                    UNTIL PurchaseLine.NEXT() = 0;
                END;

                // Process Purchase Order Response
                COMMIT();
                CLEARLASTERROR();

                ProcessPORWasSuccess := FALSE;
                CLEAR(EDIProcessPurchOrderResp);
                EDIProcessPurchOrderResp.SetCallFromASN(TRUE);
                ProcessPORWasSuccess := EDIProcessPurchOrderResp.RUN(POResponseHeader);
                IF ProcessPORWasSuccess = FALSE THEN BEGIN
                    POResponseLine.RESET();
                    POResponseLine.SETRANGE("PO Response Number", POResponseHeader."Response Number");
                    IF POResponseLine.COUNT() > 0 THEN
                        POResponseLine.DELETEALL();
                    POResponseHeader.DELETE();
                    IF EDIProcessMgmt.IsLockingError(GETLASTERRORCODE()) = FALSE THEN
                        EDIProcessMgmt.InsertEDIDocumentLog(ASNHeader."EDI File Log Entry No.", 2, 3, ProcessPORWasSuccess);

                    EDIErrorMgt.SetErrorMessage(GETLASTERRORTEXT());
                    EDIErrorMgt.ThrowErrorMessage();

                END ELSE
                    EDIProcessMgmt.InsertEDIDocumentLog(ASNHeader."EDI File Log Entry No.", 2, 3, ProcessPORWasSuccess);

            END;
        END;
    end;

    local procedure GetASNItemQty(PurchLine: Record "Purchase Line"; var OMQty: Decimal; var OPQty: Decimal)
    var
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
    begin
        OMQty := 0;
        OPQty := 0;
        ASNLevel3Line.RESET();
        ASNLevel3Line.SETCURRENTKEY("Document Type", "Document No.", "Level 3 Code");
        ASNLevel3Line.SETRANGE("Document Type", ASNHeader."Document Type");
        ASNLevel3Line.SETRANGE("Document No.", ASNHeader."No.");
        // >> HP2-SPRINT2
        if PurchLine."GXL Legacy Item No." <> '' then
            ASNLevel3Line.SETRANGE("Level 3 Code", PurchLine."GXL Legacy Item No.")
        else
            // << HP2-SPRINT2
            ASNLevel3Line.SETRANGE("Level 3 Code", PurchLine."No.");
        IF ASNLevel3Line.FINDFIRST() THEN BEGIN
            ASNLevel3Line.CALCSUMS(Quantity);
            OMQty := ASNLevel3Line.Quantity;
            OPQty := PurchLine.GXL_CalcCartonQty(OMQty);
        END;
    end;

    [Scope('OnPrem')]
    procedure GetGTINChanges(var ItemSupplierGTINBuffer: Record "GXL Item-Supplier-GTIN Buffer" temporary)
    begin
        EDIFunctionLib.GetGTINChanges(ItemSupplierGTINBuffer);
    end;

    local procedure ValidateDuplication()
    var
        ASNHeader2: Record "GXL ASN Header";
    begin
        //TODO: temporarily add condition as Original EDI Document No. is not mandatory now
        if ASNHeader."Original EDI Document No." <> '' then begin
            // Error if a validated ASN already exists for a given supplier
            ASNHeader2.RESET();
            ASNHeader2.SETCURRENTKEY("Original EDI Document No.", "Supplier No.");
            ASNHeader2.SETRANGE("Original EDI Document No.", ASNHeader."Original EDI Document No.");
            ASNHeader2.SETRANGE("Supplier No.", ASNHeader."Supplier No.");
            ASNHeader2.SETRANGE("Document Type", ASNHeader2."Document Type"::Purchase);
            ASNHeader2.SETFILTER(Status, '%1..', ASNHeader2.Status::Validated);
            IF ASNHeader2.FINDFIRST() THEN BEGIN
                EDIErrorMgt.SetErrorMessage(
                  STRSUBSTNO(
                    Text023Txt,
                    //There is already a valid ASN %1 for supplier %2.
                    MiscUtilities.AddOriginalDocNo(ASNHeader2."No.", ASNHeader2."Original EDI Document No."),
                    ASNHeader2."Supplier No."));
                EDIErrorMgt.ThrowErrorMessage();
            END;
        end;
    end;

    //PS-2428+
    /// <summary>
    /// Check if the ASN is replicated from NAV13 and P2P Contingency then error as ASN for P2P Contingency will be created from BC
    /// </summary>
    /// <param name="ASNHeader"></param>
    /// <returns></returns>
    local procedure CheckIfASNIsP2PContingency()
    var
        ASNHeader2: Record "GXL ASN Header";
    begin
        if (ASNHeader."Document Type" = ASNHeader."Document Type"::Purchase) and (ASNHeader."Purchase Order No." <> '') and
           (ASNHeader."EDI Type" = ASNHeader."EDI Type"::"P2P Contingency") and (ASNHeader."NAV EDI File Log Entry No." <> 0) then begin

            ASNHeader2.SetCurrentKey("Document Type", "Purchase Order No.");
            ASNHeader2.SetRange("Document Type", ASNHeader2."Document Type"::Purchase);
            ASNHeader2.SetRange("Purchase Order No.", ASNHeader."Purchase Order No.");
            ASNHeader2.SetRange("NAV EDI File Log Entry No.", 0);
            ASNHeader2.SetFilter("MIM User ID", '<>%1', '');
            if not ASNHeader2.IsEmpty then begin
                EDIErrorMgt.SetErrorMessage(StrSubstNo('Replicated ASN for purchase order %1 has already been created', ASNHeader."Purchase Order No."));
                EDIErrorMgt.ThrowErrorMessage();
            end;
        end;
    end;
    //PS-2428-
}

