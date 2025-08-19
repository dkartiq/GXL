table 50250 "GXL PDA-Store User"
{
    Caption = 'PDA-Store User';
    DataClassification = CustomerContent;
    LookupPageId = "GXL PDA-Store Users";
    DrillDownPageId = "GXL PDA-Store Users";

    fields
    {
        field(1; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
            NotBlank = true;
            TableRelation = User."User Name";
            ValidateTableRelation = false;

            trigger OnValidate()
            var
                // >> Upgrade
                //UserMgt: Codeunit "User Management";
                UserSelection: Codeunit "User Selection";
            // << Upgrade
            begin
                // >> Upgrade
                //UserMgt.ValidateUserID("User ID");
                UserSelection.ValidateUserName("User ID");
                // << Upgrade
            end;

            trigger OnLookup()
            var
                UserMgt: Codeunit "User Management";
            begin
                // >> Upgrade
                //UserMgt.LookupUserID("User ID");
                UserMgt.DisplayUserInformation("User ID");
                // << Upgrade
            end;
        }
        field(2; "Store Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Store Code';
            // >> Upgrade
            //TableRelation = Store;
            TableRelation = "LSC Store";
            // << Upgrade
        }
        field(3; Default; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Default';
        }
        field(4; "Store Name"; Text[100])
        {
            Caption = 'Store Name';
            FieldClass = FlowField;
            // >> Upgrade
            //CalcFormula = lookup(Store.Name where("No." = field("Store Code")));
            CalcFormula = lookup("LSC Store".Name where("No." = field("Store Code")));
            // << Upgrade
            Editable = false;
        }
    }

    keys
    {
        key(PK; "User ID", "Store Code")
        {
            Clustered = true;
        }
    }
    fieldgroups
    {
        fieldgroup(Dropdown; "User ID", "Store Code", "Store Name") { }
    }

    var
        OneDefaultUserPerStoreErr: Label 'You can only have one default store per user ID.';

    trigger OnInsert()
    begin
        if Default then
            CheckDefault();
    end;

    trigger OnModify()
    begin
        if Default then
            CheckDefault();
    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    local procedure CheckDefault()
    var
        StoreUser: Record "GXL PDA-Store User";
    begin
        StoreUser.SetRange("User ID", "User ID");
        StoreUser.SetFilter("Store Code", '<>%1', "Store Code");
        StoreUser.SetRange(Default, true);
        if not StoreUser.IsEmpty() then
            Error(OneDefaultUserPerStoreErr);
    end;
}