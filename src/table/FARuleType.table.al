// 001 17.04.2025 BY LCB-799 
table 50067 "GXL FA Rule Type"
{
    DataClassification = ToBeClassified;
    LookupPageId = "GXL FA Rule Types";
    DrillDownPageId = "GXL FA Rule Types";
    DataCaptionFields = Code, Description;

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = ToBeClassified;
            Caption = 'Code';
        }
        field(10; Description; Text[50])
        {
            DataClassification = ToBeClassified;
            Caption = 'Description';
        }
        field(20; Blocked; Boolean)
        {
            DataClassification = ToBeClassified;
            Caption = 'Blocked';
        }
    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }
    trigger OnDelete()
    var
        FA: Record "Fixed Asset";
    begin
        If Rec.Code > '' then begin
            FA.SetRange("GXL FA Tax Type", Rec.Code); // >> 002 <<
            If not FA.IsEmpty then
                Error('%1 # %2 is in use on %3 %4s.\You can not delete %1 # %2.', Rec.TableCaption, Rec.Code, FA.Count, FA.TableCaption);
        end;
    end;
}