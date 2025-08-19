table 50007 "GXL Illegal Product Range Log"
{
    Caption = 'Illegal Product Range Log';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item;
        }
        field(3; "Store Code"; Code[10])
        {
            Caption = 'Store Code';
            DataClassification = CustomerContent;
            TableRelation = Location;
        }
        field(10; "Logged Date"; Date)
        {
            Caption = 'Logged Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(21; "Sent Date"; Date)
        {
            Caption = 'Sent Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(30; "Store Name"; Text[100])
        {
            Caption = 'Store Name';
            FieldClass = FlowField;
            CalcFormula = lookup(Location.Name where(Code = field("Store Code")));
            Editable = false;
        }
        field(31; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            FieldClass = FlowField;
            CalcFormula = lookup(Item.Description where("No." = field("Item No.")));
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(StoreItem; "Store Code", "Item No.")
        { }
        key(SentDate; "Sent Date")
        { }
    }

    var


    trigger OnInsert()
    begin
        "Logged Date" := WorkDate();
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

    procedure CheckIllegalProdLogged(ItemCode: Code[20]; StoreCode: Code[10]): Boolean
    var
        IllegalItem: Record "GXL Illegal Item";
        IllegalProdRangeLog: Record "GXL Illegal Product Range Log";
        LastSetDate: Date;
    begin
        //If already been logged today?
        IllegalProdRangeLog.SETCURRENTKEY("Store Code", "Item No.");
        IllegalProdRangeLog.SETRANGE("Store Code", StoreCode);
        IllegalProdRangeLog.SETRANGE("Item No.", ItemCode);
        IllegalProdRangeLog.SETRANGE("Logged Date", TODAY);
        IF NOT IllegalProdRangeLog.IsEmpty() THEN
            EXIT(TRUE);

        //Get last date that the SKU set as illegal
        //check if the SKU has already been logged since that last date set
        LastSetDate := IllegalItem.GetLastDateIllegalSKUSet(ItemCode, StoreCode);
        IF LastSetDate <> 0D THEN BEGIN
            IllegalProdRangeLog.SETFILTER("Logged Date", '>=%1', LastSetDate);
            IF NOT IllegalProdRangeLog.IsEmpty() THEN
                EXIT(TRUE);
        END;

        EXIT(FALSE);
    end;

    procedure LogIllegalProdRanged(ItemCode: Code[20]; StoreCode: Code[10])
    var
        IllegalProdRangeLog: Record "GXL Illegal Product Range Log";
    begin
        IllegalProdRangeLog.Init();
        IllegalProdRangeLog."Entry No." := 0;
        IllegalProdRangeLog."Item No." := ItemCode;
        IllegalProdRangeLog."Store Code" := StoreCode;
        IllegalProdRangeLog.Insert(true);
    end;

}