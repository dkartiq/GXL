page 50388 "GXL EDI Invoice"
{
    Caption = 'EDI Invoice';
    PageType = Card;
    ApplicationArea = All;
    InsertAllowed = false; // 001 HAR2-513 28.07.2025 MAY HP2-Sprint2-Changes
    DeleteAllowed = false;
    SourceTable = "GXL PO INV Header";
    SourceTableView = sorting("EDI Vendor Type") where("EDI Vendor Type" = filter(VAN));

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
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = All;
                }
                field("Invoice Received Date"; Rec."Invoice Received Date")
                {
                    ApplicationArea = All;
                }
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Buyer ABN"; Rec."Buyer ABN")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Supplier ABN"; Rec."Supplier ABN")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Ship For"; Rec."Ship For")
                {
                    ApplicationArea = All;
                }
                field("Invoice Type"; Rec."Invoice Type")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("ASN Number"; Rec."ASN Number")
                {
                    ApplicationArea = All;
                }
                field("Original ASN No."; Rec."Original ASN No.")
                {
                    ApplicationArea = All;
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
                {
                    ApplicationArea = All;
                }
                field("Total GST"; Rec."Total GST")
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
                    Editable = false;
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Manual Processing Status"; Rec."Manual Processing Status")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Original EDI Document No."; Rec."Original EDI Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("NAV EDI Document No."; Rec."NAV EDI Document No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part(EDIInvoiceLines; "GXL EDI Invoice Line")
            {
                Caption = 'Lines';
                SubPageLink = "INV No." = field("No.");
            }
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
            // >> 001 HAR2-513 21.07.2025 MAY HP2-Sprint2-Changes  
            action("Versions")
            {
                ApplicationArea = All;
                Caption = 'Versions';
                Image = Versions;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                trigger OnAction()
                begin
                    Rec.ShowVersions(Rec."Original Inv No.");
                end;
            }
            // << 001 HAR2-513 21.07.2025 MAY HP2-Sprint2-Changes  
        }
        // >> 001 HAR2-513 21.07.2025 MAY HP2-Sprint2-Changes
        area(Processing)
        {
            action("Create new version")
            {
                ApplicationArea = All;
                Caption = 'Create New Version';
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Image = NewDocument;
                trigger OnAction()
                begin
                    rec.CreateNewVer(Rec."No.", true);
                end;
            }
            action("Reset Error")
            {
                ApplicationArea = All;
                Caption = 'Reset Error';
                Ellipsis = true;
                Image = ResetStatus;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;

                trigger OnAction()
                begin
                    Rec.ResetError();
                    CurrPage.UPDATE();
                end;
            }
        }
    }
}