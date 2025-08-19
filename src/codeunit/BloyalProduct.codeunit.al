// Change log
// LCB-96 STH 24/7/22  Product feed barcode - Primary barcode should appear before secondary.
// LCB-110 Codeunit 50173 - GXL Bloyal Product / Codeunit 50482 GXL Comestri Product Stop Block Items
codeunit 50173 "GXL Bloyal Product"
{
    TableNo = "Job Queue Entry";
    Permissions = tabledata "GXL Bloyal Azure Log" = rmid;

    trigger OnRun()
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
        //FromDateTime: DateTime;
        FromEntryNo: Integer;
    begin

        ClearAll();
        GetSetup();
        if IntegrationSetup."Bloyal Product Template" = '' then
            exit;

        GetTemplateFields();

        //Re-Process all the Reset entries
        BloyalAzureLog2.SetCurrentKey(Reset);
        BloyalAzureLog2.SetRange(Reset, true);
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::Product);
        BloyalAzureLog2.SetFilter("Start Entry No.", '<>0'); //WRP-397
        ReProcessProduct(BloyalAzureLog2);

        //Process the new entries
        //WRP-397+
        //FromDateTime := GetLastEndDateTime();
        //ProcessProduct(FromDateTime, 0DT, false, true);
        FromEntryNo := GetNextEntryNo();
        ProcessProduct(FromEntryNo, 0, false, true);
        //WRP-397-
    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        BloyalAzureLog: Record "GXL Bloyal Azure Log";
        ItemNameValueBuff: Record "Name/Value Buffer" temporary;
        UOMNameValueBuff: Record "Name/Value Buffer" temporary;
        BarcodesNameValueBuff: Record "Name/Value Buffer" temporary;
        SetupRead: Boolean;
        TemplateRead: Boolean;
        StartRunDT: DateTime;
        GlobalDT: DateTime;


    ///<Summary>
    ///Process to use Item table to send data over. It is an initial data feed
    ///</Summary>
    procedure ProcessProduct(var Item: Record Item; ReProcess: Boolean; SendtoWS: Boolean)
    var
        // >> Upgrade
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        // << Upgrade
        BloyalIntegrationHelpers: Codeunit "GXL Bloyal Integration Helpers";
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
        ChangeLogDT: DateTime;
    begin
        GetSetup();
        if IntegrationSetup."Bloyal Product Template" = '' then
            exit;
        GetTemplateFields();

        MaxOfRecs := IntegrationSetup."Bloyal Product Max Records";

        FileNo := 1;
        i := 0;
        PrevDateTime := 0DT;
        Item.SetRange(Blocked, false); // >> LCB-110 <<
        If Item.FindSet() then begin
            if not SendtoWS then
                BloyalIntegrationHelpers.InitialiseZipStream();

            NewStartDateTime := Item."GXL Bloyal Date Time Modified";
            BloyalIntegrationHelpers.SetSetup(IntegrationSetup);

            GlobalDT := CurrentDateTime();

            if ReProcess then
                StartRunDT := BloyalAzureLog."Sent Date Time"
            else
                StartRunDT := CurrentDateTime();

            InitialiseJsonObjectForProduct(JsonObjItem);
            repeat
                //Break the data into a chunk of max. number of records
                //WRP-1176 >>
                //Issue: number of records split is more than max
                // if (not ReProcess) and (MaxOfRecs <> 0) and (i > MaxOfRecs) then begin
                if (not ReProcess) and (MaxOfRecs <> 0) and (i >= MaxOfRecs) then begin
                    //WRP-1176 <<
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
                    //WRP-1176 >>
                    //Issue: wrong object reference was used, should have been an array
                    // JsonObjItem.WriteTo(OutS);
                    JsonArrItem.WriteTo(OutS);
                    //WRP-1176 <<

                    //Send to Azure LogicApp
                    NewEndDateTime := PrevDateTime;
                    AddAzureLogEntry(FileNo, NewStartDateTime, NewEndDateTime);
                    if SendtoWS then begin
                        BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                    end else begin
                        //Send to file
                        FileName := StrSubstNo('Product_%1.json', FileNo);
                        BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                    end;

                    //Update Azure Log
                    BloyalAzureLog."No. Of Records Sent" := i;
                    BloyalAzureLog."Start Processed Date Time" := GlobalDT;
                    BloyalAzureLog."Sent Date Time" := CurrentDateTime();
                    BloyalAzureLog.Modify();
                    Commit();

                    //Reset for the next set of records
                    i := 0;
                    FileNo += 1;
                    NewStartDateTime := Item."GXL Bloyal Date Time Modified";
                    Clear(JsonArrItem);
                    Clear(JsonObjItem);
                    InitialiseJsonObjectForProduct(JsonObjItem);
                    GlobalDT := CurrentDateTime();
                end;

                i += 1;
                ChangeLogDT := Item."GXL Bloyal Date Time Modified";
                if ChangeLogDT = 0DT then
                    ChangeLogDT := Item."Last DateTime Modified";

                BuildJsonItem(Item, JsonObjItem, ChangeLogDT);
                JsonArrItem.Add(JsonObjItem.Clone());
                PrevDateTime := ChangeLogDT;
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
                    BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                end else begin
                    //Send to file
                    FileName := StrSubstNo('Product_%1.json', FileNo);
                    BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                    BloyalIntegrationHelpers.DownloadZipFiles('Product.zip');
                end;

                //Update Azure Log
                BloyalAzureLog."No. Of Records Sent" := i;
                BloyalAzureLog."Start Processed Date Time" := GlobalDT;
                BloyalAzureLog."Sent Date Time" := CurrentDateTime();
                BloyalAzureLog.Reset := false;
                BloyalAzureLog.Modify();
                Commit();
            end;

        end;

    end;

    //WRP-397+
    //Removed
    /*
    procedure ProcessProduct(StartDateTime: DateTime; EndDateTime: DateTime; ReProcess: Boolean; SendtoWS: Boolean)
    var
        Item: Record Item;
    begin
        GetSetup();
        if IntegrationSetup."Bloyal Product Template" = '' then
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
    end;
    */

    //Restructured to use Bloyal Product Change Log table
    ///<Summary>
    ///Process to use Bloyal Product Change Log to send data over. It is a delta feed
    ///</Summary>
    procedure ProcessProduct(StartEntryNo: Integer; EndEntryNo: Integer; ReProcess: Boolean; SendtoWS: Boolean)
    var
        BloyalProdChangeLog: Record "GXL Bloyal Product Change Log";
        Item: Record Item;
        // >> Upgrade
        //TempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        // << Upgrade
        BloyalIntegrationHelpers: Codeunit "GXL Bloyal Integration Helpers";
        JsonArrItem: JsonArray;
        JsonObjItem: JsonObject;
        i: Integer;
        MaxOfRecs: Integer;
        FileNo: Integer;
        PrevEntryNo: Integer;
        NewStartEntryNo: Integer;
        NewEndEntryNo: Integer;
        InS: InStream;
        OutS: OutStream;
        ToBreak: Boolean;
        FileName: Text;
    begin
        GetSetup();
        if IntegrationSetup."Bloyal Product Template" = '' then
            exit;
        GetTemplateFields();

        MaxOfRecs := IntegrationSetup."Bloyal Product Max Records";

        FileNo := 1;
        i := 0;
        PrevEntryNo := 0;

        BloyalProdChangeLog.Reset();
        if (EndEntryNo <> 0) then
            BloyalProdChangeLog.SetRange("Entry No.", StartEntryNo, EndEntryNo)
        else
            BloyalProdChangeLog.SetFilter("Entry No.", '>=%1', StartEntryNo);
        if BloyalProdChangeLog.FindLast() then begin
            EndEntryNo := BloyalProdChangeLog."Entry No.";
            BloyalProdChangeLog.SetRange("Entry No.", StartEntryNo, EndEntryNo);
        end;
        If BloyalProdChangeLog.FindSet() then begin
            if not SendtoWS then
                BloyalIntegrationHelpers.InitialiseZipStream();

            NewStartEntryNo := BloyalProdChangeLog."Entry No.";
            BloyalIntegrationHelpers.SetSetup(IntegrationSetup);

            GlobalDT := CurrentDateTime();

            InitialiseJsonObjectForProduct(JsonObjItem);
            repeat
                //Break the data into a chunk of max. number of records
                //WRP-1176 >>
                //Issue: number of records split is more than max
                // if (not ReProcess) and (MaxOfRecs <> 0) and (i > MaxOfRecs) then begin
                if (not ReProcess) and (MaxOfRecs <> 0) and (i >= MaxOfRecs) then begin
                    //WRP-1176 <<
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
                    //WRP-1176 >>
                    //Issue: wrong object reference was used, should have been an array
                    // JsonObjItem.WriteTo(OutS);
                    JsonArrItem.WriteTo(OutS);
                    //WRP-1176 <<

                    //Send to Azure LogicApp
                    NewEndEntryNo := PrevEntryNo;
                    AddAzureLogEntry(FileNo, NewStartEntryNo, NewEndEntryNo);
                    if SendtoWS then begin
                        BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                    end else begin
                        //Send to file
                        FileName := StrSubstNo('Product_%1.json', FileNo);
                        BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                    end;

                    //Update Azure Log
                    BloyalAzureLog."No. Of Records Sent" := i;
                    BloyalAzureLog."Start Processed Date Time" := GlobalDT;
                    BloyalAzureLog.Modify();
                    Commit();

                    //Reset for the next set of records
                    i := 0;
                    FileNo += 1;
                    NewStartEntryNo := BloyalProdChangeLog."Entry No.";
                    Clear(JsonArrItem);
                    Clear(JsonObjItem);
                    InitialiseJsonObjectForProduct(JsonObjItem);
                end;

                if Item.Get(BloyalProdChangeLog."Item No.") then begin
                    IF NOT Item.Blocked then begin  // >> LCB-110
                        i += 1;
                        BuildJsonItem(Item, JsonObjItem, BloyalProdChangeLog."Log Date Time");
                        JsonArrItem.Add(JsonObjItem.Clone());
                        PrevEntryNo := BloyalProdChangeLog."Entry No.";
                    end;    // << LCB-110
                end;
            until BloyalProdChangeLog.Next() = 0;

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
                NewEndEntryNo := PrevEntryNo;
                if not ReProcess then
                    AddAzureLogEntry(FileNo, NewStartEntryNo, NewEndEntryNo);
                if SendtoWS then begin
                    BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                end else begin
                    //Send to file
                    FileName := StrSubstNo('Product_%1.json', FileNo);
                    BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                    BloyalIntegrationHelpers.DownloadZipFiles('Product.zip');
                end;

                //Update Azure Log
                BloyalAzureLog."No. Of Records Sent" := i;
                BloyalAzureLog."Start Processed Date Time" := GlobalDT;
                BloyalAzureLog.Reset := false;
                BloyalAzureLog.Modify();
                Commit();
            end;
        end;

    end;
    //WRP-397-


    local procedure GetTemplateFields()
    var
        DataTemplateHeader: Record "GXL ECS Data Template Header";
        DataTemplateMgt: Codeunit "GXL Data Template Management";
    begin
        GetSetup();
        if IntegrationSetup."Bloyal Product Template" = '' then
            exit;
        DataTemplateHeader.Get(IntegrationSetup."Bloyal Product Template");

        if not TemplateRead then begin
            ItemNameValueBuff.Reset();
            ItemNameValueBuff.DeleteAll();
            UOMNameValueBuff.Reset();
            UOMNameValueBuff.DeleteAll();
            BarcodesNameValueBuff.Reset();
            BarcodesNameValueBuff.DeleteAll();

            DataTemplateMgt.GetBloyalTemplateFields(IntegrationSetup."Bloyal Product Template", Database::Item, ItemNameValueBuff);
            DataTemplateMgt.GetBloyalTemplateFields(IntegrationSetup."Bloyal Product Template", Database::"Item Unit of Measure", UOMNameValueBuff);
            // >> Upgrade
            //DataTemplateMgt.GetBloyalTemplateFields(IntegrationSetup."Bloyal Product Template", Database::Barcodes, BarcodesNameValueBuff);
            DataTemplateMgt.GetBloyalTemplateFields(IntegrationSetup."Bloyal Product Template", Database::"LSC Barcodes", BarcodesNameValueBuff);
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

    local procedure BuildJsonItem(var Item: Record Item; JsonObjItem: JsonObject; ChangeLogDT: DateTime)
    var
        BloyalIntegrationHelpers: Codeunit "GXL Bloyal Integration Helpers";
        RecRef: RecordRef;
        FldRef: FieldRef;
        ChangeDT: DateTime;
        GSTPct: Decimal;
    begin

        //WRP-397+
        //ChangeDT := Item."GXL Bloyal Date Time Modified";
        ChangeDT := ChangeLogDT;
        //WRP-397-

        if ChangeDT = 0DT then
            ChangeDT := StartRunDT;
        ChangeDT := RoundDateTime(ChangeDT, 1000);

        RecRef.GetTable(Item);
        if ItemNameValueBuff.FindSet() then begin
            repeat
                FldRef := RecRef.Field(ItemNameValueBuff.ID);
                BloyalIntegrationHelpers.ReplaceFieldRefValueJsonObject(FldRef, ItemNameValueBuff.Value, JsonObjItem);
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
        BloyalIntegrationHelpers: Codeunit "GXL Bloyal Integration Helpers";
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
                        BloyalIntegrationHelpers.ReplaceFieldRefValueJsonObject(FldRef, UOMNameValueBuff.Value, JsonObjUOM);
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
    end;

    local procedure BuildBarcodesJson(Item: Record Item; ItemUOM: Record "Item Unit of Measure"; JsonObjUOM: JsonObject)
    var
        Barcodes: Record "LSC Barcodes";
        BloyalIntegrationHelpers: Codeunit "GXL Bloyal Integration Helpers";
        RecRef: RecordRef;
        FldRef: FieldRef;
        JsonArrBarcodes: JsonArray;
        JsonObjBarcodes: JsonObject;
    begin
        if BarcodesNameValueBuff.FindSet() then begin
            Clear(JsonObjBarcodes);
            InitialiseJsonObjectForBarcodes(JsonObjBarcodes);
            // >> LCB-96
            // Barcodes.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code");
            Barcodes.SetCurrentKey("Item No.", "Variant Code", "Unit of Measure Code", "Show for Item");
            Barcodes.SetAscending("Show for Item", false);
            // << LCB-96
            Barcodes.SetRange("Item No.", ItemUOM."Item No.");
            Barcodes.SetRange("Unit of Measure Code", ItemUOM.Code);
            if Barcodes.FindSet() then
                repeat
                    RecRef.GetTable(Barcodes);
                    BarcodesNameValueBuff.FindSet();
                    repeat
                        FldRef := RecRef.Field(BarcodesNameValueBuff.ID);
                        BloyalIntegrationHelpers.ReplaceFieldRefValueJsonObject(FldRef, BarcodesNameValueBuff.Value, JsonObjBarcodes);
                    until BarcodesNameValueBuff.Next() = 0;
                    //Removed as it caused error: duplicate key
                    //Comestri Mods
                    // IF ItemRecL.Get(Barcodes."Item No.") then
                    //     if ItemRecL.GTIN <> '' then
                    //         JsonObjBarcodes.Add('Barcode_No', ItemRecL.GTIN);
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
                        //BloyalIntegrationHelpers.ReplaceBlankFieldRefJsonObject(Database::Barcodes, BarcodesNameValueBuff.ID, BarcodesNameValueBuff.Value, JsonObjBarcodes);
                        BloyalIntegrationHelpers.ReplaceBlankFieldRefJsonObject(Database::"LSC Barcodes", BarcodesNameValueBuff.ID, BarcodesNameValueBuff.Value, JsonObjBarcodes);
                // << Upgrade
                until BarcodesNameValueBuff.Next() = 0;
                JsonArrBarcodes.Add(JsonObjBarcodes.Clone());
            end;

        end;
        JsonObjUOM.Replace('Barcodes', JsonArrBarcodes);
    end;

    procedure GetLastEndDateTime(): DateTime
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog2.SetCurrentKey("End Date Time Modified");
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::Product);
        if BloyalAzureLog2.FindLast() then begin
            if BloyalAzureLog2."End Date Time Modified" <> 0DT then
                exit(BloyalAzureLog2."End Date Time Modified")
            else begin
                if BloyalAzureLog2."Start Processed Date Time" <> 0DT then
                    exit(BloyalAzureLog2."Start Processed Date Time")
                else
                    exit(BloyalAzureLog2."Sent Date Time");
            end;
        end else
            exit(0DT);
    end;

    local procedure AddAzureLogEntry(FileNo: Integer; StartDateTime: DateTime; EndDateTime: DateTime)
    begin
        BloyalAzureLog.InitAzureLogEntry(BloyalAzureLog."Web Service Name"::Product, FileNo, StartDateTime, EndDateTime);
        BloyalAzureLog.Insert(true);
    end;

    //WRP-397+
    //Restructured to use Bloyal Product Change Log table
    local procedure AddAzureLogEntry(FileNo: Integer; FromEntryNo: Integer; ToEntryNo: Integer)
    begin
        BloyalAzureLog.InitAzureLogEntry(BloyalAzureLog."Web Service Name"::Product, FileNo, FromEntryNo, ToEntryNo);
        BloyalAzureLog.Insert(true);
    end;

    procedure GetNextEntryNo(): Integer
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog2.SetCurrentKey("End Entry No.");
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::Product);
        if BloyalAzureLog2.FindLast() then
            exit(BloyalAzureLog2."End Entry No." + 1)
        else
            exit(1);
    end;
    //WRP-397-

    procedure ReProcessProduct(var _BloyalAzureLog: Record "GXL Bloyal Azure Log")
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog2.Copy(_BloyalAzureLog);
        BloyalAzureLog2.SetCurrentKey(Reset);
        BloyalAzureLog2.SetRange(Reset, true);
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::Product);
        if BloyalAzureLog2.FindSet() then begin
            GetTemplateFields();
            repeat
                BloyalAzureLog := BloyalAzureLog2;
                //WRP-397+
                //ProcessProduct(BloyalAzureLog."Start Date Time Modified", BloyalAzureLog."End Date Time Modified", true, true);
                ProcessProduct(BloyalAzureLog."Start Entry No.", BloyalAzureLog."End Entry No.", true, true);
            //WRP-397-
            until BloyalAzureLog2.Next() = 0;
        end;
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