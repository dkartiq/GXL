// 001 18.11.2024 KDU https://petbarnjira.atlassian.net/browse/LCB-726  
codeunit 50101 "GXL Magento Web Order Helper"
{
    trigger OnRun()
    var
        TmpRunAction: Integer;
    begin
        TmpRunAction := RunAction;
        RunAction := RunAction::DoNothing;
        case TmpRunAction of
            RunAction::CreatePOStrans:
                DoCreatePOStrans();
            RunAction::PostPOStrans:
                DoPostPOStrans();
        end;
    end;

    var
        IntegrationSetup: Record "GXL Integration Setup";
        POSsession: Codeunit "LSC POS Session"; //Single instance
        POSFunc: Codeunit "LSC POS Functions"; //Single instance
        RunAction: Option "DoNothing","CreatePOStrans","PostPOStrans";
        // >> 001 
        //CreateForWebOrderTransID: Code[20]; 
        CreateForWebOrderTransID: Code[50];
        // << 001 
        PosReceiptNo: Code[20];
        PostingPosTransReceiptNo: Code[20];
        PostedTransHeaderNo: Integer;
        SetupRead: Boolean;

    // >> 001 
    //procedure SetCreatePOStransParameters(WebOrderTransID: Code[20]) 
    procedure SetCreatePOStransParameters(WebOrderTransID: Code[50])
    // << 001 
    begin
        RunAction := RunAction::CreatePOStrans;
        CreateForWebOrderTransID := WebOrderTransID;
        PosReceiptNo := '';
    end;

    procedure GetCreatePOStransResult(var PosTransReceiptNo: Code[20])
    begin
        PosTransReceiptNo := PosReceiptNo;
    end;

    procedure SetPostPOStransParameters(PosTransReceiptNo: Code[20])
    begin
        RunAction := RunAction::PostPOStrans;
        PostedTransHeaderNo := 0;
        PostingPosTransReceiptNo := PosTransReceiptNo;
    end;

    procedure GetPostPOStransResult(var NewPostedTransHeaderNo: Integer)
    begin
        NewPostedTransHeaderNo := PostedTransHeaderNo;
    end;

    local procedure DoCreatePOStrans()
    var
        WebOrder: Record "GXL Magento Web Order";
        POSTransaction: Record "LSC POS Transaction";
        POSTransLine: record "LSC POS Trans. Line";
        Store: Record "LSC Store";
        NextLineNo: Integer;
        PmtLineNo: Integer;
        // >> GX-202329
        SalesTypeFromMagentoSalesType: Code[20];
        ModifyPOSTransaction: Boolean;
    // << GX-202329
    begin
        PosReceiptNo := '';
        if (CreateForWebOrderTransID = '') then
            exit;
        WebOrder.Reset();
        WebOrder.SetCurrentKey("Transaction ID", "Transaction Type", "Line Number");
        WebOrder.SetRange("Transaction ID", CreateForWebOrderTransID);
        if not WebOrder.FindSet() then
            exit;

        GetSetup(); //CR028
        Store.get(WebOrder."Store No.");
        POSsession.SetStore(Store."No."); // SingleInstance CU 99008919 used on POS trans validation

        // >> GX-202329
        SalesTypeFromMagentoSalesType := '';
        if WebOrder."Transaction Type" = WebOrder."Transaction Type"::Sales then
            SalesTypeFromMagentoSalesType := GetSalesTypeFromMagentoSalesTypeMapping(WebOrder."Sales Type");
        ModifyPOSTransaction := false;
        // << GX-202329

        // Check if POS Transaction already exists - otherwise Insert new
        PosReceiptNo := '';
        POSTransaction.SetCurrentKey("GXL Magento WebOrder Trans. ID");
        POSTransaction.SetRange("GXL Magento WebOrder Trans. ID", WebOrder."Transaction ID");
        if POSTransaction.FindFirst() then begin
            POSTransaction.Reset();
            if (POSTransaction."Entry Status" <> POSTransaction."Entry Status"::Suspended) then begin
                POSTransaction."Entry Status" := POSTransaction."Entry Status"::Suspended;
                //Using transaction date from payment as payment may made after sales
                if POSTransaction."Trans. Date" < WebOrder."Transaction Date" then begin
                    POSTransaction."Trans. Date" := WebOrder."Transaction Date";
                    POSTransaction."Trans Time" := Time(); //<< PS-1348
                end;
                // >> GX-202329
                //POSTransaction.Modify(); 
                ModifyPOSTransaction := true;
                // << GX-202329
            end else begin
                //Using transaction date from payment as payment may made after sales
                if POSTransaction."Trans. Date" < WebOrder."Transaction Date" then begin
                    POSTransaction."Trans. Date" := WebOrder."Transaction Date";
                    POSTransaction."Trans Time" := Time(); //<< PS-1348
                    // >> GX-202329
                    //POSTransaction.Modify(); 
                    ModifyPOSTransaction := true;
                    // << GX-202329
                end;
            end;
            // >> GX-202329
            if (POSTransaction."Sales Type" = '') and (SalesTypeFromMagentoSalesType <> '') then begin
                POSTransaction."Sales Type" := SalesTypeFromMagentoSalesType;
                ModifyPOSTransaction := true;
            end;
            if ModifyPOSTransaction then
                POSTransaction.Modify();
            // << GX-202329
            PosReceiptNo := POSTransaction."Receipt No.";
            POSTransLine.SetRange("Receipt No.", POSTransaction."Receipt No.");
            if POSTransLine.FindLast() then
                NextLineNo := POSTransLine."Line No.";
        end else begin
            // Create POS Transaction - header
            clear(POSTransaction);
            PosReceiptNo := FindNextPOSTransReceiptNo(WebOrder."Terminal No.");
            InsertPOSTransaction(POSTransaction, PosReceiptNo);
            //Moved to below as transactions do not come in once
            /*
            //Record Not Open Issue Fix            
            POSFunc.PosTransDiscLoadData(PosReceiptNo, true);
            POSFunc.InitTrackingInstanceID(POSTransaction);
            //Record Not Open Issue Fix
            */
            POSTransaction."Transaction Type" := POSTransaction."Transaction Type"::Sales;
            POSTransaction."GXL Magento WebOrder Trans. ID" := WebOrder."Transaction ID";
            POSTransaction."GXL Magento Web Order" := true;
            POSTransaction."Store No." := WebOrder."Store No.";
            POSTransaction."POS Terminal No." := WebOrder."Terminal No.";
            POSTransaction."Created on POS Terminal" := WebOrder."Terminal No.";
            POSTransaction."Staff ID" := WebOrder."Staff ID";
            POSTransaction."Trans. Date" := WebOrder."Transaction Date";
            POSTransaction."VAT Bus.Posting Group" := Store."Store VAT Bus. Post. Gr.";
            POSTransaction."Currency Factor" := 1;
            POSTransaction."Entry Status" := POSTransaction."Entry Status"::Suspended;
            //>> PS-1348
            POSTransaction."Trans Time" := Time();
            // >> GX-202329
            //POSTransaction."Sales Type" := IntegrationSetup."Magento Sales Type";
            POSTransaction."Sales Type" := SalesTypeFromMagentoSalesType;
            // << GX-202329
            //<< PS-1348
            POSTransaction.Modify();
        end;

        POSFunc.PosTransDiscFlush();
        POSFunc.PosTransDiscLoadData(PosReceiptNo, true);
        POSFunc.InitTrackingInstanceID(POSTransaction); //LS-TICKET:LSTS-27050
        repeat
            PmtLineNo := 0;
            NextLineNo := NextLineNo + 10000;
            POSTransLine.Init();
            POSTransLine."Receipt No." := POSTransaction."Receipt No.";
            POSTransLine."Line No." := NextLineNo;
            POSTransLine.Insert();
            POSTransLine."Store No." := WebOrder."Store No.";
            POSTransLine."POS Terminal No." := WebOrder."Terminal No.";
            POSTransLine."Trans. Date" := WebOrder."Transaction Date";
            POSTransLine."Trans. Time" := Time(); //<< PS-1348
            POSTransLine."Created by Staff ID" := WebOrder."Staff ID";
            case WebOrder."Transaction Type" of
                WebOrder."Transaction Type"::Sales:
                    begin
                        POSTransLine."Entry Type" := POSTransLine."Entry Type"::Item;
                        POSTransLine."Unit of Measure" := WebOrder."Sales Item UoM Code";
                        POSTransLine.Validate(Number, WebOrder."Sales Item No.");
                        POSTransLine.Validate(Quantity, WebOrder.Quantity);
                        POSTransLine.Validate(Price, WebOrder.Price);
                        POSTransLine.Amount := Round(POSTransLine.Amount, 0.01);
                    end;
                WebOrder."Transaction Type"::Payment:
                    begin
                        POSTransLine."Entry Type" := POSTransLine."Entry Type"::Payment;
                        POSTransLine.Validate(Number, WebOrder."Tender Type");
                        if (WebOrder.Quantity = 0) then
                            POSTransLine.Validate(Quantity, 1)
                        else
                            POSTransLine.Validate(Quantity, WebOrder.Quantity);
                        //>> PS-1597
                        //Validate(Price, WebOrder."Amount Tendered");
                        //Validate(Amount, WebOrder."Amount Tendered");
                        POSTransLine.Validate(Price, Round(WebOrder."Amount Tendered", 0.01));
                        POSTransLine.Validate(Amount, POSTransLine.Price);
                        //<< PS-1597 
                        PmtLineNo := POSTransLine."Line No."; //<< CR028
                    end;
            end;
            POSTransLine.Modify();

            //>> CR028
            //Freight charge
            if (WebOrder."Transaction Type" = WebOrder."Transaction Type"::Payment) and (WebOrder."Freight Charge" <> 0) then begin
                NextLineNo := NextLineNo + 10000;
                POSTransLine.Init();
                POSTransLine."Receipt No." := POSTransaction."Receipt No.";
                POSTransLine."Line No." := NextLineNo;
                POSTransLine.Insert();
                POSTransLine."Store No." := WebOrder."Store No.";
                POSTransLine."POS Terminal No." := WebOrder."Terminal No.";
                POSTransLine."Trans. Date" := WebOrder."Transaction Date";
                POSTransLine."Trans. Time" := Time(); //<< PS-1348
                POSTransLine."Created by Staff ID" := WebOrder."Staff ID";
                IntegrationSetup.TestField("Magento Income/Expense Acc.");
                POSTransLine."Entry Type" := POSTransLine."Entry Type"::IncomeExpense;
                POSTransLine.Validate(Number, IntegrationSetup."Magento Income/Expense Acc.");
                POSTransLine.Validate(Quantity, 1);
                POSTransLine.Validate(Price, Round(WebOrder."Freight Charge", 0.01));
                POSTransLine.Modify();
            end;
            //<< CR028

            WebOrder.Status := WebOrder.Status::Processed;
            WebOrder."POS Trans. Receipt No." := POSTransaction."Receipt No.";
            //>> CR028
            if (WebOrder."Transaction Type" = WebOrder."Transaction Type"::Payment) and (PmtLineNo <> 0) then
                WebOrder."POS Trans. Line No." := PmtLineNo
            else
                //<< CR028
                WebOrder."POS Trans. Line No." := POSTransLine."Line No.";
            WebOrder.Modify();
        until WebOrder.Next() = 0;
        PosReceiptNo := POSTransaction."Receipt No.";
    end;

    local procedure DoPostPOStrans()
    var
        POSTransaction: Record "LSC POS Transaction";
        POSPostUtility: Codeunit "LSC POS Post Utility";
    begin
        POSTransaction.Get(PostingPosTransReceiptNo);
        if (POSTransaction."Entry Status" <> POSTransaction."Entry Status"::" ") or
           (POSTransaction."Original Date" <> Today())
        then begin
            POSTransaction."Entry Status" := POSTransaction."Entry Status"::" ";
            POSTransaction."Original Date" := Today();
            POSTransaction.Modify();
        end;
        POSsession.SetStore(POSTransaction."Store No.");
        //>> CR028
        //Record not Open issue
        POSFunc.PosTransDiscFlush();
        POSFunc.PosTransDiscLoadData(PostingPosTransReceiptNo, true);
        //<< CR028
        PostedTransHeaderNo := POSPostUtility.ProcessTransaction(POSTransaction);
    end;

    local procedure FindNextPOSTransReceiptNo(POSTerminalNo: Code[10]): Code[20]
    var
        POSTransaction: Record "LSC POS Transaction";
        TransactionHeader: Record "LSC Transaction Header";
        ReceiptRangeFrom: Code[20];
        ReceiptRangeTo: Code[20];
        LastUsedReceiptNo: Code[20];
    begin
        ReceiptRangeFrom := ZeroPadText(POSTerminalNo, 10) + PADSTR('', 9, '0');
        ReceiptRangeTo := ZeroPadText(POSTerminalNo, 10) + PADSTR('', 9, '9');
        LastUsedReceiptNo := ReceiptRangeFrom;
        // Any posted transactions...
        TransactionHeader.SetCurrentKey("Receipt No.");
        TransactionHeader.SetRange("Receipt No.", ReceiptRangeFrom, ReceiptRangeTo);
        if TransactionHeader.FindLast() then
            LastUsedReceiptNo := TransactionHeader."Receipt No.";
        // Any current not posted trans...
        POSTransaction.SetRange("Receipt No.", ReceiptRangeFrom, ReceiptRangeTo);
        if POSTransaction.FindLast() then begin
            if (POSTransaction."Receipt No." > LastUsedReceiptNo) then
                LastUsedReceiptNo := POSTransaction."Receipt No.";
        end;
        exit(IncStr(LastUsedReceiptNo));
    end;

    local procedure InsertPOSTransaction(var POSTransaction: Record "LSc POS Transaction"; var PosReceiptNo: Code[20])
    var
        RetryCounter: Integer;
    begin
        POSTransaction."Receipt No." := PosReceiptNo;
        if POSTransaction.Insert() then
            exit;
        // Doing as in CU 99008900 POS Functions
        for RetryCounter := 1 to 2 do begin
            Sleep(100);
            PosReceiptNo := IncStr(PosReceiptNo);
            if POSTransaction.Insert() then
                exit;
        end;
        PosReceiptNo := IncStr(PosReceiptNo);
        POSTransaction.Insert();
    end;

    local procedure ZeroPadText(InText: text; Length: integer) OutText: Text
    var
        TmpText: text;
    begin
        if Length <= 0 then
            exit('');
        TmpText := PADSTR('0', Length, '0') + InText;
        OutText := COPYSTR(TmpText, STRLEN(TmpText) - Length + 1, Length);
    end;

    local procedure GetSetup()
    begin
        if not SetupRead then begin
            IntegrationSetup.Get();
            SetupRead := true;
        end;
    end;

    procedure SetSetup(NewIntegrationSetup: Record "GXL Integration Setup")
    begin
        IntegrationSetup := NewIntegrationSetup;
        SetupRead := true;
    end;

    // >> GX-202329
    local procedure GetSalesTypeFromMagentoSalesTypeMapping(inMagentoSalesType: Code[20]) outSalesType: Code[20]
    var
        MagentoSalesTypeMapping: Record "Magento Sales Type Mapping";
        SalesType: Record "LSC Sales Type";
    begin
        outSalesType := '';

        GetSetup();
        outSalesType := IntegrationSetup."Magento Sales Type";

        if inMagentoSalesType = '' then
            exit;

        MagentoSalesTypeMapping.SetRange("Magento Sales Type", inMagentoSalesType);
        if MagentoSalesTypeMapping.FindFirst() then begin
            SalesType.Get(MagentoSalesTypeMapping."Sales Type");
            outSalesType := SalesType.Code;
        end;
    end;
    // << GX-202329

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC POS Post Utility", 'OnAfterInsertTransaction', '', true, true)]
    local procedure OnAfterInsertTransaction_POSPostUtility(POSTrans: Record "LSC POS Transaction"; var Transaction: Record "LSC Transaction Header")
    begin
        Transaction."GXL Magento WebOrder Trans. ID" := POSTrans."GXL Magento WebOrder Trans. ID";
    end;
}