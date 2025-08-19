page 50387 "GXL EDI Invoice List"
{
    Caption = 'EDI Invoice List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL PO INV Header";
    SourceTableView = sorting("EDI Vendor Type") where("EDI Vendor Type" = filter(VAN));
    Editable = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    // trigger OnAssistEdit()
                    // begin
                    //     Rec.OpenCard(Rec."No.");
                    // end;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Original Inv No."; Rec."Original Inv No.")
                {
                    ApplicationArea = all;
                }
                field("Vendor Invoice No."; Rec."Vendor Invoice No.")
                {
                    ApplicationArea = all;
                }
                field("Invoice Received Date"; Rec."Invoice Received Date")
                {
                    ApplicationArea = All;
                }
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Buyer ABN"; Rec."Buyer ABN")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Supplier ABN"; Rec."Supplier ABN")
                {
                    ApplicationArea = All;
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
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                }
                field("Amount Incl. VAT"; Rec."Amount Incl. VAT")
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
                field("Manual Processing Status"; Rec."Manual Processing Status")
                {
                    ApplicationArea = All;
                }
                field("Original EDI Document No."; Rec."Original EDI Document No.")
                {
                    ApplicationArea = All;
                }
                field("NAV EDI Document No."; Rec."NAV EDI Document No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            // >> 001 HAR2-513 21.07.2025 MAY HP2-Sprint2-Changes  
            action("Open Card")
            {
                trigger OnAction()
                begin
                    Rec.OpenCard(Rec."No.");
                end;
            }
            action("Create new version")
            {
                ApplicationArea = All;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
                Caption = 'Create New Version';
                Image = NewDocument;
                Enabled = (Rec.Status = Rec.Status::"Validation Error") or (Rec.status = Rec.Status::"Processing Error") or (Rec.Status = Rec.status::"Return Credit Posting Error");
                trigger OnAction()
                begin
                    Rec.CreateNewVer(Rec."No.", true);
                end;
            }
            // << 001 HAR2-513 21.07.2025 MAY HP2-Sprint2-Changes
            action(ManualAcceptInvoice)
            {
                ApplicationArea = All;
                Caption = 'Manually Accept Invoice';
                Image = PostDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedOnly = true;
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
    }
}