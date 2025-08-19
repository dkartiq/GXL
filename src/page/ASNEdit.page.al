page 10016860 "GXL ASN - Edit"
{
    Caption = 'Advance Shipping Notice - Edit';
    PageType = Document;
    ApplicationArea = All;
    SourceTable = "GXL ASN Header";
    DelayedInsert = true;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Document Type"; Rec."Document Type")
                {
                    Editable = false;
                }
                field("No."; Rec."No.")
                {
                    Editable = false;
                }
                field(Status; Rec.Status)
                {
                    Editable = false;
                }
                field("Supplier No."; Rec."Supplier No.")
                {
                    Editable = false;
                }
                field("Supplier Name"; Rec."Supplier Name")
                {
                    Editable = false;
                }
                field("Purchase Order No."; Rec."Purchase Order No.")
                {
                    Editable = false;
                }
                field("Transfer Order No."; Rec."Transfer Order No.")
                {
                    Editable = false;
                }
                field("Order Date"; Rec."Order Date")
                {
                    Editable = false;
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    Editable = false;
                }
                field("Ship-To Code"; Rec."Ship-To Code")
                {
                    Editable = false;
                }
                field("Ship-To Name"; Rec."Ship-To Name")
                {
                    Editable = false;
                }
                field("Ship-To Address"; Rec."Ship-To Address")
                {
                    Editable = false;
                }
                field("Ship-To Address 2"; Rec."Ship-To Address 2")
                {
                    Editable = false;
                }
                field("Ship-To Post Code"; Rec."Ship-To Post Code")
                {
                    Editable = false;
                }
                field("Ship-To City"; Rec."Ship-To City")
                {
                    Editable = false;
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
                    Editable = false;
                }
                field("Claim Credit Memo No."; Rec."Claim Credit Memo No.")
                {
                    Editable = false;
                }
                field("Manual Application"; Rec."Manual Application")
                {
                    Editable = false;
                }
                field("EDI Type"; Rec."EDI Type")
                {
                    Editable = false;
                }
                field("Received from PDA"; Rec."Received from PDA")
                {
                    Editable = false;
                }
                field("Original EDI Document No."; Rec."Original EDI Document No.")
                {
                    Editable = false;
                }
                field("NAV EDI Document No."; Rec."NAV EDI Document No.")
                {
                    Editable = false;
                }
                field("EDI File Log Entry No."; Rec."EDI File Log Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("NAV EDI File Log Entry No."; Rec."NAV EDI File Log Entry No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
            part("GXL ASN SF - Edit"; "GXL ASN SF - Edit")
            {
                SubPageLink = "Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.");
            }
        }
    }
    trigger OnAfterGetRecord()
    begin
        if not Rec.IsEditAllowed(Rec, true) then
            CurrPage.Close();
    end;
}

