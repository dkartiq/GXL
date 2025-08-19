/// <summary>
/// CR099 - Revaluation Journal Batch
/// </summary>
report 50041 "GXL Calc. Wksh. Invt. Value"
{
    Caption = 'Calculate Worksheet Item Inventory Value';
    ProcessingOnly = true;

    dataset
    {
        dataitem(GXLItemRevalWkshLine; "GXL Item Reval. Wksh. Line")
        {
            DataItemTableView = SORTING("Batch ID", "Line No.");

            trigger OnAfterGetRecord()
            var
                Item: Record Item;
                Loc: Record Location;
                RevalWkshLocLine: Record "GXL Item Reval. Wksh. Loc Line";
                AppliedAmount: Decimal;
                ContinueCalc: Boolean;
                NewErrorMsg: Boolean;
                LocLineNo: Integer;
                TotalCost: Decimal;
                TotalQty: Decimal;
            begin
                if (Status <> Status::Posted) then begin
                    GXLItemRevalWkshLine.DeleteWkshLocLines();

                    Quantity := 0;
                    Amount := 0;
                    "Inventory Value (Revalued)" := 0;
                    "Inventory Value (Calculated)" := 0;
                    "Unit Cost (Calculated)" := 0;

                    if not CalledOnAfterImport then begin
                        if ChangePostingDate then
                            "Posting Date" := PostingDate;
                        if ChangeDocNo then
                            "Document No." := DocNo;
                        if ChangeReasonCode then
                            "Reason Code" := ReasonCode;
                    end;
                    PostingDate := "Posting Date";

                    ClearLastError();
                    ContinueCalc := CheckItemRevaluationConditions("Item No.", Item);

                    if not ContinueCalc then begin
                        SetNewStatus(Status::"Value Calc. Error", GetLastErrorText());
                    end else begin
                        ValJnlBuffer.Reset;
                        ValJnlBuffer.DeleteAll;
                        IncludeExpectedCost := (Item."Costing Method" = Item."Costing Method"::Standard);

                        ItemLedgEntry.SetRange("Item No.", Item."No.");
                        ItemLedgEntry.SetRange(Positive, true);
                        if ItemLedgEntry.FindSet() then begin
                            repeat
                                if IncludeEntryInCalc(ItemLedgEntry, PostingDate, IncludeExpectedCost) then begin
                                    RemQty := ItemLedgEntry.CalculateRemQuantity(ItemLedgEntry."Entry No.", PostingDate);
                                    InsertValJnlBuffer(
                                      ItemLedgEntry."Item No.", ItemLedgEntry."Variant Code",
                                      ItemLedgEntry."Location Code", RemQty,
                                      ItemLedgEntry.CalculateRemInventoryValue(
                                        ItemLedgEntry."Entry No.", ItemLedgEntry.Quantity, RemQty,
                                        IncludeExpectedCost and not ItemLedgEntry."Completely Invoiced", PostingDate));
                                end;
                            until ItemLedgEntry.Next = 0;

                            ValJnlBuffer.Reset;
                            if ByLocation then begin
                                LocLineNo := 0;
                                TotalQty := 0;
                                TotalCost := 0;
                                Clear(ValJnlBuffer);
                                ValJnlBuffer.SetCurrentKey("Item No.", "Location Code", "Variant Code");
                                ValJnlBuffer.SetRange("Item No.", Item."No.");
                                if Loc.FindSet() then
                                    repeat
                                        ValJnlBuffer.SetRange("Location Code", Loc.Code);
                                        ValJnlBuffer.CalcSums(Quantity, "Inventory Value (Calculated)");
                                        if ValJnlBuffer.Quantity <> 0 then begin
                                            AppliedAmount := 0;
                                            if Item."Costing Method" = Item."Costing Method"::Average then
                                                CalcAverageUnitCost(Item, ValJnlBuffer.Quantity, ValJnlBuffer."Inventory Value (Calculated)", AppliedAmount);

                                            LocLineNo += 10;
                                            RevalWkshLocLine.Init();
                                            RevalWkshLocLine."Batch ID" := "Batch ID";
                                            RevalWkshLocLine."Wksh. Line No." := "Line No.";
                                            RevalWkshLocLine."Line No." := LocLineNo;
                                            RevalWkshLocLine."Item No." := "Item No.";
                                            RevalWkshLocLine."Unit of Measure Code" := "Unit of Measure Code";
                                            RevalWkshLocLine."Location Code" := Loc.Code;
                                            RevalWkshLocLine."Unit Cost (Revalued)" := "Unit Cost (Revalued)";
                                            RevalWkshLocLine.Validate(Quantity, ValJnlBuffer.Quantity);
                                            RevalWkshLocLine.Validate("Inventory Value (Calculated)", Round(ValJnlBuffer."Inventory Value (Calculated)", GLSetup."Amount Rounding Precision"));
                                            RevalWkshLocLine.Validate("Unit Cost (Revalued)");
                                            RevalWkshLocLine.Insert();

                                            TotalQty += RevalWkshLocLine.Quantity;
                                            TotalCost += RevalWkshLocLine."Inventory Value (Calculated)";
                                        end;
                                    until Loc.Next() = 0;

                                if TotalQty <> 0 then begin
                                    Validate(Quantity, TotalQty);
                                    Validate("Inventory Value (Calculated)", TotalCost);
                                    Validate("Unit Cost (Revalued)");
                                    "Inventory Value Per" := "Inventory Value Per"::Location;
                                end;

                            end else begin
                                Clear(ValJnlBuffer);
                                ValJnlBuffer.SetCurrentKey("Item No.");
                                ValJnlBuffer.SetRange("Item No.", Item."No.");

                                ValJnlBuffer.CalcSums(Quantity, "Inventory Value (Calculated)");
                                if ValJnlBuffer.Quantity <> 0 then begin
                                    AppliedAmount := 0;
                                    if Item."Costing Method" = Item."Costing Method"::Average then
                                        CalcAverageUnitCost(Item, ValJnlBuffer.Quantity, ValJnlBuffer."Inventory Value (Calculated)", AppliedAmount);

                                    Validate(Quantity, ValJnlBuffer.Quantity);
                                    Validate("Inventory Value (Calculated)", Round(ValJnlBuffer."Inventory Value (Calculated)", GLSetup."Amount Rounding Precision"));
                                    Validate("Unit Cost (Revalued)");
                                    "Inventory Value Per" := "Inventory Value Per"::Item;
                                end;
                            end;
                        end;

                        //ERP-320 +
                        // if (Quantity = 0) or (Amount = 0) then begin
                        //     SetNewStatus(Status::"Value Calc. Error", 'Nothing to revalue.');
                        // end else begin
                        //     SetNewStatus(Status::"Value Calculated", '');
                        // end;
                        SetNewStatus(Status::"Value Calculated", '');
                        //ERP-320 -
                    end;

                    SetNewUserDateTime();
                    Modify();
                end;
            end;

            trigger OnPreDataItem()
            begin
                GXLItemRevalWkshLine.SetRange("Batch ID", WkshBatchID);
            end;
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group("Worksheet Lines")
                {
                    Caption = 'Worksheet Lines';
                    field(WkshBatchID; WkshBatchID)
                    {
                        ApplicationArea = All;
                        Caption = 'Batch ID';
                        Editable = false;
                    }

                    field(ChangePostingDate; ChangePostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'Update Valuation Date';

                        trigger OnValidate()
                        begin
                            if ChangePostingDate and (PostingDate = 0D) then
                                PostingDate := WorkDate;
                        end;
                    }

                    field(PostingDate; PostingDate)
                    {
                        ApplicationArea = All;
                        Caption = 'New Valuation Date';
                        ShowMandatory = ChangePostingDate;
                    }

                    field(ChangeDocNo; ChangeDocNo)
                    {
                        ApplicationArea = All;
                        Caption = 'Update Document No.';
                    }

                    field(DocNo; DocNo)
                    {
                        ApplicationArea = All;
                        Caption = 'New Document No.';
                        ShowMandatory = ChangeDocNo;
                    }

                    field(ChangeReasonCode; ChangeReasonCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Update Reason Code';
                    }
                    field(ReasonCode; ReasonCode)
                    {
                        ApplicationArea = All;
                        Caption = 'New Reason Code';
                        TableRelation = "Reason Code";
                    }
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        GXLItemRevalWkshBatch.Get(WkshBatchID);
        if (GXLItemRevalWkshBatch."Job Queue Status" in
             [GXLItemRevalWkshBatch."Job Queue Status"::"Scheduled for Posting", GXLItemRevalWkshBatch."Job Queue Status"::Posting])
        then
            GXLItemRevalWkshBatch.FieldError("Job Queue Status");

        if not CalledOnAfterImport then begin
            if ChangePostingDate then
                if PostingDate = 0D then
                    Error(PostingDateMissingErrMsg);
            if ChangeDocNo then
                if DocNo = '' then
                    Error(DocumentNoMissingErrMsg);
        end;

        GLSetup.Get;
        InvtSetup.Get;
        SourceCodeSetup.Get;
        SourceCodeSetup.TestField("Revaluation Journal");

        ItemLedgEntry.SetCurrentKey("Item No.", Positive, "Location Code", "Variant Code");
        if InvtSetup."Average Cost Calc. Type" = InvtSetup."Average Cost Calc. Type"::"Item & Location & Variant" then
            ByLocation := true
        else
            ByLocation := false;
    end;

    var
        DocumentNoMissingErrMsg: Label 'You must enter the new Document No.';
        PostingDateMissingErrMsg: Label 'You must enter the new Valuation Date';
        GXLItemRevalWkshBatch: Record "GXL Item Reval. Wksh. Batch";
        ValJnlBuffer: Record "Item Journal Buffer" temporary;
        ItemLedgEntry: Record "Item Ledger Entry";
        AvgCostAdjmtEntryPoint: Record "Avg. Cost Adjmt. Entry Point";
        GLSetup: Record "General Ledger Setup";
        InvtSetup: Record "Inventory Setup";
        SourceCodeSetup: Record "Source Code Setup";
        CalendarPeriod: Record Date;
        NextLineNo2: Integer;
        PostingDate: Date;
        DocNo: Code[20];
        ReasonCode: Code[10];
        AverageUnitCostLCY: Decimal;
        RemQty: Decimal;
        IncludeExpectedCost: Boolean;
        ChangePostingDate: Boolean;
        ChangeDocNo: Boolean;
        ChangeReasonCode: Boolean;
        WkshBatchID: Integer;
        CalledOnAfterImport: Boolean;
        ByLocation: Boolean;

    local procedure IncludeEntryInCalc(var ItemLedgEntry: Record "Item Ledger Entry"; PostingDate: Date; IncludeExpectedCost: Boolean): Boolean
    begin
        if IncludeExpectedCost then
            exit(ItemLedgEntry."Posting Date" in [0D .. PostingDate]);
        exit(ItemLedgEntry."Completely Invoiced" and (ItemLedgEntry."Last Invoice Date" in [0D .. PostingDate]));
    end;

    local procedure InsertValJnlBuffer(ItemNo2: Code[20]; VariantCode2: Code[10]; LocationCode2: Code[10]; Quantity2: Decimal; Amount2: Decimal)
    begin
        ValJnlBuffer.Reset;
        ValJnlBuffer.SetCurrentKey("Item No.", "Location Code", "Variant Code");
        ValJnlBuffer.SetRange("Item No.", ItemNo2);
        ValJnlBuffer.SetRange("Location Code", LocationCode2);
        ValJnlBuffer.SetRange("Variant Code", VariantCode2);
        if ValJnlBuffer.FindFirst then begin
            ValJnlBuffer.Quantity := ValJnlBuffer.Quantity + Quantity2;
            ValJnlBuffer."Inventory Value (Calculated)" :=
              ValJnlBuffer."Inventory Value (Calculated)" + Amount2;
            ValJnlBuffer.Modify;
        end else
            if Quantity2 <> 0 then begin
                NextLineNo2 := NextLineNo2 + 10000;
                ValJnlBuffer.Init;
                ValJnlBuffer."Line No." := NextLineNo2;
                ValJnlBuffer."Item No." := ItemNo2;
                ValJnlBuffer."Variant Code" := VariantCode2;
                ValJnlBuffer."Location Code" := LocationCode2;
                ValJnlBuffer.Quantity := Quantity2;
                ValJnlBuffer."Inventory Value (Calculated)" := Amount2;
                ValJnlBuffer.Insert;
            end;
    end;

    local procedure CalcAverageUnitCost(var Item: Record Item; BufferQty: Decimal; var InvtValueCalc: Decimal; var AppliedAmount: Decimal)
    var
        ValueEntry: Record "Value Entry";
        AverageQty: Decimal;
        AverageCost: Decimal;
        NotComplInvQty: Decimal;
        NotComplInvValue: Decimal;
    begin
        ValueEntry."Item No." := Item."No.";
        ValueEntry."Valuation Date" := PostingDate;
        if ValJnlBuffer.GetFilter("Location Code") <> '' then
            ValueEntry."Location Code" := ValJnlBuffer.GetRangeMin("Location Code");
        if ValJnlBuffer.GetFilter("Variant Code") <> '' then
            ValueEntry."Variant Code" := ValJnlBuffer.GetRangeMin("Variant Code");
        ValueEntry.SumCostsTillValuationDate(ValueEntry);
        AverageQty := ValueEntry."Invoiced Quantity";
        AverageCost := ValueEntry."Cost Amount (Actual)";

        CalcNotComplInvcdTransfer(Item, NotComplInvQty, NotComplInvValue);
        AverageQty -= NotComplInvQty;
        AverageCost -= NotComplInvValue;

        ValueEntry.Reset;
        ValueEntry.SetRange("Item No.", Item."No.");
        ValueEntry.SetRange("Valuation Date", 0D, PostingDate);
        ValueEntry.SetFilter("Location Code", ValJnlBuffer.GetFilter("Location Code"));
        ValueEntry.SetFilter("Variant Code", ValJnlBuffer.GetFilter("Variant Code"));
        ValueEntry.SetRange(Inventoriable, true);
        ValueEntry.SetRange("Item Charge No.", '');
        ValueEntry.SetFilter("Posting Date", '>%1', PostingDate);
        ValueEntry.SetFilter("Entry Type", '<>%1', ValueEntry."Entry Type"::Revaluation);
        ValueEntry.CalcSums("Invoiced Quantity", "Cost Amount (Actual)");
        AverageQty -= ValueEntry."Invoiced Quantity";
        AverageCost -= ValueEntry."Cost Amount (Actual)";

        if AverageQty <> 0 then begin
            AverageUnitCostLCY := AverageCost / AverageQty;
            if AverageUnitCostLCY < 0 then
                AverageUnitCostLCY := 0;
        end else
            AverageUnitCostLCY := 0;

        AppliedAmount := InvtValueCalc;
        InvtValueCalc := BufferQty * AverageUnitCostLCY;
    end;

    local procedure CalcNotComplInvcdTransfer(var Item: Record Item; var NotComplInvQty: Decimal; var NotComplInvValue: Decimal)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        RemQty: Decimal;
        RemInvValue: Decimal;
        i: Integer;
    begin
        for i := 1 to 2 do begin
            ItemLedgEntry.SetCurrentKey("Item No.", Positive, "Location Code", "Variant Code");
            ItemLedgEntry.SetRange("Item No.", Item."No.");
            ItemLedgEntry.SetRange(Positive, i = 1);
            ItemLedgEntry.SetFilter("Location Code", ValJnlBuffer.GetFilter("Location Code"));
            ItemLedgEntry.SetFilter("Variant Code", ValJnlBuffer.GetFilter("Variant Code"));
            //ERP-270 - CR104 - Performance improvement +
            ItemLedgEntry.SetRange("Completely Invoiced", false);
            //ERP-270 - CR104 - Performance improvement -
            if ItemLedgEntry.Find('-') then
                repeat
                    if (ItemLedgEntry.Quantity = ItemLedgEntry."Invoiced Quantity") and
                       not ItemLedgEntry."Completely Invoiced" and
                       (ItemLedgEntry."Last Invoice Date" in [0D .. PostingDate]) and
                       (ItemLedgEntry."Invoiced Quantity" <> 0)
                    then begin
                        RemQty := ItemLedgEntry.Quantity;
                        RemInvValue := CalcItemLedgEntryActualCostTillPostingDate(ItemLedgEntry."Entry No.", PostingDate);
                        NotComplInvQty := NotComplInvQty + RemQty;
                        NotComplInvValue := NotComplInvValue + RemInvValue;
                    end;
                until ItemLedgEntry.Next = 0;
        end;
    end;

    local procedure CalcItemLedgEntryActualCostTillPostingDate(ItemLedgEntryNo: Integer; PostingDate: Date): Decimal
    var
        ValueEntry: Record "Value Entry";
    begin
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgEntryNo);
        ValueEntry.SetFilter("Posting Date", '<=%1', PostingDate);
        ValueEntry.SetFilter("Entry Type", '<>%1', ValueEntry."Entry Type"::Rounding);
        ValueEntry.SetRange("Expected Cost", false);
        ValueEntry.CalcSums("Cost Amount (Actual)");
        exit(ValueEntry."Cost Amount (Actual)");
    end;

    [TryFunction]
    local procedure CheckItemRevaluationConditions(ItemNo: Code[20]; var Item: Record Item)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        Item.Get(ItemNo);
        Item.TestField(Type, Item.Type::Inventory);

        // Using CalculatePer::Item
        if (Item."Costing Method" = Item."Costing Method"::Average) then begin
            //Removed check as will calculate per Item or per Item and Location basing on setup
            // if (InvtSetup."Average Cost Calc. Type" <> InvtSetup."Average Cost Calc. Type"::Item) then
            //     Error(
            //       'Item %1 with Costing Method %2 cannot be revalued PerItem when Average Cost Calc. Type is %3 in Inventory Setup.',
            //       Item."No.", Item."Costing Method", InvtSetup."Average Cost Calc. Type");

            AvgCostAdjmtEntryPoint.Reset;
            AvgCostAdjmtEntryPoint.SetCurrentKey("Item No.", "Cost Is Adjusted");
            AvgCostAdjmtEntryPoint.SetFilter("Item No.", Item."No.");
            AvgCostAdjmtEntryPoint.SetRange("Cost Is Adjusted", false);
            AvgCostAdjmtEntryPoint.SetRange("Valuation Date", 0D, PostingDate);
            if not AvgCostAdjmtEntryPoint.IsEmpty then
                Error('Item %1 cannot be revalued before the Adjust Cost is run.', Item."No.");

            Clear(AvgCostAdjmtEntryPoint);
            CalendarPeriod."Period Start" := PostingDate;
            AvgCostAdjmtEntryPoint."Valuation Date" := PostingDate;
            AvgCostAdjmtEntryPoint.GetValuationPeriod(CalendarPeriod);
            if PostingDate <> CalendarPeriod."Period End" then
                Error(
                  'Item %1 cannot be revalued PerItem with posting date %2. You can only use the posting date %3 for this period.',
                  Item."No.", PostingDate, CalendarPeriod."Period End");
        end;

        ItemLedgEntry.SetCurrentKey("Item No.", Open, "Variant Code", Positive, "Location Code", "Posting Date");
        ItemLedgEntry.SetRange("Item No.", Item."No.");
        ItemLedgEntry.SetRange(Open, true);
        ItemLedgEntry.SetRange(Positive, false);
        ItemLedgEntry.SetRange("Posting Date", 0D, PostingDate);
        if not ItemLedgEntry.IsEmpty then
            Error('Item %1 cannot be revalued because there is at least one open outbound item ledger entry.', Item."No.");
    end;


    procedure InitializeRequest(NewWkshBatchID: Integer; NewCalledOnAfterImport: Boolean)
    begin
        WkshBatchID := NewWkshBatchID;
        CalledOnAfterImport := NewCalledOnAfterImport;
    end;
}

