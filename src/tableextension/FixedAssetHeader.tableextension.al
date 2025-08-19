// 001 17.04.2025 BY LCB-799 
tableextension 50404 "GXL Fixed Asset Header" extends "Fixed Asset"
{
    fields
    {
        field(50000; "GXL FA Tax Type"; Code[20])  
        {
            DataClassification = ToBeClassified;
            Caption = 'FA Tax Type';
            TableRelation = "GXL FA Rule Type".Code where (Blocked = const(false));
        }
        field(50001; "GXL Tax Only"; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Tax Only';
            trigger OnValidate()
            var 
                FADeprBook : Record "FA Depreciation Book";
                DeprBook : Record "Depreciation Book";
            begin
                if Rec."GXL Tax Only" then begin
                    FADeprBook.SetRange("FA No.", Rec."No.");
                    if FADeprBook.FindSet() then
                        repeat
                            if DeprBook.Get(FADeprBook."Depreciation Book Code")then
                                if DeprBook."G/L Integration - Depreciation" then
                                    Error('You cannot set %1 because the %2 %3 has %4 enabled.',Rec.FieldCaption("GXL Tax Only"),DeprBook.TableCaption(), FADeprBook."Depreciation Book Code", DeprBook.FieldCaption("G/L Integration - Depreciation"));
                        until FADeprBook.Next() = 0;
                end;   
            end;
        }
    }
}