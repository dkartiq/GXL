codeunit 50019 "GXL Automatic Stock Posting-JQ"
{
    /*Change Log
        PS-2313 2020-10-06 LP: New codeunit to be run via Standard Job Queue Entry
        Required CAL version MCS1.20 for new key in transaction header
    */

    TableNo = "Job Queue Entry";

    trigger OnRun();
    begin
        RunProcess(Rec);
    end;

    var
        RetailSetup: Record "LSC Retail Setup";
        IntegrationSetup: Record "GXL Integration Setup";
        Store: Record "LSC Store";
        SalesType: Record "LSC Sales Type";
        Staff: Record "LSC Staff";


    procedure RunProcess(var Rec: Record "Job Queue Entry")
    var
        TransactionHeader: Record "LSC Transaction Header";
        TempTransHeader: Record "LSC Transaction Header" temporary;
        AutoStockPostTrans: Codeunit "GXL Automatic Stock Post Trans";
        DF: DateFormula;
        NoOfErrors: Integer;
        LastReplicationCounter: Integer;
        NoOfTrans: Integer;
        MaxNoOfTrans: Integer;
        ExitLoop: Boolean;
        LogEntryNo: Integer;
        ParamStr: Text;
        ParamList: array[2] of Text;
        i: Integer;
    begin
        TempTransHeader.Reset();
        TempTransHeader.DeleteAll();

        TransactionHeader.Reset();
        TransactionHeader.SetCurrentKey("Replication Counter");
        if TransactionHeader.FindLast() then
            LastReplicationCounter := TransactionHeader."Replication Counter"
        else
            LastReplicationCounter := 0;

        GetSetups();
        TransactionHeader.RESET();
        TransactionHeader.SETCURRENTKEY(Date, Time);
        if Rec."Parameter String" <> '' then begin
            ParamStr := Rec."Parameter String";
            ParamStr := DelChr(ParamStr, '<>', ' ');

            for i := 1 to 2 do
                ParamList[i] := ReturnNextWordOrParameters(ParamStr);

            if ParamList[1] <> '' then begin
                if not Evaluate(DF, ParamList[1]) then
                    Evaluate(DF, '<-7D>');
            end else
                Evaluate(DF, '<-7D>');

            if ParamList[2] <> '' then begin
                if not Evaluate(MaxNoOfTrans, ParamList[2]) then
                    MaxNoOfTrans := 5000;
            end else
                MaxNoOfTrans := 5000;
        end else begin
            MaxNoOfTrans := 5000;
            Evaluate(DF, '<-7D>');
        end;

        TransactionHeader.Reset();
        TransactionHeader.SetCurrentKey("Entry Status", Date, Time);
        TransactionHeader.SetFilter("Entry Status", '%1|%2', TransactionHeader."Entry Status"::" ", TransactionHeader."Entry Status"::Posted);
        if Format(DF) <> '' then
            TransactionHeader.SetRange(Date, CalcDate(DF, Today()), Today());
        TransactionHeader.SetRange("Transaction Type", TransactionHeader."Transaction Type"::Sales);
        TransactionHeader.SetFilter("Posted Statement No.", '=%1', '');
        if LastReplicationCounter <> 0 then
            TransactionHeader.SetFilter("Replication Counter", '..%1', LastReplicationCounter);
        TransactionHeader.SetAutoCalcFields("Posting Status");
        TransactionHeader.SetRange("Posting Status", TransactionHeader."Posting Status"::" ");

        ExitLoop := false;
        NoOfTrans := 0;
        if TransactionHeader.FindSet(false, false) then
            repeat
                TempTransHeader.Init();
                TempTransHeader := TransactionHeader;
                TempTransHeader.Insert();
                NoOfTrans += 1;
                if (MaxNoOfTrans <> 0) and (NoOfTrans >= MaxNoOfTrans) then
                    ExitLoop := true;
            until (TransactionHeader.Next() = 0) or ExitLoop;

        TransactionHeader.Reset();
        LogEntryNo := AutoStockPostTrans.GetLastErrorLogEntry();
        TempTransHeader.Reset();
        TempTransHeader.SetCurrentKey("Replication Counter");
        if TempTransHeader.FindSet() then
            repeat
                TransactionHeader := TempTransHeader;
                if TransactionHeader.Find() then
                    PostSingleTransaction(TransactionHeader, NoOfErrors, LogEntryNo);
            until TempTransHeader.Next() = 0;
        TempTransHeader.DeleteAll();

    end;


    local procedure GetSetups()
    begin
        RetailSetup.Get();
        if IntegrationSetup.Get() then;
    end;


    local procedure PostSingleTransaction(var TransactionHeader: Record "LSC Transaction Header"; var NoOfErrors: Integer; var LogEntryNo: Integer)
    var
        AutoStockPostTrans: Codeunit "GXL Automatic Stock Post Trans";
        ProcessWasSuccess: Boolean;
    begin
        if Store."No." <> TransactionHeader."Store No." then
            if not Store.Get(TransactionHeader."Store No.") then
                Clear(Store);
        if SalesType.Code <> TransactionHeader."Sales Type" then
            if not SalesType.Get(TransactionHeader."Sales Type") then
                Clear(SalesType);
        if Staff.ID <> TransactionHeader."Staff ID" then
            if not Staff.Get(TransactionHeader."Staff ID") then
                Clear(Staff);

        Commit();
        Clear(AutoStockPostTrans);
        ClearLastError();
        AutoStockPostTrans.SetSetups(IntegrationSetup, RetailSetup);
        AutoStockPostTrans.SetStore(Store, Staff, SalesType);
        ProcessWasSuccess := AutoStockPostTrans.Run(TransactionHeader);
        if not ProcessWasSuccess then begin
            if not AutoStockPostTrans.IsLockingError(GetLastErrorCode(), GetLastErrorText()) then begin
                Commit();
                AutoStockPostTrans.InsertErrorLog(TransactionHeader, GetLastErrorText(), LogEntryNo);
                NoOfErrors += 1;
            end;
        end;
    end;

    procedure ReturnNextWordOrParameters(var TextIn: Text) TextOut: Text
    var
        SepPosition: Integer;
    begin
        SepPosition := StrPos(TextIn, ' ');
        if SepPosition > 0 then begin
            TextOut := CopyStr(TextIn, 1, SepPosition - 1);
            TextIn := DelChr(COPYSTR(TextIn, SepPosition + 1), '<>', ' ');
        end else begin
            TextOut := DelChr(TextIn, '<>', ' ');
            TextIn := '';
        end;
    end;
}