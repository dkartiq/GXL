// 001 08.07.2025 KDU HP2-Sprint2
tableextension 50017 "GXL Purchases & Payables Setup" extends "Purchases & Payables Setup"
{
    fields
    {
        field(50010; "GXL BP Receipt Age Days"; Integer)
        {
            Caption = 'BP Receipt Age Days';
            DataClassification = CustomerContent;
        }
        /*
        field(50010; "GXL BP Vendor No."; Code[20])
        {
            Caption = 'BP Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(50011; "GXL BP Bank Acc. No."; Code[20])
        {
            Caption = 'BP Bank Acc. No.';
            DataClassification = CustomerContent;
            TableRelation = "Bank Account";
        }
        field(50012; "GXL BP Purchase G/L Acc. No."; Code[20])
        {
            Caption = 'BP Purchase G/L Acc. No.';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account" where ("Direct Posting" = const (true));
        }
        */
        field(50013; "GXL BP Payment Method Code"; Code[10])
        {
            Caption = 'BP Payment Method Code';
            DataClassification = CustomerContent;
            TableRelation = "Payment Method";
        }
        // field(50014; "GXL BP Transitional Inv. Nos."; Code[20])
        // {
        //     Caption = 'BP Transitional Inv. Nos.';
        //     DataClassification = CustomerContent;
        //     TableRelation = "No. Series";
        // }
        field(50015; "GXL BP Trans. Posted Inv. Nos."; Code[20])
        {
            Caption = 'BP Trans. Posted Inv. Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        // >> LCB-203  
        field(50016; "GXL Override OP/OM Calc."; Boolean)
        {
            Caption = 'Override OP/OM Calculation';
            DataClassification = SystemMetadata;
        }
        // << LCB-203 

        // >> LCB-250
        field(50017; "GXL EDI Validate VendReord No."; Boolean)
        {
            Caption = 'EDI Validate Vendor Reorder No.';
            DataClassification = SystemMetadata;
        }
        // << LCB-250
        // >> 001
        field(50018; "Import Order Nos."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Import Order Nos.';
            TableRelation = "No. Series";
        }
        // << 001
    }
}