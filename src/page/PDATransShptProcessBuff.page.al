page 50262 "GXL PDA-TransShpt Process Buff"
{
    Caption = 'PDA Transfer Shpt. Process Buffer';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL PDA-TransShpt Process Buff";
    Editable = false;
    RefreshOnActivate = true;

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
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; Rec."Line No.")
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
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                }
                field("Shipment Date"; Rec."Shipment Date")
                {
                    ApplicationArea = All;
                }
                field("Created by User ID"; Rec."Created by User ID")
                {
                    ApplicationArea = All;
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    ApplicationArea = All;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                }
                field("Processing Date Time"; Rec."Processing Date Time")
                {
                    ApplicationArea = All;
                }
                field(Errored; Rec.Errored)
                {
                    ApplicationArea = All;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
                //PS-2046+
                field("MIM User ID"; Rec."MIM User ID")
                {
                    ApplicationArea = All;
                }
                //PS-2046-
                //PS-2523 VET Clinic transfer order +
                field("Process Status"; Rec."Process Status")
                {
                    ApplicationArea = All;
                }
                field("Transfer Shipment No."; Rec."Transfer Shipment No.")
                {
                    ApplicationArea = All;
                }
                field("Transfer Receipt No."; Rec."Transfer Receipt No.")
                {
                    ApplicationArea = All;
                }
                field("Sales Order No."; Rec."Sales Order No.")
                {
                    ApplicationArea = All;
                }
                field("Posted Sales Invoice No."; Rec."Posted Sales Invoice No.")
                {
                    ApplicationArea = All;
                }
                //PS-2523 VET Clinic transfer order -
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            group(Functions)
            {
                Caption = 'Fuctions';
                action(ResetError)
                {
                    ApplicationArea = All;
                    Caption = 'Reset Error';
                    Image = ResetStatus;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    Ellipsis = true;

                    trigger OnAction();
                    var
                        PDATransShptProcessBuff: Record "GXL PDA-TransShpt Process Buff";
                        PDAProcessTransShpts: Codeunit "GXL PDA-Process Trans Shpts";
                    begin
                        CurrPage.SetSelectionFilter(PDATransShptProcessBuff);
                        PDAProcessTransShpts.ResetError(PDATransShptProcessBuff);
                        CurrPage.Update();
                    end;
                }
            }
        }
    }
}