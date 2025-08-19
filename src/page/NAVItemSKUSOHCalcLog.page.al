/// <summary>
/// ERP-NAV Master Data Management
/// </summary>
page 50051 "GXL NAV Item/SKU SOH-Calc. Log"
{
    Caption = 'NAV Item/SKU SOH-Calculation Log';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "GXL NAV Item/SKU SOH-Calc. Log";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Last Item Ledger Entry No."; Rec."Last Item Ledger Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Created Date Time"; Rec."Created Date Time")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}