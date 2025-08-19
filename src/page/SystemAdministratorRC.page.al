page 50001 "GXL System Administrator RC"
{
    /*Change Log
        CR050: PS-1948 External stocktake
            Added action "Extenral Stocktake Batches"
        ERP-204 GL History Batches
        NAV9-11 Integrations: New fields to turn synch to NAV13 on/off
    */

    Caption = 'GXL System Administrator';
    PageType = RoleCenter;

    layout
    {
        area(rolecenter)
        {
            part(GXLSystemAdminActivities; "GXL System Admin. Activities")
            {
                ApplicationArea = All;
            }
            part(ReportInboxPart; "Report Inbox Part")
            {
                ApplicationArea = All;
            }
            part(MyJobQueue; "My Job Queue")
            {
                ApplicationArea = All;
            }
            systempart(MyNotes; MyNotes)
            {
                ApplicationArea = All;
            }
            part(MyVendors; "My Vendors")
            {
                ApplicationArea = All;
            }
            part(MyItems; "My Items")
            {
                ApplicationArea = All;
            }
            part(MyCustomers; "My Customers")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(embedding)
        {
            action("Job Queue Entries")
            {
                ApplicationArea = All;
                Caption = 'Job Queue Entries';
                Image = TaskList;
                RunObject = Page "Job Queue Entries";
            }
            action(Items)
            {
                ApplicationArea = All;
                Caption = 'Items';
                RunObject = Page "LSC Retail Item List";
            }
            action("Stockkeeping Units")
            {
                ApplicationArea = All;
                Caption = 'Stockkeeping Units';
                RunObject = Page "Stockkeeping Unit List";
            }
            action(Locations)
            {
                ApplicationArea = All;
                Caption = 'Locations';
                RunObject = Page "Location List";
            }
            action(Vendors)
            {
                ApplicationArea = All;
                Caption = 'Vendors';
                RunObject = Page "Vendor List";
            }
            action(Customers)
            {
                ApplicationArea = All;
                Caption = 'Customers';
                RunObject = Page "Customer List";
            }
            action(ReasonCodes)
            {
                ApplicationArea = All;
                Caption = 'Reason Codes';
                RunObject = page "Reason Codes";
            }
        }
        area(sections)
        {
            group(UsersAndPermissions)
            {
                Caption = 'Users & Permissions';
                Image = Setup;
                action(Users)
                {
                    ApplicationArea = All;
                    Caption = 'Users';
                    Image = Users;
                    RunObject = Page Users;
                }
                action("User Setup")
                {
                    ApplicationArea = All;
                    Caption = 'User Setup';
                    Image = UserSetup;
                    RunObject = Page "User Setup";
                }
                action(ApprovalUserSetup)
                {
                    ApplicationArea = All;
                    Caption = 'Approval User Setup';
                    Image = ApprovalSetup;
                    RunObject = Page "Approval User Setup";
                }
                action("User Personalizations")
                {
                    ApplicationArea = All;
                    Caption = 'User Personalizations';
                    Image = UserInterface;
                    // >> Upgrade
                    //RunObject = Page "User Personalization List";
                    RunObject = Page "User Settings List";
                    // << Upgrade
                }
                action("User Groups")
                {
                    ApplicationArea = All;
                    Caption = 'User Groups';
                    Image = Group;
                    RunObject = Page "User Groups";
                }
                action("Permission Sets")
                {
                    ApplicationArea = All;
                    Caption = 'Permission Sets';
                    Image = Permission;
                    RunObject = Page "Permission Sets";
                }
            }
            group(SetupAndExtensions)
            {
                Caption = 'Setup & Extensions';
                Image = Setup;
                action(Extensions)
                {
                    ApplicationArea = All;
                    Caption = 'Extensions';
                    Image = NonStockItemSetup;
                    RunObject = Page "Extension Management";
                }
                action("Assisted Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Assisted Setup';
                    Image = QuestionaireSetup;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Assisted Setup";
                }
                action("Manual Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Manual Setup';
                    Promoted = true;
                    PromotedCategory = Process;
                    // >> Upgrade
                    //   ObsoleteReason = 'This table is being replaced by new table called Manual Setup.';
                    // ObsoleteTag = '18.0';
                    //RunObject = Page "Business Setup";
                    RunObject = Page "Manual Setup";
                    // << Upgrade
                }
                action("Service Connections")
                {
                    ApplicationArea = All;
                    Caption = 'Service Connections';
                    Image = ServiceTasks;
                    Promoted = true;
                    PromotedCategory = Process;
                    RunObject = Page "Service Connections";
                }
                action("Event Subscriptions")
                {
                    ApplicationArea = All;
                    Image = "Event";
                    RunObject = Page "Event Subscriptions";
                }
            }
            group(Workflow)
            {
                Caption = 'Workflow';
                Image = Administration;
                action(Workflows)
                {
                    ApplicationArea = All;
                    Caption = 'Workflows';
                    Image = ApprovalSetup;
                    RunObject = Page Workflows;
                    ToolTip = 'Set up or enable workflows that connect business-process tasks performed by different users. System tasks, such as automatic posting, can be included as steps in workflows, preceded or followed by user tasks. Requesting and granting approval to create new records are typical workflow steps.';
                }
                action("Workflow Templates")
                {
                    ApplicationArea = All;
                    Caption = 'Workflow Templates';
                    Image = Setup;
                    RunObject = Page "Workflow Templates";
                    ToolTip = 'View the list of workflow templates that exist in the standard version of Business Central for supported scenarios. The codes for workflow templates that are added by Microsoft are prefixed with MS-. You cannot modify a workflow template, but you use it to create a workflow.';
                }
                action(WorkflowUserGroups)
                {
                    ApplicationArea = All;
                    Caption = 'Workflow User Groups';
                    Image = Users;
                    RunObject = Page "Workflow User Groups";
                    ToolTip = 'View or edit the list of users that take part in workflows and which workflow user groups they belong to.';
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Job Queue Log Entries")
                {
                    ApplicationArea = All;
                    Caption = 'Job Queue Log Entries';
                    Image = EntriesList;
                    RunObject = Page "Job Queue Log Entries";
                }
                action("Change Log Entries")
                {
                    ApplicationArea = All;
                    Caption = 'Change Log Entries';
                    Image = ChangeLog;
                    RunObject = Page "Change Log Entries";
                    ToolTip = 'View the log with all the changes in your system';
                }
                action(MagentoWebOrderArchive)
                {
                    ApplicationArea = All;
                    Caption = 'Magento Web Order Archive';
                    Image = Archive;
                    RunObject = Page "GXL Magento Web Order Archive";
                }
            }
        }
        area(processing)
        {
            group("Application Setup")
            {
                Caption = 'Application Setup';
                Image = Setup;
                group(GeneralSetup)
                {
                    Caption = 'General Setup';
                    Image = Setup;
                    action("General Ledger Setup")
                    {
                        ApplicationArea = All;
                        Caption = 'General Ledger Setup';
                        Image = Setup;
                        RunObject = Page "General Ledger Setup";
                        ToolTip = 'Define your accounting policies, such as invoice rounding details, the currency code for your local currency, address formats, and whether you want to use an additional reporting currency.';
                    }
                    action("Purchase && Payables Setup")
                    {
                        ApplicationArea = All;
                        Caption = 'Purchase && Payables Setup';
                        Image = ReceivablesPayablesSetup;
                        RunObject = Page "Purchases & Payables Setup";
                        ToolTip = 'Define your general policies for purchase invoicing and returns, such as whether to require vendor invoice numbers and how to post purchase discounts. Set up your number series for creating vendors and different purchase documents.';
                    }
                    action("Sales && Receivables Setup")
                    {
                        ApplicationArea = All;
                        Caption = 'Sales && Receivables Setup';
                        Image = Setup;
                        RunObject = Page "Sales & Receivables Setup";
                        ToolTip = 'Define your general policies for sales invoicing and returns, such as when to show credit and stockout warnings and how to post sales discounts. Set up your number series for creating customers and different sales documents.';
                    }
                    action("Marketing Setup")
                    {
                        ApplicationArea = All;
                        Caption = 'Marketing Setup';
                        Image = MarketingSetup;
                        RunObject = Page "Marketing Setup";
                        ToolTip = 'Configure your company''s policies for marketing.';
                    }
                    action("Inventory Setup")
                    {
                        ApplicationArea = All;
                        Caption = 'Inventory Setup';
                        Image = InventorySetup;
                        RunObject = Page "Inventory Setup";
                        ToolTip = 'Define your general inventory policies, such as whether to allow negative inventory and how to post and adjust item costs. Set up your number series for creating new inventory items or services.';
                    }
                    action("Fixed &Asset Setup")
                    {
                        ApplicationArea = All;
                        Caption = 'Fixed &Asset Setup';
                        Image = Setup;
                        RunObject = Page "Fixed Asset Setup";
                        ToolTip = 'Configure your company''s policies for managing fixed assets.';
                    }
                    action("Change Log Setup")
                    {
                        ApplicationArea = All;
                        Caption = 'Change Log Setup';
                        Image = LogSetup;
                        RunObject = Page "Change Log Setup";
                        ToolTip = 'Define which contract changes are logged.';
                    }
                    action("SMTP Mail Setup")
                    {
                        ApplicationArea = All;
                        Caption = 'SMTP Mail Setup';
                        Image = MailSetup;
                        //RunObject = Page "SMTP Mail Setup";
                        RunObject = Page "SMTP Account";
                        ToolTip = 'Set up the integration and security of the mail server at your site that handles email.';
                    }
                    action("Web Services")
                    {
                        ApplicationArea = All;
                        Caption = 'Web Services';
                        Image = Web;
                        RunObject = Page "Web Services";
                    }
                    action("Com&pany Information")
                    {
                        ApplicationArea = All;
                        Caption = 'Com&pany Information';
                        Image = CompanyInformation;
                        RunObject = Page "Company Information";
                        ToolTip = 'Specify basic information about your company, which designates a complete set of accounting information and financial statements for a business entity. You enter information such as name, addresses, and shipping information. The information in the Company Information window is printed on documents, such as sales invoices.';
                    }
                }
                group(SupplyChain)
                {
                    Caption = 'Supply Chain';
                    Image = Setup;

                    action(SupplyChainSetup)
                    {
                        ApplicationArea = All;
                        Caption = 'Supply Chain Setup';
                        Image = Setup;
                        RunObject = page "GXL Supply Chain Setup";
                    }
                    action(SubCat3List)
                    {
                        ApplicationArea = All;
                        Caption = 'Sub-Category 3 List';
                        Image = CodesList;
                        RunObject = page "GXL Sub-Category 3 List";
                    }
                    action(SubCat4List)
                    {
                        ApplicationArea = All;
                        Caption = 'Sub-Category 4 List';
                        Image = CodesList;
                        RunObject = page "GXL Sub-Category 4 List";
                    }
                    action(SubDesc2List)
                    {
                        ApplicationArea = All;
                        Caption = 'Sub-Description 2 List';
                        Image = CodesList;
                        RunObject = page "GXL Sub-Description 2 List";
                    }
                    action(PrivateLabelCode)
                    {
                        ApplicationArea = All;
                        Caption = 'Private Label Code';
                        Image = CodesList;
                        RunObject = page "GXL Private Label Code";
                    }
                    action(SupplyPlanner)
                    {
                        ApplicationArea = All;
                        Caption = 'Supply Planner';
                        Image = CodesList;
                        RunObject = page "GXL Supply Planner";
                    }
                    action(Regions)
                    {
                        ApplicationArea = All;
                        Caption = 'Regions';
                        Image = CodesList;
                        RunObject = page "GXL Regions";
                    }
                    action(VendorClaimClassification)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor Claim Classification';
                        Image = CodesList;
                        RunObject = page "GXL Vend. Claim Classification";
                    }
                    action(WarehouseAssignment)
                    {
                        ApplicationArea = All;
                        Caption = 'Warehouse Assignments';
                        Image = CodesList;
                        RunObject = page "GXL Warehouse Assignments";
                    }
                    group(RangingSetup)
                    {
                        Caption = 'Ranging Setup';
                        action(ProductRangingCodeList)
                        {
                            ApplicationArea = All;
                            Caption = 'Product Range Code List';
                            Image = CodesList;
                            RunObject = page "GXL Product Range Code List";
                        }
                        action(ProdStoreRanging)
                        {
                            ApplicationArea = All;
                            Caption = 'Product Store Ranging List';
                            Image = CodesList;
                            RunObject = page "GXL Product-Store Ranging List";
                        }
                        action(RangingExceptions)
                        {
                            ApplicationArea = All;
                            Caption = 'Ranging Exceptions';
                            Image = CodesList;
                            RunObject = page "GXL Ranging Exceptions";
                        }
                        action(IllegalItems)
                        {
                            ApplicationArea = All;
                            Caption = 'Illegal Items';
                            Image = CodesList;
                            RunObject = page "GXL Illegal Items";
                        }
                        action(CreateUpdProdStoreRanging)
                        {
                            ApplicationArea = All;
                            Caption = 'Create/Update Product Store Ranging';
                            Image = CreateSKU;
                            RunObject = report "GXL Create Prod Store Ranging";
                        }
                    }
                }
                action("Integration Setup")
                {
                    ApplicationArea = All;
                    Caption = 'Integration Setup';
                    Image = InteractionTemplateSetup;
                    RunObject = Page "GXL Integration Setup";
                }

            }

            group(Reports)
            {
                Caption = 'Reports';
                group(ReportSelections)
                {
                    Caption = 'Report Selections';
                    Image = SelectReport;
                    action("Report Selection - Purchase")
                    {
                        ApplicationArea = All;
                        Caption = 'Report Selection - Purchase';
                        Image = SelectReport;
                        RunObject = Page "Report Selection - Purchase";
                    }
                    action("Report Selection - Sales")
                    {
                        ApplicationArea = All;
                        Caption = 'Report Selection - Sales';
                        Image = SelectReport;
                        RunObject = Page "Report Selection - Sales";
                    }
                    action("Report Selection - Inventory")
                    {
                        ApplicationArea = All;
                        Caption = 'Report Selection - Inventory';
                        Image = SelectReport;
                        RunObject = Page "Report Selection - Inventory";
                    }
                    action("Report Selection - Bank Account")
                    {
                        ApplicationArea = All;
                        Caption = 'Report Selection - Bank Account';
                        Image = SelectReport;
                        RunObject = Page "Report Selection - Bank Acc.";
                    }
                    action("Report Selection - Reminder && Finance Charge")
                    {
                        ApplicationArea = Suite;
                        Caption = 'Report Selection - Reminder && Finance Charge';
                        Image = SelectReport;
                        RunObject = Page "Report Selection - Reminder";
                    }
                }
                action("Custom Report Layouts")
                {
                    ApplicationArea = All;
                    Caption = 'Custom Report Layouts';
                    Image = Design;
                    RunObject = Page "Custom Report Layouts";
                }
                action("Report Layout Selection")
                {
                    ApplicationArea = All;
                    Caption = 'Report Layout Selection';
                    Image = SelectReport;
                    RunObject = Page "Report Layout Selection";
                }
            }
            group(Magento)
            {
                Caption = 'Magento';
                action(MagentoWebOrders)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Magento Web Orders';
                    Image = OrderList;
                    RunObject = Page "GXL Magento Web Orders";
                }
                action(MagentoPOSTransaction)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Magento POS Transactions';
                    Image = OrderList;
                    RunObject = Page "GXL Magento POS Transactions";
                }
                //PS-2423 Magento web order cancelled +
                action(MagentoCancelOrder)
                {
                    ApplicationArea = All;
                    Caption = 'Magento Cancelled Orders';
                    Image = CancelledEntries;
                    RunObject = page "GXL Magento Cancelled Orders";
                }
                //PS-2423 Magento web order cancelled -
            }
            group(ECS)
            {
                Caption = 'ECS';
                group(ECSProduct)
                {
                    Caption = 'Product';
                    Image = Item;
                    action(ECSProdHierarchy)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'ECS Product Hierarchy Data';
                        Image = ChangeLog;
                        RunObject = page "GXL ECS Product Hierarchy Data";
                    }
                    action(ECSItemContent)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'ECS Item Content Data';
                        Image = ChangeLog;
                        RunObject = page "GXL ECS Item Content Data";
                    }
                    action(ECSSalesPrice)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'ECS Sales Price Data';
                        Image = SalesPrices;
                        RunObject = page "GXL ECS Sales Price Data";
                    }
                }
                group(ECSStoreGrp)
                {
                    Caption = 'Store';
                    Image = ListPage;
                    action(ECSStore)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'ECS Store Data';
                        Image = ChangeLog;
                        RunObject = page "GXL ECS Store Data";
                    }
                    action(ECSStockRange)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'ECS Stock Range Data';
                        Image = ChangeLog;
                        RunObject = page "GXL ECS Stock Range Data";
                    }
                    action(ECSCluster)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'ECS Cluster Data';
                        Image = ChangeLog;
                        RunObject = page "GXL ECS Cluster Data";
                    }
                    action(ECSClusterStore)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'ECS Cluster Store Data';
                        Image = ChangeLog;
                        RunObject = page "GXL ECS Cluster Store Data";
                    }
                }
                group(ECSPromotionGrp)
                {
                    Caption = 'Promotions';
                    Image = SalesPrices;
                    action(ECSPromo)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'ECS Promotions';
                        Image = PriceWorksheet;
                        RunObject = page "GXL ECS Promotions";
                    }
                    action(ECSPromoData)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'ECS Promotion Data';
                        Image = ChangeLog;
                        RunObject = page "GXL ECS Promotion Data";
                    }
                    action(ECSPromoType)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'ECS Promotion Type';
                        Image = Setup;
                        RunObject = page "GXL ECS Promotion Types";
                    }
                }
                group(ECSTemplateGrp)
                {
                    Caption = 'Templates';
                    Image = Template;
                    action(ECSTemplate)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'ECS Data Templates';
                        Image = Template;
                        RunObject = page "GXL ECS Data Templates";
                    }
                }
                group(ECSTasks)
                {
                    Caption = 'Tasks';
                    Image = TaskList;
                    action(ECSInitialisation)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Initialise ECS Data';
                        Image = SetupList;
                        RunObject = report "GXl ECS Initialise Data";
                    }
                    action(ECSInitLocPrice)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Initialise Sales Price for a Location';
                        Image = SalesPrices;
                        RunObject = report "GXL ECS Init Location Prices";
                    }
                }
            }
            group(SOH)
            {
                Caption = 'SOH';
                action(SOHStaggingLog)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'SOH Stagging Data Log';
                    Image = ChangeLog;
                    RunObject = page "GXL SOH Staging Data Log";
                }
                action(AutoSOHLogUpdate)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Update SOH Stock Data';
                    Image = UpdateUnitCost;
                    RunObject = report "GXL SOH Stock Auto Update";
                }
            }
            group(Bloyal)
            {
                Caption = 'Bloyal';
                action(BloyalLog)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Bloyal Azure Log';
                    Image = ChangeLog;
                    RunObject = page "GXL BLoyal Azure Log";
                }

                group(BloyalTasks)
                {
                    Caption = 'Tasks';
                    Image = TaskList;
                    action(BloyalInitProduct)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Initialise Bloyal Product';
                        Image = SetupList;
                        RunObject = report "GXL Bloyal Init Product";
                    }
                }
            }
            group(Comestri)
            {
                Caption = 'Comestri';
                action(ComestriLog)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Comestri Azure Log';
                    Image = ChangeLog;
                    RunObject = page "GXL Comestri Azure Log";
                }
            }

            group(PDA)
            {

                Caption = 'PDA';
                group(PDAStaging)
                {
                    Caption = 'Staging';
                    Image = ImportLog;
                    action(PDAStockAdjBuffer)
                    {
                        ApplicationArea = All;
                        Caption = 'PDA Stock Adjustment Buffer';
                        ToolTip = 'MIM inserts entries into this table. Data in this table will be transferred to PDA Stock Adjustment Processing Buffer to be processed by the batch job';
                        Image = ItemLines;
                        RunObject = page "GXL PDA-Stock Adj. Buffer";
                    }
                    action(PDAPurchaseLine)
                    {
                        ApplicationArea = All;
                        Caption = 'PDA Purchase Lines';
                        ToolTip = 'MIM inserts entries into this table. Data in this table will be transferred to PDA Receiving Buffer to be processed by the batch job';
                        Image = ReceiptLines;
                        RunObject = page "GXL PDA-Purchase Lines";
                    }
                    action(PDAStagingPO)
                    {
                        ApplicationArea = All;
                        Caption = 'PDA Staging Purchase Orders';
                        ToolTip = 'MIM inserts entries into this table. Data in this table will be processed by the batch job to create actual purchase orders';
                        Image = OrderList;
                        RunObject = page "GXL PDA-Staging Purch. Orders";
                        Visible = false; //Not in this phase
                    }
                    action(PDAStagingTO)
                    {
                        ApplicationArea = All;
                        Caption = 'PDA Staging Transfer Orders';
                        ToolTip = 'MIM inserts entries into this table. Data in this table will be processed by the batch job to create actual transfer orders';
                        Image = OrderList;
                        RunObject = page "GXL PDA-Staging Trans. Orders";
                    }
                    action(PDATransShptLines)
                    {
                        ApplicationArea = All;
                        Caption = 'PDA Transfer Shipment Lines';
                        ToolTip = 'MIM inserts transfer shipment entries into this table. Data in this table will be transferred to PDA Transfer Shipment Process Buffer to be processed by the batch job';
                        Image = TransferToLines;
                        RunObject = page "GXL PDA-Trans. Shipment Lines";
                    }
                }

                action(PDAStockAdjProcessingBuffer)
                {
                    ApplicationArea = All;
                    Caption = 'PDA Stock Adj Processing Buffer';
                    ToolTip = 'Data in this table has been transferred from PDA Stock Adjustment Buffer to create inventory adjustments.';
                    Image = ItemLines;
                    RunObject = page "GXL PDA-StAdjProcessing Buffer";
                }
                action(PDAReceiveBuffer)
                {
                    ApplicationArea = All;
                    Caption = 'PDA Receiving Buffer';
                    ToolTip = 'Data in this table has been transferred from PDA Purchase Lines to post purchase receipts';
                    Image = ReceiptLines;
                    RunObject = page "GXL PDA-Receiving Buffer";
                }
                action(PDATransShptProcessBuff)
                {
                    ApplicationArea = All;
                    Caption = 'PDA Transfer Shpt Process Buffer';
                    ToolTip = 'Data in this table has been transferred from PDA Transfer Shipment Lines to ship transfer orders';
                    Image = TransferToLines;
                    RunObject = page "GXL PDA-TransShpt Process Buff";
                }

                group(PDASetups)
                {
                    Caption = 'PDA Setups';
                    action(PDAStoreUsers)
                    {
                        ApplicationArea = All;
                        Caption = 'PDA Store Users';
                        Image = UserSetup;
                        RunObject = page "GXL PDA-Store Users";
                    }

                }
            }
            group(WMS_3PL)
            {
                Caption = 'WMS/3PL';
                group(ThreePLGrp)
                {
                    Caption = '3PL';
                    action(ThreePLStockAdj)
                    {
                        ApplicationArea = All;
                        Caption = '3PL Stock Adjustment';
                        Image = ImportLog;
                        RunObject = page "GXL 3PL Stock Adjustment";
                    }
                    action(ThreePLPackingSlip)
                    {
                        ApplicationArea = All;
                        Caption = '3PL Packing Slip';
                        Image = ImportLog;
                        RunObject = page "GXL 3PL Packing Slip";
                    }
                    action(VendorInvoiceMessage)
                    {
                        ApplicationArea = All;
                        Caption = 'Vendor Invoice Message List';
                        Image = ImportLog;
                        RunObject = page "GXL Vendor Invoice Messages";
                    }
                    action(ImportLocationFiles)
                    {
                        ApplicationArea = All;
                        Caption = 'Import Location Files';
                        Image = Import;
                        RunObject = report "GXL Import Location Files";
                    }
                }
                group(EDIGrp)
                {
                    Caption = 'EDI';
                    action(AdvanceShipNotice)
                    {
                        ApplicationArea = All;
                        Caption = 'Advance Shipping Notice';
                        Image = ImportLog;
                        RunObject = page "GXL Adv. Shipping Notice List";
                    }
                    action(P2PInvoices)
                    {
                        ApplicationArea = All;
                        Caption = 'P2P Invoice List';
                        Image = ImportLog;
                        RunObject = page "GXL P2P Invoice List";
                    }
                    group(Log)
                    {
                        Caption = 'Log';
                        action(EDIFileLog)
                        {
                            ApplicationArea = All;
                            Caption = 'EDI File Log';
                            Image = ImportLog;
                            RunObject = page "GXL EDI File Log";
                        }
                        action(EDIDocLog)
                        {
                            ApplicationArea = All;
                            Caption = 'EDI Document Log';
                            Image = ErrorLog;
                            RunObject = page "GXL EDI Document Log";
                        }
                        action(ASNScanLog)
                        {
                            ApplicationArea = All;
                            Caption = 'ASN Scan Log';
                            Image = ImportLog;
                            RunObject = page "GXL ASN Header Scan Logs";
                        }
                    }
                }
                group(WMSSetup)
                {
                    Caption = 'Setup';
                    action(ThreePLFileSetup)
                    {
                        ApplicationArea = All;
                        Caption = '3PL File Setup';
                        Image = SetupList;
                        RunObject = page "GXL 3PL File Setup";
                    }
                }
            }
            group(NAV13)
            {
                Caption = 'NAV-13';
                group(NAV13Incoming)
                {
                    Caption = 'Incoming';
                    action(ConfirmedOrders)
                    {
                        ApplicationArea = All;
                        Caption = 'NAV Confirmed Orders';
                        Image = Intercompany;
                        RunObject = page "GXL NAV Confirmed Orders";
                    }
                    //PS-2270+
                    action(CancelledOrders)
                    {
                        ApplicationArea = All;
                        Caption = 'NAV Cancelled Orders';
                        Image = Intercompany;
                        RunObject = page "GXL NAV Cancelled Orders";
                    }
                    //PS-2270-
                }
                group(NAV13Outgoing)
                {
                    Caption = 'Outgoing';
                    //NAV9-11+
                    action(CancelNAVOrderLog)
                    {
                        ApplicationArea = All;
                        Caption = 'Cancel NAV Order Log';
                        Image = Log;
                        RunObject = page "GXL Cancel NAV Order Log";
                    }
                    //NAV9-11-
                    //ERP-NAV Master Data Management +
                    action(ItemSKUBuffer)
                    {
                        ApplicationArea = All;
                        Caption = 'NAV Item/SKU Log';
                        Image = OutboundEntry;
                        RunObject = page "GXL NAV Item/SKU Log";
                    }
                    //ERP-NAV Master Data Management -
                }
            }
            group(DataUpload)
            {
                Caption = 'Data Upload';
                action(ItemJnlBuffer)
                {
                    ApplicationArea = All;
                    Caption = 'Item Jounral Buffer Batches';
                    Image = ImportLog;
                    RunObject = page "GXL Item Jnl Buffer Batches";
                }
                //+ CR050: PS-1948 External stocktake
                action(ExternalStocktake)
                {
                    ApplicationArea = All;
                    Caption = 'External Stocktake Batches';
                    Image = ImportLog;
                    RunObject = page "GXL External Stocktake Batches";
                }
                //- CR050: PS-1948 External stocktake
                group(GLJnlImport)
                {
                    Caption = 'G/L Import';
                    Image = Import;
                    //PS-2284+
                    action(GeneralJournalExcel)
                    {
                        ApplicationArea = All;
                        Caption = 'Import General Journal from Excel';
                        Image = Excel;
                        RunObject = report "GXL ImportGenJnlFromExcel";
                    }
                    action(GeneralJournalCSV)
                    {
                        ApplicationArea = All;
                        Caption = 'Import General Journal from CSV';
                        Image = Excel;
                        RunObject = xmlport "GXL Gen. Journal Import";
                    }
                    //PS-2284-
                    //CR103 - G/L Import +
                    action(GLImportPetbarn)
                    {
                        ApplicationArea = All;
                        Caption = 'Import General Journal - Petbarn';
                        Image = Import;
                        RunObject = xmlport "GXL Gen. Jnl. Import - Petbarn";
                    }
                    action(GLImportVet)
                    {
                        ApplicationArea = All;
                        Caption = 'Import General Journal - Vet';
                        Image = Import;
                        RunObject = xmlport "GXL Gen. Jnl. Import - Vet";
                    }
                    //CR103 - G/L Import -

                }
                //ERP-204 GL History Batches >>
                action(GLHistoryLoad)
                {
                    ApplicationArea = All;
                    Caption = 'G/L History Batches';
                    Image = Journals;
                    RunObject = page "GXL GL History Batches";
                }
                //ERP-204 GL History Batches <<

                //CR099 - Revaluation Journal Batch +
                action(RevaluationJnlBatch)
                {
                    ApplicationArea = All;
                    Caption = 'Revaluation Journal Worksheet';
                    Image = Worksheet;
                    RunObject = page "GXL Item Reval. Worksheets";
                }
                //CR099 - Revaluation Journal Batch -
            }
        }
    }

}