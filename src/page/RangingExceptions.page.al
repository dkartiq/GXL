page 50005 "GXL Ranging Exceptions"
{
    Caption = 'Ranging Exceptions';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Ranging Exceptions";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                }
                field(Range; Rec.Range)
                {
                    ApplicationArea = All;
                }
                field("Last Modified Date"; Rec."Last Modified Date")
                {
                    ApplicationArea = All;
                }
            }
        }
        area(Factboxes)
        {

        }
    }

    actions
    {
        area(Processing)
        {
            action(UpdateRanging)
            {
                Caption = 'Update Product Ranging';
                ApplicationArea = All;
                Image = CreateSKU;

                trigger OnAction()
                var
                    RangingException: Record "GXL Ranging Exceptions";
                    UpdateProdStoreRanging: Report "GXL UpdateProdRangingException";
                begin
                    CurrPage.SetSelectionFilter(RangingException);
                    UpdateProdStoreRanging.SetTableView(RangingException);
                    UpdateProdStoreRanging.RunModal();
                end;
            }
            action(ProdRangingSetup)
            {
                Caption = 'Product Ranging Setup';
                ApplicationArea = All;
                Image = SKU;
                RunObject = page "GXL Product-Store Ranging List";
            }

        }
    }
}