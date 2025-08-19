page 10016922 "API Payload Request Matrix"
{
    PageType = List;
    SourceTable = "GXL Payload Request Records";
    Caption = 'API Payload Request Matrix';
    ApplicationArea = All;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.") { }
                field("API Log Entry No."; Rec."GXL API Log Entry No.") { }
                field("RecordID"; Rec."RecordID") { }
                field("Status"; Rec."GXL Status") { }
                field("Field1"; Field1) { CaptionClass = FieldCaption1; Visible = FieldVisible1; }
                field("Field2"; Field2) { CaptionClass = FieldCaption2; Visible = FieldVisible2; }
                field("Field3"; Field3) { CaptionClass = FieldCaption3; Visible = FieldVisible3; }
                field("Field4"; Field4) { CaptionClass = FieldCaption4; Visible = FieldVisible4; }
                field("Field5"; Field5) { CaptionClass = FieldCaption5; Visible = FieldVisible5; }
                field("Field6"; Field6) { CaptionClass = FieldCaption6; Visible = FieldVisible6; }
                field("Field7"; Field7) { CaptionClass = FieldCaption7; Visible = FieldVisible7; }
                field("Field8"; Field8) { CaptionClass = FieldCaption8; Visible = FieldVisible8; }
                field("Field9"; Field9) { CaptionClass = FieldCaption9; Visible = FieldVisible9; }
                field("Field10"; Field10) { CaptionClass = FieldCaption10; Visible = FieldVisible10; }
                field("Field11"; Field11) { CaptionClass = FieldCaption11; Visible = FieldVisible11; }
                field("Field12"; Field12) { CaptionClass = FieldCaption12; Visible = FieldVisible12; }
                field("Field13"; Field13) { CaptionClass = FieldCaption13; Visible = FieldVisible13; }
                field("Field14"; Field14) { CaptionClass = FieldCaption14; Visible = FieldVisible14; }
                field("Field15"; Field15) { CaptionClass = FieldCaption15; Visible = FieldVisible15; }
                field("Field16"; Field16) { CaptionClass = FieldCaption16; Visible = FieldVisible16; }
                field("Field17"; Field17) { CaptionClass = FieldCaption17; Visible = FieldVisible17; }
                field("Field18"; Field18) { CaptionClass = FieldCaption18; Visible = FieldVisible18; }
                field("Field19"; Field19) { CaptionClass = FieldCaption19; Visible = FieldVisible19; }
                field("Field20"; Field20) { CaptionClass = FieldCaption20; Visible = FieldVisible20; }
            }
        }
    }
    trigger OnOpenPage()
    var
        i: Integer;
    begin
        APILog.Get(Rec.GetFilter("GXL API Log Entry No."));
        for i := 1 to 20 do begin
            SetVisibility(i);
        end;
    end;

    trigger OnAfterGetRecord()
    var
        i: Integer;
    begin
        for i := 1 to 20 do begin
            SetFieldValues(i);
        end;
    end;

    local procedure SetVisibility(FieldNo: Integer)
    var
        FieldSelection: Record "GXL API Table Fields";
        IsVisible: Boolean;
        Caption: Text;
    begin
        if FieldSelection.Get(APILog."GXL Function", FieldNo) then begin
            Caption := FieldSelection."Field Name";
            IsVisible := FieldSelection."Enable Field";
            case FieldNo of
                1:
                    begin
                        FieldCaption1 := Caption;
                        FieldVisible1 := IsVisible;
                    end;
                2:
                    begin
                        FieldCaption2 := Caption;
                        FieldVisible2 := IsVisible;
                    end;
                3:
                    begin
                        FieldCaption3 := Caption;
                        FieldVisible3 := IsVisible;
                    end;
                4:
                    begin
                        FieldCaption4 := Caption;
                        FieldVisible4 := IsVisible;
                    end;
                5:
                    begin
                        FieldCaption5 := Caption;
                        FieldVisible5 := IsVisible;
                    end;
                6:
                    begin
                        FieldCaption6 := Caption;
                        FieldVisible6 := IsVisible;
                    end;
                7:
                    begin
                        FieldCaption7 := Caption;
                        FieldVisible7 := IsVisible;
                    end;
                8:
                    begin
                        FieldCaption8 := Caption;
                        FieldVisible8 := IsVisible;
                    end;
                9:
                    begin
                        FieldCaption9 := Caption;
                        FieldVisible9 := IsVisible;
                    end;
                10:
                    begin
                        FieldCaption10 := Caption;
                        FieldVisible10 := IsVisible;
                    end;
                11:
                    begin
                        FieldCaption11 := Caption;
                        FieldVisible11 := IsVisible;
                    end;
                12:
                    begin
                        FieldCaption12 := Caption;
                        FieldVisible12 := IsVisible;
                    end;
                13:
                    begin
                        FieldCaption13 := Caption;
                        FieldVisible13 := IsVisible;
                    end;
                14:
                    begin
                        FieldCaption14 := Caption;
                        FieldVisible14 := IsVisible;
                    end;
                15:
                    begin
                        FieldCaption15 := Caption;
                        FieldVisible15 := IsVisible;
                    end;
                16:
                    begin
                        FieldCaption16 := Caption;
                        FieldVisible16 := IsVisible;
                    end;
                17:
                    begin
                        FieldCaption17 := Caption;
                        FieldVisible17 := IsVisible;
                    end;
                18:
                    begin
                        FieldCaption18 := Caption;
                        FieldVisible18 := IsVisible;
                    end;
                19:
                    begin
                        FieldCaption19 := Caption;
                        FieldVisible19 := IsVisible;
                    end;
                20:
                    begin
                        FieldCaption20 := Caption;
                        FieldVisible20 := IsVisible;
                    end;
            end;

        end;
    end;


    local procedure SetFieldValues(FieldNo: Integer)
    var
        APIData: Record "GXL API Data";
        FieldDef: Record "GXL API Table Fields";
        FieldSelection: Record "GXL API Table Fields";
        Value: Text;
        Caption: Text;
        IsVisible: Boolean;
    begin
        APIData.SetRange("GXL API PayloadRequestEntryNo.", Rec."Entry No.");
        APIData.SetRange("GXL Field No.", FieldNo);
        if APIData.FindFirst() then
            Value := APIData."GXL Field Value"
        else
            Value := '';

        case FieldNo of
            1:
                Field1 := Value;
            2:
                Field2 := Value;
            3:
                Field3 := Value;
            4:
                Field4 := Value;
            5:
                Field5 := Value;
            6:
                Field6 := Value;
            7:
                Field7 := Value;
            8:
                Field8 := Value;
            9:
                Field9 := Value;
            10:
                Field10 := Value;
            11:
                Field11 := Value;
            12:
                Field12 := Value;
            13:
                Field13 := Value;
            14:
                Field14 := Value;
            15:
                Field15 := Value;
            16:
                Field16 := Value;
            17:
                Field17 := Value;
            18:
                Field18 := Value;
            19:
                Field19 := Value;
            20:
                Field20 := Value;
        end;
    end;

    var
        APILog: Record "GXL API Log";
        Field1, Field2, Field3, Field4, Field5, Field6, Field7, Field8, Field9, Field10 : Text;
        Field11, Field12, Field13, Field14, Field15, Field16, Field17, Field18, Field19, Field20 : Text;
        FieldCaption1, FieldCaption2, FieldCaption3, FieldCaption4, FieldCaption5 : Text;
        FieldCaption6, FieldCaption7, FieldCaption8, FieldCaption9, FieldCaption10 : Text;
        FieldCaption11, FieldCaption12, FieldCaption13, FieldCaption14, FieldCaption15 : Text;
        FieldCaption16, FieldCaption17, FieldCaption18, FieldCaption19, FieldCaption20 : Text;
        FieldVisible1, FieldVisible2, FieldVisible3, FieldVisible4, FieldVisible5 : Boolean;
        FieldVisible6, FieldVisible7, FieldVisible8, FieldVisible9, FieldVisible10 : Boolean;
        FieldVisible11, FieldVisible12, FieldVisible13, FieldVisible14, FieldVisible15 : Boolean;
        FieldVisible16, FieldVisible17, FieldVisible18, FieldVisible19, FieldVisible20 : Boolean;
}
