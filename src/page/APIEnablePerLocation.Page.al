page 50071 "API Enable Per Location"
{
    ApplicationArea = All;
    Caption = 'API Enable Per Location';
    PageType = List;
    SourceTable = "API Enable Per Location";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Location Code"; Rec."Location Code")
                {
                    ToolTip = 'Specifies the value of the Location Code field.';
                }
                field("API Type"; Rec."API Type")
                {
                    ToolTip = 'Specifies the value of the API Type field.';
                }
            }
        }
    }
}
