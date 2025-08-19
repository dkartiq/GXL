tableextension 50000 "GXL Item Unit Of Measure" extends "Item Unit of Measure"
{
    fields
    {
        field(50000; "GXL Legacy Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Legacy Item No.';

            trigger OnValidate()
            var
                GXLLegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
            begin
                if ("GXL Legacy Item No." <> xRec."GXL Legacy Item No.") and ("GXL Legacy Item No." <> '') then
                    GXLLegacyItemHelpers.CheckLegacyItemNo(Rec);
            end;
        }
        field(50001; "GXL Unit Price"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Unit Price';
            MinValue = 0;
            AutoFormatType = 2;
        }
        field(50010; "GXL OM Depth"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'OM Depth';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                GXL_CalcOMCubage();
            end;
        }
        field(50011; "GXL OM Width"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'OM Width';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                GXL_CalcOMCubage();
            end;
        }
        field(50012; "GXL OM Height"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'OM Height';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                GXL_CalcOMCubage();
            end;
        }
        field(50013; "GXL OM Cubage"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'OM Cubage';
            DecimalPlaces = 0 : 5;
        }
        field(50014; "GXL OM Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'OM Weight';
            DecimalPlaces = 0 : 5;
        }
        field(50020; "GXL OP Depth"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'OP Depth';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                GXL_CalcOPCubage();
            end;
        }
        field(50021; "GXL OP Width"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'OP Width';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                GXL_CalcOPCubage();
            end;
        }
        field(50022; "GXL OP Height"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'OP Height';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                GXL_CalcOPCubage();
            end;
        }
        field(50023; "GXL OP Cubage"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'OP Cubage';
            DecimalPlaces = 0 : 5;
        }
        field(50024; "GXL OP Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'OP Weight';
            DecimalPlaces = 0 : 5;
        }
    }

    keys
    {
        key("GXL Legacy Item No."; "GXL Legacy Item No.")
        {
        }
    }

    local procedure GXL_CalcOMCubage()
    begin
        "GXL OM Cubage" := ("GXL OM Depth" / 1000) * ("GXL OM Width" / 1000) * ("GXL OM Height" / 1000);
    end;

    local procedure GXL_CalcOPCubage()
    begin
        "GXL OP Cubage" := ("GXL OP Depth" / 1000) * ("GXL OP Width" / 1000) * ("GXL OP Height" / 1000);
    end;
}