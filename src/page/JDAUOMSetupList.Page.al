page 50376 "GXL JDA UOM Setup List"
{
    Caption = 'JDA UOM Setup List';
    PageType = List;
    SourceTable = "GXL JDA UOM Setup";
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
                field("Category Code"; Rec."Category Code")
                {
                }
                field("Singular Name"; Rec."Singular Name")
                {
                }
                field("Plural Name"; Rec."Plural Name")
                {
                }
                field(Ratio; Rec.Ratio)
                {
                }
            }
        }
    }

    actions
    {
    }
}

