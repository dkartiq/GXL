table 50260 "GXL PDA-Staging Purch. Header"
{
    Caption = 'PDA-Staging Purchase Header';
    DataClassification = CustomerContent;
    LookupPageId = "GXL PDA-Staging Purch. Orders";

    fields
    {
        field(2; "Buy-from Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Buy-from Vendor No.';
            TableRelation = Vendor;
        }
        field(3; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';

            trigger OnValidate()
            begin
                if xRec."No." <> "No." then begin
                    GetPurchSetup();
                    NoSeriesMgt.TestManual(GetNoSeriesCode());
                end;
            end;
        }
        field(4; "Pay-to Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Pay-to Vendor No.';
            TableRelation = Vendor;
        }
        field(19; "Order Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Date';
        }
        field(20; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
        }
        field(21; "Expected Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Receipt Date';
        }
        field(28; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(32; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
            TableRelation = Currency;
        }
        field(35; "Prices Including VAT"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Prices Including GST';
        }
        field(79; "Buy-from Vendor Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Buy-from Vendor Name';
        }
        field(50002; "Created Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date';
            Editable = false;
        }
        field(50003; "Created Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Time';
            Editable = false;
        }
        field(50004; "Created By User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Created By User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(50252; "PDA Batch Id"; Integer)
        {
            //Unique Id from MIM, it is stored to avoid mutiple same order created in case of communication issue b/w PDA and BC
            Caption = 'PDA Batch Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50350; "Order Status"; Enum "GXL PDA-Order Status")
        {
            Caption = 'Order Status';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50378; "Audit Flag"; Boolean)
        {
            Caption = 'Audit Flag';
            DataClassification = CustomerContent;
        }
        field(50380; "Total Order Value"; Decimal)
        {
            Caption = 'Total Order Value';
            FieldClass = FlowField;
            CalcFormula = sum("GXL PDA-Staging Purch. Line"."Amount Including VAT" where("Document No." = field("No.")));
            Editable = false;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
        }
        field(50381; "Total Order Qty"; Decimal)
        {
            Caption = 'Total Order Qty';
            DecimalPlaces = 0 : 5;
            FieldClass = FlowField;
            CalcFormula = sum("GXL PDA-Staging Purch. Line"."Carton-Qty" where("Document No." = field("No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "No.")
        {
            Clustered = true;
        }
        key(PDAId; "PDA Batch Id") { }
        key(OrderStatus; "Order Status") { }
    }

    var
        PurchSetup: Record "Purchases & Payables Setup";
        PDAStagingLine: Record "GXL PDA-Staging Purch. Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        HasPurchSetup: Boolean;
        NoSeries: Code[20];
        xNoSeries: Code[20];
        DoYouWishToConvertTxt: Label 'Do you wish to convert Staging Purchase Order %1 to Purchase Order?';
        OrderConvertedOkTxt: Label 'Staging Purchase Order %1 has been successfully converted to Purchase Order.';


    trigger OnInsert()
    begin
        GetPurchSetup();
        if "No." = '' then begin
            xNoSeries := '';
            TestNoSeries();
            NoSeriesMgt.InitSeries(GetNoSeriesCode(), xNoSeries, "Posting Date", "No.", NoSeries);
        end;
        InitRecord();
    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin
        PDAStagingLine.SetRange("Document No.", "No.");
        if not PDAStagingLine.IsEmpty() then
            PDAStagingLine.DeleteAll();
    end;

    trigger OnRename()
    begin

    end;

    local procedure GetPurchSetup()
    begin
        if not HasPurchSetup then begin
            PurchSetup.Get();
            HasPurchSetup := true;
        end;
    end;

    local procedure TestNoSeries()
    begin
        PurchSetup.TestField("Order Nos.");
    end;

    local procedure GetNoSeriesCode(): Code[20]
    var
        NoSeriesCode: Code[20];
    begin
        GetPurchSetup();
        NoSeriesCode := PurchSetup."Order Nos.";
        exit(NoSeriesCode);
    end;

    local procedure InitRecord()
    begin
        if "Posting Date" = 0D then
            "Posting Date" := WorkDate();

        if "Order Date" = 0D then
            "Order Date" := WorkDate();

        "Created Date" := Today();
        "Created Time" := Time();
        "Created By User ID" := UserId();
    end;

    procedure GetNextPONumber(): Code[20]
    begin
        GetPurchSetup();
        TestNoSeries();
        NoSeriesMgt.InitSeries(GetNoSeriesCode(), xNoSeries, "Posting Date", "No.", NoSeries);
        exit("No.");
    end;

    procedure PopulateTempPurchaseHeader(var TempPurchHeader: Record "Purchase Header" temporary)
    begin
        TempPurchHeader.Init();
        TempPurchHeader."Document Type" := TempPurchHeader."Document Type"::Order;
        TempPurchHeader."No." := '';
        TempPurchHeader."Order Date" := "Order Date";
        TempPurchHeader."Posting Date" := "Posting Date";
        TempPurchHeader.SetHideValidationDialog(true);
        TempPurchHeader.Validate("Buy-from Vendor No.", "Buy-from Vendor No.");
        TempPurchHeader.Validate("Location Code", "Location Code");
        TempPurchHeader."GXL Source of Supply" := TempPurchHeader."GXL Source of Supply"::SD;
        TempPurchHeader.GXL_InitSupplyChain();
        //TempPurchHeader.UpdateLeadTimeFields; //TODO: check if we need lead time
    end;

    procedure ConvertStagingDocument()
    var
        PDAStagingPO2PO: Codeunit "GXL PDA-Staging PO-to-PO";
    begin
        TestOrderStatusApproved();
        if not Confirm(StrSubstNo(DoYouWishToConvertTxt, "No."), true) then
            exit;
        PDAStagingPO2PO.Run(Rec);

        Message(StrSubstNo(OrderConvertedOkTxt, "No."));
    end;

    procedure TestOrderStatusApproved()
    begin
        if "Order Status" <> "Order Status"::Approved then
            Error('%1 must be %2', FieldCaption("Order Status"), "Order Status");
    end;
}