page 50020 "GXL Negative Stock"
{
    AdditionalSearchTerms = 'product,finished good,component,raw material,assembly item';
    ApplicationArea = Basic, Suite, Assembly, Service;
    Caption = 'Negative Stock Report';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Item,History,Special Prices & Discounts,Request Approval,Periodic Activities,Inventory,Attributes';
    QueryCategory = 'Item List';
    RefreshOnActivate = true;
    SourceTable = Item;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                Caption = 'Item';
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the item.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the item.';
                }
                field("GXL Item Category Description"; Rec."GXL Item Category Description")
                {
                    ApplicationArea = All;
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the base unit used to measure the item, such as piece, box, or pallet. The base unit of measure also serves as the conversion basis for alternate units of measure.';
                }
                field(InventoryCtrl; Rec.Inventory)
                {
                    ApplicationArea = All;
                    HideValue = IsNonInventoriable;
                    ToolTip = 'Specifies how many units, such as pieces, boxes, or cans, of the item are in inventory.';

                    trigger OnDrillDown()
                    begin
                        GXL_DrilldownItemLedger();
                    end;
                }
                field("GXL Supplier Number"; Rec."GXL Supplier Number")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the supplier number of the item.';
                }
                field("GXL Supplier Name"; Rec."GXL Supplier Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the supplier name of the item.';
                }
            }
        }
        area(factboxes)
        {
            part("Power BI Report FactBox"; "Power BI Report FactBox")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Power BI Reports';
                Visible = PowerBIVisible;
            }
            part(Control1901314507; "Item Invoicing FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("No."),
                              "Date Filter" = FIELD("Date Filter"),
                              "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                              "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                              "Location Filter" = FIELD("Location Filter"),
                              "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                              "Bin Filter" = FIELD("Bin Filter"),
                              "Variant Filter" = FIELD("Variant Filter"),
                              "Lot No. Filter" = FIELD("Lot No. Filter"),
                              "Serial No. Filter" = FIELD("Serial No. Filter");
            }
            part(Control1903326807; "Item Replenishment FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("No."),
                              "Date Filter" = FIELD("Date Filter"),
                              "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                              "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                              "Location Filter" = FIELD("Location Filter"),
                              "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                              "Bin Filter" = FIELD("Bin Filter"),
                              "Variant Filter" = FIELD("Variant Filter"),
                              "Lot No. Filter" = FIELD("Lot No. Filter"),
                              "Serial No. Filter" = FIELD("Serial No. Filter");
                Visible = false;
            }
            part(Control1906840407; "Item Planning FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("No."),
                              "Date Filter" = FIELD("Date Filter"),
                              "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                              "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                              "Location Filter" = FIELD("Location Filter"),
                              "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                              "Bin Filter" = FIELD("Bin Filter"),
                              "Variant Filter" = FIELD("Variant Filter"),
                              "Lot No. Filter" = FIELD("Lot No. Filter"),
                              "Serial No. Filter" = FIELD("Serial No. Filter");
            }
            part(Control1901796907; "Item Warehouse FactBox")
            {
                ApplicationArea = Basic, Suite;
                SubPageLink = "No." = FIELD("No."),
                              "Date Filter" = FIELD("Date Filter"),
                              "Global Dimension 1 Filter" = FIELD("Global Dimension 1 Filter"),
                              "Global Dimension 2 Filter" = FIELD("Global Dimension 2 Filter"),
                              "Location Filter" = FIELD("Location Filter"),
                              "Drop Shipment Filter" = FIELD("Drop Shipment Filter"),
                              "Bin Filter" = FIELD("Bin Filter"),
                              "Variant Filter" = FIELD("Variant Filter"),
                              "Lot No. Filter" = FIELD("Lot No. Filter"),
                              "Serial No. Filter" = FIELD("Serial No. Filter");
                Visible = false;
            }
            part(ItemAttributesFactBox; "Item Attributes Factbox")
            {
                ApplicationArea = Basic, Suite;
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Item)
            {
                Caption = 'Item';
                Image = DataEntry;
                action("&Units of Measure")
                {
                    ApplicationArea = Advanced;
                    Caption = '&Units of Measure';
                    Image = UnitOfMeasure;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Item Units of Measure";
                    RunPageLink = "Item No." = FIELD("No.");
                    Scope = Repeater;
                    ToolTip = 'Set up the different units that the item can be traded in, such as piece, box, or hour.';
                }
                action(Attributes)
                {
                    AccessByPermission = TableData "Item Attribute" = R;
                    ApplicationArea = Advanced;
                    Caption = 'Attributes';
                    Image = Category;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Scope = Repeater;
                    ToolTip = 'View or edit the item''s attributes, such as color, size, or other characteristics that help to describe the item.';

                    trigger OnAction()
                    begin
                        PAGE.RunModal(PAGE::"Item Attribute Value Editor", Rec);
                        CurrPage.SaveRecord();
                        CurrPage.ItemAttributesFactBox.PAGE.LoadItemAttributesData(Rec."No.");
                    end;
                }
                action(FilterByAttributes)
                {
                    AccessByPermission = TableData "Item Attribute" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Filter by Attributes';
                    Image = EditFilter;
                    Promoted = true;
                    PromotedCategory = Category10;
                    PromotedOnly = true;
                    ToolTip = 'Find items that match specific attributes. To make sure you include recent changes made by other users, clear the filter and then reset it.';

                    trigger OnAction()
                    var
                        ItemAttributeManagement: Codeunit "Item Attribute Management";
                        TypeHelper: Codeunit "Type Helper";
                        CloseAction: Action;
                        FilterText: Text;
                        FilterPageID: Integer;
                        ParameterCount: Integer;
                    begin
                        FilterPageID := PAGE::"Filter Items by Attribute";
                        if ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::Phone then
                            FilterPageID := PAGE::"Filter Items by Att. Phone";

                        CloseAction := PAGE.RunModal(FilterPageID, TempFilterItemAttributesBuffer);
                        if (ClientTypeManagement.GetCurrentClientType() <> CLIENTTYPE::Phone) and (CloseAction <> ACTION::LookupOK) then
                            exit;

                        if TempFilterItemAttributesBuffer.IsEmpty() then begin
                            ClearAttributesFilter();
                            exit;
                        end;

                        ItemAttributeManagement.FindItemsByAttributes(TempFilterItemAttributesBuffer, TempItemFilteredFromAttributes);
                        FilterText := ItemAttributeManagement.GetItemNoFilterText(TempItemFilteredFromAttributes, ParameterCount);

                        if ParameterCount < TypeHelper.GetMaxNumberOfParametersInSQLQuery() - 100 then begin
                            Rec.FilterGroup(0);
                            Rec.MarkedOnly(false);
                            Rec.SetFilter("No.", FilterText);
                        end else begin
                            RunOnTempRec := true;
                            Rec.ClearMarks();
                            Rec.Reset();
                        end;
                    end;
                }
                action(ClearAttributes)
                {
                    AccessByPermission = TableData "Item Attribute" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Clear Attributes Filter';
                    Image = RemoveFilterLines;
                    Promoted = true;
                    PromotedCategory = Category10;
                    PromotedOnly = true;
                    ToolTip = 'Remove the filter for specific item attributes.';

                    trigger OnAction()
                    begin
                        ClearAttributesFilter();
                        TempItemFilteredFromAttributes.Reset();
                        TempItemFilteredFromAttributes.DeleteAll();
                        RunOnTempRec := false;

                        RestoreTempItemFilteredFromAttributes();
                    end;
                }
                action("Va&riants")
                {
                    ApplicationArea = Planning;
                    Caption = 'Va&riants';
                    Image = ItemVariant;
                    RunObject = Page "Item Variants";
                    RunPageLink = "Item No." = FIELD("No.");
                    ToolTip = 'View how the inventory level of an item will develop over time according to the variant that you select.';
                }
                action("Substituti&ons")
                {
                    ApplicationArea = Suite;
                    Caption = 'Substituti&ons';
                    Image = ItemSubstitution;
                    RunObject = Page "Item Substitution Entry";
                    RunPageLink = Type = CONST(Item),
                                  "No." = FIELD("No.");
                    ToolTip = 'View substitute items that are set up to be sold instead of the item.';
                }
                action(Identifiers)
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Identifiers';
                    Image = BarCode;
                    RunObject = Page "Item Identifiers";
                    RunPageLink = "Item No." = FIELD("No.");
                    RunPageView = SORTING("Item No.", "Variant Code", "Unit of Measure Code");
                    ToolTip = 'View a unique identifier for each item that you want warehouse employees to keep track of within the warehouse when using handheld devices. The item identifier can include the item number, the variant code and the unit of measure.';
                }
                action("Cross Re&ferences")
                {
                    ApplicationArea = Advanced;
                    Caption = 'Cross Re&ferences';
                    Image = Change;
                    Promoted = true;
                    PromotedCategory = Category4;
                    PromotedOnly = true;
                    // >> Upgrade
                    //RunObject = Page "Item Cross Reference Entries";
                    RunObject = Page "Item Reference Entries";
                    // << Upgrade
                    RunPageLink = "Item No." = FIELD("No.");
                    Scope = Repeater;
                    ToolTip = 'Set up a customer''s or vendor''s own identification of the selected item. Cross-references to the customer''s item number means that the item number is automatically shown on sales documents instead of the number that you use.';
                }
                action("E&xtended Texts")
                {
                    ApplicationArea = Advanced;
                    Caption = 'E&xtended Texts';
                    Image = Text;
                    RunObject = Page "Extended Text List";
                    RunPageLink = "Table Name" = CONST(Item),
                                  "No." = FIELD("No.");
                    RunPageView = SORTING("Table Name", "No.", "Language Code", "All Language Codes", "Starting Date", "Ending Date");
                    Scope = Repeater;
                    ToolTip = 'Select or set up additional text for the description of the item. Extended text can be inserted under the Description field on document lines for the item.';
                }
                action(Translations)
                {
                    ApplicationArea = Advanced;
                    Caption = 'Translations';
                    Image = Translations;
                    Promoted = true;
                    PromotedCategory = Category4;
                    RunObject = Page "Item Translations";
                    RunPageLink = "Item No." = FIELD("No."),
                                  "Variant Code" = CONST('');
                    Scope = Repeater;
                    ToolTip = 'Set up translated item descriptions for the selected item. Translated item descriptions are automatically inserted on documents according to the language code.';
                }
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action(DimensionsSingle)
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = CONST(27),
                                      "No." = FIELD("No.");
                        Scope = Repeater;
                        ShortCutKey = 'Shift+Ctrl+D';
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                    }
                    action(DimensionsMultiple)
                    {
                        AccessByPermission = TableData Dimension = R;
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-&Multiple';
                        Image = DimensionSets;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';

                        trigger OnAction()
                        var
                            Item: Record Item;
                            DefaultDimMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(Item);
                            DefaultDimMultiple.SetMultiRecord(Item, Rec.FieldNo("No."));
                            DefaultDimMultiple.RunModal();
                        end;
                    }
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                group("E&ntries")
                {
                    Caption = 'E&ntries';
                    Image = Entries;
                    action("Ledger E&ntries")
                    {
                        ApplicationArea = Advanced;
                        Caption = 'Ledger E&ntries';
                        Image = ItemLedger;
                        Promoted = true;
                        PromotedCategory = Category4;
                        Scope = Repeater;
                        ShortCutKey = 'Ctrl+F7';
                        ToolTip = 'View the history of transactions that have been posted for the selected record.';

                        trigger OnAction()
                        begin
                            GXL_DrilldownItemLedger();
                        end;
                    }
                    action("&Phys. Inventory Ledger Entries")
                    {
                        ApplicationArea = Warehouse;
                        Caption = '&Phys. Inventory Ledger Entries';
                        Image = PhysicalInventoryLedger;
                        Promoted = true;
                        PromotedCategory = Category4;
                        Scope = Repeater;
                        ToolTip = 'View how many units of the item you had in stock at the last physical count.';

                        trigger OnAction()
                        var
                            PhysLedgEntry: Record "Phys. Inventory Ledger Entry";
                        begin
                            PhysLedgEntry.Reset();
                            PhysLedgEntry.SetCurrentKey("Item No.", "Variant Code", "Location Code", "Posting Date");
                            PhysLedgEntry.SetRange("Item No.", Rec."No.");
                            if Rec.GetFilter("Location Filter") <> '' then begin
                                PhysLedgEntry.FilterGroup(2);
                                PhysLedgEntry.SetFilter("Location Code", Rec.GetFilter("Location Filter"));
                                PhysLedgEntry.FilterGroup(0);
                            end;
                            Page.RunModal(0, PhysLedgEntry);
                        end;
                    }
                    action("&Value Entries")
                    {
                        ApplicationArea = Advanced;
                        Caption = '&Value Entries';
                        Image = ValueLedger;
                        ToolTip = 'View the history of posted amounts that affect the value of the item. Value entries are created for every transaction with the item.';

                        trigger OnAction()
                        var
                            ValueEntry: Record "Value Entry";
                        begin
                            ValueEntry.Reset();
                            ValueEntry.SetCurrentKey("Item No.", "Valuation Date", "Location Code", "Variant Code");
                            ValueEntry.SetRange("Item No.", Rec."No.");
                            if Rec.GetFilter("Location Filter") <> '' then begin
                                ValueEntry.FilterGroup(2);
                                ValueEntry.SetFilter("Location Code", Rec.GetFilter("Location Filter"));
                                ValueEntry.FilterGroup(0);
                            end;
                            page.RunModal(0, ValueEntry);
                        end;
                    }
                }
            }
            action("Requisition Worksheet")
            {
                ApplicationArea = Planning;
                Caption = 'Requisition Worksheet';
                Image = Worksheet;
                RunObject = Page "Req. Worksheet";
                ToolTip = 'Calculate a supply plan to fulfill item demand with purchases or transfers.';
            }
            group(Display)
            {
                Caption = 'Display';
                action(ReportFactBoxVisibility)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Show/Hide Power BI Reports';
                    Image = "Report";
                    ToolTip = 'Select if the Power BI FactBox is visible or not.';

                    trigger OnAction()
                    begin
                        // save visibility value into the table
                        CurrPage."Power BI Report FactBox".PAGE.SetFactBoxVisibility(PowerBIVisible);
                    end;
                }
            }
        }
    }


    trigger OnAfterGetCurrRecord()
    var
        CRMCouplingManagement: Codeunit "CRM Coupling Management";
        // >> Upgrade
        //     ObsoleteReason = 'Microsoft Social Engagement has been discontinued.';
        // ObsoleteTag = '20.0';
        //SocialListeningMgt: Codeunit "Social Listening Management";
        // << Upgrade
        WorkflowWebhookManagement: Codeunit "Workflow Webhook Management";
    begin
        LimitUserAccess();
        // >> Upgrade
        // if SocialListeningSetupVisible then
        //     SocialListeningMgt.GetItemFactboxVisibility(Rec, SocialListeningSetupVisible, SocialListeningVisible);
        // << Upgrade
        if CRMIntegrationEnabled then
            CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(Rec.RecordId);

        OpenApprovalEntriesExist := ApprovalsMgmt.HasOpenApprovalEntries(Rec.RecordId);

        CanCancelApprovalForRecord := ApprovalsMgmt.CanCancelApprovalForRecord(Rec.RecordId);
        CurrPage.ItemAttributesFactBox.PAGE.LoadItemAttributesData(Rec."No.");

        WorkflowWebhookManagement.GetCanRequestAndCanCancel(Rec.RecordId, CanRequestApprovalForFlow, CanCancelApprovalForFlow);

        SetWorkflowManagementEnabledState();

        // Contextual Power BI FactBox: send data to filter the report in the FactBox
        CurrPage."Power BI Report FactBox".PAGE.SetCurrentListSelection(Rec."No.", false, PowerBIVisible);
    end;

    trigger OnAfterGetRecord()
    begin
        LimitUserAccess();
        EnableControls();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    var
        Found: Boolean;
    begin
        if RunOnTempRec then begin
            TempItemFilteredFromAttributes.Copy(Rec);
            Found := TempItemFilteredFromAttributes.Find(Which);
            if Found then
                Rec := TempItemFilteredFromAttributes;
            exit(Found);
        end;
        exit(Rec.Find(Which));
    end;

    trigger OnInit()
    begin
        CurrPage."Power BI Report FactBox".PAGE.InitFactBox(CurrPage.ObjectId(false), CurrPage.Caption, PowerBIVisible);
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        ResultSteps: Integer;
    begin
        if RunOnTempRec then begin
            TempItemFilteredFromAttributes.Copy(Rec);
            ResultSteps := TempItemFilteredFromAttributes.Next(Steps);
            if ResultSteps <> 0 then
                Rec := TempItemFilteredFromAttributes;
            exit(ResultSteps);
        end;
        exit(Rec.Next(Steps));
    end;

    trigger OnOpenPage()
    var
        //SocialListeningSetup: Record "Social Listening Setup"; // >> Upgrade <<
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
    begin
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled();
        //SocialListeningSetupVisible := SocialListeningSetup.Get() and SocialListeningSetup."Show on Customers" and SocialListeningSetup."Accept License Agreement" and (SocialListeningSetup."Solution ID" <> '');
        IsFoundationEnabled := ApplicationAreaMgmtFacade.IsFoundationEnabled();
        SetWorkflowManagementEnabledState();
        IsOnPhone := ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::Phone;

        if not RetailUser.Get(UserId()) then
            Clear(RetailUser);
        LimitUserAccess();
    end;

    var
        TempFilterItemAttributesBuffer: Record "Filter Item Attributes Buffer" temporary;
        TempItemFilteredFromAttributes: Record Item temporary;
        TempItemFilteredFromPickItem: Record Item temporary;
        RetailUser: Record "LSC Retail User";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        ApprovalsMgmt: Codeunit "Approvals Mgmt.";
        ClientTypeManagement: Codeunit "Client Type Management";
        IsFoundationEnabled: Boolean;
        [InDataSet]
        SocialListeningSetupVisible: Boolean;
        [InDataSet]
        SocialListeningVisible: Boolean;
        CRMIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
        OpenApprovalEntriesExist: Boolean;
        EnabledApprovalWorkflowsExist: Boolean;
        CanCancelApprovalForRecord: Boolean;
        IsOnPhone: Boolean;
        RunOnTempRec: Boolean;
        EventFilter: Text;
        PowerBIVisible: Boolean;
        CanRequestApprovalForFlow: Boolean;
        CanCancelApprovalForFlow: Boolean;
        [InDataSet]
        IsNonInventoriable: Boolean;
        [InDataSet]
        IsInventoriable: Boolean;
        RunOnPickItem: Boolean;


    local procedure EnableControls()
    begin
        IsNonInventoriable := Rec.IsNonInventoriableType();
        IsInventoriable := Rec.IsInventoriableType();
    end;

    local procedure SetWorkflowManagementEnabledState()
    var
        WorkflowManagement: Codeunit "Workflow Management";
        WorkflowEventHandling: Codeunit "Workflow Event Handling";
    begin
        EventFilter := WorkflowEventHandling.RunWorkflowOnSendItemForApprovalCode() + '|' +
          WorkflowEventHandling.RunWorkflowOnItemChangedCode();

        EnabledApprovalWorkflowsExist := WorkflowManagement.EnabledWorkflowExist(DATABASE::Item, EventFilter);
    end;

    local procedure ClearAttributesFilter()
    begin
        Rec.ClearMarks();
        Rec.MarkedOnly(false);
        TempFilterItemAttributesBuffer.Reset();
        TempFilterItemAttributesBuffer.DeleteAll();
        Rec.FilterGroup(0);
        Rec.SetRange("No.");
    end;

    procedure SetTempFilteredItemRec(var Item: Record Item)
    begin
        TempItemFilteredFromAttributes.Reset();
        TempItemFilteredFromAttributes.DeleteAll();

        TempItemFilteredFromPickItem.Reset();
        TempItemFilteredFromPickItem.DeleteAll();

        RunOnTempRec := true;
        RunOnPickItem := true;

        if Item.FindSet() then
            repeat
                TempItemFilteredFromAttributes := Item;
                TempItemFilteredFromAttributes.Insert();
                TempItemFilteredFromPickItem := Item;
                TempItemFilteredFromPickItem.Insert();
            until Item.Next() = 0;
    end;

    local procedure RestoreTempItemFilteredFromAttributes()
    begin
        if not RunOnPickItem then
            exit;

        TempItemFilteredFromAttributes.Reset();
        TempItemFilteredFromAttributes.DeleteAll();
        RunOnTempRec := true;

        if TempItemFilteredFromPickItem.FindSet() then
            repeat
                TempItemFilteredFromAttributes := TempItemFilteredFromPickItem;
                TempItemFilteredFromAttributes.Insert();
            until TempItemFilteredFromPickItem.Next() = 0;
    end;

    local procedure LimitUserAccess()
    begin
        if RetailUser."Store No." <> '' then begin
            Rec.SetFilter("LSC Store Filter", RetailUser."Store No.");
            Rec.SetFilter("Location Filter", RetailUser."Store No.");
        end;
        Rec.SetFilter(Inventory, '<0');
    end;

    local procedure GXL_DrilldownItemLedger()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
    begin
        ItemLedgEntry.Reset();
        if Rec.GetFilter("Location Filter") <> '' then begin
            ItemLedgEntry.SetCurrentKey("Item No.", "Location Code", "Posting Date");
            ItemLedgEntry.SetRange("Item No.", Rec."No.");
            ItemLedgEntry.FilterGroup(2);
            ItemLedgEntry.SetFilter("Location Code", Rec.GetFilter("Location Filter"));
            ItemLedgEntry.FilterGroup(0);
            ItemLedgEntry.SetAscending("Posting Date", false);
        end else begin
            ItemLedgEntry.SetCurrentKey("Item No.");
            ItemLedgEntry.SetRange("Item No.", Rec."No.");
            ItemLedgEntry.SetAscending("Item No.", false);
        end;
        Page.RunModal(page::"GXL Item Ledger Entries", ItemLedgEntry);
    end;
}

