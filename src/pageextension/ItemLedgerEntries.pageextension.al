pageextension 50014 "GXL Item Ledger Entries" extends "Item Ledger Entries"
{
    layout
    {
        addbefore("Entry No.")
        {
            //PS-2046+
            field("GXL MIM User ID"; Rec."GXL MIM User ID")
            {
                ApplicationArea = All;
            }
            //PS-2046-
        }
    }

    trigger OnOpenPage()
    begin
        GXL_LimitUserAccess(); //PS-2155
    end;

    //PS-2155+
    local procedure GXL_LimitUserAccess()
    var
        RetailUser: Record "LSC Retail User";
        Store: Record "LSC Store";
    begin
        if not RetailUser.Get(UserId()) then
            Clear(RetailUser);
        if RetailUser."Store No." <> '' then begin
            Rec.SetCurrentKey("Location Code", "Item No.", "Posting Date");
            Rec.FilterGroup(2);
            if RetailUser."Location Code" <> '' then begin
                Rec.SetRange("Location Code", RetailUser."Location Code");
            end else begin
                if Store.Get(RetailUser."Store No.") then begin
                    Rec.SetRange("Location Code", Store."Location Code");
                end else begin
                    Rec.SetRange("Location Code", RetailUser."Store No.");
                end;
            end;
            Rec.FilterGroup(0);
        end;
    end;
    //PS-2155-

}