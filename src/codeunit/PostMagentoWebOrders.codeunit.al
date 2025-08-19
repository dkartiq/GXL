// 001 18.11.2024 KDU https://petbarnjira.atlassian.net/browse/LCB-726
codeunit 50100 "GXL Post Magento Web Orders"
{
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        if not CheckIfProcessingEnabled(true) then
            exit;
        HandleWebOrders();
        HandlePendingPOSTransactions();
    end;

    var
        IntegrSetup: Record "GXL Integration Setup";
        TempErrorLog: Record "GXL Magento WebOrder Error Log" temporary;
        ErrorLog: Record "GXL Magento WebOrder Error Log";
        TempStore: Record "LSC Store" temporary;
        GlobalStore: Record "LSC Store";
        TempPOSTerminal: record "LSC POS Terminal" temporary;
        GlobalPOSTerminal: record "LSC POS Terminal";
        TempTenderType: record "LSC Tender Type" temporary;
        GlobalTenderType: record "LSC Tender Type";
        VATBusPostingGrp: record "VAT Business Posting Group";
        TempIncomeExpenseAcc: Record "LSC Income/Expense Account" temporary;
        GlobalIncomeExpenseAcc: Record "LSC Income/Expense Account";
        LegacyItemHelper: Codeunit "GXL Legacy Item Helpers";
        ValidateOnly: Boolean;
        LatestWebOrderProcessingDateTime: DateTime;
        HasLatestWebOrderProcessingDateTime: Boolean;
        HasIntegrSetup: Boolean;
        NextTempLogEntryNo: Integer;
        FromDateTime: DateTime;


    local procedure HandleWebOrders()
    var
        WebOrder: Record "GXL Magento Web Order";
        // >> 001 
        // PrevTransID: Code[20];  
        // LastNotCheckedTransID: Code[20]; 
        // ProcessTransactionID: Code[20]; 
        PrevTransID: Code[50];
        LastNotCheckedTransID: Code[50];
        ProcessTransactionID: Code[50];
    // << 001 

    begin
        if WebOrder.IsEmpty() then
            exit;
        InitGlobalVariables();
        CalcLatestWebOrderProcessingDateTime();

        // Basic data checks and validation
        CheckOrdersBasic();
        // Check consistency per Transaction ID 
        CheckOrderTransIDConsistency();

        if (not ValidateOnly) then begin
            // Posting
            WebOrder.Reset();
            //ERP-333 +
            if FromDateTime <> 0DT then begin
                WebOrder.SetCurrentKey("Transaction ID", "Last Modified Date-Time");
                WebOrder.SetFilter("Transaction ID", '<>%1', '');
                WebOrder.SetFilter("Last Modified Date-Time", '>=%1', FromDateTime);
            end else begin
                //ERP-333 -
                WebOrder.SetCurrentKey("Transaction ID");
                WebOrder.SetFilter("Transaction ID", '<>%1', '');
            end;
            if not WebOrder.FindSet() then
                exit;
            PrevTransID := WebOrder."Transaction ID";
            repeat
                if (PrevTransID <> WebOrder."Transaction ID") then
                    if (ProcessTransactionID <> '') then
                        ProcessTransactions(ProcessTransactionID);

                if (WebOrder.Status = WebOrder.Status::Validated) and
                   (WebOrder."Transaction ID" <> LastNotCheckedTransID)
                then begin
                    PrevTransID := WebOrder."Transaction ID";
                    ProcessTransactionID := WebOrder."Transaction ID";
                end else begin
                    LastNotCheckedTransID := WebOrder."Transaction ID";
                    ProcessTransactionID := '';
                end;
            until WebOrder.Next() = 0;
            if (ProcessTransactionID <> '') then
                ProcessTransactions(ProcessTransactionID);
        end;
    end;
    // >> 001 
    //local procedure ProcessTransactions(var ProcessTransactionID: Code[20]) 
    local procedure ProcessTransactions(var ProcessTransactionID: Code[50])
    // << 001 
    var
        WebOrder: Record "GXL Magento Web Order";
        POSTransaction: Record "LSC POS Transaction";
        MagentoWebOrderHelper: Codeunit "GXL Magento Web Order Helper";
        PosReceiptNo: Code[20];
        PostedTransHeaderNo: Integer;
        OK: Boolean;
        LastErrMsgText: Text;
        AmtDiff: Decimal;
    begin
        if (ProcessTransactionID = '') then
            exit;
        WebOrder.SetCurrentKey("Transaction ID", "Transaction Type", "Line Number");
        WebOrder.SetRange("Transaction ID", ProcessTransactionID);
        //ERP-333 +
        // WebOrder.FindFirst(); 
        if not WebOrder.FindFirst() then
            exit;
        //ERP-333 -
        ProcessTransactionID := '';

        ClearLastError();
        // Create POS Transaction/lines
        MagentoWebOrderHelper.SetCreatePOStransParameters(WebOrder."Transaction ID");
        MagentoWebOrderHelper.SetSetup(IntegrSetup); //CR028
        OK := MagentoWebOrderHelper.Run();
        MagentoWebOrderHelper.GetCreatePOStransResult(PosReceiptNo);

        if not OK then
            LastErrMsgText := copystr(GetLastErrorText(), 1, MaxStrLen(ErrorLog."Error Message"));

        // >> LCB-780
        if ok then begin
            //If there are new lines stop the process and exit
            WebOrder.SetRange(Status, WebOrder.Status::New);
            if not WebOrder.IsEmpty then
                exit;

            WebOrder.SetRange(Status, WebOrder.Status::Processed);
        end;
        // << LCB-780

        WebOrder.FindSet();
        repeat
            if OK then begin
                WebOrder.ArchiveAndDelete();
            end else begin
                WebOrder.Status := WebOrder.Status::Error;
                WebOrder.Modify();
                Clear(ErrorLog);
                ErrorLog."Web Order Entry No." := WebOrder."Entry No.";
                ErrorLog."Error Message" := LastErrMsgText;
                ErrorLog.Insert(true);
            end;
        until WebOrder.Next() = 0;
        Commit();

        if OK then begin  // Post POSTrans
            //>> BUGFIX
            // POSTransaction.CalcFields("Gross Amount", Payment);
            POSTransaction.SetAutoCalcFields("Gross Amount", Payment, "Income/Exp. Amount");
            //<< BUGFIX
            if POSTransaction.Get(PosReceiptNo) then begin
                //Jira PS-1780 - allow 4 cents difference +
                // Has sales and payment lines?
                //if (POSTransaction."Gross Amount" <> 0) and (POSTransaction.Payment <> 0) and
                // ((POSTransaction."Gross Amount" + POSTransaction."Income/Exp. Amount") = POSTransaction.Payment) //sales amount and payment amount must be the same
                //then begin
                //PS-2307+
                //if (POSTransaction."Gross Amount" <> 0) and (POSTransaction.Payment <> 0) then begin
                if IsItemLineFound(POSTransaction) and IsPaymentLineFound(POSTransaction) then begin
                    //PS-2307-
                    AmtDiff := POSTransaction."Gross Amount" + POSTransaction."Income/Exp. Amount" - POSTransaction.Payment;
                    if (Abs(AmtDiff) <= 0.04) then begin
                        //Jira PS-1780 - allow 4 cents difference -
                        Clear(MagentoWebOrderHelper);
                        MagentoWebOrderHelper.SetPostPOStransParameters(POSTransaction."Receipt No.");
                        OK := MagentoWebOrderHelper.Run();
                        MagentoWebOrderHelper.GetPostPOStransResult(PostedTransHeaderNo);
                        Commit();
                    end;
                end;
            end;
        end;
    end;

    local procedure CheckOrdersBasic()
    var
        WebOrder: Record "GXL Magento Web Order";
        xWebOrder: Record "GXL Magento Web Order";
        WebOrder2: Record "GXL Magento Web Order";
        DoWriteCommit: Boolean;
        NoOfDays: Integer;
    begin
        InitGlobalVariables();
        CalcLatestWebOrderProcessingDateTime();

        //ERP-333 +
        if IntegrSetup."Magento Recent Process Days" <> 0 then
            FromDateTime := CreateDateTime(Today() - IntegrSetup."Magento Recent Process Days", 0T);
        //ERP-333 -

        // Check data
        WebOrder.SetCurrentKey("Last Modified Date-Time");
        //ERP-333 +
        if FromDateTime <> 0DT then
            WebOrder.SetFilter("Last Modified Date-Time", '>=%1', FromDateTime);
        //ERP-333 -
        if not WebOrder.FindSet() then
            exit;
        repeat
            if WebOrder."Manually Modified" or (WebOrder."Last Modified Date-Time" < LatestWebOrderProcessingDateTime) then begin
                xWebOrder := WebOrder;
                ResetTempErrorLog();
                CheckAndUpdateOrderValues(WebOrder);
                if (NextTempLogEntryNo > 0) then begin
                    WebOrder.Status := WebOrder.Status::Error;
                    TransferTemp2ErrorLog(WebOrder."Entry No.");
                    DoWriteCommit := true;
                end else begin
                    WebOrder.Status := WebOrder.Status::Validated;
                    DoWriteCommit := DoWriteCommit or RemoveWebOrderErrorLog(WebOrder."Entry No.");
                end;

                if Format(WebOrder) <> Format(xWebOrder) then begin
                    // Was record modified by API -> Status changed to New
                    if WebOrder2.Get(WebOrder."Entry No.") and (WebOrder2.Status = xWebOrder.Status) then begin
                        WebOrder.Modify();
                        DoWriteCommit := true;
                    end;
                end;
            end;
        until WebOrder.Next() = 0;
        if DoWriteCommit then
            Commit();
    end;

    local procedure CheckAndUpdateOrderValues(var WebOrder: Record "GXL Magento Web Order")
    var
        DoContinue: Boolean;
    begin
        DoContinue := true;
        GlobalStore."No." := '';
        GlobalPOSTerminal."No." := '';
        // Clear legacy mapping fields
        WebOrder."Sales Item No." := '';
        WebOrder."Sales Item UoM Code" := '';

        if (WebOrder."Transaction ID" = '') then begin
            AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is mandatory.', WebOrder.FieldCaption("Transaction ID")));
            DoContinue := false;
        end;
        if (WebOrder."Store No." = '') then
            AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is mandatory.', WebOrder.FieldCaption("Store No.")))
        else begin
            if not GetStore(WebOrder."Store No.") then
                AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is invalid (%2).', WebOrder.FieldCaption("Store No."), WebOrder."Store No."));
        end;
        if (WebOrder."Terminal No." = '') then
            AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is mandatory.', WebOrder.FieldCaption("Terminal No.")))
        else begin
            if not GetPOSTerminal(WebOrder."Terminal No.") then
                AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is invalid (%2).', WebOrder.FieldCaption("Terminal No."), WebOrder."Terminal No."));
        end;
        if (GlobalStore."No." <> '') and (GlobalPOSTerminal."No." <> '') then begin
            IF (GlobalPOSTerminal."Store No." <> GlobalStore."No.") THEN
                AddTempError(WebOrder."Entry No.", StrSubstNo('%1 %2 is not setup for %3 %4.', GlobalPOSTerminal.TableCaption(), WebOrder."Terminal No.", GlobalStore.TableCaption(), GlobalStore."No."));
        end;

        if (WebOrder."Transaction Date" = 0D) then
            AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is mandatory.', WebOrder.FieldCaption("Transaction Date")));

        //CR028 - add transaction type IncomeExpense
        if not (WebOrder."Transaction Type" in [WebOrder."Transaction Type"::Sales, WebOrder."Transaction Type"::Payment]) then begin
            if (WebOrder."Transaction Type" = WebOrder."Transaction Type"::" ") then
                AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is mandatory.', WebOrder.FieldCaption("Transaction Type")))
            else
                AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is invalid (%2).', WebOrder.FieldCaption("Transaction Type"), WebOrder."Transaction Type"));
            DoContinue := false;
        end;
        IF (WebOrder."Transaction Type" = WebOrder."Transaction Type"::Sales) THEN BEGIN
            if (WebOrder."Item Number" = '') then begin
                AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is mandatory.', WebOrder.FieldCaption("Item Number")));
                DoContinue := false;
            end;
            if (WebOrder.Quantity = 0) then begin
                AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is mandatory.', WebOrder.FieldCaption(Quantity)));
                DoContinue := false;
            end;
        END;
        //>> CR028
        if (WebOrder."Transaction Type" = WebOrder."Transaction Type"::Payment) and (WebOrder."Freight Charge" <> 0) then begin
            if IntegrSetup."Magento Income/Expense Acc." = '' then begin
                AddTempError(WebOrder."Entry No.", StrSubstNo('%1 must be specified on %2', IntegrSetup.FieldCaption("Magento Income/Expense Acc."), IntegrSetup.TableCaption()));
                DoContinue := false;
            end;
        end;
        //<< CR028

        if not DoContinue then
            exit;
        case WebOrder."Transaction Type" of
            WebOrder."Transaction Type"::Sales:
                begin
                    //PS-2307+
                    //Allow zero price                        
                    // if (Price = 0) then
                    //     AddTempError("Entry No.", StrSubstNo('%1 is mandatory for %2 = %3.', FieldCaption(Price), FieldCaption("Transaction Type"), "Transaction Type"));
                    //PS-2307-

                    LegacyItemHelper.GetItemNo(WebOrder."Item Number", WebOrder."Sales Item No.", WebOrder."Sales Item UoM Code");
                    if (WebOrder."Sales Item No." = '') or (WebOrder."Sales Item UoM Code" = '') then
                        AddTempError(WebOrder."Entry No.", StrSubstNo('%1 cannot be found or mapped (%2).', WebOrder.FieldCaption("Item Number"), WebOrder."Item Number"));
                end;
            WebOrder."Transaction Type"::Payment:
                begin
                    if (WebOrder."Tender Type" = '') then
                        AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is mandatory for %2 = %3.', WebOrder.FieldCaption("Tender Type"), WebOrder.FieldCaption("Transaction Type"), WebOrder."Transaction Type"))
                    else
                        if not GetTenderType(GlobalStore."No.", WebOrder."Tender Type") then
                            AddTempError(WebOrder."Entry No.", StrSubstNo('%1 is invalid (%2) for %3 = %4.', WebOrder.FieldCaption("Tender Type"), WebOrder."Tender Type", GlobalStore.TableCaption(), WebOrder."Store No."));

                    //PS-2307+
                    //Allow Zero                        
                    // if ("Amount Tendered" = 0) then
                    //     AddTempError("Entry No.", StrSubstNo('%1 is mandatory for %2 = %3.', FieldCaption("Amount Tendered"), FieldCaption("Transaction Type"), "Transaction Type"));
                    //PS-2307-

                    //>> CR028
                    if (WebOrder."Freight Charge" <> 0) then begin
                        if not GetIncomeExpenseAccount(WebOrder."Store No.", IntegrSetup."Magento Income/Expense Acc.") then
                            AddTempError(WebOrder."Entry No.", StrSubstNo('%1 does not exist for %2 = %3, %4 = %5',
                                GlobalIncomeExpenseAcc.TableCaption(),
                                GlobalIncomeExpenseAcc.FieldCaption("Store No."), WebOrder."Store No.",
                                GlobalIncomeExpenseAcc.FieldCaption("No."), IntegrSetup."Magento Income/Expense Acc."));
                    end;
                    //<< CR028
                end;
        end;
    end;

    local procedure CheckOrderTransIDConsistency()
    var
        WebOrder: Record "GXL Magento Web Order";
        TempWebOrder: Record "GXL Magento Web Order" temporary;
        DoWriteCommit: Boolean;
    begin
        WebOrder.Reset();
        WebOrder.SetCurrentKey("Transaction ID");
        WebOrder.SetFilter("Transaction ID", '<>%1', '');
        if not WebOrder.FindSet() then
            exit;

        Clear(TempWebOrder);
        repeat
            if (WebOrder.Status = WebOrder.Status::Validated) then begin
                if (WebOrder."Transaction ID" = TempWebOrder."Transaction ID") then begin
                    if (WebOrder."Store No." <> TempWebOrder."Store No.") or
                       (WebOrder."Terminal No." <> TempWebOrder."Terminal No.")
                    then begin
                        ResetTempErrorLog();
                        if (WebOrder."Store No." <> TempWebOrder."Store No.") then
                            AddTempError(WebOrder."Entry No.", StrSubstNo('%1 must the same for all records with this %2.', WebOrder.FieldCaption("Store No."), WebOrder.FieldCaption("Transaction ID")));
                        if (WebOrder."Terminal No." <> TempWebOrder."Terminal No.") then
                            AddTempError(WebOrder."Entry No.", StrSubstNo('%1 must the same for all records with this %2.', WebOrder.FieldCaption("Terminal No."), WebOrder.FieldCaption("Transaction ID")));

                        if (NextTempLogEntryNo > 0) then begin
                            WebOrder.Status := WebOrder.Status::Error;
                            WebOrder.Modify();
                            TransferTemp2ErrorLog(WebOrder."Entry No.");
                            DoWriteCommit := true;
                        end
                    end;
                end else
                    TempWebOrder := WebOrder;
            end;
        until WebOrder.Next() = 0;
        if DoWriteCommit then
            Commit();
    end;

    local procedure GetSetup(DoFreshRead: Boolean)
    begin
        if DoFreshRead then
            IntegrSetup.Get()
        else begin
            if not HasIntegrSetup then
                IntegrSetup.Get();
        end;
        HasIntegrSetup := true;
    end;

    local procedure CalcLatestWebOrderProcessingDateTime()
    var
        msecDelay: BigInteger;
    begin
        if HasLatestWebOrderProcessingDateTime then
            exit;
        // We do not want to start processing records with the same Transaction ID until they all are uploaded by the API.
        GetSetup(false);
        LatestWebOrderProcessingDateTime := RoundDateTime(CurrentDateTime(), 1000, '<');
        msecDelay := 1000 * IntegrSetup."Magento POS-Trans. Post. Delay";
        if (msecDelay <= 0) then // Set min. 1 second delay
            msecDelay := 1000;
        LatestWebOrderProcessingDateTime := LatestWebOrderProcessingDateTime - msecDelay;
        HasLatestWebOrderProcessingDateTime := true;
    end;

    local procedure InitGlobalVariables()
    begin
        TempStore.DeleteAll();
        TempPOSTerminal.DeleteAll();
        HasLatestWebOrderProcessingDateTime := false;
        FromDateTime := 0DT; //ERP-333 +
    end;

    local procedure ResetTempErrorLog()
    begin
        NextTempLogEntryNo := 0;
        TempErrorLog.DeleteAll();
    end;

    local procedure AddTempError(OrderEntryNo: Integer; ErrorTxt: text)
    begin
        NextTempLogEntryNo := NextTempLogEntryNo + 1;
        TempErrorLog.Init();
        TempErrorLog."Entry No." := NextTempLogEntryNo;
        TempErrorLog."Web Order Entry No." := OrderEntryNo;
        TempErrorLog."Error Message" := CopyStr(ErrorTxt, 1, MaxStrLen(TempErrorLog."Error Message"));
        TempErrorLog.Insert();
    end;

    local procedure RemoveWebOrderErrorLog(OrderEntryNo: Integer) RecordsDeleted: Boolean
    begin
        ErrorLog.Reset();
        ErrorLog.SetCurrentKey("Web Order Entry No.");
        ErrorLog.SetRange("Web Order Entry No.", OrderEntryNo);
        if not ErrorLog.IsEmpty() then begin
            ErrorLog.DeleteAll();
            RecordsDeleted := true;
        end;
        ErrorLog.Reset();
    end;

    local procedure TransferTemp2ErrorLog(OrderEntryNo: Integer)
    begin
        RemoveWebOrderErrorLog(OrderEntryNo);
        if not TempErrorLog.FindSet() then
            exit;
        repeat
            ErrorLog := TempErrorLog;
            ErrorLog."Entry No." := 0;
            ErrorLog.Insert(true);
        until TempErrorLog.Next() = 0;
        TempErrorLog.DeleteAll();
    end;

    local procedure GetStore(StoreNo: Code[10]): Boolean
    begin
        if (StoreNo = '') then
            exit(false);
        if not TempStore.Get(StoreNo) then begin
            if GlobalStore.Get(StoreNo) then begin
                GlobalStore.TestField("Store VAT Bus. Post. Gr.");
                if not VATBusPostingGrp.Get(GlobalStore."Store VAT Bus. Post. Gr.") then
                    GlobalStore.FieldError("Store VAT Bus. Post. Gr.");
                TempStore := GlobalStore;
                TempStore.Insert();
            end else begin
                exit(false);
            end;
        end else begin
            GlobalStore := TempStore;
        end;
        exit(true);
    end;

    local procedure GetPOSTerminal(POSTerminalNo: Code[10]): Boolean
    begin
        if (POSTerminalNo = '') then
            exit(false);
        if not TempPOSTerminal.Get(POSTerminalNo) then begin
            if GlobalPOSTerminal.Get(POSTerminalNo) then begin
                TempPOSTerminal := GlobalPOSTerminal;
                TempPOSTerminal.Insert();
            end else begin
                exit(false);
            end;
        end else begin
            GlobalPOSTerminal := TempPOSTerminal;
        end;
        exit(true);
    end;

    local procedure GetTenderType(StoreNo: Code[10]; TenderTypeCode: Code[10]): Boolean
    begin
        if (StoreNo = '') or (TenderTypeCode = '') then
            exit(false);
        if not TempTenderType.Get(StoreNo, TenderTypeCode) then begin
            if GlobalTenderType.Get(StoreNo, TenderTypeCode) then begin
                TempTenderType := GlobalTenderType;
                TempTenderType.Insert();
            end else begin
                exit(false);
            end;
        end else begin
            GlobalTenderType := TempTenderType;
        end;
        exit(true);
    end;

    procedure CheckIfProcessingEnabled(ShowError: Boolean) OK: Boolean
    begin
        GetSetup(true);
        if GuiAllowed() then begin
            if (IntegrSetup."Magento POS-Trans. Posting" <> IntegrSetup."Magento POS-Trans. Posting"::Manual) then begin
                if ShowError then
                    Error('You cannot process the web orders because %1 = %2 in %3.', IntegrSetup.FieldCaption("Magento POS-Trans. Posting"), IntegrSetup."Magento POS-Trans. Posting", IntegrSetup.TableCaption())
                else
                    exit(false);
            end;
        end else begin
            if (IntegrSetup."Magento POS-Trans. Posting" <> IntegrSetup."Magento POS-Trans. Posting"::"Job Queue") then
                exit(false);
        end;
        exit(true);
    end;

    procedure ManualProcessWebOrders(DoPost: Boolean)
    var
        WebOrder: Record "GXL Magento Web Order";
    begin
        CheckIfProcessingEnabled(true);
        if WebOrder.IsEmpty() then
            Error('There are no orders to process.');
        if DoPost then begin
            if not Confirm('Do you want to Post the web order(s) ?', false) then
                exit;
        end else begin
            if not Confirm('Do you want to Validate the web order(s) ?', false) then
                exit;
        end;
        CheckIfProcessingEnabled(true);
        ValidateOnly := not DoPost;
        HandleWebOrders();
    end;

    // >> 001 
    //local procedure AmountSalesAndTenderedMatched(TransactioNID: Code[20]): Boolean 
    local procedure AmountSalesAndTenderedMatched(TransactioNID: Code[50]): Boolean
    // << 001 
    var
        WebOrder: Record "GXL Magento Web Order";
        SalesAmt: Decimal;
        PmtAmt: Decimal;
    begin
        WebOrder.SetCurrentKey("Transaction ID");
        WebOrder.SetRange("Transaction ID", TransactioNID);
        WebOrder.SetRange("Transaction Type", WebOrder."Transaction Type"::Sales);
        WebOrder.CalcSums(Price);
        SalesAmt := WebOrder.Price;
        WebOrder.SetRange("Transaction Type", WebOrder."Transaction Type"::Payment);
        WebOrder.CalcSums("Amount Tendered");
        PmtAmt := WebOrder."Amount Tendered";
        exit(SalesAmt = PmtAmt);
    end;

    //>> CR028
    local procedure GetIncomeExpenseAccount(StoreNo: Code[10]; IncomeExpenseAccCode: Code[20]): Boolean
    begin
        if (StoreNo = '') or (IncomeExpenseAccCode = '') then
            exit(false);
        if not TempIncomeExpenseAcc.Get(StoreNo, IncomeExpenseAccCode) then begin
            if GlobalIncomeExpenseAcc.Get(StoreNo, IncomeExpenseAccCode) then begin
                TempIncomeExpenseAcc := GlobalIncomeExpenseAcc;
                TempIncomeExpenseAcc.Insert();
            end else
                exit(false);
        end else
            GlobalIncomeExpenseAcc := TempIncomeExpenseAcc;
        exit(true);
    end;
    //<< CR028

    //This function to post the pending POS Transaction which were failed to post due to uncached errors
    local procedure HandlePendingPOSTransactions()
    var
        POSTransaction: Record "LSC POS Transaction";
        WebOrder: Record "GXL Magento Web Order";
        MagentoWebOrderHelper: Codeunit "GXL Magento Web Order Helper";
        OK: Boolean;
        PostedTransHeaderNo: Integer;
        AmtDiff: Decimal;
    begin
        POSTransaction.SetCurrentKey("GXL Magento Web Order");
        POSTransaction.SetRange("GXL Magento Web Order", true);
        POSTransaction.SetAutoCalcFields("Gross Amount", Payment, "Income/Exp. Amount");
        if POSTransaction.FindSet() then
            repeat
                WebOrder.SetCurrentKey("Transaction ID");
                WebOrder.SetRange("Transaction ID", POSTransaction."GXL Magento WebOrder Trans. ID");
                if WebOrder.IsEmpty() then begin
                    //Jira PS-1780 - allow 4 cents difference +
                    // if (POSTransaction."Gross Amount" <> 0) and (POSTransaction.Payment <> 0)
                    //    and ((POSTransaction."Gross Amount" + POSTransaction."Income/Exp. Amount") = POSTransaction.Payment) //sales amount and payment amount must be the same
                    // then begin
                    //PS-2307+
                    //if (POSTransaction."Gross Amount" <> 0) and (POSTransaction.Payment <> 0) then begin
                    if IsItemLineFound(POSTransaction) and IsPaymentLineFound(POSTransaction) then begin
                        //PS-2307-
                        AmtDiff := POSTransaction."Gross Amount" + POSTransaction."Income/Exp. Amount" - POSTransaction.Payment;
                        if (Abs(AmtDiff) <= 0.04) then begin
                            //Jira PS-1780 - allow 4 cents difference -
                            Clear(MagentoWebOrderHelper);
                            MagentoWebOrderHelper.SetPostPOStransParameters(POSTransaction."Receipt No.");
                            OK := MagentoWebOrderHelper.Run();
                            MagentoWebOrderHelper.GetPostPOStransResult(PostedTransHeaderNo);
                            Commit();
                        end;
                    end;
                end;
            until POSTransaction.Next() = 0;
    end;

    //PS-2307+
    procedure IsPaymentLineFound(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        POSTransLine: Record "LSC POS Trans. Line";
    begin
        POSTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Payment);
        if not POSTransLine.IsEmpty() then
            exit(true)
        else
            exit(false);
    end;

    procedure IsItemLineFound(POSTransaction: Record "LSC POS Transaction"): Boolean
    var
        POSTransLine: Record "LSC POS Trans. Line";
    begin
        POSTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
        POSTransLine.SetRange("Entry Type", POSTransLine."Entry Type"::Item);
        if not POSTransLine.IsEmpty() then
            exit(true)
        else
            exit(false);
    end;
    //PS-2307-
}