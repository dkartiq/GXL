// 001 8.07.2025 KDU HP2-Sprint2
tableextension 50012 "GXL Reason Code" extends "Reason Code"
{
    fields
    {
        field(50250; "GXL Audit Reason Code"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Audit Reason Code';
        }
        field(50251; "GXL Stock Adj."; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Stock Adj.';
            // >> LCB-120
            trigger OnValidate()
            begin
                if not "GXL Stock Adj." then
                    "GXL Source of Supply" := "GXL Source of Supply"::" ";
            end;
            // << LCB-120
        }
        field(50252; "GXL PO. Variance"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'PO. Variance';
        }
        field(50253; "GXL Claimable"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Claimable';
        }
        field(50254; "GXL Ullaged"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Ullaged';
            OptionMembers = Both,Ullaged,"Non-Ullaged";
            OptionCaption = 'Both,Ullaged,Non-Ullaged';
        }
        field(50255; "GXL PDA-SOH Update"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'PDA-SOH Update';

            trigger OnValidate()
            var
                GXLReasonCode: Record "Reason Code";
            begin
                if "GXL PDA-SOH Update" then begin
                    GXLReasonCode.SetRange("GXL PDA-SOH Update", true);
                    GXLReasonCode.SetFilter(Code, '<>%1', Code);
                    if not GXLReasonCode.IsEmpty() then
                        Error('There must be only one reason code that is %1.', FieldCaption("GXL PDA-SOH Update"));
                end;
            end;
        }
        field(50256; "GXL PDA Short Supply"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'PDA Short Supply';
        }
        field(50257; "GXL PDA Over Supply"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'PDA Over Supply';
        }
        // >> LCB-120
        field(50258; "GXL Source of Supply"; Option)
        {
            DataClassification = SystemMetadata;
            Caption = 'Source of Supply';
            OptionMembers = " ",SD,WH,"Both SD and WH";
            trigger OnValidate()
            begin
                IF "GXL Source of Supply" <> "GXL Source of Supply"::" " then
                    TestField("GXL Stock Adj.", true);
            end;
        }
        // >> LCB-120
        // >> 001
        field(50259; "GXL PO Change Reason Code"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'PO Change Reason Code';
        }
        // << 001
    }

}