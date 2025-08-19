// 001 05.07.2025 KDU HP2-Sprint2
page 50365 "GXL 3PL File Setup"
{
    Caption = 'File Exchange Setup';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "GXL 3Pl File Setup";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                }
                // >> 001
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                }
                // << 001
                field("XML Port"; Rec."XML Port")
                {
                    ApplicationArea = All;
                }
                field(Direction; Rec.Direction)
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("File Format"; Rec."File Format")
                {
                    ApplicationArea = All;
                }
                field("3PL Types"; Rec."3PL Types")
                {
                    ApplicationArea = All;
                }
                field(Frequency; Rec.Frequency)
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}