table 50003 "GXL Warehouse Assignment"
{
    Caption = 'Warehouse Assignment';
    DataClassification = CustomerContent;
    LookupPageId = "GXL Warehouse Assignments";

    fields
    {
        field(1; "Distributor Code"; Code[20])
        {
            Caption = 'Distributor Code';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(2; "Store Code"; Code[10])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("GXL Location Type" = filter("6"));
        }
        field(3; "Warehouse Code"; Code[10])
        {
            Caption = 'Warehouse Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("GXL Location Type" = filter("3"));
        }
        field(4; "Distributor Name"; Text[100])
        {
            Caption = 'Distributor Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor.Name where("No." = field("Distributor Code")));
            Editable = false;
        }
        field(5; "Store Name"; Text[100])
        {
            Caption = 'Store Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Location.Name where(Code = field("Store Code")));
            Editable = false;
        }
        field(6; "Warehouse Name"; Text[100])
        {
            Caption = 'Warehouse Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Location.Name where(Code = field("Warehouse Code")));
            Editable = false;
        }
    }
    keys
    {
        key(PK; "Distributor Code", "Store Code")
        {
            Clustered = true;
        }
    }

    var


    trigger OnInsert()
    begin
        UpdateSKU(0);
    end;

    trigger OnModify()
    begin
        UpdateSKU(1);
    end;

    trigger OnDelete()
    begin
        UpdateSKU(2);
    end;

    trigger OnRename()
    begin
        Error('You cannot rename a %1.', TableCaption());
    end;


    procedure UpdateSKU(UpdateOption: Option I,M,D)
    var
        Sku: Record "Stockkeeping Unit";
    begin
        Sku.Reset();
        Sku.SetRange("GXL Distributor Number", "Distributor Code");
        Sku.SetRange("Location Code", "Store Code");
        Sku.SetFilter("GXL Product Status", '%1|%2|%3',
            Sku."GXL Product Status"::Approved, Sku."GXL Product Status"::"New-Line", Sku."GXL Product Status"::Active);
        case UpdateOption of
            UpdateOption::I:
                begin
                    if "Warehouse Code" <> '' then begin
                        Sku.SetFilter("GXL Source of Supply", '<>%1', Sku."GXL Source of Supply"::SD);
                        if Sku.FindSet() then
                            repeat
                                Sku.VALIDATE("GXL Source of Supply Code", "Warehouse Code");
                                Sku.Modify(true);
                                UpdateItemFlag(Sku."Item No.");
                            until Sku.Next() = 0;
                    end;
                end;
            UpdateOption::M:
                begin
                    if "Warehouse Code" <> '' then
                        Sku.SetFilter("GXL Source of Supply", '<>%1', Sku."GXL Source of Supply"::SD);
                    if Sku.FindSet() then
                        repeat
                            if Sku."GXL Source of Supply Code" <> "Warehouse Code" then begin
                                Sku.VALIDATE("GXL Source of Supply Code", "Warehouse Code");
                                Sku.Modify(true);
                                UpdateItemFlag(Sku."Item No.");
                            end;
                        until Sku.Next() = 0;

                end;
            UpdateOption::D:
                begin
                    Sku.SetRange("GXL Product Status");
                    if Sku.FindSet() then
                        repeat
                            if Sku."GXL Source of Supply Code" <> '' then begin
                                Sku.VALIDATE("GXL Source of Supply Code", '');
                                Sku.Modify(true);
                                UpdateItemFlag(Sku."Item No.");
                            end;
                        until Sku.Next() = 0;
                end;
        end;
    end;

    procedure UpdateItemFlag(ItemNo: Code[20])
    var
        Item: Record Item;
        ProdRangingMgt: Codeunit "GXL Product Ranging Management";
    begin
        if Item.Get(ItemNo) then
            if ProdRangingMgt.ProductStatusCanBeRanged(Item."GXL Product Status") then
                if Item."GXL Delta Ranging Required" = false then begin
                    Item."GXL Delta Ranging Required" := true;
                    Item.Modify();
                end;
    end;

}