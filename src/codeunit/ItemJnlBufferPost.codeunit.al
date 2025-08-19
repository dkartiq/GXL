codeunit 50012 "GXL Item Jnl Buffer-Post"
{
    // 001  03.04.2022  KDU  BAU LCB-6 Cascade the Reason Code field value to Item Journal Lines
    TableNo = "GXL Item Journal Buffer";

    trigger OnRun()
    begin
        ItemJnlBuffer := Rec;
        GetSetups();
        GetDimensions();
        if CheckLine() then
            PostLine()
        else
            Error(Sb.ToText());
        Rec := ItemJnlBuffer;
    end;

    var
        GLSetup: Record "General Ledger Setup";
        SourceCodeSetup: Record "Source Code Setup";
        ItemJnlBuffer: Record "GXL Item Journal Buffer";
        Item: Record Item;
        Loc: Record Location;
        DimVal1: Record "Dimension Value";
        DimVal2: Record "Dimension Value";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        GLSetupShortcutDimCode: array[8] of Code[20];
        ShortcutDimCode: array[8] of Code[20];
        Ok: Boolean;
        Sb: TextBuilder;
        SetupRead: Boolean;

    local procedure CheckLine(): Boolean
    begin
        Sb.Clear();
        if ItemJnlBuffer."Legacy Item No." = '' then
            Sb.AppendLine(StrSubstNo('%1 is empty', ItemJnlBuffer.FieldCaption("Legacy Item No.")))
        else begin
            LegacyItemHelpers.GetItemNo(ItemJnlBuffer."Legacy Item No.", ItemJnlBuffer."Item No.", ItemJnlBuffer."Unit of Measure Code");
            if ItemJnlBuffer."Item No." = '' then
                Sb.AppendLine(StrSubstNo('%1 is not found', ItemJnlBuffer.FieldCaption("Legacy Item No.")))
            else begin
                Item.Get(ItemJnlBuffer."Item No.");
                if Item.Blocked then
                    Sb.AppendLine(StrSubstNo('%1 %2 is blocked', ItemJnlBuffer.FieldCaption("Item No."), ItemJnlBuffer."Item No."));
                if Item."Inventory Posting Group" = '' then
                    Sb.AppendLine(StrSubstNo('%1 is empty', Item.FieldCaption("Inventory Posting Group")));
                if Item."Gen. Prod. Posting Group" = '' then
                    Sb.AppendLine(StrSubstNo('%1 is empty', Item.FieldCaption("Gen. Prod. Posting Group")));
            end;
        end;
        if ItemJnlBuffer."Document No." = '' then
            Sb.AppendLine(StrSubstNo('%1 is empty', ItemJnlBuffer.FieldCaption("Document No.")));
        if ItemJnlBuffer."Posting Date" = 0D then
            Sb.AppendLine(StrSubstNo('%1 is empty', ItemJnlBuffer.FieldCaption("Posting Date")));
        if ItemJnlBuffer."Location Code" = '' then
            Sb.AppendLine(StrSubstNo('%1 is empty', ItemJnlBuffer.FieldCaption("Location Code")))
        else begin
            if not Loc.Get(ItemJnlBuffer."Location Code") then
                Sb.AppendLine(StrSubstNo('%1 is not found', ItemJnlBuffer.FieldCaption("Location Code")));
        end;

        if ItemJnlBuffer."Shortcut Dimension 1 Code" <> '' then begin
            if not DimVal1.Get(GLSetup."Global Dimension 1 Code", ItemJnlBuffer."Shortcut Dimension 1 Code") then
                Sb.AppendLine(StrSubstNo('%1 %2 is not found', GLSetup."Global Dimension 1 Code", ItemJnlBuffer."Shortcut Dimension 1 Code"))
            else
                if DimVal1.Blocked then
                    Sb.AppendLine(StrSubstNo('%1 %2 is blocked', GLSetup."Global Dimension 1 Code", ItemJnlBuffer."Shortcut Dimension 1 Code"));
        end;
        if ItemJnlBuffer."Shortcut Dimension 2 Code" <> '' then begin
            if not DimVal2.Get(GLSetup."Global Dimension 2 Code", ItemJnlBuffer."Shortcut Dimension 2 Code") then
                Sb.AppendLine(StrSubstNo('%1 %2 is not found', GLSetup."Global Dimension 2 Code", ItemJnlBuffer."Shortcut Dimension 2 Code"))
            else
                if DimVal2.Blocked then
                    Sb.AppendLine(StrSubstNo('%1 %2 is blocked', GLSetup."Global Dimension 2 Code", ItemJnlBuffer."Shortcut Dimension 2 Code"));
        end;


        if Sb.Length() > 0 then
            Ok := false
        else
            Ok := true;
        exit(Ok);
    end;

    local procedure PostLine()
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        ItemJnlLine.Init();
        ItemJnlLine.Validate("Item No.", ItemJnlBuffer."Item No.");
        ItemJnlLine."Posting Date" := ItemJnlBuffer."Posting Date";
        if ItemJnlBuffer."Document Date" <> 0D then
            ItemJnlLine."Document Date" := ItemJnlBuffer."Document Date"
        else
            ItemJnlLine."Document Date" := ItemJnlBuffer."Posting Date";
        ItemJnlLine.Validate("Entry Type", ItemJnlBuffer."Entry Type");
        ItemJnlLine."Document No." := ItemJnlBuffer."Document No.";
        if ItemJnlBuffer.Description <> '' then
            ItemJnlLine.Description := ItemJnlBuffer.Description;
        ItemJnlLine."Location Code" := ItemJnlBuffer."Location Code";
        if ItemJnlBuffer."Gen. Prod. Posting Group" <> '' then
            ItemJnlLine."Gen. Prod. Posting Group" := ItemJnlBuffer."Gen. Prod. Posting Group";
        if ItemJnlBuffer."Unit of Measure Code" <> '' then begin
            ItemJnlLine.Validate("Unit of Measure Code", ItemJnlBuffer."Unit of Measure Code");
            ItemJnlLine.Validate(Quantity, ItemJnlBuffer.Quantity);
        end else begin
            ItemJnlLine."Qty. per Unit of Measure" := 1;
            ItemJnlLine.Validate("Quantity (Base)", ItemJnlBuffer.Quantity);
        end;
        if ItemJnlBuffer."Unit Amount" <> 0 then
            ItemJnlLine."Unit Amount" := ItemJnlBuffer."Unit Amount"
        else
            ItemJnlLine."Unit Amount" := ROUND(ItemJnlBuffer.Amount / ItemJnlBuffer.Quantity, 0.00001);

        if ItemJnlBuffer.Amount <> 0 then
            ItemJnlLine.Amount := ItemJnlBuffer.Amount
        else
            ItemJnlLine.Amount := Round(ItemJnlLine."Unit Amount" * ItemJnlLine.Quantity, 0.01);

        ItemJnlLine."Value Entry Type" := ItemJnlLine."Value Entry Type"::"Direct Cost";
        ItemJnlLine."Source Code" := SourceCodeSetup."Item Journal";
        ItemJnlLine."Shortcut Dimension 1 Code" := ItemJnlBuffer."Shortcut Dimension 1 Code";
        ItemJnlLine."Shortcut Dimension 2 Code" := ItemJnlBuffer."Shortcut Dimension 2 Code";
        ItemJnlLine."Dimension Set ID" := GetDimensionSetId();
        // >> 001
        ItemJnlLine."Reason Code" := ItemJnlBuffer."Reason Code";
        // << 001
        ItemJnlPostLine.RunWithCheck(ItemJnlLine);
    end;

    local procedure GetDimensionSetId(): Integer
    var
        TempDimSetEntry: Record "Dimension Set Entry" temporary;
        DimMgt: Codeunit DimensionManagement;
        i: Integer;
        FoundDim: Boolean;
    begin
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

    local procedure GetDimensions()
    begin
        GLSetupShortcutDimCode[1] := GLSetup."Shortcut Dimension 1 Code";
        GLSetupShortcutDimCode[2] := GLSetup."Shortcut Dimension 2 Code";
        GLSetupShortcutDimCode[3] := GLSetup."Shortcut Dimension 3 Code";
        GLSetupShortcutDimCode[4] := GLSetup."Shortcut Dimension 4 Code";
        GLSetupShortcutDimCode[5] := GLSetup."Shortcut Dimension 5 Code";
        GLSetupShortcutDimCode[6] := GLSetup."Shortcut Dimension 6 Code";
        GLSetupShortcutDimCode[7] := GLSetup."Shortcut Dimension 7 Code";
        GLSetupShortcutDimCode[8] := GLSetup."Shortcut Dimension 8 Code";

        ShortcutDimCode[1] := ItemJnlBuffer."Shortcut Dimension 1 Code";
        ShortcutDimCode[2] := ItemJnlBuffer."Shortcut Dimension 2 Code";
        ShortcutDimCode[3] := ItemJnlBuffer."Shortcut Dimension 3 Code";
        ShortcutDimCode[4] := ItemJnlBuffer."Shortcut Dimension 4 Code";
        ShortcutDimCode[5] := ItemJnlBuffer."Shortcut Dimension 5 Code";
        ShortcutDimCode[6] := ItemJnlBuffer."Shortcut Dimension 6 Code";
        ShortcutDimCode[7] := ItemJnlBuffer."Shortcut Dimension 7 Code";
        ShortcutDimCode[8] := ItemJnlBuffer."Shortcut Dimension 8 Code";
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