page 50391 "GXL P2P Invoice"
{
    Caption = 'P2P Invoice';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "GXL PO INV Header";
    SourceTableView = sorting("EDI Vendor Type") where("EDI Vendor Type" = filter("Point 2 Point" | "Point 2 Point Contingency"));
    Editable = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
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
                field("Supplier Name"; Rec."Supplier Name")
                {
                    ApplicationArea = All;
                }
                field("P2P Supplier ABN"; Rec."P2P Supplier ABN")
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
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("EDI File Log Entry No."; Rec."EDI File Log Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Manual Processing Status"; Rec."Manual Processing Status")
                {
                    ApplicationArea = All;
                }
            }
            part(EDIInvoiceLines; "GXL EDI Invoice Line")
            {
                Caption = 'Lines';
                SubPageLink = "INV No." = field("No.");
            }
        }
        area(Factboxes)
        {
            systempart(Notes; Notes) { }
        }

    }

    actions
    {
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
            action("Reset Error")
            {
                ApplicationArea = All;
                Caption = 'Reset Error';
                Ellipsis = true;
                Image = ResetStatus;
                Promoted = true;

                trigger OnAction()
                begin
                    Rec.ResetError();
                    CurrPage.UPDATE();
                end;
            }
        }
    }
}