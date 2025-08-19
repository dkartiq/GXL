/// <summary>
/// PS-2523 VET Clinic transfer order
/// </summary>
codeunit 50276 "GXL VET TransferOrder-PostRcpt"
{
    TableNo = "GXL PDA-TransShpt Process Buff";

    trigger OnRun()
    var
        TransRcptHead: Record "Transfer Receipt Header";
    begin
        ClearAll();

        PDATransShptProcessBuff := Rec;
        PDATransShptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransShptProcessBuff.SetRange("No.", Rec."No.");
        PDATransShptProcessBuff.FindSet();

        //Transfer has been posted manually, not via batch job process
        if not TransHead.Get(PDATransShptProcessBuff."No.") then begin
            TransRcptHead.SetCurrentKey("Transfer Order No.");
            TransRcptHead.SetRange("Transfer Order No.", PDATransShptProcessBuff."No.");
            TransRcptHead.FindLast();
            ReceiptNo := TransRcptHead."No.";
            exit;
        end;

        TransHead."Shipment Date" := PDATransShptProcessBuff."Shipment Date";
        TransHead."Posting Date" := WorkDate();
        TransHead."GXL MIM User ID" := Rec."MIM User ID";

        ProcessLines();
        ReceiveTransferOrder();
        Commit();

        Rec := PDATransShptProcessBuff;
    end;

    var
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        TransHead: Record "Transfer Header";
        ReceiptNo: Code[20];

    local procedure ProcessLines()
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.Reset();
        TransferLine.SetRange("Document No.", PDATransShptProcessBuff."No.");
        TransferLine.SetRange("Derived From Line No.", 0);
        TransferLine.SetFilter("Qty. in Transit", '<>0');
        if TransferLine.FindSet() then
            repeat
                if TransferLine."Qty. to Receive" <> TransferLine."Qty. in Transit" then begin
                    TransferLine.Validate("Qty. to Receive", TransferLine."Qty. in Transit");
                    TransferLine.Modify();
                end;
            until TransferLine.Next() = 0;
    end;


    local procedure ReceiveTransferOrder()
    var
        TransOrderPostReceipt: Codeunit "TransferOrder-Post Receipt";
    begin
        TransOrderPostReceipt.SetHideValidationDialog(true);
        TransOrderPostReceipt.Run(TransHead);
        ReceiptNo := TransHead."Last Receipt No.";
    end;

    procedure GetReceiptNo(var NewReceiptNo: Code[20])
    begin
        NewReceiptNo := ReceiptNo;
    end;
}