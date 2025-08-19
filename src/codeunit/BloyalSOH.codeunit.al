codeunit 50172 "GXL Bloyal SOH"
{
    TableNo = "Job Queue Entry";
    Permissions = tabledata "GXL Bloyal Azure Log" = rmid;

    trigger OnRun()
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
        FromEntryNo: Integer;
    begin

        ClearAll();
        GetSetup();

        //Re-Process all the Reset entries
        BloyalAzureLog2.SetCurrentKey(Reset);
        BloyalAzureLog2.SetRange(Reset, true);
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::SOH);
        ReProcessSOH(BloyalAzureLog2);

        //Process the new entries
        //Note: this process is based on SOH Staging Data table, means the SOH process must be run before this process.
        FromEntryNo := GetNextEntryNo();
        ProcessSOH(FromEntryNo, 0, false, true);
    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        BloyalAzureLog: Record "GXL Bloyal Azure Log";
        SetupRead: Boolean;
        GlobalDT: DateTime;

    // >> lcb-23
    procedure IsValidSOHStagingData(SOHStagingData: Record "GXL SOH Staging Data"): Boolean
    var
        Item: Record Item;
        Store: Record "LSC Store";
    begin
        GetSetup();
        if IntegrationSetup."Live Store Only" then begin
            if not store.get(SOHStagingData."Store Code") then
                exit;
            if not Store."GXL LS Live Store" then
                exit;
        end;

        If not Item.get(SOHStagingData."Item No.") then
            exit;

        exit(not Item.Blocked);
    end;
    // << lcb-23

    procedure ProcessSOH(StartEntryNo: Integer; EndEntryNo: Integer; ReProcess: Boolean; SendtoWS: Boolean)
    var
        SOHStagingData: Record "GXL SOH Staging Data";
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
        MaxOfRecs := IntegrationSetup."Bloyal SOH Max Records";

        FileNo := 1;
        PrevEntryNo := 0;
        i := 0;

        SOHStagingData.SetCurrentKey("Auto ID");
        if (EndEntryNo <> 0) then
            SOHStagingData.SetRange("Auto ID", StartEntryNo, EndEntryNo)
        else
            SOHStagingData.SetFilter("Auto ID", '>=%1', StartEntryNo);
        if SOHStagingData.FindLast() then begin
            EndEntryNo := SOHStagingData."Auto ID";
            SOHStagingData.SetRange("Auto ID", StartEntryNo, EndEntryNo);
        end;
        if SOHStagingData.FindSet() then begin
            if not SendtoWS then
                BloyalIntegrationHelpers.InitialiseZipStream();

            GlobalDT := CurrentDateTime();

            NewStartEntryNo := SOHStagingData."Auto ID";
            BloyalIntegrationHelpers.SetSetup(IntegrationSetup);
            InitialiseJsonObjectForSOH(JsonObjItem);
            repeat

                // >> lcb-23
                if IsValidSOHStagingData(SOHStagingData) then begin
                    // << lcb-23

                    //Break the data into a chunk of max. number of records
                    if (not ReProcess) and (MaxOfRecs <> 0) and (i >= MaxOfRecs) then
                        ToBreak := true
                    else
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
                            //Send to File
                            FileName := StrSubstNo('SOH_%1.json', FileNo);
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
                        NewStartEntryNo := SOHStagingData."Auto ID";
                        Clear(JsonArrItem);
                        Clear(JsonObjItem);
                        InitialiseJsonObjectForSOH(JsonObjItem);
                    end;

                    i += 1;
                    BuildJsonSOH(SOHStagingData, JsonObjItem);
                    JsonArrItem.Add(JsonObjItem.Clone());
                    PrevEntryNo := SOHStagingData."Auto ID";

                    // >> lcb-23
                end;
            // << lcb-23
            until SOHStagingData.Next() = 0;

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
                    //Send to File
                    FileName := StrSubstNo('SOH_%1.json', FileNo);
                    BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                    BloyalIntegrationHelpers.DownloadZipFiles('SOH.zip');
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

    local procedure BuildJsonSOH(var SOHStagingData: Record "GXL SOH Staging Data"; JsonObjItem: JsonObject)
    var
        Item: Record Item;
        ChangeDT: DateTime;
    begin
        Item.Get(SOHStagingData."Item No.");
        ChangeDT := RoundDateTime(CreateDateTime(SOHStagingData."Log Date", SOHStagingData."Log Time"), 1000);
        JsonObjItem.Replace('Legacy_Item_No', SOHStagingData."Legacy Item No.");
        JsonObjItem.Replace('Description', Item.Description);
        JsonObjItem.Replace('Store_Code', SOHStagingData."Store Code");
        JsonObjItem.Replace('Quantity', SOHStagingData."New Qty.");
        JsonObjItem.Replace('Item_No', SOHStagingData."Item No.");
        JsonObjItem.Replace('UOM', SOHStagingData.UOM);
        JsonObjItem.Replace('Changedate', ChangeDT);
    end;

    procedure GetNextEntryNo(): Integer
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog2.SetCurrentKey("End Entry No.");
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::SOH);
        if BloyalAzureLog2.FindLast() then
            exit(BloyalAzureLog2."End Entry No." + 1)
        else
            exit(1);
    end;

    local procedure AddAzureLogEntry(FileNo: Integer; StartEntryNo: Integer; EndEntryNo: Integer)
    begin
        BloyalAzureLog.InitAzureLogEntry(BloyalAzureLog."Web Service Name"::SOH, FileNo, StartEntryNo, EndEntryNo);
        BloyalAzureLog.Insert(true);
    end;

    procedure ReProcessSOH(var _BloyalAzureLog: Record "GXL Bloyal Azure Log")
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog2.Copy(_BloyalAzureLog);
        BloyalAzureLog2.SetCurrentKey(Reset);
        BloyalAzureLog2.SetRange(Reset, true);
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::SOH);
        if BloyalAzureLog2.FindSet() then
            repeat
                BloyalAzureLog := BloyalAzureLog2;
                ProcessSOH(BloyalAzureLog."Start Entry No.", BloyalAzureLog."End Entry No.", true, true);
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