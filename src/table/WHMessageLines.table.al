// 001  18.03.2024 LCB-291 New field added
//WMSVD-002-Boomi API Sales Order integration.
// 001  30.04.2024  SKY  HP-2134  https://petbarnjira.atlassian.net/browse/HP-2134
table 50350 "GXL WH Message Lines"
{
    Caption = 'WH Message Lines';
    DataClassification = CustomerContent;

    fields
    {
        field(2; "Import Type"; Option)
        {
            Caption = 'Import Type';
            DataClassification = CustomerContent;
            OptionCaption = 'Purchase Order,Item Adj.,Transfer Order,Sales Order';
            OptionMembers = "Purchase Order","Item Adj.","Transfer Order","Sales Order"; //WMSVD-002 New option member ("Sales Order") adding.
        }
        field(3; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
        }
        field(4; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }
        field(5; "Location Code"; Code[10])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        /// This is the legacy item number
        field(6; "Item No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(7; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(8; "Qty. To Receive"; Decimal)
        {
            Caption = 'Qty. to Receive';
            DataClassification = CustomerContent;
        }
        field(9; "Qty. Variance"; Decimal)
        {
            Caption = 'Qty. Variance';
            DataClassification = CustomerContent;
        }
        field(10; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
        }
        field(19; Processed; Boolean)
        {
            Caption = 'Processed';
            DataClassification = CustomerContent;
        }
        field(20; "Error Found"; Boolean)
        {
            Caption = 'Error Found';
            DataClassification = CustomerContent;
        }
        field(21; "Error Description"; Text[250])
        {
            Caption = 'Error Description';
            DataClassification = CustomerContent;
        }
        field(22; "Date Imported"; Date)
        {
            Caption = 'Data Imported';
            DataClassification = CustomerContent;
        }
        field(23; "Time Imported"; Time)
        {
            Caption = 'Time Imported';
            DataClassification = CustomerContent;
        }
        field(24; "Entry Type"; Text[30])
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
        }
        field(25; "User Name"; Text[80])
        {
            Caption = 'User Name';
            DataClassification = CustomerContent;
        }
        field(26; "EDI Type"; Option)
        {
            Caption = 'EDI Type';
            DataClassification = CustomerContent;
            OptionMembers = " ","3PL EDI";
        }
        field(27; "EDI Claimable"; Boolean)
        {
            Caption = 'EDI Claimable';
            DataClassification = CustomerContent;
        }
        field(50; "Skip Decrease"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        field(60; "Increase Entry No."; RecordId)
        {
            DataClassification = CustomerContent;
        }
        field(70; "Decrease Entry No."; RecordId)
        {
            DataClassification = CustomerContent;
        }
        //WMSVD-002->>---------------------------------- 
        field(71; "Source No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        field(72; "Created Document No."; Code[20])
        {
            DataClassification = CustomerContent;
        }
        //<<-WMSVD-002---------------------------
        // >> 001 
        field(28; "BC Reason Code"; Code[10])
        {
            Caption = 'BC Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(29; "Mapping Exists"; Option)
        {
            Caption = 'Mapping Exists';
            DataClassification = CustomerContent;
            OptionMembers = " ",Exists,"Not Exists","Exists with Blank BC Reason Code";
        }
        // << 001
    }

    keys
    {
        key(Key1; "Document No.", "Line No.", "Import Type")
        {
            Clustered = true;
        }
        key(Key2; "Import Type", "Document No.", "Item No.")
        {
        }
        key(Key3; "EDI Type", "Document No.", "Line No.", "Import Type")
        {
        }
        //PS-2210+
        key(Key4; Processed, "EDI Claimable")
        { }
        //PS-2210-
    }

    fieldgroups
    {
    }

    procedure GetRealItemNo() RealItemNo: Code[20]
    var
        LegacyItemHelper: Codeunit "GXL Legacy Item Helpers";
        UOMCode: Code[10];
    begin
        LegacyItemHelper.GetItemNo("Item No.", RealItemNo, UOMCode);
    end;

    procedure GetRealItemNoAndUOMCode(Var UOMCode: Code[10]) RealItemNo: Code[20]
    var
        LegacyItemHelper: Codeunit "GXL Legacy Item Helpers";
    begin
        LegacyItemHelper.GetItemNo("Item No.", RealItemNo, UOMCode);
    end;

    // >> GX202316
    procedure DecreaseStock()
    var
        WhMessageLines: Record "GXL WH Message Lines";
        WhMessageLines2: Record "GXL WH Message Lines";
        DocumentNo: Text[20];
    begin
        WhMessageLines.SetRange("Entry Type", 'POSITIVE ADJMT');
        WhMessageLines.SetRange(Processed, true);
        WhMessageLines.SetRange("Skip Decrease", false);
        WhMessageLines.SetFilter("Decrease Entry No.", '');
        WhMessageLines.SetFilter("Document No.", '*_INCREASE*');
        if WhMessageLines.FindSet() then
            repeat
                WhMessageLines2.Init();
                WhMessageLines2 := WhMessageLines;

                WhMessageLines2."Entry Type" := 'NEGATIVE ADJMT';
                WhMessageLines2."Qty. To Receive" := -WhMessageLines2."Qty. To Receive";
                WhMessageLines2."Import Type" := WhMessageLines2."Import Type"::"Item Adj."; // TBD
                WhMessageLines2."Document No." := WhMessageLines."Document No.";
                DocumentNo := ConvertStr(WhMessageLines."Document No.", '_IN', '_DE');
                WhMessageLines2."Line No." := FindLineNoForDecreaseStock(WhMessageLines."Import Type", DocumentNo);
                WhMessageLines2."Document No." := DocumentNo;
                WhMessageLines2."Increase Entry No." := WhMessageLines.RecordId();
                WhMessageLines2.Processed := False; // >> 001 <<
                Clear(WhMessageLines2."Decrease Entry No.");
                WhMessageLines2.Insert(true);

                WhMessageLines."Decrease Entry No." := WhMessageLines2.RecordId();
                WhMessageLines."Skip Decrease" := true;
                WhMessageLines.Modify(true);
            until WhMessageLines.Next() = 0;
    end;

    local procedure FindLineNoForDecreaseStock(ImportType: Option; DocumentNo: Code[20]): Integer
    var
        WhMessageLinesL: Record "GXL WH Message Lines";
    begin
        WhMessageLinesL.SetRange("Import Type", ImportType);
        WhMessageLinesL.SetRange("Document No.", DocumentNo);
        if WhMessageLinesL.FindLast() then
            exit(WhMessageLinesL."Line No." + 1);
        exit(1);
    end;
    // << GX202316
}

