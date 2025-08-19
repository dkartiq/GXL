/* Change Log
    PS-2521: Limit user access by store
    PS-2524: Add Member No/Name
*/
pageextension 50100 "GXL Transaction Register" extends "LSC Transaction Register"
{
    layout
    {
        addafter("Transaction No.")
        {
            field("GXL Magento WebOrder Trans. ID"; Rec."GXL Magento WebOrder Trans. ID")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        //PS-2524+
        addbefore("Customer No.")
        {
            // >> LCB-463
            field("Re-Submit to Bloyal"; Rec."Re-Submit to Bloyal")
            {
                ApplicationArea = All;
                Editable = false;
            }
            // << LCB-463
            field("GXL Member Card No."; Rec."Member Card No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
            field("GXL Member Name"; Rec."Member name")
            {
                ApplicationArea = All;
            }
        }
        //PS-2524-
    }

    // >> LCB-463
    actions
    {
        addafter("&Move Trans. to New Shift")
        {
            action("ReSubmit to Bloyal Action")
            {
                Caption = 'Re-Submit to Bloyal';
                Image = ExportReceipt;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    TransHeader: Record "LSC Transaction Header";
                begin
                    CurrPage.SetSelectionFilter(TransHeader);
                    if Confirm(StrSubstNo('Are you sure you want to re-submit the "%1" selected records?', TransHeader.Count)) then
                        TransHeader.ModifyAll("Re-Submit to Bloyal", true);
                end;
            }
            action("Cancel ReSubmit to Bloyal")
            {
                Caption = 'Cancel Re-Submit to Bloyal';
                Image = CancelLine;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                PromotedIsBig = true;
                ApplicationArea = All;
                trigger OnAction()
                var
                    TransHeader: Record "LSC Transaction Header";
                begin
                    CurrPage.SetSelectionFilter(TransHeader);
                    if Confirm(StrSubstNo('Are you sure you want to cancel re-submit of the "%1" selected records?', TransHeader.Count)) then
                        TransHeader.ModifyAll("Re-Submit to Bloyal", false);
                end;
            }
        }
    }
    // << LCB-463

    trigger OnOpenPage()
    begin
        //PS-2521+        
        GXL_LimitUserAccess();
        //PS-2521-
    end;

    //PS-2521+
    local procedure GXL_LimitUserAccess()
    var
        RetailUser: Record "LSC Retail User";
    begin
        if not RetailUser.Get(UserId()) then
            Clear(RetailUser);
        if RetailUser."Store No." <> '' then begin
            Rec.FilterGroup(2);
            Rec.SetRange("Store No.", RetailUser."Store No.");
            Rec.FilterGroup(0);
        end;
    end;
    //PS-2521-

}