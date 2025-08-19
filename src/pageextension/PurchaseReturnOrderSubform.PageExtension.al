pageextension 50054 "Purchase Return Order Subform" extends "Purchase Return Order Subform"
{
    // >> LCB-13
    trigger OnDeleteRecord(): Boolean
    var
        PurchaseEventMgmt: Codeunit "GXL Purchase Events Mgt.";
    begin
        PurchaseEventMgmt.CheckAndUpdateSendEmailToVendorOnDeleteLine(Rec);
    end;
    // << LCB-13
}
