/// <summary>
/// PS-2423 Magento web order cancelled
/// </summary>
// 001 18.11.2024 KDU https://petbarnjira.atlassian.net/browse/LCB-726
table 50034 "GXL Magento Cancelled Order"
{
    Caption = 'Magento Cancelled Order';
    DataClassification = CustomerContent;

    fields
    {
        // >> 001 
        //field(10; "Magento WebOrder Trans. ID"; Code[20]) 
        field(10; "Magento WebOrder Trans. ID"; Code[50])
        // << 001 
        {
            Caption = 'Magento WebOrder Trans. ID';
            DataClassification = CustomerContent;
        }
        field(20; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Magento WebOrder Trans. ID")
        {
            Clustered = true;
        }
        key(Key3; Processed)
        {
        }
    }

    var

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}