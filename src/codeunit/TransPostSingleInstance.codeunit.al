codeunit 50001 "GXL TransPost-SingleInstance"
{
    SingleInstance = true;

    var
        TransferHeader: Record "Transfer Header";

    procedure SetTransferHeader(NewTransferHeader: Record "Transfer Header")
    begin
        TransferHeader := NewTransferHeader;
    end;

    procedure GetTransferHeader(var NewTransferHeader: Record "Transfer Header")
    begin
        NewTransferHeader := TransferHeader;
    end;

    procedure ClearTransferHeader()
    begin
        Clear(TransferHeader);
    end;

}