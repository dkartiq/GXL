// 001 8.07.2025 KDU HP2-Sprint2
table 50015 "GXL Lead Time"
{
    Caption = 'Lead Time';
    DataClassification = CustomerContent;
    LookupPageId = "GXL Lead Time Setup";
    DrillDownPageId = "GXL Lead Time Setup";

    fields
    {
        field(1; "From Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'From Type';
            OptionMembers = Supplier,Store,WH,Port;
            OptionCaption = 'Supplier,Store,WH,Port';
        }
        field(2; "From Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'From Code';
            TableRelation = if ("From Type" = const(Supplier)) Vendor else
            if ("From Type" = const(Store)) Location where("GXL Location Type" = const("6"))
            else
            if ("From Type" = const(WH)) Location where("GXL Location Type" = const("3"));
        }
        field(3; "To Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'To Type';
            OptionMembers = Supplier,Store,WH,Port;
            OptionCaption = 'Supplier,Store,WH,Port';
        }
        field(4; "To Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'To Code';
            TableRelation = if ("To Type" = const(Supplier)) Vendor else
            if ("To Type" = const(Store)) Location where("GXL Location Type" = const("6"))
            else
            if ("To Type" = const(WH)) Location where("GXL Location Type" = const("3"));
        }
        field(5; "Lead Time"; DateFormula)
        {
            DataClassification = CustomerContent;
            Caption = 'Lead Time';
        }
        field(8; "Lead Time Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Lead Time Type';
            // >> 001
            // OptionMembers = Regular,Clearance,Shipment,Production;
            // OptionCaption = 'Regular,Clearance,Shipment,Production';
            OptionMembers = Regular,Clearance,Shipment,Production,Origin;
            OptionCaption = 'Regular,Clearance,Shipment,Production,Origin';
            // << 001
        }
        field(9; "Last Date Modified"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Last Date Modified';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "From Type", "From Code", "To Type", "To Code", "Lead Time Type")
        {
            Clustered = true;
        }
    }

    var

    trigger OnInsert()
    begin
        "Last Date Modified" := Today();
    end;

    trigger OnModify()
    begin
        "Last Date Modified" := Today();
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;


    procedure FindTransferLeadTime(FromCode: Code[10]; DestinationCode: Code[10]; OrderDate: Date; var OrderReceiptDate: Date)
    var
        Loc: Record Location;
        LeadTime: Record "GXL Lead Time";
        FromType: Option Supplier,Store,WH,Port;
    begin
        //SD,WH,XD,FT
        //Supplier,Store,WH,Port
        OrderReceiptDate := OrderDate;

        if Loc.Get(FromCode) then begin
            Loc.CalcFields("GXL Location Type");
            if Loc."GXL Location Type" = Loc."GXL Location Type"::"3" then
                FromType := FromType::WH
            else
                FromType := FromType::Store;
        end else
            exit;

        LeadTime.SetRange("From Type", FromType);
        LeadTime.SetRange("From Code", FromCode);
        LeadTime.SetRange("To Type", LeadTime."To Type"::Store);
        LeadTime.SetRange("To Code", DestinationCode);
        if LeadTime.FindFirst() then
            OrderReceiptDate := CalcDate(LeadTime."Lead Time", OrderReceiptDate);

    end;
}