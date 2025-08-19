// 001 18.03.2024 KDU LCB-291 New object created.
page 50057 "GXL 3PL Reason Code Mapping"
{
    Caption = '3PL Reason Code Mapping';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL 3PL Reason Code Mapping";
    DelayedInsert = true;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field("3PL Reason Code"; Rec."3PL Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3PL Reason Code field.';
                }
                field("BC Reason Code"; Rec."BC Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the BC Reason Code field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                ApplicationArea = All;

                trigger OnAction()
                begin

                end;
            }
        }
    }

    var
        myInt: Integer;
}