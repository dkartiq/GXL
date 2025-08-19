/// <summary>
/// ERP-NAV Master Data Management
/// </summary>
page 50050 "GXL NAV Item/SKU Log"
{
    Caption = 'NAV Item/SKU Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL NAV Item/SKU Buffer";
    Editable = false;
    LinksAllowed = false;

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
                field("Legacy Item No."; Rec."Legacy Item No.")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                }
                field("First Receipt Date"; Rec."First Receipt Date")
                {
                    ApplicationArea = All;
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                }
                field("Qty. on Purch. Order"; Rec."Qty. on Purch. Order")
                {
                    ApplicationArea = All;
                }
                field("Qty. in Transit"; Rec."Qty. in Transit")
                {
                    ApplicationArea = All;
                }
                field("Date Time Created"; Rec."Date Time Created")
                {
                    ApplicationArea = All;
                }
                field("Date Time Modified"; Rec."Date Time Modified")
                {
                    ApplicationArea = All;
                }
                field("Replication Counter"; Rec."Replication Counter")
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
        }
    }
}