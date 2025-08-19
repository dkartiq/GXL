report 50352 "GXL Audit Mgmt"
{
    Caption = 'Audit Mgmt';
    ProcessingOnly = true;
    UsageCategory = Administration;
    ApplicationArea = All;

    dataset
    {
        dataitem(Store; "LSC Store")
        {
            DataItemTableView = SORTING("GXL Closed Date", "GXL Location Type", "GXL Audit Count") WHERE("GXL Location Type" = FILTER("6"), "GXL Closed Date" = FILTER(0D));

            trigger OnAfterGetRecord()
            var
                TransHeader: Record "Transfer Header";
                RecLoc: Record "LSC Store";
                AuditCount: Integer;
            begin
                IF (Store."GXL Open Date" >= WorkDate())
                THEN
                    CurrReport.Skip();

                IF WorkDate() >= Store."GXL Next Audit Date" THEN BEGIN
                    Store."GXL Audit Date" := WorkDate();
                    Store."GXL Next Audit Date" := CALCDATE('<CM+1D>', WorkDate());
                    Store."GXL Audit Count" := 0;
                    Modify();
                END;

                IF (Store."GXL Audit Count" = SupplySetup."Audits per Month")
                THEN
                    CurrReport.Skip();

                IF WorkDate() < Store."GXL Next Audit Date" THEN BEGIN
                    Store."GXL Audit Date" := WorkDate();
                END;

                AuditCount := 0;


                FlagNextPurchaseOrderForAudit(AuditCount, "No.");
                TransHeader.Reset();
                TransHeader.SetRange("LSC Store-to", "No.");
                TransHeader.SETRANGE("GXL Order Status", TransHeader."GXL Order Status"::Confirmed);
                TransHeader.SETRANGE("GXL Audit Flag", FALSE);
                IF TransHeader.FindFirst() THEN BEGIN
                    TransHeader."GXL Audit Flag" := TRUE;
                    TransHeader.Modify();
                    AuditCount += 1;
                END;

                IF AuditCount > 0 THEN BEGIN
                    RecLoc.Reset();
                    RecLoc.GET("No.");
                    RecLoc."GXL Audit Count" += 1;
                    RecLoc.Modify();
                END;
            end;

            trigger OnPreDataItem()
            begin
                SupplySetup.GET();
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    var
        SupplySetup: Record "GXL Integration Setup";
        CalledFromEDI: Boolean;
        PurchaseOrderNo: Code[20];
        VendorNo: Code[20];


    [Scope('OnPrem')]
    procedure SetEDIOptions(CalledFromEDINew: Boolean; PurchaseOrderNoNew: Code[20]; VendorNoNew: Code[20])
    begin
        CalledFromEDI := CalledFromEDINew;
        PurchaseOrderNo := PurchaseOrderNoNew;
        VendorNo := VendorNoNew;
    end;

    [Scope('OnPrem')]
    procedure FlagNextPurchaseOrderForAudit(var AuditCount: Integer; StoreNo: Code[10])
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SETRANGE("Document Type", PurchaseHeader."Document Type"::Order);
        PurchaseHeader.SetRange("LSC Store No.", StoreNo);
        //TODO: Order Status - Audit purchase order
        PurchaseHeader.SETRANGE("GXL Order Status", PurchaseHeader."GXL Order Status"::Confirmed);
        PurchaseHeader.SETRANGE("GXL Audit Flag", FALSE);
        IF CalledFromEDI THEN BEGIN
            PurchaseHeader.SETFILTER("Buy-from Vendor No.", VendorNo);
            PurchaseHeader.SETFILTER("No.", '%1..', PurchaseOrderNo);
        END;
        IF PurchaseHeader.FindFirst() THEN BEGIN
            PurchaseHeader."GXL Audit Flag" := TRUE;
            AuditCount += 1;
            PurchaseHeader.Modify();
        END;
    end;
}

