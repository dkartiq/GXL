// >> LCB-237 <<
page 50049 "GXL Intl. Ship. Advice Subform"
{
    Caption = 'International Shipping Advice Lines';
    PageType = ListPart;
    SourceTable = "GXL Intl. Shipping Advice Line";
    Editable = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Legacy Item No.';
                }
                field("Order Line No."; Rec."Order Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Line No.';
                }
                field("Quantity Shipped"; Rec."Quantity Shipped")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity Shipped';
                }
                field("Carton-Quantity Shipped"; Rec."Carton-Quantity Shipped")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Carton-Quantity Shipped';
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Unit of Measure Code';
                }
            }
        }
    }
}
