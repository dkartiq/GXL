//  LCB-3  23-09-2022  PREM    New field "Post Credit Claim On Receipt" added. 
tableextension 50005 "GXL Vendor" extends Vendor
{
    fields
    {

        field(50000; "GXL Supplier Planner"; Code[10])
        {
            Caption = 'Supplier Planner';
            DataClassification = CustomerContent;
            TableRelation = "GXL Planner Setup";
        }
        //ERP-293 +
        field(50001; "GXL Disable Auto Invoice"; Boolean)
        {
            Caption = 'Disable Auto Invoice';
            DataClassification = CustomerContent;
            trigger OnValidate() // >> LCB-3 << trigger added
            begin
                if NOT "GXL Disable Auto Invoice" then
                    "GXL Post Credit ClaimOnReceipt" := false;
            end;
        }
        //ERP-293 -
        field(50250; "GXL Ullaged Supplier"; Enum "GXL Vendor Ullaged Status")
        {
            Caption = 'Ullaged Supplier';
            DataClassification = CustomerContent;
        }
        field(50251; "GXL Minimum Order Value"; Decimal)
        {
            Caption = 'Minimum Order Value';
            DataClassification = CustomerContent;
        }
        field(50252; "GXL Minimum Order Quantity"; Decimal)
        {
            Caption = 'Minimum Order Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
        }
        field(50253; "GXL Rolled-Out"; Boolean)
        {
            Caption = 'Rolled-Out';
            DataClassification = CustomerContent;
        }
        field(50254; "GXL Post / Send Claims"; Enum "GXL Post/Send Claims")
        {
            Caption = 'Post / Send Claims';
            DataClassification = CustomerContent;
        }
        field(50350; "GXL EDI Order in Out. Pack UoM"; Boolean)
        {
            Caption = 'EDI Order in Out. Pack UoM';
            DataClassification = CustomerContent;
        }
        field(50351; "GXL EDI Flag"; Boolean)
        {
            Caption = 'EDI Flag';
            DataClassification = CustomerContent;
        }
        field(50352; "GXL Import Flag"; Boolean)
        {
            Caption = 'Import Flag';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                Location: Record Location;
            begin
                IF "GXL Import Flag" THEN BEGIN
                    // Removed for now.
                    //TESTFIELD("Agent Number");
                    //TESTFIELD("Port of Loading");

                    IF ("Location Code" <> '') AND
                       (Location.GET("Location Code"))
                    THEN begin
                        Location.CalcFields("GXL Location Type");
                        Location.TESTFIELD("GXL Location Type", Location."GXL Location Type"::"3"); // Location Type = 3-DC
                    end;
                END;
            end;
        }
        field(50353; "GXL EDI Vendor Type"; Option)
        {
            Caption = 'EDI Vendor Type';
            DataClassification = CustomerContent;
            OptionMembers = " ","Point 2 Point",VAN,"3PL Supplier","Point 2 Point Contingency";
        }
        field(50354; "GXL Acc. Lower Cost Purch. Inv"; Boolean)
        {
            Caption = 'Accept Lower Cost Purch. Inv';
            DataClassification = CustomerContent;
        }
        field(50355; "GXL PO File Format"; Option)
        {
            Caption = 'PO File Format';
            DataClassification = CustomerContent;
            OptionMembers = XML,Excel,CSV,"Excel Document","PDF Document";
        }
        field(50356; "GXL Email Type"; Option)
        {
            Caption = 'Email Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Outlook,SMTP;
            OptionCaption = ' ,Outlook,SMTP';
        }
        field(50357; "GXL Email On Posting"; Boolean)
        {
            Caption = 'Email On Posting';
            DataClassification = CustomerContent;

        }
        field(50358; "GXL Email To"; Option)
        {
            Caption = 'Email To';
            DataClassification = CustomerContent;
            OptionMembers = Vendor,Contact,"Use Contact if no Email","Both Contact & Vendor";
        }
        field(50359; "GXL PO Email Address"; Text[80])
        {
            Caption = 'PO Email Address';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(50360; "GXL EDI Supplier No. Source"; Option)
        {
            Caption = 'EDI Supplier No. Source';
            DataClassification = CustomerContent;
            OptionMembers = "Outer Pack GTIN","Outer Pack Reorder No.";
        }
        field(50364; "GXL EDI Email Address"; Text[80])
        {
            Caption = 'EDI Email Address';
            DataClassification = CustomerContent;
        }
        field(50365; "GXL EDI Inbound Directory"; Text[250])
        {
            Caption = 'EDI Inbound Directory';

            trigger OnValidate()
            begin
                IF "GXL EDI Inbound Directory" <> '' THEN
                    GXLUtilities.CheckServerDirectory("GXL EDI Inbound Directory")
            end;
        }
        field(50366; "GXL EDI Outbound Directory"; Text[250])
        {
            Caption = 'EDI Outbound Directory';

            trigger OnValidate()
            begin
                IF "GXL EDI Outbound Directory" <> '' THEN
                    GXLUtilities.CheckServerDirectory("GXL EDI Outbound Directory")
            end;
        }
        field(50367; "GXL EDI Archive Directory"; Text[250])
        {
            Caption = 'EDI Archive Directory';

            trigger OnValidate()
            begin
                IF "GXL EDI Archive Directory" <> '' THEN
                    GXLUtilities.CheckServerDirectory("GXL EDI Archive Directory")
            end;
        }
        field(50368; "GXL EDI Error Directory"; Text[250])
        {
            Caption = 'EDI Error Directory';

            trigger OnValidate()
            begin
                IF "GXL EDI Error Directory" <> '' THEN
                    GXLUtilities.CheckServerDirectory("GXL EDI Error Directory")
            end;
        }
        // TODO International/Domestic PO - Not needed for now
        //ERP-NAV Master Data Management +
        field(50369; "GXL Import Vendor/Agent"; Boolean)
        {
            Caption = 'Import Vendor/Agent';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                Vend: Record Vendor;
            begin
                if (not "GXL Import Vendor/Agent") and ("GXL Import Vendor/Agent" <> xRec."GXL Import Vendor/Agent") then begin
                    Vend.SetRange("GXL Agent Number", "No.");
                    if not Vend.IsEmpty() then
                        FieldError("GXL Import Vendor/Agent", 'cannot be changed to No because of linked vendor(s), ');
                end;
            end;
        }
        field(50370; "GXL Agent Number"; Code[20])
        {
            Caption = 'Agent Number';
            DataClassification = CustomerContent;
            TableRelation = Vendor."No." where("GXL Import Vendor/Agent" = const(true));
        }
        field(50371; "GXL Incoterms Code"; Code[10])
        {
            Caption = 'Incoterms Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL Incoterms";
        }
        field(50072; "GXL Consolidated Freight Shpt"; Boolean)
        {
            Caption = 'Consolidated Freight Shipment';
            DataClassification = CustomerContent;
        }
        field(50173; "GXL Shipment Load Type"; Option)
        {
            Caption = 'Shipment Load Type';
            DataClassification = CustomerContent;
            OptionMembers = " ",Pallet,"Slip-Sheet",Carton;
            OptionCaption = ' ,Pallet,Slip-Sheet,Carton';
        }
        field(50374; "GXL Port of Loading"; Code[10])
        {
            Caption = 'Port of Loading';
            DataClassification = CustomerContent;
            TableRelation = "GXL Port of Loading";
            trigger OnValidate()
            begin
                IF "GXL Port of Loading" = '' THEN
                    TESTFIELD("GXL Import Flag", FALSE);
            end;
        }
        field(50375; "GXL Freight Forwarder Code"; Code[20])
        {
            Caption = 'Freight Forwarder Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL Freight Forwarder";
        }
        //ERP-NAV Master Data Management -
        field(50376; "GXL Post Credit ClaimOnReceipt"; Boolean)  // >> LCB-3 << new field added
        {
            Caption = 'Post Credit Claim On Receipt';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IF "GXL Post Credit ClaimOnReceipt" then
                    TestField("GXL Disable Auto Invoice", TRUE);
            end;
        }
        // >> LCB-203 
        field(50377; "GXL Override OP/OM Calc."; Boolean)
        {
            Caption = 'Override OP/OM Calculation';
            DataClassification = SystemMetadata;
        }
        // << LCB-203 
        // >> 001 07.07.2025 BY HP2-Sprint2-Changes
        field(50378; "PO Address from Company"; Text[30])
        {
            DataClassification = ToBeClassified;
            TableRelation = Company;
        }
        field(50460; "GXL EDI Cancel"; Boolean)
        {
            Caption = 'Do not Send Cancellation to Vendor';
        }
        // << 001 07.07.2025 BY HP2-Sprint2-Changes
        field(500453; "GXL Kentico User ID"; Code[50])
        {
            Caption = 'Kentico User ID';
        }
        modify("Location Code")
        {
            trigger OnAfterValidate()
            var
                Store: Record "LSC Store";
            begin
                if "GXL Import Flag" then begin
                    if ("Location Code" <> xRec."Location Code") AND ("Location Code" <> '') then begin
                        Store.SetCurrentKey("Location Code");
                        Store.SetRange("Location Code", "Location Code");
                        if Store.FindFirst() then
                            Store.TestField("GXL Location Type", store."GXL Location Type"::"3");
                    end;
                end;
            end;
        }

    }
    // >> LCB-203 
    procedure OverrideOPOMCalculation(VendorNoP: Code[20]): Boolean
    var
        VendorL: Record Vendor;
    begin
        if Rec."No." = VendorNoP then
            exit(Rec."GXL Override OP/OM Calc.");

        VendorL.Get(VendorNoP);
        exit(VendorL."GXL Override OP/OM Calc.");
    end;
    // << LCB-203 

    var
        GXLUtilities: Codeunit "GXL Misc. Utilities";

}
