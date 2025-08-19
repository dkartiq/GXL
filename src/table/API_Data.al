// 001 22.07.2025 KDU https://petbarnjira.atlassian.net/browse/HAR2-576
table 50073 "GXL API Data"
{
    DataClassification = ToBeClassified;
    Caption = 'API Data';
    fields
    {
        field(1; "Entry No."; Integer) { DataClassification = SystemMetadata; AutoIncrement = true; }
        field(2; "GXL API Log Entry No."; Integer) { DataClassification = SystemMetadata; Caption = 'API Log Entry No.'; TableRelation = "GXL API Log"."Entry No."; }
        field(3; "GXL API PayloadRequestEntryNo."; Integer) { DataClassification = SystemMetadata; Caption = 'API Payload Request Entry No.'; TableRelation = "GXL Payload Request Records"."Entry No."; }
        field(4; "GXL Field No."; Integer) { DataClassification = SystemMetadata; Caption = 'Field No.'; }
        field(5; "GXL Field Name"; Text[100]) { DataClassification = ToBeClassified; Caption = 'Field Name'; }
        field(6; "GXL Field Value"; Text[1024]) { DataClassification = ToBeClassified; Caption = 'Field Value'; }
        field(7; "GXL Error Desc"; Text[1024]) { DataClassification = ToBeClassified; Caption = 'Error Decription'; }
        field(8; "GXL Sequence"; Integer) { DataClassification = ToBeClassified; Caption = 'Sequence'; }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
        key(Key1; "GXL Sequence") { }
    }
}
