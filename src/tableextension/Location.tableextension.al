// 001 05.07.2025 KDU HP2-Sprint2
tableextension 50350 "GXL Location" extends Location
{
    fields
    {
        field(50350; "GXL 3PL Warehouse"; Boolean)
        {
            Caption = '3PL Warehouse';
            DataClassification = CustomerContent;
        }
        field(50351; "GXL Inbound File Path"; Text[80])
        {
            Caption = 'Inbound File Path';
            DataClassification = CustomerContent;
        }
        field(50352; "GXL EDI Type"; Option)
        {
            Caption = 'EDI Type';
            DataClassification = CustomerContent;
            OptionMembers = " ","3PL EDI";
        }
        field(50353; "GXL 3PL Archive File Path"; Text[80])
        {
            Caption = '3PL Archive File Path';
            DataClassification = CustomerContent;
        }
        field(50354; "GXL 3PL Error File Path"; Text[80])
        {
            Caption = '3PL Error File Path';
            DataClassification = CustomerContent;
        }
        field(50355; "GXL Receive File Format"; Option)
        {
            Caption = 'Receive File Format';
            DataClassification = CustomerContent;
            OptionMembers = " ",CSV,XML;
        }
        field(50357; "GXL Def. Stock Adj. Batch Name"; Code[10])
        {
            Caption = 'Default Stock Adj. Batch Name';
            DataClassification = CustomerContent;
            TableRelation = "Item Journal Batch".Name WHERE("Journal Template Name" = FILTER('ITEM'));
        }
        field(50358; "GXL Outbound File Path"; Text[80])
        {
            Caption = 'Outbound File Path';
            DataClassification = CustomerContent;
        }
        field(50359; "GXL Send File Name Prefix"; Code[10])
        {
            Caption = 'Send File Name Prefix';
            DataClassification = CustomerContent;
        }
        field(50361; "GXL File Exchange Email Addr."; Text[80])
        {
            Caption = 'File Exchange Email Address';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(50362; "GXL Send File Format"; Option)
        {
            Caption = 'Send File Format';
            DataClassification = CustomerContent;
            OptionMembers = " ",CSV,XML;
        }
        field(50363; "GXL Location Type"; Option)
        {
            Caption = 'Location Type';
            OptionMembers = "1","3","6";
            OptionCaption = '1 - Supplier,3 - DC,6 - Store';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Store"."GXL Location Type" where("Location Code" = field(Code)));
            Editable = false;
        }
        // >> 001
        field(50364; "GXL Arrival Port"; Code[10])
        {
            Caption = 'Arrival Port';
            TableRelation = "GXL Port of Loading";
        }
        // << 001
    }
    procedure GetAssociatedStore(var Store: Record "LSC Store"; SuppressError: Boolean): Boolean
    begin
        Store.SetCurrentKey("Location Code");
        Store.SetRange("Location Code", Rec.Code);
        if SuppressError then
            exit(Store.FindFirst())
        else
            Store.FindFirst();
        exit(true);
    end;
}