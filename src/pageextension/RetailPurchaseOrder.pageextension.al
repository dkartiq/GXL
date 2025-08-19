pageextension 50352 "GXL Retail Purchase Order" extends "LSC Retail Purchase Order"
{
    // 001  06.04.2022  KDU  GX-202201 ERP-355 Blocked sending order to vendor and printing purchase order report.
    layout
    {
        addlast(General)
        {
            field("GXL Trade PO"; Rec.IsTradePO(Rec."No.")) { Editable = false; }
        }
    }
    actions
    {
        modify("Print")
        {
            Enabled = Rec.Status = Rec.Status::Released;
        }
        modify("&Print")
        {
            Enabled = Rec.Status = Rec.Status::Released;
        }
        modify(Send)
        {
            Enabled = Rec.Status = Rec.Status::Released;
        }
    }
}