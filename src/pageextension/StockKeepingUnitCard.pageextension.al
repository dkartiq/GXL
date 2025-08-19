pageextension 50005 "GXL Stockkeeping Unit Card" extends "Stockkeeping Unit Card"
{
    layout
    {
        addafter(Control1907509201) // Warehouse
        {
            group("GXL GXLSupplyChain")
            {
                Caption = 'Supply Chain';
                field("GXL Product Status"; Rec."GXL Product Status")
                {
                    ApplicationArea = All;
                }
                field("GXL Product Range Code"; Rec."GXL Product Range Code")
                {
                    ApplicationArea = All;
                }
                field("GXL Division Code"; GXLItem."LSC Division Code")
                {
                    Caption = 'Division Code';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Division Description"; GXL_strText[5])
                {
                    ApplicationArea = All;
                    Caption = 'Division Description';
                    Editable = false;
                }
                field("GXL Category Code"; Rec."GXL Category Code")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Category Code Description"; GXL_strText[2])
                {
                    ApplicationArea = All;
                    Caption = 'Category Description';
                    Editable = false;
                }
                field("GXL Sub Category3 Code"; GXLItem."GXL Sub Category3 Code")
                {
                    Caption = 'Sub Category3 Code';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Sub Category3 Description"; GXL_strText[3])
                {
                    ApplicationArea = All;
                    Caption = 'Sub Category3 Description';
                    Editable = false;
                }
                field("GXL Sub Category4 Code"; GXLItem."GXL Sub Category4 Code")
                {
                    Caption = 'Sub Category4 Code';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Sub Category4 Description"; GXL_strText[4])
                {
                    ApplicationArea = All;
                    Caption = 'Sub Category4 Description';
                    Editable = false;
                }
                field("GXL Product Type"; Rec."GXL Product Type")
                {
                    ApplicationArea = All;
                }
                field("GXL Source of Supply"; Rec."GXL Source of Supply")
                {
                    ApplicationArea = All;
                }
                field("GXL Source of Supply Code"; Rec."GXL Source of Supply Code")
                {
                    ApplicationArea = All;
                }
                field("GXL Supplier Number"; Rec."GXL Supplier Number")
                {
                    ApplicationArea = All;
                }
                field("GXL Agent Number"; Rec."GXL Agent Number")
                {
                    ApplicationArea = All;
                }
                field("GXL Distributor Number"; Rec."GXL Distributor Number")
                {
                    ApplicationArea = All;
                }
                field("GXL Order Pack (OP)"; Rec."GXL Order Pack (OP)")
                {
                    ApplicationArea = All;
                }
                field("GXL Order Multiple (OM)"; Rec."GXL Order Multiple (OM)")
                {
                    ApplicationArea = All;
                }
                field("GXL SC-Size"; Rec."GXL SC-Size")
                {
                    ApplicationArea = All;
                }
                field("GXL NAV First Receipt Date"; Rec."GXL NAV First Receipt Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies first receipt date from NAV13 system';
                }
                field("GXL GXl First Receipt Date"; Rec."GXl First Receipt Date")
                {
                    ApplicationArea = All;
                }
                field("GXL Age of Item"; Rec."GXL Age of Item")
                {
                    ApplicationArea = All;
                }
                field("GXL Expiry Date Flag"; Rec."GXL Expiry Date Flag")
                {
                    ApplicationArea = All;
                }
                field("GXL Forecast Flag"; Rec."GXL Forecast Flag")
                {
                    ApplicationArea = All;
                }
                field("GXL Replenish Flag"; Rec."GXL Replenish Flag")
                {
                    ApplicationArea = All;
                }
                field("GXL Effective Date"; Rec."GXL Effective Date")
                {
                    ApplicationArea = All;
                }
                field("GXL Quit Date"; Rec."GXL Quit Date")
                {
                    ApplicationArea = All;
                }
                field("GXL Discontinued Date"; Rec."GXL Discontinued Date")
                {
                    ApplicationArea = All;
                }
                field("GXL On-Line Status"; Rec."GXL On-Line Status")
                {
                    ApplicationArea = All;
                }
                field("GXL Like Item"; Rec."GXL Like Item")
                {
                    ApplicationArea = All;
                }
                field("GXL Like Item Factor"; Rec."GXL Like Item Factor")
                {
                    ApplicationArea = All;
                }
                field("GXL Supersession Item"; Rec."GXL Supersession Item")
                {
                    ApplicationArea = All;
                }
                field("GXL Parent Item"; Rec."GXL Parent Item")
                {
                    ApplicationArea = All;
                }
                field("GXL Parent Quantity"; Rec."GXL Parent Quantity")
                {
                    ApplicationArea = All;
                }
                field("GXL GXLUnitCost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL GXLUnitPrice"; GXLItem."Unit Price")
                {
                    Caption = 'Unit Price';
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Order Minimum"; Rec."GXL Order Minimum")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Order Increment"; Rec."GXL Order Increment")
                {
                    ApplicationArea = All;
                }
                field("GXL MPL Factor"; Rec."GXL MPL Factor")
                {
                    ApplicationArea = All;
                }
                field("GXL Facing"; Rec."GXL Facing")
                {
                    ApplicationArea = All;
                }
                field("GXL Minimum Presentation Level"; Rec."GXL Minimum Presentation Level")
                {
                    ApplicationArea = All;
                }
                field("GXL Shelf Capacity"; Rec."GXL Shelf Capacity")
                {
                    ApplicationArea = All;
                }
                field("GXL Ranged"; Rec."GXL Ranged")
                {
                    ApplicationArea = All;
                }
                field("GXL New Ranging Flag"; Rec."GXL New Ranging Flag")
                {
                    ApplicationArea = All;
                }
                field("GXL OOS Reason Code"; Rec."GXL OOS Reason Code")
                {
                    ApplicationArea = All;
                }
                field("GXL Import Flag"; Rec."GXL Import Flag")
                {
                    ApplicationArea = All;
                }
                field("GXL Private Label Flag"; Rec."GXL Private Label Flag")
                {
                    ApplicationArea = All;
                }
                field("GXL Total SOH"; Rec."GXL Total SOH")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Availabile SOH"; Rec."GXL Availabile SOH")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Stock Held"; Rec."GXL Stock Held")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Held SOH"; Rec."GXL Held SOH")
                {
                    ApplicationArea = All;
                    Editable = false;
                }

            }
            group("GXL GXLSales Price Setup")
            {
                Caption = 'Sales Price Setup';
                field("GXL Sales Price Type"; Rec."GXL Sales Price Type")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        Clear(GXLItem);
        Clear(GXL_strText);
        if GXLItem.Get(Rec."Item No.") then
            GXLItem.GXLGetFamilyStructureDescText(GXL_strText);
    end;

    var
        GXLItem: Record Item;
        GXL_strText: array[5] of Text;

}