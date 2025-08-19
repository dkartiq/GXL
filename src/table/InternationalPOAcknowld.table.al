table 50389 "GXL International PO Acknowld"
{
    Caption = 'International Purchase Order Acknowledgement';

    fields
    {
        field(1; "No."; Code[20])
        {
        }
        field(2; "Purchase Order No."; Code[20])
        {
        }
        field(3; "Order Version No."; Integer)
        {
        }
        field(4; "Order Processing Date"; Date)
        {
        }
        field(5; Status; Option)
        {
            OptionMembers = Imported,"Validation Error",Validated,"Processing Error",Processed;
        }
        field(6; "Status Message"; Text[250])
        {
        }
        field(10; "EDI File Log Entry No."; Integer)
        {
            TableRelation = "GXL EDI File Log"."Entry No.";
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
        key(Key2; "EDI File Log Entry No.")
        {
        }
    }

    fieldgroups
    {
    }
}

