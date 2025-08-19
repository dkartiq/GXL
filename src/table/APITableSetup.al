// 001 22.07.2025 KDU https://petbarnjira.atlassian.net/browse/HAR2-576
table 50075 "GXL API Table Setup"
{
    Caption = 'API Table Setup';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "API Name"; Code[50]) { }
        field(2; "Table ID"; Integer) { TableRelation = AllObjWithCaption."Object ID" where("Object Type" = const(Table)); }
        field(3; "Table Name"; Text[249])
        {
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup(AllObjWithCaption."Object Caption" where("Object Type" = const(Table), "Object ID" = field("Table ID")));
        }
        field(4; "Enable Insert Trigger"; Boolean) { }
        field(5; "Enable Modify Trigger"; Boolean) { }
        field(6; Description; Text[100]) { }
        field(7; "GXL Disable"; Boolean)
        {
            Caption = 'Disable';
            trigger OnValidate()
            begin
                CheckPriorityLevel(Rec);
            end;
        }
        field(8; "GXL Priority Level"; Integer)
        {
            Caption = 'Priority Level';
            DataClassification = SystemMetadata;
            MinValue = 0;
            trigger OnValidate()
            begin
                CheckPriorityLevel(Rec);
            end;
        }
    }

    keys
    {
        key(PK; "API Name") { Clustered = true; }
    }
    procedure CheckPriorityLevel(APITableSetupP: Record "GXL API Table Setup")
    var
        APITableSetupL: Record "GXL API Table Setup";
        PriorityError: Label '%1 is already mentioned in %2';
    begin
        if APITableSetupP."GXL Disable" then
            exit;
        if APITableSetupP."GXL Priority Level" = 0 then
            exit;
        APITableSetupL.SetFilter("API Name", '<>%1', APITableSetupP."API Name");
        APITableSetupL.SetRange("GXL Disable", false);
        APITableSetupL.SetRange("GXL Priority Level", APITableSetupP."GXL Priority Level");
        if APITableSetupL.FindFirst() then
            Error(StrSubstNo(PriorityError, APITableSetupP."GXL Priority Level", APITableSetupL."API Name"));
    end;
}
