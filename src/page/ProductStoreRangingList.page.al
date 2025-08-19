page 50006 "GXL Product-Store Ranging List"
{
    Caption = 'Product-Store Ranging List';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL Product-Store Ranging";
    InsertAllowed = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                }
                field("Product Status"; Rec."Product Status")
                {
                    ApplicationArea = All;
                }
                field("Store Code"; Rec."Store Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Store Name"; Rec."Store Name")
                {
                    ApplicationArea = All;
                }
                field(Ranged; Rec.Ranged)
                {
                    ApplicationArea = All;
                }
                field("Effective Date"; Rec."Effective Date")
                {
                    ApplicationArea = All;
                }
                field("Deleted Date"; Rec."Deleted Date")
                {
                    ApplicationArea = All;
                }
                field("Last Deleted Date"; Rec."Last Deleted Date")
                {
                    ApplicationArea = All;
                }
                field(Exceptions; Rec.Exceptions)
                {
                    ApplicationArea = All;
                }
                field("Modified Date"; Rec."Modified Date")
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
        }
    }
}