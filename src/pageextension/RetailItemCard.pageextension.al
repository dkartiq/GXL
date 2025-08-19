pageextension 50007 "GXL Retail Item Card" extends "LSC Retail Item Card"
{
    layout
    {
        addafter("Standard Cost")
        {
            field("GXL Standard Cost"; Rec."GXL Standard Cost")
            {
                ApplicationArea = All;
            }
        }
        addbefore(Warehouse)
        {
            group("GXL GXLOtherGroup")
            {
                Caption = 'Other';
                field("GXL Top Two Hundred"; Rec."GXL Top Two Hundred")
                {
                    ApplicationArea = All;
                }
                field("GXL Top One Thousand"; Rec."GXL Top One Thousand")
                {
                    ApplicationArea = All;
                }
                field("GXL Signage 1"; Rec."GXL Signage 1")
                {
                    ApplicationArea = All;
                }
                field("GXL Family Tree ID"; Rec."GXL Family Tree ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("GXL Bloyal Date Time Modified"; Rec."GXL Bloyal Date Time Modified")
                {
                    ApplicationArea = All;
                }
                field("GXL Item Category Description"; Rec."GXL Item Category Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
                field("GXL Retail Product Code Description"; Rec."GXL Product Group Description")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group("GXL GXLWebGroup")
            {
                Caption = 'Web';
                field("GXL Price_WebRRP"; Rec."GXL Price_WebRRP")
                {
                    ApplicationArea = All;
                }
                field("GXL Price_WebSpecial"; Rec."GXL Price_WebSpecial")
                {
                    ApplicationArea = All;
                }
                field("GXL GXLEnabled"; Rec."GXL Enabled")
                {
                    ApplicationArea = All;
                }
                field("GXL GXLPackaging"; Rec."GXL Packaging")
                {
                    ApplicationArea = All;
                }
                field("GXL GXLFragile"; Rec."GXL Fragile")
                {
                    ApplicationArea = All;
                }
                field("GXL GXLMarketingOfferShort"; Rec."GXL MarketingOfferShort")
                {
                    ApplicationArea = All;
                }
                field("GXL GXLMarketingOfferLong"; Rec."GXL MarketingOfferLong")
                {
                    ApplicationArea = All;
                }

            }
            group("GXL GXLSupplyChainGroup")
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
                field("GXL Division Code"; Rec."LSC Division Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        Rec.CalcFields(Rec."GXL Division Description");
                    end;
                }
                field("GXL Division Description"; Rec."GXL Division Description")
                {
                    ApplicationArea = All;
                }
                field("GXL Category Code"; Rec."GXL Category Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        GXL_strText[2] := GXL_ItemSKUFunctions.GetProductGroupDesc(Rec."Item Category Code", Rec."LSC Retail Product Code");
                    end;
                }
                field("GXL Category Code Description"; GXL_strText[2])
                {
                    ApplicationArea = All;
                    Caption = 'Category Description';
                    Editable = false;
                }
                field("GXL Sub Category3 Code"; Rec."GXL Sub Category3 Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        GXL_strText[3] := GXL_ItemSKUFunctions.GetSubCat3Desc(Rec."GXL Sub Category3 Code");
                    end;
                }
                field("GXL Sub Category3 Description"; GXL_strText[3])
                {
                    ApplicationArea = All;
                    Caption = 'Sub Category3 Description';
                    Editable = false;
                }
                field("GXL Sub Category4 Code"; Rec."GXL Sub Category4 Code")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        GXL_strText[4] := GXL_ItemSKUFunctions.GetSubCat4Desc(Rec."GXL Sub Category4 Code");
                    end;
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
                field("GXL Supplier Number"; Rec."GXL Supplier Number")
                {
                    ApplicationArea = All;
                }
                field("GXL Supplier Name"; Rec."GXL Supplier Name")
                {
                    ApplicationArea = All;
                }
                field("GXL Agent Number"; Rec."GXL Agent Number")
                {
                    ApplicationArea = All;
                }
                field("GXL Agent Name"; Rec."GXL Agent Name")
                {
                    ApplicationArea = All;
                }
                field("GXL Distributor Number"; Rec."GXL Distributor Number")
                {
                    ApplicationArea = All;
                }
                field("GXL Distributor Name"; Rec."GXL Distributor Name")
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
                    ToolTip = 'Specifies the first receipt date from NAV13 system';
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
                field("GXL On-Line Effective Date"; Rec."GXL On-Line Effective Date")
                {
                    ApplicationArea = All;
                }
                field("GXL On-Line Discontinued Date"; Rec."GXL On-Line Discontinued Date")
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
                field("GXL GXLUnitPrice"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                }
                field("GXL GXLUnitCost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                }
                field("GXL GXLWebItem"; Rec."GXL Enabled")
                {
                    ApplicationArea = All;
                    Caption = 'Web item';
                }
                field("GXL Import Flag"; Rec."GXL Import Flag")
                {
                    ApplicationArea = All;
                }
                field("GXL Private Label Flag"; Rec."GXL Private Label Flag")
                {
                    ApplicationArea = All;
                }
                field("GXL Private Label Type"; Rec."GXL Private Label Type")
                {
                    ApplicationArea = All;
                }
                field("GXL Demand Planner ID"; Rec."GXL Demand Planner ID")
                {
                    ApplicationArea = All;
                }
                field("GXL Supply Planner ID"; Rec."GXL Supply Planner ID")
                {
                    ApplicationArea = All;
                }
                field("GXL Category Manager"; Rec."GXL Category Manager")
                {
                    ApplicationArea = All;
                }
                field("GXL Quit Reason Code"; Rec."GXL Quit Reason Code")
                {
                    ApplicationArea = All;
                }
                field("GXL Hazardous Item"; Rec."GXL Hazardous Item")
                {
                    ApplicationArea = All;
                }
                field("GXL MPL Factor"; Rec."GXL MPL Factor")
                {
                    ApplicationArea = All;
                }
                field("GXL New Item"; Rec."GXL New Item")
                {
                    ApplicationArea = All;
                }
                field("GXL Delta Ranging Required"; Rec."GXL Delta Ranging Required")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        addlast("F&unctions")
        {
            group("GXL GXLProductRanging")
            {
                Caption = 'Product Ranging';
                action("GXL GXLUpdateRanging")
                {
                    Caption = 'Update Product Ranging';
                    ApplicationArea = All;
                    Image = CreateSKU;

                    trigger OnAction()
                    var
                        Item: Record Item;
                        CreateProdStoreRanging: Report "GXL Create Prod Store Ranging";
                    begin
                        Item.SetRange("No.", Rec."No.");
                        CreateProdStoreRanging.SetTableView(Item);
                        CreateProdStoreRanging.SetValues(Database::Item, Rec."No.", '');
                        CreateProdStoreRanging.RunModal();
                    end;

                }
                action("GXL GXLProdRangingSetup")
                {
                    Caption = 'Product Ranging Setup';
                    ApplicationArea = All;
                    Image = SKU;
                    RunObject = page "GXL Product-Store Ranging List";
                    RunPageLink = "Item No." = field("No.");
                }
            }
        }

    }

    trigger OnAfterGetRecord()
    begin
        Rec.GXLGetFamilyStructureDescText(GXL_strText);
    end;

    var
        GXL_ItemSKUFunctions: Codeunit "GXL Item/SKU Functions";
        GXL_strText: array[5] of Text;

}