codeunit 50171 "GXL Bloyal Sales & Payment"
{
    //Bloyal integration
    //Sales and Payment
    //To be run via job queue

    TableNo = "Job Queue Entry";
    Permissions = tabledata "GXL Bloyal Azure Log" = rmid;

    trigger OnRun()
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
        FromEntryNo: Integer;
    begin

        ClearAll();
        GetSetup();
        if IntegrationSetup."Bloyal Sales Payment Template" = '' then
            exit;

        GetTemplateFields();

        //Re-Process all the Reset entries
        BloyalAzureLog2.SetCurrentKey(Reset);
        BloyalAzureLog2.SetRange(Reset, true);
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::"Sales & Payment");
        ReProcessSalesPayment(BloyalAzureLog2);

        //Process the new entries
        FromEntryNo := GetNextEntryNo();
        ProcessTransSalesPayment(FromEntryNo, 0, false, true);
    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        BloyalAzureLog: Record "GXL Bloyal Azure Log";
        GSTPosSetup: Record "VAT Posting Setup";
        Store: Record "LSC Store";
        // >> Upgrade
        //PosFuncProfile: Record "LSC POS Functionality Profile";
        PosFuncProfile: Record "LSC POS Func. Profile";
        // << Upgrade
        HeaderNameValueBuff: Record "Name/Value Buffer" temporary;
        NameValueBuff: Record "Name/Value Buffer" temporary;
        SetupRead: Boolean;
        TemplateRead: Boolean;
        GlobalDT: DateTime;

    // >> LCB-463
    procedure ReSendTransaction(SendtoWS: Boolean)
    var
        TransactionHeader: Record "LSC Transaction Header";
        TempTransactionHeader: Record "LSC Transaction Header" temporary;

        TransSalesEntry: Record "LSC Trans. Sales Entry";
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        BloyalIntegrationHelpers: Codeunit "GXL Bloyal Integration Helpers";
        JsonArrHeader: JsonArray;
        JsonObjHeader: JsonObject;
        i: Integer;
        j: Integer;
        NoOfRecs: Integer;
        MaxOfRecs: Integer;
        FileNo: Integer;

        OutS: OutStream;
        InS: InStream;
        FileName: Text;
        ToBreak: Boolean;
    begin

        ClearAll();
        GetSetup();
        if IntegrationSetup."Bloyal Sales Payment Template" = '' then
            exit;
        GetTemplateFields();

        MaxOfRecs := IntegrationSetup."Bloyal Sales Pmt Max Records";

        FileNo := 1;
        i := 0;
        NoOfRecs := 0;

        TransactionHeader.SetCurrentKey("Re-Submit to Bloyal");

        TransactionHeader.SetRange("Re-Submit to Bloyal", true);

        TransactionHeader.SetRange("Transaction Type", TransactionHeader."Transaction Type"::Sales);
        TransactionHeader.SetFilter("Entry Status", '<>%1', TransactionHeader."Entry Status"::Voided);

        if TransactionHeader.FindSet() then begin
            if not SendtoWS then
                BloyalIntegrationHelpers.InitialiseZipStream();

            BloyalIntegrationHelpers.SetSetup(IntegrationSetup);

            GlobalDT := CurrentDateTime();

            InitialiseJsonObject(JsonObjHeader);

            AddModifyIfExists(JsonObjHeader);

            repeat
                TransSalesEntry.SetRange("Store No.", TransactionHeader."Store No.");
                TransSalesEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
                TransSalesEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
                if TransSalesEntry.FindSet() then begin
                    j := TransSalesEntry.Count();

                    if Store."No." <> TransactionHeader."Store No." then
                        if Store.Get(TransactionHeader."Store No.") then
                            if Store."Functionality Profile" <> '' then
                                if PosFuncProfile.Get(Store."Functionality Profile") then;

                    if PosFuncProfile."Profile ID" = '' then
                        if PosFuncProfile.Get('##DEFAULT') then;

                    //Break the data into a chunk of max. number of records
                    if (MaxOfRecs <> 0) and ((i + j) > MaxOfRecs) then begin
                        ToBreak := true;
                        //Not to break if the sales entries per transaction no. contains more records than the maximum allowed, 
                        //it is highly unlikely
                        if (i = 0) then
                            ToBreak := false;
                    end else
                        ToBreak := false;

                    if ToBreak then begin
                        Clear(TempBlob);

                        TempBlob.CreateInStream(InS);
                        TempBlob.CreateOutStream(OutS);

                        JsonArrHeader.WriteTo(OutS);

                        //Send to Azure LogicApp                        
                        ReSubmitAddAzureLogEntry(FileNo);

                        if SendtoWS then begin
                            BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                        end else begin
                            //Send to File
                            FileName := StrSubstNo('SalesPmt_%1.json', FileNo);
                            BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                        end;

                        //update Azure Log
                        BloyalAzureLog."No. Of Records Sent" := i;
                        BloyalAzureLog."Start Processed Date Time" := GlobalDT;
                        BloyalAzureLog.Modify();
                        Commit();

                        //reset counter
                        i := 0;
                        FileNo += 1;
                        NoOfRecs := 0;

                        Clear(JsonArrHeader);
                        Clear(JsonObjHeader);
                        InitialiseJsonObject(JsonObjHeader);

                        AddModifyIfExists(JsonObjHeader);
                    end;

                    //Log all sent transaction so we can mark them as resubmit = false
                    TempTransactionHeader := TransactionHeader;
                    if TempTransactionHeader.insert then;

                    BuildJsonTransHeader(TransactionHeader, JsonObjHeader);

                    //Here add the extra flag for modifying the existing transaction
                    //This is not really needed but left here just as precaution
                    BuildJsonModifyIfExists(JsonObjHeader);

                    BuildJsonTransSalesEntry(TransactionHeader, JsonObjHeader);
                    i := i + j;

                    BuildJsonTransPmtEntry(TransactionHeader, JsonObjHeader);
                    JsonArrHeader.Add(JsonObjHeader.Clone());
                    NoOfRecs += 1;
                end;
            until TransactionHeader.Next() = 0;

            if i > 0 then begin
                Clear(TempBlob);

                TempBlob.CreateInStream(InS);
                TempBlob.CreateOutStream(OutS);

                JsonArrHeader.WriteTo(OutS);

                //Send to Azure LogicApp
                ReSubmitAddAzureLogEntry(FileNo);

                if SendtoWS then begin
                    BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                end else begin
                    //Send to File
                    FileName := StrSubstNo('SalesPmt_%1.json', FileNo);
                    BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                    BloyalIntegrationHelpers.DownloadZipFiles('SalesPmt.zip');
                end;

                //update Azure Log
                BloyalAzureLog."No. Of Records Sent" := i;
                BloyalAzureLog."Start Processed Date Time" := GlobalDT;
                BloyalAzureLog.Reset := false;
                BloyalAzureLog.Modify();
                Commit();

            end;
        end;

        // Update Trans Header as processed
        MarkTransHeaderProcessed(TempTransactionHeader);
    end;

    local procedure MarkTransHeaderProcessed(var TempTransactionHeader: Record "LSC Transaction Header" temporary)
    var
        TransactionHeader2: Record "LSC Transaction Header";
    begin
        TempTransactionHeader.reset;
        if TempTransactionHeader.FindSet() then
            repeat
                TransactionHeader2.get(TempTransactionHeader."Store No.", TempTransactionHeader."POS Terminal No.", TempTransactionHeader."Transaction No.");
                TransactionHeader2."Re-Submit to Bloyal" := false;
                TransactionHeader2.Modify();
                commit;
            until TempTransactionHeader.next = 0;

        TempTransactionHeader.DeleteAll();
        commit;
    end;
    // << LCB-463

    procedure ProcessTransSalesPayment(FromEntryNo: Integer; ToEntryNo: Integer; ReProcess: Boolean; SendtoWS: Boolean)
    var
        TransactionHeader: Record "LSC Transaction Header";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        BloyalIntegrationHelpers: Codeunit "GXL Bloyal Integration Helpers";
        JsonArrHeader: JsonArray;
        JsonObjHeader: JsonObject;
        i: Integer;
        j: Integer;
        NoOfRecs: Integer;
        MaxOfRecs: Integer;
        FileNo: Integer;
        PrevCounter: Integer;
        NewFromEntryNo: Integer;
        NewToEntryNo: Integer;
        LastEntryNo: Integer;
        OutS: OutStream;
        InS: InStream;
        FileName: Text;
        ToBreak: Boolean;
    begin

        GetSetup();
        if IntegrationSetup."Bloyal Sales Payment Template" = '' then
            exit;
        GetTemplateFields();

        MaxOfRecs := IntegrationSetup."Bloyal Sales Pmt Max Records";

        FileNo := 1;
        PrevCounter := 0;
        i := 0;
        NoOfRecs := 0;

        TransactionHeader.SetCurrentKey("Replication Counter");
        if ToEntryNo <> 0 then
            TransactionHeader.SetRange("Replication Counter", FromEntryNo, ToEntryNo)
        else
            TransactionHeader.SetFilter("Replication Counter", '>=%1', FromEntryNo);
        TransactionHeader.SetRange("Transaction Type", TransactionHeader."Transaction Type"::Sales);
        TransactionHeader.SetFilter("Entry Status", '<>%1', TransactionHeader."Entry Status"::Voided);

        //During the long running process, new transactions may be created
        //So limit to the last replication counter at the beginning of the process as the process may take long
        if TransactionHeader.FindLast() then begin
            ToEntryNo := TransactionHeader."Replication Counter";
            LastEntryNo := TransactionHeader."Replication Counter";
        end;
        TransactionHeader.SetRange("Replication Counter", FromEntryNo, ToEntryNo);
        if TransactionHeader.FindSet() then begin
            if not SendtoWS then
                BloyalIntegrationHelpers.InitialiseZipStream();

            NewFromEntryNo := TransactionHeader."Replication Counter";
            BloyalIntegrationHelpers.SetSetup(IntegrationSetup);

            GlobalDT := CurrentDateTime();

            InitialiseJsonObject(JsonObjHeader);
            repeat
                TransSalesEntry.SetRange("Store No.", TransactionHeader."Store No.");
                TransSalesEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
                TransSalesEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
                if TransSalesEntry.FindSet() then begin
                    j := TransSalesEntry.Count();

                    if Store."No." <> TransactionHeader."Store No." then
                        if Store.Get(TransactionHeader."Store No.") then
                            if Store."Functionality Profile" <> '' then
                                if PosFuncProfile.Get(Store."Functionality Profile") then;

                    if PosFuncProfile."Profile ID" = '' then
                        if PosFuncProfile.Get('##DEFAULT') then;

                    //Break the data into a chunk of max. number of records
                    if (not ReProcess) and (MaxOfRecs <> 0) and ((i + j) > MaxOfRecs) then begin
                        ToBreak := true;
                        //Not to break if the sales entries per transaction no. contains more records than the maximum allowed, 
                        //it is highly unlikely
                        if (i = 0) then
                            ToBreak := false;
                    end else
                        ToBreak := false;

                    if ToBreak then begin
                        Clear(TempBlob);
                        // >> Upgrade
                        // TempBlob.Blob.CreateInStream(InS);
                        // TempBlob.Blob.CreateOutStream(OutS);
                        TempBlob.CreateInStream(InS);
                        TempBlob.CreateOutStream(OutS);
                        // << Upgrade
                        JsonArrHeader.WriteTo(OutS);

                        //Send to Azure LogicApp
                        NewToEntryNo := PrevCounter;
                        AddAzureLogEntry(FileNo, NewFromEntryNo, NewToEntryNo);
                        if SendtoWS then begin
                            BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                        end else begin
                            //Send to File
                            FileName := StrSubstNo('SalesPmt_%1.json', FileNo);
                            BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                        end;

                        //update Azure Log
                        BloyalAzureLog."No. Of Records Sent" := i;
                        BloyalAzureLog."Start Processed Date Time" := GlobalDT;
                        BloyalAzureLog.Modify();
                        Commit();

                        //reset counter
                        i := 0;
                        FileNo += 1;
                        NoOfRecs := 0;
                        NewFromEntryNo := TransactionHeader."Replication Counter";
                        Clear(JsonArrHeader);
                        Clear(JsonObjHeader);
                        InitialiseJsonObject(JsonObjHeader);
                    end;

                    BuildJsonTransHeader(TransactionHeader, JsonObjHeader);
                    BuildJsonTransSalesEntry(TransactionHeader, JsonObjHeader);
                    i := i + j;

                    BuildJsonTransPmtEntry(TransactionHeader, JsonObjHeader);
                    JsonArrHeader.Add(JsonObjHeader.Clone());
                    PrevCounter := TransactionHeader."Replication Counter";
                    NoOfRecs += 1;
                end;
            until TransactionHeader.Next() = 0;

            if i > 0 then begin
                Clear(TempBlob);
                // >> Upgrade
                // TempBlob.Blob.CreateInStream(InS);
                // TempBlob.Blob.CreateOutStream(OutS);
                TempBlob.CreateInStream(InS);
                TempBlob.CreateOutStream(OutS);
                // << Upgrade
                JsonArrHeader.WriteTo(OutS);

                //Send to Azure LogicApp
                NewToEntryNo := PrevCounter;
                if not ReProcess then
                    AddAzureLogEntry(FileNo, NewFromEntryNo, NewToEntryNo);
                if SendtoWS then begin
                    BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                end else begin
                    //Send to File
                    FileName := StrSubstNo('SalesPmt_%1.json', FileNo);
                    BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                    BloyalIntegrationHelpers.DownloadZipFiles('SalesPmt.zip');
                end;

                //update Azure Log
                BloyalAzureLog."No. Of Records Sent" := i;
                BloyalAzureLog."Start Processed Date Time" := GlobalDT;
                BloyalAzureLog.Reset := false;
                BloyalAzureLog.Modify();
                Commit();

            end;
        end;
    end;

    local procedure AddModifyIfExists(JsonObjHeader2: JsonObject)
    begin
        JsonObjHeader2.Add('ModifyIfExists', 'true');
    end;

    local procedure InitialiseJsonObject(JsonObjHeader2: JsonObject)
    begin
        InitialiseJsonObjectForTransHeader(JsonObjHeader2);
        JsonObjHeader2.Add('sales', '');
        JsonObjHeader2.Add('payments', '');
    end;

    local procedure InitialiseJsonObjectForTransHeader(JsonObjHeader2: JsonObject)
    begin
        HeaderNameValueBuff.Reset();
        if HeaderNameValueBuff.FindSet() then
            repeat
                JsonObjHeader2.Add(HeaderNameValueBuff.Value, '');
            until HeaderNameValueBuff.Next() = 0;
    end;

    local procedure BuildJsonModifyIfExists(JsonObjHeader2: JsonObject)
    begin
        JsonObjHeader2.Replace('ModifyIfExists', 'true');
    end;

    local procedure BuildJsonTransHeader(var TransactionHeader: Record "LSC Transaction Header"; JsonObjHeader2: JsonObject)
    var
        BloyalIntegrationHelpers: Codeunit "GXL Bloyal Integration Helpers";
        RecRef: RecordRef;
        FldRef: FieldRef;
    begin
        RecRef.GetTable(TransactionHeader);
        HeaderNameValueBuff.Reset();
        if HeaderNameValueBuff.FindSet() then begin
            repeat
                FldRef := RecRef.Field(HeaderNameValueBuff.ID);
                BloyalIntegrationHelpers.ReplaceFieldRefValueJsonObject(FldRef, HeaderNameValueBuff.Value, JsonObjHeader2);
            until HeaderNameValueBuff.Next() = 0;
        end;

    end;

    local procedure InitialiseJsonObjectForSalesEntry(JsonObjSales: JsonObject)
    begin
        if NameValueBuff.FindSet() then begin
            JsonObjSales.Add('Legacy_Item_No', '');
            repeat
                JsonObjSales.Add(NameValueBuff.Value, '');
            until NameValueBuff.Next() = 0;

            JsonObjSales.Add('DiscountSubcode', '');
            JsonObjSales.Add('ReturnSubcode', '');
        end;
    end;

    local procedure BuildJsonTransSalesEntry(TransactionHeader: Record "LSC Transaction Header"; JsonObjHeader: JsonObject)
    var
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        TransSalesEntry2: Record "LSC Trans. Sales Entry";
        Item: Record Item;
        BloyalIntegrationHelpers: Codeunit "GXL Bloyal Integration Helpers";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        RecRef: RecordRef;
        FldRef: FieldRef;
        JsonArrSales: JsonArray;
        JsonObjSales: JsonObject;
        LegacyItemNo: Code[20];
        DiscAmt: Decimal;
        FullPrice: Decimal;
        PriceSigned: Integer;
        DiscountSigned: Integer;
        UOMQty: Decimal;
        IsGiftCard: Boolean;
    begin
        TransSalesEntry.SetRange("Store No.", TransactionHeader."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        if TransSalesEntry.FindSet() then begin

            Clear(JsonArrSales);
            InitialiseJsonObjectForSalesEntry(JsonObjSales);
            repeat
                if NameValueBuff.FindSet() then begin
                    TransSalesEntry2 := TransSalesEntry;
                    LegacyItemNo := TransSalesEntry2."GXL Legacy Item No.";
                    if LegacyItemNo = '' then
                        LegacyItemHelpers.GetLegacyItemNo(TransSalesEntry2."Item No.", TransSalesEntry2."Unit of Measure", LegacyItemNo);
                    JsonObjSales.Replace('Legacy_Item_No', LegacyItemNo);

                    if TransSalesEntry2.Price >= 0 then
                        PriceSigned := 1
                    else
                        PriceSigned := -1;
                    if TransSalesEntry2.Price >= 0 then
                        DiscountSigned := 1
                    else
                        DiscountSigned := -1;

                    if (GSTPosSetup."VAT Bus. Posting Group" <> TransSalesEntry2."VAT Bus. Posting Group") or (GSTPosSetup."LSC POS Terminal VAT Code" <> TransSalesEntry2."VAT Code") then begin
                        GSTPosSetup.SetRange("VAT Bus. Posting Group", TransSalesEntry2."VAT Bus. Posting Group");
                        GSTPosSetup.SetRange("LSC POS Terminal VAT Code", TransSalesEntry2."VAT Code");
                        if not GSTPosSetup.FindFirst() then
                            Clear(GSTPosSetup);
                    end;

                    FullPrice := Abs(TransSalesEntry2."Standard Net Price");
                    FullPrice := Round(FullPrice * (1 + GSTPosSetup."VAT %" / 100), PosFuncProfile."Price Rounding to");

                    DiscAmt := TransSalesEntry2."Discount Amount";
                    if (TransSalesEntry2."Discount Amount" = 0) and (TransSalesEntry2."Disc. Amount From Std. Price" <> 0) and
                        (TransSalesEntry2."UOM Quantity" = 0)
                    then begin
                        DiscAmt := Abs(TransSalesEntry2."Disc. Amount From Std. Price");
                        DiscAmt := Round(DiscAmt * (1 + GSTPosSetup."VAT %" / 100), PosFuncProfile."Amount Rounding to");
                        DiscAmt := Round(DiscAmt * Abs(TransSalesEntry2.Quantity), PosFuncProfile."Amount Rounding to");
                    end;

                    //PS-2064+
                    IsGiftCard := false;
                    if (TransSalesEntry2."Disc. Amount From Std. Price" <> 0) and (TransSalesEntry2."Standard Net Price" = 0) then begin
                        if Item.Get(TransSalesEntry2."Item No.") then
                            if Item."LSC Keying in Price" = Item."LSC Keying in Price"::"Must Key in New Price" then
                                IsGiftCard := true;
                    end;
                    if IsGiftCard then begin
                        FullPrice := Abs(TransSalesEntry2."Net Price");
                        FullPrice := Round(FullPrice * (1 + GSTPosSetup."VAT %" / 100), PosFuncProfile."Price Rounding to");
                        DiscAmt := TransSalesEntry2."Discount Amount";
                    end;
                    //PS-2064-

                    UOMQty := TransSalesEntry2."UOM Quantity";
                    if UOMQty = 0 then
                        UOMQty := TransSalesEntry2.Quantity;

                    // >> LCB-45
                    DiscAmt := -TransSalesEntry2."Discount Amount" / UOMQty;
                    FullPrice := TransSalesEntry2."Total Rounded Amt." / UOMQty;
                    FullPrice += DiscAmt;
                    // << LCB-45

                    RecRef.GetTable(TransSalesEntry);
                    repeat
                        FldRef := RecRef.Field(NameValueBuff.ID);

                        //Return full price
                        if NameValueBuff.ID = TransSalesEntry.FieldNo(Price) then
                            // >> LCB-45
                            //FldRef.Value := PriceSigned * FullPrice;
                            FldRef.Value := FullPrice;
                        // << LCB-45

                        //Price override as a discount
                        if NameValueBuff.ID = TransSalesEntry.FieldNo("Discount Amount") then
                            // >> LCB-45
                            //FldRef.Value := DiscountSigned * DiscAmt;
                            FldRef.Value := DiscAmt;
                        // << LCB-45

                        //UOM Quantity
                        if NameValueBuff.ID = TransSalesEntry.FieldNo(Quantity) then
                            FldRef.Value := UOMQty;


                        BloyalIntegrationHelpers.ReplaceFieldRefValueJsonObject(FldRef, NameValueBuff.Value, JsonObjSales);
                    until NameValueBuff.Next() = 0;

                    BuildJsonInfocodeEntry(TransSalesEntry, JsonObjSales);

                end;
                JsonArrSales.Add(JsonObjSales.Clone());
            until TransSalesEntry.Next() = 0;
            JsonObjHeader.Replace('sales', JsonArrSales);
        end;

    end;

    local procedure BuildJsonInfocodeEntry(TransSalesEntry: Record "LSC Trans. Sales Entry"; JsonObjSales: JsonObject)
    var
        TransInfocodeEntry: Record "LSC Trans. Infocode Entry";
        InformationSubcode: Record "LSC Information Subcode";
        DiscInfoCode: Text;
        ReturnInfoCode: Text;
    begin
        DiscInfoCode := '';
        ReturnInfoCode := '';
        TransInfocodeEntry.SetRange("Store No.", TransSalesEntry."Store No.");
        TransInfocodeEntry.SetRange("POS Terminal No.", TransSalesEntry."POS Terminal No.");
        TransInfocodeEntry.SetRange("Transaction No.", TransSalesEntry."Transaction No.");
        TransInfocodeEntry.SetRange("Transaction Type", TransInfocodeEntry."Transaction Type"::"Sales Entry");
        TransInfocodeEntry.SetRange("Line No.", TransSalesEntry."Line No.");
        TransInfocodeEntry.SetRange(Infocode, 'DISCOUNT');
        if TransInfocodeEntry.FindFirst() then begin
            //PS-1688 +
            //if InformationSubcode.Get(TransInfocodeEntry.Infocode, TransInfocodeEntry.Subcode) then
            //    DiscInfoCode := InformationSubcode.Description
            //else
            //    DiscInfoCode := TransInfocodeEntry.Information;
            DiscInfoCode := TransInfocodeEntry.Information;
            //PS-1688 -
        end;
        TransInfocodeEntry.SetRange(Infocode, 'RETURN');
        if TransInfocodeEntry.FindFirst() then begin
            if InformationSubcode.Get(TransInfocodeEntry.Infocode, TransInfocodeEntry.Subcode) then
                ReturnInfoCode := InformationSubcode.Description
            else
                ReturnInfoCode := TransInfocodeEntry.Information;
        end;
        JsonObjSales.Replace('DiscountSubcode', DiscInfoCode);
        JsonObjSales.Replace('ReturnSubcode', ReturnInfoCode);
    end;

    local procedure BuildJsonTransPmtEntry(TransactionHeader: Record "LSC Transaction Header"; JsonObjHeader: JsonObject)
    var
        TransPmtEntry: Record "LSC Trans. Payment Entry";
        JsonArrPmt: JsonArray;
        JsonObjPmt: JsonObject;
    begin
        Clear(JsonArrPmt);
        TransPmtEntry.SetRange("Store No.", TransactionHeader."Store No.");
        TransPmtEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransPmtEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        if TransPmtEntry.FindSet() then begin
            JsonObjPmt.Add('Tender_Type', '');
            JsonObjPmt.Add('Amount_Tendered', '');
            repeat
                JsonObjPmt.Replace('Tender_Type', TransPmtEntry."Tender Type");
                JsonObjPmt.Replace('Amount_Tendered', TransPmtEntry."Amount Tendered");
                JsonArrPmt.Add(JsonObjPmt.Clone());
            until TransPmtEntry.Next() = 0;
            JsonObjHeader.Replace('payments', JsonArrPmt);
        end;

    end;

    local procedure GetTemplateFields()
    var
        DataTemplateHeader: Record "GXL ECS Data Template Header";
        DataTemplateMgt: Codeunit "GXL Data Template Management";
    begin
        GetSetup();
        if IntegrationSetup."Bloyal Sales Payment Template" = '' then
            exit;
        DataTemplateHeader.Get(IntegrationSetup."Bloyal Sales Payment Template");

        if not TemplateRead then begin
            NameValueBuff.Reset();
            NameValueBuff.DeleteAll();

            HeaderNameValueBuff.Reset();
            HeaderNameValueBuff.DeleteAll();

            DataTemplateMgt.GetBloyalTemplateFields(IntegrationSetup."Bloyal Sales Payment Template", Database::"LSC Trans. Sales Entry", NameValueBuff);
            DataTemplateMgt.GetBloyalTemplateFields(IntegrationSetup."Bloyal Sales Payment Template", Database::"LSC Transaction Header", HeaderNameValueBuff);
            TemplateRead := true;
        end;

    end;

    procedure GetNextEntryNo(): Integer
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog2.SetCurrentKey("End Entry No.");
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::"Sales & Payment");
        if BloyalAzureLog2.FindLast() then
            exit(BloyalAzureLog2."End Entry No." + 1)
        else
            exit(1);
    end;

    local procedure ReSubmitAddAzureLogEntry(FileNo: Integer)
    begin
        BloyalAzureLog.InitAzureLogEntry(BloyalAzureLog."Web Service Name"::"Sales & Payment", FileNo, 0, 0);
        BloyalAzureLog."Re-Submit to Bloyal" := true;
        BloyalAzureLog.Insert(true);
    end;

    local procedure AddAzureLogEntry(FileNo: Integer; StartEntryNo: Integer; EndEntryNo: Integer)
    begin
        BloyalAzureLog.InitAzureLogEntry(BloyalAzureLog."Web Service Name"::"Sales & Payment", FileNo, StartEntryNo, EndEntryNo);
        BloyalAzureLog.Insert(true);
    end;

    procedure ReProcessSalesPayment(var _BloyalAzureLog: Record "GXL Bloyal Azure Log")
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog2.Copy(_BloyalAzureLog);
        BloyalAzureLog2.SetCurrentKey(Reset);
        BloyalAzureLog2.SetRange(Reset, true);
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::"Sales & Payment");
        if BloyalAzureLog2.FindSet() then
            repeat
                BloyalAzureLog := BloyalAzureLog2;
                ProcessTransSalesPayment(BloyalAzureLog2."Start Entry No.", BloyalAzureLog2."End Entry No.", true, true);
            until BloyalAzureLog2.Next() = 0;
    end;

    procedure SetBloyalAzureLog(_BloyalAzureLog: Record "GXL Bloyal Azure Log")
    begin
        BloyalAzureLog := _BloyalAzureLog;
    end;

    local procedure GetSetup()
    begin
        if not SetupRead then begin
            IntegrationSetup.Get();
            SetupRead := true;
        end;
    end;

}