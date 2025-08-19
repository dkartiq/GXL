//CR050: PS-1948 External stocktake
table 50021 "GXL External Stocktake Line"
{
    Caption = 'External Stocktake Line';
    DataClassification = CustomerContent;
    LookupPageId = "GXL External Stocktake Lines";
    DrillDownPageId = "GXL External Stocktake Lines";

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

            trigger OnValidate()
            begin
                "Quantity (Base)" := UnitOfMeasureMgt.CalcBaseQty(Quantity, "Qty. per Unit of Measure");
            end;
        }
        field(14; "Quantity (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Quantity (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(15; "Qty. per Unit of Measure"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. per Unit of Measure';
            DecimalPlaces = 0 : 5;
            InitValue = 1;
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
        field(44; "Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(53; "Qty. Calculated (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. Calculated (Base)';
            DecimalPlaces = 0 : 5;
        }
        field(54; "Qty. (Phys. Inventory)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. (Phys. Inventory)';
            DecimalPlaces = 0 : 5;

            trigger OnValidate()
            begin
                "Qty. Phys. Inventory (Base)" := UnitOfMeasureMgt.CalcBaseQty("Qty. (Phys. Inventory)", "Qty. per Unit of Measure");
            end;
        }
        field(55; "Qty. Phys. Inventory (Base)"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Qty. Phys. Inventory (Base)';
            DecimalPlaces = 0 : 5;
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

    }

    keys
    {
        key(PK; "Batch ID", "Line No.")
        {
            Clustered = true;
        }
        key(Key2; "Process Status", "Item No.")
        {
        }
        key(Key3; "Item No.")
        {
        }
    }

    var
        UnitOfMeasureMgt: Codeunit "Unit of Measure Management";


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

    procedure CalculateInventory()
    var
        Item: Record Item;
    begin
        if "Item No." <> '' then begin
            Item.Get("Item No.");
            if "Posting Date" <> 0D then
                CalculateInventory(Item, "Posting Date")
            else
                CalculateInventory(Item, Today());
        end;
    end;

    procedure CalculateInventory(var Item: Record Item; ToDate: Date)
    begin
        Item.SetFilter("Location Filter", "Location Code");
        Item.SetRange("Date Filter", 0D, ToDate);
        Item.CalcFields("Net Change");
        "Qty. Calculated (Base)" := Item."Net Change";
    end;

    procedure ResetError(var NewExtStocktakeLine: Record "GXL External Stocktake Line")
    var
        ExtStocktakeLine: Record "GXL External Stocktake Line";
        ExtStocktakeLine2: Record "GXL External Stocktake Line";
        ExtStocktakeLine3: Record "GXL External Stocktake Line";
        TempItem: Record "Document Search Result" temporary;
    begin
        ExtStocktakeLine.Copy(NewExtStocktakeLine);
        ExtStocktakeLine.SetCurrentKey("Process Status");
        ExtStocktakeLine.SetRange("Process Status", ExtStocktakeLine."Process Status"::"Posting Error");
        ExtStocktakeLine.SetRange("Batch ID", "Batch ID");
        if ExtStocktakeLine.IsEmpty() then
            Error('Processed Status must be Posting Error can be reset');

        TempItem.Reset();
        TempItem.DeleteAll();
        if ExtStocktakeLine.FindSet() then
            repeat
                ExtStocktakeLine2 := ExtStocktakeLine;
                ExtStocktakeLine2."Process Status" := ExtStocktakeLine."Process Status"::Imported;
                ExtStocktakeLine2.Modify();

                if "Item No." <> '' then begin
                    ExtStocktakeLine3.SetCurrentKey("Item No.");
                    ExtStocktakeLine3.SetRange("Batch ID", ExtStocktakeLine."Batch ID");
                    ExtStocktakeLine3.SetRange("Item No.", ExtStocktakeLine."Item No.");
                    ExtStocktakeLine3.SetFilter("Line No.", '<>%1', ExtStocktakeLine."Line No.");
                    ExtStocktakeLine3.SetRange("Process Status", ExtStocktakeLine3."Process Status"::"Posting Error");
                    if not ExtStocktakeLine3.IsEmpty() then begin
                        TempItem.Init();
                        TempItem."Doc. No." := ExtStocktakeLine."Item No.";
                        TempItem.Insert();
                    end;
                end;
            until ExtStocktakeLine.Next() = 0;

        ExtStocktakeLine3.Reset();
        if TempItem.FindSet() then
            repeat
                ExtStocktakeLine3.SetCurrentKey("Item No.");
                ExtStocktakeLine3.SetRange("Batch ID", ExtStocktakeLine."Batch ID");
                ExtStocktakeLine3.SetRange("Item No.", TempItem."Doc. No.");
                ExtStocktakeLine3.SetRange("Process Status", ExtStocktakeLine3."Process Status"::"Posting Error");
                if ExtStocktakeLine3.FindSet() then
                    repeat
                        ExtStocktakeLine2 := ExtStocktakeLine3;
                        ExtStocktakeLine2."Process Status" := ExtStocktakeLine."Process Status"::Imported;
                        ExtStocktakeLine2.Modify();
                    until ExtStocktakeLine3.Next() = 0;
            until TempItem.Next() = 0;
        TempItem.DeleteAll();
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