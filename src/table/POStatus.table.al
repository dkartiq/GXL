table 50080 "GXL PO Status"
{
    DataClassification = ToBeClassified;

    fields
    {
        field(1; Status; Enum "GXL PO Status")
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                if Description = '' then
                    Description := Format(Rec.Status);
            end;
        }
        field(2; Description; Text[100])
        {
            DataClassification = ToBeClassified;
            NotBlank = true;
        }
        field(3; "Authorized Users"; Code[1024])
        {
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                ValidateAuthorizedUser();
            end;

            trigger OnLookup()
            begin
                Rec.Validate("Authorized Users", LookupUser());
            end;
        }
    }

    keys
    {
        key(PK; Status)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Status, Description) { }
    }
    local procedure ValidateAuthorizedUser()
    var
        User: Record User;
    begin
        if Rec."Authorized Users" > '' then begin
            User.SetRange(State, User.State::Enabled);
            User.SetFilter("User Name", rec."Authorized Users");
            if User.IsEmpty then
                IF CONFIRM('There are no active users within filter %1.\Would you like to clear the value.', true, Rec."Authorized Users") then
                    rec."Authorized Users" := '';
        end;
    end;

    local procedure LookupUser(): Text
    var
        User: Record User;
        UserPage: Page "User Lookup";
        UserFilter: Text;
    begin
        User.SetRange(State, User.State::Enabled);
        UserPage.SetTableView(User);
        UserPage.LookupMode(true);
        if UserPage.RunModal() <> Action::LookupOK then
            exit('');
        UserPage.GetSelectedUsers(User);
        if not User.FindSet() then
            exit('');

        repeat
            UserFilter += User."User Name" + '|';
        until User.Next() = 0;
        if UserFilter > '' then
            UserFilter += CopyStr(UserFilter, 1, StrLen(UserFilter) - 1); // Remove last '|'

        exit(UserFilter);

    end;

    trigger OnDelete()
    var
        POStatusChangeMapping: Record "GXL PO Status Change Mapping";
    begin
        //Status From
        POStatusChangeMapping.SetRange(From, Status);
        if not POStatusChangeMapping.IsEmpty then
            POStatusChangeMapping.DeleteAll();

        //Status To
        POStatusChangeMapping.SetRange(From);
        POStatusChangeMapping.SetRange("To", Status);
        if not POStatusChangeMapping.IsEmpty then
            POStatusChangeMapping.DeleteAll();
    end;
}