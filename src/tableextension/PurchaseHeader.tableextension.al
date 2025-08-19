// 003 BY 10.08.2025 International Purchase order Changes
// 002 05.07.2025 KDU HP2-Sprint2
tableextension 50006 "GXL Purchase Header" extends "Purchase Header"
{
    // 002  28.07.2025  BY  HAR2-406 Bulk Release, Placement, Status update of PORs and TORs
    /*Change Log
        ERP-397 26-10-21 LP: Exflow and Purchase Order Creation
    */
    // 001  05.04.2022  KDU  GX-202201 ERP-356 New procedure "IsTradePO" has been added

    fields
    {
        field(50002; "GXL Created Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Date';
            Editable = false;
        }
        field(50003; "GXL Created Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Created Time';
            Editable = false;
        }
        field(50004; "GXL Created By User ID"; Code[50])
        {
            DataClassification = EndUserIdentifiableInformation;
            Caption = 'Created By User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            Editable = false;
        }
        //ERP-397+
        field(50005; "GXL Auto Invoice Error Msg"; Text[250])
        {
            Caption = 'Auto Invoice Error Message';
            DataClassification = CustomerContent;
            Editable = false;
        }
        //ERP-397-
        field(50250; "GXL Staging Order Quantity"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Staging Total Order Quantity';
            DecimalPlaces = 0 : 5;
            Editable = false;
            //Internal field, to be used for PDA
        }
        field(50251; "GXL Staging Order Value"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Staging Total Order Value';
            AutoFormatType = 1;
            AutoFormatExpression = "Currency Code";
            Editable = false;
            //Internal field, to be used for PDA
        }
        //PS-2046+
        field(50253; "GXL MIM User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'MIM User ID';
            Editable = false;
        }
        //PS-2046-
        //PS-2428+
        field(50254; "GXL P2P Conting ASN Imported"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'P2P Contingency ASN Imported';
            Editable = false;
        }
        //PS-2428-
        //ERP-NAV Master Data Management +
        field(50300; "GXL Departure Port"; Code[10])
        {
            Caption = 'Departure Port';
            DataClassification = CustomerContent;
            TableRelation = "GXL Port of Loading";
            trigger OnValidate()
            begin
                IF "GXL Departure Port" <> xRec."GXL Departure Port" THEN
                    ResendOrderToFreightForwarder(CurrFieldNo);
            end;
        }
        field(50301; "GXL Arrival Port"; Code[10])
        {
            Caption = 'Arrival Port';
            DataClassification = CustomerContent;
            TableRelation = "GXL Port of Loading";
            trigger OnValidate()
            begin
                IF "GXL Arrival Port" <> xRec."GXL Arrival Port" THEN
                    ResendOrderToFreightForwarder(CurrFieldNo);
            end;
        }
        field(50302; "GXL Expected Shipment Date"; Date)
        {
            Caption = 'Expected Shipment Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Document Type" = "Document Type"::Order) and "GXL International Order" then
                    UpdateImportDates(FieldCaption("GXL Expected Shipment Date"));
            end;
        }
        field(50303; "GXL Into Port Arrival Date"; Date)
        {
            Caption = 'Into Port Arrival Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Document Type" = "Document Type"::Order) and "GXL International Order" then
                    UpdateImportDates(FieldCaption("GXL Into Port Arrival Date"));
            end;
        }
        field(50304; "GXL Into DC Delivery Date"; Date)
        {
            Caption = 'Into DC Delivery Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Document Type" = "Document Type"::Order) and "GXL International Order" then
                    UpdateImportDates(FieldCaption("GXL Into DC Delivery Date"));
            end;
        }
        field(50305; "GXL Vendor Shipment Date"; Date)
        {
            Caption = 'Vendor Shipment Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IF ("Document Type" = "Document Type"::Order) AND "GXL International Order" THEN
                    UpdateImportDates(FIELDCAPTION("GXL Vendor Shipment Date"));

                IF "GXL Vendor Shipment Date" <> xRec."GXL Vendor Shipment Date" THEN
                    ResendOrderToFreightForwarder(CurrFieldNo);
            end;
        }
        field(50306; "GXL Port Arrival Date"; Date)
        {
            Caption = 'Port Arrival Date';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                IF ("Document Type" = "Document Type"::Order) AND "GXL International Order" THEN
                    UpdateImportDates(FIELDCAPTION("GXL Port Arrival Date"));

                IF "GXL Port Arrival Date" <> xRec."GXL Port Arrival Date" THEN
                    ResendOrderToFreightForwarder(CurrFieldNo);
            end;
        }
        field(50307; "GXL DC Receipt Date"; Date)
        {
            Caption = 'DC Receipt Date';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if ("Document Type" = "Document Type"::Order) and "GXL International Order" then
                    UpdateImportDates(FieldCaption("GXL DC Receipt Date"));
            end;
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
            trigger OnValidate()
            begin
                IF "GXL Incoterms Code" <> xRec."GXL Incoterms Code" THEN
                    ResendOrderToFreightForwarder(CurrFieldNo);
            end;
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

            trigger OnValidate()
            begin
                if "GXL Shipment Load Type" <> xRec."GXL Shipment Load Type" then
                    ResendOrderToFreightForwarder(CurrFieldNo);
            end;
        }
        field(50320; "GXL Total Ordered Qty. Unit"; Decimal)
        {
            Caption = 'Total Ordered Quantity Unit';
            FieldClass = FlowField;
            CalcFormula = sum("Purchase Line"."Quantity (Base)" where("Document Type" = field("Document Type"), "Document No." = field("No.")));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(50321; "GXL Total Weight"; Decimal)
        {
            Caption = 'Total Weight';
            FieldClass = FlowField;
            CalcFormula = sum("Purchase Line"."GXL Gross Weight" where("Document Type" = field("Document Type"), "Document No." = field("No.")));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        field(50322; "GXL Total Cubage"; Decimal)
        {
            Caption = 'Total Cubage';
            FieldClass = FlowField;
            CalcFormula = sum("Purchase Line"."GXL Cubage" where("Document Type" = field("Document Type"), "Document No." = field("No.")));
            Editable = false;
            DecimalPlaces = 0 : 5;
        }
        //ERP-NAV Master Data Management -

        field(50350; "GXL Order Status"; Option)
        {
            Caption = 'Order Status';
            DataClassification = CustomerContent;
            OptionMembers = New,Created,Placed,Confirmed,"Booked to Ship",Shipped,Arrived,Cancelled,Closed;
            Editable = false;

            ///<Summary>
            ///Order Status
            /// New - order created
            /// Created - order released
            /// Placed - send order to supplier
            /// Confirmed - ASN received from Vendor (for EDI), validate Advance Shipment Notice process, 
            ///           - Or file received from 3PL location
            /// Boook to Ship, Shipped, Arrived are used for International Order
            /// Cancelled - order cancelled manually            
            /// Closed - purchase order posted as received. 
            ///          Only Closed status, order can be invoiced
            ///</Summary>

            //TODO: JDA is not in scope, need to be re-visited when it is back in-scope
            /*
            trigger OnValidate()
            var
                IntegrationSetup: Record "GXL Integration Setup";
            begin
                IntegrationSetup.Get();
                Validate("GXL Last JDA Date Modified", IntegrationSetup.GetJDADateModified());
            end;
            */
        }
        field(50351; "GXL EDI Vendor Type"; Option)
        {
            Caption = 'EDI Vendor Type';
            DataClassification = CustomerContent;
            OptionMembers = " ","Point 2 Point",VAN,"3PL Supplier","Point 2 Point Contingency";
        }
        field(50352; "GXL 3PL EDI"; Boolean)
        {
            Caption = '3PL EDI';
            DataClassification = CustomerContent;
        }
        field(50353; "GXL EDI Order"; Boolean)
        {
            Caption = 'EDI Order';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50354; "GXL Domestic Order"; Boolean)
        {
            Caption = 'Domestic Order';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50355; "GXL 3PL File Receive"; Boolean)
        {
            Caption = '3PL File Receive';
            DataClassification = CustomerContent;
        }
        field(50356; "GXL Vendor File Exchange"; Boolean)
        {
            Caption = 'Vendor File Exchange';
            DataClassification = CustomerContent;
        }
        field(50357; "GXL Vendor File Sent"; Boolean)
        {
            Caption = 'Vendor File Sent';
            DataClassification = CustomerContent;
        }
        field(50358; "GXL Invoice Received"; Boolean)
        {
            Caption = 'Invoice Received';
            DataClassification = CustomerContent;
        }
        field(50359; "GXL 3PL"; Boolean)
        {
            Caption = '3PL';
            DataClassification = CustomerContent;
        }
        field(50360; "GXL 3PL File Sent"; Boolean)
        {
            Caption = '3PL File Sent';
            DataClassification = CustomerContent;
        }
        field(50361; "GXL Source of Supply"; enum "GXL Source of Supply")
        {
            Caption = 'Source of Supply';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                PurchLine: Record "Purchase Line";
                Location: Record Location;
                Store: Record "LSC Store";
            Begin
                IF xRec."GXL Source of Supply" <> "GXL Source of Supply" THEN BEGIN
                    PurchLine.RESET();
                    PurchLine.SETRANGE("Document Type", "Document Type");
                    PurchLine.SETRANGE("Document No.", "No.");
                    PurchLine.SETRANGE(Type, PurchLine.Type::Item);
                    PurchLine.SETFILTER("No.", '<>%1', '');
                    IF not PurchLine.IsEmpty() then
                        ERROR('You must delete the existing purchase lines before you can change Source of Supply.');

                    GetVend("Buy-from Vendor No.");
                    //"Transport Type" := FORMAT("Source of Supply") + Vend."Transport Type";
                    IF "Location Code" <> '' THEN BEGIN
                        Location.GET("Location Code");
                        Location.GetAssociatedStore(Store, false);
                        IF ("GXL Source of Supply" = "GXL Source of Supply"::SD) THEN BEGIN
                            IF Store."GXL Location Type" = Store."GXL Location Type"::"3" THEN
                                TESTFIELD("Location Code", '');
                            Store.TESTFIELD("GXL Location Type", Store."GXL Location Type"::"6")
                        END ELSE BEGIN
                            IF Store."GXL Location Type" = Store."GXL Location Type"::"6" THEN
                                TESTFIELD("Location Code", '');

                            Store.TESTFIELD("GXL Location Type", Store."GXL Location Type"::"3");
                        END;
                    END;
                END;
            End;
        }

        field(50362; "GXL Last JDA Date Modified"; Date)
        {
            Caption = 'Last JDA Date Modified';
            DataClassification = CustomerContent;
        }

        field(50363; "GXL Invoice Received Date"; Date)
        {
            Caption = 'Invoice Received Date';
            DataClassification = CustomerContent;
        }
        field(50364; "GXL Order Conf. Received"; Boolean)
        {
            Caption = 'Order Confirmation Received';
            DataClassification = CustomerContent;
        }
        field(50365; "GXL Order Confirmation Date"; Date)
        {
            Caption = 'Order Confirmation Date';
            DataClassification = CustomerContent;
        }

        field(50367; "GXL International Order"; Boolean)
        {
            Caption = 'International Order';
            DataClassification = CustomerContent;
        }

        field(50368; "GXL Supplier File PO No."; Code[30])
        {
            Caption = 'Supplier File PO No.';
            DataClassification = CustomerContent;
            Editable = false;
            trigger OnValidate()
            begin
                CALCFIELDS("GXL ASN Created");
                TESTFIELD("GXL ASN Created", TRUE);
            end;
        }
        field(50369; "GXL ASN Created"; Boolean)
        {
            Caption = 'ASN Created';
            FieldClass = FlowField;
            CalcFormula = Exist("GXL ASN Header" WHERE("Document Type" = CONST(Purchase), "Purchase Order No." = FIELD("No."), Status = FILTER(Validated ..)));
            Editable = false;
            trigger OnLookup()
            var
                ASNHeader: Record "GXL ASN Header";
            begin
                CALCFIELDS("GXL ASN Created");

                IF NOT "GXL ASN Created" THEN
                    EXIT;

                IF "Document Type" <> "Document Type"::Order THEN
                    EXIT;

                ASNHeader.SETCURRENTKEY("Document Type", "Purchase Order No.");
                ASNHeader.FILTERGROUP(2);
                ASNHeader.SETRANGE("Document Type", ASNHeader."Document Type"::Purchase);
                ASNHeader.SETRANGE("Purchase Order No.", "No.");
                ASNHeader.FILTERGROUP(0);
                PAGE.RUNMODAL(PAGE::"GXL Advance Shipping Notice", ASNHeader);
            end;
        }
        field(50370; "GXL Vendor File Sent Date"; Date)
        {
            Caption = 'Vendor File Sent Date';
            DataClassification = CustomerContent;
        }
        field(50371; "GXL PO Placed Date"; Date)
        {
            Caption = 'PO Placed Date';
            DataClassification = CustomerContent;
        }
        field(50372; "GXL Last EDI Document Status"; Option)
        {
            Caption = 'Last EDI Document Status';
            DataClassification = CustomerContent;
            OptionMembers = " ",PO,POX,POR,ASN,INV;
            OptionCaption = ' ,Purchase Order,Purchase Order Cancellation,Purchase Order Response,Advance Shipping Notice,Invoice';
        }
        field(50374; "GXL 3PL File Sent Date"; Date)
        {
            Caption = '3PL File Sent Date';
            DataClassification = CustomerContent;
        }
        field(50375; "GXL Cancelled via EDI"; Boolean)
        {
            Caption = 'Cancelled via EDI';
            DataClassification = CustomerContent;
        }
        // TODO International/Domestic PO - Not needed for now

        field(50373; "GXL Send to Freight Forwarder"; Boolean)
        {
            Caption = 'Send to Freight Forwarder';
            DataClassification = CustomerContent;
        }
        field(50376; "GXL Freight Forward. File Sent"; Boolean)
        {
            Caption = 'Freight Forwarder File Sent';
            DataClassification = CustomerContent;
        }
        field(50349; "GXL Freight Delivery Mode"; Option)
        {
            Caption = 'Freight Delivery Mode';
            DataClassification = CustomerContent;
            OptionMembers = " ","CFS-CFS","CFS-CY","CY-CY","CY-CFS";
        }
        field(50344; "GXL Received at Origin Date"; Date)
        {
            Caption = 'Received at Origin Date';
            DataClassification = CustomerContent;
        }
        field(50343; "GXL Freight Forwarder File Ack"; Boolean)
        {
            Caption = 'Freight Forwarder File Ack.';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50342; "GXL Freight Forwarder Ack Date"; Date)
        {
            Caption = 'Freight Forwarder Ack. Date';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50341; "GXL Freight Forw. File Sent DT"; DateTime)
        {
            Caption = 'Freight Forwarder File Sent DT';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50377; "GXL Expired Order"; Boolean)
        {
            Caption = 'Expired Order';
            DataClassification = CustomerContent;
        }
        field(50378; "GXL Audit Flag"; Boolean)
        {
            Caption = 'Audit Flag';
            DataClassification = CustomerContent;
        }
        field(50379; "GXL ASN Number"; Code[20])
        {
            Caption = 'ASN Number';
            FieldClass = FlowField;
            CalcFormula = Lookup("GXL ASN Header"."No." WHERE("Document Type" = CONST(Purchase), "Purchase Order No." = FIELD("No."), Status = FILTER(<> Imported & <> "Validation Error")));
            Editable = false;
        }
        field(50380; "GXL Total Order Value"; Decimal)
        {
            Caption = 'Total Order Value';
            FieldClass = FlowField;
            CalcFormula = Sum("Purchase Line"."Amount Including VAT" WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.")));
            Editable = false;
            AutoFormatExpression = "Currency Code";
            AutoFormatType = 1;
        }
        field(50381; "GXL Total Order Qty"; Decimal)
        {
            Caption = 'Total Order Qty';
            FieldClass = FlowField;
            CalcFormula = Sum("Purchase Line"."GXL Carton-Qty" WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.")));
            Editable = false;
        }
        field(50382; "GXL Total Value"; Decimal)
        {
            Caption = 'Total Value';
            FieldClass = FlowField;
            CalcFormula = Sum("Purchase Line"."Line Amount" WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("No.")));
            Editable = false;
        }
        field(50383; "GXL Transport Type"; Code[30])
        {
            Caption = 'Transport Type';
            TableRelation = "GXL Transport Type";
            DataClassification = CustomerContent;
        }
        field(50387; "GXL Freight Forwarder Code"; Code[20])
        {
            Caption = 'Freight Forwarder Code';
            DataClassification = CustomerContent;
            TableRelation = "GXL Freight Forwarder";
            trigger OnValidate()
            begin
                IF "GXL Freight Forwarder Code" <> xRec."GXL Freight Forwarder Code" THEN BEGIN
                    IF "GXL Freight Forwarder Code" <> '' THEN BEGIN
                        TESTFIELD("Document Type", "Document Type"::Order);
                        TESTFIELD("GXL International Order");
                    END;

                    IF "GXL Order Status" > "GXL Order Status"::Placed THEN
                        ERROR(Text100Err, "GXL Order Status");
                    // TODO International/Domestic PO - Not needed for now
                    // >> 002
                    IF "GXL Freight Forwarder Code" <> '' THEN
                        "GXL Send to Freight Forwarder" := TRUE
                    ELSE
                        "GXL Send to Freight Forwarder" := FALSE;
                    // << 002
                END;

                //CALCFIELDS("GXL Freight Forwarder Name");
            end;
        }
        // TODO International/Domestic PO - Not needed for now

        field(50388; "GXL Freight Forwarder File Ver"; Integer)
        {
            Caption = 'Freight Forwarder File Version';
            DataClassification = CustomerContent;
        }

        // 001 07.07.2025 MAY HP2-Sprint2-Changes
        field(50391; "GXL JDA Load ID"; Code[20])
        {
            Caption = 'JDA Load ID';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                PurchLine: Record "Purchase Line";
            begin
                if xRec."GXL JDA Load ID" <> "GXL JDA Load ID" then begin
                    PurchLine.Reset();
                    PurchLine.SetRange("Document Type", "Document Type");
                    PurchLine.SetRange("Document No.", "No.");
                    PurchLine.ModifyAll("GXL JDA Load ID", "GXL JDA Load ID");
                end;
            end;

        }
        // 001 07.07.2025 MAY HP2-Sprint2-Changes
        field(50392; "GXL Receiving Discrepancy"; Boolean)
        {
            Caption = 'Receiving Discrepancy';
            FieldClass = FlowField;
            CalcFormula = Exist("Purchase Line" WHERE("Document Type" = FIELD("Document Type"), "Document No." = FIELD("No."), "GXL Rec. Variance" = FILTER(<> 0)));
            Editable = false;
        }
        field(50393; "GXL EDI Order in Out. Pack UoM"; Boolean)
        {
            Caption = 'EDI Order in Outer Pack UoM';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50394; "GXL ASN File Received"; Boolean)
        {
            Caption = 'ASN File Received';
            DataClassification = CustomerContent;
            Editable = false;

            trigger OnValidate()
            begin
                if "GXL ASN File Received" then begin
                    CalcFields("GXL ASN Created");
                    TestField("GXL ASN Created", true);
                end;
            end;
        }
        field(50395; "GXL EDI Ord. Manually Invoiced"; Boolean)
        {
            Caption = 'EDI Order Manually Invoiced';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(50396; "GXL EDI PO File Log Entry No."; Integer)
        {
            Caption = 'EDI PO File Log Entry No.';
            DataClassification = CustomerContent;
            Editable = false;
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
        field(50399; "GXL No. Emailed"; Integer)
        {
            Caption = 'No. Emailed';
            DataClassification = CustomerContent;
            Editable = false;
        }
        // >> LCB-13
        field(50400; "Send Email to Vendor"; Boolean)
        {
            DataClassification = CustomerContent;
        }
        // << LCB-13
        // >> 002
        field(50401; "GXL Reset Order Status Required"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Reset Order Status Required';
        }
        field(50409; "GXL Changed by User ID"; Code[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Changed by User ID';
            TableRelation = User;
            ValidateTableRelation = false;
        }
        field(50410; "GXL Order Changed Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Changed Date';
        }
        field(50404; "GXL Order Changed Time"; Time)
        {
            DataClassification = CustomerContent;
            Caption = 'Order Changed Time';
        }
        field(50405; "GXL Order Change Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Order Change Reason Code';
            TableRelation = "Reason Code";
        }
        field(50407; "GXL Org Port Departure Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Original Port Departure Date';
            trigger OnValidate()
            begin

                IF ("Document Type" = "Document Type"::Order) AND "GXL International Order" THEN
                    UpdateImportDates(FIELDCAPTION("GXL Org Port Departure Date"));
            end;
        }
        field(50408; "GXL Actual Port Departure Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Actual Port Departure Date';
            trigger OnValidate()
            begin

                IF ("Document Type" = "Document Type"::Order) AND "GXL International Order" THEN
                    UpdateImportDates(FIELDCAPTION("GXL Actual Port Departure Date"));
            end;
        }
        // << 002
        // >> 003
        field(50411; "GXL Freight Forwarder Name"; Text[50])
        {
            Caption = 'Freight Forwarder Name';
            FieldClass = FlowField;
            CalcFormula = lookup("GXL Freight Forwarder".Name where(Code = field("GXL Freight Forwarder Code")));
            Editable = false;
        }
        field(50412; "GXl Original Order Date"; Date)
        {
            Caption = 'Original Order Date';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50413; "GXl Replenishment Contact"; Code[20])
        {
            Caption = 'Replenishment Contact';
            DataClassification = ToBeClassified;
        }
        field(50414; "GXl LSC Received"; Boolean)
        {
            Caption = 'LSC Received';
            DataClassification = ToBeClassified;
            Editable = false;
        }
        field(50415; "GXl 3PL Cancel Request Sent"; Boolean)
        {
            Caption = '3PL Cancel Request Sent';
            DataClassification = ToBeClassified;
        }
        field(50416; "GXl 3PL Cancel Req Receieved"; Boolean)
        {
            Caption = '3PL Cancel Request Receieved';
            DataClassification = ToBeClassified;
        }
        field(50417; "GXl 3PL Cancel Date"; Date)
        {
            Caption = '3PL Cancel Date';
            DataClassification = ToBeClassified;
        }
        field(50418; "GXl 3PL File Updated"; Date)
        {
            Caption = '3PL File Updated';
            DataClassification = ToBeClassified;
        }
        field(50419; "GXl PDA Integer"; Integer)
        {
            Caption = 'PDA Integer';
            DataClassification = ToBeClassified;
        }
        field(50406; "GXL Kentico User ID"; Code[50])
        {
            Caption = 'Kentico User ID';
            FieldClass = FlowField;
            CalcFormula = Lookup(Vendor."GXL Kentico User ID" WHERE("No." = field("Buy-from Vendor No.")));
        }
        field(50420; "GXL Error on Posting"; Text[50])
        {
            Caption = 'Error on Posting';
            DataClassification = ToBeClassified;
        }
        field(50422; "GXL ASN Confirmed"; Boolean)
        {
            Caption = 'ASN Confirmed';
            DataClassification = ToBeClassified;
            trigger OnValidate()
            begin
                CalcFields("GXL ASN Created");
                TestField("GXL ASN Created", true);
            end;
        }
        // >> 001 01.08.2025 MAY HAR2-Sprint2-Changes
        field(50421; "GXL Org Expected Receipt Date"; Date)
        {
            DataClassification = CustomerContent;
            Caption = 'Original Expected Receipt Date';
        }
        // << 001 01.08.2025 MAY HAR2-Sprint2-Changes
        // << 003
        modify("Location Code")
        {
            trigger OnAfterValidate()
            var
                Location: Record Location;
                Store: Record "LSC Store";
                SourceOfSupplyMustBeSDErr: Label '%1 must be %2';
            begin
                // TODO International/Domestic PO - Not needed for now
                if "Location Code" = '' then begin
                    "GXL Arrival Port" := '';
                end else begin
                    if Location.Get("Location Code") then begin
                        if Location.GetAssociatedStore(Store, true) then begin
                            if "GXL International Order" then
                                Store.TestField("GXL Location Type", Store."GXL Location Type"::"3");
                            IF Store."GXL Location Type" = Store."GXL Location Type"::"3" THEN BEGIN
                                // TODO International/Domestic PO - Not needed for now
                                "GXL Arrival Port" := Location."GXL Arrival Port"; // >> 002 <<
                                "GXL 3PL" := (Location."GXL 3PL Warehouse" = TRUE);
                                "GXL 3PL EDI" := (Location."GXL EDI Type" = Location."GXL EDI Type"::"3PL EDI") AND "GXL EDI Order";
                                IF "GXL Source of Supply" = "GXL Source of Supply"::SD THEN
                                    VALIDATE("GXL Source of Supply", "GXL Source of Supply"::WH);
                            END ELSE BEGIN
                                if "GXL Source of Supply" <> "GXL Source of Supply"::SD then
                                    Error(SourceOfSupplyMustBeSDErr, FieldCaption("GXL Source of Supply"), "GXL Source of Supply"::SD);
                            END;
                        end;
                    end;
                    // >> HP2-SPRINT2
                    UpdateLeadTimeFields;
                    IF "GXL International Order" AND ("Location Code" <> xRec."Location Code") THEN
                        UpdateImportDates(FIELDCAPTION("Location Code"));
                    // << HP2-SPRINT2

                end;

            end;
        }
        // >> 002
        modify("Order Date")
        {
            trigger OnBeforeValidate()
            begin
                // >> PSSC.00
                IF "Document Type" = "Document Type"::Order THEN BEGIN
                    IF (xRec."Order Date" <> "Order Date") AND
                       (xRec."Order Date" <> 0D)
                    THEN BEGIN
                        IF CurrFieldNo = FIELDNO("Order Date") THEN
                            GXLArchiveDocument(FIELDCAPTION("Order Date"));
                    END;
                END;

                UpdateLeadTimeFields;
                UpdatePurchLines(FIELDCAPTION("Order Date"));
                IF "Document Type" = "Document Type"::Order THEN
                    //>> MCS1.49
                    IF "GXL International Order" AND ("Order Date" <> xRec."Order Date") THEN
                        UpdateImportDates(FIELDCAPTION("Order Date"));
                //<< MCS1.49
                // << PSSC.00
            end;
        }
        // << 002
    }


    keys
    {
        key(GXL_CreatedDate; "GXL Created Date") { }
        key(GXL_OrderStatus; "GXL Order Status") { }
        key(GXL_EdiPoFileLogEntryNo; "GXL EDI PO File Log Entry No.") { }
        key(GXL_EdiOrd_VendFE_OrdStat; "GXL EDI Order", "GXL Vendor File Exchange", "GXL Order Status") { }
        // TODO International/Domestic PO - Not needed for now
        // >> 002
        key(GXL_IntOrder_OrdSt_STFF; "GXL International Order", "GXL Order Status", "GXL Send to Freight Forwarder") { }
        // key(GXL_IntOrder_OrdSt_STFF; "GXL International Order", "GXL Order Status") { }
        // << 002
    }

    LOCAL procedure GetVend(VendNo: Code[20])
    begin
        IF VendNo <> Vend."No." THEN
            Vend.GET(VendNo);
    end;

    procedure ZeroQuantityReceivedInLines()
    var
        PurchaseLine: Record "Purchase Line";
    begin
        PurchaseLine.SETRANGE("Document Type", "Document Type");
        PurchaseLine.SETRANGE("Document No.", "No.");
        PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
        IF PurchaseLine.FINDSET(TRUE) THEN
            REPEAT
                if PurchaseLine."Qty. to Receive" <> 0 then begin
                    PurchaseLine.SuspendOrderStatusCheck(TRUE);
                    PurchaseLine.VALIDATE("Qty. to Receive", 0);
                    PurchaseLine.SuspendOrderStatusCheck(FALSE);
                    PurchaseLine.MODIFY(TRUE);
                end;
            UNTIL PurchaseLine.NEXT() = 0;
    end;

    procedure ZeroQuantityInLines(SkipStatusCheck: Boolean)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        IF SkipStatusCheck THEN
            PurchaseLine.SuspendOrderStatusCheck(TRUE);

        PurchaseLine.SETRANGE("Document Type", "Document Type");
        PurchaseLine.SETRANGE("Document No.", "No.");
        PurchaseLine.SETRANGE(Type, PurchaseLine.Type::Item);
        IF PurchaseLine.FINDSET(TRUE) THEN
            REPEAT
                IF PurchaseLine.Quantity <> 0 THEN BEGIN
                    PurchaseLine.VALIDATE(Quantity, 0);
                    PurchaseLine.MODIFY(TRUE);
                END;
            UNTIL PurchaseLine.NEXT() = 0;
    end;

    procedure GXL_InitSupplyChain()
    begin
        "GXL Created By User ID" := UserId();
        "GXL Created Date" := WorkDate();
        "GXL Created Time" := Time();
        "GXL Order Status" := "GXL Order Status"::New;
        // TODO International/Domestic PO - Not needed for now
        "GXL JDA Load ID" := "No."; // >> 002 <<
        "GXL Manual PO" := true;
        "GXL Order Type" := "GXL Order Type"::Manual;
    end;

    procedure ResendOrderToFreightForwarder(CurrFldNumber: Integer)
    begin
        // TODO International/Domestic PO - Not needed for now
        // >> 002 << Uncommented this function
        IF (CurrFldNumber = 0) OR ("GXL Send to Freight Forwarder") then
            EXIT;

        IF ("Document Type" = "Document Type"::Order) AND
           ("GXL Freight Forwarder Code" <> '') AND
           ("GXL Freight Forward. File Sent") AND
           (("GXL Order Status" = "GXL Order Status"::Confirmed) OR ("GXL Order Status" = "GXL Order Status"::"Booked to Ship"))
        THEN
            "GXL Send to Freight Forwarder" := TRUE;

    end;

    local procedure UpdateImportDates(CalledFromFieldName: Text[100])
    var
        // >> 002
        LeadTimeMgt: Codeunit "Lead-Time Management";
        LeadTime: Record "GXL Lead Time";
        UseLeadTimes: Boolean;
        StartLeadTimeType: Integer;
        VendorShipmentDate: Date;
        PortArrivalDate: Date;
        DCReceiptDate: Date;
        PortDepDateL: Date;
    // << 002
    begin
        IF NOT ("GXL International Order" AND ("Document Type" = "Document Type"::Order)) THEN
            exit;
        // >> 002
        CASE "GXL Order Status" OF
            "GXL Order Status"::Cancelled:
                EXIT;
            "GXL Order Status"::New,
            "GXL Order Status"::Created:
                BEGIN
                    // Use Original dates
                    VendorShipmentDate := "GXL Expected Shipment Date";
                    PortArrivalDate := "GXL Into Port Arrival Date";
                    DCReceiptDate := "GXL Into DC Delivery Date";
                    PortDepDateL := "GXL Org Port Departure Date";  // >> 007 <<
                END;
            "GXL Order Status"::Placed,
            "GXL Order Status"::Confirmed,
            "GXL Order Status"::"Booked to Ship",
            "GXL Order Status"::Shipped,
            "GXL Order Status"::Arrived,
            "GXL Order Status"::Closed:
                BEGIN
                    // Original dates are frozen
                    VendorShipmentDate := "GXL Vendor Shipment Date";
                    PortArrivalDate := "GXL Port Arrival Date";
                    DCReceiptDate := "GXL DC Receipt Date";
                    PortDepDateL := "GXL Actual Port Departure Date";  // >> 007 <<
                END;
        END;

        UseLeadTimes := TRUE;
        // Which dates to retain/fix and calculate
        CASE CalledFromFieldName OF
            FIELDCAPTION("Order Date"), FIELDCAPTION("Location Code"):
                StartLeadTimeType := LeadTime."Lead Time Type"::Production;
            // >> 007
            FIELDCAPTION("GXL Org Port Departure Date"), FIELDCAPTION("GXL Actual Port Departure Date"):
                StartLeadTimeType := LeadTime."Lead Time Type"::Origin;
            // << 007
            FIELDCAPTION("GXL Expected Shipment Date"), FIELDCAPTION("GXL Vendor Shipment Date"):
                StartLeadTimeType := LeadTime."Lead Time Type"::Shipment;
            FIELDCAPTION("GXL Into Port Arrival Date"), FIELDCAPTION("GXL Port Arrival Date"):
                StartLeadTimeType := LeadTime."Lead Time Type"::Clearance;
            FIELDCAPTION("GXL Into DC Delivery Date"), FIELDCAPTION("GXL DC Receipt Date"):
                UseLeadTimes := FALSE;
            ELSE
                EXIT;
        END;
        IF UseLeadTimes THEN
            CalcPurchOrderImportDates(
              "Buy-from Vendor No.", "Location Code", "Order Date",
              StartLeadTimeType, VendorShipmentDate, PortArrivalDate, DCReceiptDate, PortDepDateL);
        // << 007
        CASE "GXL Order Status" OF
            "GXL Order Status"::New,
            "GXL Order Status"::Created:
                BEGIN
                    "GXL Expected Shipment Date" := VendorShipmentDate;
                    "GXL Org Port Departure Date" := PortDepDateL;
                    "GXL Actual Port Departure Date" := PortDepDateL;
                    "GXL Into Port Arrival Date" := PortArrivalDate;
                    "GXL Into DC Delivery Date" := DCReceiptDate;
                    "GXL Vendor Shipment Date" := "GXL Expected Shipment Date";
                    "GXL Port Arrival Date" := "GXL Into Port Arrival Date";
                    "GXL DC Receipt Date" := "GXL Into DC Delivery Date";
                END;
            "GXL Order Status"::Placed,
            "GXL Order Status"::Confirmed,
            "GXL Order Status"::"Booked to Ship",
            "GXL Order Status"::Shipped,
            "GXL Order Status"::Arrived,
            "GXL Order Status"::Closed:
                BEGIN
                    "GXL Vendor Shipment Date" := VendorShipmentDate;
                    "GXL Port Arrival Date" := PortArrivalDate;
                    "GXL DC Receipt Date" := DCReceiptDate;
                    "GXL Actual Port Departure Date" := PortDepDateL; // >> 007 <<
                END;
        END;

        IF ("GXL DC Receipt Date" <> "Expected Receipt Date") AND ("GXL DC Receipt Date" <> 0D) THEN BEGIN
            VALIDATE("Expected Receipt Date", "GXL DC Receipt Date");
        END;
        //<< MCS1.49
        // << 002
    end;


    //PS-1807
    ///<Summary>
    ///Check if the purchase order can be completed once it has been invoiced even if it has outstanding Quantity 
    ///as mutiple receipts are not allowed
    ///</Summary>
    procedure GXL_PurchaseOrderCanBeCompleted(var PurchHead: Record "Purchase Header") ToBeCompleted: Boolean
    var
        PurchLine: Record "Purchase Line";
    begin
        ToBeCompleted := false;
        PurchLine.Reset();
        PurchLine.SetRange("Document Type", PurchHead."Document Type");
        PurchLine.SetRange("Document No.", PurchHead."No.");
        if PurchLine.IsEmpty() then
            exit;
        PurchLine.SetFilter("Qty. Rcd. Not Invoiced", '<>0');
        if not PurchLine.IsEmpty() then
            exit;

        PurchLine.SetRange("Qty. Rcd. Not Invoiced");
        PurchLine.SetFilter("Quantity Invoiced", '<>0');
        if PurchLine.IsEmpty() then
            exit;

        ToBeCompleted := true;
    end;
    // >> 001
    procedure IsTradePO(DocNo: Code[20]): Boolean
    var
        TradePOQuery: Query "GXL TradePO";
    begin
        TradePOQuery.SetRange(TradePOQuery.Document_No_, DocNo);
        TradePOQuery.Open();
        while TradePOQuery.Read() do
            exit(true);
        exit(false);
    end;
    // << 001
    // >> 002
    procedure GXLArchiveDocument(ChangedFieldCaption: Text)
    var
        ReasonCode: Record "Reason Code";
        ArchiveMgt: Codeunit ArchiveManagement;
    begin

        IF "GXL Reset Order Status Required" AND ("GXL Order Status" = "GXL Order Status"::Cancelled) THEN
            EXIT;
        ReasonCode.RESET;
        ReasonCode.SETRANGE("GXL PO Change Reason Code", TRUE);
        //<<pv00.10
        IF GUIALLOWED THEN BEGIN
            IF PAGE.RUNMODAL(0, ReasonCode) = ACTION::LookupOK THEN BEGIN

                "GXL Changed by User ID" := USERID;
                "GXL Order Changed Date" := WORKDATE;
                "GXL Order Changed Time" := TIME;
                "GXL Order Change Reason Code" := ReasonCode.Code;
                ArchiveMgt.ArchPurchDocumentNoConfirm(xRec);
                "GXL Order Change Reason Code" := '';
            END ELSE
                ERROR(STRSUBSTNO(Text50000, ChangedFieldCaption, ReasonCode.TABLECAPTION));
        END;
    end;

    procedure UpdateLeadTimeFields()
    var
        StartingDate: Date;
        LeadTimeMgt: Codeunit "Lead-Time Management";
        CalendarMgmt: Codeunit "Calendar Management";
        CustomCalendarChange: Array[2] of Record "Customized Calendar Change";
    begin
        IF "Document Type" IN
             ["Document Type"::Quote, "Document Type"::Order]
        THEN BEGIN
            EVALUATE("Lead Time Calculation",
              PurchaseLeadTime2(
                "Location Code", "Buy-from Vendor No.", "Order Date"));

            IF "Order Date" <> 0D THEN BEGIN
                SetHideValidationDialog(TRUE);
                CustomCalendarChange[1].SetSource(CalChange."Source Type"::Vendor, "Buy-from Vendor No.", '', '');
                CustomCalendarChange[2].SetSource(CalChange."Source Type"::Location, "Location Code", '', '');

                "Expected Receipt Date" :=
                   CalendarMgmt.CalcDateBOC(AdjustDateFormula("Lead Time Calculation"), "Order Date",
            CustomCalendarChange, TRUE);
                IF "GXL Org Expected Receipt Date" = 0D THEN
                    "GXl Org Expected Receipt Date" := "Expected Receipt Date";
                UpdatePurchLines(FIELDCAPTION("Expected Receipt Date"));
            END;
        END;
    end;

    procedure PurchaseLeadTime2(LocationCode: Code[10]; VendorNo: Code[20]; OrderDate: Date): Code[20]
    var
        ItemVend: Record "Item Vendor";
        LeadTimeSetup: Record "GXL Lead Time";
        rsVendor: Record Vendor;
        rsLoc: Record Location;
        ToType: Option Supplier,Store,WH,Port;
        LeadTimeManagement: Codeunit "Lead-Time Management";
        OrderReceiptDate: Date;
    begin

        // Returns the leadtime in a date formula
        IF LocationCode = '' THEN EXIT('0D');
        rsVendor.GET(VendorNo);
        rsLoc.GET(LocationCode);
        CLEAR(LeadTimeManagement);

        ExpectedReceiptDate := OrderDate;
        if not CheckDirectRoute(VendorNo, LocationCode, OrderDate, OrderReceiptDate) then
            ExpectedReceiptDate := OrderDate;
        OrderReceiptDate := ExpectedReceiptDate;

        IF OrderReceiptDate >= OrderDate THEN
            EXIT(FORMAT(OrderReceiptDate - OrderDate) + 'D')
        ELSE
            EXIT('0D');
    end;

    procedure CheckDirectRoute(Suppliercode: Code[20]; DestinationCode: Code[10]; OrderDate: Date; VAR OrderReceiptDate: Date): Boolean
    var
        Vend: Record Vendor;
    begin
        ExpectedReceiptDate := OrderDate;
        _recLT.RESET;
        _recLT.SETRANGE("From Type", _recLT."From Type"::Supplier);
        _recLT.SETRANGE("From Code", Suppliercode);
        _recLT.SETRANGE("To Type", _recLT."To Type"::Store);
        _recLT.SETRANGE("To Code", DestinationCode);

        IF _recLT.FINDSET THEN BEGIN
            REPEAT
                ExpectedReceiptDate := CALCDATE(_recLT."Lead Time", ExpectedReceiptDate);
            UNTIL _recLT.NEXT = 0;

            EXIT(TRUE);
        END;

        _recLT.RESET;
        _recLT.SETRANGE("From Type", _recLT."From Type"::Supplier);
        _recLT.SETRANGE("From Code", Suppliercode);
        _recLT.SETRANGE("To Type", _recLT."To Type"::WH);
        _recLT.SETRANGE("To Code", DestinationCode);

        IF _recLT.FINDSET THEN BEGIN
            REPEAT
                ExpectedReceiptDate := CALCDATE(_recLT."Lead Time", ExpectedReceiptDate);
            UNTIL _recLT.NEXT = 0;
            EXIT(TRUE);
        END;

        Vend.RESET;
        IF Vend.GET(Suppliercode) THEN
            IF Vend."GXL Import Flag" = FALSE THEN
                EXIT(TRUE);
        EXIT(FALSE);
    end;

    procedure AdjustDateFormula(DateFormulatoAdjust: DateFormula): Text[30]
    begin
        IF FORMAT(DateFormulatoAdjust) <> '' THEN
            EXIT(FORMAT(DateFormulatoAdjust));
        EVALUATE(DateFormulatoAdjust, '<0D>');
        EXIT(FORMAT(DateFormulatoAdjust));
    end;
    // >> HP2-SPRINT2
    procedure PurchLinesExist2(): Boolean
    begin
        PurchLine.Reset();
        PurchLine.ReadIsolation := IsolationLevel::ReadUncommitted;
        PurchLine.SetRange("Document Type", "Document Type");
        PurchLine.SetRange("Document No.", "No.");
        exit(PurchLine.FindFirst());
    end;
    // << HP2-SPRINT2
    procedure UpdatePurchLines(ChangedFieldName: Text[100])
    var
        UpdateConfirmed: Boolean;
    begin
        // >> HP2-SPRINT2
        // IF NOT PurchLinesExist THEN
        IF NOT PurchLinesExist2 THEN
            // << HP2-SPRINT2
            EXIT;

        IF NOT GUIALLOWED THEN
            UpdateConfirmed := TRUE
        ELSE
            CASE ChangedFieldName OF
                FIELDCAPTION("Expected Receipt Date"):
                    UpdateConfirmed := TRUE;

                FIELDCAPTION("Requested Receipt Date"):
                    BEGIN
                        UpdateConfirmed :=
                          CONFIRM(
                            STRSUBSTNO(
                              Text032 +
                              Text033, ChangedFieldName));
                        IF UpdateConfirmed THEN
                            ConfirmResvDateConflict;
                    END;
                FIELDCAPTION("Promised Receipt Date"):
                    BEGIN
                        UpdateConfirmed :=
                          CONFIRM(
                            STRSUBSTNO(
                              Text032 +
                              Text033, ChangedFieldName));
                        IF UpdateConfirmed THEN
                            ConfirmResvDateConflict;
                    END;
                FIELDCAPTION("Lead Time Calculation"):
                    BEGIN
                        UpdateConfirmed :=
                          CONFIRM(
                            STRSUBSTNO(
                              Text032 +
                              Text033, ChangedFieldName));
                        IF UpdateConfirmed THEN
                            ConfirmResvDateConflict;
                    END;
                FIELDCAPTION("Inbound Whse. Handling Time"):
                    BEGIN
                        UpdateConfirmed :=
                          CONFIRM(
                            STRSUBSTNO(
                              Text032 +
                              Text033, ChangedFieldName));
                        IF UpdateConfirmed THEN
                            ConfirmResvDateConflict;
                    END;
                FIELDCAPTION("Prepayment %"):
                    UpdateConfirmed :=
                      CONFIRM(
                        STRSUBSTNO(
                          Text032 +
                          Text033, ChangedFieldName));

                FIELDCAPTION("Location Code"):
                    UpdateConfirmed := TRUE;

                FIELDCAPTION("Order Date"):
                    UpdateConfirmed := TRUE;

            END;

        PurchLine.LOCKTABLE;
        MODIFY;

        REPEAT
            xPurchLine := PurchLine;
            PurchLine.SuspendStatusCheck(TRUE);
            CASE ChangedFieldName OF
                FIELDCAPTION("Expected Receipt Date"):
                    IF UpdateConfirmed AND (PurchLine."No." <> '') THEN BEGIN
                        // PurchLine.UpdateJDADate; //TODO: When Codeunit JDA MGmt avaiable
                        PurchLine.VALIDATE("Expected Receipt Date", "Expected Receipt Date");
                    END;
                FIELDCAPTION("Order Date"):
                    IF UpdateConfirmed AND (PurchLine."No." <> '') THEN
                        PurchLine.VALIDATE("Order Date", "Order Date");
                FIELDCAPTION("Currency Factor"):
                    IF PurchLine.Type <> PurchLine.Type::" " THEN
                        PurchLine.VALIDATE("Direct Unit Cost");
                FIELDCAPTION("Transaction Type"):
                    PurchLine.VALIDATE("Transaction Type", "Transaction Type");
                FIELDCAPTION("Transport Method"):
                    PurchLine.VALIDATE("Transport Method", "Transport Method");
                FIELDCAPTION("Entry Point"):
                    PurchLine.VALIDATE("Entry Point", "Entry Point");
                FIELDCAPTION(Area):
                    PurchLine.VALIDATE(Area, Area);
                FIELDCAPTION("Transaction Specification"):
                    PurchLine.VALIDATE("Transaction Specification", "Transaction Specification");
                FIELDCAPTION("Requested Receipt Date"):
                    IF UpdateConfirmed AND (PurchLine."No." <> '') THEN
                        PurchLine.VALIDATE("Requested Receipt Date", "Requested Receipt Date");
                FIELDCAPTION("Prepayment %"):
                    IF UpdateConfirmed AND (PurchLine."No." <> '') THEN
                        PurchLine.VALIDATE("Prepayment %", "Prepayment %");
                FIELDCAPTION("Promised Receipt Date"):
                    IF UpdateConfirmed AND (PurchLine."No." <> '') THEN
                        PurchLine.VALIDATE("Promised Receipt Date", "Promised Receipt Date");
                FIELDCAPTION("Lead Time Calculation"):
                    IF UpdateConfirmed AND (PurchLine."No." <> '') THEN
                        PurchLine.VALIDATE("Lead Time Calculation", "Lead Time Calculation");
                FIELDCAPTION("Inbound Whse. Handling Time"):
                    IF UpdateConfirmed AND (PurchLine."No." <> '') THEN
                        PurchLine.VALIDATE("Inbound Whse. Handling Time", "Inbound Whse. Handling Time");
                FIELDCAPTION("Location Code"):
                    IF UpdateConfirmed AND (PurchLine."No." <> '') THEN
                        PurchLine.VALIDATE("Location Code", "Location Code");

            END;
            PurchLine.MODIFY(TRUE);
            ReservePurchLine.VerifyChange(PurchLine, xPurchLine);
        UNTIL PurchLine.NEXT = 0;
    end;

    procedure ConfirmResvDateConflict()
    var
        ResvEngMgt: Codeunit "Reservation Engine Mgt.";
    begin
        IF ResvEngMgt.ResvExistsForPurchHeader(Rec) THEN
            IF NOT CONFIRM(Text050 + Text011, FALSE) THEN
                ERROR('');
    end;

    procedure CalcPurchOrderImportDates(VendorNo: Code[20]; LocationCode: Code[10]; OrderDate: Date; StartLeadTimeType: Integer; VAR VendorShipmentDate: Date; VAR PortArrivalDate: Date; VAR DCReceiptDate: Date; VAR PortDepDateP: Date)
    var
        LeadTime: Record "GXL Lead Time";
    begin


        WITH LeadTime DO BEGIN
            // >> 001
            IF NOT (StartLeadTimeType IN ["Lead Time Type"::Clearance .. "Lead Time Type"::Origin]) THEN
                // << 001
                EXIT;

            IF (StartLeadTimeType = "Lead Time Type"::Production) THEN BEGIN
                IF (OrderDate <> 0D) THEN BEGIN
                    RESET;

                    IF FindLeadTimeToUpdatePO(LeadTime, VendorNo, LocationCode, "Lead Time Type"::Production) THEN
                        // << 001
                        VendorShipmentDate := CALCDATE("Lead Time", OrderDate)
                    ELSE
                        VendorShipmentDate := 0D;
                    // >> 001
                    RESET;
                    IF FindLeadTimeToUpdatePO(LeadTime, VendorNo, LocationCode, "Lead Time Type"::Origin) THEN
                        PortDepDateP := CALCDATE("Lead Time", VendorShipmentDate)
                    ELSE
                        PortDepDateP := 0D;
                    // << 001
                END ELSE
                    VendorShipmentDate := 0D;
            END;

            IF (StartLeadTimeType IN ["Lead Time Type"::Production, "Lead Time Type"::Shipment]) THEN BEGIN
                // >> 001
                RESET;
                IF FindLeadTimeToUpdatePO(LeadTime, VendorNo, LocationCode, "Lead Time Type"::Origin) THEN
                    PortDepDateP := CALCDATE("Lead Time", VendorShipmentDate)
                ELSE
                    PortDepDateP := 0D;
                // << 001


                IF (PortDepDateP <> 0D) THEN BEGIN
                    RESET;
                    IF FindLeadTimeToUpdatePO(LeadTime, VendorNo, LocationCode, "Lead Time Type"::Shipment) THEN
                        PortArrivalDate := CALCDATE("Lead Time", PortDepDateP)
                    ELSE
                        PortArrivalDate := 0D;
                END ELSE
                    PortArrivalDate := 0D;
            END;

            // >> 001
            IF (StartLeadTimeType = "Lead Time Type"::Origin) THEN BEGIN
                IF (PortDepDateP <> 0D) THEN BEGIN
                    RESET;
                    IF FindLeadTimeToUpdatePO(LeadTime, VendorNo, LocationCode, "Lead Time Type"::Shipment) THEN
                        PortArrivalDate := CALCDATE("Lead Time", PortDepDateP)
                    ELSE
                        PortArrivalDate := 0D;
                END ELSE
                    PortArrivalDate := 0D;

            END;
            // << 001

            IF (PortArrivalDate <> 0D) THEN BEGIN
                RESET;
                IF FindLeadTimeToUpdatePO(LeadTime, VendorNo, LocationCode, "Lead Time Type"::Clearance) THEN
                    DCReceiptDate := CALCDATE("Lead Time", PortArrivalDate)
                ELSE
                    DCReceiptDate := 0D;
            END ELSE
                DCReceiptDate := 0D;
        END;
        //<< MCS1.49
    end;

    procedure FindLeadTimeToUpdatePO(VAR LeadTimeP: Record "GXL Lead Time"; VendorNoP: Code[20]; LocationCodeP: Code[20]; LeadTimeTypeP: Option Regular,Clearance,Shipment,Production,Origin): Boolean
    begin
        LeadTimeP.RESET;
        LeadTimeP.SETRANGE("From Type", LeadTimeP."From Type"::Supplier);
        LeadTimeP.SETRANGE("From Code", VendorNoP);
        LeadTimeP.SETRANGE("To Code", LocationCodeP);
        LeadTimeP.SETRANGE("Lead Time Type", LeadTimeTypeP);
        EXIT(LeadTimeP.FINDFIRST AND (FORMAT(LeadTimeP."Lead Time") <> ''));
    end;

    internal procedure PerformOrderStatusChange(var PurchHdr: Record "Purchase Header")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        POStatusMgmt: Codeunit "GXL PO Status Mgmt";
        CurrentOrderStatus: Enum "GXL PO Status";
        ToOrderStatus: Enum "GXL PO Status";
        SingleInstance: Codeunit "GXL Single Instance";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin

        CurrentOrderStatus := POStatusMgmt.GetCurrentOrderStatusInEnum(Rec);
        ToOrderStatus := POStatusMgmt.GetNewStatus(CurrentOrderStatus);
        SingleInstance.SetPOStatus_To(ToOrderStatus);

        NoOfSelected := PurchHdr.Count();
        PurchHdr.SetFilter(Status, '<>%1', ToOrderStatus);
        NoOfSkipped := NoOfSelected - PurchHdr.Count;
        BatchProcessingMgt.BatchProcess(PurchHdr, Codeunit::"GXL PO Status Mgmt", "Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
    end;

    internal procedure PerformsManualRelease(var PurchaseHeader: Record "Purchase Header")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin
        NoOfSelected := PurchaseHeader.Count();
        PurchaseHeader.SetFilter(Status, '<>%1', PurchaseHeader.Status::Released);
        NoOfSkipped := NoOfSelected - PurchaseHeader.Count;
        BatchProcessingMgt.BatchProcess(PurchaseHeader, Codeunit::"Purchase Manual Release", "Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
    end;

    internal procedure PerformsManualReopen(var PurchaseHeader: Record "Purchase Header")
    var
        BatchProcessingMgt: Codeunit "Batch Processing Mgt.";
        NoOfSelected: Integer;
        NoOfSkipped: Integer;
    begin
        NoOfSelected := PurchaseHeader.Count();
        PurchaseHeader.SetFilter(Status, '<>%1', PurchaseHeader.Status::Open);
        NoOfSkipped := NoOfSelected - PurchaseHeader.Count;
        BatchProcessingMgt.BatchProcess(PurchaseHeader, Codeunit::"Purchase Manual Reopen", "Error Handling Options"::"Show Error", NoOfSelected, NoOfSkipped);
    end;
    // << 002
    var
        Vend: Record Vendor;
        _recLT: Record "GXL Lead Time";
        CalChange: Record "Customized Calendar Change";
        xPurchLine: Record "Purchase Line";
        ReservePurchLine: Codeunit "Purch. Line-Reserve";
        SourceOfSupply: Option SD,WH,XD,FT;
        ExpectedReceiptDate: Date;
        Text100Err: Label 'You cannot change Freight Forwarder because Order Status is %1.';
        Text50000: Label 'You cannot make changes to %1 without choosing a %2.';
        Text032: Label 'You have modified %1.\\';
        Text033: Label 'Do you want to update the lines?';
        Text011: Label 'Do you want to continue?';
        Text050: Label 'Reservations exist for this order. These reservations will be canceled if a date conflict is caused by this change.\\';
    // << 002
}