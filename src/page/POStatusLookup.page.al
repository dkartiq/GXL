page 10016883 "GXL PO Status Lookup"
{
    PageType = Card;
    SourceTable = "GXL PO Status Change Mapping";
    Caption = 'Change Order Status to';
    Editable = false;
    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("To"; Rec."To")
                {
                    ApplicationArea = all;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field.', Comment = '%';
                    DrillDown = false;
                }
            }
        }
    }
}