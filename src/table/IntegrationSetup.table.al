table 50000 "GXL Integration Setup"
{
    /*Change Log
        NAV9-11 Integrations: New fields to turn synch to NAV13 on/off
        WRP-1013: 03-02-21
            Comestri Send to Parameters can be different b/w SOH and Product full feed
    */

    Caption = 'GXL Integration Setup';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary key"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Primary Key';
        }
        //Magento
        field(50100; "Magento POS-Trans. Posting"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Magento POS-Transaction Posting';
            OptionMembers = "Disabled","Manual","Job Queue";
            OptionCaption = 'Disabled,Manual,Job Queue';
        }
        field(50101; "Magento POS-Trans. Post. Delay"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Magento POS-Trans. Posting Delay (Sec)';
            MinValue = 0;
            InitValue = 10;
        }
        field(50102; "Magento Income/Expense Acc."; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Magento Income/Expense Acc.';
            TableRelation = "LSC Income/Expense Account"."No.";
            ValidateTableRelation = false;
        }
        field(50103; "Magento Sales Type"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Default Magento Sales Type';
            TableRelation = "LSC Sales Type";
        }
        //NAV13
        //ERP-333 +
        field(50104; "Magento Recent Process Days"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Magento Recent Process Days';
        }
        //ERP-333 -
        //NAV9-11+
        field(50140; "Sync Cancel NAV Purchase Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Sync to Cancel NAV Purchase Order';
        }
        field(50141; "Sync Cancel NAV Transfer Order"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Sync to Cancel NAV Transfer Order';
        }
        //NAV9-11-
        //ERP-NAV Master Data Management +
        field(50145; "Sync NAV-13 Inactive"; Boolean)
        {
            Caption = 'Sync NAV-13 Inactive';
            DataClassification = CustomerContent;
        }
        //ERP-NAV Master Data Management -
        //Episys/ECS
        field(50150; "ECS Store Integration"; enum "GXL ECS Integration Option")
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Store Integration';

            trigger OnValidate()
            begin
                if "ECS Store Integration" = "ECS Store Integration"::Disable then begin
                    "ECS Store Data Template" := '';
                    "ECS Cluster Data Template" := '';
                    "ECS StoreCluster Data Template" := '';
                end;
            end;
        }
        field(50151; "ECS Prod Hierarchy Integration"; Enum "GXL ECS Integration Option")
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Product Hierarchy Integration';
        }
        field(50152; "ECS Item Content Integration"; Enum "GXL ECS Integration Option")
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Item Content Integration';

            trigger OnValidate()
            begin
                if "ECS Item Content Integration" = "ECS Item Content Integration"::Disable then
                    "ECS Item Content Data Template" := '';
            end;
        }
        field(50153; "ECS Promotion Integration"; Enum "GXL ECS Integration Option")
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Promotion Integration';
        }
        field(50154; "ECS Sales Price Integration"; Enum "GXL ECS Integration Option")
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Sales Price Integration';

            trigger OnValidate()
            begin
                if "ECS Sales Price Integration" = "ECS Sales Price Integration"::Disable then
                    "ECS Sales Price Data Template" := '';
            end;
        }
        field(50155; "ECS Stock Ranging Integration"; Enum "GXL ECS Integration Option")
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Stock Ranging Integration';

            trigger OnValidate()
            begin
                if "ECS Stock Ranging Integration" = "ECS Stock Ranging Integration"::Disable then
                    "ECS Stock Range Data Template" := '';
            end;
        }
        field(50160; "ECS Store Data Template"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Store Data Template';
            TableRelation = "GXL ECS Data Template Header";
        }
        field(50161; "ECS Cluster Data Template"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Cluster Data Template';
            TableRelation = "GXL ECS Data Template Header";
        }
        field(50162; "ECS StoreCluster Data Template"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Store Cluster Data Template';
            TableRelation = "GXL ECS Data Template Header";
        }
        field(50163; "ECS Item Content Data Template"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Item Content Data Template';
            TableRelation = "GXL ECS Data Template Header";
        }
        field(50164; "ECS Sales Price Data Template"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Sales Price Data Template';
            TableRelation = "GXL ECS Data Template Header";
        }
        field(50165; "ECS Stock Range Data Template"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ECS Stock Range Data Template';
            TableRelation = "GXL ECS Data Template Header";
        }
        //Bloyal
        field(50170; "Bloyal Access Token"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Access Token';
        }
        field(50171; "Bloyal Sales Payment Endpoint"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Sales & Payment Endpoint';
        }
        field(50172; "Bloyal SOH Endpoint"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal SOH Endpoint';
        }
        field(50173; "Bloyal Product Endpoint"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Product Endpoint';
        }
        field(50175; "Bloyal Sales Pmt Max Records"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Sales & Payment Web Service Max. Records';
        }
        field(50176; "Bloyal SOH Max Records"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal SOH Web Service Max. Records';
        }
        field(50177; "Bloyal Product Max Records"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Product Web Service Max. Records';
        }
        field(50178; "Bloyal Hierarchy Max Records"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Hierarchy Web Service Max. Records';
        }
        field(50179; "Bloyal Max. of Try"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Max. of Try';
        }
        field(50180; "Bloyal Notif. Sender E-Mail"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Notification Sender E-Mail';
            ExtendedDatatype = EMail;
        }
        field(50181; "Bloyal Notif. Recipient"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Notification Recipient';
            ExtendedDatatype = EMail;
        }
        field(50182; "Bloyal Sales Payment Template"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Sales & Payment Template';
            TableRelation = "GXL ECS Data Template Header";
        }
        field(50183; "Bloyal Product Template"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Product Template';
            TableRelation = "GXL ECS Data Template Header";
        }
        field(50184; "Bloyal Division Endpoint"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Division Endpoint';
        }
        field(50185; "Bloyal Item Category Endpoint"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Item Category Endpoint';
        }
        field(50186; "Bloyal Retail Product Endpoint"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'Bloyal Retail Product Group Endpoint';
        }

        //SOH
        field(50200; "SOH Batch No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
            Caption = 'Batch No. Series';
        }
        field(50202; "DB server"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'DB Server';
        }
        field(50203; "DB Name"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'DB Name';
        }
        field(50204; "User name"; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'User Name';
        }
        field(50205; Password; Text[80])
        {
            DataClassification = CustomerContent;
            Caption = 'Password';
        }
        field(50206; "SOH Clear Data After"; DateFormula)
        {
            DataClassification = CustomerContent;
            Caption = 'Clear Data After';
        }
        //PDA
        field(50250; "Recent Order Days"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Recent Order Days';
        }
        field(50251; "Post / Send Claims"; Enum "GXL Post/Send Claims")
        {
            Caption = 'Post / Send Claims';
            DataClassification = CustomerContent;
        }
        field(50252; "PDA Over Receiving Reason Code"; Code[10])
        {
            Caption = 'PDA Over Receiving Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(50253; "Last RMS ID"; Integer)
        {
            Caption = 'Last RMS ID';
            DataClassification = CustomerContent;
        }
        //PS-2523 VET Clinic transfer order +
        field(50254; "VET Transfer Order Nos."; Code[20])
        {
            Caption = 'VET Transfer Order Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50255; "VET Customer No."; Code[20])
        {
            Caption = 'VET Customer No.';
            DataClassification = CustomerContent;
            TableRelation = Customer;
        }
        field(50256; "VET Intercompany G/L Account"; Code[20])
        {
            Caption = 'VET Intercompany G/L Account';
            DataClassification = CustomerContent;
            TableRelation = "G/L Account";
        }
        //PS-2523 VET Clinic transfer order -
        //WMS/3PL
        field(50343; "P2P Contingency ASN Nos."; Code[20])
        {
            Caption = 'P2P Contingency ASN Nos.';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50344; "EDI Credit Memo No. Series"; Code[20])
        {
            Caption = 'EDI Credit Memo No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50345; "Invoice On Hold Duration"; Integer)
        {
            Caption = 'Invoice On Hold Duration';
            DataClassification = CustomerContent;
        }
        field(50346; "Default Error Dir. Non-EDI"; Text[150])
        {
            Caption = 'Default Error Dir. Non-EDI';
            DataClassification = CustomerContent;
        }
        field(50347; "Default Archive Dir. Non-EDI"; Text[150])
        {
            Caption = 'Default Archive Dir. Non-EDI';
            DataClassification = CustomerContent;
        }
        field(50348; "Default Outbound Dir. Non-EDI"; Text[150])
        {
            Caption = 'Default Outbound Dir. Non-EDI';
            DataClassification = CustomerContent;
        }
        field(50349; "Default Inbound Dir. Non-EDI"; Text[150])
        {
            Caption = 'Default Inbound Dir. Non-EDI';
            DataClassification = CustomerContent;
        }
        field(50350; "3PL Archive Directory"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = '3PL Archive Directory';
        }
        field(50351; "3PL Error Directory"; Text[250])
        {
            DataClassification = CustomerContent;
            Caption = '3PL Error Directory';
        }
        field(50352; "ASN File Name Prefix"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'ASN File Name Prefix';
        }
        field(50353; "ASN Variance Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'ASN Variance Reason Code';
            TableRelation = "Reason Code";
        }
        field(50354; "Intl. Ship. Advice No. Series"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'Intl. Ship. Advice No. Series';
            TableRelation = "No. Series".Code;
        }
        field(50355; "Suffix for TO SOH Increase"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Suffix for TO SOH Increase';
        }
        field(50356; "Suffix for TO SOH Decrease"; Text[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Suffix for TO SOH Decrease';
        }
        field(50357; "3PL Purch. St. Adj Reason Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = '3PL Purch. St. Adj Reason Code';
            TableRelation = "Reason Code";
        }
        field(50358; "Default STK Adj. Reason Code"; Code[10])
        {
            Caption = 'Default STK Adj. Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(50359; "Store Dimension Code"; Code[20])
        {
            Caption = 'Store Dimension Code';
            DataClassification = CustomerContent;
            TableRelation = Dimension;
        }
        field(50360; "Time Format"; Option)
        {
            Caption = 'Time Format';
            DataClassification = CustomerContent;
            OptionMembers = " ",HHMM,HHMMSS;
        }
        field(50361; "Date Format"; Option)
        {
            Caption = 'Date Format';
            DataClassification = CustomerContent;
            OptionMembers = " ",DDMMYYYY,DDMMYY,YYYYMMDD,YYMMDD;
        }
        field(50362; "Default WH Stk Adj No. Series"; Code[20])
        {
            Caption = 'Default WH Stk Adj No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50364; "Vendor Archive Directory"; Text[250])
        {
            Caption = 'Vendor Archive Directory';
            DataClassification = CustomerContent;
        }
        field(50365; "Vendor Error Directory"; Text[250])
        {
            Caption = 'Vendor Error Directory';
            DataClassification = CustomerContent;
        }
        field(50366; "Default Error Dir. P2P"; Text[250])
        {
            Caption = 'Default Error Dir. P2P';
            DataClassification = CustomerContent;
        }
        field(50367; "PO XMLPort ID"; Integer)
        {
            Caption = 'PO File Format';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" WHERE("Object Type" = CONST(XMLport));
        }
        field(50368; "Replenishment Team Email"; Text[80])
        {
            Caption = 'Replenishment Team Email';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
        }
        field(50369; "Allowable Tolerance %"; Decimal)
        {
            Caption = 'Allowable Tolerance %';
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
        }
        field(50370; "Audits per Month"; Integer)
        {
            Caption = 'Audits per Month';
            DataClassification = CustomerContent;
        }
        field(50371; "Suffix for EDI Document"; Code[5])
        {
            Caption = 'Suffix for EDI Document';
            DataClassification = CustomerContent;
        }
        field(50372; "NAV EDI Document No. Format"; Text[30])
        {
            Caption = 'NAV EDI Document No. Format';
            DataClassification = CustomerContent;
        }
        field(50373; "EDI Return Order No. Series"; Code[20])
        {
            Caption = 'EDI Return Order No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50374; "EDI Return Order Vendor No."; Code[20])
        {
            Caption = 'EDI Return Order Vendor No.';
            DataClassification = CustomerContent;
            TableRelation = Vendor;
        }
        field(50375; "EDI Ret. Order Bal. Acc. Type"; Option)
        {
            Caption = 'EDI Ret. Order Bal. Acc. Type';
            DataClassification = CustomerContent;
            OptionMembers = "G/L Account","Bank Account";
        }
        field(50376; "EDI Ret. Order Bal. Acc. No."; Code[20])
        {
            Caption = 'EDI Ret. Order Bal. Acc. No.';
            DataClassification = CustomerContent;
            TableRelation = IF ("EDI Ret. Order Bal. Acc. Type" = CONST("G/L Account")) "G/L Account" ELSE
            IF ("EDI Ret. Order Bal. Acc. Type" = CONST("Bank Account")) "Bank Account";
        }
        field(50377; "EDI Return Order Reason Code"; Code[10])
        {
            Caption = 'EDI Return Order Reason Code';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(50378; "Log Age for Deletion"; DateFormula)
        {
            Caption = 'Log Age for Deletion';
            DataClassification = CustomerContent;
        }
        field(50379; "PO File Name Prefix"; Text[30])
        {
            Caption = 'PO File Name Prefix';
            DataClassification = CustomerContent;
        }
        field(50380; "POX File Name Prefix"; Text[30])
        {
            Caption = 'POX File Name Prefix';
            DataClassification = CustomerContent;
        }
        field(50381; "EDI POR No. Series"; Code[20])
        {
            Caption = 'EDI POR No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50382; "EDI ASN No. Series"; Code[20])
        {
            Caption = 'EDI ASN No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50383; "EDI Invoice No. Series"; Code[20])
        {
            Caption = 'EDI Invoice No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50384; "Intl. PO Ack. No. Series"; Code[20])
        {
            Caption = 'Intl. PO Ack. No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50385; "POR File Name Prefix"; Text[30])
        {
            Caption = 'POR File Name Prefix';
            DataClassification = CustomerContent;
        }
        field(50386; "INV File Name Prefix"; Text[30])
        {
            Caption = 'INV File Name Prefix';
            DataClassification = CustomerContent;
        }
        field(50387; "GLN for EDI"; Code[20])
        {
            Caption = 'GLN for EDI';
            DataClassification = CustomerContent;
        }
        field(50388; "Amount Rounding Precision"; Decimal)
        {
            Caption = 'Amount Rounding Precision';
            DataClassification = CustomerContent;
        }
        field(50389; "P2P INV Line Amount Variance"; Decimal)
        {
            Caption = 'EDI INV Line Amount Variance';
            DataClassification = CustomerContent;
        }
        field(50390; "Staging Table Age for Deletion"; DateFormula)
        {
            Caption = 'Staging Table Age for Deletion';
            DataClassification = CustomerContent;
        }
        field(50391; "P2P Invoice No. Series"; Code[20])
        {
            Caption = 'P2P Invoice No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
        field(50392; "Default Inbound Dir. VAN"; Text[250])
        {
            Caption = 'Default Inbound Dir. VAN';
            DataClassification = CustomerContent;
        }
        field(50393; "Default Outbound Dir. VAN"; Text[250])
        {
            Caption = 'Default Outbound Dir. VAN';
            DataClassification = CustomerContent;
        }
        field(50394; "Default Archive Dir. VAN"; Text[250])
        {
            Caption = 'Default Archive Dir. VAN';
            DataClassification = CustomerContent;
        }
        field(50395; "Default Error Dir. VAN"; Text[250])
        {
            Caption = 'Default Error Dir. VAN';
            DataClassification = CustomerContent;
        }
        field(50396; "Default Inbound Dir. P2P"; Text[250])
        {
            Caption = 'Default Inbound Dir. P2P';
            DataClassification = CustomerContent;
        }
        field(50397; "Default Outbound Dir. P2P"; Text[250])
        {
            Caption = 'Default Outbound Dir. P2P';
            DataClassification = CustomerContent;
        }
        field(50398; "Default Archive Dir. P2P"; Text[250])
        {
            Caption = 'Default Archive Dir. P2P';
            DataClassification = CustomerContent;
        }
        // >> GX202316 - New Change
        field(50399; "TOR Auto Decrease Enable"; Boolean)
        {
            Caption = 'TOR Auto Decrease Enable';
            DataClassification = CustomerContent;
        }
        // << GX202316 - New Change
        field(50400; "POS Return Non-Saleable Reason"; Code[10])
        {
            Caption = 'POS Return Non-Saleable Reason';
            DataClassification = CustomerContent;
            TableRelation = "Reason Code";
        }
        field(50480; "Comestri Product End Point"; Text[100])
        {
            Caption = 'Comestri Product End Point';
            DataClassification = CustomerContent;
        }
        field(50481; "Comestri SOH End Point"; Text[100])
        {
            Caption = 'Comestri SOH End Point';
            DataClassification = CustomerContent;
        }
        field(50482; "Comestri Product Template"; Code[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Comestri Product Template';
            TableRelation = "GXL ECS Data Template Header";
        }
        field(50483; "Comestri Send Data to"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Comestri SOH Send to';
            OptionMembers = "End Point","SFTP Location";
            OptionCaption = 'End Point,SFTP LOcation';
        }
        field(50484; "Comestri SFTP Host"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'SFTP Host';
        }
        field(50485; "Comestri File Download Type"; Option)
        {
            DataClassification = CustomerContent;

            OptionMembers = "Json","Zip";
            OptionCaption = 'Json,Zip';
        }
        field(50486; "Comestri SFTP Username"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'SFTP Username';
        }
        field(50487; "Comestri SFTP Password"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'SFTP Password';
        }
        field(50488; "Comestri SFTP Port"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'SFTP Port';
        }
        field(50489; "Comestri SFTP Host Key"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'SFTP Host Key';
        }
        field(50490; "Comestri SFTP Path"; Text[100])
        {
            DataClassification = CustomerContent;
            Caption = 'SFTP Path';
        }
        field(50491; "Live Store Only"; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Live Store Only';
        }
        //WRP-1013+
        field(50492; "Comestri Product Send to"; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Comestri Product Send to';
            OptionMembers = "End Point","SFTP Location";
            OptionCaption = 'End Point,SFTP LOcation';
        }
        //WRP-1013-
        // >> Upgrade
        field(50493; "GXL Maximum Message Size in MB"; Integer)
        {
            Caption = 'Maximum Message Size in MB';
            DataClassification = CustomerContent;
            InitValue = 0;
            MinValue = 0;
        }
        // << Upgrade
        // >> Harmony
        field(50494; "API Log CleanUp Frequency"; DateFormula)
        {
            Caption = 'Log CleanUp Frequency';
        }
        field(50495; "API Retry Frequency"; DateFormula)
        {
            Caption = 'Retry Frequency (Days)';
        }
        field(50496; "API Process On Event"; Boolean)
        {
            Caption = 'Process On Events';
        }
        field(50497; "API Lock Retry No."; Integer)
        {
            Caption = 'Lock Retry No.';
        }
        // << Harmony
    }

    keys
    {
        key(PK; "Primary key")
        {
            Clustered = true;
        }
    }

    trigger OnInsert()
    begin
        SetDefaultValuesOnInsert();
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

    local procedure SetDefaultValuesOnInsert()
    begin

    end;

}