//CR050: PS-1948 External stocktake
codeunit 50020 "GXL Ext. Stockatke-Post Line"
{
    TableNo = "GXL External Stocktake Line";

    trigger OnRun()
    var
        ErrorText: Text;
    begin
        GlobalExtStocktakeLine := Rec;
        GetSetups();
        GetGlobalDimensions();
        if CheckLines(ErrorText) then
            PostLines()
        else
            Error(ErrorText);
        Rec := GlobalExtStocktakeLine;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        GlobalExtStocktakeLine: Record "GXL External Stocktake Line";
        Item: Record Item;
        Loc: Record Location;
        DimVal1: Record "Dimension Value";
        DimVal2: Record "Dimension Value";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        GLSetupShortcutDimCode: array[8] of Code[20];
        Ok: Boolean;
        SetupRead: Boolean;


    local procedure CheckLines(var ErrorText: Text) Ok: Boolean
    var
        ExtStocktakeLine: Record "GXL External Stocktake Line";
        LegacyItemNo: Code[20];
        AtLeastOnePassed: Boolean;
    begin
        Ok := true;
        AtLeastOnePassed := false;
        ErrorText := '';
        if GlobalExtStocktakeLine."Item No." = '' then begin
            ExtStocktakeLine.SetCurrentKey("Batch ID", "Line No.");
            ExtStocktakeLine.SetRange("Line No.", GlobalExtStocktakeLine."Line No.");
        end else begin
            ExtStocktakeLine.SetCurrentKey("Item No.");
            ExtStocktakeLine.SetRange("Item No.", GlobalExtStocktakeLine."Item No.");
        end;
        ExtStocktakeLine.SetRange("Batch ID", GlobalExtStocktakeLine."Batch ID");
        ExtStocktakeLine.SetRange("Process Status", ExtStocktakeLine."Process Status"::Imported);
        if ExtStocktakeLine.FindSet() then
            repeat
                if not CheckLine(ExtStocktakeLine) then begin
                    ExtStocktakeLine."Process Status" := ExtStocktakeLine."Process Status"::"Posting Error";
                    ExtStocktakeLine."Processed Date Time" := CurrentDateTime();
                    ExtStocktakeLine."Processed by User" := UserId();
                    ExtStocktakeLine.Modify();
                    LegacyItemNo := ExtStocktakeLine."Legacy Item No.";
                    Ok := false;
                    ErrorText := ErrorText + '\' + ExtStocktakeLine."Error Message";
                end else
                    AtLeastOnePassed := true;
            until ExtStocktakeLine.Next() = 0;

        if (not Ok) and AtLeastOnePassed then begin
            if ExtStocktakeLine.FindSet() then
                repeat
                    ExtStocktakeLine."Error Message" := 'Errors occured in Legacy Item No. ' + LegacyItemNo;
                    ExtStocktakeLine."Process Status" := ExtStocktakeLine."Process Status"::"Posting Error";
                    ExtStocktakeLine."Processed Date Time" := CurrentDateTime();
                    ExtStocktakeLine."Processed by User" := UserId();
                    ExtStocktakeLine.Modify();
                until ExtStocktakeLine.Next() = 0;
        end;
    end;

    local procedure CheckLine(var ExtStocktakeLine: Record "GXL External Stocktake Line"): Boolean
    var
        ExtStocktakeLine2: Record "GXL External Stocktake Line";
        ItemUOM: Record "Item Unit of Measure";
        NeedToCalcInventory: Boolean;
        Sb: TextBuilder;
    begin
        Sb.Clear();
        if ExtStocktakeLine."Legacy Item No." = '' then
            Sb.AppendLine(StrSubstNo('%1 is empty', ExtStocktakeLine.FieldCaption("Legacy Item No.")))
        else begin
            if DuplicateLegacyItemFound(ExtStocktakeLine) then
                Sb.AppendLine(StrSubstNo('Duplicate Legacy Item No. %1', ExtStocktakeLine."Legacy Item No."));

            NeedToCalcInventory := false;
            if ExtStocktakeLine."Item No." = '' then
                if LegacyItemHelpers.GetItemUOM(ExtStocktakeLine."Legacy Item No.", ItemUOM) then begin
                    ExtStocktakeLine."Item No." := ItemUOM."Item No.";
                    ExtStocktakeLine."Unit of Measure Code" := ItemUOM.Code;
                    ExtStocktakeLine."Qty. per Unit of Measure" := ItemUOM."Qty. per Unit of Measure";
                    if ExtStocktakeLine."Qty. per Unit of Measure" = 0 then
                        ExtStocktakeLine."Qty. per Unit of Measure" := 1;
                    ExtStocktakeLine.Validate("Qty. (Phys. Inventory)");

                    NeedToCalcInventory := true;
                end;

            if ExtStocktakeLine."Item No." = '' then
                Sb.AppendLine(StrSubstNo('%1 is not found', ExtStocktakeLine.FieldCaption("Legacy Item No.")))
            else begin
                if ExtStocktakeLine."Item No." <> Item."No." then
                    Item.Get(ExtStocktakeLine."Item No.");
                if Item.Blocked then
                    Sb.AppendLine(StrSubstNo('%1 %2 is blocked', ExtStocktakeLine.FieldCaption("Item No."), ExtStocktakeLine."Item No."));
                if Item."Inventory Posting Group" = '' then
                    Sb.AppendLine(StrSubstNo('%1 is empty', Item.FieldCaption("Inventory Posting Group")));
                if Item."Gen. Prod. Posting Group" = '' then
                    Sb.AppendLine(StrSubstNo('%1 is empty', Item.FieldCaption("Gen. Prod. Posting Group")));

                //Same item and UOM must be unique in one batch
                FilterItemNo(ExtStocktakeLine, ExtStocktakeLine2);
                ExtStocktakeLine2.SetRange("Unit of Measure Code", ExtStocktakeLine."Unit of Measure Code");
                if not ExtStocktakeLine2.IsEmpty() then
                    Sb.AppendLine(StrSubstNo('Duplicate Item No. %1 and UOM %2', ExtStocktakeLine."Item No.", ExtStocktakeLine."Unit of Measure Code"));
            end;
            if ExtStocktakeLine."Document No." = '' then
                Sb.AppendLine(StrSubstNo('%1 is empty', ExtStocktakeLine.FieldCaption("Document No.")));
            if ExtStocktakeLine."Posting Date" = 0D then
                Sb.AppendLine(StrSubstNo('%1 is empty', ExtStocktakeLine.FieldCaption("Posting Date")));
            if ExtStocktakeLine."Location Code" = '' then
                Sb.AppendLine(StrSubstNo('%1 is empty', ExtStocktakeLine.FieldCaption("Location Code")))
            else begin
                if not Loc.Get(ExtStocktakeLine."Location Code") then
                    Sb.AppendLine(StrSubstNo('%1 is not found', ExtStocktakeLine.FieldCaption("Location Code")));
            end;

            if ExtStocktakeLine."Shortcut Dimension 1 Code" <> '' then begin
                if not DimVal1.Get(GLSetup."Global Dimension 1 Code", ExtStocktakeLine."Shortcut Dimension 1 Code") then
                    Sb.AppendLine(StrSubstNo('%1 %2 is not found', GLSetup."Global Dimension 1 Code", ExtStocktakeLine."Shortcut Dimension 1 Code"))
                else
                    if DimVal1.Blocked then
                        Sb.AppendLine(StrSubstNo('%1 %2 is blocked', GLSetup."Global Dimension 1 Code", ExtStocktakeLine."Shortcut Dimension 1 Code"));
            end;
            if ExtStocktakeLine."Shortcut Dimension 2 Code" <> '' then begin
                if not DimVal2.Get(GLSetup."Global Dimension 2 Code", ExtStocktakeLine."Shortcut Dimension 2 Code") then
                    Sb.AppendLine(StrSubstNo('%1 %2 is not found', GLSetup."Global Dimension 2 Code", ExtStocktakeLine."Shortcut Dimension 2 Code"))
                else
                    if DimVal2.Blocked then
                        Sb.AppendLine(StrSubstNo('%1 %2 is blocked', GLSetup."Global Dimension 2 Code", ExtStocktakeLine."Shortcut Dimension 2 Code"));
            end;


            if Sb.Length() > 0 then begin
                Ok := false;
                ExtStocktakeLine."Error Message" := CopyStr(sb.ToText(), 1, MaxStrLen(ExtStocktakeLine."Error Message"));
            end else begin
                Ok := true;
                if NeedToCalcInventory then
                    ExtStocktakeLine.CalculateInventory(Item, ExtStocktakeLine."Posting Date");
            end;
            exit(Ok);
        end;
    end;

    local procedure PostLines()
    var
        ExtStocktakeLine: Record "GXL External Stocktake Line";
    begin
        ExtStocktakeLine.SetCurrentKey("Item No.");
        ExtStocktakeLine.SetRange("Item No.", GlobalExtStocktakeLine."Item No.");
        ExtStocktakeLine.SetRange("Batch ID", GlobalExtStocktakeLine."Batch ID");
        ExtStocktakeLine.SetRange("Process Status", ExtStocktakeLine."Process Status"::Imported);
        ExtStocktakeLine.SetRange("Qty. per Unit of Measure", 1);
        if not ExtStocktakeLine.FindFirst() then
            ExtStocktakeLine.SetRange("Qty. per Unit of Measure");
        if ExtStocktakeLine.FindFirst() then begin
            PostLine(ExtStocktakeLine);
            ExtStocktakeLine.Modify();
        end;

    end;

    local procedure PostLine(var ExtStocktakeLine: Record "GXL External Stocktake Line")
    var
        ItemJnlLine: Record "Item Journal Line";
        ExtStocktakeLine2: Record "GXL External Stocktake Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
        UnitOfMeasureMgt: Codeunit "Unit of Measure Management";
        QtyPhysBase: Decimal;
        QtyCalculatedBase: Decimal;
    begin
        if ExtStocktakeLine."Process Status" = ExtStocktakeLine."Process Status"::Posted then
            exit;

        //If there is already same item has been posted then calculated inventory to be considered as 0
        FilterItemNo(ExtStocktakeLine, ExtStocktakeLine2);
        ExtStocktakeLine2.SetRange("Process Status", ExtStocktakeLine2."Process Status"::Posted);
        if not ExtStocktakeLine2.IsEmpty() then
            QtyCalculatedBase := 0
        else begin
            ExtStocktakeLine2.SetRange("Process Status", ExtStocktakeLine2."Process Status"::Imported);
            if ExtStocktakeLine2.FindSet() then
                repeat
                    QtyPhysBase += ExtStocktakeLine2."Qty. Phys. Inventory (Base)";
                until ExtStocktakeLine2.Next() = 0;
            QtyCalculatedBase := ExtStocktakeLine."Qty. Calculated (Base)";
        end;
        QtyPhysBase += ExtStocktakeLine."Qty. Phys. Inventory (Base)";

        ItemJnlLine.Init();
        ItemJnlLine.Validate("Item No.", ExtStocktakeLine."Item No.");
        ItemJnlLine."Posting Date" := ExtStocktakeLine."Posting Date";
        if ExtStocktakeLine."Document Date" <> 0D then
            ItemJnlLine."Document Date" := ExtStocktakeLine."Document Date"
        else
            ItemJnlLine."Document Date" := ExtStocktakeLine."Posting Date";
        ItemJnlLine.Validate("Entry Type", ExtStocktakeLine."Entry Type");
        ItemJnlLine."Document No." := ExtStocktakeLine."Document No.";
        if ExtStocktakeLine.Description <> '' then
            ItemJnlLine.Description := ExtStocktakeLine.Description;
        ItemJnlLine."Location Code" := ExtStocktakeLine."Location Code";
        if ExtStocktakeLine."Gen. Prod. Posting Group" <> '' then
            ItemJnlLine."Gen. Prod. Posting Group" := ExtStocktakeLine."Gen. Prod. Posting Group";

        ItemJnlLine."Qty. (Phys. Inventory)" := QtyPhysBase;
        ItemJnlLine."Phys. Inventory" := true;
        ItemJnlLine.Validate("Qty. (Calculated)", QtyCalculatedBase);

        ItemJnlLine."Reason Code" := ExtStocktakeLine."Reason Code";
        ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::"Direct Cost";
        ItemJnlLine."Source Code" := SourceCodeSetup."Item Journal";
        ItemJnlLine."Shortcut Dimension 1 Code" := ExtStocktakeLine."Shortcut Dimension 1 Code";
        ItemJnlLine."Shortcut Dimension 2 Code" := ExtStocktakeLine."Shortcut Dimension 2 Code";
        ItemJnlLine."Dimension Set ID" := GetDimensionSetId(ExtStocktakeLine);
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);

        ExtStocktakeLine."Quantity (Base)" := ItemJnlLine."Quantity (Base)";
        ExtStocktakeLine.Quantity := UnitOfMeasureMgt.CalcQtyFromBase(ItemJnlLine."Quantity (Base)", ExtStocktakeLine."Qty. per Unit of Measure");
        ExtStocktakeLine."Entry Type" := ItemJnlLine."Entry Type";
    end;

    local procedure GetDimensionSetId(CurrExtStocktakeLine: Record "GXL External Stocktake Line"): Integer
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        ShortcutDimCode: array[8] of Code[20];
        i: Integer;
        FoundDim: Boolean;
    begin
        ShortcutDimCode[1] := CurrExtStocktakeLine."Shortcut Dimension 1 Code";
        ShortcutDimCode[2] := CurrExtStocktakeLine."Shortcut Dimension 2 Code";
        ShortcutDimCode[3] := CurrExtStocktakeLine."Shortcut Dimension 3 Code";
        ShortcutDimCode[4] := CurrExtStocktakeLine."Shortcut Dimension 4 Code";
        ShortcutDimCode[5] := CurrExtStocktakeLine."Shortcut Dimension 5 Code";
        ShortcutDimCode[6] := CurrExtStocktakeLine."Shortcut Dimension 6 Code";
        ShortcutDimCode[7] := CurrExtStocktakeLine."Shortcut Dimension 7 Code";
        ShortcutDimCode[8] := CurrExtStocktakeLine."Shortcut Dimension 8 Code";

        FoundDim := false;
        for i := 1 to 8 do
            if ShortcutDimCode[i] <> '' then begin
                TempDimSetEntry.Init();
                TempDimSetEntry."Dimension Set ID" := 0;
                TempDimSetEntry."Dimension Code" := GLSetupShortcutDimCode[i];
                TempDimSetEntry.Validate("Dimension Value Code", ShortcutDimCode[i]);
                TempDimSetEntry.Insert();
                FoundDim := true;
            end;

        if FoundDim then
            exit(DimMgt.GetDimensionSetID(TempDimSetEntry))
        else
            exit(0);
    end;

    local procedure GetGlobalDimensions()
    begin
        GLSetupShortcutDimCode[1] := GLSetup."Shortcut Dimension 1 Code";
        GLSetupShortcutDimCode[2] := GLSetup."Shortcut Dimension 2 Code";
        GLSetupShortcutDimCode[3] := GLSetup."Shortcut Dimension 3 Code";
        GLSetupShortcutDimCode[4] := GLSetup."Shortcut Dimension 4 Code";
        GLSetupShortcutDimCode[5] := GLSetup."Shortcut Dimension 5 Code";
        GLSetupShortcutDimCode[6] := GLSetup."Shortcut Dimension 6 Code";
        GLSetupShortcutDimCode[7] := GLSetup."Shortcut Dimension 7 Code";
        GLSetupShortcutDimCode[8] := GLSetup."Shortcut Dimension 8 Code";
    end;

    local procedure FilterItemNo(CurrExtStocktakeLine: Record "GXL External Stocktake Line"; var ExtStocktakeLine2: Record "GXL External Stocktake Line")
    begin
        ExtStocktakeLine2.Reset();
        ExtStocktakeLine2.SetRange("Batch ID", CurrExtStocktakeLine."Batch ID");
        ExtStocktakeLine2.SetRange("Item No.", CurrExtStocktakeLine."Item No.");
        ExtStocktakeLine2.SetFilter("Line No.", '<>%1', CurrExtStocktakeLine."Line No.");
    end;

    local procedure DuplicateLegacyItemFound(CurrExtStocktakeLine: Record "GXL External Stocktake Line"): Boolean
    var
        ExtStocktakeLine2: Record "GXL External Stocktake Line";
    begin
        ExtStocktakeLine2.Reset();
        ExtStocktakeLine2.SetRange("Batch ID", CurrExtStocktakeLine."Batch ID");
        ExtStocktakeLine2.SetRange("Legacy Item No.", CurrExtStocktakeLine."Legacy Item No.");
        ExtStocktakeLine2.SetFilter("Line No.", '<>%1', CurrExtStocktakeLine."Line No.");
        exit(not ExtStocktakeLine2.IsEmpty());
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

}