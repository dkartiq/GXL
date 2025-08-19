page 50012 "GXL PDA-Facing Update by Store"
{
    Caption = 'PDA-Facing Update by Store';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL PDA-Facing Update by Store";
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                }
                field("Store Facing"; Rec."Store Facing")
                {
                    ApplicationArea = All;
                }
                field("Cashier Number"; Rec."Cashier Number")
                {
                    ApplicationArea = All;
                }
                field("Date Modified"; Rec."Date Modified")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

}