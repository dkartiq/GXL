/// <summary>
/// CR099 - Revaluation Journal Batch
/// </summary>
table 50043 "GXL Item Reval. Wksh. Loc Line"
{
    Caption = 'Item Revaluation Wksh Location Line';
    DataCaptionFields = "Batch ID";
    DataClassification = CustomerContent;
    DrillDownPageID = "GXL Item Reval. Wksh Loc Lines";
    LookupPageID = "GXL Item Reval. Wksh Loc Lines";

    fields
    {
        field(1; "Batch ID"; Integer)
        {
            Caption = 'Batch ID';
            DataClassification = CustomerContent;
            TableRelation = "GXL Item Reval. Wksh. Batch";
            Editable = false;
        }
        field(2; "Wksh. Line No."; Integer)
        {
            Caption = 'Wksh. Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(10; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(30; "Inventory Value (Calculated)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Inventory Value (Calculated)';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                ReadGLSetup;
                TestField(Quantity);
                "Unit Cost (Calculated)" := Round("Inventory Value (Calculated)" / Quantity, GLSetup."Unit-Amount Rounding Precision");
                Validate(Amount, "Inventory Value (Revalued)" - "Inventory Value (Calculated)");
            end;
        }
        field(31; "Inventory Value (Revalued)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Inventory Value (Revalued)';
            DataClassification = CustomerContent;
            MinValue = 0;
            Editable = false;

            trigger OnValidate()
            begin
                Validate(Amount, "Inventory Value (Revalued)" - "Inventory Value (Calculated)");
            end;
        }
        field(32; "Unit Cost (Calculated)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (Calculated)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(33; "Unit Cost (Revalued)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (Revalued)';
            DataClassification = CustomerContent;
            MinValue = 0;
            Editable = false;

            trigger OnValidate()
            begin
                ReadGLSetup;
                Validate("Inventory Value (Revalued)", Round("Unit Cost (Revalued)" * Quantity, GLSetup."Amount Rounding Precision"));
            end;
        }
    }

    keys
    {
        key(Key1; "Batch ID", "Wksh. Line No.", "Line No.") { Clustered = true; }
    }

    var
        GLSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;

    local procedure ReadGLSetup()
    begin
        if not GLSetupRead then begin
            GLSetup.Get;
            GLSetupRead := true;
        end;
    end;

}

