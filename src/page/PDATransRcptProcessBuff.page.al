page 50263 "GXL PDA-TransRcpt Process Buff"
{
    Caption = 'PDA Transfer Receipt Process Buffer';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL PDA-TransRcpt Process Buff";
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
                field("Receipt Date"; Rec."Receipt Date")
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
                        PDATransRcptProcessBuff: Record "GXL PDA-TransRcpt Process Buff";
                        PDAProcessTransRcpts: Codeunit "GXL PDA-Process Trans Receipts";
                    begin
                        CurrPage.SetSelectionFilter(PDATransRcptProcessBuff);
                        PDAProcessTransRcpts.ResetError(PDATransRcptProcessBuff);
                        CurrPage.Update();
                    end;
                }
            }
        }
    }
}