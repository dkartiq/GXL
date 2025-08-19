pageextension 50002 "GXL Value Entries" extends "Value Entries"
{
    layout
    {
        addbefore("Return Reason Code")
        {
            field("GXL Reason Code"; Rec."Reason Code")
            {
                ApplicationArea = All;
            }
        }
    }

    trigger OnOpenPage()
    begin
        GXL_LimitUserAccess(); //PS-2155
    end;

    //PS-2155+
    local procedure GXL_LimitUserAccess()
    var
        RetailUser: Record "lsc Retail User";
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