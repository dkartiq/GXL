tableextension 50102 "GXL POS Trans. Line" extends "LSC POS Trans. Line"
{
    fields
    {
        field(50000; "GXL Legacy Item No."; Code[20])
        {
            Caption = 'Legacy Item No.';
            DataClassification = CustomerContent;
        }

        modify(Number)
        {
            trigger OnAfterValidate()
            begin
                if ("Entry Type" = "Entry Type"::Item) and (Number <> '') then
                    LegacyItemHelpers.GetLegacyItemNo(Number, "Unit of Measure", "GXL Legacy Item No.")
                else
                    "GXL Legacy Item No." := '';
            end;
        }
        modify("Unit of Measure")
        {
            trigger OnAfterValidate()
            begin
                if ("Entry Type" = "Entry Type"::Item) and (Number <> '') then
                    LegacyItemHelpers.GetLegacyItemNo(Number, "Unit of Measure", "GXL Legacy Item No.")
                else
                    "GXL Legacy Item No." := '';
            end;
        }
    }

    var
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
}