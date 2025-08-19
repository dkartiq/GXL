table 50005 "GXL Product-Store Ranging"
{
    Caption = 'Product-Store Ranging';
    DataClassification = CustomerContent;
    LookupPageId = "GXL Product-Store Ranging List";
    DrillDownPageId = "GXL Product-Store Ranging List";

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(2; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            Editable = false;
        }
        field(3; "Product Status"; Enum "GXL Product Status")
        {
            Caption = 'Product Status';
            FieldClass = FlowField;
            CalcFormula = lookup("Stockkeeping Unit"."GXL Product Status" where("Item No." = field("Item No."), "Location Code" = field("Store Code")));
            Editable = false;
        }
        field(5; "Store Code"; Code[10])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(6; "Store Name"; Text[100])
        {
            Caption = 'Store Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Location.Name where(Code = field("Store Code")));
            Editable = false;
        }
        field(8; Ranged; Boolean)
        {
            Caption = 'Ranged';
            DataClassification = CustomerContent;
        }
        field(9; "Effective Date"; Date)
        {
            Caption = 'Effective Date';
            DataClassification = CustomerContent;
        }
        field(10; "Deleted Date"; Date)
        {
            Caption = 'Deleted Date';
            DataClassification = CustomerContent;
        }
        field(11; "Last Deleted Date"; Date)
        {
            Caption = 'Last Deleted Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(13; Exceptions; Boolean)
        {
            Caption = 'Exceptions';
            FieldClass = FlowField;
            CalcFormula = lookup("GXL Ranging Exceptions".Range where("Item No." = field("Item No."), "Store Code" = field("Store Code")));
            Editable = false;
        }
        field(14; "Modified Date"; Date)
        {
            Caption = 'Modified Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.", "Store Code")
        {
            Clustered = true;
        }
    }

    var


    trigger OnInsert()
    begin
        "Modified Date" := Today();
    end;

    trigger OnModify()
    begin
        "Modified Date" := Today();
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin
        Error('You cannot rename a %1', TableCaption());
    end;

}