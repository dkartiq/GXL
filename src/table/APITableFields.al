// 001 22.07.2025 KDU https://petbarnjira.atlassian.net/browse/HAR2-576
table 50076 "GXL API Table Fields"
{
    Caption = 'API Table Fields';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "API Name"; Code[50]) { TableRelation = "GXL API Table Setup"."API Name"; }
        field(2; "Field No."; Integer) { }
        field(3; "Field Name"; Text[100]) { Editable = false; }
        field(4; "Enable Field"; Boolean) { }
        field(5; "Validate"; Boolean) { }
        field(6; "Sequence"; Integer) { }
    }

    keys
    {
        key(PK; "API Name", "Field No.") { Clustered = true; }
    }
    trigger OnDelete()
    var
        FieldRec: Record "GXL API Table Fields";
    begin
        FieldRec.SetRange("API Name", "API Name");
        FieldRec.DeleteAll();
    end;
}
