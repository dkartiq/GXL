// 001 22.07.2025 KDU https://petbarnjira.atlassian.net/browse/HAR2-576
table 50072 "GXL API Attachment Log"
{
    DataClassification = ToBeClassified;
    Caption = 'API Attachment Log';
    fields
    {
        field(1; "GXL API Log Entry No."; Integer) { DataClassification = SystemMetadata; Caption = 'API Log Entry No.'; TableRelation = "GXL API Log"."Entry No."; }
        field(2; "GXL Attachment"; Media) { DataClassification = ToBeClassified; Caption = 'Attachment'; }
        field(3; "GXL Payload Attachment"; Media) { DataClassification = ToBeClassified; Caption = 'Payload Attachment'; }
    }

    keys
    {
        key(PK; "GXL API Log Entry No.") { Clustered = true; }
    }
}
