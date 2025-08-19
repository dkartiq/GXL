// 001 KDU 28.06.2025 HAR2-397
codeunit 50371 "GXL EDI-Proc Purch Order Resp."
{

    TableNo = "GXL PO Response Header";

    trigger OnRun()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLines: Record "Purchase Line";
        POResponseLines: Record "GXL PO Response Line";
        PurchOrderStatusMgt: Codeunit "GXL SC-Purch. Order Status Mgt";
        CancelOnZeroQuantity: Boolean;
    begin
        PurchaseHeader.RESET();
        PurchaseLines.RESET();

        IF NOT PurchaseHeader.GET(PurchaseHeader."Document Type"::Order, Rec."Order No.") THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text001Txt, Rec."Response Number"));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF PurchaseHeader."GXL Last EDI Document Status" <> PurchaseHeader."GXL Last EDI Document Status"::PO THEN BEGIN
            IF PurchaseHeader."GXL Last EDI Document Status" = PurchaseHeader."GXL Last EDI Document Status"::POX THEN
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text005Txt, Rec."Response Number", PurchaseHeader."No."))
            ELSE
                EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text002Txt, Rec."Response Number"));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        //TODO: Order Status - EDI Process order response, only Placed is accepted
        IF PurchaseHeader."GXL Order Status" <> PurchaseHeader."GXL Order Status"::Placed THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text003Txt, Rec."Response Number"));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        IF NOT PurchaseHeader."GXL Vendor File Sent" THEN BEGIN
            EDIErrorMgt.SetErrorMessage(STRSUBSTNO(Text004Txt, Rec."Response Number"));
            EDIErrorMgt.ThrowErrorMessage();
        END;

        CLEAR(PurchOrderStatusMgt);
        CASE Rec."Response Type" OF
            Rec."Response Type"::Accepted:
                BEGIN
                    PurchOrderStatusMgt.SetEDIOptions(FALSE, TRUE);
                    PurchOrderStatusMgt.ConfirmPurchHeader(PurchaseHeader);
                END;
            Rec."Response Type"::Rejected:
                BEGIN
                    PurchOrderStatusMgt.SetEDIOptions(TRUE, FALSE);
                    PurchOrderStatusMgt.Cancel(PurchaseHeader, 0); //send blank cancel reason
                END;
            Rec."Response Type"::Changed:
                BEGIN
                    CancelOnZeroQuantity := FALSE;
                    IF Rec."Expected Receipt Date" <> PurchaseHeader."Expected Receipt Date" THEN BEGIN
                        PurchaseHeader.VALIDATE("Expected Receipt Date", Rec."Expected Receipt Date");
                        PurchaseHeader.MODIFY();
                    END;

                    POResponseLines.SETRANGE("PO Response Number", Rec."Response Number");
                    IF POResponseLines.FINDSET() THEN
                        REPEAT
                            PurchaseLines.SETRANGE("Document Type", PurchaseLines."Document Type"::Order);
                            PurchaseLines.SETRANGE("Document No.", PurchaseHeader."No.");
                            PurchaseLines.SETRANGE("Line No.", POResponseLines."PO Line No.");
                            IF PurchaseLines.FINDFIRST() THEN //Already checked if all the lines exist with proper handling
                                IF POResponseLines."Item Response Indicator" = 'IR' THEN
                                    POResponseLines.Quantity := 0;
                            IF PurchaseLines.Quantity <> POResponseLines.Quantity THEN BEGIN
                                PurchaseLines.SuspendStatusCheck(TRUE);
                                IF IsCallFromASN THEN
                                    PurchaseLines.SuspendSKUCheck(TRUE);
                                // >> 001
                                //     PurchaseLines.VALIDATE("GXL Confirmed Quantity", POResponseLines.Quantity);
                                // PurchaseLines.MODIFY();
                                PurchaseHeader.CalcFields("GXL ASN Created");
                                if not PurchaseHeader."GXL ASN Created" then begin
                                    PurchaseLines.VALIDATE("GXL Confirmed Quantity", POResponseLines.Quantity);
                                    PurchaseLines.MODIFY();
                                end;
                                // << 001
                            END;
                        UNTIL POResponseLines.NEXT() = 0;

                    IF CancelOnZeroQuantity THEN BEGIN
                        PurchOrderStatusMgt.SetEDIOptions(TRUE, FALSE);
                        PurchOrderStatusMgt.Cancel(PurchaseHeader, 0);
                    END ELSE BEGIN
                        PurchOrderStatusMgt.SetEDIOptions(FALSE, TRUE);
                        PurchOrderStatusMgt.ConfirmPurchHeader(PurchaseHeader);
                    END;
                END;
        END;

        Rec.Status := Rec.Status::Processed;
        Rec.MODIFY();
    end;

    var
        EDIErrorMgt: Codeunit "GXL EDI Error Management";
        IsCallFromASN: Boolean;
        Text001Txt: Label 'Purchase Order for PO Response %1 doesn''t exist.';
        Text002Txt: Label 'Purchase Order has already been confirmed for PO Response %1';
        Text003Txt: Label 'Order has not been placed for PO Response %1';
        Text004Txt: Label 'Vendor File has not been sent yet for PO Response %1';
        Text005Txt: Label 'The Purchase Order Response %1 was not accepted because the Purchase Order %2 has been cancelled.';

    [Scope('OnPrem')]
    procedure SetCallFromASN(BoolCallFromASN: Boolean)
    begin
        IsCallFromASN := BoolCallFromASN;
    end;
}

