pageextension 50020 "GXL Retail Purch Order Store" extends "LSC Retail Purch. Order Store"
{
    // 002  28.07.2025  BY  HAR2-421 Bulk Release and Placement of POI
    /*Change Log
        PS-2344: View closed orders
    */
    // 001  06.04.2022  KDU  GX-202201 ERP-355 Blocked sending order to vendor and printing purchase order report.
    layout
    {
        addbefore("Store No.")
        {
            field("GXL Expected Receipt Date"; Rec."Expected Receipt Date")
            {
                ApplicationArea = All;
            }
        }
    }
    // >> 001
    actions
    {
        modify("print")
        {
            Enabled = rec.Status = rec.Status::Released;
        }
        // >> 002
        modify(Release)
        {
            Visible = false;
            Enabled = false;
        }
        modify(Reopen)
        {
            Visible = false;
            Enabled = false;
        }
        addfirst(Action10)
        {
            action(Releases)
            {
                ApplicationArea = Suite;
                Caption = 'Re&lease';
                Image = ReleaseDoc;
                ShortCutKey = 'Ctrl+F9';
                ToolTip = 'Release the document to the next stage of processing. You must reopen the document before you can make changes to it.';

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    CurrPage.SetSelectionFilter(PurchaseHeader);
                    Rec.PerformsManualRelease(PurchaseHeader);
                end;
            }
            action(Reopens)
            {
                ApplicationArea = Suite;
                Caption = 'Re&open';
                Image = ReOpen;
                ToolTip = 'Reopen the document to change it after it has been approved. Approved documents have the Released status and must be opened before they can be changed';

                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    CurrPage.SetSelectionFilter(PurchaseHeader);
                    Rec.PerformsManualReopen(PurchaseHeader);
                end;
            }
        }
        addlast(navigation)
        {
            action("Change Order Status")
            {
                ApplicationArea = All;
                Caption = 'Change Order Status';
                Image = ChangeStatus;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    PurchHdr: Record "Purchase Header";
                begin
                    PurchHdr.SetRecFilter();
                    Rec.PerformOrderStatusChange(PurchHdr);
                end;
            }
        }
        // << 002
        // << 001
    }
}