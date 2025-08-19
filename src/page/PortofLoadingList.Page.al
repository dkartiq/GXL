page 50379 "GXL Port of Loading List"
{
    PageType = List;
    SourceTable = "GXL Port of Loading";
    Caption = 'Port of Loading';
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
                }
                field(Description; Rec.Description)
                {
                }
                field("Port Type"; Rec."Port Type")
                {
                }
            }
        }
    }

    actions
    {
    }
}

