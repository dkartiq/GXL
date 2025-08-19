
pageextension 50013 "GXL Transfer Order" extends "Transfer Order"
{
    layout
    {
        addlast(General)
        {
            // >> 002
            field("GXL RMS ID"; Rec."GXL RMS ID")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the RMS ID field.', Comment = '%';
            }
            field("GXL RMS Transfer No."; Rec."GXL RMS Transfer No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the value of the RMS Transfer No. field.', Comment = '%';
            }
            // << 002
            field("GXL Expected Receipt Date"; Rec."GXL Expected Receipt Date")
            {
                ApplicationArea = All;
            }
            field("GXL Last Shipment No."; Rec."Last Shipment No.")
            {
                ApplicationArea = All;
                Editable = false;
            }
            // >> HP2-SPRINT2
            field("GXL Transport Type"; Rec."GXL Transport Type")
            {
                ApplicationArea = All;
            }
            // << HP2-SPRINT2

        }
        addafter("Foreign Trade")
        {
            group("GXL GXLSupplyChain")
            {
                Caption = 'Supply Chain';
                // >> 002
                field("GXL Order Type"; Rec."GXL Order Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Order Type field.', Comment = '%';
                }
                // << 002
                field("GXL Source of Supply"; Rec."GXL Source of Supply")
                {
                    ApplicationArea = All;
                }
                // >> 002
                field("GXL JDA Load ID"; Rec."GXL JDA Load ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the JDA Load ID field.', Comment = '%';
                }
                field("JDA PO No."; Rec."JDA PO No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the JDA PO No. field.', Comment = '%';
                }
                // << 002
                field("GXL Order Status"; Rec."GXL Order Status")
                {
                    ApplicationArea = All;
                }
                // >> 002
                field("GXL LSC Received "; Rec."GXL LSC Received ")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the LSC Received field.', Comment = '%';
                }
                field("GXL Transport Type(2)"; Rec."GXL Transport Type")
                {
                    Caption = 'Transport Type';
                    ApplicationArea = All;
                }
                field("Distributor Name"; Rec."Distributor Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Distributor Name field.', Comment = '%';
                }
                field("GXL Total Order Quantity"; Rec."GXL Total Order Quantity")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Order Quantity field.', Comment = '%';
                }
                field("GXL Total Value"; Rec."GXL Total Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Total Value field.', Comment = '%';
                }
                field("GXL Send To JDA"; Rec."GXL Send To JDA")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Send To JDA field.', Comment = '%';
                }
                field("GXL Last JDA Date Modified"; Rec."GXL Last JDA Date Modified")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Last JDA Date Modified field.', Comment = '%';
                }
                field("GXL ASN Created"; Rec."GXL ASN Created")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ASN Created field.', Comment = '%';
                }
                field("GXL ASN Confirmed"; Rec."GXL ASN Confirmed")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the ASN Confirmed field.', Comment = '%';
                }
            }
            group("GXL Third Party Data")
            {
                Caption = 'Third Party Data';
                field("GXL 3PL"; Rec."GXL 3PL")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3PL field.', Comment = '%';
                }
                field("GXL 3PL File Sent"; Rec."GXL 3PL File Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3PL File Sent field.', Comment = '%';
                }
                field("GXL 3PL File Receive"; Rec."GXL 3PL File Receive")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3PL File Receive field.', Comment = '%';
                }
                field("GXl 3PL Cancel Request Sent"; Rec."GXl 3PL Cancel Request Sent")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3PL Cancel Request Sent field.', Comment = '%';
                }
                field("GXl 3PL Cancel Req Receieved"; Rec."GXl 3PL Cancel Req Receieved")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3PL Cancel Request Receieved field.', Comment = '%';
                }
                field("GXL 3PL File Sent Date"; Rec."GXL 3PL File Sent Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3PL File Sent Date field.', Comment = '%';
                }
                field("GXl 3PL Cancel Date"; Rec."GXl 3PL Cancel Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3PL Cancel Date field.', Comment = '%';
                }
                field("GXl 3PL File Updated"; Rec."GXl 3PL File Updated")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the 3PL File Updated field.', Comment = '%';
                }
                field("GXl PDA Integer"; Rec."GXl PDA Integer")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the PDA Integer field.', Comment = '%';
                }
            }
            group("GXL Integration")
            {
                Caption = 'Integration';
                field("GXL Date Sent to Store"; Rec."GXL Date Sent to Store")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Date Sent to Store field.', Comment = '%';
                }
                field("GXL RMS Worksheet ID"; Rec."GXL RMS Worksheet ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the RMS Worksheet ID field.', Comment = '%';
                }
            }
            // << 002
        }
        //PS-2523 VET Clinic transfer order +
        addlast("Transfer-to")
        {
            field("GXL VET Store Code"; Rec."GXL VET Store Code")
            {
                ApplicationArea = All;
                Editable = false;
            }
        }
        //PS-2523 VET Clinic transfer order +

    }
    actions
    {
        addafter(Post)
        {
            action("GXL PostInvAdj")
            {
                Caption = 'Post Non-Live Inv. Adj.';
                Image = TestFile;
                trigger OnAction()
                var
                    AdjustInv: Codeunit "GXL Adj. Trans. Order Inv.";
                begin
                    AdjustInv.PostTestAdjustment(Rec);
                end;
            }
        }
    }

}