// 001 18.11.2024 KDU https://petbarnjira.atlassian.net/browse/LCB-726
tableextension 50100 "GXL POS Transaction" extends "LSC POS Transaction"
{
    fields
    {
        // >> 001 
        //field(50100; "GXL Magento WebOrder Trans. ID"; Code[20]) 
        field(50100; "GXL Magento WebOrder Trans. ID"; Code[50])
        // << 001 
        {
            Caption = 'Magento Web Order Trans. ID';
            DataClassification = CustomerContent;
        }
        field(50101; "GXL Magento Web Order"; Boolean)
        {
            Caption = 'Magento Web Order';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(GXLMagentoKey1; "GXL Magento WebOrder Trans. ID")
        {
        }
        key(GXLMagentoKey2; "GXL Magento Web Order")
        {
            MaintainSqlIndex = false;
        }
    }
}