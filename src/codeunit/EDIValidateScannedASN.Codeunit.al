codeunit 50379 "GXL EDI-Validate Scanned ASN"
{
    TableNo = "GXL ASN Header";

    trigger OnRun()
    begin
        ASNHeader := Rec;

        TempScanDiscrepancy.Reset();
        TempScanDiscrepancy.DeleteAll();

        CheckASNDiscrepancy();
        SendASNScanDiscrepancy();

        TempScanDiscrepancy.Reset();
        TempScanDiscrepancy.DeleteAll();
    end;

    var
        TempScanDiscrepancy: Record "GXL ASN Scanning Discrepancy" temporary;
        ASNHeader: Record "GXL ASN Header";


    [Scope('OnPrem')]
    procedure CheckASNDiscrepancy()
    var
        ASNLevel3Line: Record "GXL ASN Level 3 Line";
        ItemNo: Code[20];
        ItemQuantityConfirmed: Decimal;
        ItemQuantityScanned: Integer;
    begin
        ItemNo := '';
        ItemQuantityConfirmed := 0;
        ItemQuantityScanned := 0;

        ASNLevel3Line.Reset();
        ASNLevel3Line.SETCURRENTKEY("Document Type", "Document No.", "Level 3 Code");
        ASNLevel3Line.SETRANGE("Document Type", ASNHeader."Document Type");
        ASNLevel3Line.SETRANGE("Document No.", ASNHeader."No.");
        IF ASNLevel3Line.FindSet() THEN
            REPEAT

                IF ItemNo <> ASNLevel3Line."Level 3 Code" THEN BEGIN

                    IF ItemNo <> '' THEN //not first record
                        InsertASNScanDiscrepancy(ItemNo, ItemQuantityConfirmed, ItemQuantityScanned);

                    ItemNo := ASNLevel3Line."Level 3 Code";
                    ItemQuantityConfirmed := ASNLevel3Line.Quantity;
                    ItemQuantityScanned := ASNLevel3Line."Quantity Received";

                END ELSE BEGIN

                    ItemQuantityConfirmed += ASNLevel3Line.Quantity;
                    ItemQuantityScanned += ASNLevel3Line."Quantity Received";

                END;

            UNTIL ASNLevel3Line.Next() = 0;

        InsertASNScanDiscrepancy(ItemNo, ItemQuantityConfirmed, ItemQuantityScanned);
    end;

    [Scope('OnPrem')]
    procedure SendASNScanDiscrepancy()
    var
        EDIEmailMgt: Codeunit "GXL EDI Email Management";
    begin
        EDIEmailMgt.SendASNScanValidationEmail(ASNHeader, TempScanDiscrepancy, GetLastErrorText());
    end;

    local procedure InsertASNScanDiscrepancy(InputItemNo: Code[20]; InputConfirmedQuantity: Decimal; InputScannedQuantity: Decimal)
    begin
        IF InputScannedQuantity <= InputConfirmedQuantity THEN
            EXIT;

        TempScanDiscrepancy.Init();
        TempScanDiscrepancy."ASN Document Type" := ASNHeader."Document Type";
        TempScanDiscrepancy."ASN Document No." := ASNHeader."No.";
        TempScanDiscrepancy."Item No." := InputItemNo;
        TempScanDiscrepancy."Quantity Confirmed" := InputConfirmedQuantity;
        TempScanDiscrepancy."Quantity Scanned" := InputScannedQuantity;
        TempScanDiscrepancy.Difference := InputScannedQuantity - InputConfirmedQuantity;
        TempScanDiscrepancy.Insert();
    end;
}

