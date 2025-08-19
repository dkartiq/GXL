page 50104 "GXL Magento Web Order Archive"
{
    Caption = 'Magento Web Order Archive';
    ApplicationArea = All;
    PageType = List;
    SourceTable = "GXL Magento Web Order Archive";
    UsageCategory = History;
    RefreshOnActivate = true;
    Editable = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = "Transaction Type";
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Archived Date-Time"; Rec."Archived Date-Time")
                {
                    ApplicationArea = All;
                }
                field("Last Modified Date-Time"; Rec."Last Modified Date-Time")
                {
                    ApplicationArea = All;
                }
                field("Transaction ID"; Rec."Transaction ID")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("No. of Errors"; Rec."No. of Errors")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                }
                field("Transaction Date"; Rec."Transaction Date")
                {
                    ApplicationArea = All;
                }
                field(SalesType; Rec."Sales Type")
                {
                    ApplicationArea = All;
                }
                field("Line Number"; Rec."Line Number")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Item Number"; Rec."Item Number")
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
                field("Tender Type"; Rec."Tender Type")
                {
                    ApplicationArea = All;
                }
                field("Amount Tendered"; Rec."Amount Tendered")
                {
                    ApplicationArea = All;
                }
                field("Freight Charge"; Rec."Freight Charge")
                {
                    ApplicationArea = All;
                }
                field("Sales Item No."; Rec."Sales Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Sales Item UoM Code"; Rec."Sales Item UoM Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field("Terminal No."; Rec."Terminal No.")
                {
                    ApplicationArea = All;
                }
                field("Staff ID"; Rec."Staff ID")
                {
                    ApplicationArea = All;
                }
                field("Archived by User ID"; Rec."Archived by User ID")
                {
                    ApplicationArea = All;
                }
                field("Last Modified by User ID"; Rec."Last Modified by User ID")
                {
                    ApplicationArea = All;
                }
                field("Manually Modified"; Rec."Manually Modified")
                {
                    Visible = false;
                    ApplicationArea = All;
                }
                field(Id; Rec.Id)
                {
                    Visible = false;
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

