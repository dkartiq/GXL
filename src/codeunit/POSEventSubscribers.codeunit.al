codeunit 50401 "GXL POS Event Subscribers"
{
    //CR008
    //This publisher event is called in the function: "ZReportSuspendProcess" in CAL which is not available in "LSC POS Transaction" codeunit AL
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'GXLOnZReportSuspendProcessOnAfterVoidSuspendedTrans', '', false, false)] //LSTS-27266
    local procedure AfterCreateDocNo(POSTransaction: Record "LSC POS Transaction"; TerminalNo: Code[10])
    var
        gxlPOSVoidedInfocodeEntry: Record "LSC POS Voided Infoc Entry";
        gxlInfocode: Record "LSC Infocode";
        gxlInformationSubcode: Record "LSC Information Subcode";
    begin
        gxlInfocode.RESET();
        //gxlInfocode.SETRANGE(Description, 'Closed by Z report');
        gxlInfocode.SETFILTER(Description, '''%1''', '@' + 'closed by z report'); //'@%1'
        //gxlInfocode.SETRANGE(Code, 'CLOSEDBYZREPORT');
        IF gxlInfocode.FINDFIRST() THEN BEGIN
            gxlInformationSubcode.RESET();
            //gxlInformationSubcode.SETRANGE(Code, '01');
            gxlInformationSubcode.SETRANGE(Code, gxlInfocode.Code);
            gxlInformationSubcode.SETFILTER(Description, '''%1''', '@' + 'closed by z report');

            gxlPOSVoidedInfocodeEntry.INIT();
            gxlPOSVoidedInfocodeEntry."Receipt No." := POSTransaction."Receipt No.";
            gxlPOSVoidedInfocodeEntry."Transaction Type" := gxlPOSVoidedInfocodeEntry."Transaction Type"::Header;
            gxlPOSVoidedInfocodeEntry.Infocode := gxlInfocode.Code;
            gxlPOSVoidedInfocodeEntry."Store No." := POSTransaction."Store No.";
            gxlPOSVoidedInfocodeEntry.Information := gxlInfocode.Description;
            gxlPOSVoidedInfocodeEntry.Date := TODAY();
            gxlPOSVoidedInfocodeEntry.Time := TIME();
            gxlPOSVoidedInfocodeEntry."POS Terminal No." := TerminalNo;
            gxlPOSVoidedInfocodeEntry."Staff ID" := POSTransaction."Staff ID";
            IF gxlInformationSubcode.FINDFIRST() THEN BEGIN
                gxlPOSVoidedInfocodeEntry.Information := gxlInformationSubcode.Subcode;
                gxlPOSVoidedInfocodeEntry."Type of Input" := gxlPOSVoidedInfocodeEntry."Type of Input"::SubCode;
                gxlPOSVoidedInfocodeEntry.Subcode := gxlInformationSubcode.Subcode;
                gxlPOSVoidedInfocodeEntry."Selected Quantity" := 1;
            END;
            gxlPOSVoidedInfocodeEntry.INSERT(TRUE);
        END;
    end;

    // >> Upgrade
    //[EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'SalesEntryOnBeforeInsert', '', true, true)]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'SalesEntryOnBeforeInsertV2', '', true, true)]
    // << Upgrade
    local procedure POSPostUtility_SalesEntryOnBeforeInsert(var pTransSalesEntry: Record "LSC Trans. Sales Entry")
    var
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        Signed: Decimal;
    begin
        //PS-1781: Send Standard Cost per UOM to Cost Amount field
        /*
        if pTransSalesEntry."Item No." <> '' then
            LegacyItemHelpers.GetLegacyItemNo(pTransSalesEntry."Item No.", pTransSalesEntry."Unit of Measure", pTransSalesEntry."GXL Legacy Item No.");
        pTransSalesEntry."GXL Cost Amount" := pTransSalesEntry."Cost Amount";
        if Item.Get(pTransSalesEntry."Item No.") then
            pTransSalesEntry."GXL Cost Amount" := Round(pTransSalesEntry.Quantity * Item."GXL Standard Cost");
        */
        pTransSalesEntry."GXL Legacy Item No." := pTransSalesEntry."Item No.";
        if pTransSalesEntry.Quantity > 0 then
            Signed := 1
        else
            Signed := -1;
        if Item.Get(pTransSalesEntry."Item No.") then begin
            pTransSalesEntry."GXL Cost Amount" := Item."GXL Standard Cost";
            if ItemUOM.Get(pTransSalesEntry."Item No.", pTransSalesEntry."Unit of Measure") then begin
                LegacyItemHelpers.GetLegacyItemNo(ItemUOM, pTransSalesEntry."GXL Legacy Item No.");
                if ItemUOM."Qty. per Unit of Measure" > 0 then
                    pTransSalesEntry."GXL Cost Amount" := Round(Item."GXL Standard Cost" * ItemUOM."Qty. per Unit of Measure", 0.01);
            end;
            pTransSalesEntry."GXL Cost Amount" := Signed * pTransSalesEntry."GXL Cost Amount";
        end;
    end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Transaction Events", 'OnBeforeInsertItemLine', '', true, true)]
    local procedure POSTransEvents_OnBeforeInsertItemLine(var POSTransLine: Record "LSC POS Trans. Line")
    var
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
    begin
        if (POSTransLine."Entry Type" = POSTransLine."Entry Type"::Item) and (POSTransLine.Number <> '') then
            LegacyItemHelpers.GetLegacyItemNo(POSTransLine.Number, POSTransLine."Unit of Measure", POSTransLine."GXL Legacy Item No.")
        else
            POSTransLine."GXL Legacy Item No." := '';
    end;

}