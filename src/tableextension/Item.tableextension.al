tableextension 50003 "GXL Item" extends Item
{

    fields
    {
        field(50000; "GXL Item Category Description"; Text[100])
        {
            Caption = 'Item Category Description';
            FieldClass = FlowField;
            CalcFormula = lookup("Item Category".Description where(Code = field("Item Category Code")));
            Editable = false;
        }
        field(50001; "GXL Product Group Description"; Text[100])
        {
            Caption = 'Product Group Description';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Retail Product Group".Description where("Item Category Code" = field("Item Category Code"), Code = field("LSC Retail Product Code")));
            Editable = false;
        }
        field(50002; "GXL Division Description"; Text[30])
        {
            Caption = 'Division Description';
            FieldClass = FlowField;
            CalcFormula = lookup("LSC Division".Description where(Code = field("LSC Division Code")));
            Editable = false;
        }
        field(50003; "GXL Standard Cost"; Decimal)
        {
            Caption = 'GXL Standard Cost';
            DataClassification = CustomerContent;
            AutoFormatType = 2;
            MinValue = 0;
        }
        //CR036 +
        field(50004; "GXL NAV First Receipt Date"; Date)
        {
            Caption = 'NAV First Receipt Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GXL_ProductStatusMgt.OnValidateNAVFirstReceiptDate_Item(Rec, xRec);
            end;
        }
        //CR036 -
        field(50005; "GXL SC-Size Description"; Text[30])
        {
            Caption = 'SC-Size Description';
            FieldClass = FlowField;
            CalcFormula = lookup("GXL Sub-Description 2".Description where(Code = field("GXL SC-Size")));
            Editable = false;
        }
        //Others
        field(50010; "GXL Family Tree ID"; Integer)
        {
            Caption = 'Family Tree ID';
            DataClassification = CustomerContent;
        }
        field(50011; "GXL Signage 1"; Text[65])
        {
            Caption = 'Signage 1';
            DataClassification = CustomerContent;
        }
        //Web
        field(50021; "GXL Price_WebRRP"; Decimal)
        {
            Caption = 'Price_WebRRP';
            DataClassification = CustomerContent;
        }
        field(50022; "GXL Price_WebSpecial"; Decimal)
        {
            Caption = 'Price_WebSpecial';
            DataClassification = CustomerContent;
        }
        field(50023; "GXL Enabled"; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(50024; "GXL Packaging"; Text[50])
        {
            Caption = 'Packaging';
            DataClassification = CustomerContent;
        }
        field(50025; "GXL Fragile"; Boolean)
        {
            Caption = 'Fragile';
            DataClassification = CustomerContent;
        }
        field(50026; "GXL MarketingOfferShort"; Text[250])
        {
            Caption = 'MarketingOfferShort';
            DataClassification = CustomerContent;
        }
        field(50027; "GXL MarketingOfferLong"; Text[250])
        {
            Caption = 'MarketingOfferLong';
            DataClassification = CustomerContent;
        }
        //Supply Chain
        field(50029; "GXL Category Code"; Code[20])
        {
            Caption = 'Category Code';
            DataClassification = CustomerContent;
            TableRelation = "LSC Retail Product Group".Code;
            Editable = false;

            trigger OnValidate()
            begin
                if "GXL Category Code" <> xRec."GXL Category Code" then
                    GXLUpdateSKU(FieldNo("GXL Category Code"));
            end;
        }
        field(50033; "GXL Sub Category3 Code"; Code[30])
        {
            TableRelation = "GXL Sub-Category 3";
            Caption = 'Sub Category3 Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GXLUpdateFamilyTreeID();
            end;
        }
        field(50034; "GXL Sub Category4 Code"; Code[40])
        {
            TableRelation = "GXL Sub-Category 4";
            Caption = 'Sub Category4 Code';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                GXLUpdateFamilyTreeID();
            end;
        }
        //Planning
        field(50035; "GXL Product Type"; Enum "GXL Product Type")
        {
            Caption = 'Product Type';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                IF "GXL Product Type" <> xRec."GXL Product Type" THEN BEGIN
                    IF "GXL Product Type" <> "GXL Product Type"::" " THEN BEGIN
                        IF "GXL Product Type" IN ["GXL Product Type"::Core, "GXL Product Type"::Seasonal] THEN BEGIN
                            Validate("GXL Forecast Flag", TRUE);
                            Validate("GXL Replenish Flag", TRUE);
                        END ELSE BEGIN
                            Validate("GXL Forecast Flag", FALSE);
                            Validate("GXL Replenish Flag", FALSE);
                        END;
                    END ELSE BEGIN
                        Validate("GXL Forecast Flag", FALSE);
                        Validate("GXL Replenish Flag", FALSE);
                    END;
                    GXLUpdateSKU(FieldNo("GXL Product Type"));

                END;
            end;
        }
        field(50036; "GXL Source of Supply"; Enum "GXL Source of Supply")
        {
            Caption = 'Source of Supply';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin

                IF "GXL Source of Supply" <> xRec."GXL Source of Supply" THEN BEGIN
                    GXL_ProductStatusMgt.OnValidateSourceOfSupply_Item(Rec, xRec);

                    GXLUpdateSKU(FieldNo("GXL Source of Supply"));

                    IF ("GXL Source of Supply" <> "GXL Source of Supply"::WH) AND ("GXL Discontinued Date" <> 0D) THEN
                        Validate("GXL Discontinued Date", 0D);

                    GXLUpdateProductRanging();
                END;

            end;
        }
        field(50037; "GXL Supplier Number"; Code[20])
        {
            Caption = 'Supplier Number';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            trigger OnValidate();
            begin
                IF "GXL Supplier Number" <> xRec."GXL Supplier Number" THEN BEGIN
                    GXLUpdateSKU(FieldNo("GXL Supplier Number"));
                END;
            end;
        }
        field(50038; "GXL Agent Number"; Code[20])
        {
            Caption = 'Agent Number';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            trigger OnValidate();
            begin
                IF "GXL Agent Number" <> xRec."GXL Agent Number" THEN BEGIN
                    GXLUpdateSKU(FieldNo("GXL Agent Number"));
                END;
            end;
        }
        field(50039; "GXL Distributor Number"; Code[20])
        {
            Caption = 'Distributor Number';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            trigger OnValidate();
            begin
                IF "GXL Distributor Number" <> xRec."GXL Distributor Number" THEN BEGIN
                    GXLUpdateSKU(FieldNo("GXL Distributor Number"));
                    GXLUpdateProductRanging();
                END;
            end;
        }
        field(50040; "GXL Order Pack (OP)"; Integer)
        {
            Caption = 'Order Pack (OP)';
            DataClassification = CustomerContent;
        }
        field(50041; "GXL Order Multiple (OM)"; Integer)
        {
            Caption = 'Order Multiple (OM)';
            DataClassification = CustomerContent;
        }
        field(50042; "GXL SC-Size"; Code[10])
        {
            Caption = 'SC-Size';
            DataClassification = CustomerContent;
            TableRelation = "GXL Sub-Description 2";
            trigger OnValidate();
            begin
                IF "GXL SC-Size" <> xRec."GXL SC-Size" THEN BEGIN
                    GXLUpdateSKU(FieldNo("GXL SC-Size"));
                END;
            end;
        }
        //Product Life Cycle
        field(50043; "GXL Product Status"; enum "GXL Product Status")
        {
            Caption = 'Product Status';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //Product life cycle and ranging
                if "GXL Product Status" <> xRec."GXL Product Status" then begin
                    GXL_ProductStatusMgt.OnValidateProductStatus_Item(Rec, xRec, CurrFieldNo);
                    GXL_ProdRangingMgt.DerangeProductRangingOnQuit(Rec);
                    if not GXL_SkipUpdateSKUStatus then
                        GXLUpdateSKU(FieldNo("GXL Product Status"));
                end;
            end;
        }
        field(50044; "GXL Expiry Date Flag"; Boolean)
        {
            Caption = 'Expiry Date Flag';
            DataClassification = CustomerContent;
            trigger OnValidate();
            begin
                IF "GXL Expiry Date Flag" <> xRec."GXL Expiry Date Flag" THEN BEGIN
                    GXLUpdateSKU(FieldNo("GXL Expiry Date Flag"));
                END;
            end;
        }
        field(50045; "GXL Forecast Flag"; Boolean)
        {
            Caption = 'Forecast Flag';
            DataClassification = CustomerContent;
            trigger OnValidate();
            begin
                IF "GXL Forecast Flag" <> xRec."GXL Forecast Flag" THEN BEGIN
                    GXLUpdateSKU(FieldNo("GXL Forecast Flag"));
                END;
            end;
        }
        field(50046; "GXL Replenish Flag"; Boolean)
        {
            Caption = 'Replenish Flag';
            DataClassification = CustomerContent;
            trigger OnValidate();
            begin
                IF "GXL Replenish Flag" <> xRec."GXL Replenish Flag" THEN BEGIN
                    GXLUpdateSKU(FieldNo("GXL Replenish Flag"));
                END;

            end;
        }
        field(50047; "GXL Effective Date"; Date)
        {
            Caption = 'Effective Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "GXL Effective Date" <> xRec."GXL Effective Date" then begin
                    GXLUpdateSKU(FieldNo("GXL Effective Date"));
                    GXLUpdateProductRanging();
                end;
            end;
        }
        field(50048; "GXL Quit Date"; Date)
        {
            Caption = 'Quit Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //Product life cycle and ranging mods
                if "GXL Quit Date" <> xRec."GXL Quit Date" then begin
                    GXL_ProductStatusMgt.OnValidateQuitDate_Item(Rec, xRec);
                    GXLUpdateProductRanging();
                end;
            end;
        }
        field(50049; "GXL Discontinued Date"; Date)
        {
            Caption = 'Discontinued Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //Product life cycle and ranging mods
                if "GXL Discontinued Date" <> xRec."GXL Discontinued Date" then begin
                    GXL_ProductStatusMgt.OnValidateDiscontinuedDate_Item(Rec, xRec);
                    GXLUpdateProductRanging();
                end;
            end;
        }
        field(50050; "GXL Quit Reason Code"; Option)
        {
            Caption = 'Quit Reason Code';
            DataClassification = CustomerContent;
            OptionMembers = " ",XP,XS;
            OptionCaption = ' ,XP,XS';
        }

        //Web
        field(50051; "GXL On-Line Status"; Option)
        {
            Caption = 'On-Line Status';
            DataClassification = CustomerContent;
            OptionMembers = Online,Store,Both;
            OptionCaption = 'Online,Store,Both';

            trigger OnValidate();
            begin
                IF "GXL On-Line Status" <> xRec."GXL On-Line Status" THEN BEGIN
                    GXLUpdateSKU(FieldNo("GXL On-Line Status"));
                END;
            end;
        }
        field(50052; "GXL Like Item"; Code[20])
        {
            Caption = 'Like Item';
            DataClassification = CustomerContent;
            TableRelation = Item;
            trigger OnValidate();
            begin

                IF "GXL Like Item" <> xRec."GXL Like Item" THEN BEGIN
                    IF ("GXL Like Item" <> '') THEN
                        Rec.TESTFIELD("GXL Like Item Factor")
                    ELSE
                        Validate("GXL Like Item Factor", 0);

                    GXLUpdateSKU(FieldNo("GXL Like Item"));
                END;
            end;
        }
        field(50053; "GXL Like Item Factor"; Decimal)
        {
            Caption = 'Like Item Factor';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 1;

            trigger OnValidate();
            begin
                if "GXL Like Item Factor" <> xRec."GXL Like Item Factor" then
                    GXLUpdateSKU(FieldNo("GXL Like Item Factor"));
            end;
        }
        field(50054; "GXL Supersession Item"; Code[20])
        {
            Caption = 'Supersession Item';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(50055; "GXL Hazardous Item"; Boolean)
        {
            Caption = 'Hazardous Item';
            DataClassification = CustomerContent;
        }
        field(50056; "GXL Import Flag"; Boolean)
        {
            Caption = 'Import Flag';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "GXL Import Flag" <> xRec."GXL Import Flag" then
                    GXLUpdateSKU(FieldNo("GXL Import Flag"));
            end;
        }
        field(50057; "GXL Private Label Flag"; Boolean)
        {
            Caption = 'Private Label Flag';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "GXL Private Label Flag" <> xRec."GXL Private Label Flag" then
                    GXLUpdateSKU(FieldNo("GXL Private Label Flag"));
            end;
        }
        field(50058; "GXL Supplier Name"; Text[100])
        {
            Caption = 'Supplier Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Lookup(Vendor.Name WHERE("No." = FIELD("GXL Supplier Number")));
        }
        field(50059; "GXL Agent Name"; Text[100])
        {
            Caption = 'Agent Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Lookup(Vendor.Name WHERE("No." = FIELD("GXL Agent Number")));
        }
        field(50060; "GXL Parent Item"; Code[20])
        {
            Caption = 'Parent Item';
            DataClassification = CustomerContent;
            //TableRelation = Item; //+PS-2351-Removed

            trigger OnValidate();
            begin
                IF "GXL Parent Item" <> xRec."GXL Parent Item" THEN
                    GXLUpdateSKU(FieldNo("GXL Parent Item"));

            end;
        }
        field(50061; "GXL Parent Quantity"; Integer)
        {
            Caption = 'Parent Quantity';
            DataClassification = CustomerContent;

            trigger OnValidate();
            begin
                IF "GXL Parent Quantity" <> xRec."GXL Parent Quantity" THEN
                    GXLUpdateSKU(FieldNo("GXL Parent Quantity"));

            end;
        }
        field(50062; "GXL Distributor Name"; Text[100])
        {
            Caption = 'Distributor Name';
            FieldClass = FlowField;
            Editable = false;
            CalcFormula = Lookup(Vendor.Name WHERE("No." = FIELD("GXL Distributor Number")));
        }
        field(50063; "GXL Private Label Type"; Code[10])
        {
            Caption = 'Private Label Type';
            DataClassification = CustomerContent;
            TableRelation = "GXL Private Label Type";
        }
        field(50064; "GXL Top Two Hundred"; Boolean)
        {
            Caption = 'Top Two Hundred';
            DataClassification = CustomerContent;
        }
        field(50065; "GXL Top One Thousand"; Boolean)
        {
            Caption = 'Top One Thousand';
            DataClassification = CustomerContent;
        }
        field(50066; "GXL MPL Factor"; Integer)
        {
            Caption = 'MPL Factor';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if "GXL MPL Factor" <> xRec."GXL MPL Factor" then
                    GXL_ItemSKUFunctions.UpdateSKUMPLFactor(Rec, "GXL MPL Factor");
            end;
        }
        field(50067; "GXL Product Range Code"; Code[10])
        {
            Caption = 'Product Range Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL Product Range Code";

            trigger OnValidate();
            begin
                IF "GXL Product Range Code" <> xRec."GXL Product Range Code" THEN BEGIN
                    IF "GXL Product Range Code" = '' THEN BEGIN
                        IF "GXL Product Type" <> "GXL Product Type"::" " THEN
                            ERROR(GXL_ProdRangeCodeCannotBeBlankMsg)
                        ELSE BEGIN
                            IF "GXL Replenish Flag" OR "GXL Forecast Flag" THEN
                                ERROR(GXL_ProdRangeCodeCannotBeBlankMsg);
                        END;
                    END;
                    GXLUpdateSKU(FieldNo("GXL Product Range Code"));
                END;


            end;
        }
        field(50068; "GXL Demand Planner ID"; Code[10])
        {
            Caption = 'Demand Planner ID';
            DataClassification = CustomerContent;
            TableRelation = "GXL Planner Setup";
        }
        field(50069; "GXL Supply Planner ID"; Code[10])
        {
            Caption = 'Supply Planner ID';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor."GXL Supplier Planner" where("No." = field("GXL Distributor Number")));
            Editable = false;
        }
        field(50070; "GXL Category Manager"; Code[10])
        {
            Caption = 'Category Manager';
            DataClassification = CustomerContent;
            TableRelation = "GXL Planner Setup";
        }
        field(50071; "GXL On-Line Effective Date"; Date)
        {
            Caption = 'On-Line Effective Date';
            DataClassification = CustomerContent;
        }
        field(50072; "GXL On-Line Discontinued Date"; Date)
        {
            Caption = 'On-Line Discontinued Date';
            DataClassification = CustomerContent;
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
            CalcFormula = min("Item Ledger Entry"."Posting Date" where("Item No." = field("No."), "Entry Type" = filter(Purchase)));
            Editable = false;
        }
        field(50075; "GXL Delta Ranging Required"; Boolean)
        {
            Caption = 'Delta Ranging Required';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50076; "GXL New Item"; Boolean)
        {
            Caption = 'New Item';
            DataClassification = CustomerContent;
            Editable = false;
        }
        //Bloyal integration
        field(50170; "GXL Bloyal Date Time Modified"; DateTime)
        {
            //Internal used for Bloyal integration only. To update last datetime that specific fields being changed.
            DataClassification = CustomerContent;
            Caption = 'Bloyal Date Time Modified';
            Editable = false;
        }
        //>> PS-1392: Removed as SOH has been re-designed 
        /*
        //SOH Integration        
        field(50200; "GXL Inventory Changed"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Inventory Changed';
        }
        */
        //<< PS-1392: Removed as SOH has been re-designed 
        modify("LSC Division Code")
        {
            trigger OnAfterValidate()
            begin
                GXLUpdateFamilyTreeID();
            end;
        }
        modify("Item Category Code")
        {
            trigger OnAfterValidate()
            begin
                GXLUpdateFamilyTreeID();
            end;
        }
        modify("LSC Retail Product Code")
        {
            trigger OnAfterValidate()
            begin
                if "LSC Retail Product Code" <> xRec."LSC Retail Product Code" then
                    Validate("GXL Category Code", "LSC Retail Product Code");
                GXLUpdateFamilyTreeID();
            end;
        }
    }
    keys
    {
        key(GXL_CategoryCode; "GXL Category Code") { }
        key(GXL_SubCat3Code; "GXL Sub Category3 Code") { }
        key(GXL_SubCat4Code; "GXL Sub Category4 Code") { }
        key(GXL_FamilyTreeId; "GXL Family Tree ID") { }
        key(GXL_BloyalDateTimeModified; "GXL Bloyal Date Time Modified") { }
        key(GXL_ProductStatus; "GXL Product Status") { }
        key(GXL_DeltaRanging; "GXL Delta Ranging Required") { }
    }

    var
        GXL_ItemSKUFunctions: Codeunit "GXL Item/SKU Functions";
        GXL_ProductStatusMgt: Codeunit "GXL Product Status Management";
        GXL_ProdRangingMgt: Codeunit "GXL Product Ranging Management";
        GXL_SkipUpdateSKUStatus: Boolean;
        GXL_ProdRangeCodeCannotBeBlankMsg: label 'Product Range Code can not be blank !';


    trigger OnBeforeInsert()
    begin
        "GXL Source of Supply" := "GXL Source of Supply"::WH;
        "GXL On-Line Status" := "GXL On-Line Status"::Store;
        GXL_ItemSKUFunctions.InitSupplyChain(Rec);
    end;

    trigger OnBeforeModify()
    begin
        if GuiAllowed() then begin
            GXL_ItemSKUFunctions.CheckOrderMutiple(Rec);
            GXL_ItemSKUFunctions.UpdateSKUOrderPack(Rec);
        end;
    end;

    local procedure GXLUpdateSKU(CurrentField: Integer)
    var
        SKU: Record "Stockkeeping Unit";
    begin

        SKU.RESET();
        SKU.SETCURRENTKEY("Item No.");
        SKU.SETRANGE("Item No.", "No.");
        IF SKU.IsEmpty() then
            EXIT;

        CASE CurrentField OF
            FieldNo("GXL Product Type"):
                SKU.ModifyAll("GXL Product Type", "GXL Product Type");
            FieldNo("GXL Product Range Code"):
                SKU.ModifyAll("GXL Product Range Code", "GXL Product Range Code");

            FieldNo("Last Date Modified"):
                SKU.ModifyAll("Last Date Modified", "Last Date Modified");

            FieldNo("GXL Supplier Number"):
                SKU.ModifyAll("GXL Supplier Number", "GXL Supplier Number");
            FieldNo("GXL Agent Number"):
                SKU.ModifyAll("GXL Agent Number", "GXL Agent Number");

            FieldNo("GXL Category Code"):
                SKU.ModifyAll("GXL Category Code", "GXL Category Code");

            FieldNo("GXL SC-Size"):
                SKU.ModifyAll("GXL SC-Size", "GXL SC-Size");
            FieldNo("GXL Expiry Date Flag"):
                SKU.ModifyAll("GXL Expiry Date Flag", "GXL Expiry Date Flag");

            FieldNo("GXL Like Item"):
                SKU.ModifyAll("GXL Like Item", "GXL Like Item");
            FieldNo("GXL Like Item Factor"):
                SKU.ModifyAll("GXL Like Item Factor", "GXL Like Item Factor");

            FieldNo("GXL Parent Item"):
                SKU.ModifyAll("GXL Parent Item", "GXL Parent Item");
            FieldNo("GXL Parent Quantity"):
                SKU.ModifyAll("GXL Parent Quantity", "GXL Parent Quantity");

            FieldNo("GXL Supersession Item"):
                SKU.ModifyAll("GXL Supersession Item", "GXL Supersession Item");

            FieldNo("GXL Import Flag"):
                SKU.ModifyAll("GXL Import Flag", "GXL Import Flag");
            FieldNo("GXL Private Label Flag"):
                SKU.ModifyAll("GXL Private Label Flag", "GXL Private Label Flag");
            FieldNo("GXL On-Line Status"):
                SKU.ModifyAll("GXL On-Line Status", "GXL On-Line Status");

            FieldNo("GXL Distributor Number"),
            FieldNo("GXL Source of Supply"),
            FieldNo("GXL Product Status"),
            FieldNo("GXL Effective Date"),
            FieldNo("GXL Forecast Flag"),
            FieldNo("GXL Replenish Flag"):
                BEGIN
                    IF SKU.FindSet() THEN
                        REPEAT
                            IF CurrentField = FieldNo("GXL Distributor Number") THEN
                                SKU.Validate("GXL Distributor Number", "GXL Distributor Number");
                            IF CurrentField = FieldNo("GXL Source of Supply") THEN
                                SKU.Validate("GXL Source of Supply", "GXL Source of Supply");

                            //Product life cycle and ranging
                            IF CurrentField = FieldNo("GXL Product Status") THEN BEGIN
                                IF "GXL Product Status" IN ["GXL Product Status"::Approved, "GXL Product Status"::"New-Line", "GXL Product Status"::Active] THEN BEGIN
                                    SKU.CalcFields("GXL Ranged");
                                    if SKU."GXL Ranged" then
                                        if GXL_ProdRangingMgt.CheckSKUIsLegal(SKU."Item No.", SKU."Location Code") then
                                            SKU.Validate("GXL Product Status", "GXL Product Status");
                                END ELSE BEGIN
                                    SKU.Validate("GXL Product Status", "GXL Product Status");
                                END;
                            END;

                            IF CurrentField = FieldNo("GXL Effective Date") THEN
                                SKU.Validate("GXL Effective Date", "GXL Effective Date");
                            IF CurrentField = FieldNo("GXL Forecast Flag") THEN
                                SKU.Validate("GXL Forecast Flag", "GXL Forecast Flag");
                            IF CurrentField = FieldNo("GXL Replenish Flag") THEN
                                SKU.Validate("GXL Replenish Flag", "GXL Replenish Flag");

                            SKU.Modify(true);
                        UNTIL SKU.Next() = 0;
                END;
        END;
    end;

    local procedure GXLUpdateFamilyTreeID()
    var
        GXLItem: Record Item;
    begin
        if "GXL Family Tree ID" <> 0 then
            exit;

        GXLItem.SetCurrentKey("GXL Family Tree ID");
        if GXLItem.FindLast() then
            "GXL Family Tree ID" := GXLItem."GXL Family Tree ID" + 1
        else
            "GXL Family Tree ID" := 1;
    end;

    procedure GXLGetFamilyStructureDescText(var GXL_strText: array[5] of Text)
    var
        GXLItemSKUFunctions: Codeunit "GXL Item/SKU Functions";
    begin
        CalcFields("GXL Item Category Description", "GXL Product Group Description", "GXL Division Description");
        GXL_strText[1] := "GXL Item Category Description";
        GXL_strText[2] := "GXL Product Group Description";
        GXL_strText[3] := GXLItemSKUFunctions.GetSubCat3Desc("GXL Sub Category3 Code");
        GXL_strText[4] := GXLItemSKUFunctions.GetSubCat4Desc("GXL Sub Category4 Code");
        GXL_strText[5] := "GXL Division Description";

    end;

    procedure GXLSetSkipUpdateSKUStatus(_Value: Boolean)
    begin
        GXL_SkipUpdateSKUStatus := _Value;
    end;

    local procedure GXLUpdateProductRanging()
    begin
        if GXL_ProdRangingMgt.ProductStatusCanBeRanged("GXL Product Status") then
            "GXL Delta Ranging Required" := true;
    end;
}