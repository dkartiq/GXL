pageextension 50150 "GXL Store Card" extends "LSC Store Card"
{
    layout
    {
        addafter(Attributes)
        {
            group("GXL GXLSupplyChainGroup")
            {
                Caption = 'Supply Chain';

                field("GXL Region Code"; Rec."GXL Region Code")
                {
                    ApplicationArea = All;
                }
                field("GXL Region 2 Code"; Rec."GXL Region 2 Code")
                {
                    ApplicationArea = All;
                }
                field("GXL Open Date"; Rec."GXL Open Date")
                {
                    ApplicationArea = All;
                }
                field("GXL Closed Date"; Rec."GXL Closed Date")
                {
                    ApplicationArea = All;
                }
                field("GXL Location Type"; Rec."GXL Location Type")
                {
                    ApplicationArea = All;
                }
                field("GXL Delta Ranging Required"; Rec."GXL Delta Ranging Required")
                {
                    ApplicationArea = All;
                }
                field("GXL Rolled-Out"; Rec."GXL Rolled-Out")
                {
                    ApplicationArea = All;
                }
                field("GXL LS Live Store"; Rec."GXL LS Live Store")
                {
                    ApplicationArea = All;
                }
                field("GXL LS Store Go-Live Date"; Rec."GXL LS Store Go-Live Date")
                {
                    ApplicationArea = All;
                }
                field("GXL Pre-Live Adj. Reason Code"; Rec."GXL Pre-Live Adj. Reason Code")
                {
                    ApplicationArea = All;
                }
                //PS-2523 VET Clinic transfer order +
                field("GXL VET Store"; Rec."GXL VET Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the store is VET store which is used to specify the transfer order to VET clinic';
                }
                //PS-2523 VET Clinic transfer order -

            }
        }
    }

    actions
    {
    }

}