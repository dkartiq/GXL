pageextension 50026 "GXL TransactionInfocodeEntries" extends "LSC Trans. Infocode Entries"
{
    /*Change Log
        PS-1951
        PS-2625: 02-08-2021
    */

    layout
    {
        addafter("Staff ID")
        {
            //PS-2625 +
            field("GXL GXLStaffName"; GXLStaffName)
            {
                ApplicationArea = All;
                Caption = 'Staff Name';
                Editable = false;
            }
            //PS-2625 -
        }
        addafter(Subcode)
        {
            field("GXL GXLItemDescription"; GXLItemDesc)
            {
                ApplicationArea = All;
                Caption = 'Item Description';
                Editable = false;
            }
            //PS-2625 +
            field("GXL GXLSubcodeDesc"; GXLSubcodeDesc)
            {
                ApplicationArea = All;
                Caption = 'Reason Code';
                Editable = false;
            }
            //PS-2625 -
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        Clear(GXLItemDesc);
        if Rec."Transaction Type" = Rec."Transaction Type"::"Sales Entry" then begin
            if (GXLTransSalesEntry."Store No." <> Rec."Store No.") or (GXLTransSalesEntry."POS Terminal No." <> REC."POS Terminal No.") or
                (GXLTransSalesEntry."Transaction No." <> Rec."Transaction No.") or (GXLTransSalesEntry."Line No." <> REC."Line No.")
            then begin
                GXLTransSalesEntry.SetRange("Store No.", Rec."Store No.");
                GXLTransSalesEntry.SetRange("POS Terminal No.", Rec."POS Terminal No.");
                GXLTransSalesEntry.SetRange("Transaction No.", Rec."Transaction No.");
                GXLTransSalesEntry.SetRange("Line No.", Rec."Line No.");
                if GXLTransSalesEntry.FindFirst() then begin
                    GXLTransSalesEntry.CalcFields("GXL Item Description");
                    GXLItemDesc := GXLTransSalesEntry."GXL Item Description";
                end;
            end else
                GXLItemDesc := GXLTransSalesEntry."GXL Item Description";
        end;
        GXL_GetInfoSubcode(); //PS-2625 +
        GXL_GetStaff(); //PS-2625 +
    end;

    trigger OnOpenPage()
    begin
        Clear(GXLInfocodeDic); //PS-2625 +
        Clear(GXLStaffName); //PS-2625 +
    end;

    var
        GXLTransSalesEntry: Record "LSC Trans. Sales Entry";
        GXLItemDesc: Text[100];
        GXLInfocodeDic: Dictionary of [Text, Text];
        GXLStaffDic: Dictionary of [Text, Text];
        GXLSubcodeDesc: Text;
        GXLStaffName: Text;

    //PS-2625 +
    local procedure GXL_GetInfoSubcode()
    var
        GXLInfoSubcode: Record "LSC Information Subcode";
        TempCode: Text;
    begin
        TempCode := StrSubstNo('%1:%2', REC.Infocode, REC.Subcode);
        if not GXLInfocodeDic.ContainsKey(TempCode) then begin
            if GXLInfoSubcode.Get(REC.Infocode, REC.Subcode) then begin
                GXLInfocodeDic.Add(TempCode, GXLInfoSubcode.Description);
                GXLSubcodeDesc := GXLInfoSubcode.Description;
            end else begin
                GXLInfocodeDic.Add(TempCode, REC.Information);
                GXLSubcodeDesc := REC.Information;
            end;
        end else begin
            GXLInfocodeDic.Get(TempCode, GXLSubcodeDesc);
        end;
    end;

    local procedure GXL_GetStaff()
    var
        Staff: Record "LSC Staff";
    begin
        if not GXLStaffDic.ContainsKey(REC."Staff ID") then begin
            if Staff.Get(REC."Staff ID") then begin
                GXLStaffDic.Add(REC."Staff ID", Staff."Name on Receipt");
                GXLStaffName := Staff."Name on Receipt";
            end else begin
                GXLStaffDic.Add(REC."Staff ID", REC."Staff ID");
                GXLStaffName := REC."Staff ID";
            end;
        end else begin
            GXLStaffDic.Get(REC."Staff ID", GXLStaffName);
        end;
    end;
    //PS-2625 -
}