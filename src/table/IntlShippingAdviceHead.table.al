table 50358 "GXL Intl. Shipping Advice Head"
{
    Caption = 'Intl. Shipping Advice Header';
    fields
    {
        field(1; "No."; Code[20])
        {

            trigger OnValidate()
            begin
                IF "No." <> xRec."No." THEN BEGIN
                    IntegrationSetup.Get();
                    NoSeriesMgt.TestManual(GetNoSeriesCode());
                END;
            end;
        }
        field(2; "Date Received"; Date)
        {
        }
        field(3; Status; Option)
        {
            Caption = 'Status';
            OptionCaption = 'Imported,Validation Error,Validated,Processing Error,Processed';
            OptionMembers = Imported,"Validation Error",Validated,"Processing Error",Processed;
        }
        field(4; "Order No."; Code[20])
        {
        }
        field(5; "Buy-from Vendor No."; Code[20])
        {
            TableRelation = Vendor;
        }
        field(6; "Vendor Order No."; Code[20])
        {
        }
        field(7; "Vendor Shipment No."; Code[20])
        {
        }
        field(8; "Order Shipping Status"; Option)
        {
            OptionMembers = " ","Booked to Ship","At CFS",Shipped,Arrived;
        }
        field(9; "Delivery Mode"; Option)
        {
            OptionMembers = " ","CFS-CFS","CFS-CY","CY-CY","CY-CFS";
        }
        field(10; "Shipment Method Code"; Code[10])
        {
            TableRelation = "Shipment Method";
        }
        field(11; "Departure Port"; Code[10])
        {
            TableRelation = "GXL Port of Loading";
        }
        field(12; "Vessel Name"; Text[50])
        {
        }
        field(13; "Container No."; Code[20])
        {
        }
        field(14; "Container Type"; Option)
        {
            OptionMembers = " ","20ft","40ft","40ft HC",LCL;
        }
        field(15; "Container Carrier"; Text[50])
        {
        }
        field(16; "CFS Receipt Date"; Date)
        {
        }
        field(17; "Shipping Date"; Date)
        {
        }
        field(18; "Arrival Date"; Date)
        {
        }
        field(20; "Freight Forwarding Agent Code"; Code[20])
        {
            TableRelation = "GXL Freight Forwarder";
        }
        field(21; "EDI File Log Entry No."; Integer)
        {
            TableRelation = "GXL EDI File Log"."Entry No.";
        }
        field(100; "No. Series"; Code[20])
        {
            Caption = 'No. Series';
            Editable = false;
            TableRelation = "No. Series";
        }
        //ERP-NAV Master Data Management +
        field(200; "NAV EDI File Log Entry No."; Integer)
        {
            Caption = 'NAV EDI File Log Entry No.';
            DataClassification = CustomerContent;
        }
        //ERP-NAV Master Data Management -

    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "EDI File Log Entry No.")
        {
        }
        key(Key3; "NAV EDI File Log Entry No.")
        { }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        ShipAdviceLines.SETRANGE("Shipping Advice No.", "No.");
        IF NOT ShipAdviceLines.ISEMPTY() THEN
            ShipAdviceLines.DELETEALL();
    end;

    trigger OnInsert()
    begin
        IF "No." = '' THEN BEGIN
            TestNoSeries();
            "No." := NoSeriesMgt.GetNextNo(GetNoSeriesCode(), TODAY(), TRUE);
        END;
    end;

    var
        ShipAdviceLines: Record "GXL Intl. Shipping Advice Line";
        IntegrationSetup: REcord "GXL Integration Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;


    [Scope('OnPrem')]
    procedure AssistEdit(OldShipAdviceHeader: Record "GXL Intl. Shipping Advice Head"): Boolean
    begin
        IntegrationSetup.GET();
        TestNoSeries();
        IF NoSeriesMgt.SelectSeries(GetNoSeriesCode(), OldShipAdviceHeader."No. Series", "No. Series") THEN BEGIN
            TestNoSeries();
            NoSeriesMgt.SetSeries("No.");
            EXIT(TRUE);
        END;
    end;

    local procedure TestNoSeries(): Boolean
    begin
        IntegrationSetup.TESTFIELD("Intl. Ship. Advice No. Series");
    end;

    local procedure GetNoSeriesCode(): Code[20]
    begin
        EXIT(IntegrationSetup."Intl. Ship. Advice No. Series");
    end;

    //ERP-NAV Master Data Management +
    //Added this for compatibility in case if Int. Shipment Header and/or EDI File Log is synced from NAV
    procedure AddEDIFileLog(): Boolean
    var
        PurchHead: Record "Purchase Header";
        EDIFileLog: Record "GXL EDI File Log";
        EDIDocLog: Record "GXL EDI Document Log";
        EDIProcessMgt: Codeunit "GXL EDI Process Mngt";
    begin
        if ("EDI File Log Entry No." = 0) then begin
            if "NAV EDI File Log Entry No." <> 0 then begin
                EDIFileLog.SetCurrentKey("NAV Entry No.");
                EDIFileLog.SetRange("NAV Entry No.", "NAV EDI File Log Entry No.");
                if EDIFileLog.FindFirst() then begin
                    "EDI File Log Entry No." := EDIFileLog."Entry No.";
                    EDIDocLog.SetCurrentKey("NAV EDI File Log Entry No.");
                    EDIDocLog.SetRange("NAV EDI File Log Entry No.", EDIFileLog."NAV Entry No.");
                    if not EDIDocLog.IsEmpty() then
                        EDIDocLog.ModifyAll("EDI File Log Entry No.", EDIFileLog."Entry No.");
                    exit(true);
                end;
            end;

            if PurchHead.Get(PurchHead."Document Type"::Order, "Order No.") then begin
                "EDI File Log Entry No." := EDIProcessMgt.InsertEDIFileLog3('', 3, 0, '', PurchHead."GXL EDI Vendor Type");
                exit(true);
            end;
        end;
        exit(false);
    end;
    //ERP-NAV Master Data Management -

}

