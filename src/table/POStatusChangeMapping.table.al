table 50081 "GXL PO Status Change Mapping"
{
    DataClassification = ToBeClassified;
    DataCaptionFields = "To";

    fields
    {
        field(1; From; Enum "GXL PO Status")
        {
            DataClassification = ToBeClassified;
        }
        field(2; "To"; Enum "GXL PO Status")
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                Rec.CalcFields(Description);
            end;
        }
        field(3; Description; Text[100])
        {
            FieldClass = FlowField;
            CalcFormula = lookup("GXL PO Status".Description where(Status = field(To)));
        }
    }

    keys
    {
        key(PK; From, To)
        {
            Clustered = true;
        }
    }
    procedure AddRecords(CurrStatus: Enum "GXL PO Status")
    var
        PagePOStatus: Page "GXL PO Status";
        POStatus: Record "GXL PO Status";
    begin
        POStatus.SetFilter(Status, '<>%1', CurrStatus);
        PagePOStatus.SetTableView(POStatus);
        PagePOStatus.LookupMode(true);
        if PagePOStatus.RunModal <> Action::LookupOK then
            exit;

        PagePOStatus.GetSelectedRecords(POStatus);
        if POStatus.FindSet() then begin
            repeat
                AddRecord(CurrStatus, POStatus.Status);
            until POStatus.Next() = 0;
        end;
    end;

    local procedure AddRecord(FromStatus: Enum "GXL PO Status"; ToStatus: Enum "GXL PO Status")
    var
        POStatusChangeMapping: Record "GXL PO Status Change Mapping";
    begin

        if FromStatus = ToStatus then
            exit;

        POStatusChangeMapping.SetRange(From, FromStatus);
        POStatusChangeMapping.SetRange("To", ToStatus);
        if POStatusChangeMapping.IsEmpty then begin
            POStatusChangeMapping.Init();
            POStatusChangeMapping.Validate(From, FromStatus);
            POStatusChangeMapping.Validate("To", ToStatus);
            POStatusChangeMapping.Insert(true);
        end;

    end;
}