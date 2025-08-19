table 50383 "GXL Incoterms"
{
    Caption = 'Incoterms';
    DataCaptionFields = "Code", Description;
    DrillDownPageID = "GXL Incoterms";
    LookupPageID = "GXL Incoterms";

    fields
    {
        field(1; "Code"; Code[10])
        {
            NotBlank = true;
        }
        field(2; Description; Text[80])
        {
        }
        // TODO International/Domestic PO - Not needed for now
        // field(10; "No. of Vendors"; Integer)
        // {
        //     BlankZero = true;
        //     CalcFormula = Count (Vendor WHERE("GXL Incoterms Code" = FIELD(Code)));
        //     Editable = false;
        //     FieldClass = FlowField;
        // }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        //TODO: Domestic and Internaltional Order is not in scope, need to be re-visited when it is back in-scope
        //CALCFIELDS("No. of Vendors");
        //TESTFIELD("No. of Vendors");
    end;
}

