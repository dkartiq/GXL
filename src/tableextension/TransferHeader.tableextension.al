// 001 23.07.2025 BY  HAR2-406 Added action Release and Reopen
// 002 14.08.2025 BY HP2-Sprint2-Changes
tableextension 50008 "GXL Transfer Header" extends "Transfer Header"
{
    fields
    {
        field(50000; "GXL Order Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Date';
        }
        field(50001; "GXL Delivery Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Delivery Date';
        }
        field(50002; "GXL Created Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date';
            Editable = false;
        }
        field(50003; "GXL Created Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Time';
            Editable = false;
        }
        field(50004; "GXL Created By User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Created By User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            Editable = false;
        }
        field(50005; "GXL Expected Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Receipt Date';
        }
        field(50006; "GXL Total Order Quantity"; Decimal)
        {
            Caption = 'Total Order Quantity';
            DecimalPlaces = 0 : 5;
            FieldClass = FlowField;
            CalcFormula = sum("Transfer Line".Quantity where("Document No." = field("No.")));
            Editable = false;
        }
        field(50250; "GXL Staging Order Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Staging Total Order Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            //Internal field, to be used for PDA
        }
        //fields 50251, 50252 are reserved for PDA-Staging Trans. Line - do not use

        //PS-2046+
        field(50253; "GXL MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
        //PS-2523 VET Clinic transfer order +
        field(50254; "GXL VET Store Code"; Code[20])
        {
            Caption = 'VET Store Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL VET Store";
        }
        //PS-2523 VET Clinic transfer order -

        field(50350; "GXL Order Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Status';
            OptionMembers = New,Created,Placed,Confirmed,"Booked to Ship",Shipped,Arrived,Cancelled,Closed,"Cancel Requested","Cancel Denied";
            Editable = false;
        }
        field(50351; "GXL 3PL"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = '3PL';
        }
        field(50352; "GXL 3PL File Sent"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = '3PL File Sent';
        }
        field(50353; "GXL 3PL File Receive"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = '3PL File Receive';
        }
        field(50354; "GXL Source of Supply"; Enum "GXL Source of Supply")
        {
            DataClassification = CustomerContent;
            Caption = 'Source of Supply';

            trigger OnValidate()
            var
                RecTransLine: Record "Transfer Line";
                SupplyChainSetup: Record "GXL Supply Chain Setup"; // >> HP2-SPRINT <<
            begin
                IF "GXL Source of Supply" <> xRec."GXL Source of Supply" THEN BEGIN
                    RecTransLine.RESET();
                    RecTransLine.SETRANGE("Document No.", "No.");
                    RecTransLine.SETFILTER("Item No.", '<>%1', '');
                    IF not RecTransLine.IsEmpty() THEN
                        ERROR('You must delete the existing transfer lines before you can change Source of Supply.');
                    "GXL Transport Type" := '';
                    IF "GXL Source of Supply" = "GXL Source of Supply"::WH THEN BEGIN
                        SupplyChainSetup.GET;
                        "GXL Transport Type" := FORMAT("GXL Source of Supply") + SupplyChainSetup."GXL Default Transportation Mode";
                    END;
                END;
            end;
        }
        field(50355; "GXL 3PL File Sent Date"; Date)
        {
            Caption = '3PL File Sent Date';
            DataClassification = CustomerContent;
        }
        field(50356; "GXL Audit Flag"; Boolean)
        {
            Caption = 'Audit Flag';
            DataClassification = CustomerContent;
        }
        // >> 001 07.07.2025 BY HP2-Sprint2-Changes
        field(50357; "JDA PO No."; Code[20])
        {
            Caption = 'JDA PO No.';
            DataClassification = ToBeClassified;
        }
        // << 001 07.07.2025 BY HP2-Sprint2-Changes
        // >> HP2-SPRINT2
        field(50358; "GXL Transport Type"; Code[30])
        {
            Caption = 'Transport Type';
            TableRelation = "GXL Transport Type";
            DataClassification = ToBeClassified;
        }
        field(50359; "GXL 3PL Out"; Boolean)
        {
            Caption = '3PL Out';
        }
        // >> 002
        field(50361; "Distributor Name"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
        field(50363; "GXL Order Type"; Option)
        {
            Caption = 'Order Type';
            OptionMembers = Manual,Automatic,JDA;
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(50364; "GXL JDA Load ID"; Code[20])
        {
            Caption = 'JDA Load ID';
            DataClassification = ToBeClassified;
        }
        field(50365; "GXL LSC Received "; Boolean)
        {
            Caption = 'LSC Received';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(50366; "GXL Total Value"; Decimal)
        {
            Caption = 'Total Value';
            FieldClass = FlowField;
            CalcFormula = sum("Transfer Line"."GXL Total Cost" where("Document No." = field("No.")));
        }
        field(50367; "GXL Send To JDA"; Boolean)
        {
            Caption = 'Send To JDA';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            var
                myInt: Integer;
            begin
                IF "GXL Send To JDA" <> xRec."GXL Send To JDA" then
                    UpdateTransLines(Rec, FieldNo("GXL Send To JDA"));
            end;
        }
        field(50368; "GXL Last JDA Date Modified"; Date)
        {
            Caption = 'Last JDA Date Modified';
            DataClassification = ToBeClassified;
        }
        field(50369; "GXL ASN Created"; Boolean)
        {
            Caption = 'ASN Created';
            FieldClass = FlowField;
            CalcFormula = exist("GXL ASN Header" where("Document Type" = const(Transfer), "Transfer Order No." = field("No.")));
            trigger OnValidate()
            var
                ASNHeader: Record "GXL ASN Header";
            begin
                CalcFields("GXL ASN Created");
                IF not "GXL ASN Created" then
                    exit;
                ASNHeader.SetCurrentKey("Document Type", "Transfer Order No.");
                ASNHeader.FilterGroup(2);
                ASNHeader.SetRange("Document Type", ASNHeader."Document Type"::Transfer);
                ASNHeader.FilterGroup(0);

                Page.RunModal(Page::"GXL Advance Shipping Notice", ASNHeader);
            end;
        }
        field(50370; "GXL ASN Confirmed"; Boolean)
        {
            Caption = 'ASN Confirmed';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                CalcFields("GXL ASN Created");
                TestField("GXL ASN Created", true);
            end;
        }
        field(50371; "GXl 3PL Cancel Request Sent"; Boolean)
        {
            Caption = '3PL Cancel Request Sent';
            DataClassification = ToBeClassified;
        }
        field(50372; "GXl 3PL Cancel Req Receieved"; Boolean)
        {
            Caption = '3PL Cancel Request Receieved';
            DataClassification = ToBeClassified;
        }
        field(50373; "GXl 3PL Cancel Date"; Date)
        {
            Caption = '3PL Cancel Date';
            DataClassification = ToBeClassified;
        }
        field(50374; "GXl 3PL File Updated"; Date)
        {
            Caption = '3PL File Updated';
            DataClassification = ToBeClassified;
        }
        field(50375; "GXl PDA Integer"; Integer)
        {
            Caption = 'PDA Integer';
            DataClassification = ToBeClassified;
        }
        field(50376; "GXL RMS ID"; Integer)
        {
            Caption = 'RMS ID';
            DataClassification = ToBeClassified;
        }
        field(50377; "GXL RMS Transfer No."; Code[20])
        {
            Caption = 'RMS Transfer No.';
            DataClassification = ToBeClassified;
        }
        field(50378; "GXL RMS Worksheet ID"; Integer)
        {
            Caption = 'RMS Worksheet ID';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        field(50379; "GXL Date Sent to Store"; Date)
        {
            Caption = 'Date Sent to Store';
            Editable = false;
            DataClassification = ToBeClassified;
        }
        // << 002
        // << HP2-SPRINT2
        //PS-2143+
        //Moved code to event triggers in codeunit
        /*
        modify("Transfer-from Code")
        {
            trigger OnAfterValidate()
            var
                Location: Record Location;
            begin
                if ("Transfer-from Code" <> '') then begin
                    IF Location.Get("Transfer-from Code") then begin
                        "GXL 3PL" := false;
                        Location.CalcFields("GXL Location Type");
                        if Location."GXL Location Type" = Location."GXL Location Type"::"3" then begin //3=DC
                            "GXL Source of Supply" := "GXL Source of Supply"::WH;
                            "GXL 3PL" := Location."GXL 3PL Warehouse";
                        end;
                    end;
                end;
            end;
        }
        modify("Shipment Date")
        {
            trigger OnAfterValidate()
            var
                CalChange: Record "Customized Calendar Change";
                CalendarMgt: Codeunit "Calendar Management";
                TransLT: Text;
            begin
                if "Shipment Date" <> 0D then begin
                    TransLT := GXL_GetTransferLeadTime("Transfer-from Code", "Transfer-to Code", "Shipment Date");
                    Validate("GXL Expected Receipt Date",
                        CalendarMgt.CalcDateBOC(
                            TransLT,
                            "Shipment Date",
                            CalChange."Source Type"::Location, "Transfer-from Code", '',
                            CalChange."Source Type"::Location, "Transfer-to Code", '',
                            true
                        ));
                end;
            end;
        }
        */
        //PS-2143-

    }

    keys
    {
        key(GXLOrderDate; "GXL Order Date") { }
    }



    procedure GXL_InitSupplyChain()
    begin
        if "GXL Order Date" = 0D then
            "GXL Order Date" := WorkDate();

        "GXL Created By User ID" := UserId();
        "GXL Created Date" := Today();
        "GXL Created Time" := Time();
    end;

    procedure GXL_GetTransferLeadTime(LocationCode: Code[10]; TransToCode: Code[10]; OrderDate: Date): Text
    var
        LeadTime: Record "GXL Lead Time";
        OrderRcptDate: Date;
    begin
        if LocationCode = '' then
            exit('0D');
        if TransToCode = '' then
            exit('0D');
        LeadTime.FindTransferLeadTime(LocationCode, TransToCode, OrderDate, OrderRcptDate);
        exit(Format(OrderRcptDate - OrderDate) + 'D');
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
    // << 001
    procedure PerformManualRelease(var TransferHeader: Record "Transfer Header")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin
        NoOfSelected := TransferHeader.Count();
        TransferHeader.SetFilter(Status, '<>%1', TransferHeader.Status::Released);
        NoOfSkipped := NoOfSelected - TransferHeader.Count;
        BatchProcessingMgt.BatchProcess(TransferHeader, Codeunit::"Release Transfer Document", "Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
    end;

    procedure PerformManualReopen(var TransferHeader: Record "Transfer Header")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin
        NoOfSelected := TransferHeader.Count();
        TransferHeader.SetFilter(Status, '<>%1', TransferHeader.Status::Open);
        NoOfSkipped := NoOfSelected - TransferHeader.Count;
        BatchProcessingMgt.BatchProcess(TransferHeader, Codeunit::"GXL Perform Manual Reopen", "Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
    end;
    // << 001
}