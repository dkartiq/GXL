table 50256 "GXL PDA-Staging Trans. Header"
{
    DataClassification = CustomerContent;
    Caption = 'PDA-Staging Transfer Header';
    LookupPageId = "GXL PDA-Staging Trans. Orders";

    fields
    {
        field(1; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';

            trigger OnValidate()
            begin
                if "No." <> '' then
                    NoSeriesMgt.TestManual(GetNoSeriesCode());
            end;
        }
        field(2; "Transfer-from Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer-from Code';
            TableRelation = Location;
        }
        field(3; "Transfer-from Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer-from Name';
        }
        field(11; "Transfer-to Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer-to Code';
            TableRelation = Location;
        }
        field(12; "Transfer-to Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer-to Name';
        }
        field(20; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
        }
        field(21; "Shipment Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Shipment Date';
        }
        field(22; "Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Receipt Date';
        }
        field(50000; "Order Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Date';
        }
        field(50001; "Delivery Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Delivery Date';
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
        field(50005; "GXL Expected Rceipt Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Receipt Date';
        }
        field(50004; "Created By User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Created By User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(50006; "Total Order Quantity"; Decimal)
        {
            Caption = 'Total Order Quantity';
            DecimalPlaces = 0 : 5;
            FieldClass = FlowField;
            CalcFormula = sum("GXL PDA-Staging Trans. Line".Quantity where("Document No." = field("No.")));
        }
        field(50251; "PDA Batch Id"; Integer)
        {
            //Unique Id from MIM, it is stored to avoid mutiple same order created in case of communication issue b/w PDA and BC
            Caption = 'PDA Batch Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50252; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
            Editable = false;
        }
        //PS-2523 VET Clinic transfer order +
        field(50254; "VET Store Code"; Code[20])
        {
            Caption = 'VET Store Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL VET Store";
        }
        //PS-2523 VET Clinic transfer order -
        field(50350; "Order Status"; enum "GXL PDA-Order Status")
        {
            DataClassification = CustomerContent;
            Caption = 'Order Status';
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
        InvtSetup: Record "Inventory Setup";
        IntegrationSetup: Record "GXL Integration Setup";
        PDAStagingLine: Record "GXL PDA-Staging Trans. Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        HasInventorySetup: Boolean;
        HasIntegationSetup: Boolean;
        NoSeries: Code[20];
        xNoSeries: Code[20];
        DoYouWishToConvertTxt: Label 'Do you wish to convert Staging Transfer Order %1 to Transfer Order?';
        OrderConvertedOkTxt: Label 'Staging Transfer Order %1 has been successfully converted to Transfer Order.';


    trigger OnInsert()
    begin
        GetInventorySetup();
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

    local procedure GetInventorySetup()
    begin
        if not HasInventorySetup then begin
            InvtSetup.Get();
            HasInventorySetup := true;
        end;
    end;


    local procedure TestNoSeries()
    begin
        InvtSetup.TestField("Transfer Order Nos.");
    end;

    local procedure GetNoSeriesCode(): Code[20]
    var
        NoSeriesCode: Code[20];
    begin
        GetInventorySetup();
        NoSeriesCode := InvtSetup."Transfer Order Nos.";
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

    procedure GetNextTONumber(): Code[20]
    begin
        GetInventorySetup();
        xNoSeries := '';
        TestNoSeries();
        NoSeriesMgt.InitSeries(GetNoSeriesCode(), xNoSeries, "Posting Date", "No.", NoSeries);
        exit("No.");
    end;

    procedure PopulateTempTransferHeader(var TempTransHeader: Record "Transfer Header" temporary)
    var
    begin
        TempTransHeader.Init();
        TempTransHeader."No." := '';
        TempTransHeader."GXL Order Date" := "Order Date";
        TempTransHeader."Posting Date" := "Posting Date";
        TempTransHeader."Shipment Date" := "Shipment Date";
        TempTransHeader.SetHideValidationDialog(true);
        TempTransHeader.Insert(); // >> upgrade <<
        TempTransHeader.Validate("Transfer-from Code", "Transfer-from Code");
        TempTransHeader.Validate("Transfer-to Code", "Transfer-to Code");
        TempTransHeader.InitRecord();
    end;

    procedure ConvertStagingDocument()
    var
        PDAStagingTO2TO: Codeunit "GXL PDA-Staging TO-to-TO";
    begin
        TestOrderStatusApproved();
        if not Confirm(StrSubstNo(DoYouWishToConvertTxt, "No."), true) then
            exit;
        PDAStagingTO2TO.Run(Rec);
        Message(StrSubstNo(OrderConvertedOkTxt, "No."));
    end;

    procedure TestOrderStatusApproved()
    begin
        if "Order Status" <> "Order Status"::Approved then
            Error('%1 must be %2', FieldCaption("Order Status"), "Order Status");
    end;


    //PS-2523 VET Clinic transfer order +
    local procedure GetIntegrationSetup()
    begin
        if not HasIntegationSetup then begin
            IntegrationSetup.Get();
            HasIntegationSetup := true;
        end;
    end;

    procedure GetNextTONumberVET(): Code[20]
    begin
        GetIntegrationSetup();
        xNoSeries := '';
        IntegrationSetup.TestField("VET Transfer Order Nos.");
        NoSeriesMgt.InitSeries(IntegrationSetup."VET Transfer Order Nos.", xNoSeries, "Posting Date", "No.", NoSeries);
        exit("No.");
    end;
    //PS-2523 VET Clinic transfer order -


}