pageextension 50353 "GXL Purchase Order List" extends "Purchase Order List"
{
    // 002  18.07.2025  BY   HP2-Sprint3-Changes HAR2-69
    // 001  06.04.2022  KDU  GX-202201 ERP-355 Blocked sending order to vendor and printing purchase order report.\
    // 002  22.07.2025  by   HAR2-406  Bulk Release, Placement, Status update of PORs and TORs
    // 001  06.04.2022  KDU  GX-202201 ERP-355 Blocked sending order to vendor and printing purchase order report.
    actions
    {
        modify(Print)
        {
            Enabled = Rec.Status = Rec.Status::Released;
        }
        modify(Send)
        {
            Enabled = Rec.Status = Rec.Status::Released;
        }
        // >> 002
        addlast(processing)
        {
            action(Export)
            {
                ApplicationArea = all;
                caption = 'Export PO Lines';
                Image = Export;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    PurchHeader: Record "Purchase Header";
                    PurchLine: Record "Purchase Line";
                    RecRef: RecordRef;
                    SelectionFilterMgmt: Codeunit "SelectionFilterManagement";
                    ItemFilter: text;
                begin
                    CurrPage.SetSelectionFilter(PurchHeader);
                    RecRef.GETTABLE(PurchHeader);
                    ItemFilter := SelectionFilterMgmt.GetSelectionFilter(RecRef, PurchHeader.FIELDNO("No."));
                    PurchLine.ExportPurchLines(ItemFilter);
                end;
            }
            action(Import)
            {
                ApplicationArea = all;
                caption = 'Import PO Lines';
                Image = Import;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                trigger OnAction()
                var
                    PurchHeader: Record "Purchase Header";
                    PurchLine: Record "Purchase Line";
                    RecRef: RecordRef;
                    SelectionFilterMgmt: Codeunit "SelectionFilterManagement";
                    ItemFilter: text;
                begin
                    CurrPage.SetSelectionFilter(PurchHeader);
                    RecRef.GETTABLE(PurchHeader);
                    ItemFilter := SelectionFilterMgmt.GetSelectionFilter(RecRef, PurchHeader.FIELDNO("No."));
                    PurchLine.ImportPurchaseLinesFromExcel(PurchHeader);

                end;
            }
            // >> 002 
            action("Change Status")
            {
                ApplicationArea = All;
                Caption = 'Change Status';
                Image = ChangeStatus;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                var
                    PurchHdr: Record "Purchase Header";
                begin
                    CurrPage.SetSelectionFilter(PurchHdr);
                    Rec.PerformOrderStatusChange(PurchHdr);
                end;
            }
            // << 002 
        }
    }
}
