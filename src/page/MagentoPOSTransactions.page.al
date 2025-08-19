page 50106 "GXL Magento POS Transactions"
{
    Caption = 'Magento POS Transactions';
    ApplicationArea = All;
    PageType = List;
    UsageCategory = Lists;
    SourceTable = "LSC POS Transaction";
    SourceTableView = sorting("GXL Magento Web Order") where("GXL Magento Web Order" = filter(true));
    RefreshOnActivate = true;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                FreezeColumn = "Transaction Type";
                field("Receipt No."; Rec."Receipt No.")
                {
                    ApplicationArea = All;
                }
                field("GXL Magento WebOrder Trans. ID"; Rec."GXL Magento WebOrder Trans. ID")
                {
                    ApplicationArea = All;
                }
                field("Trans. Date"; Rec."Trans. Date")
                {
                    ApplicationArea = All;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = All;
                }
                field("Sales Type"; Rec."Sales Type")
                {
                    ApplicationArea = All;
                }
                field("Gross Amount"; Rec."Gross Amount")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    BlankZero = true;
                }
                field("Income/Exp. Amount"; Rec."Income/Exp. Amount")
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    BlankZero = true;
                }
                field(Payment; Rec.Payment)
                {
                    ApplicationArea = All;
                    DrillDown = false;
                    BlankZero = true;
                }
                field("Entry Status"; Rec."Entry Status")
                {
                    ApplicationArea = All;
                }
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field("POS Terminal No."; Rec."POS Terminal No.")
                {
                    ApplicationArea = All;
                }
                field("Staff ID"; Rec."Staff ID")
                {
                    ApplicationArea = All;
                }
                field("VAT Bus.Posting Group"; Rec."VAT Bus.Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Created on POS Terminal"; Rec."Created on POS Terminal")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
            part(LineListpart; "GXL Magento POSTransLine Sub")
            {
                ApplicationArea = All;
                SubPageLink = "Receipt No." = FIELD("Receipt No.");
            }
        }
    }

    actions
    {
    }
}

