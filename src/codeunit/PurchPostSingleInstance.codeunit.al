codeunit 50395 "GXL Purch-Post Single Instance"
{
    SingleInstance = true;

    var
        PurchHeader: Record "Purchase Header";


    procedure SetPurchaseHeader(NewPurchHead: Record "Purchase Header")
    begin
        PurchHeader := NewPurchHead;
    end;

    procedure GetPurchaseHeader(var NewPurchHead: Record "Purchase Header")
    begin
        NewPurchHead := PurchHeader;
    end;

}