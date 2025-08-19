table 50045 "Magento Sales Type Mapping"
{
    Caption = 'Magento Sales Type Mapping';
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1; "Magento Sales Type"; Code[20])
        {
            Caption = 'Magento Sales Type';
        }
        field(2; "Sales Type"; Code[20])
        {
            Caption = 'Sales Type';
            TableRelation = "LSC Sales Type";
        }
        field(3; Remarks; Text[100])
        {
            Caption = 'Remarks';
        }
    }
    keys
    {
        key(PK; "Magento Sales Type","Sales Type")
        {
            Clustered = true;
        }
    }
}
