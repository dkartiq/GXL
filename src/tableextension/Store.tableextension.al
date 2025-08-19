// 001  04-04-2024  HP-2346 KDU Procedure to identify if the system is Store or not. 
tableextension 50150 "GXL Store" extends "LSC Store"
{
    fields
    {
        field(50000; "GXL Delta Ranging Required"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Delta Ranging Required';
            Editable = false;
        }
        field(50001; "GXL Store Closed"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Store Closed';
            Editable = false;
        }
        field(50010; "GXL LS Live Store"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'LS Live Store';
        }
        field(50011; "GXL LS Store Go-Live Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'LS Store Go-Live Date';
        }
        field(50013; "GXL Pre-Live Adj. Reason Code"; Code[10])
        {
            Caption = 'Pre-Live Adj. Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code".Code;
        }
        field(50150; "GXL Region Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Region Code';
            TableRelation = "GXL Region";
        }
        field(50151; "GXL Region 2 Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Region 2 Code';
            TableRelation = "GXL Region";
        }
        field(50152; "GXL Open Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Open Date';

            trigger OnValidate()
            begin
                if "GXL Closed Date" <> 0D then
                    if "GXL Closed Date" < "GXL Open Date" then
                        Error(GXL_DateCannotBeEarlierThanErr, FieldCaption("GXL Closed Date"), FieldCaption("GXL Open Date"));
            end;
        }
        field(50153; "GXL Closed Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Closed Date';

            trigger OnValidate()
            var
                ProdStatusMgt: Codeunit "GXL Product Status Management";
                ProdRangingMgt: Codeunit "GXL Product Ranging Management";
            begin
                if "GXL Closed Date" <> 0D then
                    if "GXL Closed Date" < "GXL Open Date" then
                        Error(GXL_DateCannotBeEarlierThanErr, FieldCaption("GXL Closed Date"), FieldCaption("GXL Open Date"));
                if "GXL Closed Date" <> xRec."GXL Closed Date" then begin
                    if ProdRangingMgt.CheckStoreClosed(Rec) then
                        Validate("GXL Store Closed", true)
                    else
                        Validate("GXL Store Closed", false);
                    if "Location Code" <> '' then
                        ProdStatusMgt.UpdateStatusOnStoreClosedDate(xRec."GXL Closed Date", "GXL Closed Date", "Location Code");
                end;
            end;
        }
        field(50154; "GXL Location Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Location Type';
            OptionMembers = "1","3","6";
            OptionCaption = '1 - Supplier,3 - DC,6 - Store';

            trigger OnValidate()
            begin
                //Product ranging
                if "GXL Location Type" <> xRec."GXL Location Type" then
                    "GXL Delta Ranging Required" := true;
            end;
        }
        //PDA
        field(50250; "GXL Rolled-Out"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Rolled-Out';
        }
        //PS-2523 VET Clinic transfer order +
        field(50251; "GXL VET Store"; Boolean)
        {
            Caption = 'VET Store';
            DataClassification = CustomerContent;
        }
        //PS-2523 VET Clinic transfer order -
        //WMS/3PL
        field(50350; "GXL Warehouse Type"; Option)
        {
            DataClassification = CustomerContent;
            OptionMembers = " ","3PL Warehouse";
            trigger OnValidate()
            begin
                TestField("Store Type", "Store Type"::Other);
            end;
        }
        field(50352; "GXL Audit Count"; Integer)
        {
            Caption = 'Audit Count';
            DataClassification = CustomerContent;
        }
        field(50353; "GXL Next Audit Date"; Date)
        {
            Caption = 'Next Audit Date';
            DataClassification = CustomerContent;
        }
        field(50354; "GXL Audit Date"; Date)
        {
            Caption = 'Audit Date';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(GXL_LocationType; "GXL Location Type")
        { }
        key(GXL_Key2; "GXL Closed Date", "GXL Location Type", "GXL Audit Count") { }
    }

    var
        GXL_DateCannotBeEarlierThanErr: Label '%1 cannot be earlier than %2.';


    trigger OnInsert()
    begin
        //Product ranging
        "GXL Delta Ranging Required" := true;
    end;

    // >> 001 
    procedure IsStore(StoreNoP: code[20]): Boolean
    begin
        if StoreNoP = '' then
            exit(false);
        Rec.Get(StoreNoP);
        exit(Rec."Store Type" <> Rec."Store Type"::"Head Office");
    end;
    // << 001
}