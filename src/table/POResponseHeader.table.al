table 50360 "GXL PO Response Header"
{
    DataCaptionFields = "Response Number";
    DrillDownPageID = "GXL PO Responses";
    LookupPageID = "GXL PO Responses";

    fields
    {
        field(1; "Response Number"; Code[35])
        {
            Caption = 'Response Number';
        }
        field(2; "PO Response Date"; Date)
        {
            Caption = 'Date';
        }
        field(3; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            TableRelation = Vendor;
        }
        field(4; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(5; "Order No."; Code[20])
        {
            Caption = 'Order No.';
        }
        field(6; "Expected Receipt Date"; Date)
        {
            Caption = 'Expected Receipt Date';
        }
        field(7; "Ship-to Code"; Code[20])
        {
            Caption = 'Ship-to Code';
        }
        field(8; "Response Type"; Option)
        {
            Caption = 'Response Type';
            OptionCaption = ' ,Accepted,Changed,Rejected';
            OptionMembers = " ",Accepted,Changed,Rejected;
        }
        field(9; Status; Option)
        {
            Caption = 'Status';
            Description = 'pv00.01';
            OptionCaption = 'Imported,Validation Error,Validated,Processing Error,Processed';
            OptionMembers = Imported,"Validation Error",Validated,"Processing Error",Processed;
        }
        field(10; "EDI File Log Entry No."; Integer)
        {
            Caption = 'EDI File Log Entry No.';
            Description = 'pv00.01';
            TableRelation = "GXL EDI File Log"."Entry No.";
        }
        field(11; "ASN Document Type"; Option)
        {
            Caption = 'ASN Document Type';
            Description = 'pv00.02';
            OptionCaption = ',Purchase,Transfer';
            OptionMembers = ,Purchase,Transfer;
        }
        field(12; "ASN Document No."; Code[20])
        {
            Caption = 'ASN Document No.';
            Description = 'pv00.02';
            TableRelation = "GXL ASN Header";
        }
        field(13; "Original EDI Document No."; Code[35])
        {
            Caption = 'Original EDI Document No.';
        }
        field(14; "NAV EDI Document No."; Code[60])
        {
            Caption = 'NAV EDI Document No.';
        }
    }

    keys
    {
        key(Key1; "Response Number")
        {
            Clustered = true;
        }
        key(Key2; "EDI File Log Entry No.")
        {
        }
        key(Key3; "Order No.")
        {
        }
        key(Key4; Status)
        {
        }
        key(Key5; "Original EDI Document No.", "Buy-from Vendor No.")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        POResponseLine: Record "GXL PO Response Line";
    begin
        POResponseLine.SETRANGE("PO Response Number", "Response Number");
        POResponseLine.DELETEALL(TRUE);
    end;
}

