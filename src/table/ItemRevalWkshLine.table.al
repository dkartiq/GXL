/// <summary>
/// CR099 - Revaluation Journal Batch
/// </summary>
table 50042 "GXL Item Reval. Wksh. Line"
{
    Caption = 'Item Revaluation Wksh Line';
    DataCaptionFields = "Batch ID";
    DataClassification = CustomerContent;
    DrillDownPageID = "GXL Item Reval. Wksh. Lines";
    LookupPageID = "GXL Item Reval. Wksh. Lines";

    fields
    {
        field(1; "Batch ID"; Integer)
        {
            Caption = 'Batch ID';
            DataClassification = CustomerContent;
            TableRelation = "GXL Item Reval. Wksh. Batch";
            Editable = false;
        }
        field(2; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(4; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(5; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Reason Code";
        }
        field(7; "Document No."; Code[20])
        {
            Caption = 'Document No.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(8; "Item Description"; Text[100])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(11; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            Editable = false;
        }
        field(18; Amount; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Amount';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(20; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
            DataClassification = CustomerContent;
            Editable = false;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(30; "Inventory Value (Calculated)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Inventory Value (Calculated)';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                ReadGLSetup;
                TestField(Quantity);
                "Unit Cost (Calculated)" := Round("Inventory Value (Calculated)" / Quantity, GLSetup."Unit-Amount Rounding Precision");
                Validate(Amount, "Inventory Value (Revalued)" - "Inventory Value (Calculated)");
            end;
        }
        field(31; "Inventory Value (Revalued)"; Decimal)
        {
            AutoFormatType = 1;
            Caption = 'Inventory Value (Revalued)';
            DataClassification = CustomerContent;
            MinValue = 0;
            Editable = false;

            trigger OnValidate()
            begin
                Validate(Amount, "Inventory Value (Revalued)" - "Inventory Value (Calculated)");
            end;
        }
        field(32; "Unit Cost (Calculated)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (Calculated)';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(33; "Unit Cost (Revalued)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Unit Cost (Revalued)';
            DataClassification = CustomerContent;
            MinValue = 0;
            Editable = false;

            trigger OnValidate()
            begin
                ReadGLSetup;
                Validate("Inventory Value (Revalued)", Round("Unit Cost (Revalued)" * Quantity, GLSetup."Amount Rounding Precision"));
            end;
        }
        field(40; "Inventory Value Per"; Option)
        {
            Caption = 'Inventory Value Per';
            DataClassification = CustomerContent;
            OptionMembers = " ",Item,Location,"Variant","Location and Variant";
            OptionCaption = ' ,Item,Location,Variant,Location and Variant';
            Editable = false;
        }
        field(50; Status; Option)
        {
            Caption = 'Status';
            DataClassification = CustomerContent;
            Editable = false;
            OptionCaption = 'Imported,Value Calculated,Value Calc. Error,Posting Error,Posted';
            OptionMembers = Imported,"Value Calculated","Value Calc. Error","Posting Error",Posted;
        }
        field(51; "Error Message"; Text[250])
        {
            Caption = 'Error Message';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(55; "Processed Date Time"; DateTime)
        {
            Caption = 'Processed Date Time';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(56; "Processed by User"; Code[50])
        {
            Caption = 'Processed by User';
            DataClassification = EndUserIdentifiableInformation;
            Editable = false;
        }
        //ERP-320 +
        field(100; "Inventory Posting Group"; Code[20])
        {
            Caption = 'Inventory Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Inventory Posting Group";
        }
        field(101; "Gen. Product Posting Group"; Code[20])
        {
            Caption = 'Gen. Product Posting Group';
            DataClassification = CustomerContent;
            TableRelation = "Gen. Product Posting Group";
        }
        field(102; "Cost Update Forced"; Boolean)
        {
            Caption = 'Cost Update Forced';
            DataClassification = CustomerContent;
            Editable = false;
        }
        //ERP-320 -
    }

    keys
    {
        key(Key1; "Batch ID", "Line No.") { Clustered = true; }
        key(Key2; Status) { MaintainSIFTIndex = false; SumIndexFields = Amount; }
    }

    var
        RevalWkshBatch: Record "GXL Item Reval. Wksh. Batch";
        GLSetup: Record "General Ledger Setup";
        GLSetupRead: Boolean;


    trigger OnDelete()
    begin
        DeleteWkshLocLines();
    end;

    local procedure ReadGLSetup()
    begin
        if not GLSetupRead then begin
            GLSetup.Get;
            GLSetupRead := true;
        end;
    end;

    local procedure TestProcessStatus()
    begin
        if (Status = Status::Posted) then
            FieldError(Status);
        RevalWkshBatch.Get("Batch ID");
        if (RevalWkshBatch."Job Queue Status" <> RevalWkshBatch."Job Queue Status"::"Not Scheduled") then
            RevalWkshBatch.FieldError("Job Queue Status");
    end;


    procedure GetStatusStyleTxt(): Text
    begin
        case Status of
            Status::"Value Calc. Error",
          Status::"Posting Error":
                exit('Unfavorable');
            Status::Posted:
                exit('Favorable');
        end;
    end;


    procedure SetNewUserDateTime()
    begin
        "Processed by User" := UserId();
        "Processed Date Time" := CurrentDateTime();
    end;


    procedure SetNewStatus(NewStatus: Integer; NewErrorMsg: Text)
    begin
        Status := NewStatus;
        "Error Message" := '';
        if Status in [Status::"Value Calc. Error", Status::"Posting Error"] then
            "Error Message" := CopyStr(NewErrorMsg, 1, MaxStrLen("Error Message"));
    end;

    procedure DeleteWkshLocLines()
    var
        RevalWkshLocLine: Record "GXL Item Reval. Wksh. Loc Line";
    begin
        RevalWkshLocLine.SetRange("Batch ID", "Batch ID");
        RevalWkshLocLine.SetRange("Wksh. Line No.", "Line No.");
        if not RevalWkshLocLine.IsEmpty() then
            RevalWkshLocLine.DeleteAll();
    end;
}

