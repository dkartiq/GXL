// LCB-110 Codeunit 50173 - GXL Bloyal Product / Codeunit 50482 GXL Comestri Product Stop Block Items
codeunit 50482 "GXL Comestri Product"
{
    /*Change Log
        WRP-1013: 03-02-21
            Comestri Send to Parameters can be different b/w SOH and Product full feed
    */

    TableNo = "Job Queue Entry";
    Permissions = tabledata "GXL Comestri Azure Log" = rmid;

    trigger OnRun()
    var
        ComestriAzureLog2: Record "GXL Comestri Azure Log";
        FromDateTime: DateTime;
    begin

        ClearAll();
        GetSetup();
        if IntegrationSetup."Comestri Product Template" = '' then
            exit;

        GetTemplateFields();

        //Re-Process all the Reset entries
        ComestriAzureLog2.SetCurrentKey(Reset);
        ComestriAzureLog2.SetRange(Reset, true);
        ComestriAzureLog2.SetRange("Web Service Name", ComestriAzureLog2."Web Service Name"::Product);
        ReProcessProduct(ComestriAzureLog2);

        //Process the new entries
        FromDateTime := GetLastEndDateTime();
        //WRP-1013+
        //if IntegrationSetup."Comestri Send Data to" = IntegrationSetup."Comestri Send Data to"::"End Point" then
        if IntegrationSetup."Comestri Product Send to" = IntegrationSetup."Comestri Product Send to"::"End Point" then
            //WRP-1013- 
            ProcessProduct(false, true, false)
        else
            ProcessProduct(false, false, true);

    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        ComestriAzureLog: Record "GXL Comestri Azure Log";
        ItemNameValueBuff: Record "Name/Value Buffer" temporary;
        UOMNameValueBuff: Record "Name/Value Buffer" temporary;
        BarcodesNameValueBuff: Record "Name/Value Buffer" temporary;
        SetupRead: Boolean;
        TemplateRead: Boolean;
        StartRunDT: DateTime;
        GlobalDT: DateTime;


    procedure ProcessProduct(ReProcess: Boolean; SendtoWS: Boolean; SendtoSFTP: Boolean)
    var
        Item: Record Item;
        // >> Upgrder
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        // << Upgrade
        ComestriIntegrationHelpers: Codeunit "GXL Comestri IntegrationHelper";
        JsonArrItem: JsonArray;
        JsonObjItem: JsonObject;
        i: Integer;
        MaxOfRecs: Integer;
        FileNo: Integer;
        PrevDateTime: DateTime;
        NewStartDateTime: DateTime;
        NewEndDateTime: DateTime;
        InS: InStream;
        OutS: OutStream;
        ToBreak: Boolean;
        FileName: Text;
        JsonObjProduct: JsonObject;
        ProdIns: InStream;
        ProdOuts: OutStream;
        // >> Upgrder
        //ProdTempBlob: Record TempBlob;
        ProdTempBlob: Codeunit "Temp Blob";
        // >> Upgrder
        JsonProdText: Text;

    begin
        GetSetup();
        if IntegrationSetup."Comestri Product Template" = '' then
            exit;
        GetTemplateFields();

        //MaxOfRecs := IntegrationSetup."Bloyal Product Max Records";

        FileNo := 1;
        i := 0;
        PrevDateTime := 0DT;
        Item.SetRange(Blocked, false); // >> LCB-110 <<
        If Item.FindSet() then begin
            if not SendtoWS then
                ComestriIntegrationHelpers.InitialiseZipStream();

            NewStartDateTime := Item."GXL Bloyal Date Time Modified";
            ComestriIntegrationHelpers.SetSetup(IntegrationSetup);

            GlobalDT := CurrentDateTime();

            if ReProcess then
                StartRunDT := ComestriAzureLog."Sent Date Time"
            else
                StartRunDT := CurrentDateTime();

            InitialiseJsonObjectForProduct(JsonObjItem);
            repeat
                //Break the data into a chunk of max. number of records
                if (not ReProcess) and (MaxOfRecs <> 0) and (i > MaxOfRecs) then begin
                    ToBreak := true;
                    //Not to break if the Item UOM per item contains more records than the maximum allowed, 
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
                    JsonObjItem.WriteTo(OutS);

                    //Send to Azure LogicApp
                    NewEndDateTime := PrevDateTime;
                    AddAzureLogEntry(FileNo, NewStartDateTime, NewEndDateTime);
                    if SendtoWS then begin
                        ComestriIntegrationHelpers.PushToAzure(ComestriAzureLog, InS, false, '');
                    end else begin
                        //Send to file
                        FileName := StrSubstNo('Product_%1.json', FileNo);
                        ComestriIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                    end;

                    //Update Azure Log
                    ComestriAzureLog."No. Of Records Sent" := i;
                    ComestriAzureLog."Start Processed Date Time" := GlobalDT;
                    ComestriAzureLog.Modify();
                    Commit();

                    //Reset for the next set of records
                    i := 0;
                    FileNo += 1;
                    NewStartDateTime := Item."GXL Bloyal Date Time Modified";
                    Clear(JsonArrItem);
                    Clear(JsonObjItem);
                    InitialiseJsonObjectForProduct(JsonObjItem);
                end;

                i += 1;
                BuildJsonItem(Item, JsonObjItem);
                JsonArrItem.Add(JsonObjItem.Clone());
                PrevDateTime := Item."GXL Bloyal Date Time Modified";
            until Item.Next() = 0;

            if (i > 0) then begin
                Clear(TempBlob);
                // >> Upgrade
                // TempBlob.Blob.CreateInStream(InS);
                // TempBlob.Blob.CreateOutStream(OutS);
                TempBlob.CreateInStream(InS);
                TempBlob.CreateOutStream(OutS);
                // << Upgrade
                JsonArrItem.WriteTo(OutS);

                //Send to Azure LogicApp
                NewEndDateTime := PrevDateTime;
                if not ReProcess then
                    AddAzureLogEntry(FileNo, NewStartDateTime, NewEndDateTime);

                if SendtoWS then begin
                    ComestriIntegrationHelpers.PushToAzure(ComestriAzureLog, InS, false, '');
                end else
                    if SendtoSFTP then begin
                        //Send to file
                        Clear(JsonProdText);
                        FileName := StrSubstNo('Product_%1_%2.json', FileNo, CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-'));
                        IF IntegrationSetup."Comestri File download type" = IntegrationSetup."Comestri File download type"::Json then begin
                            ComestriIntegrationHelpers.UploadFiletoFTP(InS, false, FileName);
                            JsonObjProduct.Add('Filename', FileName);
                            JsonProdText := '{ "FileName": "' + FileName + '"}';
                        end else begin
                            ComestriIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                            ComestriIntegrationHelpers.UploadFiletoFTP(InS, true, StrSubstNo('Product_%1.zip', CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-')));
                            JsonObjProduct.Add('Filename', StrSubstNo('Product_%1.zip', CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-')));
                            JsonProdText := '{ "FileName": "' + StrSubstNo('Product_%1.zip', CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-')) + '"}';
                        end;
                        Clear(ProdTempBlob);
                        // >> Upgrade
                        // ProdTempBlob.Blob.CreateInStream(ProdIns);
                        // ProdTempBlob.Blob.CreateOutStream(ProdOuts);
                        ProdTempBlob.CreateInStream(ProdIns);
                        ProdTempBlob.CreateOutStream(ProdOuts);
                        // << Upgrade
                        JsonObjProduct.WriteTo(ProdOuts);
                        ComestriIntegrationHelpers.PushToAzure(ComestriAzureLog, ProdIns, true, JsonProdText);
                    end else begin
                        FileName := StrSubstNo('Product_%1.json', FileNo);
                        IF IntegrationSetup."Comestri File download type" = IntegrationSetup."Comestri File download type"::Json then begin
                            DownloadFromStream(InS, '', '', '', FileName);
                        end else begin
                            ComestriIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                            ComestriIntegrationHelpers.DownloadZipFiles('Product.zip', '');
                        end;
                    end;

                //Update Azure Log
                ComestriAzureLog."No. Of Records Sent" := i;
                ComestriAzureLog."Start Processed Date Time" := GlobalDT;
                ComestriAzureLog.Reset := false;
                ComestriAzureLog.Modify();
                Commit();
            end;

        end;

    end;

    /* procedure ProcessProduct(StartDateTime: DateTime; EndDateTime: DateTime; ReProcess: Boolean; SendtoWS: Boolean)
    var
        Item: Record Item;
    begin
        GetSetup();
        if IntegrationSetup."Comestri Product Template" = '' then
            exit;
        GetTemplateFields();

        if EndDateTime = 0DT then
            EndDateTime := CurrentDateTime();

        Item.SetCurrentKey("GXL Bloyal Date Time Modified");
        if ReProcess then
            Item.SetRange("GXL Bloyal Date Time Modified", StartDateTime, EndDateTime)
        else begin
            if StartDateTime <> 0DT then
                Item.SetFilter("GXL Bloyal Date Time Modified", '>%1&<=%2', StartDateTime, EndDateTime)
            else
                Item.SetRange("GXL Bloyal Date Time Modified", StartDateTime, EndDateTime);
        end;
        ProcessProduct(Item, ReProcess, SendtoWS);
    end; */

    local procedure GetTemplateFields()
    var
        DataTemplateHeader: Record "GXL ECS Data Template Header";
        DataTemplateMgt: Codeunit "GXL Data Template Management";
    begin
        GetSetup();
        if IntegrationSetup."Comestri Product Template" = '' then
            exit;
        DataTemplateHeader.Get(IntegrationSetup."Comestri Product Template");

        if not TemplateRead then begin
            ItemNameValueBuff.Reset();
            ItemNameValueBuff.DeleteAll();
            UOMNameValueBuff.Reset();
            UOMNameValueBuff.DeleteAll();
            BarcodesNameValueBuff.Reset();
            BarcodesNameValueBuff.DeleteAll();

            DataTemplateMgt.GetBloyalTemplateFields(IntegrationSetup."Comestri Product Template", Database::Item, ItemNameValueBuff);
            DataTemplateMgt.GetBloyalTemplateFields(IntegrationSetup."Comestri Product Template", Database::"Item Unit of Measure", UOMNameValueBuff);
            // >> Upgrade
            //DataTemplateMgt.GetBloyalTemplateFields(IntegrationSetup."Comestri Product Template", Database::Barcodes, BarcodesNameValueBuff);
            DataTemplateMgt.GetBloyalTemplateFields(IntegrationSetup."Comestri Product Template", Database::"LSC Barcodes", BarcodesNameValueBuff);
            // << Upgrade
            TemplateRead := true;
        end;

    end;

    local procedure InitialiseJsonObjectForProduct(JsonObjItem: JsonObject)
    begin
        if ItemNameValueBuff.FindSet() then begin
            repeat
                JsonObjItem.Add(ItemNameValueBuff.Value, '');
            until ItemNameValueBuff.Next() = 0;
            JsonObjItem.Add('GSTAmount', '');
            JsonObjItem.Add('Cross_ref', '');
            JsonObjItem.Add('Changedate', '');
        end;
    end;

    local procedure BuildJsonItem(var Item: Record Item; JsonObjItem: JsonObject)
    var
        ComestriIntegrationHelpers: Codeunit "GXL Comestri IntegrationHelper";
        RecRef: RecordRef;
        FldRef: FieldRef;
        ChangeDT: DateTime;
        GSTPct: Decimal;
    begin
        ChangeDT := Item."GXL Bloyal Date Time Modified";
        if ChangeDT = 0DT then
            ChangeDT := StartRunDT;
        ChangeDT := RoundDateTime(ChangeDT, 1000);

        RecRef.GetTable(Item);
        if ItemNameValueBuff.FindSet() then begin
            repeat
                FldRef := RecRef.Field(ItemNameValueBuff.ID);
                ComestriIntegrationHelpers.ReplaceFieldRefValueJsonObject(FldRef, ItemNameValueBuff.Value, JsonObjItem);
            until ItemNameValueBuff.Next() = 0;
            case Item."VAT Prod. Posting Group" of
                'GST':
                    GSTPct := 10;
                'FRE':
                    GSTPct := 0;
                else
                    GSTPct := -1;
            end;
            JsonObjItem.Replace('GSTAmount', GSTPct);

            BuildItemUOMJson(Item, JsonObjItem);

            JsonObjItem.Replace('Changedate', ChangeDT);
        end;
    end;

    local procedure InitialiseJsonObjectForUOM(JsonObjUOM: JsonObject)
    begin
        if UOMNameValueBuff.FindSet() then
            repeat
                JsonObjUOM.Add(UOMNameValueBuff.Value, '');
            until UOMNameValueBuff.Next() = 0;
        JsonObjUOM.Add('Barcodes', '')
    end;

    local procedure BuildItemUOMJson(Item: Record Item; JsonObjItem: JsonObject)
    var
        ItemUOM: Record "Item Unit of Measure";
        ComestriIntegrationHelpers: Codeunit "GXL Bloyal Integration Helpers";
        RecRef: RecordRef;
        FldRef: FieldRef;
        JsonArrUOM: JsonArray;
        JsonObjUOM: JsonObject;
    begin
        Clear(JsonObjUOM);
        InitialiseJsonObjectForUOM(JsonObjUOM);
        if UOMNameValueBuff.FindSet() then begin
            ItemUOM.SetRange("Item No.", Item."No.");
            if ItemUOM.FindSet() then
                repeat
                    RecRef.GetTable(ItemUOM);
                    UOMNameValueBuff.FindSet();
                    repeat
                        FldRef := RecRef.Field(UOMNameValueBuff.ID);
                        ComestriIntegrationHelpers.ReplaceFieldRefValueJsonObject(FldRef, UOMNameValueBuff.Value, JsonObjUOM);
                    until UOMNameValueBuff.Next() = 0;
                    BuildBarcodesJson(Item, ItemUOM, JsonObjUOM);
                    JsonArrUOM.Add(JsonObjUOM.Clone());
                until ItemUOM.Next() = 0;
            JsonObjItem.Replace('Cross_ref', JsonArrUOM);
        end;

    end;


    local procedure InitialiseJsonObjectForBarcodes(JsonObjBarcodes: JsonObject)
    begin
        if BarcodesNameValueBuff.FindSet() then
            repeat
                JsonObjBarcodes.Add(BarcodesNameValueBuff.Value, '');
            until BarcodesNameValueBuff.Next() = 0;
        //JsonObjBarcodes.Add('GTIN', '');
    end;

    local procedure BuildBarcodesJson(Item: Record Item; ItemUOM: Record "Item Unit of Measure"; JsonObjUOM: JsonObject)
    var
        Barcodes: Record "LSC Barcodes";
        ComestriIntegrationHelpers: Codeunit "GXL Comestri IntegrationHelper";
        RecRef: RecordRef;
        FldRef: FieldRef;
        JsonArrBarcodes: JsonArray;
        JsonObjBarcodes: JsonObject;
    //ItemRecL: Record Item;
    begin
        if BarcodesNameValueBuff.FindSet() then begin
            Clear(JsonObjBarcodes);
            InitialiseJsonObjectForBarcodes(JsonObjBarcodes);
            // >> LCB-279
            //Barcodes.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code");
            Barcodes.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code", "Show for Item");
            // << LCB-279
            Barcodes.SetRange("Item No.", ItemUOM."Item No.");
            Barcodes.SetRange("Unit of Measure Code", ItemUOM.Code);
            Barcodes.SetAscending("Show for Item", false); // >> LCB-279 <<
            if Barcodes.FindSet() then
                repeat
                    RecRef.GetTable(Barcodes);
                    BarcodesNameValueBuff.FindSet();
                    repeat
                        FldRef := RecRef.Field(BarcodesNameValueBuff.ID);
                        ComestriIntegrationHelpers.ReplaceFieldRefValueJsonObject(FldRef, BarcodesNameValueBuff.Value, JsonObjBarcodes);
                    until BarcodesNameValueBuff.Next() = 0;
                    //Removed as it caused error: duplicate key
                    //IF ItemRecL.Get(Barcodes."Item No.") then
                    //    if ItemRecL.GTIN <> '' then
                    //        JsonObjBarcodes.Add('Barcode_No', ItemRecL.GTIN);
                    //JsonObjBarcodes.Replace('GTIN', ItemRecL.GTIN);
                    JsonArrBarcodes.Add(JsonObjBarcodes.Clone());
                until Barcodes.Next() = 0;

            //Add the GTIN here
            if Item.GTIN <> '' then begin
                BarcodesNameValueBuff.FindSet();
                repeat
                    if BarcodesNameValueBuff.ID = Barcodes.FieldNo("Barcode No.") then
                        JsonObjBarcodes.Replace(BarcodesNameValueBuff.Value, Item.GTIN)
                    else
                        // >> Upgrade
                        //ComestriIntegrationHelpers.ReplaceBlankFieldRefJsonObject(Database::Barcodes, BarcodesNameValueBuff.ID, BarcodesNameValueBuff.Value, JsonObjBarcodes);
                        ComestriIntegrationHelpers.ReplaceBlankFieldRefJsonObject(Database::"LSC Barcodes", BarcodesNameValueBuff.ID, BarcodesNameValueBuff.Value, JsonObjBarcodes);
                // << Upgrade
                until BarcodesNameValueBuff.Next() = 0;
                JsonArrBarcodes.Add(JsonObjBarcodes.Clone());
            end;

        end;
        JsonObjUOM.Replace('Barcodes', JsonArrBarcodes);
    end;

    procedure GetLastEndDateTime(): DateTime
    var
        ComestriAzureLog2: Record "GXL Comestri Azure Log";
    begin
        ComestriAzureLog2.SetCurrentKey("End Date Time Modified");
        ComestriAzureLog2.SetRange("Web Service Name", ComestriAzureLog2."Web Service Name"::Product);
        if ComestriAzureLog2.FindLast() then begin
            if ComestriAzureLog2."End Date Time Modified" <> 0DT then
                exit(ComestriAzureLog2."End Date Time Modified")
            else begin
                if ComestriAzureLog2."Start Processed Date Time" <> 0DT then
                    exit(ComestriAzureLog2."Start Processed Date Time")
                else
                    exit(ComestriAzureLog2."Sent Date Time");
            end;
        end else
            exit(0DT);
    end;

    local procedure AddAzureLogEntry(FileNo: Integer; StartDateTime: DateTime; EndDateTime: DateTime)
    begin
        ComestriAzureLog.InitAzureLogEntry(ComestriAzureLog."Web Service Name"::Product, FileNo, StartDateTime, EndDateTime);
        ComestriAzureLog.Insert(true);
    end;

    procedure ReProcessProduct(var _ComestriAzureLog: Record "GXL Comestri Azure Log")
    var
        ComestriAzureLog2: Record "GXL Comestri Azure Log";
    begin
        ComestriAzureLog2.Copy(_ComestriAzureLog);
        ComestriAzureLog2.SetCurrentKey(Reset);
        ComestriAzureLog2.SetRange(Reset, true);
        ComestriAzureLog2.SetRange("Web Service Name", ComestriAzureLog2."Web Service Name"::Product);
        if ComestriAzureLog2.FindSet() then begin
            GetTemplateFields();
            repeat
                ComestriAzureLog := ComestriAzureLog2;
                //ProcessProduct(ComestriAzureLog."Start Date Time Modified", ComestriAzureLog."End Date Time Modified", true, true);
                //WRP-1013+
                //if IntegrationSetup."Comestri Send Data to" = IntegrationSetup."Comestri Send Data to"::"End Point" then
                if IntegrationSetup."Comestri Product Send to" = IntegrationSetup."Comestri Product Send to"::"End Point" then
                    //WRP-1013-
                    ProcessProduct(true, true, false)
                else
                    ProcessProduct(true, false, true);

            until ComestriAzureLog2.Next() = 0;
        end;
    end;

    procedure SetComestriAzureLog(_ComestriAzureLog: Record "GXL Comestri Azure Log")
    begin
        ComestriAzureLog := _ComestriAzureLog;
    end;

    local procedure GetSetup()
    begin
        if not SetupRead then begin
            IntegrationSetup.Get();
            SetupRead := true;
        end;
    end;


}