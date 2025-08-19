// 001 02.07.2025 KDU HP2-Sprint1
page 50000 "GXL Integration Setup"
{
    /*Change Log
        NAV9-11 Integrations: New fields to turn synch to NAV13 on/off
        WRP-1013: 03-02-21
            Comestri Send to Parameters can be different b/w SOH and Product full feed
    */

    Caption = 'GXL Integration Setup';
    PageType = Card;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "GXL Integration Setup";
    InsertAllowed = false;
    DeleteAllowed = false;

    layout
    {
        area(Content)
        {
            group(MagentoWebOrder)
            {
                Caption = 'Magento Web Order';
                field("Magento POS-Trans. Posting"; Rec."Magento POS-Trans. Posting")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if magento POS posting is disabled or if the posting is either manually triggered or scheduled using the Job Queue.';
                }
                field("Magento POS-Trans. Post. Delay"; Rec."Magento POS-Trans. Post. Delay")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies in seconds, the minimum time that the system will wait after a transaction entry is inserted before trying to POS post all the entries with the same Transaction ID.';
                }
                field("Magento Income/Expense Acc."; Rec."Magento Income/Expense Acc.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code of income/expense account. This code will be used in combination of Magento store no.';
                }
                field("Magento Sales Type"; Rec."Magento Sales Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies Sales Type for Magento orders';
                }
                //ERP-333 +
                field("Magento Recent Process Days"; Rec."Magento Recent Process Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies number of days back from today the transactions to be processed';
                }
                //ERP-333 -
                // >> 001
                field("Replenishment Team Email"; Rec."Replenishment Team Email")
                {
                    ApplicationArea = All;
                }
                // << 001

            }
            group(SOHIntegration)
            {
                Caption = 'SOH Integration';
                field("SOH Batch No. Series"; Rec."SOH Batch No. Series")
                { ApplicationArea = All; }
                field("SOH Clear Data After"; Rec."SOH Clear Data After")
                { ApplicationArea = All; }
                field("DB server"; Rec."DB server")
                { ApplicationArea = All; }
                field("DB Name"; Rec."DB Name")
                { ApplicationArea = All; }
                field("User name"; Rec."User name")
                { ApplicationArea = All; }
                field(Password; Rec.Password)
                { ApplicationArea = All; }
            }
            group(ECSIntegration)
            {
                Caption = 'ECS Integration';
                field("ECS Store Integration"; Rec."ECS Store Integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies ECS store, cluster and store cluster integration option. Select Enable to let the system to automatically log the changes into ECS Store Data.';
                }
                field("ECS Prod Hierarchy Integration"; Rec."ECS Prod Hierarchy Integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies ECS product hierarchy integration option. Select Enable to let the system to automatically log the changes into ECS Product Hierarchy.';
                }
                field("ECS Item Content Integration"; Rec."ECS Item Content Integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies ECS item content integration option. Select Enable to let the system to automatically log the changes into ECS Item Content.';
                }
                field("ECS Sales Price Integration"; Rec."ECS Sales Price Integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies ECS sales price integration option. Select Enable to let the system to automatically log the changes into ECS Sales Price.';
                }
                field("ECS Stock Ranging Integration"; Rec."ECS Stock Ranging Integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies ECS stock ranging integration option. Select Enable to let the system to automatically log the changes into ECS Stock Ranging.';
                }
                field("ECS Promotion Integration"; Rec."ECS Promotion Integration")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies ECS promotion integration option.';
                }

                group(ECSDataTemplate)
                {
                    ShowCaption = false;
                    field("ECS Store Data Template"; Rec."ECS Store Data Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the ECS data template to be used to trigger to log the change to ECS Store Data basing on configuration fields in the template.';
                    }
                    field("ECS Cluster Data Template"; Rec."ECS Cluster Data Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the ECS data template to be used to trigger to log the change to ECS Store Data basing on configuration fields in the template.';
                    }
                    field("ECS StoreCluster Data Template"; Rec."ECS StoreCluster Data Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the ECS data template to be used to trigger to log the change to ECS Store Data basing on configuration fields in the template.';
                    }
                    field("ECS Item Content Data Template"; Rec."ECS Item Content Data Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the ECS data template to be used to trigger to log the change to ECS Item Content basing on configuration fields in the template.';
                    }
                    field("ECS Sales Price Data Template"; Rec."ECS Sales Price Data Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the ECS data template to be used to trigger to log the change to ECS Sales Price basing on configuration fields in the template.';
                    }
                    field("ECS Stock Range Data Template"; Rec."ECS Stock Range Data Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the ECS data template to be used to trigger to log the change to ECS Stock Ranging basing on configuration fields in the template.';
                    }
                }
            }
            group(BloyalIntegration)
            {
                Caption = 'Bloyal Integration';
                group(BloyalEndpoints)
                {

                    ShowCaption = false;
                    field("Bloyal Access Token"; Rec."Bloyal Access Token")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the OAuth Bearer token to be used to send data to Azure LogicApp.';
                    }
                    field("Bloyal Sales Payment Endpoint"; Rec."Bloyal Sales Payment Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Azure LogicApp endpoint for Sales and Payment';
                    }
                    field("Bloyal SOH Endpoint"; Rec."Bloyal SOH Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Azure LogicApp endpoint for Stock on Hand';
                    }
                    field("Bloyal Product Endpoint"; Rec."Bloyal Product Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Azure LogicApp endpoint for Product';
                    }
                    field("Bloyal Division Endpoint"; Rec."Bloyal Division Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Azure LogicApp endpoint for Product Hierarchy: Division';
                    }
                    field("Bloyal Item Category Endpoint"; Rec."Bloyal Item Category Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Azure LogicApp endpoint for Product Hierarchy: Item Category';
                    }
                    field("Bloyal Retail Product Endpoint"; Rec."Bloyal Retail Product Endpoint")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the Azure LogicApp endpoint for Product Hierarchy: Retail Product Group';
                    }
                }
                group(BloyalTemplate)
                {
                    ShowCaption = false;
                    field("Bloyal Sales Payment Template"; Rec."Bloyal Sales Payment Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifes the data template to be used to specify which fields in Trans. Sales Entry to be sent to Azure LogicApp.';
                    }
                    field("Bloyal Product Template"; Rec."Bloyal Product Template")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifes the data template to be used to specify which fields in Item to be sent to Azure LogicApp.';
                    }
                }
                group(BloyalLimits)
                {
                    ShowCaption = false;
                    field("Bloyal Max. of Try"; Rec."Bloyal Max. of Try")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies maximum number of tries to send to Azure LogicApp, if error occurs, before errors being thrown.';
                    }
                    field("Bloyal Sales Pmt Max Records"; Rec."Bloyal Sales Pmt Max Records")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the maximum number of sales entry records can be sent in one API request.';
                    }
                    field("Bloyal SOH Max Records"; Rec."Bloyal SOH Max Records")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the maximum number of SOH records can be sent in one API request.';
                    }
                    field("Bloyal Product Max Records"; Rec."Bloyal Product Max Records")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the maximum number of product records can be sent in one API request.';
                    }
                    field("Bloyal Hierarchy Max Records"; Rec."Bloyal Hierarchy Max Records")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the maximum number of product hierarchy records can be sent in one API request.';
                    }
                }
                group(BloyalNotification)
                {
                    ShowCaption = false;
                    field("Bloyal Notif. Sender E-Mail"; Rec."Bloyal Notif. Sender E-Mail")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the sender email to be used to send errors notification.';
                    }
                    field("Bloyal Notif. Recipient"; Rec."Bloyal Notif. Recipient")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the recipient email that the errors notification will be sent to.';
                    }
                }
            }
            group(ComestriIntegration)
            {
                Caption = 'Comestri Integration';
                field("Comestri Access Token"; Rec."Bloyal Access Token")
                { ApplicationArea = all; }
                field("Comestri Product End Point"; Rec."Comestri Product End Point")
                { ApplicationArea = All; }
                field("Comestri SOH End Point"; Rec."Comestri SOH End Point")
                { ApplicationArea = All; }
                field("Comestri Product Template"; Rec."Comestri Product Template")
                { ApplicationArea = All; }
                field("Comestri SOH Send Data to"; Rec."Comestri Send Data to")
                { ApplicationArea = All; }
                //WRP-1013+
                field("Comestri Product Send to"; Rec."Comestri Product Send to")
                {
                    ApplicationArea = All;
                }
                //WRP-1013-
                field("Comestri SFTP Host"; Rec."Comestri SFTP Host")
                { ApplicationArea = All; }
                field("Comestri SFTP Username"; Rec."Comestri SFTP Username")
                { ApplicationArea = All; }
                field("Comestri SFTP Password"; Rec."Comestri SFTP Password")
                { ApplicationArea = All; }
                field("Comestri SFTP Port"; Rec."Comestri SFTP Port")
                { ApplicationArea = All; }
                field("Comestri SFTP Host Key"; Rec."Comestri SFTP Host Key")
                { ApplicationArea = All; }
                field("Comestri SFTP Path"; Rec."Comestri SFTP Path")
                { ApplicationArea = All; }
                field("Comestri File Download Type"; Rec."Comestri File Download Type")
                { ApplicationArea = All; }
                field("Live Store Only"; Rec."Live Store Only")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies to extract SOH for Live Stores only';
                }

            }
            group(SupplyChain)
            {
                Caption = 'Supply Chain';
                field("Allowable Tolerance %"; Rec."Allowable Tolerance %")
                {
                    ApplicationArea = All;
                }
                field("Audits per Month"; Rec."Audits per Month")
                {
                    ApplicationArea = All;
                }
                field("Store Dimension Code"; Rec."Store Dimension Code")
                {
                    ApplicationArea = All;
                }
                field("Time Format"; Rec."Time Format")
                {
                    ApplicationArea = All;
                }
                field("Date Format"; Rec."Date Format")
                {
                    ApplicationArea = All;
                }
            }
            // >> Harmony
            group(API)
            {
                Caption = 'API';
                field("API Process On Event"; Rec."API Process On Event")
                {
                    ApplicationArea = all;
                }
                field("API Retry Frequency"; Rec."API Retry Frequency")
                {
                    ApplicationArea = all;
                }
                field("API Log CleanUp Frequency"; Rec."API Log CleanUp Frequency")
                {
                    ApplicationArea = all;
                }
                field("API Lock Retry No."; Rec."API Lock Retry No.")
                {
                    ApplicationArea = all;
                }
            }
            // << Harmony
            group(WMS3PL)
            {
                Caption = 'WMS-3PL-EDI';
                group(EDIGeneral)
                {
                    Caption = 'General';
                    field("Log Age for Deletion"; Rec."Log Age for Deletion")
                    {
                        ApplicationArea = All;
                    }
                    field("Staging Table Age for Deletion"; Rec."Staging Table Age for Deletion")
                    {
                        ApplicationArea = All;
                    }
                    field("Invoice On Hold Duration"; Rec."Invoice On Hold Duration")
                    {
                        ApplicationArea = All;
                    }
                    field("GLN for EDI"; Rec."GLN for EDI")
                    {
                        ApplicationArea = All;
                    }
                    field("Post / Send Claims"; Rec."Post / Send Claims")
                    {
                        ApplicationArea = All;
                    }
                }
                group(EDIDocument)
                {
                    Caption = 'EDI Document';
                    field("Amount Rounding Precision"; Rec."Amount Rounding Precision")
                    {
                        ApplicationArea = All;
                    }
                    field("P2P INV Line Amount Variance"; Rec."P2P INV Line Amount Variance")
                    {
                        ApplicationArea = All;
                    }
                    field("Suffix for EDI Document"; Rec."Suffix for EDI Document")
                    {
                        ApplicationArea = All;
                    }
                    field("NAV EDI Document No. Format"; Rec."NAV EDI Document No. Format")
                    {
                        ApplicationArea = All;
                    }
                }
                group(EDINumbering)
                {
                    Caption = 'Numbering';
                    field("EDI POR No. Series"; Rec."EDI POR No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI ASN No. Series"; Rec."EDI ASN No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI Invoice No. Series"; Rec."EDI Invoice No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("P2P Contingency ASN Nos."; Rec."P2P Contingency ASN Nos.")
                    {
                        ApplicationArea = All;
                    }
                    field("P2P Invoice No. Series"; Rec."P2P Invoice No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("Intl. Ship. Advice No. Series"; Rec."Intl. Ship. Advice No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("Intl. PO Ack. No. Series"; Rec."Intl. PO Ack. No. Series")
                    {
                        ApplicationArea = All;
                    }
                }
                group(FilePrefix)
                {
                    Caption = 'File Prefix';
                    field("PO File Name Prefix"; Rec."PO File Name Prefix")
                    {
                        ApplicationArea = All;
                    }
                    field("POR File Name Prefix"; Rec."POR File Name Prefix")
                    {
                        ApplicationArea = All;
                    }
                    field("ASN File Name Prefix"; Rec."ASN File Name Prefix")
                    {
                        ApplicationArea = All;
                    }
                    field("INV File Name Prefix"; Rec."INV File Name Prefix")
                    {
                        ApplicationArea = All;
                    }
                    field("POX File Name Prefix"; Rec."POX File Name Prefix")
                    {
                        ApplicationArea = All;
                    }

                }
                group(EDIPathFiles)
                {
                    Caption = 'Paths & Files';
                    group(VAN)
                    {
                        ShowCaption = false;
                        field("Default Inbound Dir. VAN"; Rec."Default Inbound Dir. VAN")
                        {
                            ApplicationArea = All;
                        }
                        field("Default Outbound Dir. VAN"; Rec."Default Outbound Dir. VAN")
                        {
                            ApplicationArea = All;
                        }
                        field("Default Archive Dir. VAN"; Rec."Default Archive Dir. VAN")
                        {
                            ApplicationArea = All;
                        }
                        field("Default Error Dir. VAN"; Rec."Default Error Dir. VAN")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(P2P)
                    {
                        ShowCaption = false;
                        field("Default Inbound Dir. P2P"; Rec."Default Inbound Dir. P2P")
                        {
                            ApplicationArea = All;
                        }
                        field("Default Outbound Dir. P2P"; Rec."Default Outbound Dir. P2P")
                        {
                            ApplicationArea = All;
                        }
                        field("Default Archive Dir. P2P"; Rec."Default Archive Dir. P2P")
                        {
                            ApplicationArea = All;
                        }
                        field("Default Error Dir. P2P"; Rec."Default Error Dir. P2P")
                        {
                            ApplicationArea = All;
                        }
                    }
                    group(NonEDI)
                    {
                        ShowCaption = false;
                        field("Default Inbound Dir. Non-EDI"; Rec."Default Inbound Dir. Non-EDI")
                        {
                            ApplicationArea = All;
                        }
                        field("Default Outbound Dir. Non-EDI"; Rec."Default Outbound Dir. Non-EDI")
                        {
                            ApplicationArea = All;
                        }
                        field("Default Archive Dir. Non-EDI"; Rec."Default Archive Dir. Non-EDI")
                        {
                            ApplicationArea = All;
                        }
                        field("Default Error Dir. Non-EDI"; Rec."Default Error Dir. Non-EDI")
                        {
                            ApplicationArea = All;
                        }
                    }
                }
                group(EDIClaims)
                {
                    Caption = 'EDI Claims';
                    field("EDI Credit Memo No. Series"; Rec."EDI Credit Memo No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI Return Order No. Series"; Rec."EDI Return Order No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI Return Order Reason Code"; Rec."EDI Return Order Reason Code")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI Return Order Vendor No."; Rec."EDI Return Order Vendor No.")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI Ret. Order Bal. Acc. Type"; Rec."EDI Ret. Order Bal. Acc. Type")
                    {
                        ApplicationArea = All;
                    }
                    field("EDI Ret. Order Bal. Acc. No."; Rec."EDI Ret. Order Bal. Acc. No.")
                    {
                        ApplicationArea = All;
                    }
                }
                group(VendorFiles)
                {
                    Caption = 'Vendor File Exchange';
                    field("Vendor Archive Directory"; Rec."Vendor Archive Directory")
                    {
                        ApplicationArea = All;
                    }
                    field("Vendor Error Directory"; Rec."Vendor Error Directory")
                    {
                        ApplicationArea = All;
                    }
                    field("Default STK Adj. Reason Code"; Rec."Default STK Adj. Reason Code")
                    {
                        ApplicationArea = All;
                    }
                    field("ASN Variance Reason Code"; Rec."ASN Variance Reason Code")
                    {
                        ApplicationArea = All;
                    }
                    field("PO XMLPort ID"; Rec."PO XMLPort ID")
                    {
                        ApplicationArea = All;
                    }
                }
                group(ThirsdPartyData)
                {
                    Caption = '3PL';
                    field("Default WH Stk Adj No. Series"; Rec."Default WH Stk Adj No. Series")
                    {
                        ApplicationArea = All;
                    }
                    field("3PL Archive Directory"; Rec."3PL Archive Directory")
                    {
                        ApplicationArea = All;
                    }
                    field("3PL Error Directory"; Rec."3PL Error Directory")
                    {
                        ApplicationArea = All;
                    }
                    field("3PL Purch. St. Adj Reason Code"; Rec."3PL Purch. St. Adj Reason Code")
                    {
                        ApplicationArea = All;
                    }
                    field("Suffix for TO SOH Increase"; Rec."Suffix for TO SOH Increase")
                    {
                        ApplicationArea = All;
                    }
                    field("Suffix for TO SOH Decrease"; Rec."Suffix for TO SOH Decrease")
                    {
                        ApplicationArea = All;
                    }
                    // >> GX202316 - New Change
                    field("TOR Auto Decrease Enable"; Rec."TOR Auto Decrease Enable")
                    {
                        ApplicationArea = All;
                    }
                    // << GX202316 - New Change

                }
            }
            group(PDA)
            {
                Caption = 'PDA';
                field("PDA Over Receiving Reason Code"; Rec."PDA Over Receiving Reason Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason code to be populated to purchase order when the quantity to receive from PDA is greater than quantity ordered';
                }
                field("Recent Order Days"; Rec."Recent Order Days")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of days to get the recent purchase/transfer orders from PDA.';
                }
                field("Last RMS ID"; Rec."Last RMS ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the last RMS ID that NAV13-MIM generated. This RMS ID is only applicable for integration back to NAV13 for inventory adjustment';
                }
            }
            group(POS)
            {
                Caption = 'POS';
                field("POS Return Non-Saleable Reason"; Rec."POS Return Non-Saleable Reason")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the reason code to be used for return non-saleable items from POS to be posted to Item Ledger';
                }
            }
            //NAV9-11+
            group(NAV)
            {
                Caption = 'NAV-13';
                field("Sync Cancel NAV Purchase Order"; Rec."Sync Cancel NAV Purchase Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if sync back to NAV13 to cancel purchase order on purchase receipt';
                }
                field("Sync Cancel NAV Transfer Order"; Rec."Sync Cancel NAV Transfer Order")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if sync back to NAV13 to cancel transfer order on transfer receipt';
                }
                //ERP-NAV Master Data Management +
                field("Sync NAV-13 Inactive"; Rec."Sync NAV-13 Inactive")
                {
                    ApplicationArea = All;
                    ToolTip = 'Tick the box will deactivate of creating a record in table "GXL PDA-StAdjProcessing Buffer" on store-to-store transfer shipment/receipt or stocktake';
                }
                //ERP-NAV Master Data Management -
            }
            //NAV9-11-
            //PS-2523 VET Clinic transfer order +
            group(VET)
            {
                Caption = 'VET Clinic';
                field("VET Transfer Order Nos."; Rec."VET Transfer Order Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number series to be used for transfer order for VET clinic';
                }
                field("VET Customer No."; Rec."VET Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer number to be used to create a sales order from transfer order for VET clinic';
                }
                field("VET Intercompany G/L Account"; Rec."VET Intercompany G/L Account")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the G/L Account as a cash receipt account for a sales invoice';
                }
            }
            //PS-2523 VET Clinic transfer order -
        }
    }

    actions
    {
        area(processing)
        {

            action("Enable API For Locations")
            {
                ApplicationArea = All;
                Caption = 'Enable API For Locations';
                Image = EntriesList;
                RunObject = page "API Enable Per Location";
                RunPageView = sorting("Location Code", "API Type");
                RunPageMode = Edit;
            }

        }
    }

    trigger OnOpenPage()
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert(true);
        end;
    end;
}