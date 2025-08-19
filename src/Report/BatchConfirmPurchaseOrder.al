// 001 02.07.2025 KDU HP2-Sprint2 New Object
report 50046 "Batch Confirm Purchase Order"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    ProcessingOnly = true;
    UseRequestPage = false;
    UseSystemPrinter = false;

    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            trigger OnPreDataItem()
            begin
                SetRange("GXL 3PL File Sent", false); // >> HP2-Sprint2 <<
                SETRANGE("GXL Order Status", "GXL Order Status"::Placed);
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

                // IF ("GXL EDI Order" OR ("GXL EDI Vendor Type" = "GXL EDI Vendor Type"::VAN)) AND ("GXL PO Placed Date" >= TODAY) THEN
                //     CurrReport.SKIP;
                // << pv00.02

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
                // >> HP2-SPRINT2
                if PurchHeader."GXL EDI Order" then
                    SCPurchaseOrderStatusMgt.ConfirmPurchHeaderforEDI(PurchHeader)
                else
                    // << HP2-SPRINT2
                    SCPurchaseOrderStatusMgt.ConfirmPurchHeader(PurchHeader);
                SuccessCounter += 1;

                IF PurchHeader."GXL Order Status" = PurchHeader."GXL Order Status"::Confirmed THEN BEGIN
                    TempPurchaseHeader.RESET;
                    TempPurchaseHeader.INIT;
                    TempPurchaseHeader.TRANSFERFIELDS("Purchase Header");
                    TempPurchaseHeader.INSERT;
                END;
                // << PSSC.00
            end;

            trigger OnPostDataItem()
            var
                BodyText: array[2] of Text;
                ReturnText: Text;
                TableCSS: Label '<style>table,th,td{border=1px solid black;text-align:left;}</style>';
                StartTable: Label '<table border="1">';
                EndTable: Label '</table>';
                StartHeaderData: Label '<th>';
                EndHeaderData: Label '</th>';
                StartRow: Label '<tr>';
                EndRow: Label '</tr>';
                StartData: Label '<td>';
                EndData: Label '</td>';
                ParagraphStart: Label '<p>';
                ParagraphEnd: Label '</p>';
            begin

                IF GUIALLOWED THEN BEGIN
                    Window.CLOSE;
                    IF SuccessCounter > 0 THEN BEGIN
                        MESSAGE(Text000, FORMAT(SuccessCounter));
                    END;
                END;
                CLEAR(EmailManagement);
                TempPurchaseHeader.RESET;
                IF TempPurchaseHeader.COUNT > 0 THEN
                    ReturnText := '';
                IF TempPurchaseHeader.FINDFIRST THEN BEGIN

                    ReturnText += TableCSS;

                    REPEAT
                        IF BodyText[1] = '' THEN BEGIN
                            BodyText[1] := ParagraphStart + Text017 + ParagraphEnd;
                            BodyText[1] += StartTable;
                            BodyText[1] += StartRow;
                            BodyText[1] += StartHeaderData + TempPurchaseHeader.FIELDCAPTION("No.") + EndHeaderData;
                            BodyText[1] += StartHeaderData + TempPurchaseHeader.FIELDCAPTION("Buy-from Vendor No.") + EndHeaderData;
                            BodyText[1] += EndRow;
                        END;

                        BodyText[2] += StartRow;
                        BodyText[2] += StartData + TempPurchaseHeader."No." + EndData;
                        BodyText[2] += StartData + TempPurchaseHeader."Buy-from Vendor No." + EndData;
                        BodyText[2] += EndRow;


                    UNTIL TempPurchaseHeader.NEXT = 0;
                END;

                IF BodyText[2] <> '' THEN
                    BodyText[2] += EndTable;

                ReturnText += BodyText[1] + BodyText[2];
                //ERROR (ReturnText);
                IF ReturnText <> '' THEN
                    IF EmailManagement.SendEmailConfirmPurchaseOrders(TRUE, FALSE, 1, ReturnText) THEN;

            end;
        }
    }
    var
        SendingBehaviour: Option ,"Do Not Prompt User","Prompt User";
        SuccessCounter: Integer;
        Window: Dialog;
        TotalRecords: Integer;
        Counter: Integer;
        TempPurchaseHeader: Record "Purchase Header" temporary;
        EmailManagement: Codeunit "GXL Email Management";
        Text000: Label 'You have successfully confirmed %1';
        Text001: Label 'Confirming Purchase Order...\\';
        Text002: Label 'Processing Purchases %1';
        Text003: Label '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        Text004: Label '#1###########\\';
        Text005: Label 'The Document Type %1 is not allowed.';
        Text006: Label 'You must select a Document Type filter.';
        Text017: Label 'Confirmed Purchase Orders';
}