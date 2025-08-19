page 50257 "GXL PDA-Receiving Buffer"
{
    Caption = 'PDA Receiving Buffer';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL PDA-PL Receive Buffer";
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = true;
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
                    Editable = false;
                }
                field(Processed; Rec.Processed)
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Manually Posted"; Rec."Manually Posted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Manually Posted';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Legacy Item No."; Rec."Legacy Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(QtyOrdered; Rec.QtyOrdered)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(QtyToReceive; Rec.QtyToReceive)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(InvoiceQuantity; Rec.InvoiceQuantity)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Claim Quantity"; Rec."Claim Quantity")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Errored; Rec.Errored)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Error Code"; Rec."Error Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Receipt Type"; Rec."Receipt Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Processing Date Time"; Rec."Processing Date Time")
                {
                    ApplicationArea = All;
                }
                field("Received from PDA"; Rec."Received from PDA")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Claim Document Type"; Rec."Claim Document Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Claim Document No."; Rec."Claim Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Claim Document Line No."; Rec."Claim Document Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Return Shipment No."; Rec."Return Shipment No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Purchase Credit Memo No."; Rec."Purchase Credit Memo No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Vendor No."; Rec."Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Purchase Receipt No."; Rec."Purchase Receipt No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Purchase Invoice No."; Rec."Purchase Invoice No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("EDI File Log Entry No."; Rec."EDI File Log Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Post / Send Claim"; Rec."Post / Send Claim")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Entry Closed"; Rec."Entry Closed")
                {
                    ApplicationArea = All;
                    Editable = false;
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
                    Ellipsis = true;

                    trigger OnAction();
                    var
                        PDAReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
                        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
                    begin
                        CurrPage.SetSelectionFilter(PDAReceiveBuffer);
                        NonEDIProcessMgt.ResetError(PDAReceiveBuffer, true);
                        CurrPage.Update();
                    end;
                }
                action(ClearBufferError)
                {
                    ApplicationArea = All;
                    Caption = 'Clear Buffer Error';
                    Image = ClearLog;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    var
                        PDAReceiveBuffer: Record "GXL PDA-PL Receive Buffer";
                        NonEDIProcessMgt: Codeunit "GXL Non-EDI Process Management";
                    begin
                        CurrPage.SetSelectionFilter(PDAReceiveBuffer);
                        NonEDIProcessMgt.ManualClearPDAReceivingBufferErrors(PDAReceiveBuffer, true);
                        CurrPage.Update();
                    end;
                }
                action(OpenDoc)
                {
                    ApplicationArea = All;
                    Caption = 'Open Document';
                    Image = Document;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;

                    trigger OnAction();
                    begin
                        Rec.OpenDocument();
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
                // >> LCB-227
                action("Update Status")
                {
                    ApplicationArea = All;
                    Caption = 'Update Status';
                    Image = Status;
                    Promoted = false;
                    Visible = true;

                    trigger OnAction();
                    var
                        PdaReceivingBuffer: Record "GXL PDA-PL Receive Buffer";
                        ConfirmationQst: Label 'Do you want to update the status for selected lines?';
                    begin
                        if not Confirm(ConfirmationQst, true) then
                            exit;
                        CurrPage.SetSelectionFilter(PdaReceivingBuffer);
                        Rec.UpdateStatus(PdaReceivingBuffer);
                    end;
                }
                // << LCB-227
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