tableextension 50002 "GXL Inventory Lookup Table" extends "LSC Inventory Lookup Table"
{
    fields
    {
        field(50000; "GXL Store Name"; Text[100])
        {
            Caption = 'Store Name';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store".Name where("No." = field("Store No.")));
        }
        field(50001; "GXL Store Phone No."; Text[30])
        {
            Caption = 'Store Phone No.';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store"."Phone No." where("No." = field("Store No.")));
        }
    }

}