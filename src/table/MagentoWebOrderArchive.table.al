table 50101 "GXL Magento Web Order Archive"
{
    DataClassification = CustomerContent;
    Caption = 'Magento Web Order Archive';
    LookupPageId = "GXL Magento Web Order Archive";
    DrillDownPageId = "GXL Magento Web Order Archive";

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(2; Id; Guid)
        {
            Caption = 'Id';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
            OptionMembers = "New","Validated","Error","Processed";
            OptionCaption = 'New,Validated,Error,Processed';
        }
        // >> 001 
        //field(10; "Transaction ID"; Code[20]) 
        field(10; "Transaction ID"; Code[50])
        // << 001 
        {
            Caption = 'Transaction ID';
            DataClassification = CustomerContent;
        }
        field(11; "Transaction Type"; Option)
        {
            Caption = 'Transaction Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Sales,Payment;
        }
        field(12; "Store No."; Code[10])
        {
            Caption = 'Store No.';
            DataClassification = CustomerContent;
            TableRelation = "LSC Store";
            ValidateTableRelation = false;
        }
        field(13; "Terminal No."; Code[10])
        {
            Caption = 'Terminal No.';
            DataClassification = CustomerContent;
            TableRelation = "LSC POS Terminal";
            ValidateTableRelation = false;
        }
        field(14; "Staff ID"; Code[20])
        {
            Caption = 'Staff ID';
            DataClassification = CustomerContent;
            TableRelation = "LSC Staff";
            ValidateTableRelation = false;
        }
        field(15; "Transaction Date"; Date)
        {
            Caption = 'Transaction Date';
            DataClassification = CustomerContent;
        }
        field(16; "Sales Type"; Code[20])
        {
            Caption = 'Sales Type (Magento)';
            DataClassification = CustomerContent;
        }
        field(20; "Line Number"; Integer)
        {
            Caption = 'Line Number';
            DataClassification = CustomerContent;
        }
        field(21; "Item Number"; Code[20])
        {
            Caption = 'Item Number';
            DataClassification = CustomerContent;
        }
        field(22; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(23; Price; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Price';
            DataClassification = CustomerContent;
        }
        field(30; "Tender Type"; Code[10])
        {
            Caption = 'Tender Type';
            DataClassification = CustomerContent;
        }
        field(31; "Amount Tendered"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount Tendered';
            DataClassification = CustomerContent;
        }
        field(32; "Freight Charge"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Freight Charge';
            AutoFormatType = 1;
        }
        field(40; "Sales Item No."; Code[20])
        {
            Caption = 'Sales Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(41; "Sales Item UoM Code"; Code[10])
        {
            Caption = 'Sales Item UoM Code';
            DataClassification = CustomerContent;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Sales Item No."));
        }
        field(50; "Last Modified Date-Time"; DateTime)
        {
            Caption = 'Last Modified Date-Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(51; "Last Modified by User ID"; Code[50])
        {
            Caption = 'Last Modified by User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
        field(52; "Manually Modified"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(60; "POS Trans. Receipt No."; Code[20])
        {
            Caption = 'POS Trans. Receipt No.';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "LSC POS Transaction";
            ValidateTableRelation = false;
        }
        field(61; "POS Trans. Line No."; Integer)
        {
            Caption = 'POS Trans. Line No.';
            DataClassification = CustomerContent;
            Editable = false;
            BlankZero = true;
            TableRelation = "LSC POS Trans. Line"."Line No." where("Receipt No." = field("POS Trans. Receipt No."));
            ValidateTableRelation = false;
        }
        field(100; "No. of Errors"; Integer)
        {
            Caption = 'No. of Errors';
            FieldClass = FlowField;
            CalcFormula = count("GXL Magento WebOrder Error Log" where("Web Order Entry No." = field("Entry No.")));
            Editable = false;
            BlankZero = false;
        }
        field(200; "Archived Date-Time"; DateTime)
        {
            Caption = 'Archived Date-Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(201; "Archived by User ID"; Code[50])
        {
            Caption = 'Archived by User ID';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
            TableRelation = User."User Name";
            ValidateTableRelation = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Archived Date-Time")
        {
        }
        key(Key3; "POS Trans. Receipt No.")
        {
        }
        key(Key4; "Transaction ID", "Transaction Type", "Line Number")
        {
        }
        key(Key5; Status)
        {
        }
    }

    trigger OnInsert()
    begin
        "Archived by User ID" := UserId();
        "Archived Date-Time" := CurrentDateTime();
    end;

    trigger OnModify()
    begin
    end;

    trigger OnRename()
    begin
        Error('You cannot rename a %1.', TableCaption());
    end;

    trigger OnDelete()
    begin
        DeleteErrorLog();
    end;

    procedure DeleteErrorLog()
    var
        MagentoWebOrderErrorLog: record "GXL Magento WebOrder Error Log";
    begin
        MagentoWebOrderErrorLog.SetCurrentKey("Web Order Entry No.");
        MagentoWebOrderErrorLog.SetRange("Web Order Entry No.", "Entry No.");
        if not MagentoWebOrderErrorLog.IsEmpty() then
            MagentoWebOrderErrorLog.DeleteAll();
    end;
}
