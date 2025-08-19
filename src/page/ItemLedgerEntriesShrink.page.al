/// <summary>
/// PS-2400 - New page created for shrinkage report
/// source table is temporary
/// </summary>
page 50046 "GXL ItemLedgerEntries-Shrink"
{
    AdditionalSearchTerms = 'inventory transactions';
    Caption = 'Item Ledger Entries';
    DataCaptionExpression = GetCaption();
    DataCaptionFields = "Item No.";
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Entry';
    SourceTable = "Item Ledger Entry";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    UsageCategory = None;
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the posting date for the entry.';
                }
                field("Entry Type"; Rec."Entry Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies which type of transaction that the entry is created from.';
                }
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies what type of document was posted to create the item ledger entry.';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the document number on the entry. The document is the voucher that the entry was based on, for example, a receipt.';
                }
                field("Document Line No."; Rec."Document Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the line on the posted document that corresponds to the item ledger entry.';
                    Visible = false;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the item in the entry.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the entry.';
                }
                field("Return Reason Code"; Rec."Return Reason Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the code explaining why the item was returned.';
                    Visible = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = false;
                }
                field("Expiration Date"; Rec."Expiration Date")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the last date that the item on the line can be used.';
                    Visible = false;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies a serial number if the posted item carries such a number.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        ItemTrackingManagement: Codeunit "Item Tracking Management";
                        // >> Upgrade
                        TrackingType: Enum "Item Tracking Type";
                    // << Upgrade
                    begin
                        // ItemTrackingManagement.LookupLotSerialNoInfo(Rec."Item No.", Rec."Variant Code", 0, Rec."Serial No.");
                        ItemTrackingManagement.LookupTrackingNoInfo(Rec."Item No.", Rec."Variant Code", TrackingType::"serial No.", Rec."Serial No.");
                    end;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies a lot number if the posted item carries such a number.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        ItemTrackingManagement: Codeunit "Item Tracking Management";
                        // >> Upgrade
                        TrackingType: Enum "Item Tracking Type";
                    // << Upgrade
                    begin
                        //ItemTrackingManagement.LookupLotSerialNoInfo(Rec."Item No.", Rec."Variant Code", 1, Rec."Lot No.");
                        ItemTrackingManagement.LookupTrackingNoInfo(Rec."Item No.", Rec."Variant Code", TrackingType::"lot No.", Rec."Lot No.");
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies the code for the location that the entry is linked to.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of units of the item in the item entry.';
                }
                field("Invoiced Quantity"; Rec."Invoiced Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies how many units of the item on the line have been invoiced.';
                    Visible = true;
                }
                field("Remaining Quantity"; Rec."Remaining Quantity")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity in the Quantity field that remains to be processed.';
                    Visible = true;
                }
                field("Shipped Qty. Not Returned"; Rec."Shipped Qty. Not Returned")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the quantity for this item ledger entry that was shipped and has not yet been returned.';
                    Visible = false;
                }
                field("Reserved Quantity"; Rec."Reserved Quantity")
                {
                    ApplicationArea = Reservation;
                    ToolTip = 'Specifies how many units of the item on the line have been reserved.';
                    Visible = false;
                }
                field("Qty. per Unit of Measure"; Rec."Qty. per Unit of Measure")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the quantity per item unit of measure.';
                    Visible = false;
                }
                field("Sales Amount (Expected)"; Rec."Sales Amount (Expected)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the expected sales amount, in LCY.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Sales Amount (Actual)"; Rec."Sales Amount (Actual)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the sales amount, in LCY.';
                    DrillDown = false;
                }
                field("Cost Amount (Expected)"; Rec."Cost Amount (Expected)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the expected cost, in LCY, of the quantity posting.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Cost Amount (Actual)"; Rec."Cost Amount (Actual)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the adjusted cost, in LCY, of the quantity posting.';
                    DrillDown = false;
                }
                field("Cost Amount (Non-Invtbl.)"; Rec."Cost Amount (Non-Invtbl.)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the adjusted non-inventoriable cost, that is an item charge assigned to an outbound entry.';
                    DrillDown = false;
                }
                field("Cost Amount (Expected) (ACY)"; Rec."Cost Amount (Expected) (ACY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the expected cost, in ACY, of the quantity posting.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Cost Amount (Actual) (ACY)"; Rec."Cost Amount (Actual) (ACY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the adjusted cost of the entry, in the additional reporting currency.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Cost Amount (Non-Invtbl.)(ACY)"; Rec."Cost Amount (Non-Invtbl.)(ACY)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the adjusted non-inventoriable cost, that is, an item charge assigned to an outbound entry in the additional reporting currency.';
                    Visible = false;
                    DrillDown = false;
                }
                field("Completely Invoiced"; Rec."Completely Invoiced")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the entry has been fully invoiced or if more posted invoices are expected. Only completely invoiced entries can be revalued.';
                    Visible = false;
                }
                field(Open; Rec.Open)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the entry has been fully applied to.';
                }
                field("Drop Shipment"; Rec."Drop Shipment")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if your vendor ships the items directly to your customer.';
                    Visible = false;
                }
                field("Assemble to Order"; Rec."Assemble to Order")
                {
                    ApplicationArea = Assembly;
                    ToolTip = 'Specifies if the posting represents an assemble-to-order sale.';
                    Visible = false;
                }
                field("Applied Entry to Adjust"; Rec."Applied Entry to Adjust")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether there is one or more applied entries, which need to be adjusted.';
                    Visible = false;
                }
                field("Order Type"; Rec."Order Type")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies which type of order that the entry was created in.';
                }
                field("Order No."; Rec."Order No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the order that created the entry.';
                    Visible = false;
                }
                field("Order Line No."; Rec."Order Line No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the line number of the order that created the entry.';
                    Visible = false;
                }
                field("Prod. Order Comp. Line No."; Rec."Prod. Order Comp. Line No.")
                {
                    ApplicationArea = Manufacturing;
                    ToolTip = 'Specifies the line number of the production order component.';
                    Visible = false;
                }
                //PS-2308+
                field("GXL MIM User ID"; Rec."GXL MIM User ID")
                {
                    ApplicationArea = All;
                }
                //PS-2308-
                //PS-2624 +
                field(ReasonDesc; ReasonDesc)
                {
                    ApplicationArea = All;
                    Caption = 'Reason Code';
                    Editable = false;
                }
                //PS-2624 -
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the number of the entry, as assigned from the specified number series when the entry was created.';
                }
                field("Job No."; Rec."Job No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the number of the related job.';
                    Visible = false;
                }
                field("Job Task No."; Rec."Job Task No.")
                {
                    ApplicationArea = Jobs;
                    ToolTip = 'Specifies the number of the related job task.';
                    Visible = false;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies a reference to a combination of dimension values. The actual values are stored in the Dimension Set Entry table.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("Ent&ry")
            {
                Caption = 'Ent&ry';
                Image = Entry;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    Promoted = true;
                    PromotedCategory = Category4;
                    ShortCutKey = 'Shift+Ctrl+D';
                    ToolTip = 'View or edit dimensions, such as area, project, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                    end;
                }
                action(SetDimensionFilter)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Set Dimension Filter';
                    Ellipsis = true;
                    Image = "Filter";
                    Promoted = true;
                    PromotedCategory = Category4;
                    ToolTip = 'Limit the entries according to the dimension filters that you specify. NOTE: If you use a high number of dimension combinations, this function may not work and can result in a message that the SQL server only supports a maximum of 2100 parameters.';

                    trigger OnAction()
                    begin
                        Rec.SetFilter("Dimension Set ID", DimensionSetIDFilter.LookupFilter());
                    end;
                }
                action("&Value Entries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = '&Value Entries';
                    Image = ValueLedger;
                    Promoted = true;
                    PromotedCategory = Category4;
                    //PS-2155+
                    // RunObject = Page "Value Entries";
                    // RunPageLink = "Item Ledger Entry No." = FIELD("Entry No.");
                    // RunPageView = SORTING("Item Ledger Entry No.");
                    //PS-2155-
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of posted amounts that affect the value of the item. Value entries are created for every transaction with the item.';

                    trigger OnAction()
                    begin
                        //PS-2155+
                        ValueEntryOnDrilldown(Rec."Entry No.");
                        //PS-2155-
                    end;
                }
            }
            group("&Application")
            {
                Caption = '&Application';
                Image = Apply;
                action("Applied E&ntries")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Applied E&ntries';
                    Image = Approve;
                    ToolTip = 'View the ledger entries that have been applied to this record.';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Show Applied Entries", Rec);
                    end;
                }
                action("Reservation Entries")
                {
                    AccessByPermission = TableData Item = R;
                    ApplicationArea = Reservation;
                    Caption = 'Reservation Entries';
                    Image = ReservationLedger;
                    ToolTip = 'View the entries for every reservation that is made, either manually or automatically.';

                    trigger OnAction()
                    begin
                        Rec.ShowReservationEntries(true);
                    end;
                }
                action("Application Worksheet")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Application Worksheet';
                    Image = ApplicationWorksheet;
                    ToolTip = 'View item applications that are automatically created between item ledger entries during item transactions.';

                    trigger OnAction()
                    var
                        Worksheet: Page "Application Worksheet";
                    begin
                        Clear(Worksheet);
                        Worksheet.SetRecordToShow(Rec);
                        Worksheet.Run();
                    end;
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Order &Tracking")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Order &Tracking';
                    Image = OrderTracking;
                    ToolTip = 'Tracks the connection of a supply to its corresponding demand. This can help you find the original demand that created a specific production order or purchase order.';

                    trigger OnAction()
                    var
                        TrackingForm: Page "Order Tracking";
                    begin
                        TrackingForm.SetItemLedgEntry(Rec);
                        TrackingForm.RunModal();
                    end;
                }
            }
            //PS-2155+            
            // action("&Navigate")
            // {
            //     ApplicationArea = Basic, Suite;
            //     Caption = '&Navigate';
            //     Image = Navigate;
            //     Promoted = true;
            //     PromotedCategory = Category4;
            //     ToolTip = 'Find all entries and documents that exist for the document number and posting date on the selected entry or document.';

            //     trigger OnAction()
            //     begin
            //         Navigate.SetDoc("Posting Date", "Document No.");
            //         Navigate.Run();
            //     end;
            // }
            //PS-2155-
        }
    }

    trigger OnOpenPage()
    begin
        LimitUserAccess();
        if Rec.GetFilters <> '' then
            if Rec.FindFirst() then;

    end;

    trigger OnAfterGetRecord()
    begin
        GetReasonCode(); //PS-2624 +
    end;

    var
        DimensionSetIDFilter: Page "Dimension Set ID Filter";
        LocationFilter: Text;
        ReasonDict: Dictionary of [Text, Text];
        ReasonDesc: Text;

    local procedure GetCaption(): Text
    var
        GLSetup: Record "General Ledger Setup";
        ObjTransl: Record "Object Translation";
        Item: Record Item;
        ProdOrder: Record "Production Order";
        Cust: Record Customer;
        Vend: Record Vendor;
        Dimension: Record Dimension;
        DimValue: Record "Dimension Value";
        SourceTableName: Text;
        SourceFilter: Text;
        DescriptionText: Text[100];
    begin
        Rec.Description := '';

        case true of
            Rec.GetFilter("Item No.") <> '':
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 27);
                    SourceFilter := Rec.GetFilter("Item No.");
                    if MaxStrLen(Item."No.") >= StrLen(SourceFilter) then
                        if Item.Get(SourceFilter) then
                            DescriptionText := Item.Description;
                end;
            (Rec.GetFilter("Order No.") <> '') and (Rec."Order Type" = Rec."Order Type"::Production):
                begin
                    SourceTableName := ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 5405);
                    SourceFilter := Rec.GetFilter("Order No.");
                    if MaxStrLen(ProdOrder."No.") >= StrLen(SourceFilter) then
                        if ProdOrder.Get(ProdOrder.Status::Released, SourceFilter) or
                           ProdOrder.Get(ProdOrder.Status::Finished, SourceFilter)
                        then begin
                            SourceTableName := StrSubstNo('%1 %2', ProdOrder.Status, SourceTableName);
                            DescriptionText := ProdOrder.Description;
                        end;
                end;
            Rec.GetFilter("Source No.") <> '':
                case Rec."Source Type" of
                    Rec."Source Type"::Customer:
                        begin
                            SourceTableName :=
                              ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 18);
                            SourceFilter := Rec.GetFilter("Source No.");
                            if MaxStrLen(Cust."No.") >= StrLen(SourceFilter) then
                                if Cust.Get(SourceFilter) then
                                    DescriptionText := Cust.Name;
                        end;
                    Rec."Source Type"::Vendor:
                        begin
                            SourceTableName :=
                              ObjTransl.TranslateObject(ObjTransl."Object Type"::Table, 23);
                            SourceFilter := Rec.GetFilter("Source No.");
                            if MaxStrLen(Vend."No.") >= StrLen(SourceFilter) then
                                if Vend.Get(SourceFilter) then
                                    DescriptionText := Vend.Name;
                        end;
                end;
            Rec.GetFilter("Global Dimension 1 Code") <> '':
                begin
                    GLSetup.Get();
                    Dimension.Code := GLSetup."Global Dimension 1 Code";
                    SourceFilter := Rec.GetFilter("Global Dimension 1 Code");
                    SourceTableName := Dimension.GetMLName(GlobalLanguage);
                    if MaxStrLen(DimValue.Code) >= StrLen(SourceFilter) then
                        if DimValue.Get(GLSetup."Global Dimension 1 Code", SourceFilter) then
                            DescriptionText := DimValue.Name;
                end;
            Rec.GetFilter("Global Dimension 2 Code") <> '':
                begin
                    GLSetup.Get();
                    Dimension.Code := GLSetup."Global Dimension 2 Code";
                    SourceFilter := Rec.GetFilter("Global Dimension 2 Code");
                    SourceTableName := Dimension.GetMLName(GlobalLanguage);
                    if MaxStrLen(DimValue.Code) >= StrLen(SourceFilter) then
                        if DimValue.Get(GLSetup."Global Dimension 2 Code", SourceFilter) then
                            DescriptionText := DimValue.Name;
                end;
            Rec.GetFilter("Document Type") <> '':
                begin
                    SourceTableName := Rec.GetFilter("Document Type");
                    SourceFilter := Rec.GetFilter("Document No.");
                    DescriptionText := Rec.GetFilter("Document Line No.");
                end;
        end;
        exit(StrSubstNo('%1 %2 %3', SourceTableName, SourceFilter, DescriptionText));
    end;

    local procedure LimitUserAccess()
    var
        RetailUser: Record "LSC Retail User";
        Store: Record "LSC Store";
    begin
        LocationFilter := '';
        if not RetailUser.Get(UserId()) then
            Clear(RetailUser);
        if RetailUser."Store No." <> '' then begin
            Rec.SetCurrentKey("Location Code", "Item No.", "Posting Date");
            Rec.FilterGroup(2);
            if RetailUser."Location Code" <> '' then begin
                Rec.SetRange("Location Code", RetailUser."Location Code");
                LocationFilter := RetailUser."Location Code";
            end else begin
                if Store.Get(RetailUser."Store No.") then begin
                    Rec.SetRange("Location Code", Store."Location Code");
                    LocationFilter := Store."Location Code";
                end else begin
                    Rec.SetRange("Location Code", RetailUser."Store No.");
                    LocationFilter := RetailUser."Store No.";
                end;
            end;
            Rec.FilterGroup(0);
        end;
    end;

    //PS-2155+
    local procedure ValueEntryOnDrilldown(ItemLedgerEntryNo: Integer)
    var
        ValueEntry: Record "Value Entry";
    begin
        if ItemLedgerEntryNo <> 0 then begin
            ValueEntry.SetCurrentKey("Item Ledger Entry No.");
            ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgerEntryNo);
        end else
            ValueEntry.SetCurrentKey("Location Code");
        if LocationFilter <> '' then begin
            ValueEntry.FilterGroup(2);
            ValueEntry.SetFilter("Location Code", LocationFilter);
            ValueEntry.FilterGroup(0);
        end;
        Page.RunModal(0, ValueEntry);
    end;
    //PS-2155-

    procedure SetItemLedgerEntry(var TempItemLedgEntry: Record "Item Ledger Entry" temporary)
    begin
        Rec.Copy(TempItemLedgEntry, true);
    end;

    //PS-2624 +
    local procedure GetReasonCode()
    var
        ValueEntry: Record "Value Entry";
        ReasonCodeRec: Record "Reason Code";
        ReasonCode: Code[10];
    begin
        Clear(ReasonCode);
        ValueEntry.SetCurrentKey("Item Ledger Entry No.");
        ValueEntry.SetRange("Item Ledger Entry No.", Rec."Entry No.");
        if ValueEntry.FindFirst() then
            ReasonCode := ValueEntry."Reason Code";
        if ReasonCode = '' then begin
            ReasonDesc := '';
            exit;
        end;

        if not ReasonDict.ContainsKey(ReasonCode) then begin
            if ReasonCodeRec.Get(ReasonCode) then begin
                ReasonDict.Add(ReasonCode, ReasonCodeRec.Description);
                ReasonDesc := ReasonCodeRec.Description;
            end else begin
                ReasonDict.Add(ReasonCode, ReasonCode);
                ReasonDesc := ReasonCode;
            end;
        end else
            ReasonDict.Get(ReasonCode, ReasonDesc);
    end;
    //PS-2624 -

}

