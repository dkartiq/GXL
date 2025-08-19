//001   03.04.2022  PREM    new field "Reason Code"added
table 50009 "GXL Item Journal Buffer"
{
    Caption = 'GXL Item Journal Buffer';
    DataClassification = CustomerContent;
    LookupPageId = "GXL Item Journal Buffer";
    DrillDownPageId = "GXL Item Journal Buffer";

    fields
    {
        field(1; "Journal Template Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Template Name';
        }
        field(2; "Line No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Line No.';
        }
        field(3; "Legacy Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Legacy Item No.';
        }
        field(4; "Posting Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Posting Date';
        }
        field(5; "Entry Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry Type';
            OptionMembers = Purchase,Sale,"Positive Adjmt.","Negative Adjmt.",Transfer,Consumption,Output," ","Assembly Consumption","Assembly Output";
            OptionCaption = 'Purchase,Sale,Positive Adjmt.,Negative Adjmt.,Transfer,Consumption,Output, ,Assembly Consumption,Assembly Output';
        }
        field(6; "Source No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Source No.';
        }
        field(7; "Document No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Document No.';
        }
        field(8; Description; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(9; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
            TableRelation = Location;
        }
        field(13; Quantity; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(16; "Unit Amount"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Unit Amount';
            AutoFormatType = 2;
        }
        field(17; "Unit Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Unit Cost';
            AutoFormatType = 2;
        }
        field(18; Amount; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Amount';
            AutoFormatType = 1;
        }
        field(26; "Source Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Source Code';
        }
        field(34; "Shortcut Dimension 1 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 1 Code';
            CaptionClass = '1,2,1';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(1));
        }
        field(35; "Shortcut Dimension 2 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 2 Code';
            CaptionClass = '1,2,2';
            TableRelation = "Dimension Value".Code where("Global Dimension No." = const(2));
        }
        field(41; "Journal Batch Name"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Journal Batch Name';
        }
        field(58; "Gen. Prod. Posting Group"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Gen. Prod. Posting Group';
            TableRelation = "Gen. Product Posting Group";
            ValidateTableRelation = false;
        }
        field(60; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Date';
        }
        field(100; "Batch ID"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Batch ID';
            TableRelation = "GXL Item Jnl. Buffer Batch";
        }
        field(101; "Item No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Item No.';
            TableRelation = Item;
        }
        field(102; "Unit of Measure Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Unit of Measure Code';
            TableRelation = "Item Unit of Measure".Code where("Item No." = field("Item No."));
        }
        field(103; "Shortcut Dimension 3 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 3 Code';
            CaptionClass = '1,2,3';
        }
        field(104; "Shortcut Dimension 4 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 4 Code';
            CaptionClass = '1,2,4';
        }
        field(105; "Shortcut Dimension 5 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 5 Code';
            CaptionClass = '1,2,5';
        }
        field(106; "Shortcut Dimension 6 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 6 Code';
            CaptionClass = '1,2,6';
        }
        field(107; "Shortcut Dimension 7 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 7 Code';
            CaptionClass = '1,2,7';
        }
        field(108; "Shortcut Dimension 8 Code"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Shortcut Dimension 8 Code';
            CaptionClass = '1,2,8';
        }
        field(200; "Process Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Process Status';
            OptionMembers = Imported,"Posting Error",Posted;
            OptionCaption = 'Imported,Posting Error,Posted';
            Editable = false;
        }
        field(201; "Processed Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed Date Time';
            Editable = false;
        }
        field(202; "Processed by User"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Processed by User';
            Editable = false;
        }
        field(203; "Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
            Editable = false;
        }
        // >> 001 
        field(204; "Reason Code"; Code[10])
        {
            DataClassification = ToBeClassified;
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        // << 001        
    }

    keys
    {
        key(PK; "Batch ID", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Process Status")
        {
        }
    }

    var

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

    procedure ResetError(var NewItemJnlBuffer: Record "GXL Item Journal Buffer")
    var
        ItemJnlBuffer: Record "GXL Item Journal Buffer";
        ItemJnlBuffer2: Record "GXL Item Journal Buffer";
    begin
        ItemJnlBuffer.Copy(NewItemJnlBuffer);
        ItemJnlBuffer.SetCurrentKey("Process Status");
        ItemJnlBuffer.SetRange("Process Status", ItemJnlBuffer."Process Status"::"Posting Error");
        if ItemJnlBuffer.IsEmpty() then
            Error('Processed Status must be Posting Error can be reset');

        if ItemJnlBuffer.FindSet() then
            repeat
                ItemJnlBuffer2 := ItemJnlBuffer;
                ItemJnlBuffer2."Process Status" := ItemJnlBuffer."Process Status"::Imported;
                ItemJnlBuffer2.Modify();
            until ItemJnlBuffer.Next() = 0;
    end;

    procedure UpdateJournalPosted()
    begin
        "Process Status" := "Process Status"::Posted;
        "Error Message" := '';
        "Processed Date Time" := CurrentDateTime();
        "Processed by User" := UserId();
    end;

    procedure UpdateJournalErrored(ErrorMsg: Text[250])
    begin
        "Process Status" := "Process Status"::"Posting Error";
        "Error Message" := ErrorMsg;
        "Processed Date Time" := CurrentDateTime();
        "Processed by User" := UserId();
    end;

}