page 50255 "GXL PDA-Staging Purch. Order"
{
    Caption = 'PDA-Staging Purchase Order';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "GXL PDA-Staging Purch. Header";
    Editable = false;
    RefreshOnActivate = true;

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
                field("Buy-from Vendor No."; Rec."Buy-from Vendor No.")
                {
                    ApplicationArea = All;
                }
                field("Buy-from Vendor Name"; Rec."Buy-from Vendor Name")
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
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                }
                group(OrderDate)
                {
                    ShowCaption = false;
                    field("Order Date"; Rec."Order Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Expected Receipt Date"; Rec."Expected Receipt Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Order Status"; Rec."Order Status")
                    {
                        ApplicationArea = All;
                    }
                    field("Total Order Value"; Rec."Total Order Value")
                    {
                        ApplicationArea = All;
                    }
                    field("Total Order Qty"; Rec."Total Order Qty")
                    {
                        ApplicationArea = All;
                    }
                    field("Created Date"; Rec."Created Date")
                    {
                        ApplicationArea = All;
                    }
                    field("Created Time"; Rec."Created Time")
                    {
                        ApplicationArea = All;
                    }
                    field("Created By User ID"; Rec."Created By User ID")
                    {
                        ApplicationArea = All;
                    }
                }
            }

            part(Lines; "GXL PDA-Staging Purch. Lines")
            {
                Caption = 'Lines';
                SubPageLink = "Document No." = field("No.");
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateOrder)
            {
                ApplicationArea = All;
                Caption = 'Create Purchase Order';
                Image = CreateDocument;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    Rec.ConvertStagingDocument();
                    CurrPage.Update(false);
                end;
            }
        }
    }

    var

}