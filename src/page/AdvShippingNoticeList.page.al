page 50350 "GXL Adv. Shipping Notice List"
{
    Caption = 'Advance Shipping Notice List';
    CardPageID = "GXL Advance Shipping Notice";
    Editable = false;
    PageType = List;
    SourceTable = "GXL ASN Header";
    ApplicationArea = All;
    UsageCategory = Lists;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                }
                field("Original EDI Document No."; Rec."Original EDI Document No.")
                {
                    ApplicationArea = All;
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                    ApplicationArea = All;
                }
                field("Supplier Name"; Rec."Supplier Name")
                {
                    ApplicationArea = All;
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    ApplicationArea = All;
                }
                field("Transfer Order No."; Rec."Transfer Order No.")
                {
                    ApplicationArea = All;
                }
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("Ship-To Code"; Rec."Ship-To Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-To Name"; Rec."Ship-To Name")
                {
                    ApplicationArea = All;
                }
                field("Ship-To Address"; Rec."Ship-To Address")
                {
                    ApplicationArea = All;
                }
                field("Ship-To Address 2"; Rec."Ship-To Address 2")
                {
                    ApplicationArea = All;
                }
                field("Ship-To Post Code"; Rec."Ship-To Post Code")
                {
                    ApplicationArea = All;
                }
                field("Ship-To City"; Rec."Ship-To City")
                {
                    ApplicationArea = All;
                }
                field("Total Containers"; Rec."Total Containers")
                {
                    ApplicationArea = All;
                }
                field("Total Pallets"; Rec."Total Pallets")
                {
                    ApplicationArea = All;
                }
                field("Total Boxes"; Rec."Total Boxes")
                {
                    ApplicationArea = All;
                }
                field("Total Items"; Rec."Total Items")
                {
                    ApplicationArea = All;
                }
                field("Manual Application"; Rec."Manual Application")
                {
                    ApplicationArea = All;
                }
                field("EDI Type"; Rec."EDI Type")
                {
                    ApplicationArea = All;
                }
                field("NAV EDI Document No."; Rec."NAV EDI Document No.")
                {
                    ApplicationArea = All;
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
                Image = ResetStatus;
                Ellipsis = true;
                Promoted = true;

                trigger OnAction()
                var
                    ASNHead: Record "GXL ASN Header";
                begin
                    //PS-2343 +
                    // ResetError();
                    CurrPage.SetSelectionFilter(ASNHead);
                    Rec.ResetError(ASNHead, true);
                    //PS-2343 -
                    CurrPage.UPDATE();
                end;
            }
            action("Versions")
            {
                ApplicationArea = All;
                Caption = 'Versions';
                Image = Versions;
                Promoted = true;
                PromotedCategory = Process;
                trigger OnAction()
                begin
                    Rec.ShowVersions(Rec."Document Type", Rec."No.");
                end;
            }
        }
    }
}