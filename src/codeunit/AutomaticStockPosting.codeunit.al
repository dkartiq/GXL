codeunit 50400 "GXL Automatic Stock Posting"
{
    /*Change Log
        PS-2313 2020-10-06 LP: Code review, include error log
    */

    TableNo = "LSC Scheduler Job Header";

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


    procedure RunProcess(var Rec: Record "LSC Scheduler Job Header")
    var
        TransactionHeader: Record "LSC Transaction Header";
        AutoStockPostTrans: Codeunit "GXL Automatic Stock Post Trans";
        StartTime: Time;
        EndTime: Time;
        NoOfErrors: Integer;
        LogEntryNo: Integer;
    begin
        EndTime := DT2TIME(CURRENTDATETIME());
        if FORMAT(Rec."Last Time Checked") = '' then//EBT::To optiomize something
            StartTime := EndTime - (2 * 3600000)
        else
            StartTime := Rec."Last Time Checked" - (1 * 3600000);//EBT::To optiomize

        if FORMAT(Rec.Date) <> '' then begin
            TransactionHeader.RESET();
            TransactionHeader.SETCURRENTKEY(Date, Time);
            TransactionHeader.SETRANGE(TransactionHeader.Date, Rec.Date, Today());
        end else
            if Rec.Boolean = true then begin
                TransactionHeader.RESET();
                TransactionHeader.SETCURRENTKEY(Date, Time);
                TransactionHeader.SETRANGE(TransactionHeader.Date, Today() - 1, Today());
            end else begin
                TransactionHeader.RESET();
                TransactionHeader.SETCURRENTKEY(Date, Time);
                TransactionHeader.SETRANGE(TransactionHeader.Date, TODAY());
                TransactionHeader.SETRANGE(TransactionHeader.Time, StartTime, EndTime);
            end;

        GetSetups();
        TransactionHeader.SetFilter("Entry Status", '%1|%2', TransactionHeader."Entry Status"::" ", TransactionHeader."Entry Status"::Posted);
        TransactionHeader.SetRange("Transaction Type", TransactionHeader."Transaction Type"::Sales);
        //PS-2313+
        // if TransactionHeader.FindSet() then
        //     repeat
        //         if Store."No." <> TransactionHeader."Store No." then
        //             if not Store.Get(TransactionHeader."Store No.") then
        //                 Clear(Store);
        //         if SalesType.Code <> TransactionHeader."Sales Type" then
        //             if not SalesType.Get(TransactionHeader."Sales Type") then
        //                 Clear(SalesType);
        //         if Staff.ID <> TransactionHeader."Staff ID" then
        //             if not Staff.Get(TransactionHeader."Staff ID") then
        //                 Clear(Staff);

        //         Commit();
        //         Clear(AutoStockPostTrans);
        //         AutoStockPostTrans.SetSetups(IntegrationSetup, RetailSetup);
        //         AutoStockPostTrans.SetStore(Store, Staff, SalesType);
        //         if AutoStockPostTrans.Run(TransactionHeader) then;
        //     until TransactionHeader.NEXT() = 0;

        if TransactionHeader.FindSet() then begin
            LogEntryNo := AutoStockPostTrans.GetLastErrorLogEntry();
            repeat
                PostSingleTransaction(TransactionHeader, NoOfErrors, LogEntryNo);
            until (TransactionHeader.Next() = 0);
        end;
        //PS-2313-
    end;


    local procedure GetSetups()
    begin
        RetailSetup.Get();
        if IntegrationSetup.Get() then;
    end;

    //PS-2313+
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
    //PS-2313-
}