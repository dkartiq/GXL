// 001 22.07.2025 KDU https://petbarnjira.atlassian.net/browse/HAR2-576
page 10016924 "GXL API Table Fields SubPage"
{
    PageType = ListPart;
    SourceTable = "GXL API Table Fields";
    ApplicationArea = All;
    Editable = true;
    Caption = 'API Table Fields';

    layout
    {

        area(content)
        {
            repeater(Lines)
            {
                field("Field No."; Rec."Field No.") { Editable = false; }
                field("Field Name"; Rec."Field Name") { Editable = false; }
                field("Enable Field"; Rec."Enable Field") { }
                field("Validate"; Rec."Validate") { }
                field("Sequence"; Rec."Sequence") { }
            }
        }
    }
    actions
    {
        area(Processing)
        {

            action(EnableAllFields)
            {
                ApplicationArea = All;
                Caption = 'Enable All Fields';
                ToolTip = 'Enable all fields.';
                Image = EnableAllBreakpoints;
                trigger OnAction()
                var
                    FieldList: Record "GXL API Table Fields";
                begin
                    FieldList.SetRange("API Name", Rec."API Name");
                    FieldList.ModifyAll("Enable Field", true);
                    CurrPage.Update(false);
                end;
            }
            action(DisableAllFields)
            {
                ApplicationArea = All;
                Caption = 'Disable All Fields';
                ToolTip = 'Disable all fields.';
                Image = DisableAllBreakpoints;
                trigger OnAction()
                var
                    FieldList: Record "GXL API Table Fields";
                begin
                    FieldList.SetRange("API Name", Rec."API Name");
                    FieldList.ModifyAll("Enable Field", false);
                    CurrPage.Update(false);
                end;
            }

            action(ShowAllFields)
            {
                ApplicationArea = All;
                Caption = 'Show All Fields';
                ToolTip = 'Show all fields.';
                Image = View;
                trigger OnAction()
                begin
                    rec.SetRange("Enable Field");
                end;
            }
            action(ShowSelectFields)
            {
                ApplicationArea = All;
                Caption = 'Show Select Fields';
                ToolTip = 'Clear filter and show all fields.';
                Image = ShowList;
                trigger OnAction()
                begin
                    rec.SetRange("Enable Field", true);
                end;
            }
        }
    }
    trigger OnOpenPage()
    begin
        rec.SetRange("Enable Field", true);
    end;

}
