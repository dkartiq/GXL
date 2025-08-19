table 50371 "GXL Email Setup"
{
    Caption = 'Email Setup';

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Email Type"; Option)
        {
            Caption = 'Email Type';
            OptionCaption = ' ,Outlook,SMTP';
            OptionMembers = " ",Outlook,SMTP;
        }
        field(3; "Allow Email Only for Rel. Doc."; Boolean)
        {
            Caption = 'Allow Email only for Released Documents';
            InitValue = true;
        }
        field(5; "Clear Log Date Formula"; DateFormula)
        {
            Caption = 'Clear Log Date Formula';

            trigger OnValidate()
            var
                PeriodDate: Date;
            begin
                PeriodDate := CALCDATE("Clear Log Date Formula", TODAY());

                IF PeriodDate > TODAY() THEN BEGIN
                    EVALUATE("Clear Log Date Formula", '-' + FORMAT("Clear Log Date Formula"));
                END;
            end;
        }
        field(6; "Test Mode"; Boolean)
        {
            Caption = 'Test Mode';

            trigger OnValidate()
            begin
                CheckTestMode();
            end;
        }
        field(7; "Test Email"; Text[80])
        {
            Caption = 'Test Email';
            ExtendedDatatype = EMail;

            trigger OnValidate()
            begin
                CheckTestMode();
                EmailFunctions.CheckValidEmailAddresses("Test Email");
            end;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        EVALUATE("Clear Log Date Formula", '-1Y');
    end;

    var
        EmailFunctions: Codeunit "GXL Email Functions";

    [Scope('OnPrem')]
    procedure CheckTestMode()
    begin
        IF "Test Mode" THEN BEGIN
            TESTFIELD("Test Email");
        END;
    end;
}

