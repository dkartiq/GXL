codeunit 50273 "GXL PDA-EDI Audit ASN"
{
    TableNo = "GXL ASN Header";

    trigger OnRun()
    var
        EDIFunctions: Codeunit "GXL EDI Functions Library";
    begin
        EDIFunctions.AuditPurchaseOrder(Rec."Purchase Order No.");
    end;

}