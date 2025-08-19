table 50006 "GXL Illegal Item"
{
    Caption = 'Illegal Item';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;

            trigger OnValidate()
            begin
                if "Item No." = '' then
                    Error(MustBeFillInMsg, FieldCaption("Item No."));
            end;
        }
        field(2; State; Code[10])
        {
            Caption = 'State';
            DataClassification = CustomerContent;
            TableRelation = County;

            trigger OnValidate()
            begin
                if State <> '' then
                    TestField("Store Code", '');
            end;
        }
        field(3; "Store Code"; Code[10])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = Location where("GXL Location Type" = filter("6"));

            trigger OnValidate()
            begin
                if "Store Code" <> '' then
                    TestField(State, '');
            end;
        }
        field(4; Legal; Boolean)
        {
            Caption = 'Legal';
            DataClassification = CustomerContent;
        }
        field(10; "Last Modified Date"; Date)
        {
            Caption = 'Last Modified Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; "Last Modified User"; Code[50])
        {
            Caption = 'Last Modified User';
            DataClassification = CustomerContent;
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Item No.", "Store Code", State)
        {
            Clustered = true;
        }
    }

    var
        DeleteNotAllowedErr: Label 'Delete is not allowed.';
        RenameNotAllowedErr: Label 'Rename is not allowed.';
        MustBeFillInMsg: Label '%1 must be filled in.';
        EitherMustBeFillInMsg: Label 'Either %1 or %2 must be filled in.';


    trigger OnInsert()
    begin
        if (State = '') and ("Store Code" = '') then
            Error(EitherMustBeFillInMsg, FieldCaption(State), FieldCaption("Store Code"));

        SetModifiedDateUser();
        UpdateItemRangedRequired();
    end;

    trigger OnModify()
    begin
        SetModifiedDateUser();
        UpdateItemRangedRequired();
    end;

    trigger OnDelete()
    begin
        Error(DeleteNotAllowedErr);
    end;

    trigger OnRename()
    begin
        Error(RenameNotAllowedErr);
    end;

    local procedure SetModifiedDateUser()
    begin
        "Last Modified Date" := Today();
        "Last Modified User" := UserId();
    end;

    local procedure UpdateItemRangedRequired()
    var
        Item: Record Item;
        ProdRangingMgt: Codeunit "GXL Product Ranging Management";
    begin
        if not Item.GET("Item No.") then
            exit;

        if Item."GXL Delta Ranging Required" then
            exit;

        if ProdRangingMgt.ProductStatusCanBeRanged(Item."GXL Product Status") then begin
            Item."GXL Delta Ranging Required" := TRUE;
            Item.Modify();
        end;
    end;

    procedure GetLastDateIllegalSKUSet(ItemNo: Code[20]; StoreCode: Code[10]): Date
    var
        IllegalItem: Record "GXL Illegal Item";
        Loc: Record Location;
    begin
        //get last date that the sku is set
        IllegalItem.SetRange("Item No.", ItemNo);
        if IllegalItem.IsEmpty() then
            exit(0D);

        IllegalItem.SetRange("Store Code", StoreCode);
        if IllegalItem.FindFirst() then
            exit(IllegalItem."Last Modified Date");

        if Loc.GET(StoreCode) then begin
            IllegalItem.SetRange("Store Code", '');
            IllegalItem.SetRange(State, UPPERCASE(Loc.County));
            if IllegalItem.FindFirst() then
                exit(IllegalItem."Last Modified Date");
        end;

        exit(0D);
    end;

    procedure CheckSKUIsLegal(ItemCode: Code[20]; StoreCode: Code[10]; VAR IllegalDate: Date): Boolean
    var
        IllegalItem: Record "GXL Illegal Item";
        Loc: Record Location;
        LegalFlag: Boolean;
    begin
        IllegalDate := 0D;
        LegalFlag := TRUE;
        if not Loc.GET(StoreCode) then
            exit(LegalFlag);

        Loc.CalcFields("GXL Location Type");
        //If Location Type is not a store, then item is considered legal
        if Loc."GXL Location Type" <> Loc."GXL Location Type"::"6" then
            exit(LegalFlag);

        IllegalItem.Reset();
        IllegalItem.SetRange("Item No.", ItemCode);
        //If the item is not in the Illegal table then do not check - i.e. item is legal
        if IllegalItem.IsEmpty() then
            exit(LegalFlag);

        //Check the store if it is in the setup, then return the Legal flag
        IllegalItem.SetRange("Store Code", StoreCode);
        IllegalItem.SetRange(State, '');
        if IllegalItem.FindFirst() then begin
            if not IllegalItem.Legal then
                IllegalDate := IllegalItem."Last Modified Date";
            LegalFlag := IllegalItem.Legal;
            exit(LegalFlag);
        end;

        //Check the state of store
        if Loc.County = '' then
            exit(LegalFlag);

        IllegalItem.SetRange("Store Code", '');
        IllegalItem.SETFILTER(State, UPPERCASE(Loc.County));
        if IllegalItem.FindFirst() then begin
            if not IllegalItem.Legal then
                IllegalDate := IllegalItem."Last Modified Date";
            LegalFlag := IllegalItem.Legal;
            exit(LegalFlag);
        end;

        exit(LegalFlag);
    end;
}