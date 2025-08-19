table 50038 "API Enable Per Location"
{
    Caption = 'Enable API Per Location';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location.Code;
        }
        field(2; "API Type"; enum "API Message Type Selection")
        {
            Caption = 'API Type';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Location Code","API Type")
        {
            Clustered = true;
        }
    }
}
