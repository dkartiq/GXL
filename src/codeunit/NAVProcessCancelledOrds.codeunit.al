codeunit 50025 "GXL NAV Process Cancelled Ords"
{
    /*Change Log
        PS-2270: Sync cancelled orders from NAV13 over
    */

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        NoOfErrors: Integer;
    begin
        GlobalJobQueueEntry := Rec;
        CopyNAVCancelledOrderToBuffer();
        NoOfErrors := ProcessCancelledOrders();

        if NoOfErrors <> 0 then begin
            Commit();
            SendError(NoOfErrors);
        end;
        TempNAVCancelledOrder.DeleteAll();

    end;

    var
        GlobalJobQueueEntry: Record "Job Queue Entry";
        TempNAVCancelledOrder: Record "GXL NAV Cancelled Order" temporary;

    local procedure CopyNAVCancelledOrderToBuffer()
    var
        NAVCancelledOrder: Record "GXL NAV Cancelled Order";
    begin
        TempNAVCancelledOrder.Reset();
        TempNAVCancelledOrder.DeleteAll();

        NAVCancelledOrder.SetCurrentKey("Process Status");
        NAVCancelledOrder.SetRange("Process Status", NAVCancelledOrder."Process Status"::Imported);
        if NAVCancelledOrder.FindSet() then
            repeat
                TempNAVCancelledOrder := NAVCancelledOrder;
                TempNAVCancelledOrder.Insert();
            until NAVCancelledOrder.Next() = 0;
    end;

    local procedure ProcessCancelledOrders(): Integer
    var
        NAVCancelledOrder: Record "GXL NAV Cancelled Order";
        NoOfErrors: Integer;
    begin
        NoOfErrors := 0;
        if TempNAVCancelledOrder.FindSet() then
            repeat
                Commit();
                NAVCancelledOrder := TempNAVCancelledOrder;
                NAVCancelledOrder.Find();
                if not CancelOrder(NAVCancelledOrder) then
                    NoOfErrors += 1;
            until TempNAVCancelledOrder.Next() = 0;
        exit(NoOfErrors);

    end;

    procedure CancelOrder(var NAVCancelledOrder: Record "GXL NAV Cancelled Order") Ok: Boolean
    var
        NAVCancelOrder: Codeunit "GXL NAV Cancel Order";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
    begin
        Ok := true;
        ClearLastError();
        if not NAVCancelOrder.Run(NAVCancelledOrder) then begin
            if not MiscUtilities.IsLockingError(GetLastErrorCode()) then begin
                SetErrored(NAVCancelledOrder, GetLastErrorText());
                NAVCancelledOrder.Modify();
                Ok := false;
            end;
        end;
    end;

    procedure SetProcessed(var NAVCancelledOrder: Record "GXL NAV Cancelled Order")
    begin
        NAVCancelledOrder."Process Status" := NAVCancelledOrder."Process Status"::Processed;
        NAVCancelledOrder."Error Message" := '';
        NAVCancelledOrder."Processed Date Time" := CurrentDateTime();
    end;

    procedure SetErrored(var NAVCancelledOrder: Record "GXL NAV Cancelled Order"; ErrorMsg: Text)
    begin
        NAVCancelledOrder."Process Status" := NAVCancelledOrder."Process Status"::"Processing Error";
        NAVCancelledOrder."Error Message" := CopyStr(ErrorMsg, 1, MaxStrLen(NAVCancelledOrder."Error Message"));
        NAVCancelledOrder."Processed Date Time" := CurrentDateTime();
    end;

    local procedure SendError(NoOfErrors: Integer)
    var
        JobQueueEntrySendEnail: Codeunit "GXL Job Queue Entry-Send Email";
        ErrMsg: Text;
    begin
        if not IsNullGuid(GlobalJobQueueEntry.ID) then
            if GlobalJobQueueEntry."GXL Error Notif. Email Address" <> '' then begin
                ErrMsg := StrSubstNo('There are %1 Cancelled orders could not be rocessed. Please check "Error Message" on the NAV Cancelled Order for details', NoOfErrors);
                // >> Upgrade
                //GlobalJobQueueEntry.SetErrorMessage(ErrMsg);
                GlobalJobQueueEntry.SetError(ErrMsg);
                // << Upgrade
                JobQueueEntrySendEnail.SetOptions(1, '', 0); //Error
                JobQueueEntrySendEnail.SendEmail(GlobalJobQueueEntry);
            end;
    end;
}