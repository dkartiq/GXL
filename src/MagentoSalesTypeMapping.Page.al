page 50058 "Magento Sales Type Mapping"
{
    ApplicationArea = All;
    Caption = 'Magento Sales Type Mapping';
    PageType = List;
    SourceTable = "Magento Sales Type Mapping";
    UsageCategory = Administration;
    AdditionalSearchTerms = 'Magento, Mapping, Sales Type';
    
    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Magento Sales Type"; Rec."Magento Sales Type")
                {
                    ToolTip = 'Specifies the value of the Magento Sales Type field.';
                }
                field("Sales Type"; Rec."Sales Type")
                {
                    ToolTip = 'Specifies the value of the Sales Type field.';
                }
                field(Remarks; Rec.Remarks)
                {
                    ToolTip = 'Specifies the value of the Remarks field.';
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                    Editable = false;
                }
                field(SystemCreatedBy; Rec.SystemCreatedBy)
                {
                    ToolTip = 'Specifies the value of the SystemCreatedBy field.';
                    Editable = false;
                }
                field(SystemModifiedAt; Rec.SystemModifiedAt)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedAt field.';
                    Editable = false;
                }
                field(SystemModifiedBy; Rec.SystemModifiedBy)
                {
                    ToolTip = 'Specifies the value of the SystemModifiedBy field.';
                    Editable = false;
                }
            }
        }
    }
}
