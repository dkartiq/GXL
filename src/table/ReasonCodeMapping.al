// 001 18.03.2024 KDU LCB-291 New object created.
table 50039 "GXL 3PL Reason Code Mapping"
{
    Caption = '3PL Reason Code Mapping';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("GXL 3PL Warehouse" = const(true));
        }
        field(2; "3PL Reason Code"; Code[30])
        {
            Caption = '3PL Reason Code';
            DataClassification = CustomerContent;
        }
        field(21; "BC Reason Code"; Code[10])
        {
            Caption = 'BC Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }

    }

    keys
    {
        key(Key1; "Location Code", "3PL Reason Code")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        TestField("Location Code");
        TestField("3PL Reason Code");
    end;

    procedure GetBCReasonCode(LocationCodeP: Code[10]; "3PLReasonCodeP": Code[30]; var BCReasonCodeP: code[10]): Boolean
    begin
        if Rec.Get(LocationCodeP, "3PLReasonCodeP") then begin
            BCReasonCodeP := Rec."BC Reason Code";
            exit(true);
        end;
    end;

}