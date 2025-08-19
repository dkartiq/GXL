page 50355 "GXL Advance Shipping Notice"
{
    Caption = 'Advance Shipping Notice';
    PageType = Document;
    UsageCategory = Documents;
    ApplicationArea = All;
    SourceTable = "GXL ASN Header";
    DelayedInsert = true;
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    Editable = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                field("Document Type"; Rec."Document Type")
                {
                }
                field("No."; Rec."No.")
                {
                }
                field(Status; Rec.Status)
                {
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                }
                field("Supplier Name"; Rec."Supplier Name")
                {
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                }
                field("Transfer Order No."; Rec."Transfer Order No.")
                {
                }
                field("Order Date"; Rec."Order Date")
                {
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                }
                field("Ship-To Code"; Rec."Ship-To Code")
                {
                }
                field("Ship-To Name"; Rec."Ship-To Name")
                {
                }
                field("Ship-To Address"; Rec."Ship-To Address")
                {
                }
                field("Ship-To Address 2"; Rec."Ship-To Address 2")
                {
                }
                field("Ship-To Post Code"; Rec."Ship-To Post Code")
                {
                }
                field("Ship-To City"; Rec."Ship-To City")
                {
                }
                field("Total Containers"; Rec."Total Containers")
                {
                }
                field("Total Pallets"; Rec."Total Pallets")
                {
                }
                field("Total Boxes"; Rec."Total Boxes")
                {
                }
                field("Total Items"; Rec."Total Items")
                {
                }
                field("Claim Document No."; Rec."Claim Document No.")
                {
                }
                field("Claim Credit Memo No."; Rec."Claim Credit Memo No.")
                {
                }
                field("Manual Application"; Rec."Manual Application")
                {
                }
                // field(Audit; Audit)
                // {
                // }
                field("EDI Type"; Rec."EDI Type")
                {
                }
                field("Received from PDA"; Rec."Received from PDA")
                {
                }
                field("Original EDI Document No."; Rec."Original EDI Document No.")
                {
                }
                field("NAV EDI Document No."; Rec."NAV EDI Document No.")
                {
                }
                field("EDI File Log Entry No."; Rec."EDI File Log Entry No.")
                {
                    ApplicationArea = All;
                }
                field("NAV EDI File Log Entry No."; Rec."NAV EDI File Log Entry No.")
                {
                    ApplicationArea = All;
                }
            }
            part("GXL Advance Shipping Notice SF"; "GXL Advance Shipping Notice SF")
            {
                SubPageLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(Edit)
            {
                ApplicationArea = all;
                Image = Edit;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.EditASN();
                end;
            }
            action("Create New Version")
            {
                ApplicationArea = all;
                Image = NewBranch;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.CreateNewVer(Rec."Document Type", Rec."No.", true);
                end;
            }
        }
        area(navigation)
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
            action(ManualApplication)
            {
                ApplicationArea = All;
                Caption = 'Manual Application';
                Image = Apply;
                Ellipsis = true;
                Promoted = true;
                trigger OnAction()
                begin
                    Rec.SetReturnOrderManualApplicationFlag(TRUE);
                    CurrPage.UPDATE();
                end;
            }
        }
    }
}

