// 001 KDU 02.07.2025 HP2 Sprint2 new object
report 50045 "Batch Place Purchase Order"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            trigger OnPreDataItem()
            begin
                SetRange("GXL EDI Order", false);
                SETRANGE("GXL Order Status", "GXL Order Status"::Created);
                IF GUIALLOWED THEN BEGIN

                    Window.OPEN(Text001 + STRSUBSTNO(Text002, GETFILTER("Document Type")) + Text004
                                + Text003);
                    TotalRecords := COUNT;
                END
            end;

            trigger OnAfterGetRecord()
            var
                Vendor: Record Vendor;
                EmailManagement: Codeunit "GXL Email Management";
                SCPurchaseOrderStatusMgt: Codeunit "GXL SC-Purch. Order Status Mgt";
                PurchHeader: Record "Purchase Header";
                ReleasePurchaseDocument: Codeunit "Release Purchase Document";
            begin

                IF GUIALLOWED THEN BEGIN
                    Counter += 1;
                    Window.UPDATE(1, "No.");
                    Window.UPDATE(2, ROUND(Counter / TotalRecords * 10000, 1));
                END;
                CLEAR(SCPurchaseOrderStatusMgt);
                PurchHeader.RESET;
                PurchHeader.GET("Document Type", "No.");

                IF Status <> Status::Released THEN
                    ReleasePurchaseDocument.RUN(PurchHeader);

                // >> PSEM.01
                IF Vendor.GET("Purchase Header"."Buy-from Vendor No.") THEN
                    IF ((Vendor."GXL PO Email Address" <> '') OR (Vendor."E-Mail" <> '')) THEN BEGIN
                        //IF EmailManagement.SendPurchaseHeader(PurchHeader,TRUE,FALSE,1) THEN BEGIN
                        //>>pv00.03
                        SCPurchaseOrderStatusMgt.Place(PurchHeader);

                        IF PurchHeader."GXL Order Status" = PurchHeader."GXL Order Status"::Placed THEN
                            EmailManagement.SendPOEmail(PurchHeader, TRUE, FALSE);
                        //<<pv00.03
                        SuccessCounter += 1;
                        //<< pv00.01
                    END ELSE BEGIN
                        //>> pv00.01
                        SCPurchaseOrderStatusMgt.Place(PurchHeader);
                        SuccessCounter += 1;
                        COMMIT;
                    END;
                //END;
            end;

            trigger OnPostDataItem()
            begin

                IF GUIALLOWED THEN
                    Window.CLOSE;

                IF SuccessCounter > 0 THEN BEGIN
                    IF SuccessCounter > 1 THEN
                        MESSAGE(Text000, FORMAT(SuccessCounter), 's.')
                    ELSE
                        MESSAGE(Text000, FORMAT(SuccessCounter), '.');
                END;
            end;
        }
    }
    var
        SendingBehaviour: Option ,"Do Not Prompt User","Prompt User";
        SuccessCounter: Integer;
        Window: Dialog;
        TotalRecords: Integer;
        Counter: Integer;
        Text000: Label 'You have successfully sent %1 email%2';
        Text001: Label 'Placing Purchase Order...\\';
        Text002: Label 'Processing Purchases %1';
        Text003: Label '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        Text004: Label '#1###########\\';
        Text005: Label 'The Document Type %1 is not allowed.';
        Text006: Label 'You must select a Document Type filter.';

}