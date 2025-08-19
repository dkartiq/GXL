tableextension 50275 "GXL Item Reference" extends "Item Reference"
{
    fields
    {
        // TODO: In furture upgrades
        field(50000; "Primary Bar Code"; Boolean)
        {

        }
        field(50001; "Primary EAN"; Code[50])
        {

        }
        field(50002; "OM GTIN"; CODE[50])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        // Add changes to keys here
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;
}