codeunit 50481 "GXL Comestri SOH"
{
    /* Change Log
        WRP-287 2020-09-18 LP
            This is full feed for SOH, means all SOH for all active SKUs are to be extracted
        ERP-366 2021-09-01 LP
            Locking because of long running process
            Changed default TransactionType to Browse
        PS-2683 2021-10-15 LP: Add integration events
    */

    TableNo = "Job Queue Entry";
    Permissions = tabledata "GXL Comestri Azure Log" = rmid;

    trigger OnRun()
    var

    //ComestriAzureLog2: Record "GXL Comestri Azure Log";
    //FromEntryNo: Integer;
    begin

        ClearAll();
        GetSetup();

        //WRP-287+
        //Removed as re-process is not applicable for full feed
        /*
        //Re-Process all the Reset entries
        ComestriAzureLog2.SetCurrentKey(Reset);
        ComestriAzureLog2.SetRange(Reset, true);
        ComestriAzureLog2.SetRange("Web Service Name", ComestriAzureLog2."Web Service Name"::SOH);
        ReProcessSOH(ComestriAzureLog2);
        */
        //WRP-287-

        //Process the new entries
        //Note: this process is based on SOH Staging Data table, means the SOH process must be run before this process.
        //WRP-287+
        //FromEntryNo := GetNextEntryNo();
        //WRP-287-
        if IntegrationSetup."Comestri Send Data to" = IntegrationSetup."Comestri Send Data to"::"End Point" then
            ProcessSOH(false, true, false)
        else
            ProcessSOH(false, false, true);

    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        ComestriAzureLog: Record "GXL Comestri Azure Log";
        SetupRead: Boolean;
        GlobalDT: DateTime;



    //WRP-287 +
    //Restrured as it is a full feed
    // procedure ProcessSOH(ReProcess: Boolean; SendtoWS: Boolean; SendtoSFTP: Boolean)
    // var
    //     SOHStagingData: Record "GXL SOH Staging Data";
    //     TempBlob: Record TempBlob;
    //     ComestriIntegrationHelpers: Codeunit "GXL Comestri IntegrationHelper";
    //     JsonArrItem: JsonArray;
    //     JsonObjItem: JsonObject;
    //     i: Integer;
    //     MaxOfRecs: Integer;
    //     FileNo: Integer;
    //     PrevEntryNo: Integer;
    //     NewStartEntryNo: Integer;
    //     NewEndEntryNo: Integer;
    //     InS: InStream;
    //     OutS: OutStream;
    //     ToBreak: Boolean;
    //     FileName: Text;
    //     JsonobjSOH: JsonObject;
    //     SOHIns: InStream;
    //     SOHOuts: OutStream;
    //     SOHTempBlob: Record TempBlob;
    //     JsonSOHText: Text;
    // begin
    //     GetSetup();
    //     //MaxOfRecs := IntegrationSetup."Bloyal SOH Max Records";

    //     FileNo := 1;
    //     PrevEntryNo := 0;
    //     i := 0;

    //     SOHStagingData.SetCurrentKey("Auto ID");
    //     /* if (EndEntryNo <> 0) then
    //         SOHStagingData.SetRange("Auto ID", StartEntryNo, EndEntryNo)
    //     else
    //         SOHStagingData.SetFilter("Auto ID", '>=%1', StartEntryNo);
    //     if SOHStagingData.FindLast() then begin
    //         EndEntryNo := SOHStagingData."Auto ID";
    //         SOHStagingData.SetRange("Auto ID", StartEntryNo, EndEntryNo);
    //     end; */
    //     if SOHStagingData.FindSet() then begin
    //         if not SendtoWS then
    //             ComestriIntegrationHelpers.InitialiseZipStream();

    //         GlobalDT := CurrentDateTime();

    //         NewStartEntryNo := SOHStagingData."Auto ID";
    //         ComestriIntegrationHelpers.SetSetup(IntegrationSetup);
    //         InitialiseJsonObjectForSOH(JsonObjItem);
    //         repeat
    //             //Break the data into a chunk of max. number of records
    //             if (not ReProcess) and (MaxOfRecs <> 0) and (i >= MaxOfRecs) then
    //                 ToBreak := true
    //             else
    //                 ToBreak := false;

    //             if ToBreak then begin

    //                 Clear(TempBlob);
    //                 TempBlob.Blob.CreateInStream(InS);
    //                 TempBlob.Blob.CreateOutStream(OutS);
    //                 JsonObjItem.WriteTo(OutS);

    //                 //Send to Azure LogicApp
    //                 NewEndEntryNo := PrevEntryNo;
    //                 AddAzureLogEntry(FileNo, NewStartEntryNo, NewEndEntryNo);
    //                 if SendtoWS then begin
    //                     ComestriIntegrationHelpers.PushToAzure(ComestriAzureLog, InS, false, '');
    //                 end else begin
    //                     //Send to File
    //                     FileName := StrSubstNo('SOH_%1.json', FileNo);
    //                     ComestriIntegrationHelpers.AddFileStreamToZip(InS, FileName);
    //                 end;

    //                 //Update Azure Log
    //                 ComestriAzureLog."No. Of Records Sent" := i;
    //                 ComestriAzureLog."Start Processed Date Time" := GlobalDT;
    //                 ComestriAzureLog.Modify();
    //                 Commit();

    //                 //Reset for the next set of records
    //                 i := 0;
    //                 FileNo += 1;
    //                 NewStartEntryNo := SOHStagingData."Auto ID";
    //                 Clear(JsonArrItem);
    //                 Clear(JsonObjItem);
    //                 InitialiseJsonObjectForSOH(JsonObjItem);
    //             end;

    //             i += 1;
    //             BuildJsonSOH(SOHStagingData, JsonObjItem);
    //             JsonArrItem.Add(JsonObjItem.Clone());
    //             PrevEntryNo := SOHStagingData."Auto ID";
    //         until SOHStagingData.Next() = 0;

    //         if (i > 0) then begin
    //             Clear(TempBlob);
    //             TempBlob.Blob.CreateInStream(InS);
    //             TempBlob.Blob.CreateOutStream(OutS);
    //             JsonArrItem.WriteTo(OutS);

    //             //Send to Azure LogicApp
    //             NewEndEntryNo := PrevEntryNo;
    //             if not ReProcess then
    //                 AddAzureLogEntry(FileNo, NewStartEntryNo, NewEndEntryNo);
    //             /* if SendtoWS then begin
    //                 ComestriIntegrationHelpers.PushToAzure(ComestriAzureLog, InS);
    //             end else begin
    //                 //Send to File
    //                 FileName := StrSubstNo('SOH_%1.json', FileNo);
    //                 IF IntegrationSetup."Comestri File download type" = IntegrationSetup."Comestri File download type"::Json then
    //                     DownloadFromStream(InS, '', '', '', FileName)
    //                 else begin
    //                     ComestriIntegrationHelpers.AddFileStreamToZip(InS, FileName);
    //                     ComestriIntegrationHelpers.DownloadZipFiles('SOH.zip', '');
    //                 end;
    //             end; */
    //             if SendtoWS then begin
    //                 ComestriIntegrationHelpers.PushToAzure(ComestriAzureLog, InS, false, '');
    //             end else
    //                 if SendtoSFTP then begin
    //                     //Send to file
    //                     Clear(JsonSOHText);
    //                     FileName := StrSubstNo('SOH_%1_%2.json', FileNo, CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-'));
    //                     IF IntegrationSetup."Comestri File download type" = IntegrationSetup."Comestri File download type"::Json then begin
    //                         ComestriIntegrationHelpers.UploadFiletoFTP(InS, false, FileName);
    //                         JsonobjSOH.Add('FileName', FileName);
    //                         JsonSOHText := '{ "FileName": "' + FileName + '"}';
    //                     end else begin
    //                         ComestriIntegrationHelpers.AddFileStreamToZip(InS, FileName);
    //                         ComestriIntegrationHelpers.UploadFiletoFTP(InS, true, StrSubstNo('SOH_%1.zip', CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-')));
    //                         JsonobjSOH.Add('FileName', StrSubstNo('SOH_%1.zip', CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-')));
    //                         JsonSOHText := '{ "FileName": "' + StrSubstNo('SOH_%1.zip', CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-')) + '"}';
    //                     end;
    //                     Clear(SOHTempBlob);
    //                     SOHTempBlob.Blob.CreateInStream(SOHIns);
    //                     SOHTempBlob.Blob.CreateOutStream(SOHOuts);
    //                     JsonobjSOH.WriteTo(SOHOuts);
    //                     ComestriIntegrationHelpers.PushToAzure(ComestriAzureLog, SOHIns, true, JsonSOHText);
    //                 end else begin
    //                     FileName := StrSubstNo('SOH_%1.json', FileNo);
    //                     IF IntegrationSetup."Comestri File download type" = IntegrationSetup."Comestri File download type"::Json then begin
    //                         DownloadFromStream(InS, '', '', '', FileName);
    //                     end else begin
    //                         ComestriIntegrationHelpers.AddFileStreamToZip(InS, FileName);
    //                         ComestriIntegrationHelpers.DownloadZipFiles('SOH.zip', '');
    //                     end;
    //                 end;

    //             //Update Azure Log
    //             ComestriAzureLog."No. Of Records Sent" := i;
    //             ComestriAzureLog."Start Processed Date Time" := GlobalDT;
    //             ComestriAzureLog.Reset := false;
    //             ComestriAzureLog.Modify();
    //             Commit();

    //         end;
    //     end;
    // end;


    procedure ProcessSOH(ReProcess: Boolean; SendtoWS: Boolean; SendtoSFTP: Boolean)
    var
        TempSOHStagingData: Record "GXL SOH Staging Data" temporary;
        Store: Record "LSC Store";
        Item: Record Item;
        ItemUOM: Record "Item Unit of Measure";
        // >> Upgrade
        // TempBlob: Record TempBlob;
        // SOHTempBlob: Record TempBlob;
        TempBlob: Codeunit "Temp Blob";
        SOHTempBlob: Codeunit "Temp Blob";
        // << Upgrade
        ComestriIntegrationHelpers: Codeunit "GXL Comestri IntegrationHelper";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        JsonArrItem: JsonArray;
        JsonObjItem: JsonObject;
        i: Integer;
        FileNo: Integer;
        PrevEntryNo: Integer;
        NewStartEntryNo: Integer;
        NewEndEntryNo: Integer;
        InS: InStream;
        OutS: OutStream;
        JsonobjSOH: JsonObject;
        SOHIns: InStream;
        SOHOuts: OutStream;
        JsonSOHText: Text;
        FileName: Text;
        LogTime: Time;
        Windows: Dialog;
        QtyBase: Decimal;
    begin
        //ERP-366 +
        //default TransactionType before commit is UpdateNoLocks
        //Change to a less isolated transaction = browse, i.e., read uncommitted transaction type, 
        //  note: dirty reads may occur
        //Before change to a less isolated TrannsactionType, need a commit, otherwise system will ignore the change
        //  Note: because of this commit, make sure that nothing before this function call that have a write to the database
        Commit();
        CurrentTransactionType := CurrentTransactionType::Browse;
        //ERP-366 -

        GetSetup();

        FileNo := 1;
        PrevEntryNo := 0;
        i := 0;
        NewStartEntryNo := 0;

        LogTime := Time();
        Store.SetFilter("Location Code", '<>%1', '');
        if IntegrationSetup."Live Store Only" then
            Store.SetRange("GXL LS Live Store", true);
        if Store.FindSet() then begin
            if GuiAllowed() then
                Windows.Open(
                    'Processing SOH\\' +
                    'Store          #1#########\'
                );

            if not SendtoWS then
                ComestriIntegrationHelpers.InitialiseZipStream();

            GlobalDT := CurrentDateTime();
            ComestriIntegrationHelpers.SetSetup(IntegrationSetup);
            InitialiseJsonObjectForSOH(JsonObjItem);
            repeat
                if GuiAllowed() then
                    Windows.Update(1, Store."No.");

                Item.Reset();
                Item.SetRange("Location Filter", Store."Location Code");
                Item.SetFilter(Inventory, '>0');
                Item.SetAutoCalcFields(Inventory);

                // >> lcb-23
                item.SetRange(Blocked, false);
                // << lcb-23

                // if Item.FindSet() then //ERP-366 -
                if Item.Find('-') then //ERP-366 +
                    repeat
                        QtyBase := Item.Inventory;

                        //PS-2683 +
                        OnAfterInventoryCalculation(Item, QtyBase);
                        //PS-2683 -

                        ItemUOM.Reset();
                        ItemUOM.SetRange("Item No.", Item."No.");
                        ItemUOM.SetFilter("GXL Legacy Item No.", '<>%1', '');
                        if ItemUOM.FindSet() then
                            repeat
                                //Use SOHStagingData as buffer
                                Clear(TempSOHStagingData);
                                TempSOHStagingData."Item No." := Item."No.";
                                TempSOHStagingData."Legacy Item No." := ItemUOM."GXL Legacy Item No.";
                                TempSOHStagingData."Location Code" := Store."Location Code";
                                TempSOHStagingData."Store Code" := Store."No.";
                                TempSOHStagingData.UOM := ItemUOM.Code;
                                TempSOHStagingData."New Qty." := LegacyItemHelpers.CalculateLegacyItemQty(ItemUOM, QtyBase);
                                TempSOHStagingData."Log Date" := Today();
                                TempSOHStagingData."Log Time" := LogTime;

                                i += 1;
                                BuildJsonSOH(TempSOHStagingData, Item.Description, JsonObjItem);
                                JsonArrItem.Add(JsonObjItem.Clone());
                            until ItemUOM.Next() = 0;
                    until Item.Next() = 0;
                Commit(); //ERP-366 +
            until Store.Next() = 0;

            if GuiAllowed() then
                Windows.Close();

            //ERP-366 +
            //Change TransactionType to UpdateNoLocks (a default) so that a write is possible (write a log entry)
            //Before change back to a more isolated transaction type, need to commit
            Commit();
            CurrentTransactionType := TransactionType::UpdateNoLocks;
            //ERP-366 -
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
                    ComestriIntegrationHelpers.PushToAzure(ComestriAzureLog, InS, false, '');
                end else
                    if SendtoSFTP then begin
                        //Send to SOH details to file and put to SFTP folder
                        //Create a json or text format to have file folder/name to be sent to endpoint
                        Clear(JsonSOHText);
                        FileName := StrSubstNo('SOH_%1_%2.json', FileNo, CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-'));
                        IF IntegrationSetup."Comestri File download type" = IntegrationSetup."Comestri File download type"::Json then begin
                            ComestriIntegrationHelpers.UploadFiletoFTP(InS, false, FileName);
                            JsonobjSOH.Add('FileName', FileName);
                            JsonSOHText := '{ "FileName": "' + FileName + '"}';
                        end else begin
                            ComestriIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                            ComestriIntegrationHelpers.UploadFiletoFTP(InS, true, StrSubstNo('SOH_%1.zip', CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-')));
                            JsonobjSOH.Add('FileName', StrSubstNo('SOH_%1.zip', CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-')));
                            JsonSOHText := '{ "FileName": "' + StrSubstNo('SOH_%1.zip', CONVERTSTR(FORMAT(Today), '/', '-') + '_' + CONVERTSTR(FORMAT(TIME), ':', '-')) + '"}';
                        end;
                        Clear(SOHTempBlob);
                        // >> Upgrade
                        // SOHTempBlob.Blob.CreateInStream(SOHIns);
                        // SOHTempBlob.Blob.CreateOutStream(SOHOuts);
                        SOHTempBlob.CreateInStream(SOHIns);
                        SOHTempBlob.CreateOutStream(SOHOuts);
                        // << Upgrade
                        JsonobjSOH.WriteTo(SOHOuts);
                        ComestriIntegrationHelpers.PushToAzure(ComestriAzureLog, SOHIns, true, JsonSOHText);
                    end else begin
                        FileName := StrSubstNo('SOH_%1.json', FileNo);
                        IF IntegrationSetup."Comestri File download type" = IntegrationSetup."Comestri File download type"::Json then begin
                            DownloadFromStream(InS, '', '', '', FileName);
                        end else begin
                            ComestriIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                            ComestriIntegrationHelpers.DownloadZipFiles('SOH.zip', '');
                        end;
                    end;

                //Update Azure Log
                ComestriAzureLog."No. Of Records Sent" := i;
                ComestriAzureLog."Start Processed Date Time" := GlobalDT;
                ComestriAzureLog."Sent Date Time" := CurrentDateTime();
                ComestriAzureLog.Reset := false;
                ComestriAzureLog.Modify();
                Commit();

            end;
        end;
    end;
    //WRP-287-

    local procedure InitialiseJsonObjectForSOH(JsonObjItem: JsonObject)
    begin
        JsonObjItem.Add('Legacy_Item_No', '');
        JsonObjItem.Add('Description', '');
        JsonObjItem.Add('Store_Code', '');
        JsonObjItem.Add('Quantity', '');
        JsonObjItem.Add('Item_No', '');
        JsonObjItem.Add('UOM', '');
        JsonObjItem.Add('Changedate', '');
    end;

    //WRP-287+
    // local procedure BuildJsonSOH(var SOHStagingData: Record "GXL SOH Staging Data"; JsonObjItem: JsonObject)
    // var
    //     Item: Record Item;
    //     ChangeDT: DateTime;
    //     QtyInt: Integer;
    // begin
    //     Item.Get(SOHStagingData."Item No.");
    //     QtyInt := Round(SOHStagingData."New Qty.", 1, '=');
    //     ChangeDT := RoundDateTime(CreateDateTime(SOHStagingData."Log Date", SOHStagingData."Log Time"), 1000);
    //     JsonObjItem.Replace('Legacy_Item_No', SOHStagingData."Legacy Item No.");
    //     JsonObjItem.Replace('Description', Item.Description);
    //     JsonObjItem.Replace('Store_Code', SOHStagingData."Store Code");
    //     JsonObjItem.Replace('Quantity', QtyInt);
    //     JsonObjItem.Replace('Item_No', SOHStagingData."Item No.");
    //     JsonObjItem.Replace('UOM', SOHStagingData.UOM);
    //     JsonObjItem.Replace('Changedate', ChangeDT);
    // end;

    local procedure BuildJsonSOH(SOHStagingData: Record "GXL SOH Staging Data"; Desc: Text; JsonObjItem: JsonObject)
    var
        ChangeDT: DateTime;
        QtyInt: Integer;
    begin
        QtyInt := Round(SOHStagingData."New Qty.", 1, '=');
        ChangeDT := RoundDateTime(CreateDateTime(SOHStagingData."Log Date", SOHStagingData."Log Time"), 1000);
        JsonObjItem.Replace('Legacy_Item_No', SOHStagingData."Legacy Item No.");
        JsonObjItem.Replace('Description', Desc);
        JsonObjItem.Replace('Store_Code', SOHStagingData."Store Code");
        JsonObjItem.Replace('Quantity', QtyInt);
        JsonObjItem.Replace('Item_No', SOHStagingData."Item No.");
        JsonObjItem.Replace('UOM', SOHStagingData.UOM);
        JsonObjItem.Replace('Changedate', ChangeDT);
    end;
    //WRP-287-

    procedure GetNextEntryNo(): Integer
    var
        ComestriAzureLog2: Record "GXL Comestri Azure Log";
    begin
        ComestriAzureLog2.SetCurrentKey("End Entry No.");
        ComestriAzureLog2.SetRange("Web Service Name", ComestriAzureLog2."Web Service Name"::SOH);
        if ComestriAzureLog2.FindLast() then
            exit(ComestriAzureLog2."End Entry No." + 1)
        else
            exit(1);
    end;

    local procedure AddAzureLogEntry(FileNo: Integer; StartEntryNo: Integer; EndEntryNo: Integer)
    begin
        ComestriAzureLog.InitAzureLogEntry(ComestriAzureLog."Web Service Name"::SOH, FileNo, StartEntryNo, EndEntryNo);
        ComestriAzureLog.Insert(true);
    end;

    //WRP-287+
    //Removed as re-process is not applicable for full feed
    /*
    procedure ReProcessSOH(var _ComestriAzureLog: Record "GXL Comestri Azure Log")
    var
        ComestriAzureLog2: Record "GXL Comestri Azure Log";
    begin
        ComestriAzureLog2.Copy(_ComestriAzureLog);
        ComestriAzureLog2.SetCurrentKey(Reset);
        ComestriAzureLog2.SetRange(Reset, true);
        ComestriAzureLog2.SetRange("Web Service Name", ComestriAzureLog2."Web Service Name"::SOH);
        if ComestriAzureLog2.FindSet() then
            repeat
                ComestriAzureLog := ComestriAzureLog2;
                if IntegrationSetup."Comestri Send Data to" = IntegrationSetup."Comestri Send Data to"::"End Point" then
                    ProcessSOH(true, true, false)
                else
                    ProcessSOH(true, false, true);
            until ComestriAzureLog2.Next() = 0;
    end;
    */
    //WRP-287-

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

    //PS-2683 +
    [IntegrationEvent(false, false)]
    local procedure OnAfterInventoryCalculation(var Item: Record Item; var QtyBase: Decimal)
    begin
    end;
    //PS-2683 -
}