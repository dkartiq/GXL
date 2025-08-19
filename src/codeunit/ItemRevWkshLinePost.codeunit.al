/// <summary>
/// CR099 - Revaluation Journal Batch
/// </summary>
codeunit 50044 "GXL Item Rev.Wksh.Line-Post"
{
    TableNo = "GXL Item Reval. Wksh. Line";

    trigger OnRun()
    var
        RevalWkshLine: Record "GXL Item Reval. Wksh. Line";
    begin
        RevalWkshLine := Rec;
        GetSetups();

        PostLine(RevalWkshLine);
        Rec := RevalWkshLine;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        SetupRead: Boolean;

    local procedure PostLine(var RevalWkshLine: Record "GXL Item Reval. Wksh. Line")
    var
        RevalWkshLocLine: Record "GXL Item Reval. Wksh. Loc Line";
        ItemJnlLine: Record "Item Journal Line";
        NoInventory: Boolean;
    begin
        //ERP-320 +
        NoInventory := true;
        RevalWkshLine."Cost Update Forced" := false;
        //ERP-320 -

        if RevalWkshLine."Inventory Value Per" = RevalWkshLine."Inventory Value Per"::Item then begin
            //Per Item
            if RevalWkshLine.Quantity > 0 then begin
                ItemJnlLine.Init();
                ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::Revaluation;
                ItemJnlLine.Validate("Posting Date", RevalWkshLine."Posting Date");
                ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.");
                ItemJnlLine.Validate("Document No.", RevalWkshLine."Document No.");
                ItemJnlLine.Validate("Item No.", RevalWkshLine."Item No.");
                ItemJnlLine."Reason Code" := RevalWkshLine."Reason Code";
                ItemJnlLine."Source Code" := SourceCodeSetup."Revaluation Journal";
                ItemJnlLine.Validate("Unit Amount", 0);

                ItemJnlLine."Inventory Value Per" := ItemJnlLine."Inventory Value Per"::Item;
                ItemJnlLine.Validate(Quantity, RevalWkshLine.Quantity);
                ItemJnlLine.Validate("Inventory Value (Calculated)", RevalWkshLine."Inventory Value (Calculated)");
                ItemJnlLine.Validate("Inventory Value (Revalued)", RevalWkshLine."Inventory Value (Revalued)");

                //ERP-320 +
                if RevalWkshLine."Inventory Posting Group" <> '' then
                    ItemJnlLine."Inventory Posting Group" := RevalWkshLine."Inventory Posting Group";
                if RevalWkshLine."Gen. Product Posting Group" <> '' then
                    ItemJnlLine."Gen. Prod. Posting Group" := RevalWkshLine."Gen. Product Posting Group";
                //ERP-320 -

                ItemJnlLine."Update Standard Cost" := false;
                ItemJnlLine."Partial Revaluation" := true;
                ItemJnlLine."Applied Amount" := 0;

                ItemJnlPostSumLine(ItemJnlLine);
            end;

            //ERP-320 +
            if RevalWkshLine.Quantity <> 0 then
                NoInventory := false;
            //ERP-320 -
        end;

        if RevalWkshLine."Inventory Value Per" = RevalWkshLine."Inventory Value Per"::Location then begin
            RevalWkshLocLine.SetRange("Batch ID", RevalWkshLine."Batch ID");
            RevalWkshLocLine.SetRange("Wksh. Line No.", RevalWkshLine."Line No.");
            if RevalWkshLocLine.FindSet() then begin
                //Per SKU
                repeat
                    if RevalWkshLocLine.Quantity > 0 then begin
                        ItemJnlLine.Init();
                        ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::Revaluation;
                        ItemJnlLine.Validate("Posting Date", RevalWkshLine."Posting Date");
                        ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.");
                        ItemJnlLine.Validate("Document No.", RevalWkshLine."Document No.");
                        ItemJnlLine.Validate("Item No.", RevalWkshLine."Item No.");
                        ItemJnlLine.Validate("Location Code", RevalWkshLocLine."Location Code");
                        ItemJnlLine."Reason Code" := RevalWkshLine."Reason Code";
                        ItemJnlLine."Source Code" := SourceCodeSetup."Revaluation Journal";
                        ItemJnlLine.Validate("Unit Amount", 0);

                        ItemJnlLine."Inventory Value Per" := ItemJnlLine."Inventory Value Per"::Location;
                        ItemJnlLine.Validate(Quantity, RevalWkshLocLine.Quantity);
                        ItemJnlLine.Validate("Inventory Value (Calculated)", RevalWkshLocLine."Inventory Value (Calculated)");
                        ItemJnlLine.Validate("Inventory Value (Revalued)", RevalWkshLocLine."Inventory Value (Revalued)");

                        //ERP-320 +
                        if RevalWkshLine."Inventory Posting Group" <> '' then
                            ItemJnlLine."Inventory Posting Group" := RevalWkshLine."Inventory Posting Group";
                        if RevalWkshLine."Gen. Product Posting Group" <> '' then
                            ItemJnlLine."Gen. Prod. Posting Group" := RevalWkshLine."Gen. Product Posting Group";
                        //ERP-320 -

                        ItemJnlLine."Update Standard Cost" := false;
                        ItemJnlLine."Partial Revaluation" := true;
                        ItemJnlLine."Applied Amount" := 0;

                        ItemJnlPostSumLine(ItemJnlLine);
                    end;

                    //ERP-320 +
                    if RevalWkshLocLine.Quantity <> 0 then
                        NoInventory := false;
                //ERP-320 -

                until RevalWkshLocLine.Next() = 0;
            end;

        end;

        //ERP-320 +
        if NoInventory then
            ForceUpdateItemCost(RevalWkshLine);
        //ERP-320 -
    end;

    local procedure ItemJnlPostSumLine(ItemJnlLine4: Record "Item Journal Line")
    var
        LocalItemJnlLine: Record "Item Journal Line";
        Item: Record Item;
        ItemLedgEntry4: Record "Item Ledger Entry";
        ItemLedgEntry5: Record "Item Ledger Entry";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        Remainder: Decimal;
        RemAmountToDistribute: Decimal;
        RemQuantity: Decimal;
        DistributeCosts: Boolean;
        IncludeExpectedCost: Boolean;
        PostingDate: Date;
        IsLastEntry: Boolean;
        ErrMsg1: Label 'Item %1 has new postings made in the period you want to revalue.\';
        ErrMsg2: Label 'You must calculate the inventory value again.';
    begin
        LocalItemJnlLine := ItemJnlLine4;

        DistributeCosts := true;
        RemAmountToDistribute := LocalItemJnlLine.Amount;
        RemQuantity := LocalItemJnlLine.Quantity;
        if LocalItemJnlLine.Amount <> 0 then begin
            Item.Get(ItemJnlLine4."Item No.");
            IncludeExpectedCost := (Item."Costing Method" = Item."Costing Method"::Standard) and
              (ItemJnlLine4."Inventory Value Per" <> ItemJnlLine4."Inventory Value Per"::" ");

            ItemLedgEntry4.Reset;
            ItemLedgEntry4.SetCurrentKey("Item No.", Positive, "Location Code", "Variant Code");
            ItemLedgEntry4.SetRange("Item No.", LocalItemJnlLine."Item No.");
            ItemLedgEntry4.SetRange(Positive, true);
            PostingDate := LocalItemJnlLine."Posting Date";

            if (ItemJnlLine4."Location Code" <> '') or
               (ItemJnlLine4."Inventory Value Per" in
                [LocalItemJnlLine."Inventory Value Per"::Location,
                 ItemJnlLine4."Inventory Value Per"::"Location and Variant"])
            then
                ItemLedgEntry4.SetRange("Location Code", LocalItemJnlLine."Location Code");
            if (LocalItemJnlLine."Variant Code" <> '') or
               (ItemJnlLine4."Inventory Value Per" in
                [LocalItemJnlLine."Inventory Value Per"::Variant,
                 ItemJnlLine4."Inventory Value Per"::"Location and Variant"])
            then
                ItemLedgEntry4.SetRange("Variant Code", LocalItemJnlLine."Variant Code");
            if ItemLedgEntry4.FindSet() then
                repeat
                    if IncludeEntryInCalc(ItemLedgEntry4, PostingDate, IncludeExpectedCost) then begin
                        ItemLedgEntry5 := ItemLedgEntry4;

                        ItemJnlLine4."Entry Type" := ItemLedgEntry4."Entry Type";
                        ItemJnlLine4.Quantity :=
                          ItemLedgEntry4.CalculateRemQuantity(ItemLedgEntry4."Entry No.", LocalItemJnlLine."Posting Date");

                        ItemJnlLine4."Quantity (Base)" := ItemJnlLine4.Quantity;
                        ItemJnlLine4."Invoiced Quantity" := ItemJnlLine4.Quantity;
                        ItemJnlLine4."Invoiced Qty. (Base)" := ItemJnlLine4.Quantity;
                        ItemJnlLine4."Location Code" := ItemLedgEntry4."Location Code";
                        ItemJnlLine4."Variant Code" := ItemLedgEntry4."Variant Code";
                        ItemJnlLine4."Applies-to Entry" := ItemLedgEntry4."Entry No.";
                        ItemJnlLine4."Source No." := ItemLedgEntry4."Source No.";
                        ItemJnlLine4."Order Type" := ItemLedgEntry4."Order Type";
                        ItemJnlLine4."Order No." := ItemLedgEntry4."Order No.";
                        ItemJnlLine4."Order Line No." := ItemLedgEntry4."Order Line No.";

                        if ItemJnlLine4.Quantity <> 0 then begin
                            ItemJnlLine4.Amount :=
                              LocalItemJnlLine."Inventory Value (Revalued)" * ItemJnlLine4.Quantity /
                              LocalItemJnlLine.Quantity -
                              Round(
                                ItemLedgEntry4.CalculateRemInventoryValue(
                                  ItemLedgEntry4."Entry No.", ItemLedgEntry4.Quantity, ItemJnlLine4.Quantity,
                                  IncludeExpectedCost and not ItemLedgEntry4."Completely Invoiced", PostingDate),
                                GLSetup."Amount Rounding Precision") + Remainder;

                            RemQuantity := RemQuantity - ItemJnlLine4.Quantity;

                            if RemQuantity = 0 then begin
                                if ItemLedgEntry4.Next > 0 then
                                    repeat
                                        if IncludeEntryInCalc(ItemLedgEntry4, PostingDate, IncludeExpectedCost) then begin
                                            RemQuantity := ItemLedgEntry4.CalculateRemQuantity(ItemLedgEntry4."Entry No.", LocalItemJnlLine."Posting Date");
                                            if RemQuantity > 0 then
                                                Error(ErrMsg1 + ErrMsg2, ItemJnlLine4."Item No.");
                                        end;
                                    until ItemLedgEntry4.Next = 0;

                                ItemJnlLine4.Amount := RemAmountToDistribute;
                                DistributeCosts := false;
                            end else begin
                                repeat
                                    IsLastEntry := ItemLedgEntry4.Next = 0;
                                until IncludeEntryInCalc(ItemLedgEntry4, PostingDate, IncludeExpectedCost) or IsLastEntry;
                                if IsLastEntry or (RemQuantity < 0) then
                                    Error(ErrMsg1 + ErrMsg2, ItemJnlLine4."Item No.");
                                Remainder := ItemJnlLine4.Amount - Round(ItemJnlLine4.Amount, GLSetup."Amount Rounding Precision");
                                ItemJnlLine4.Amount := Round(ItemJnlLine4.Amount, GLSetup."Amount Rounding Precision");
                                RemAmountToDistribute := RemAmountToDistribute - ItemJnlLine4.Amount;
                            end;
                            ItemJnlLine4."Unit Cost" := ItemJnlLine4.Amount / ItemJnlLine4.Quantity;

                            if ItemJnlLine4.Amount <> 0 then begin
                                if IncludeExpectedCost and not ItemLedgEntry5."Completely Invoiced" then begin
                                    ItemJnlLine4."Applied Amount" := Round(
                                        ItemJnlLine4.Amount * (ItemLedgEntry5.Quantity - ItemLedgEntry5."Invoiced Quantity") /
                                        ItemLedgEntry5.Quantity,
                                        GLSetup."Amount Rounding Precision");
                                end else
                                    ItemJnlLine4."Applied Amount" := 0;
                                ItemJnlPostLine.RunWithCheck(ItemJnlLine4);
                            end;
                        end else begin
                            repeat
                                IsLastEntry := ItemLedgEntry4.Next = 0;
                            until IncludeEntryInCalc(ItemLedgEntry4, PostingDate, IncludeExpectedCost) or IsLastEntry;
                            if IsLastEntry then
                                Error(ErrMsg1 + ErrMsg2, ItemJnlLine4."Item No.");
                        end;
                    end else
                        DistributeCosts := ItemLedgEntry4.Next <> 0;
                until not DistributeCosts;
        end;
    end;

    local procedure IncludeEntryInCalc(var ItemLedgEntry: Record "Item Ledger Entry"; PostingDate: Date; IncludeExpectedCost: Boolean): Boolean
    begin
        if IncludeExpectedCost then
            exit(ItemLedgEntry."Posting Date" in [0D .. PostingDate]);
        exit(ItemLedgEntry."Completely Invoiced" and (ItemLedgEntry."Last Invoice Date" in [0D .. PostingDate]));
    end;

    local procedure GetSetups()
    begin
        if not SetupRead then begin
            GLSetup.Get();
            SourceCodeSetup.Get();
            SetupRead := true;
        end;
    end;

    procedure SetSetups(NewGLSetup: Record "General Ledger Setup"; NewSourceCodeSetup: Record "Source Code Setup")
    begin
        GLSetup := NewGLSetup;
        SourceCodeSetup := NewSourceCodeSetup;
        SetupRead := true;
    end;

    //ERP-320 +
    local procedure ForceUpdateItemCost(var RevalWkshLine: Record "GXL Item Reval. Wksh. Line")
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
    begin
        if RevalWkshLine."Item No." = '' then
            exit;

        if not Item.Get(RevalWkshLine."Item No.") then
            Error('Item does not exist');

        if not Item."Cost is Adjusted" then
            Error('Item is not cost adjusted');

        Item.CalcFields(Inventory, "Net Invoiced Qty.");
        if (Item.Inventory <> 0) or (Item."Net Invoiced Qty." <> 0) then
            Error('Stock on hand on item is not zero, force update cost is not possible');

        SKU.SetRange("Item No.", Item."No.");
        SKU.SetAutoCalcFields(Inventory);
        SKU.SetFilter(Inventory, '<>0');
        if not SKU.IsEmpty() then begin
            SKU.FindFirst();
            Error('Stock on hand in SKU %1 is not zero, force update cost is not possible', SKU."Location Code");
        end;

        Item."Unit Cost" := RevalWkshLine."Unit Cost (Revalued)";
        Item."Last Direct Cost" := RevalWkshLine."Unit Cost (Revalued)";
        Item.Validate("Price/Profit Calculation");
        Item.Modify(true);

        SKU.Reset();
        SKU.SetRange("Item No.", Item."No.");
        if SKU.FindSet() then
            repeat
                SKU."Unit Cost" := RevalWkshLine."Unit Cost (Revalued)";
                SKU."Last Direct Cost" := RevalWkshLine."Unit Cost (Revalued)";
                SKU.Modify(true);
            until SKU.Next() = 0;

        RevalWkshLine."Cost Update Forced" := true;
    end;

    //ERP-320 -
}