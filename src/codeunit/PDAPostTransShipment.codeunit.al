codeunit 50254 "GXL PDA-Post Trans Shipment"
{
    TableNo = "GXL PDA-TransShpt Process Buff";

    trigger OnRun()
    begin
        ClearAll();

        PDATransShptProcessBuff := Rec;
        PDATransShptProcessBuff.SetCurrentKey("No.", "Line No.");
        PDATransShptProcessBuff.SetRange("No.", Rec."No.");
        PDATransShptProcessBuff.FindSet();

        TransHead.Get(PDATransShptProcessBuff."No.");
        TransHead."Shipment Date" := PDATransShptProcessBuff."Shipment Date";
        TransHead."Posting Date" := WorkDate();
        //PS-2046+
        TransHead."GXL MIM User ID" := Rec."MIM User ID";
        //PS-2046-

        RunCode();
        Commit();

        Rec := PDATransShptProcessBuff;
    end;

    var
        TransHead: Record "Transfer Header";
        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
        ShipmentNo: Code[20];

    local procedure RunCode()
    begin
        ResetTransferLines();
        ProcessLines();
        ShipTransferOrder();
    end;


    local procedure ResetTransferLines()
    var
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.Reset();
        TransferLine.SetRange("Document No.", PDATransShptProcessBuff."No.");
        TransferLine.SetRange("Derived From Line No.", 0);
        TransferLine.SetFilter("Outstanding Quantity", '<>0');
        if TransferLine.FindSet() then
            repeat
                if TransferLine."Qty. to Ship" <> 0 then begin
                    TransferLine.Validate("Qty. to Ship", 0);
                    TransferLine.Modify();
                end;
            until TransferLine.Next() = 0;
    end;

    local procedure ProcessLines()
    var
        TransferLine: Record "Transfer Line";
        QtyToShip: Decimal;
    begin
        if PDATransShptProcessBuff.FindSet() then
            repeat
                if TransferLine.Get(PDATransShptProcessBuff."No.", PDATransShptProcessBuff."Line No.") then begin
                    if TransferLine."Outstanding Quantity" > PDATransShptProcessBuff.Quantity then
                        QtyToShip := PDATransShptProcessBuff.Quantity
                    else
                        QtyToShip := TransferLine."Outstanding Quantity";
                    TransferLine.Validate("Qty. to Ship", QtyToShip);
                    TransferLine.Modify();
                end;
            until PDATransShptProcessBuff.Next() = 0;
    end;

    local procedure ShipTransferOrder()
    var
        TransferOrderPostShipment: Codeunit "TransferOrder-Post Shipment";
    begin
        TransferOrderPostShipment.SetHideValidationDialog(true);
        TransferOrderPostShipment.Run(TransHead);
        ShipmentNo := TransHead."Last Shipment No."; //PS-2523 VET Clinic transfer order +
    end;

    //PS-2523 VET Clinic transfer order +
    procedure GetShipmentNo(var NewShipmentNo: Code[20])
    begin
        NewShipmentNo := ShipmentNo;
    end;
    //PS-2523 VET Clinic transfer order +
}
