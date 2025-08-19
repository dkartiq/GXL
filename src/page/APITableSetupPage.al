
// 001 22.07.2025 KDU https://petbarnjira.atlassian.net/browse/HAR2-576
page 10016925 "GXL API Table Setup Page"
{
    PageType = Document;
    SourceTable = "GXL API Table Setup";
    Caption = 'API Table Setup';
    ApplicationArea = All;
    DeleteAllowed = false;
    layout
    {
        area(content)
        {
            group(Group)
            {
                field("API Name"; Rec."API Name") { }
                field("Table ID"; Rec."Table ID")
                {
                    trigger OnValidate()
                    var
                        FieldRec: Record Field;
                        FieldSetupRec: Record "GXL API Table Fields";
                        APIName: Code[50];
                        i: Integer;
                    begin
                        //Rec."Table Name" := TableCaption(Rec."Table ID");

                        // Delete existing field setup lines
                        FieldSetupRec.SetRange("API Name", Rec."API Name");
                        FieldSetupRec.DeleteAll();

                        // Insert new lines based on selected table
                        FieldRec.Reset();
                        FieldRec.SetRange(TableNo, Rec."Table ID");
                        FieldRec.SetRange(Class, FieldRec.Class::Normal);
                        FieldRec.SetRange(Enabled, true);
                        FieldRec.SetFilter(Type, '%1|%2|%3|%4|%5|%6|%7|%8|%9|%10|%11', FieldRec.Type::Boolean, FieldRec.Type::Code,
                        FieldRec.Type::Date, FieldRec.Type::DateFormula, FieldRec.Type::DateTime, FieldRec.Type::Decimal,
                        FieldRec.Type::Duration, FieldRec.Type::Integer, FieldRec.Type::Option, FieldRec.Type::Text, FieldRec.Type::Time);
                        if FieldRec.FindSet() then
                            repeat
                                i += 1;
                                FieldSetupRec.Init();
                                FieldSetupRec."API Name" := Rec."API Name";
                                FieldSetupRec."Field No." := FieldRec."No.";
                                FieldSetupRec."Field Name" := FieldRec.FieldName;
                                FieldSetupRec."Enable Field" := false;
                                FieldSetupRec."Validate" := true;
                                FieldSetupRec."Sequence" := i;
                                FieldSetupRec.Insert();
                            until FieldRec.Next() = 0;
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                }
                field("GXL Priority Level"; Rec."GXL Priority Level") { }
                field("Table Name"; Rec."Table Name") { }
                field("Enable Insert Trigger"; Rec."Enable Insert Trigger") { }
                field("Enable Modify Trigger"; Rec."Enable Modify Trigger") { }
                field("GXL Disable"; Rec."GXL Disable") { }
            }
            part(Fields; "GXL API Table Fields SubPage")
            {
                SubPageLink = "API Name" = FIELD("API Name");
            }
        }
    }
    actions
    {
        area(Processing)
        {
            action("API Log")
            {
                ApplicationArea = All;
                Image = View;
                trigger OnAction()
                var
                    APILog: Record "GXL API Log";
                begin
                    APILog.SetRange("GXL Function", Rec."API Name");
                    Page.Run(Page::"GXL API Log List", APILog);
                end;
            }
            action("Generate Sample JSON")
            {
                ApplicationArea = All;
                Image = ExportFile;
                trigger OnAction()
                var
                    APIHandler: Codeunit "GXL API Integration Handler";
                    JSON: Text;
                begin
                    JSON := APIHandler.GenerateSampleJSON(Rec."API Name", Rec."Table ID");
                    APIHandler.DownloadJson(JSON, Rec."API Name" + '.Json');
                end;
            }
        }
    }
}