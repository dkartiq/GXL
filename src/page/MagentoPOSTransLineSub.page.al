page 50107 "GXL Magento POSTransLine Sub"
{
    Caption = 'Lines';
    PageType = ListPart;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "LSC POS Trans. Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = Number;
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Trans. Date"; Rec."Trans. Date")
                {
                    ApplicationArea = All;
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                }
                field(Number; Rec.Number)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure"; Rec."Unit of Measure")
                {
                    ApplicationArea = All;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = All;
                }
                field("Created by Staff ID"; Rec."Created by Staff ID")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}