pageextension 50030 "GXL Purch. Cr. Memo Subform" extends "Purch. Cr. Memo Subform"
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
