page 50158 "GXL ECS Data Template Subpage"
{
    Caption = 'ECS Data Template Lines';
    PageType = ListPart;
    SourceTable = "GXL ECS Data Template Line";
    DelayedInsert = true;
    AutoSplitKey = true;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                }
                field("Field No."; Rec."Field No.")
                {
                    ApplicationArea = All;
                }
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                }
                field("ECS Field Name"; Rec."ECS Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the attribute name that to be sent to external application. If none is specified, then Field Name is used';
                }
                field("Mandatory Unique ID"; Rec."Mandatory Unique ID")
                {
                    ApplicationArea = All;
                }
                field("Send to ECS"; Rec."Send to ECS")
                {
                    ApplicationArea = All;
                }
                field("Trigger Field No."; Rec."Trigger Field No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specfies the field id that triggers the data change in relating to the Field No.. It is usually used if the Field No. is a flowfield and delta changes is required.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
        }
    }

    var
        TemplateHeader: Record "GXL ECS Data Template Header";

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if BelowxRec then
            Rec."Table ID" := xRec."Table ID"
        else
            if TemplateHeader.Get(Rec."ECS Data Template Code") then
                Rec."Table ID" := TemplateHeader."Table ID";
    end;
}