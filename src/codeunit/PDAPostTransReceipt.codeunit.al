codeunit 50256 "GXL PDA-Post Trans Receipt"
{
    TableNo = "GXL PDA-TransRcpt Process Buff";

    trigger OnRun()
    begin
        ClearAll();

        PDATransRcptProcessBuff := Rec;
        PDATransRcptProcessBuff.SetRange("No.", Rec."No.");
        PDATransRcptProcessBuff.FindSet();

        TransHead.Get(PDATransRcptProcessBuff."No.");
        TransHead."Receipt Date" := PDATransRcptProcessBuff."Receipt Date";
        TransHead."Posting Date" := WorkDate();
        //PS-2046+
        TransHead."GXL MIM User ID" := Rec."MIM User ID";
        //PS-2046-

        RunCode();
        Commit();

        Rec := PDATransRcptProcessBuff;
    end;

    var
        TransHead: Record "Transfer Header";
        PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff";


    local procedure RunCode()
    begin
        ResetTransferLines();
        ProcessLines();
        ReceiveTransferOrder();
    end;


    local procedure ResetTransferLines()
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.Reset();
        TransferLine.SetRange("Document No.", PDATransRcptProcessBuff."No.");
        TransferLine.SetRange("Derived From Line No.", 0);
        TransferLine.SetFilter("Qty. in Transit", '<>0');
        if TransferLine.FindSet() then
            repeat
                if TransferLine."Qty. to Receive" <> 0 then begin
                    TransferLine.Validate("Qty. to Receive", 0);
                    TransferLine.Modify();
                end;
            until TransferLine.Next() = 0;
    end;

    local procedure ProcessLines()
    var
        TransferLine: Record "Transfer Line";
        QtyToReceive: Decimal;
    begin
        if PDATransRcptProcessBuff.FindSet() then
            repeat
                if TransferLine.Get(PDATransRcptProcessBuff."No.", PDATransRcptProcessBuff."Line No.") then begin
                    if TransferLine."Qty. in Transit" > PDATransRcptProcessBuff.Quantity then
                        QtyToReceive := PDATransRcptProcessBuff.Quantity
                    else
                        QtyToReceive := TransferLine."Qty. in Transit";
                    TransferLine.Validate("Qty. to Receive", QtyToReceive);
                    TransferLine.Modify();
                end;
            until PDATransRcptProcessBuff.Next() = 0;
    end;

    local procedure ReceiveTransferOrder()
    var
        TransferOrderPostReceipt: Codeunit "TransferOrder-Post Receipt";
    begin
        TransferOrderPostReceipt.SetHideValidationDialog(true);
        TransferOrderPostReceipt.Run(TransHead);
    end;

}