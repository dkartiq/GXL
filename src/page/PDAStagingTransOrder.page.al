page 50252 "GXL PDA-Staging Trans. Order"
{
    Caption = 'PDA-Staging Transfer Order';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Documents;
    SourceTable = "GXL PDA-Staging Trans. Header";
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
                field("Transfer-from Code"; Rec."Transfer-from Code")
                {
                    ApplicationArea = All;
                }
                field("Transfer-from Name"; Rec."Transfer-from Name")
                {
                    ApplicationArea = All;
                }
                field("Transfer-to Code"; Rec."Transfer-to Code")
                {
                    ApplicationArea = All;
                }
                field("Transfer-to Name"; Rec."Transfer-to Name")
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
                    field("Order Status"; Rec."Order Status")
                    {
                        ApplicationArea = All;
                    }
                    field("Total Order Quantity"; Rec."Total Order Quantity")
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

            part(Lines; "GXL PDA-Staging Trans. Lines")
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
                Caption = 'Create Transfer Order';
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