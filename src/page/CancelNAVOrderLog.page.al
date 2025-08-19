/// <summary>
/// NAV9-11 Integrations
/// </summary>
page 50035 "GXL Cancel NAV Order Log"
{
    Caption = 'Cancel NAV Order Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Cancel NAV Order Log";
    Editable = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Creation Date Time"; Rec."Creation Date Time")
                {
                    ApplicationArea = All;
                }
                field("Created By User"; Rec."Created By User")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}