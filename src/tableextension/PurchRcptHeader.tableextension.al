tableextension 50021 "GXL Purch. Rcpt. Header" extends "Purch. Rcpt. Header"
{
    fields
    {
        //ERP-NAV Master Data Management +
        field(50300; "GXL Port of Loading Code"; Code[10])
        {
            Caption = 'Port of Loading Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL Port of Loading";
        }
        field(50301; "GXL Port of Arrival Code"; Code[10])
        {
            Caption = 'Port of Arrival Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL Port of Loading";
        }
        field(50302; "GXL Orig. Vendor Shipment Date"; Date)
        {
            Caption = 'Original Vendor Shipment Date';
            DataClassification = CustomerContent;
        }
        field(50303; "GXL Original Port Arrival Date"; Date)
        {
            Caption = 'Into Original Port Arrival Date';
            DataClassification = CustomerContent;
        }
        field(50304; "GXL Original DC Receipt Date"; Date)
        {
            Caption = 'Original DC Receipt Date';
            DataClassification = CustomerContent;
        }
        field(50305; "GXL Vendor Shipment Date"; Date)
        {
            Caption = 'Vendor Shipment Date';
            DataClassification = CustomerContent;
        }
        field(50306; "GXL Port Arrival Date"; Date)
        {
            Caption = 'Port Arrival Date';
            DataClassification = CustomerContent;
        }
        field(50307; "GXL DC Receipt Date"; Date)
        {
            Caption = 'DC Receipt Date';
            DataClassification = CustomerContent;
        }
        field(50308; "GXL Actual Receipt Date"; Date)
        {
            Caption = 'Actual Receipt Date';
            DataClassification = CustomerContent;
        }
        field(50310; "GXL Incoterms Code"; Code[10])
        {
            Caption = 'Incoterms Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL Incoterms";
        }
        field(50311; "GXL Import Agent Number"; Code[20])
        {
            Caption = 'Import Agent Number';
            DataClassification = CustomerContent;
            TableRelation = Vendor."No." where("GXL Import Vendor/Agent" = const(true));
        }
        field(50312; "GXL Container No."; Code[20])
        {
            Caption = 'Container No.';
            DataClassification = CustomerContent;
        }
        field(50313; "GXL Container Type"; Option)
        {
            Caption = 'Container Type';
            DataClassification = CustomerContent;
            OptionMembers = " ","20ft","40ft","40ft HC",LCL;
        }
        field(50314; "GXL Container Carrier"; Text[50])
        {
            Caption = 'Container Carrier';
            DataClassification = CustomerContent;
        }
        field(50315; "GXL Container Vessel"; Text[50])
        {
            Caption = 'Container Vessel';
            DataClassification = CustomerContent;
        }
        field(50316; "GXL Shipment Load Type"; Option)
        {
            Caption = 'Shipment Load Type';
            DataClassification = CustomerContent;
            OptionMembers = ,Pallet,"Slip-Sheet",Carton;
            OptionCaption = ' ,Pallet,Slip-Sheet,Carton';
        }
        field(50320; "GXL Total Ordered Quantity"; Decimal)
        {
            Caption = 'Total Ordered Quantity';
            FieldClass = FlowField;
            CalcFormula = sum("Purch. Rcpt. Line".Quantity where("Document No." = field("No.")));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(50321; "GXL Total Weight"; Decimal)
        {
            Caption = 'Total Weight';
            FieldClass = FlowField;
            CalcFormula = sum("Purch. Rcpt. Line"."GXL Gross Weight" where("Document No." = field("No.")));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(50322; "GXL Total Cubage"; Decimal)
        {
            Caption = 'Total Cubage';
            FieldClass = FlowField;
            CalcFormula = sum("Purch. Rcpt. Line"."GXL Cubage" where("Document No." = field("No.")));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(50359; "GXL 3PL"; Boolean)
        {
            Caption = '3PL';
            DataClassification = CustomerContent;
        }
        field(50361; "GXL Source of Supply"; enum "GXL Source of Supply")
        {
            Caption = 'Source of Supply';
            DataClassification = CustomerContent;
        }
        field(50367; "GXL International Order"; Boolean)
        {
            Caption = 'International Order';
            DataClassification = CustomerContent;
        }
        field(50380; "GXL Total Order Value"; Decimal)
        {
            Caption = 'Total Order Value';
            DataClassification = CustomerContent;
            Editable = false;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
        }
        field(50381; "GXL Total Order Qty"; Decimal)
        {
            Caption = 'Total Order Qty';
            DataClassification = CustomerContent;
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(50397; "GXL Manual PO"; Boolean)
        {
            Caption = 'Manual PO';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50398; "GXL Order Type"; Option)
        {
            Caption = 'Order Type';
            DataClassification = CustomerContent;
            OptionMembers = Manual,Automatic,JDA;
            Editable = false;
        }
        //ERP-NAV Master Data Management -
    }
}