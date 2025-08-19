page 50390 "GXL P2P Invoice List"
{
    Caption = 'P2P Invoice List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL PO INV Header";
    SourceTableView = sorting("EDI Vendor Type") where("EDI Vendor Type" = filter("Point 2 Point" | "Point 2 Point Contingency"));
    Editable = false;
    CardPageId = "GXL P2P Invoice";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Supplier Name"; Rec."Supplier Name")
                {
                    ApplicationArea = All;
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Invoice Received Date"; Rec."Invoice Received Date")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("ASN Number"; Rec."ASN Number")
                {
                    ApplicationArea = All;
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("EDI File Log Entry No."; Rec."EDI File Log Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ApplicationArea = All;
                }
                field("P2P Supplier ABN"; Rec."P2P Supplier ABN")
                {
                    ApplicationArea = All;
                }
                field("Manual Processing Status"; Rec."Manual Processing Status")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {
            systempart(Notes; Notes) { }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ManualAcceptInvoice)
            {
                ApplicationArea = All;
                Caption = 'Manually Accept Invoice';
                Image = PostDocument;

                trigger OnAction();
                var
                    EDIProcessInvoice: Codeunit "GXL EDI-Process Invoice";
                begin
                    EDIProcessInvoice.SetManualProcessOptions(true, false);
                    EDIProcessInvoice.Run(Rec);
                end;
            }
        }
        area(Navigation)
        {
            action("EDI File Log")
            {
                ApplicationArea = All;
                Caption = 'EDI File Log';
                Image = Log;
                RunObject = Page "GXL EDI File Log";
                RunPageLink = "Entry No." = FIELD("EDI File Log Entry No.");
                RunPageView = SORTING("Entry No.");
            }
            action("EDI Document Log")
            {
                ApplicationArea = All;
                Caption = 'EDI Document Log';
                Image = Log;
                RunObject = Page "GXL EDI Document Log";
                RunPageLink = "EDI File Log Entry No." = FIELD("EDI File Log Entry No.");
                RunPageMode = View;
                RunPageView = SORTING("Entry No.");
            }

        }
    }
}