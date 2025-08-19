//<Summary>
//Split number of items to run the update item
//</Summary>
codeunit 50008 "GXL Update Items Background"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Item: Record Item;
        DividedBy: Integer;
        SplitNumber: Integer;
        Totals: Integer;
        Loopers: Integer;
        ItemNoFilters: Text;
    begin
        //Run it first to update product status in SKUs to Quit for closed stores
        UpdateClosedStores();
        Commit();

        if Rec."Parameter String" <> '' then
            Evaluate(DividedBy, Rec."Parameter String")
        else
            DividedBy := 6;

        Item.Reset();
        Totals := Item.Count();
        if (Totals > 0) and (Totals > DividedBy) then begin
            SplitNumber := Totals div DividedBy;
            Item.Find('-');
            repeat
                Loopers += 1;
                ItemNoFilters := Item."No.";
                if (Totals <> DividedBy) then begin
                    ItemNoFilters := ItemNoFilters + '..';
                    if Item.Next(SplitNumber) <> 0 then
                        ItemNoFilters := ItemNoFilters + Item."No.";
                end;
                StartFilterSession(ItemNoFilters);
                if Item.Next(1) <= 0 then
                    exit;
            until (Loopers > DividedBy);
        end;

        VerifySessionExecution();
    end;

    var
        TempActiveSession: Record "Active Session" temporary;

    local procedure StartFilterSession(ItemNoFilters: Text)
    var
        Item: Record Item;
        NewSessionId: Integer;
    begin
        Item.SetFilter("No.", ItemNoFilters);
        StartSession(NewSessionId, Codeunit::"GXL Update Items", CompanyName(), Item);

        TempActiveSession.Init();
        TempActiveSession."Session ID" := NewSessionId;
        TempActiveSession."Server Instance ID" := ServiceInstanceId();
        TempActiveSession."Database Name" := CopyStr(ItemNoFilters, 1, 250);
        TempActiveSession.Insert();
    end;


    local procedure VerifySessionExecution()
    var
        SessionIdErrorText: Text;
        ErrorText: Text;
    begin
        TempActiveSession.Reset();
        if TempActiveSession.FindSet() then
            repeat
                repeat
                    Sleep(5000);
                until (not ActiveSessionExists(TempActiveSession."Session ID"));
            until TempActiveSession.Next() = 0;

        if TempActiveSession.FindSet() then
            repeat
                SessionIdErrorText := GetSessionLoggedOffErrorMsg(TempActiveSession."Session ID");
                if SessionIdErrorText <> '' then begin
                    if StrLen(ErrorText) < 1000 then
                        ErrorText := ErrorText + CopyStr('Items: ' + TempActiveSession."Database Name" + ' Error: ' + SessionIdErrorText, 1, 1000 - StrLen(ErrorText));
                end;
            until TempActiveSession.Next() = 0;
        if ErrorText <> '' then
            Error(ErrorText);
    end;

    local procedure ActiveSessionExists(SessionId: Integer): Boolean
    var
        ActiveSession: Record "Active Session";
    begin
        ActiveSession.SETRANGE("Server Instance ID", ServiceInstanceId());
        ActiveSession.SETRANGE("Session ID", SessionId);
        ActiveSession.SETRANGE("Client Type", ActiveSession."Client Type"::Background);
        EXIT(NOT ActiveSession.IsEmpty());
    end;

    local procedure GetSessionLoggedOffErrorMsg(SessionId: Integer): Text
    var
        SessionEvent: Record "Session Event";
    begin
        SessionEvent.SETRANGE("Server Instance ID", ServiceInstanceId());
        SessionEvent.SETRANGE("Session ID", SessionId);
        SessionEvent.SETRANGE("Event Type", SessionEvent."Event Type"::Logoff);
        SessionEvent.SETRANGE("Client Type", SessionEvent."Client Type"::Background);
        IF SessionEvent.FindLast() THEN
            EXIT(SessionEvent.Comment);
    end;

    local procedure UpdateClosedStores()
    var
        Store: Record "LSC Store";
        ProdRangingMgt: Codeunit "GXL Product Ranging Management";
    begin
        Store.SetCurrentKey("GXL Closed Date");
        Store.SetFilter("GXL Closed Date", '<>0D');
        Store.SetRange("GXL Store Closed", false);
        if Store.FindSet() then
            repeat
                if ProdRangingMgt.CheckStoreClosed(Store) then begin
                    Store.Validate("GXL Store Closed", true);
                    Store.Modify();
                end;
            until Store.Next() = 0;
    end;
}