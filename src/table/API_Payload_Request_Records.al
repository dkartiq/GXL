// 001 22.07.2025 KDU https://petbarnjira.atlassian.net/browse/HAR2-576
table 50074 "GXL Payload Request Records"
{
    Caption = 'API Payload Request Records';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer) { DataClassification = SystemMetadata; AutoIncrement = true; }
        field(2; "GXL API Log Entry No."; Integer) { DataClassification = SystemMetadata; Caption = 'API Log Entry No.'; TableRelation = "GXL API Log"."Entry No."; }
        field(3; "GXL RecordID"; RecordID) { DataClassification = SystemMetadata; Caption = 'RecordID'; }
        field(4; "GXL Status"; Enum "GXL API Record Status") { DataClassification = SystemMetadata; Caption = 'Status'; }
        field(5; "GXL Error Desc"; Text[1025]) { DataClassification = ToBeClassified; Caption = 'Error Description'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
