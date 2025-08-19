codeunit 50142 "GXL NAV Create Orders"
{
    /*Change Log;
        ERP-397 26-10-21 LP: Exflow and Purchase Order Creation
    */

    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        NoOfErrors: Integer;
    begin
        GlobalJobQueueEntry := Rec;
        CopyNAVConfirmedOrderToBuffer();
        CloseOldVersions(); //ERP-328 +
        NoOfErrors := CreateOrders();

        if NoOfErrors <> 0 then begin
            Commit();
            SendError(NoOfErrors);
        end;
        TempNAVConfirmedOrder.Reset();
        TempNAVConfirmedOrder.DeleteAll();

    end;

    var
        GlobalJobQueueEntry: Record "Job Queue Entry";
        TempNAVConfirmedOrder: Record "GXL NAV Confirmed Order" temporary;

    local procedure CopyNAVConfirmedOrderToBuffer()
    var
        NAVConfirmedOrder: Record "GXL NAV Confirmed Order";
    begin
        TempNAVConfirmedOrder.Reset();
        TempNAVConfirmedOrder.DeleteAll();

        NAVConfirmedOrder.SetCurrentKey("Process Status");
        NAVConfirmedOrder.SetRange("Process Status", NAVConfirmedOrder."Process Status"::Imported);
        if NAVConfirmedOrder.FindSet() then
            repeat
                //ERP-328 +
                // TempNAVConfirmedOrder := NAVConfirmedOrder;
                // TempNAVConfirmedOrder.Insert();
                TempNAVConfirmedOrder.SetRange("Document Type", NAVConfirmedOrder."Document Type");
                TempNAVConfirmedOrder.SetRange("No.", NAVConfirmedOrder."No.");
                TempNAVConfirmedOrder.SetRange("Process Status", TempNAVConfirmedOrder."Process Status"::Imported);
                if TempNAVConfirmedOrder.FindFirst() then begin
                    //Close old version if it has not been processed
                    if TempNAVConfirmedOrder."Version No." < NAVConfirmedOrder."Version No." then begin
                        SetClosed(TempNAVConfirmedOrder, StrSubstNo('New Version No. %1 exists', NAVConfirmedOrder."Version No."));
                        TempNAVConfirmedOrder.Modify();
                    end else begin
                        TempNAVConfirmedOrder := NAVConfirmedOrder;
                        SetClosed(TempNAVConfirmedOrder, StrSubstNo('New Version No. %1 exists', TempNAVConfirmedOrder."Version No."));
                        TempNAVConfirmedOrder.Insert();
                    end;
                end else begin
                    TempNAVConfirmedOrder := NAVConfirmedOrder;
                    TempNAVConfirmedOrder.Insert();
                end;
            //ERP-328 -
            until NAVConfirmedOrder.Next() = 0;
    end;

    //ERP-328 +
    local procedure CloseOldVersions()
    var
        NAVConfirmedOrder: Record "GXL NAV Confirmed Order";
    begin
        TempNAVConfirmedOrder.Reset();
        TempNAVConfirmedOrder.SetRange("Process Status", TempNAVConfirmedOrder."Process Status"::Closed);
        if TempNAVConfirmedOrder.Find('-') then
            repeat
                NAVConfirmedOrder := TempNAVConfirmedOrder;
                if NAVConfirmedOrder.Find() then begin
                    SetClosed(NAVConfirmedOrder, TempNAVConfirmedOrder."Error Message");
                    NAVConfirmedOrder.Modify();
                end;
            until TempNAVConfirmedOrder.Next() = 0;
        TempNAVConfirmedOrder.DeleteAll();
    end;
    //ERP-328 -

    local procedure CreateOrders(): Integer
    var
        NAVConfirmedOrder: Record "GXL NAV Confirmed Order";
        NoOfErrors: Integer;
    begin
        NoOfErrors := 0;
        //ERP-328 +
        TempNAVConfirmedOrder.Reset();
        TempNAVConfirmedOrder.SetCurrentKey("Process Status");
        TempNAVConfirmedOrder.SetRange("Process Status", TempNAVConfirmedOrder."Process Status"::Imported);
        //ERP-328 -
        if TempNAVConfirmedOrder.FindSet() then
            repeat
                Commit();
                NAVConfirmedOrder := TempNAVConfirmedOrder;
                if NAVConfirmedOrder.Find() then begin
                    if not CreateOrder(NAVConfirmedOrder) then
                        NoOfErrors += 1;
                end;
            until TempNAVConfirmedOrder.Next() = 0;
        exit(NoOfErrors);

    end;

    procedure CreateOrder(var NAVConfirmedOrder: Record "GXL NAV Confirmed Order") Ok: Boolean
    var
        PurchHead: Record "Purchase Header";
        TransHead: Record "Transfer Header";
        NAVValidateCreateOrder: Codeunit "GXL NAV Validate-Create Order";
        MiscUtilities: Codeunit "GXL Misc. Utilities";
        ReleasePurchDoc: Codeunit "Release Purchase Document";
        ReleaseTransDoc: Codeunit "Release Transfer Document";
        ModifyHeader: Boolean;
    begin
        Ok := true;
        ModifyHeader := true;
        ClearLastError();
        if NAVValidateCreateOrder.Run(NAVConfirmedOrder) then begin
            SetProcessed(NAVConfirmedOrder);
            Commit();
            case NAVConfirmedOrder."Document Type" of
                NAVConfirmedOrder."Document Type"::Purchase:
                    begin
                        NAVValidateCreateOrder.GetPurchaseHeader(PurchHead);
                        //ERP-397 +
                        PurchHead.Get(PurchHead."Document Type", PurchHead."No.");
                        //ERP-397 -
                        Clear(ReleasePurchDoc);
                        if ReleasePurchDoc.Run(PurchHead) then;
                    end;
                NAVConfirmedOrder."Document Type"::Transfer:
                    begin
                        NAVValidateCreateOrder.GetTransferHeader(TransHead);
                        Clear(ReleaseTransDoc);
                        if ReleaseTransDoc.Run(TransHead) then;
                    end;
            end;
        end else begin
            if not MiscUtilities.IsLockingError(GetLastErrorCode()) then begin
                SetErrored(NAVConfirmedOrder, GetLastErrorText());
                Ok := false;
            end else
                ModifyHeader := false;
        end;
        if ModifyHeader then
            NAVConfirmedOrder.Modify();

    end;

    procedure SetProcessed(var NAVConfirmedOrder: Record "GXL NAV Confirmed Order")
    begin
        NAVConfirmedOrder."Process Status" := NAVConfirmedOrder."Process Status"::Created;
        NAVConfirmedOrder."Error Message" := '';
        NAVConfirmedOrder."Processed Date Time" := CurrentDateTime();
    end;

    procedure SetErrored(var NAVConfirmedOrder: Record "GXL NAV Confirmed Order"; ErrorMsg: Text)
    begin
        NAVConfirmedOrder."Process Status" := NAVConfirmedOrder."Process Status"::"Creation Error";
        NAVConfirmedOrder."Error Message" := CopyStr(ErrorMsg, 1, MaxStrLen(NAVConfirmedOrder."Error Message"));
        NAVConfirmedOrder."Processed Date Time" := CurrentDateTime();
    end;

    local procedure SendError(NoOfErrors: Integer)
    var
        JobQueueEntrySendEnail: Codeunit "GXL Job Queue Entry-Send Email";
        ErrMsg: Text;
    begin
        if not IsNullGuid(GlobalJobQueueEntry.ID) then
            if GlobalJobQueueEntry."GXL Error Notif. Email Address" <> '' then begin
                ErrMsg := StrSubstNo('There are %1 confirmed orders could not be created. Please check "Error Message" on the NAV Confirmed Order for details', NoOfErrors);
                // >> Upgrade
                //GlobalJobQueueEntry.SetErrorMessage(ErrMsg);
                GlobalJobQueueEntry.SetError(ErrMsg);
                // << Upgrade
                JobQueueEntrySendEnail.SetOptions(1, '', 0); //Error
                JobQueueEntrySendEnail.SendEmail(GlobalJobQueueEntry);
            end;
    end;

    //ERP-328 +
    procedure SetClosed(var NAVConfirmedOrder: Record "GXL NAV Confirmed Order"; Msg: Text)
    begin
        NAVConfirmedOrder."Process Status" := NAVConfirmedOrder."Process Status"::Closed;
        NAVConfirmedOrder."Error Message" := CopyStr(Msg, 1, MaxStrLen(NAVConfirmedOrder."Error Message"));
        NAVConfirmedOrder."Processed Date Time" := CurrentDateTime();
    end;

    procedure CheckExistingVersionIsLatest(var NAVConfirmedOrder: Record "GXL NAV Confirmed Order")
    var
        NAVConfirmedOrder2: Record "GXL NAV Confirmed Order";
    begin
        NAVConfirmedOrder2.SetCurrentKey("Document Type", "No.", "Version No.");
        NAVConfirmedOrder2.SetRange("Document Type", NAVConfirmedOrder."Document Type");
        NAVConfirmedOrder2.SetRange("No.", NAVConfirmedOrder."No.");
        if NAVConfirmedOrder2.FindLast() then
            if NAVConfirmedOrder2."Version No." > NAVConfirmedOrder."Version No." then
                Error('The %1 %2 has latest version than the existing one. Order cannot be processed.',
                    NAVConfirmedOrder."Document Type", NAVConfirmedOrder."No.");
    end;
    //ERP-328 -

}