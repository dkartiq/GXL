codeunit 50174 "GXL Bloyal Hierarchy"
{
    TableNo = "Job Queue Entry";
    Permissions = tabledata "GXL Bloyal Azure Log" = rmid;

    trigger OnRun()
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin

        ClearAll();
        GetSetup();

        //Re-Process all the Reset entries
        BloyalAzureLog2.SetCurrentKey(Reset);
        BloyalAzureLog2.SetRange(Reset, true);
        ReprocessHierarchy(BloyalAzureLog2);

        //Process the new entries
        ProcessHierarchy(false, true);
    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        BloyalAzureLog: Record "GXL Bloyal Azure Log";
        SetupRead: Boolean;
        BloyalServName: Enum "GXL Bloyal Web Service Name";
        StartRunDT: DateTime;
        GlobalDT: DateTime;

    procedure ProcessHierarchy(ReProcess: Boolean; SendToWS: Boolean)
    var
        StartDateTime: DateTime;
        EndDateTime: DateTime;
    begin
        GetSetup();
        EndDateTime := CurrentDateTime();

        StartDateTime := GetLastEndDateTime(BloyalServName::Division);
        ProcessDivision(StartDateTime, EndDateTime, ReProcess, SendToWS);

        StartDateTime := GetLastEndDateTime(BloyalServName::"Item Category");
        ProcessItemCategory(StartDateTime, EndDateTime, ReProcess, SendToWS);

        StartDateTime := GetLastEndDateTime(BloyalServName::"Retail Product Group");
        ProcessRetailProductGroup(StartDateTime, EndDateTime, ReProcess, SendToWS);
    end;


    procedure ProcessDivision(StartDateTime: DateTime; EndDateTime: DateTime; ReProcess: Boolean; SendtoWS: Boolean)
    var
        Division: Record "LSC Division";
    begin
        if EndDateTime = 0DT then
            EndDateTime := CurrentDateTime();
        Division.SetCurrentKey("GXL Bloyal Date Time Modified");
        if ReProcess then
            Division.SetRange("GXL Bloyal Date Time Modified", StartDateTime, EndDateTime)
        else begin
            if StartDateTime <> 0DT then
                Division.SetFilter("GXL Bloyal Date Time Modified", '>%1&<=%2', StartDateTime, EndDateTime)
            else
                Division.SetRange("GXL Bloyal Date Time Modified", StartDateTime, EndDateTime);
        end;
        ProcessDivision(Division, ReProcess, SendtoWS);
    end;


    procedure ProcessDivision(var Division: Record "LSC Division"; ReProcess: Boolean; SendtoWS: Boolean)
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
    begin
        GetSetup();
        //>> Jira PS-1333: not to send if the endpoint is not specified
        if IntegrationSetup."Bloyal Division Endpoint" = '' then
            exit;
        //<< Jira PS-1333:

        MaxOfRecs := IntegrationSetup."Bloyal Hierarchy Max Records";

        i := 0;
        FileNo := 1;
        PrevDateTime := 0DT;
        If Division.FindSet() then begin
            if not SendtoWS then
                BloyalIntegrationHelpers.InitialiseZipStream();

            NewStartDateTime := Division."GXL Bloyal Date Time Modified";
            BloyalIntegrationHelpers.SetSetup(IntegrationSetup);

            GlobalDT := CurrentDateTime();
            if ReProcess then
                StartRunDT := BloyalAzureLog."Sent Date Time"
            else
                StartRunDT := CurrentDateTime();

            InitialiseJsonObjectForHierarchy(BloyalServName::Division, JsonObjItem);
            repeat
                //Break the data into a chunk of max. number of records
                if (not ReProcess) and (MaxOfRecs <> 0) and (i > MaxOfRecs) then
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
                    JsonObjItem.WriteTo(OutS);

                    //Send to Azure LogicApp
                    NewEndDateTime := PrevDateTime;
                    AddAzureLogEntry(BloyalServName::Division, FileNo, NewStartDateTime, NewEndDateTime);
                    if SendtoWS then begin
                        BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                    end else begin
                        //Send to file
                        FileName := StrSubstNo('Division_%1.json', FileNo);
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
                    NewStartDateTime := Division."GXL Bloyal Date Time Modified";
                    Clear(JsonArrItem);
                    Clear(JsonObjItem);
                    StartRunDT := CurrentDateTime();
                    InitialiseJsonObjectForHierarchy(BloyalServName::Division, JsonObjItem);
                end;

                i += 1;
                BuildJsonDivision(Division, JsonObjItem);
                JsonArrItem.Add(JsonObjItem.Clone());
                PrevDateTime := Division."GXL Bloyal Date Time Modified";
            until Division.Next() = 0;

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
                    AddAzureLogEntry(BloyalServName::Division, FileNo, NewStartDateTime, NewEndDateTime);
                if SendtoWS then begin
                    BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                end else begin
                    //Send to file
                    FileName := StrSubstNo('Division_%1.json', FileNo);
                    BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                    BloyalIntegrationHelpers.DownloadZipFiles('Division.zip');
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

    procedure ProcessItemCategory(StartDateTime: DateTime; EndDateTime: DateTime; ReProcess: Boolean; SendtoWS: Boolean)
    var
        ItemCat: Record "Item Category";
    begin
        if EndDateTime = 0DT then
            EndDateTime := CurrentDateTime();
        ItemCat.SetCurrentKey("GXL Bloyal Date Time Modified");
        if ReProcess then
            ItemCat.SetRange("GXL Bloyal Date Time Modified", StartDateTime, EndDateTime)
        else begin
            if StartDateTime <> 0DT then
                ItemCat.SetFilter("GXL Bloyal Date Time Modified", '>%1&<=%2', StartDateTime, EndDateTime)
            else
                ItemCat.SetRange("GXL Bloyal Date Time Modified", StartDateTime, EndDateTime);
        end;
        ProcessItemCategory(ItemCat, ReProcess, SendtoWS);
    end;

    procedure ProcessItemCategory(var ItemCat: Record "Item Category"; ReProcess: Boolean; SendtoWS: Boolean)
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
    begin
        GetSetup();
        //>> Jira PS-1333: not to send if the endpoint is not specified
        if IntegrationSetup."Bloyal Item Category Endpoint" = '' then
            exit;
        //<< Jira PS-1333:

        MaxOfRecs := IntegrationSetup."Bloyal Hierarchy Max Records";

        i := 0;
        FileNo := 1;
        PrevDateTime := 0DT;
        If ItemCat.FindSet() then begin
            if not SendtoWS then
                BloyalIntegrationHelpers.InitialiseZipStream();

            NewStartDateTime := ItemCat."GXL Bloyal Date Time Modified";
            BloyalIntegrationHelpers.SetSetup(IntegrationSetup);

            GlobalDT := CurrentDateTime();

            if ReProcess then
                StartRunDT := BloyalAzureLog."Sent Date Time"
            else
                StartRunDT := CurrentDateTime();

            InitialiseJsonObjectForHierarchy(BloyalServName::"Item Category", JsonObjItem);
            repeat
                //Break the data into a chunk of max. number of records
                if (not ReProcess) and (MaxOfRecs <> 0) and (i > MaxOfRecs) then
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
                    JsonObjItem.WriteTo(OutS);

                    //Send to Azure LogicApp
                    NewEndDateTime := PrevDateTime;
                    AddAzureLogEntry(BloyalServName::"Item Category", FileNo, NewStartDateTime, NewEndDateTime);
                    if SendtoWS then begin
                        BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                    end else begin
                        //Send to file
                        FileName := StrSubstNo('ItemCat_%1.json', FileNo);
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
                    NewStartDateTime := ItemCat."GXL Bloyal Date Time Modified";
                    Clear(JsonArrItem);
                    Clear(JsonObjItem);
                    StartRunDT := CurrentDateTime();
                    InitialiseJsonObjectForHierarchy(BloyalServName::"Item Category", JsonObjItem);
                end;

                i += 1;
                BuildJsonItemCategory(ItemCat, JsonObjItem);
                JsonArrItem.Add(JsonObjItem.Clone());
                PrevDateTime := ItemCat."GXL Bloyal Date Time Modified";
            until ItemCat.Next() = 0;

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
                    AddAzureLogEntry(BloyalServName::"Item Category", FileNo, NewStartDateTime, NewEndDateTime);
                if SendtoWS then begin
                    BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                end else begin
                    //Send to file
                    FileName := StrSubstNo('ItemCat_%1.json', FileNo);
                    BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                    BloyalIntegrationHelpers.DownloadZipFiles('ItemCat.zip');
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

    procedure ProcessRetailProductGroup(StartDateTime: DateTime; EndDateTime: DateTime; ReProcess: Boolean; SendtoWS: Boolean)
    var
        RetailProdGrp: Record "LSC Retail Product Group";
    begin
        if EndDateTime = 0DT then
            EndDateTime := CurrentDateTime();
        RetailProdGrp.SetCurrentKey("GXL Bloyal Date Time Modified");
        if ReProcess then
            RetailProdGrp.SetRange("GXL Bloyal Date Time Modified", StartDateTime, EndDateTime)
        else begin
            if StartDateTime <> 0DT then
                RetailProdGrp.SetFilter("GXL Bloyal Date Time Modified", '>%1&<=%2', StartDateTime, EndDateTime)
            else
                RetailProdGrp.SetRange("GXL Bloyal Date Time Modified", StartDateTime, EndDateTime);
        end;
        ProcessRetailProductGroup(RetailProdGrp, ReProcess, SendtoWS);
    end;

    procedure ProcessRetailProductGroup(var RetailProdGrp: Record "LSC Retail Product Group"; ReProcess: Boolean; SendtoWS: Boolean)
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
    begin
        GetSetup();
        //>> Jira PS-1333: not to send if the endpoint is not specified
        if IntegrationSetup."Bloyal Retail Product Endpoint" = '' then
            exit;
        //<< Jira PS-1333:

        MaxOfRecs := IntegrationSetup."Bloyal Hierarchy Max Records";

        i := 0;
        FileNo := 1;
        PrevDateTime := 0DT;
        If RetailProdGrp.FindSet() then begin
            if not SendtoWS then
                BloyalIntegrationHelpers.InitialiseZipStream();

            NewStartDateTime := RetailProdGrp."GXL Bloyal Date Time Modified";
            BloyalIntegrationHelpers.SetSetup(IntegrationSetup);

            GlobalDT := CurrentDateTime();

            if ReProcess then
                StartRunDT := BloyalAzureLog."Sent Date Time"
            else
                StartRunDT := CurrentDateTime();

            InitialiseJsonObjectForHierarchy(BloyalServName::"Retail Product Group", JsonObjItem);
            repeat
                //Break the data into a chunk of max. number of records
                if (not ReProcess) and (MaxOfRecs <> 0) and (i > MaxOfRecs) then
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
                    JsonObjItem.WriteTo(OutS);

                    //Send to Azure LogicApp
                    NewEndDateTime := PrevDateTime;
                    AddAzureLogEntry(BloyalServName::"Retail Product Group", FileNo, NewStartDateTime, NewEndDateTime);
                    if SendtoWS then begin
                        BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                    end else begin
                        //Send to file
                        FileName := StrSubstNo('RetailProdGrp_%1.json', FileNo);
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
                    NewStartDateTime := RetailProdGrp."GXL Bloyal Date Time Modified";
                    Clear(JsonArrItem);
                    Clear(JsonObjItem);
                    StartRunDT := CurrentDateTime();
                    InitialiseJsonObjectForHierarchy(BloyalServName::"Retail Product Group", JsonObjItem);
                end;

                i += 1;
                BuildJsonRetailProdGroup(RetailProdGrp, JsonObjItem);
                JsonArrItem.Add(JsonObjItem.Clone());
                PrevDateTime := RetailProdGrp."GXL Bloyal Date Time Modified";
            until RetailProdGrp.Next() = 0;

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
                    AddAzureLogEntry(BloyalServName::"Retail Product Group", FileNo, NewStartDateTime, NewEndDateTime);
                if SendtoWS then begin
                    BloyalIntegrationHelpers.PushToAzure(BloyalAzureLog, InS);
                end else begin
                    //Send to file
                    FileName := StrSubstNo('RetailProdGrp_%1.json', FileNo);
                    BloyalIntegrationHelpers.AddFileStreamToZip(InS, FileName);
                    BloyalIntegrationHelpers.DownloadZipFiles('RetailProdGrp.zip');
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

    local procedure InitialiseJsonObjectForHierarchy(ServName: enum "GXL Bloyal Web Service Name"; JsonObjItem: JsonObject)
    begin
        case ServName of
            ServName::Division:
                begin
                    JsonObjItem.Add('Division', '');
                    JsonObjItem.Add('Division_Description', '');
                    JsonObjItem.Add('Changedate', '');
                end;
            ServName::"Item Category":
                begin
                    JsonObjItem.Add('Division', '');
                    JsonObjItem.Add('Item_Category', '');
                    JsonObjItem.Add('Item_Category_Description', '');
                    JsonObjItem.Add('Changedate', '');
                end;
            ServName::"Retail Product Group":
                begin
                    JsonObjItem.Add('Division', '');
                    JsonObjItem.Add('Item_Category', '');
                    JsonObjItem.Add('Retail_Product_Group', '');
                    JsonObjItem.Add('Retail_Product_Group_Description', '');
                    JsonObjItem.Add('Changedate', '');
                end;
            else
                Error('Not implemented!');
        end;
    end;

    local procedure BuildJsonDivision(Division: Record "LSC Division"; JsonObjItem: JsonObject)
    var
        ChangeDT: DateTime;
    begin
        ChangeDT := Division."GXL Bloyal Date Time Modified";
        if ChangeDT = 0DT then
            ChangeDT := StartRunDT;
        ChangeDT := RoundDateTime(ChangeDT, 1000);

        JsonObjItem.Replace('Division', Division.Code);
        JsonObjItem.Replace('Division_Description', Division.Description);
        JsonObjItem.Replace('Changedate', ChangeDT);
    end;

    local procedure BuildJsonItemCategory(ItemCat: Record "Item Category"; JsonObjItem: JsonObject)
    var
        ChangeDT: DateTime;
    begin
        ChangeDT := ItemCat."GXL Bloyal Date Time Modified";
        if ChangeDT = 0DT then
            ChangeDT := StartRunDT;
        ChangeDT := RoundDateTime(ChangeDT, 1000);

        JsonObjItem.Replace('Division', ItemCat."LSC Division Code");
        JsonObjItem.Replace('Item_Category', ItemCat.Code);
        JsonObjItem.Replace('Item_Category_Description', ItemCat.Description);
        JsonObjItem.Replace('Changedate', ChangeDT);
    end;

    local procedure BuildJsonRetailProdGroup(RetailProdGrp: Record "LSC Retail Product Group"; JsonObjItem: JsonObject)
    var
        ChangeDT: DateTime;
    begin
        ChangeDT := RetailProdGrp."GXL Bloyal Date Time Modified";
        if ChangeDT = 0DT then
            ChangeDT := StartRunDT;
        ChangeDT := RoundDateTime(ChangeDT, 1000);

        JsonObjItem.Replace('Division', RetailProdGrp."Division Code");
        JsonObjItem.Replace('Item_Category', RetailProdGrp."Item Category Code");
        JsonObjItem.Replace('Retail_Product_Group', RetailProdGrp.Code);
        JsonObjItem.Replace('Retail_Product_Group_Description', RetailProdGrp.Description);
        JsonObjItem.Replace('Changedate', ChangeDT);
    end;

    procedure GetLastEndDateTime(ServName: Enum "GXL Bloyal Web Service Name"): DateTime
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog2.SetCurrentKey("End Date Time Modified");
        BloyalAzureLog2.SetRange("Web Service Name", ServName);
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


    local procedure AddAzureLogEntry(ServName: Enum "GXL Bloyal Web Service Name"; FileNo: Integer; StartDateTime: DateTime; EndDateTime: DateTime)
    begin
        BloyalAzureLog.InitAzureLogEntry(ServName, FileNo, StartDateTime, EndDateTime);
        BloyalAzureLog.Insert(true);
    end;

    procedure ReprocessHierarchy(var _BloyalAzureLog: Record "GXL Bloyal Azure Log")
    begin
        ReprocessDivision(_BloyalAzureLog);
        ReprocessItemCategory(_BloyalAzureLog);
        ReprocessRetailProdGroup(_BloyalAzureLog);
    end;

    procedure ReprocessDivision(var _BloyalAzureLog: Record "GXL Bloyal Azure Log")
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog2.Copy(_BloyalAzureLog);
        BloyalAzureLog2.SetCurrentKey(Reset);
        BloyalAzureLog2.SetRange(Reset, true);
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::Division);
        if BloyalAzureLog2.FindSet() then
            repeat
                BloyalAzureLog := BloyalAzureLog2;
                ProcessDivision(BloyalAzureLog2."Start Date Time Modified", BloyalAzureLog2."End Date Time Modified", true, true);
            until BloyalAzureLog2.Next() = 0;

    end;

    procedure ReprocessItemCategory(var _BloyalAzureLog: Record "GXL Bloyal Azure Log")
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog2.Copy(_BloyalAzureLog);
        BloyalAzureLog2.SetCurrentKey(Reset);
        BloyalAzureLog2.SetRange(Reset, true);
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::"Item Category");
        if BloyalAzureLog2.FindSet() then
            repeat
                BloyalAzureLog := BloyalAzureLog2;
                ProcessItemCategory(BloyalAzureLog2."Start Date Time Modified", BloyalAzureLog2."End Date Time Modified", true, true);
            until BloyalAzureLog2.Next() = 0;

    end;

    procedure ReprocessRetailProdGroup(var _BloyalAzureLog: Record "GXL Bloyal Azure Log")
    var
        BloyalAzureLog2: Record "GXL Bloyal Azure Log";
    begin
        BloyalAzureLog2.Copy(_BloyalAzureLog);
        BloyalAzureLog2.SetCurrentKey(Reset);
        BloyalAzureLog2.SetRange(Reset, true);
        BloyalAzureLog2.SetRange("Web Service Name", BloyalAzureLog2."Web Service Name"::"Retail Product Group");
        if BloyalAzureLog2.FindSet() then
            repeat
                BloyalAzureLog := BloyalAzureLog2;
                ProcessRetailProductGroup(BloyalAzureLog2."Start Date Time Modified", BloyalAzureLog2."End Date Time Modified", true, true);
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