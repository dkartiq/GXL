/// <summary>
/// ERP-NAV Master Data Management
/// </summary>
table 50032 "GXL NAV Item/SKU SOH-Calc. Log"
{
    Caption = 'NAV Item/SKU SOH Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
        }
        field(2; "Last Item Ledger Entry No."; Integer)
        {
            Caption = 'Last Item Ledger Entry No.';
            DataClassification = CustomerContent;
        }
        field(3; "Created Date Time"; DateTime)
        {
            Caption = 'Created Date Time';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
    }

    var


    trigger OnInsert()
    begin
        "Created Date Time" := CurrentDateTime();
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