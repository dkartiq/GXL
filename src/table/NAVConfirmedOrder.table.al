table 50141 "GXL NAV Confirmed Order"
{
    /*Change Log
        ERP-NAV Master Data Management: Added fields
    */

    DataClassification = CustomerContent;
    Caption = 'NAV Confirmed Order';

    fields
    {
        field(1; "Document Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Type';
            OptionMembers = "Purchase","Transfer";
            OptionCaption = 'Purchase,Transfer';
        }
        field(2; "Buy-from Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Buy-from Vendor No.';
        }
        field(3; "No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'No.';
        }
        field(4; "Pay-to Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Pay-to Vendor No.';
        }
        field(19; "Order Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Date';
        }
        field(21; "Expected Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Expected Receipt Date';
        }
        field(28; "Location Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Location Code';
        }
        field(32; "Currency Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Currency Code';
        }
        field(35; "Prices Including VAT"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Prices Including GST';
        }
        field(66; "Vendor Order No."; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Order No.';
        }
        field(68; "Vendor Invoice No."; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor Invoice No.';
        }
        field(99; "Document Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Document Date';
        }
        field(50013; "Last EDI Document Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Last EDI Document Status';
            OptionMembers = " ",PO,POX,POR,ASN,INV;
            OptionCaption = ' ,PO,POX,POR,ASN,INV';
        }
        field(50031; "EDI Vendor Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Vendor Type';
            OptionMembers = " ","Point 2 Point",VAN,"3PL Supplier","Point 2 Point Contingency";
            OptionCaption = ' ,Point 2 Point,VAN,3PL Supplier,Point 2 Point Contingency';
        }
        field(50100; "EDI Order in Outer Pack UoM"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Order in Outer Pack UoM';
        }
        field(50200; "Order Type"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Type';
            OptionMembers = Manual,Automatic,JDA;
            OptionCaption = 'Manual,Automatic,JDA';
        }
        field(50203; "Created By User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Created By User ID';
        }
        //ERP-NAV Master Data Management +
        field(50204; "Into Port Arrival Date"; Date)
        {
            Caption = 'Into Port Arrival Date';
            DataClassification = CustomerContent;
        }
        field(50205; "Into DC Delivery Date"; Date)
        {
            Caption = 'Into DC Delivery Date';
            DataClassification = CustomerContent;
        }
        //ERP-NAV Master Data Management -
        field(50207; "Created Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date';
        }
        field(50209; "Created Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Time';
        }
        field(50211; "Manual Document"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Manual Document';
        }
        field(50212; "Source of Supply"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Source of Supply';
            OptionMembers = SD,WH,XD,FT;
            OptionCaption = 'SD,WH,XD,FT';
        }
        //ERP-NAV Master Data Management +
        field(50214; "Transport Type"; Code[30])
        {
            Caption = 'Transport Type';
            TableRelation = "GXL Transport Type";
            DataClassification = CustomerContent;
        }
        field(50215; "Expected Shipment Date"; Date)
        {
            Caption = 'Expected Shipment Date';
            DataClassification = CustomerContent;
        }
        //ERP-NAV Master Data Management -
        field(50221; "EDI Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'EDI Order';
        }
        field(50227; "3PL"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = '3PL';
        }
        field(50228; "3PL File Sent"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = '3PL File Sent';
        }
        field(50229; "3PL File Received"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = '3PL File Received';
        }
        //ERP-NAV Master Data Management +
        field(50231; "Departure Port"; Code[10])
        {
            Caption = 'Departure Port';
            DataClassification = CustomerContent;
        }
        field(50232; "Arrival Port"; Code[10])
        {
            Caption = 'Arrival Port';
            DataClassification = CustomerContent;
        }
        //ERP-NAV Master Data Management -
        field(50236; "Audit Flag"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Audit Flag';
        }
        field(50239; "3PL File Sent Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = '3PL File Sent Date';
        }
        field(50260; "International Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'International Order';
        }
        //ERP-NAV Master Data Management +
        field(50261; "Incoterms Code"; Code[10])
        {
            Caption = 'Incoterms Code';
            DataClassification = CustomerContent;
        }
        field(50262; "Import Agent Number"; Code[20])
        {
            Caption = 'Import Agent Number';
            DataClassification = CustomerContent;
        }
        field(50270; "Container No."; Code[20])
        {
            Caption = 'Container No.';
            DataClassification = CustomerContent;
        }
        field(50271; "Container Type"; Option)
        {
            Caption = 'Container Type';
            DataClassification = CustomerContent;
            OptionMembers = " ","20ft","40ft","40ft HC",LCL;
        }
        field(50272; "Container Carrier"; Text[50])
        {
            Caption = 'Container Carrier';
            DataClassification = CustomerContent;
        }
        field(50273; "Container Vessel"; Text[50])
        {
            Caption = 'Container Vessel';
            DataClassification = CustomerContent;
        }
        field(50274; "Shipment Load Type"; Option)
        {
            Caption = 'Shipment Load Type';
            DataClassification = CustomerContent;
            OptionMembers = ,Pallet,"Slip-Sheet",Carton;
            OptionCaption = ' ,Pallet,Slip-Sheet,Carton';
        }
        field(50281; "Vendor Shipment Date"; Date)
        {
            Caption = 'Vendor Shipment Date';
            DataClassification = CustomerContent;
        }
        field(50283; "Port Arrival Date"; Date)
        {
            Caption = 'Port Arrival Date';
            DataClassification = CustomerContent;
        }
        field(50284; "DC Receipt Date"; Date)
        {
            Caption = 'DC Receipt Date';
            DataClassification = CustomerContent;
        }
        //ERP-NAV Master Data Management -
        field(50302; "Vendor File Exchange"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor File Exchange';
        }
        field(50303; "Vendor File Sent"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor File Sent';
        }
        field(50304; "Vendor File Sent Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Vendor File Sent Date';
        }
        field(50305; "Order Confirmation Received"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Confirmation Received';
        }
        field(50306; "Order Confirmation Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Confirmation Date';
        }
        field(50311; "ASN File Received"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'ASN File Received';
        }
        field(50312; "Supplier File PO No."; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Supplier File PO No.';
        }
        field(50316; "3PL EDI"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = '3PL EDI';
        }
        field(60002; "Transfer-from Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer-from Code';
        }
        field(60011; "Transfer-to Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer-to Code';
        }
        field(60027; "In-Transit Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'In-Transit Code';
        }
        field(60031; "Transfer-from Contact"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer-from Contact';
        }
        field(60033; "Transfer-to Contact"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Transfer-to Contact';
        }
        field(50033; "External Document No."; Code[35])
        {
            DataClassification = CustomerContent;
            Caption = 'External Document No.';
        }
        field(61021; "Delivery Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Delivery Date';
        }
        field(70000; "Replication Counter"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Replication Counter';
        }
        //ERP-328 +
        field(70003; "Version No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Version No.';
        }
        //ERP-328 -
        field(80000; "Process Status"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed Status';
            //ERP-328 + Added option Closed
            OptionMembers = Imported,"Creation Error",Created,Closed;
            OptionCaption = 'Imported,Creation Error,Created,Closed';
            Editable = false;
        }
        field(80001; "Error Message"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = 'Error Message';
            Editable = false;
        }
        field(80002; "Processed Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
            Caption = 'Processed Date Time';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Document Type", "No.", "Version No.")
        {
            //ERP-328 + Added Version No. to key
            Clustered = true;
        }
        key(ReplicationCounter; "Replication Counter")
        { }
    }

    var

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    var
        NAVConfirmedOrdLine: Record "GXL NAV Confirmed Order Line";
    begin
        NAVConfirmedOrdLine.SetRange("Document Type", "Document Type");
        NAVConfirmedOrdLine.SetRange("Document No.", "No.");
        NAVConfirmedOrdLine.SetRange("Version No.", "Version No."); //ERP-328 +
        NAVConfirmedOrdLine.DeleteAll();
    end;

    trigger OnRename()
    begin

    end;

    procedure ResetError()
    var
    begin
        if "Process Status" <> "Process Status"::"Creation Error" then
            Error('Only Status = Creation Error can be reset.');

        Validate("Process Status", "Process Status"::Imported);
    end;
}