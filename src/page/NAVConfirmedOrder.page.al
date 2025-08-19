page 50142 "GXL NAV Confirmed Order"
{
    Caption = 'NAV Confirmed Order';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "GXL NAV Confirmed Order";
    Editable = false;
    RefreshOnActivate = true;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of the document that was created in NAV-13.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order number of the document that was created in NAV-13.';
                }
                //ERP-328 +
                field("Version No."; Rec."Version No.")
                {
                    ApplicationArea = All;
                    BlankZero = true;
                    ToolTip = 'Specifies the version number of the order to indicate the the order was changed in NAV13 after synched to LSC.';
                }
                //ERP-328 -
                field("Order Date"; Rec."Order Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the order date of the purchase/transfer order that was created in NAV-13.';
                }
                field("Source of Supply"; Rec."Source of Supply")
                {
                    ApplicationArea = All;
                }
                field("Audit Flag"; Rec."Audit Flag")
                {
                    ApplicationArea = All;
                }
                field("Created Date"; Rec."Created Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date that the purchase/transfer order was created in NAV-13';
                }
                field("Created Time"; Rec."Created Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the time that the purchase/transfer order was created in NAV-13';
                }
                field("Created By User ID"; Rec."Created By User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the User ID that created the purchase/transfer order in NAV-13';
                }
                field("Process Status"; Rec."Process Status")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the process status of the order';
                }
                field("Processed Date Time"; Rec."Processed Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the processed date and time of the order';
                }
                field("Error Message"; Rec."Error Message")
                {
                    ApplicationArea = All;
                }
            }
            part(NAVConfirmedOrderLine; "GXL NAV Confirmed Order Lines")
            {
                ApplicationArea = All;
                Caption = 'Lines';
                //ERP-328 + Add Version No.
                SubPageLink = "Document Type" = field("Document Type"), "Document No." = field("No."), "Version No." = field("Version No.");
            }
            group(PurchaseOrder)
            {
                Caption = 'Purchase Order';
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Pay-to Vendor No."; Rec."Pay-to Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("Vendor Order No."; Rec."Vendor Order No.")
                {
                    ApplicationArea = All;
                }
                field("Expected Receipt Date"; Rec."Expected Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("Prices Including VAT"; Rec."Prices Including VAT")
                {
                    ApplicationArea = All;
                }
                field("International Order"; Rec."International Order")
                {
                    ApplicationArea = All;
                }
            }
            group(TransferOrder)
            {
                Caption = 'Transfer Order';
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ApplicationArea = All;
                }
                field("Transfer-from Contact"; Rec."Transfer-from Contact")
                {
                    ApplicationArea = All;
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = All;
                }
                field("Transfer-to Contact"; Rec."Transfer-to Contact")
                {
                    ApplicationArea = All;
                }
                field("In-Transit Code"; Rec."In-Transit Code")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; Rec."External Document No.")
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
            action(ResetError)
            {
                ApplicationArea = All;
                Caption = 'Reset Error';
                Image = ResetStatus;

                trigger OnAction()
                begin
                    Rec.ResetError();
                    CurrPage.Update(true);
                end;
            }
            action(CreateOrder)
            {
                ApplicationArea = All;
                Caption = 'Create Order';
                Image = CreateDocument;

                trigger OnAction()
                var
                    NAVCreateOrders: Codeunit "GXL NAV Create Orders";
                begin
                    if Rec."Process Status" = Rec."Process Status"::Imported then begin
                        NAVCreateOrders.CheckExistingVersionIsLatest(Rec); //ERP-328 +
                        NAVCreateOrders.CreateOrder(Rec);
                    end;
                end;
            }
        }
    }

    var
}