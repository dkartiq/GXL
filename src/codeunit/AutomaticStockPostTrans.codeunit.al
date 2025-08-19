codeunit 50403 "GXL Automatic Stock Post Trans"
{
    /*Change Log
        PS-2313 2020-10-06 LP: Code review, include error log
    */

    TableNo = "LSC Transaction Header";

    trigger OnRun()
    begin
        TransactionHeader := Rec;
        RunCode();
    end;

    var
        TransactionHeader: Record "LSC Transaction Header";
        IntegrationSetup: Record "GXL Integration Setup";
        RetailSetup: Record "LSC Retail Setup";
        Store: Record "LSC Store";
        Staff: Record "LSC Staff";
        SalesType: Record "LSC Sales Type";


    local procedure RunCode()
    var
        TransactionStatus: Record "LSC Transaction Status";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        PosPostUtitlity: Codeunit "LSC POS Order Connection";
        SkipRecord: Boolean;
        NonSaleable: Boolean;
    begin

        SkipRecord := false;
        NonSaleable := false;

        if TransactionHeader."Posting Status" = TransactionHeader."Posting Status"::" " then begin
            TransSalesEntry.RESET();
            TransSalesEntry.SETCURRENTKEY("Store No.", "POS Terminal No.", "Transaction No.", "Line No.");//EBT::To optiomize
            TransSalesEntry.SETRANGE(TransSalesEntry."Store No.", TransactionHeader."Store No.");//EBT::To optiomize
            TransSalesEntry.SETRANGE(TransSalesEntry."POS Terminal No.", TransactionHeader."POS Terminal No.");//EBT::To optiomize
            TransSalesEntry.SETRANGE(TransSalesEntry."Transaction No.", TransactionHeader."Transaction No.");//EBT::To optiomize
            if TransSalesEntry.IsEmpty() then
                SkipRecord := TRUE;

            if not SkipRecord then begin
                TransactionStatus.RESET();
                TransactionStatus.SETCURRENTKEY("Store No.", "POS Terminal No.", "Transaction No.");
                TransactionStatus.SETRANGE(TransactionStatus."Store No.", TransactionHeader."Store No.");
                TransactionStatus.SETRANGE(TransactionStatus."POS Terminal No.", TransactionHeader."POS Terminal No.");
                TransactionStatus.SETRANGE(TransactionStatus."Transaction No.", TransactionHeader."Transaction No.");
                if not TransactionStatus.FindFirst() then
                    TransactionStatus.Status := TransactionStatus.Status::" ";

                if TransactionStatus.Status = TransactionStatus.Status::" " then begin
                    NonSaleable := CheckReturnCodeNonSaleable(TransactionHeader."Store No.",TransactionHeader."POS Terminal No.",TransactionHeader."Transaction No.");
                    //if not NonSaleable then begin //<< PS-1685: Removed, still post as per standard LS
                    CLEAR(PosPostUtitlity);
                    TransactionHeader."GXL Auto Stock Posting" := 'GXL_ASP'; //for logic inside PostItemInventory
                    PosPostUtitlity.PostItemInventory(TransactionHeader);
                    TransactionHeader."GXL Auto Stock Posting" := '';
                    //end;

                    //>> PS-1685
                    //Post negative adjustment for return/exchange non-saleable products
                    if NonSaleable then
                        PostInventoryAdjustment(TransactionHeader);
                    //<< PS-1685
                end;
            end;
        end;

    end;

    //CR007
    procedure CheckReturnCodeNonSaleable(StoreNo: Code[10]; PosTerminalNo: Code[10]; TransactionNo: Integer): Boolean
    var
        TransInfocodeEntry: Record "LSC Trans. Infocode Entry";
        InformationSubcode: Record "LSC Information Subcode";
    begin
        TransInfocodeEntry.RESET();
        TransInfocodeEntry.SETCURRENTKEY("Store No.", "POS Terminal No.", "Transaction No.", "Infocode");
        TransInfocodeEntry.SETRANGE(TransInfocodeEntry."Store No.", StoreNo);
        TransInfocodeEntry.SETRANGE(TransInfocodeEntry."POS Terminal No.", PosTerminalNo);
        TransInfocodeEntry.SETRANGE(TransInfocodeEntry."Transaction No.", TransactionNo);
        TransInfocodeEntry.SETRANGE(TransInfocodeEntry."Infocode", 'RETURN');

        if not TransInfocodeEntry.FINDFIRST() then
            exit(false)
        else begin
            InformationSubcode.RESET();
            InformationSubcode.SETCURRENTKEY("Code", Subcode);
            InformationSubcode.SETRANGE(InformationSubcode."Code", TransInfocodeEntry."Infocode");
            InformationSubcode.SETRANGE(InformationSubcode."Subcode", TransInfocodeEntry."Subcode");
            if not InformationSubcode.FINDFIRST() then
                exit(false)
            else
                if InformationSubcode."GXL Saleable" then
                    exit(false)
                else
                    exit(true);
        end;
    end;

    //PS-1685
    //Post negative adjustment for non-saleable return/exchange items
    local procedure PostInventoryAdjustment(TransactionHeader: Record "LSC Transaction Header")
    var
        ItemJnlLine: Record "Item Journal Line";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        Item: Record Item;
        Cust: Record Customer;
        GenPostingSetup: Record "General Posting Setup";
        TransPostingFunctions: Codeunit "LSC Trans. Posting Functions";
        DimMgt: Codeunit DimensionManagement;
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        DocNo: Code[20];
        No: array[10] of Code[20];
        TableID: array[10] of Integer;
        i: Integer;
        DefaultDimSource: List of [Dictionary of [Integer, Code[20]]];
    begin
        TransSalesEntry.SetRange("Store No.", TransactionHeader."Store No.");
        TransSalesEntry.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        TransSalesEntry.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        TransSalesEntry.SetFilter(Quantity, '>0');
        if TransSalesEntry.FindSet() then begin
            if Store."No." <> TransactionHeader."Store No." then
                Store.Get(TransactionHeader."Store No.");
            Store.TestField("Location Code");
            if SalesType.Code <> TransactionHeader."Sales Type" then
                if not SalesType.Get(TransactionHeader."Sales Type") then
                    Clear(SalesType);
            if Staff.ID <> TransactionHeader."Staff ID" then
                if not Staff.Get(TransactionHeader."Staff ID") then
                    Clear(Staff);
            repeat
                if Item.Get(TransSalesEntry."Item No.") then begin
                    if not (Item.type = Item.type::"Non-Inventory") then begin
                        DocNo := GetDocumentNo(TransSalesEntry);
                        ItemJnlLine.Init();
                        ItemJnlLine."Item No." := TransSalesEntry."Item No.";
                        ItemJnlLine."Posting Date" := TransactionHeader.Date;
                        ItemJnlLine."Document Date" := ItemJnlLine."Posting Date";
                        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");
                        ItemJnlLine."Document No." := DocNo;
                        ItemJnlLine."External Document No." := DocNo;
                        ItemJnlLine.Description := Item.Description;
                        ItemJnlLine."Location Code" := Store."Location Code";
                        ItemJnlLine."Inventory Posting Group" := Item."Inventory Posting Group";
                        if Item."Base Unit of Measure" <> '' then begin
                            ItemJnlLine.Validate("Unit of Measure Code", Item."Base Unit of Measure");
                            ItemJnlLine.Validate(Quantity, TransSalesEntry.Quantity);
                        end else begin
                            ItemJnlLine."Unit of Measure Code" := '';
                            ItemJnlLine."Qty. per Unit of Measure" := 1;
                            ItemJnlLine.Validate("Quantity (Base)", TransSalesEntry.Quantity);
                        end;
                        ItemJnlLine."Unit Amount" := Round(TransSalesEntry."Net Amount" / TransSalesEntry.Quantity, 0.00001);
                        ItemJnlLine.Amount := Round(TransSalesEntry."Net Amount");
                        ItemJnlLine."Source Code" := RetailSetup."Source Code";
                        ItemJnlLine."Gen. Prod. Posting Group" := Item."Gen. Prod. Posting Group";
                        ItemJnlLine."Gen. Bus. Posting Group" := Store."Store Gen. Bus. Post. Gr.";

                        ItemJnlLine."Salespers./Purch. Code" := Staff."Sales Person";
                        ItemJnlLine."LSC Offer No." := TransSalesEntry."Periodic Disc. Group";
                        ItemJnlLine."LSC Promotion No." := TransSalesEntry."Promotion No.";
                        ItemJnlLine."Reason Code" := IntegrationSetup."POS Return Non-Saleable Reason";
                        ItemJnlLine."GXL POS Adjustment" := true;

                        if TransactionHeader."Customer No." <> '' then
                            if Cust.Get(TransactionHeader."Customer No.") then begin
                                if GenPostingSetup.Get(Cust."Gen. Bus. Posting Group", Item."Gen. Prod. Posting Group") then
                                    ItemJnlLine."Gen. Bus. Posting Group" := Cust."Gen. Bus. Posting Group";
                                ItemJnlLine."Source Type" := ItemJnlLine."Source Type"::Customer;
                                ItemJnlLine."Source No." := TransactionHeader."Customer No.";
                            end else
                                Clear(Cust);

                        ItemJnlLine."Expiration Date" := TransSalesEntry."Expiration Date";
                        if (TransSalesEntry."Serial No." <> '') or (TransSalesEntry."Lot No." <> '') then
                            TransPostingFunctions.AddSerialNoAndLotNoTracking(ItemJnlLine, TransSalesEntry."Serial No.", TransSalesEntry."Lot No.", TransSalesEntry."Expiration Date");
                        // >> Upgrade
                        // i := 1;
                        // CLEAR(TableID);
                        // CLEAR(No);
                        // TableID[i] := DATABASE::Item;
                        // No[i] := ItemJnlLine."Item No.";
                        // i += 1;
                        // TableID[i] := DATABASE::"LSC Store";
                        // No[i] := Store."No.";
                        // IF (TransactionHeader."Customer No." <> '') and (Cust."No." <> '') THEN BEGIN
                        //     i += 1;
                        //     TableID[i] := DATABASE::Customer;
                        //     No[i] := TransactionHeader."Customer No.";
                        // END;
                        // IF Staff."Sales Person" <> '' THEN BEGIN
                        //     i += 1;
                        //     TableID[i] := DATABASE::"Salesperson/Purchaser";
                        //     No[i] := Staff."Sales Person";
                        // END;
                        // IF SalesType.Code <> '' THEN BEGIN
                        //     i += 1;
                        //     TableID[i] := DATABASE::"LSC Sales Type";
                        //     No[i] := TransactionHeader."Sales Type";
                        // END;

                        DimMgt.AddDimSource(DefaultDimSource, Database::Item, ItemJnlLine."Item No.");
                        DimMgt.AddDimSource(DefaultDimSource, Database::"LSC Store", Store."No.");
                        if (TransactionHeader."Customer No." <> '') and (Cust."No." <> '') then
                            DimMgt.AddDimSource(DefaultDimSource, DATABASE::Customer, TransactionHeader."Customer No.");
                        if Staff."Sales Person" <> '' then
                            DimMgt.AddDimSource(DefaultDimSource, DATABASE::"Salesperson/Purchaser", Staff."Sales Person");
                        if SalesType.Code <> '' then
                            DimMgt.AddDimSource(DefaultDimSource, DATABASE::"LSC Sales Type", TransactionHeader."Sales Type");
                        // << Upgrade
                        ItemJnlLine."Shortcut Dimension 1 Code" := '';
                        ItemJnlLine."Shortcut Dimension 2 Code" := '';
                        ItemJnlLine."Dimension Set ID" := DimMgt.GetDefaultDimID(
                            // >> Upgrade
                            //TableID, No, ItemJnlLine."Source Code", ItemJnlLine."Shortcut Dimension 1 Code", ItemJnlLine."Shortcut Dimension 2 Code", 0, 0);
                            DefaultDimSource, ItemJnlLine."Source Code", ItemJnlLine."Shortcut Dimension 1 Code", ItemJnlLine."Shortcut Dimension 2 Code", 0, 0);
                        // << Upgrade
                        ItemJnlPostLine.Run(ItemJnlLine);
                    end;
                end;
            until TransSalesEntry.Next() = 0;
        end;
    end;

    local procedure GetDocumentNo(TransSalesEntry: Record "LSC Trans. Sales Entry"): Code[20]
    var
        TempCode: Code[50];
        TempCode2: Code[20];
    begin
        TempCode := TransSalesEntry."Receipt No." + '-' + Format(TransSalesEntry."Line No.");
        IF STRLEN(TempCode) > 20 THEN
            TempCode2 := CopyStr(TempCode, STRLEN(TempCode) - 20 + 1, 20)
        else
            TempCode2 := TempCode;
        exit(TempCode2);
    end;

    procedure SetSetups(_IntgrationSetup: Record "GXL Integration Setup"; _RetailSetup: Record "LSC Retail Setup")
    begin
        IntegrationSetup := _IntgrationSetup;
        RetailSetup := _RetailSetup;
    end;

    procedure SetStore(_Store: Record "LSC Store"; _Staff: Record "LSC Staff"; _SalesType: Record "LSC Sales Type")
    begin
        Store := _Store;
        Staff := _Staff;
        SalesType := _SalesType;
    end;


    //PS-2313+
    procedure GetLastErrorLogEntry(): Integer
    var
        ErrorLog: Record "GXL AutoStockPosting Error Log";
    begin
        ErrorLog.Reset();
        if ErrorLog.FindLast() then
            exit(ErrorLog."Entry No.")
        else
            exit(0);
    end;

    procedure InsertErrorLog(TransactionHeader: Record "LSC Transaction Header"; ErrMsg: Text; var LogEntryNo: Integer)
    var
        ErrorLog: Record "GXL AutoStockPosting Error Log";
        ErrorLog2: Record "GXL AutoStockPosting Error Log";
    begin
        ErrorLog2.SetCurrentKey("Store No.", "POS Terminal No.", "Transaction No.");
        ErrorLog2.SetRange("Store No.", TransactionHeader."Store No.");
        ErrorLog2.SetRange("POS Terminal No.", TransactionHeader."POS Terminal No.");
        ErrorLog2.SetRange("Transaction No.", TransactionHeader."Transaction No.");
        if ErrorLog2.FindFirst() then begin
            ErrorLog2."Error Message" := CopyStr(ErrMsg, 1, MaxStrLen(ErrorLog2."Error Message"));
            ErrorLog2."Log Date Time" := CurrentDateTime();
            ErrorLog2."No. of Runs" += 1;
            ErrorLog2.Modify();
            exit;
        end;

        LogEntryNo += 1;
        ErrorLog.Init();
        ErrorLog."Entry No." := LogEntryNo;
        ErrorLog."Store No." := TransactionHeader."Store No.";
        ErrorLog."POS Terminal No." := TransactionHeader."POS Terminal No.";
        ErrorLog."Transaction No." := TransactionHeader."Transaction No.";
        ErrorLog."Error Message" := CopyStr(ErrMsg, 1, MaxStrLen(ErrorLog."Error Message"));
        ErrorLog."Log Date Time" := CurrentDateTime();
        ErrorLog."No. of Runs" := 1;
        ErrorLog.Insert();
    end;

    procedure IsLockingError(ErrorCode: Text; ErrorText: Text): Boolean
    var
        MiscUtilities: Codeunit "GXL Misc. Utilities";
    begin
        if MiscUtilities.IsLockingError(ErrorCode) then
            exit(true);
        if StrPos(ErrorText, 'table was locked by another user') <> 0 then
            exit(true);
        if StrPos(ErrorText, 'Sorry, we just updated this page. Reopen it, and try again') <> 0 then
            exit(true);
        exit(false);
    end;
    //PS-2313-

    //Subscribers
    //CR009
    [EventSubscriber(ObjectType::Codeunit, 99008904, 'GXLOnPostItemInventoryOnAfterCreateDocNo', '', false, false)]
    local procedure AfterCreateDocNo(pTransaction: Record "LSC Transaction Header"; VAR xDocNumber: Code[20]; xTransSalesEntry: Record "LSC Trans. Sales Entry")
    var
    //TempCode: Code[50];
    //TempCode2: Code[20];
    begin
        IF pTransaction."GXL Auto Stock Posting" = 'GXL_ASP' THEN BEGIN
            //>> PS-1602
            // TempCode := xTransSalesEntry."Receipt No." + '-' + FORMAT(xTransSalesEntry."Line No.");
            // IF STRLEN(TempCode) > 20 THEN
            //     TempCode2 := COPYSTR(TempCode, STRLEN(TempCode) - 20 + 1, 20);
            // xDocNumber := TempCode2;
            xDocNumber := GetDocumentNo(xTransSalesEntry);
            //<< PS-1602
        end;
    end;


    //PS-1685
    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", 'GXL_OnBeforePostTransaction', '', true, true)]
    // local procedure HandleOnBeforePostTransaction_StatementPost(TransactionHeader: Record "LSC Transaction Header"; var IsReturnNonSaleable: Boolean; var ReturnReasonCode: Code[20])
    // begin
    //     IsReturnNonSaleable := CheckReturnCodeNonSaleable(TransactionHeader);
    //     if ReturnReasonCode = '' then begin
    //         if IntegrationSetup.Get() then
    //             ReturnReasonCode := IntegrationSetup."POS Return Non-Saleable Reason";
    //     end;
    // end;

    //PS-1685
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"LSC Statement-Post", 'OnBeforeItemJnlLinePostLine', '', true, true)]
    local procedure OnBeforePostItemJnlLinePostLine_StatementPost(var ItemJournalLine: Record "Item Journal Line"; Statement: Record "LSC Statement")
    begin
        if ItemJournalLine."Entry Type" in [ItemJournalLine."Entry Type"::"Negative Adjmt.", ItemJournalLine."Entry Type"::"Positive Adjmt."] then
            ItemJournalLine."GXL POS Adjustment" := true;
    end;

}