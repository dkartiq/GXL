// 001 22.07.2025 KDU https://petbarnjira.atlassian.net/browse/HAR2-576
enum 50073 "GXL API Status"
{
    Extensible = true;
    Caption = 'API Status';
    value(0; Created) { }
    value(1; PartiallyProcessed) { Caption = 'Partially Processed'; }
    value(2; Processed) { }
    value(3; Error) { }
}
