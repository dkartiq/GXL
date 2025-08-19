// 003 23.07.2025 BY  HAR2-406 Added action Release and Reopen
// 003 14.08.2025 BY HP2-Sprint2-Changes
// 002 19.04.2024 KDU HP-2346 New function added to pick the SITE nae
// 001 22-03-2024 KDU HP-2346 Filter added, new column last shipment no added
pageextension 50070 "Transfer Orders" extends "Transfer Orders"
{
    layout
    {
        addlast(Control1)
        {
            // >> 003
            field("GXL RMS ID"; Rec."GXL RMS ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the RMS ID field.', Comment = '%';
            }
            field("GXL RMS Transfer No."; Rec."GXL RMS Transfer No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the RMS Transfer No. field.', Comment = '%';
            }
            // << 003
            field("Last Shipment No."; Rec."Last Shipment No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Last Shipment No. field.';
            }
            // >> 003
            field("GXL Order Status"; Rec."GXL Order Status")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the Order Status field.', Comment = '%';
            }
            field("GXL LSC Received "; Rec."GXL LSC Received ")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the LSC Received field.', Comment = '%';
            }
            field("GXL RMS Worksheet ID"; Rec."GXL RMS Worksheet ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the RMS Worksheet ID field.', Comment = '%';
            }
            // << 003
            // >> 002
            field(SiteName; GetSiteID())
            {
                ApplicationArea = All;
                Caption = 'Site Name';
                Editable = false;
            }
            // << 002
        }
    }
    // >> 002
    // << 003
    actions
    {
        modify("Re&lease")
        {
            Visible = false;
            Enabled = false;
        }
        modify("Reo&pen")
        {
            Visible = false;
            Enabled = false;
        }
        addfirst(processing)
        {
            action("Re&leases")
            {
                ApplicationArea = Location;
                Caption = 'Re&lease';
                Image = ReleaseDoc;
                ShortCutKey = 'Ctrl+F9';
                ToolTip = 'Release the document to the next stage of processing. You must reopen the document before you can make changes to it.';
                trigger OnAction()
                var
                    TransferHeader: Record "Transfer Header";
                begin
                    CurrPage.SetSelectionFilter(TransferHeader);
                    rec.PerformManualRelease(TransferHeader);
                end;
            }
            action("Reo&pens")
            {
                ApplicationArea = Location;
                Caption = 'Reo&pen';
                Image = ReOpen;
                ToolTip = 'Reopen the transfer order after being released for warehouse handling.';
                trigger OnAction()
                var
                    TransferHeader: Record "Transfer Header";
                begin
                    CurrPage.SetSelectionFilter(TransferHeader);
                    Rec.PerformManualReopen(TransferHeader);
                end;
            }
        }
    }
    // << 003
    procedure GetSiteID(): Text
    var
        DimSetEntryL: Record "Dimension Set Entry";
    begin
        DimSetEntryL.SetRange("Dimension Set ID", Rec."Dimension Set ID");
        DimSetEntryL.SetRange("Dimension Value Code", Rec."Shortcut Dimension 2 Code");
        if DimSetEntryL.FindFirst() then begin
            DimSetEntryL.CalcFields("Dimension Value Name");
            exit(DimSetEntryL."Dimension Value Name");
        end;
    end;
    // << 002
    trigger OnOpenPage()
    var
        RetailUserL: Record "LSC Retail User";
        StoreL: Record "LSC Store";
    begin

        if RetailUserL.Get(UserId) then
            if StoreL.IsStore(RetailUserL."Store No.") then begin
                Rec.FilterGroup(2);
                Rec.SetFilter("Last Shipment No.", '>%1', '');
                Rec.SetFilter("LSC Store-to", RetailUserL."Store No.");
                Rec.FilterGroup(0);
            end;
    end;

}
