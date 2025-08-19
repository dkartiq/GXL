tableextension 50004 "GXL StockKeeping Unit" extends "Stockkeeping Unit"
{
    fields
    {
        //CR036 +
        field(50004; "GXL NAV First Receipt Date"; Date)
        {
            Caption = 'NAV First Receipt Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GXL_ProductStatusMgt.OnValidateNAVFirstReceiptDate_SKU(Rec, xRec);
            end;
        }
        //CR036 -
        field(50022; "GXL Sales Price Type"; Option)
        {
            Caption = 'Sales Price Type';
            DataClassification = CustomerContent;
            OptionMembers = " ","Standard Price","Price Fighter","Clearance Price";
            OptionCaption = ' ,Standard Price,Price Fighter,Clearance Price';
        }
        //Supply Chain
        field(50024; "GXL Availabile SOH"; Decimal)
        {
            Caption = 'Availabile SOH';
            DataClassification = CustomerContent;
        }
        field(50025; "GXL Total SOH"; Decimal)
        {
            Caption = 'Total SOH';
            DataClassification = CustomerContent;
        }
        field(50026; "GXL Facing"; Integer)
        {
            Caption = 'Facing';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "GXL Facing" <> xRec."GXL Facing" then
                    GXL_ItemSKUFunctions.UpdateFacing(Rec, xRec, xRec."GXL Facing", "GXL Facing");
            end;
        }
        field(50027; "GXL Stock Held"; Decimal)
        {
            Caption = 'Stock Held';
            DataClassification = CustomerContent;
        }
        field(50029; "GXL Category Code"; Code[20])
        {
            Caption = 'Category Code';
            DataClassification = CustomerContent;
            TableRelation = "LSC Retail Product Group".Code;
            Editable = false; //Updated from Item 
        }
        //Planning
        field(50035; "GXL Product Type"; Enum "GXL Product Type")
        {
            Caption = 'Product Type';
            DataClassification = CustomerContent;
            Editable = false; //Updated from Item
        }
        field(50036; "GXL Source of Supply"; Enum "GXL Source of Supply")
        {
            Caption = 'Source of Supply';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                if "GXL Source of Supply" <> xRec."GXL Source of Supply" then begin
                    GXL_ProductStatusMgt.OnValidateSourceOfSupply_SKU(Rec, xRec);
                    IF ("GXL Source of Supply" <> "GXL Source of Supply"::WH) AND ("GXL Discontinued Date" <> 0D) THEN
                        Validate("GXL Discontinued Date", 0D);
                    if "GXL Source of Supply" = "GXL Source of Supply"::SD then
                        "GXL Source of Supply Code" := '';
                end;
            end;
        }
        field(50037; "GXL Supplier Number"; Code[20])
        {
            Caption = 'Supplier Number';
            DataClassification = CustomerContent;
            Editable = false; //Updated from Item
            TableRelation = Vendor;
        }
        field(50038; "GXL Agent Number"; Code[20])
        {
            Caption = 'Agent Number';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(50039; "GXL Distributor Number"; Code[20])
        {
            Caption = 'Distributor Number';
            DataClassification = CustomerContent;
            TableRelation = Vendor;

            trigger OnValidate();
            begin
            end;
        }
        field(50040; "GXL Order Pack (OP)"; Integer)
        {
            Caption = 'Order Pack (OP)';
            DataClassification = CustomerContent;
            Editable = false; //Updated from item trigger
        }
        field(50041; "GXL Order Multiple (OM)"; Integer)
        {
            Caption = 'Order Multiple (OM)';
            DataClassification = CustomerContent;
            Editable = false; //Updated from item trigger
        }
        field(50042; "GXL SC-Size"; Code[10])
        {
            Caption = 'SC-Size';
            DataClassification = CustomerContent;
            Editable = false; //Updated from Item
            TableRelation = "GXL Sub-Description 2";
        }
        //Product Life Cycle
        field(50043; "GXL Product Status"; Enum "GXL Product Status")
        {
            Caption = 'Product Status';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //Product life cycle and ranging mods
                GXL_ProductStatusMgt.OnValidateProductStatus_SKU(Rec, xRec, CurrFieldNo);
            end;

        }
        field(50044; "GXL Expiry Date Flag"; Boolean)
        {
            Caption = 'Expiry Date Flag';
            DataClassification = CustomerContent;
            Editable = false; //updated from item
        }
        field(50045; "GXL Forecast Flag"; Boolean)
        {
            Caption = 'Forecast Flag';
            DataClassification = CustomerContent;
            Editable = false; //updated from item

            trigger OnValidate();
            begin
            end;
        }
        field(50046; "GXL Replenish Flag"; Boolean)
        {
            Caption = 'Replenish Flag';
            DataClassification = CustomerContent;
            Editable = false; //updated from item

            trigger OnValidate();
            begin
            end;
        }
        field(50047; "GXL Effective Date"; Date)
        {
            Caption = 'Effective Date';
            DataClassification = CustomerContent;
        }
        field(50048; "GXL Quit Date"; Date)
        {
            Caption = 'Quit Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //Product life cycle and ranging mods
                GXL_ProductStatusMgt.OnValidateQuitDate_SKU(Rec, xRec, CurrFieldNo);
            end;
        }
        field(50049; "GXL Discontinued Date"; Date)
        {
            Caption = 'Discontinued Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //Product life cycle and ranging mods
                GXL_ProductStatusMgt.OnValidateDiscontinuedDate_SKU(Rec, xRec);
            end;
        }
        //Web
        field(50051; "GXL On-Line Status"; Option)
        {
            Caption = 'On-Line Status';
            DataClassification = CustomerContent;
            OptionMembers = "On-Line","In-Store",Both;
            OptionCaption = 'On-Line,In-Store,Both';
            Editable = false; //updated from item
        }
        field(50052; "GXL Like Item"; Code[20])
        {
            Caption = 'Like Item';
            DataClassification = CustomerContent;
            TableRelation = Item;
            Editable = false; //updated from item
        }
        field(50053; "GXL Like Item Factor"; Decimal)
        {
            Caption = 'Like Item Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;
            Editable = false; //updated from item
        }
        field(50054; "GXL Supersession Item"; Code[20])
        {
            Caption = 'Supersession Item';
            DataClassification = CustomerContent;
            TableRelation = Item;
            Editable = false; //updated from item
        }
        field(50056; "GXL Import Flag"; Boolean)
        {
            Caption = 'Import Flag';
            DataClassification = CustomerContent;
            Editable = false; //updated from item
        }
        field(50057; "GXL Private Label Flag"; Boolean)
        {
            Caption = 'Private Label Flag';
            DataClassification = CustomerContent;
            Editable = false; //updated from item
        }
        field(50060; "GXL Parent Item"; Code[20])
        {
            Caption = 'Parent Item';
            DataClassification = CustomerContent;
            //TableRelation = Item; //PS-2351-Removed
            Editable = false; //updated from item
        }
        field(50061; "GXL Parent Quantity"; Integer)
        {
            Caption = 'Parent Quantity';
            DataClassification = CustomerContent;
            Editable = false; //updated from item

            trigger OnValidate();
            begin
                IF "GXL Parent Quantity" <> 0 THEN BEGIN
                    Rec.TESTFIELD("GXL Parent Item");
                END;
            end;
        }
        field(50066; "GXL MPL Factor"; Integer)
        {
            Caption = 'MPL Factor';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "GXL MPL Factor" <> xRec."GXL MPL Factor" then
                    Validate("GXL Minimum Presentation Level", "GXL Facing" * "GXL MPL Factor");
            end;
        }
        field(50067; "GXL Product Range Code"; Code[10])
        {
            Caption = 'Product Range Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL Product Range Code";
            Editable = false; //updated from item

            trigger OnValidate();
            begin
                IF "GXL Product Range Code" <> xRec."GXL Product Range Code" THEN BEGIN
                    IF "GXL Product Range Code" = '' THEN BEGIN
                        IF "GXL Product Type" = "GXL Product Type"::Core THEN
                            ERROR('Product Range Code can not be blank !')
                        ELSE BEGIN
                            IF ("GXL Replenish Flag" = TRUE) OR ("GXL Forecast Flag" = TRUE) THEN
                                ERROR('Product Range Code can not be blank !')
                        END;
                    END;
                END;
            end;
        }
        field(50068; "GXL Order Increment"; Integer)
        {
            Caption = 'Order Increment';
            DataClassification = CustomerContent;
            Editable = false; //It is updated from Stock Ranging

            trigger OnValidate();
            begin
                if "GXL Order Increment" <> 0 then begin
                    TestField("GXL Order Multiple (OM)");
                    IF "GXL Order Increment" MOD "GXL Order Multiple (OM)" <> 0 THEN
                        ERROR('This does not match the OM');
                end;
            end;
        }
        field(50069; "GXL Order Minimum"; Integer)
        {
            Caption = 'Order Minimum';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                IF "GXL Order Minimum" <> xRec."GXL Order Minimum" THEN BEGIN
                    if "GXL Order Minimum" <> 0 then begin
                        TestField("GXL Order Multiple (OM)");
                        IF "GXL Order Minimum" MOD "GXL Order Multiple (OM)" <> 0 THEN
                            ERROR('This does not match the OM');
                    end;
                    IF "GXL Order Minimum" < "GXL Order Increment" THEN
                        ERROR('The order minimum must be at least equal to the Order Increment');

                END;
            end;
        }
        field(50073; "GXL Age of Item"; Integer)
        {
            Caption = 'Age of Item';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50074; "GXL First Receipt Date"; Date)
        {
            Caption = 'First Receipt Date';
            FieldClass = FlowField;
            CalcFormula = min("Item Ledger Entry"."Posting Date" where("Item No." = field("Item No."), "Location Code" = field("Location Code"), "Entry Type" = filter(Purchase)));
            Editable = false;
        }
        field(50075; "GXL Warehouse SKU"; Boolean)
        {
            Caption = 'Warehouse SKU';
            FieldClass = FlowField;
            CalcFormula = exist("LSC Store" where("Location Code" = field("Location Code"), "GXL Location Type" = filter("3")));
            Editable = false;
        }
        field(50076; "GXL Source of Supply Code"; Code[10])
        {
            Caption = 'Warehouse';
            TableRelation = Location where("GXL Location Type" = filter("3"));
            Editable = false; //Update through Warehouse Assignment

            trigger OnValidate()
            begin
            end;
        }
        field(50077; "GXL New Ranging Flag"; Boolean)
        {
            Caption = 'New Ranging Flag';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50078; "GXL Ranged"; Boolean)
        {
            Caption = 'Ranged';
            FieldClass = FlowField;
            CalcFormula = lookup("GXL Product-Store Ranging".Ranged where("Item No." = field("Item No."), "Store Code" = field("Location Code")));
            Editable = false;
        }
        //>> PS-1392: Removed as SOH has been re-designed 
        /*
        field(50200; "GXL Inventory Changed"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Inventory Changed';
        }
        */
        //<< PS-1392: Removed as SOH has been re-designed 

        field(50250; "GXL Minimum Presentation Level"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Minimum Presentation Level';
        }
        field(50251; "GXL Shelf Capacity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Shelf Capacity';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                if "GXL Shelf Capacity" < "GXL Minimum Presentation Level" then
                    "GXL Shelf Capacity" := "GXL Minimum Presentation Level";
            end;
        }
        field(50252; "GXL OOS Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'OOS Reason Code';
            TableRelation = "Reason Code";
        }
        //WMS/3PL
        field(50350; "GXL Held SOH"; Decimal)
        {
            Caption = 'Held SOH';
            DataClassification = CustomerContent;
        }


    }


    keys
    {
        key(GXL_SourceOfSuuplyCode; "GXL Source of Supply Code") { }
        key(GXL_ProductStatus; "GXL Product Status") { }
    }

    var
        GXL_ItemSKUFunctions: Codeunit "GXL Item/SKU Functions";
        GXL_ProductStatusMgt: Codeunit "GXL Product Status Management";
        GXL_ProdRangingMgt: Codeunit "GXL Product Ranging Management";
}