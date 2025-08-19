// 003  18.07.2025  BY   HP2-Sprint3-Changes HAR2-69
// 002 BY 12.08.2025 International Purchase order Changes
// 001 23.04.2024  SKY   HP-2408 Added New Field :Item Category Description 
tableextension 50007 "GXL Purchase Line" extends "Purchase Line"
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
        field(50001; "GXL Carton-Qty"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Carton-Qty.';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            var
                VendorL: Record Vendor; // >> LCB-203 <<  
            begin
                TestStatusOpen();
                GXL_TestOrderStatusNotConfirmed();
                // >> LCB-203 
                if VendorL.OverrideOPOMCalculation(Rec."Buy-from Vendor No.") then
                    exit;
                // << LCB-203 
                if (xRec."GXL Carton-Qty" <> "GXL Carton-Qty") then begin
                    Validate(Quantity, "GXL Carton-Qty");
                    UpdateDirectUnitCost(FieldNo("GXL Carton-Qty"));
                end;
            end;
        }
        field(50002; "GXL Order Change Reason Code"; Code[10])
        {
            Caption = 'Order Change Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        //ERP-NAV Master Data Management +
        field(50300; "GXL Gross Weight"; Decimal)
        {
            Caption = 'Gross Weight';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50301; "GXL Cubage"; Decimal)
        {
            Caption = 'Cubage';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        //ERP-NAV Master Data Management +
        field(50350; "GXL Rec. Variance"; Decimal)
        {
            Caption = 'Rec. Variance';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50351; "GXL Qty. Variance Reason Code"; Code[10])
        {
            Caption = 'Qty. Variance Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(50352; "GXL Confirmed Invoice Qty"; Decimal)
        {
            Caption = 'Confirmed Invoice Qty';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50353; "GXL Confirmed Direct Unit Cost"; Decimal)
        {
            Caption = 'Confirmed Direct Unit Cost';
            DataClassification = CustomerContent;
        }
        field(50354; "GXL Confirmed Quantity"; Decimal)
        {
            Caption = 'Confirmed Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            trigger OnValidate()
            begin
                TestStatusOpen();
                GXL_TestOrderStatusNotConfirmed();

                IF (xRec."GXL Confirmed Quantity" <> "GXL Confirmed Quantity") THEN BEGIN
                    VALIDATE(Quantity, "GXL Confirmed Quantity");

                    UpdateDirectUnitCost(FIELDNO("GXL Confirmed Quantity"));
                END;

                IF ("GXL Confirmed Quantity" <> Quantity) THEN
                    "GXL ConfirmedQtyVar" := TRUE;
            end;
        }
        field(50355; "GXL ConfirmedQtyVar"; Boolean)
        {
            Caption = 'ConfirmedQtyVar';
            DataClassification = CustomerContent;
        }
        field(50356; "GXL Vendor Reorder No."; Code[20])
        {
            Caption = 'Vendor Reorder No.';
            DataClassification = CustomerContent;
        }
        field(50357; "GXL ASN Rec. Variance"; Decimal)
        {
            Caption = 'ASN Rec. Variance';
            DataClassification = CustomerContent;
        }
        field(50358; "GXL Primary EAN"; Code[50])
        {
            Caption = 'Primary EAN';
            DataClassification = CustomerContent;
        }
        field(50359; "GXL OP GTIN"; Code[50])
        {
            Caption = 'OP GTIN';
            DataClassification = CustomerContent;
        }
        // >> HP2-Sprint2
        field(50295; "GXL OM GTIN"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'OM GTIN';
        }
        field(50297; "GXL Pallet GTIN"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Pallet GTIN';
        }
        // << HP2-Sprint2
        field(50360; "GXL Vendor OP Reorder No."; Code[20])
        {
            Caption = 'Vendor OP Reorder No.';
            DataClassification = CustomerContent;
        }
        field(50361; "GXL OP Unit of Measure Code"; Code[10])
        {
            Caption = 'OP Unit of Measure Code';
            DataClassification = CustomerContent;
            TableRelation = "Unit of Measure";
        }
        field(50362; "GXL Order Status"; Option)
        {
            Caption = 'Order Status';
            OptionMembers = New,Created,Placed,Confirmed,"Booked to Ship",Shipped,Arrived,Cancelled,Closed;
            FieldClass = FlowField;
            CalcFormula = lookup("Purchase Header"."GXL Order Status" where("Document Type" = field("Document Type"), "No." = field("Document No.")));
            Editable = false;
        }

        // >> 001
        field(50363; "Item Category Description"; Text[100])
        {
            Caption = 'Item Category Description';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("Item Category".Description Where(Code = field("Item Category Code")));
        }
        // 001 09.07.2025 MAY HP2-Sprint2-Changes
        field(50364; "GXL JDA Load ID"; Code[20])
        {
            Caption = 'JDA Load ID';
            DataClassification = CustomerContent;
        }
        // 001 09.07.2025 MAY HP2-Sprint2-Changes
        // << 001
        // >> 002
        field(50365; "GXL Hazardous Item"; Boolean)
        {
            Caption = 'Hazardous Item';
            DataClassification = ToBeClassified;
        }
        field(50366; "GXL Original Ordered Quantity"; Decimal)
        {
            Caption = 'Original Ordered Quantity';
            DecimalPlaces = 0 : 5;
            DataClassification = ToBeClassified;
        }
        field(50367; "GXL Order Changed Date"; Date)
        {
            Editable = false;
            Caption = 'Order Changed Date';
            DataClassification = ToBeClassified;
        }
        field(50368; "GXL Order Changed Time"; Time)
        {
            Editable = false;
            Caption = 'Order Changed Time';
            DataClassification = ToBeClassified;
        }
        field(50369; "GXL Changed By User ID"; Code[50])
        {
            Caption = 'Changed By User ID';
            TableRelation = User;
            ValidateTableRelation = false;
            TestTableRelation = false;
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(50370; "OP GTIN"; Code[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50371; "GXL Last JDA Date Modified"; Date)
        {
            Caption = 'Last JDA Date Modified';
            DataClassification = ToBeClassified;
        }
        // << 002
        modify(Quantity)
        {
            trigger OnAfterValidate()
            begin
                if (Type = Type::Item) and (not "System-Created Entry") then //ERP-207 <<
                    GXL_TestOrderStatusNotConfirmed();
                if Type = Type::Item then
                    "GXL Carton-Qty" := GXL_CalcCartonQty(Quantity);
            end;
        }
        modify("Qty. to Receive")
        {
            trigger OnAfterValidate()
            begin
                if (Type = Type::Item) and (not "System-Created Entry") then //ERP-207 <<
                    GXL_TestOrderStatusNotClosed();
                "GXL ConfirmedQtyVar" := NOT (("Qty. to Receive" <> 0) AND ("Qty. to Receive" <> Quantity));
            end;
        }
        //PS-2270+
        //  Not required for now as PO was synched from NAV13
        modify("No.")
        {
            trigger OnAfterValidate()
            begin
                if Type = Type::Item then begin
                    if ("No." <> '') then begin
                        "GXL Vendor Reorder No." := '';
                        "GXL Vendor Reorder No." := GetVendorReorderNo("No.");
                    end;
                end;
            end;
        }

        //PS-2270-
        modify("Location Code")
        {
            trigger OnAfterValidate()
            var
                Loc: Record Location;
                Store: Record "LSC Store";
                IntegrationSetup: Record "GXL Integration Setup";
                MiscUtilities: Codeunit "GXL Misc. Utilities";
            begin
                if ("Location Code" <> xRec."Location Code") and ("Location Code" <> '') then
                    if Quantity <> 0 then begin
                        if IntegrationSetup.Get() then
                            if IntegrationSetup."Store Dimension Code" <> '' then begin
                                Loc.Get("Location Code");
                                if Loc.GetAssociatedStore(Store, true) then
                                    Validate("Shortcut Dimension 2 Code", MiscUtilities.GetStoreDimensionValue(Store."No.", IntegrationSetup."Store Dimension Code"));
                            end;
                    end;
            end;
        }
    }
    // >> HP2-SPRINT2
    procedure GetVendorReorderNo(ItemNoP: Code[20]): Code[20]
    var
        ItemRef: Record "Item Reference";
    begin
        ItemRef.RESET;
        ItemRef.SETCURRENTKEY("Item No.", "Variant Code", "Unit of Measure", "Reference Type", "Reference Type No.");
        ItemRef.SETRANGE(ItemRef."Item No.", ItemNoP);
        ItemRef.SETRANGE("Unit of Measure", "Unit of Measure Code");
        ItemRef.SETRANGE(ItemRef."Reference Type", ItemRef."Reference Type"::Vendor);
        // >> pv00.12
        ItemRef.SETRANGE(ItemRef."Reference Type No.", "Buy-from Vendor No.");
        // << pv00.12
        IF ItemRef.FINDFIRST() THEN
            EXIT(ItemRef."Reference No.");

        EXIT('');
    end;
    // << HP2-SPRINT2
    local procedure GXL_TestOrderStatusNotConfirmed()
    var
        GXLPurchHeader: Record "Purchase Header";
    begin
        IF OrderStatusCheckSuspended THEN
            EXIT;

        GXLPurchHeader.Get("Document Type", "Document No.");
        IF GXLPurchHeader."GXL Order Status" > GXLPurchHeader."GXL Order Status"::Placed THEN
            GXLPurchHeader.FIELDERROR("GXL Order Status");
    end;

    local procedure GXL_TestOrderStatusNotClosed()
    var
        GXLPurchHeader: Record "Purchase Header";
    begin
        IF OrderStatusCheckSuspended THEN
            EXIT;

        GXLPurchHeader.Get("Document Type", "Document No.");
        if GXLPurchHeader."GXL International Order" then begin
            if GXLPurchHeader."GXL Order Status" > GXLPurchHeader."GXL Order Status"::Arrived then
                GXLPurchHeader.FieldError("GXL Order Status");
        end else begin
            if GXLPurchHeader."GXL Order Status" > GXLPurchHeader."GXL Order Status"::Confirmed then
                GXLPurchHeader.FieldError("GXL Order Status");
        end;

    end;


    procedure InitSupplyChainQuantities()
    begin
        "GXL Confirmed Quantity" := Quantity;
    end;

    procedure SuspendOrderStatusCheck(Suspend: Boolean)
    begin
        OrderStatusCheckSuspended := Suspend;
    end;

    procedure SuspendSKUCheck(Suspend: Boolean)
    begin
        SkuCheckSuspended := Suspend;
    end;

    procedure SetPDAOverReceiving(ReasonCode: Code[10])
    begin
        SuspendStatusCheck(true);
        SuspendOrderStatusCheck(true);
        SuspendSKUCheck(true);
        PDAReceive := true;
        "GXL Order Change Reason Code" := ReasonCode;
    end;

    procedure GXL_CalcCartonQty(Qty: Decimal): Decimal
    var
        Loc: Record Location;
        Store: Record "LSC Store";
        CartonQty: Decimal;
        VendorL: Record Vendor;
    begin
        GXL_GetSKU();
        CartonQty := Quantity;
        Loc.Code := "Location Code";
        if Loc.GetAssociatedStore(Store, true) then
            if not VendorL.OverrideOPOMCalculation(Rec."Buy-from Vendor No.") then // >> LCB-203 <<  
                case Store."GXL Location Type" of
                    Store."GXL Location Type"::"3":
                        if GXL_SKU."GXL Order Pack (OP)" <> 0 then
                            CartonQty := Round(Qty / GXL_SKU."GXL Order Pack (OP)", 0.00001);
                    Store."GXL Location Type"::"6":
                        if GXL_SKU."GXL Order Multiple (OM)" <> 0 then
                            CartonQty := Round(Qty / GXL_SKU."GXL Order Multiple (OM)", 0.00001);
                end;

        GXL_CalcCartonWeightCubage(CartonQty);
        exit(CartonQty);
    end;

    local procedure GXL_CalcCartonWeightCubage(CartonQty: Decimal)
    var
        ItemUOM: Record "Item Unit of Measure";
        Loc: Record Location;
        Store: Record "LSC Store";
        WeightFactor: Decimal;
        CubageFactor: Decimal;
    begin
        "Gross Weight" := 0;
        "Unit Volume" := 0; //Cubage
        if CartonQty = 0 then
            exit;

        if (Type = Type::Item) and ("No." <> '') and ("Unit of Measure Code" <> '') and ("Location Code" <> '') then
            if ItemUOM.Get("No.", "Unit of Measure Code") then begin
                Loc.Code := "Location Code";
                if Loc.GetAssociatedStore(Store, true) then begin
                    case Store."GXL Location Type" of
                        Store."GXL Location Type"::"1":
                            begin
                                WeightFactor := ItemUOM.Weight;
                                CubageFactor := ItemUOM.Cubage;
                            end;
                        Store."GXL Location Type"::"3":
                            begin
                                WeightFactor := ItemUOM."GXL OP Weight";
                                CubageFactor := ItemUOM."GXL OP Cubage";
                            end;
                        Store."GXL Location Type"::"6":
                            begin
                                WeightFactor := ItemUOM."GXL OM Weight";
                                CubageFactor := ItemUOM."GXL OM Cubage";
                            end;
                    end;
                    //ERP-NAV Master Data Management +
                    //"Gross Weight" := Round(CartonQty * WeightFactor, 0.00001);
                    //"Unit Volume" := Round(CartonQty * CubageFactor, 0.00001);
                    "GXL Gross Weight" := Round(CartonQty * WeightFactor, 0.00001);
                    "GXL Cubage" := Round(CartonQty * CubageFactor, 0.00001);
                    //ERP-NAV Master Data Management -
                end;

            end;
    end;

    local procedure GXL_GetSKU(): Boolean
    begin
        TestField("No.");
        if (GXL_SKU."Location Code" = "Location Code") and
            (GXL_SKU."Item No." = "No.") and
            (GXL_SKU."Variant Code" = "Variant Code") then
            exit(true);
        if GXL_SKU.Get("Location Code", "No.", "Variant Code") then
            exit(true);
        exit(false);
    end;
    // >> Upgrade
    procedure UpdateBarCodes()
    var
        ItemCrossReference: Record "Item Reference";
    //Vendor: Record Vendor;
    begin
        ItemCrossReference.RESET();
        ItemCrossReference.SETCURRENTKEY("Reference Type", "Reference No.");

        ItemCrossReference.SETFILTER("Reference Type", '%1', ItemCrossReference."Reference Type"::"Bar Code");
        ItemCrossReference.SETRANGE("Item No.", "No.");
        /*
        ItemCrossReference.SETRANGE("Discontinue Bar Code", FALSE);
        //TODO - Are we using item cross reference for this?
        ItemCrossReference.SETRANGE("Primary Bar Code", TRUE);

        ItemCrossReference.SETRANGE(ItemCrossReference."Primary EAN");
        IF ItemCrossReference.FINDFIRST THEN BEGIN
            "GXL Primary EAN" := ItemCrossReference."Primary EAN";
            "GXL OM GTIN" := ItemCrossReference."OM GTIN";
            "GXL OP GTIN" := ItemCrossReference."OP GTIN";
            "GXL Pallet GTIN" := ItemCrossReference."Pallet GTIN";
            "GXL OP Unit of Measure Code" := ItemCrossReference."Outer UOM Code";

            Vendor.GET(PurchHeader."Buy-from Vendor No.");
            IF Vendor."GXL EDI Supplier No. Source" = Vendor."GXL EDI Supplier No. Source"::"Outer Pack GTIN" THEN
                "GXL Vendor OP Reorder No." := ItemCrossReference."OP GTIN"
            ELSE
                "Vendor OP Reorder No." := ItemCrossReference."OP Reorder No.";
        END;
        */
    end;
    // << Upgrade
    // >> 003
    procedure ExportPurchLines(DocNoP: Text)
    var
        PurchLine: Record "Purchase Line";
        ExcelBuffer: Record "Excel Buffer" temporary;
        TempBlob: Codeunit "Temp Blob";
        outStream: OutStream;
        FileName: Text;
        InStream: InStream;
        DateTimeText: Text;
    begin
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetFilter("Document No.", DocNoP);
        if Not PurchLine.FindSet() then
            exit;

        ExcelBuffer.DeleteAll();
        ExcelBuffer.AddColumn('PO No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('Line No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('Item No.', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Description', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('UOM', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('Quantity', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('Direct Unit Cost', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
        ExcelBuffer.AddColumn('Status', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
        ExcelBuffer.AddColumn('Expected Receipt Date', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
        ExcelBuffer.AddColumn('Booked for Delivery', false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);

        repeat
            ExcelBuffer.NewRow();
            ExcelBuffer.AddColumn(PurchLine."Document No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
            ExcelBuffer.AddColumn(PurchLine."Line No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
            ExcelBuffer.AddColumn(PurchLine."No.", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(PurchLine."Description", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(PurchLine."Unit of Measure Code", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(PurchLine."Quantity", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
            ExcelBuffer.AddColumn(PurchLine."Direct Unit Cost", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Number);
            ExcelBuffer.AddColumn(PurchLine."GXL Order Status", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Text);
            ExcelBuffer.AddColumn(PurchLine."Expected Receipt Date", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
        //ExcelBuffer.AddColumn(PurchLine."Booked for Delivery", false, '', false, false, false, '', ExcelBuffer."Cell Type"::Date);
        until PurchLine.Next() = 0;

        ExcelBuffer.CreateNewBook('PO Lines');
        ExcelBuffer.WriteSheet('PO Lines', '', '');
        ExcelBuffer.CloseBook();
        ExcelBuffer.OpenExcel();

        TempBlob.CreateOutStream(outStream);
        ExcelBuffer.SaveToStream(outStream, true);
        DateTimeText := Format(CurrentDateTime(), 0, '<Year4><Month,2><Day,2>_<Hour,2><Minute,2><Second,2>');
        FileName := StrSubstNo('PO Lines_%1.xlsx', DateTimeText);
        TempBlob.CreateInStream(InStream);
        DownloadFromStream(InStream, '', '', '', FileName);
    end;

    procedure ImportPurchaseLinesFromExcel(PurchaseHeader: Record "Purchase Header")
    var
        ExcelBuffer: Record "Excel Buffer";
        FileName: Text;
        FileInStream: InStream;
        Dialog: Dialog;
        PurchLine: Record "Purchase Line";
        LineNo: Integer;
        LineNo2: Integer;
        LastRow: Integer;
        ExcelRow: Integer;
    begin
        ExcelBuffer.DeleteAll();
        Clear(ExcelBuffer);
        Dialog.Open('Select Excel file to import...');
        UploadIntoStream('Import Purchase Lines', '', '', FileName, FileInStream);

        ExcelBuffer.OpenBookStream(FileInStream, 'PO Lines');
        ExcelBuffer.ReadSheet();

        ExcelBuffer.SETRANGE("Column No.", 1);
        ExcelBuffer.FINDLAST;
        LastRow := ExcelBuffer."Row No.";
        ExcelBuffer.Reset();

        FOR ExcelRow := 2 TO LastRow DO BEGIN
            Evaluate(LineNo2, ExcelBuffer.GetCellValue(ExcelRow, 2));
            PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
            PurchLine.SetRange("Document No.", ExcelBuffer.GetCellValue(ExcelRow, 1));
            PurchLine.SetRange("Line No.", LineNo2);
            IF NOT PurchLine.Findfirst() THEN Begin
                PurchLine.Init();
                PurchLine.Validate("Document Type", PurchaseHeader."Document Type"::Order);
                PurchLine.Validate("Document No.", ExcelBuffer.GetCellValue(ExcelRow, 1));
                PurchLine."Line No." := GetPurchLineNo(PurchLine."Document No.");

                PurchLine.Validate("No.", ExcelBuffer.GetCellValue(ExcelRow, 3));
                PurchLine.Validate(Description, ExcelBuffer.GetCellValue(ExcelRow, 4));
                PurchLine.Validate("Unit of Measure Code", ExcelBuffer.GetCellValue(ExcelRow, 5));
                PurchLine.Validate(Quantity, EvaluateDecimal(ExcelBuffer.GetCellValue(ExcelRow, 6)));
                PurchLine.Validate("Direct Unit Cost", EvaluateDecimal(ExcelBuffer.GetCellValue(ExcelRow, 7)));
                Evaluate(PurchLine."GXL Order Status", ExcelBuffer.GetCellValue(ExcelRow, 8));
                Evaluate(PurchLine."Expected Receipt Date", ExcelBuffer.GetCellValue(ExcelRow, 9));

                PurchLine.Insert(True);
            End Else begin
                IF (PurchLine."No." <> ExcelBuffer.GetCellValue(ExcelRow, 3)) THEN
                    PurchLine.Validate("No.", ExcelBuffer.GetCellValue(ExcelRow, 3));

                if (PurchLine.Description <> ExcelBuffer.GetCellValue(ExcelRow, 4)) THEN
                    PurchLine.Validate(Description, ExcelBuffer.GetCellValue(ExcelRow, 4));

                if (PurchLine."Unit of Measure" <> ExcelBuffer.GetCellValue(ExcelRow, 5)) THEN
                    PurchLine.Validate("Unit of Measure Code", ExcelBuffer.GetCellValue(ExcelRow, 5));

                if (PurchLine.Quantity <> EvaluateDecimal(ExcelBuffer.GetCellValue(ExcelRow, 6))) THEN
                    PurchLine.Validate(Quantity, EvaluateDecimal(ExcelBuffer.GetCellValue(ExcelRow, 6)));

                if (PurchLine."Direct Unit Cost" <> EvaluateDecimal(ExcelBuffer.GetCellValue(ExcelRow, 7))) THEN
                    PurchLine.Validate("Direct Unit Cost", EvaluateDecimal(ExcelBuffer.GetCellValue(ExcelRow, 7)));

                Evaluate(PurchLine."GXL Order Status", ExcelBuffer.GetCellValue(ExcelRow, 8));
                Evaluate(PurchLine."Expected Receipt Date", ExcelBuffer.GetCellValue(ExcelRow, 9));
                PurchLine.Modify(True);
            end;

        end;
        ExcelBuffer.Reset();

        Message('Purchase lines imported successfully.');
    end;

    local procedure EvaluateDecimal(ValueText: Text): Decimal
    var
        DecimalValue: Decimal;
    begin
        Evaluate(DecimalValue, ValueText);
        exit(DecimalValue);
    end;

    local procedure GetPurchLineNo(DocNoP: Code[20]): Integer
    var
        PurchLine: Record "Purchase Line";
    begin
        PurchLine.SetRange("Document Type", PurchLine."Document Type"::Order);
        PurchLine.SetRange("Document No.", DocNoP);
        IF PurchLine.FindLast() THEN
            exit(PurchLine."Line No." + 10000);

        Exit(10000);
    end;
    // << 003

    var
        GXL_SKU: Record "Stockkeeping Unit";
        OrderStatusCheckSuspended: Boolean;
        SkuCheckSuspended: Boolean;
        PDAReceive: Boolean;


}