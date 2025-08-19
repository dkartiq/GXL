table 50102 "GXL Magento WebOrder Error Log"
{
    DataClassification = CustomerContent;
    Caption = 'Magento Web Order Error Log';
    LookupPageId = "GXL Magento WebOrder Error Log";
    DrillDownPageId = "GXL Magento WebOrder Error Log";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; "Web Order Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Web Order Entry No.';
            Editable = false;
            TableRelation =
            IF ("Order Archived" = CONST(false)) "GXL Magento Web Order"
            ELSE
            IF ("Order Archived" = CONST(true)) "GXL Magento Web Order";
            ValidateTableRelation = false;
        }
        field(3; "Order Archived"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Archived';
            Editable = false;
        }
        field(10; "Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
        }
        field(20; "Created Date-Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date-Time';
            Editable = false;
        }
        field(21; "Created by User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Created by User ID';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key1; "Web Order Entry No.")
        { }
    }

    trigger OnInsert()
    begin
        "Created by User ID" := UserId();
        "Created Date-Time" := CurrentDateTime();
    end;
}