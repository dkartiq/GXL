table 50385 "GXL Freight Forwarder"
{
    Caption = 'Freight Forwarder';
    DrillDownPageId = "GXL Freight Forwarders";
    LookupPageId = "GXL Freight Forwarders";
    fields
    {
        field(1; "Code"; Code[20])
        {
            NotBlank = true;
        }
        field(2; Name; Text[50])
        {
        }
        field(3; "GXL Customer ID"; Code[20])
        {

            trigger OnValidate()
            begin
                IF "GXL Customer ID" = '' THEN
                    TESTFIELD(Status, Status::Inactive);
            end;
        }
        field(4; "Outbound FTP Folder"; Text[250])
        {

            trigger OnValidate()
            begin
                IF "Outbound FTP Folder" = '' THEN
                    TESTFIELD(Status, Status::Inactive);

                ValidatePath("Outbound FTP Folder");
            end;
        }
        field(5; "Inbound FTP Folder"; Text[250])
        {

            trigger OnValidate()
            begin
                IF "Inbound FTP Folder" = '' THEN
                    TESTFIELD(Status, Status::Inactive);

                ValidatePath("Inbound FTP Folder");
            end;
        }
        field(6; "Archive Folder"; Text[250])
        {

            trigger OnValidate()
            begin
                IF "Archive Folder" = '' THEN
                    TESTFIELD(Status, Status::Inactive);

                ValidatePath("Archive Folder");
            end;
        }
        field(7; "Error Folder"; Text[250])
        {

            trigger OnValidate()
            begin
                IF "Error Folder" = '' THEN
                    TESTFIELD(Status, Status::Inactive);

                ValidatePath("Error Folder");
            end;
        }
        field(8; "EDI Notifications E-Mail"; Text[80])
        {
        }
        field(10; "PO Filename Prefix"; Text[30])
        {
            Caption = 'Intl. PO File Name Prefix';
            InitValue = '50086';
        }
        field(11; "PO Response Filename Prefix"; Text[30])
        {
            Caption = 'PO Response Filename Prefix';
            InitValue = '50088';
        }
        field(12; "Ship. Advice Filename Prefix"; Text[30])
        {
            Caption = 'Intl. Shipping Status File Name Prefix';
            InitValue = '50087';
        }
        field(20; Status; Option)
        {
            OptionMembers = Inactive,Active;

            trigger OnValidate()
            begin
                IF Status = Status::Active THEN BEGIN
                    TESTFIELD("GXL Customer ID");
                    TESTFIELD("Outbound FTP Folder");
                    TESTFIELD("Inbound FTP Folder");
                    TESTFIELD("Archive Folder");
                    TESTFIELD("Error Folder");
                    TESTFIELD("PO Filename Prefix");
                    TESTFIELD("PO Response Filename Prefix");
                    TESTFIELD("Ship. Advice Filename Prefix");

                    ValidatePath("Outbound FTP Folder");
                    ValidatePath("Inbound FTP Folder");
                    ValidatePath("Archive Folder");
                    ValidatePath("Error Folder");
                END;
            end;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; Status)
        {
        }
    }

    fieldgroups
    {
    }

    local procedure ValidatePath(DirectoryPath: Text)
    var
        GXLMiscUtilities: Codeunit "GXL Misc. Utilities";
    begin
        IF DirectoryPath <> '' THEN
            GXLMiscUtilities.CheckServerDirectory(DirectoryPath);
    end;
}

