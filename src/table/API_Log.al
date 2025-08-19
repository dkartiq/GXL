// 001 22.07.2025 KDU https://petbarnjira.atlassian.net/browse/HAR2-576
table 50071 "GXL API Log"
{
    DataClassification = ToBeClassified;
    Caption = 'API Log';
    fields
    {
        field(1; "Entry No."; Integer) { DataClassification = SystemMetadata; AutoIncrement = true; }
        field(2; "GXL Request Entry No."; Integer) { DataClassification = SystemMetadata; Caption = 'Request Entry No.'; }
        field(3; "GXL Type"; Enum "GXL API Log Type") { DataClassification = SystemMetadata; Caption = 'Type'; }
        field(4; "GXL Date"; Date) { DataClassification = SystemMetadata; Caption = 'Date'; }
        field(5; "GXL Time"; Time) { DataClassification = SystemMetadata; Caption = 'Time'; }
        field(6; "GXL User"; Code[50]) { DataClassification = SystemMetadata; Caption = 'User'; TableRelation = User; }
        field(7; "GXL Action"; Enum "GXL API Action") { DataClassification = SystemMetadata; Caption = 'Action'; }
        field(8; "GXL Function"; Text[100]) { DataClassification = SystemMetadata; Caption = 'Function'; }
        field(9; "GXL Table No."; Integer) { DataClassification = SystemMetadata; Caption = 'Table No.'; }
        field(10; "GXL Status"; Enum "GXL API Status") { DataClassification = SystemMetadata; Caption = 'Status'; }
        field(11; "GXL No. of Error Records"; Integer)
        {
            FieldClass = FlowField;
            CalcFormula = Count("GXL Payload Request Records" where("GXL API Log Entry No." = field("Entry No."), "GXL Status" = const(Error)));
            Editable = false;
            Caption = 'No. of Error Records';
        }
        field(12; "GXL Partner Code"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Partner Code';
        }
        field(13; "GXL Interface Contract"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Interface Contract';
        }
        field(14; "GXL Interface Contract Version"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Interface Contract Version';
        }
        field(15; "GXL API Type"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'API Type';
        }
        field(16; "GXL Payload Type"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'Payload Type';
        }
        field(17; "GXL System"; Code[20])
        {
            DataClassification = SystemMetadata;
            Caption = 'System';
        }
    }

    keys
    {
        key(PK; "Entry No.") { Clustered = true; }
    }
}
