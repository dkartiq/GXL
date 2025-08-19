// 002 14.08.2025 BY HP2-Sprint2-Changes
// 001 23.04.2024  SKY   HP-2408 Added New Field :Item Category Description 
tableextension 50009 "GXL Transfer Line" extends "Transfer Line"
{
    fields
    {
        field(50000; "GXL Legacy Item No."; Code[20])
        {
            Caption = 'Legacy Item No.';
            DataClassification = CustomerContent;
            Editable = false;
            //Only to be validated internally
        }
        field(50001; "GXL Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
        }
        field(50002; "GXL Total Cost"; Decimal)
        {
            Caption = 'Total Cost';
            DataClassification = CustomerContent;
            AutoFormatType = 1;
        }
        field(50351; "GXL Qty Variance"; Decimal)
        {
            Caption = 'Qty Variance';
            DataClassification = CustomerContent;
        }
        field(50352; "GXL Qty. Variance Resaon Code"; Code[10])
        {
            Caption = 'Qty. Variance Resaon Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }

        // >> 001
        field(50353; "Item Category Description"; Text[100])
        {
            Caption = 'Item Category Description';
            Editable = False;
            FieldClass = FlowField;
            CalcFormula = lookup("Item Category".Description Where(Code = field("Item Category Code")));
        }
        // << 001
        // >> 001 07.07.2025 BY HP2-Sprint2-Changes
        field(50354; "Vendor Reorder No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50355; "Carton-Qty"; Decimal)
        {
            DataClassification = ToBeClassified;
        }
        field(50356; "JDA PO No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(50357; "Cross-Reference No."; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        // << 001 07.07.2025 BY HP2-Sprint2-Changes
        // >> 002
        field(50360; "GXL Last JDA Date Modified"; Date)
        {
            Caption = 'Last JDA Date Modified';
            DataClassification = ToBeClassified;
        }
        // << 002
        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
                LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
            begin
                if "Item No." = '' then begin
                    "GXL Legacy Item No." := '';
                end else begin
                    if "Unit of Measure Code" = '' then
                        "GXL Legacy Item No." := "Item No."
                    else
                        LegacyItemHelpers.GetLegacyItemNo("Item No.", "Unit of Measure Code", "GXL Legacy Item No.");

                    GXL_GetUnitCost();
                    GXL_UpdateTotalCost();
                end;
            end;
        }
        modify("Unit of Measure Code")
        {
            trigger OnAfterValidate()
            var
                LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
            begin
                if "Unit of Measure Code" = '' then
                    "GXL Legacy Item No." := "Item No."
                else
                    LegacyItemHelpers.GetLegacyItemNo("Item No.", "Unit of Measure Code", "GXL Legacy Item No.");

                GXL_GetUnitCost();
                GXL_UpdateTotalCost();
            end;
        }
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                GXL_UpdateTotalCost();
            end;
        }
    }

    var
        SKU: Record "Stockkeeping Unit";
        Item: Record Item;

    local procedure GXL_GetSKU(): Boolean
    begin
        if (SKU."Item No." <> "Item No.") or (SKU."Location Code" <> "Transfer-from Code") or (SKU."Variant Code" <> "Variant Code") then begin
            if SKU.Get("Transfer-from Code", "Item No.", "Variant Code") then
                exit(true)
            else
                exit(false);
        end else
            exit(true);
    end;

    //ERP-295 +
    local procedure GXL_GetItem()
    begin
        if "Item No." = '' then
            exit;
        if Item."No." <> "Item No." then
            Item.Get("Item No.");
    end;
    //ERP-295 -

    local procedure GXL_GetUnitCost()
    begin
        //ERP-295 +
        // if GXL_GetSKU() then
        //     "GXL Unit Cost" := Round(SKU."Standard Cost" * "Qty. per Unit of Measure", 0.00001);
        GXL_GetItem();
        if "Item No." <> '' then
            "GXL Unit Cost" := Round(Item."GXL Standard Cost" * "Qty. per Unit of Measure", 0.00001)
        else
            "GXL Unit Cost" := 0;
        //ERP-295 -
    end;

    local procedure GXL_UpdateTotalCost()
    begin
        "GXL Total Cost" := Round("GXL Unit Cost" * Quantity);
    end;

    procedure GXL_CheckStoreToStoreTransfer(): Boolean
    var
        Loc: Record Location;
        Store: Record "LSC Store";
    begin
        Loc.Code := "Transfer-from Code";
        if not Loc.GetAssociatedStore(Store, true) then
            exit(false);

        if Store."GXL Location Type" <> Store."GXL Location Type"::"6" then
            exit(false);

        Loc.Code := "Transfer-to Code";
        if not Loc.GetAssociatedStore(Store, true) then
            exit(false);

        if Store."GXL Location Type" <> Store."GXL Location Type"::"6" then
            exit(false);

        exit(true);

    end;

}