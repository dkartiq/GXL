pageextension 50350 "GXL GXLLocationCard" extends "Location Card"
{
    layout
    {
        addafter(General)
        {
            group("GXL GXL_3PL")
            {
                Caption = '3PL';
                field("GXL 3PL Warehouse"; Rec."GXL 3PL Warehouse")
                {
                    ApplicationArea = All;
                }
                field("GXL EDI Type"; Rec."GXL EDI Type")
                {
                    ApplicationArea = All;
                }
                field("GXL Inbound File Path"; Rec."GXL Inbound File Path")
                {
                    ApplicationArea = All;
                }
                field("GXL Outbound File Path"; Rec."GXL Outbound File Path")
                {
                    ApplicationArea = All;
                }
                field("GXL 3PL Archive File Path"; Rec."GXL 3PL Archive File Path")
                {
                    ApplicationArea = All;
                }
                field("GXL 3PL Error File Path"; Rec."GXL 3PL Error File Path")
                {
                    ApplicationArea = All;
                }
                field("GXL Def. Stock Adj. Batch Name"; Rec."GXL Def. Stock Adj. Batch Name")
                {
                    ApplicationArea = All;
                }
                field("GXL Receive File Format"; Rec."GXL Receive File Format")
                {
                    ApplicationArea = All;
                }
                field("GXL Send File Format"; Rec."GXL Send File Format")
                {
                    ApplicationArea = All;
                }
                field("GXL Send File Name Prefix"; Rec."GXL Send File Name Prefix")
                {
                    ApplicationArea = All;
                }
                field("GXL File Exchange Email Addr."; Rec."GXL File Exchange Email Addr.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        addlast(Navigation)
        {
            action("GXL GXL3PLFileSetup")
            {
                Caption = '3PL File Setup';
                ApplicationArea = All;
                Image = SetupList;
                RunObject = page "GXL 3PL File Setup";
                RunPageLink = Code = field(Code);
            }
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
                        CreateProdStoreRanging: Report "GXL Create Prod Store Ranging";
                    begin
                        CreateProdStoreRanging.SetValues(Database::Location, '', Rec.Code);
                        CreateProdStoreRanging.RunModal();
                    end;
                }
                action("GXL GXLProdRangingSetup")
                {
                    Caption = 'Product Ranging Setup';
                    ApplicationArea = All;
                    Image = SKU;
                    RunObject = page "GXL Product-Store Ranging List";
                    RunPageLink = "Store Code" = field(Code);
                }
            }
        }
    }
}