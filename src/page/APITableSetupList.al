page 10016923 "API Table Setup List"
{
    PageType = List;
    SourceTable = "GXL API Table Setup";
    ApplicationArea = All;
    Caption = 'API Table Setup List';
    UsageCategory = Administration;
    CardPageId = "GXL API Table Setup Page";
    Editable = false;
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("API Name"; Rec."API Name") { }
                field("Table ID"; Rec."Table ID") { }
                field("Table Name"; Rec."Table Name") { }
                field("GXL Priority Level"; Rec."GXL Priority Level") { }
                field("Enable Insert Trigger"; Rec."Enable Insert Trigger") { }
                field("Enable Modify Trigger"; Rec."Enable Modify Trigger") { }

                field("GXL Disable"; Rec."GXL Disable") { }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Edit Setup")
            {
                ApplicationArea = All;
                Caption = 'Edit Setup';
                Image = Edit;
                RunObject = Page "GXL API Table Setup Page";
                RunPageMode = Edit;
                ShortcutKey = 'Shift+F2';
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
                    // JSON := APIHandler.escapeJson(JSON);
                    APIHandler.DownloadJson(JSON, Rec."API Name" + '.Json');
                end;
            }
        }

    }


}
