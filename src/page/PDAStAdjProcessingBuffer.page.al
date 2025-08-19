page 50259 "GXL PDA-StAdjProcessing Buffer"
{
    Caption = 'PDA Stock Adjustment Processing Buffer';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL PDA-StAdjProcessing Buffer";
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
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field(Type; Rec.Type)
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
                field("Stock on Hand"; Rec."Stock on Hand")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                }
                field("Created Date Time"; Rec."Created Date Time")
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
                field("Error Code"; Rec."Error Code")
                {
                    ApplicationArea = All;
                }
                field("Claim-to Document Type"; Rec."Claim-to Document Type")
                {
                    ApplicationArea = All;
                }
                field("Claim-to Order No."; Rec."Claim-to Order No.")
                {
                    ApplicationArea = All;
                }
                field("CLaim-to Receipt No."; Rec."CLaim-to Receipt No.") { ApplicationArea = All; }  // >> LCB-239 <<
                field(Narration; Rec.Narration) { ApplicationArea = All; }  // >> LCB-239 <<
                field("Claim-to Document No."; Rec."Claim-to Document No.")
                {
                    ApplicationArea = All;
                }
                field("Claim-to Vendor No."; Rec."Claim-to Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Vendor Ullaged Status"; Rec."Vendor Ullaged Status")
                {
                    ApplicationArea = All;
                }
                field("Claim Document Type"; Rec."Claim Document Type")
                {
                    ApplicationArea = All;
                }
                field("Claim Document No."; Rec."Claim Document No.")
                {
                    ApplicationArea = All;
                }
                field("Posted Credit Memo No."; Rec."Posted Credit Memo No.")
                {
                    ApplicationArea = All;
                }
                field("Posted Return Shipment No."; Rec."Posted Return Shipment No.")
                {
                    ApplicationArea = All;
                }
                field("Post / Send Claim"; Rec."Post / Send Claim")
                {
                    ApplicationArea = All;
                }
                field(Closed; Rec.Closed)
                {
                    ApplicationArea = All;
                }
                field("RMS ID"; Rec."RMS ID")
                {
                    ApplicationArea = All;
                }
                //PS-2046+
                field("MIM User ID"; Rec."MIM User ID")
                {
                    ApplicationArea = All;
                }
                //PS-2046-
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

                    trigger OnAction();
                    var
                        PDAStAdjProcessingBuff: Record "GXL PDA-StAdjProcessing Buffer";
                    begin
                        //PS-2343 +
                        // ResetError();
                        CurrPage.SetSelectionFilter(PDAStAdjProcessingBuff);
                        Rec.ResetError(PDAStAdjProcessingBuff, true);
                        //PS-2343 -
                        CurrPage.Update();
                    end;
                }
                action(ManualApplication)
                {
                    ApplicationArea = All;
                    Caption = 'Manual Application';
                    Image = Apply;
                    Visible = false;

                    trigger OnAction()
                    begin
                        Rec.SetReturnOrderManualApplicationFlag(true);
                        CurrPage.Update();
                    end;
                }
                action(OpenClaimDoc)
                {
                    ApplicationArea = All;
                    Caption = 'Open Claim Document';
                    Image = CreditMemo;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    begin
                        Rec.OpenClaimDocument();
                    end;
                }
            }
        }
        area(Navigation)
        {
            group(EDI)
            {
                Caption = 'EDI Log Entries';
                action(EDIFileLog)
                {
                    ApplicationArea = All;
                    Caption = 'EDI File Log';
                    Image = Log;
                    RunObject = Page "GXL EDI File Log";
                    RunPageLink = "Entry No." = field("EDI File Log Entry No.");
                }
                action(EDIDocLog)
                {
                    ApplicationArea = All;
                    Caption = 'EDI Document Log';
                    Image = Log;
                    RunObject = Page "GXL EDI Document Log";
                    RunPageView = sorting("EDI File Log Entry No.");
                    RunPageLink = "EDI File Log Entry No." = field("EDI File Log Entry No.");
                }
            }
        }
    }
}