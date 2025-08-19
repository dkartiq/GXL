page 50374 "GXLAudit Exception Schedule"
{
    Caption = 'Audit Exception Schedule';
    PageType = List;
    SourceTable = "GXL Audit Exception Schedule";
    UsageCategory = Administration;
    ApplicationArea = All;
    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Week Day"; Rec."Week Day")
                {
                }
                field("Start Time"; Rec."Start Time")
                {
                }
                field("End Time"; Rec."End Time")
                {
                }
            }
        }
    }

    actions
    {
    }
}

