/// <summary>
/// PS-2393: A summary page for committed stocktakes
/// </summary>
page 50031 "GXL Stocktake Summary"
{
    Caption = 'Stoctake Summary';
    PageType = Worksheet;
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;
    SourceTable = "GXL Stocktake Summary";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTableTemporary = true;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';
                field(StoreFilter; StoreFilter)
                {
                    Caption = 'Store Filter';
                    ApplicationArea = All;
                    TableRelation = "LSC Store";
                    Editable = StoreFilterEditable;

                    trigger OnValidate()
                    begin
                        SetStore(StoreFilter);
                    end;
                }
                field(DateFilter; DateFilter)
                {
                    Caption = 'Date Filter';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        SetPostingDate(DateFilter);
                    end;
                }
                field(DocNoFilter; DocNoFilter)
                {
                    Caption = 'Document No. Filter';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        SetDocNo(DocNoFilter);
                    end;
                }
                field(StocktakeNameFilter; StocktakeNameFilter)
                {
                    Caption = 'Stocktake Name Filter';
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        SetStocktakeName(StocktakeNameFilter);
                    end;
                }
                field(RefreshText; RefreshText)
                {
                    ApplicationArea = All;
                    Caption = 'Refresh Status';
                    Editable = false;
                }
                field(TotalQty; TotalQty)
                {
                    ApplicationArea = All;
                    Caption = 'Total Quantity';
                    Editable = false;
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        OnDrilldownPhysInvtLedgerEntry(1);
                    end;
                }
                field(TotalAmount; TotalAmount)
                {
                    ApplicationArea = All;
                    Caption = 'Total Amount';
                    Editable = false;
                    AutoFormatType = 1;

                    trigger OnDrillDown()
                    begin
                        OnDrilldownPhysInvtLedgerEntry(1);
                    end;
                }
                field(TotalStandardCost; TotalStandardCost)
                {
                    ApplicationArea = All;
                    Caption = 'Total Standard Cost';
                    Editable = false;
                    AutoFormatType = 1;

                    trigger OnDrillDown()
                    begin
                        OnDrilldownPhysInvtLedgerEntry(1);
                    end;
                }
            }
            repeater(GroupName)
            {
                Editable = false;
                field("Store No."; Rec."Store No.")
                {
                    ApplicationArea = All;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Stocktake Name"; Rec."Stocktake Name")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        OnDrilldownPhysInvtLedgerEntry(0);
                    end;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        OnDrilldownPhysInvtLedgerEntry(0);
                    end;
                }
                field("Standard Cost Amount"; Rec."Standard Cost Amount")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        OnDrilldownPhysInvtLedgerEntry(0);
                    end;
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Find")
            {
                ApplicationArea = All;
                Caption = 'Search';
                Image = Find;
                Promoted = true;
                PromotedIsBig = true;
                Enabled = SearchIsEnabled;
                PromotedCategory = Process;

                trigger OnAction();
                begin
                    FindRecords();
                end;
            }
        }
    }

    var
        RetailUser: Record "LSC Retail User";
        //>>upgrade
        //TextManagement: Codeunit TextManagement;
        TextManagement: Codeunit "Filter Tokens";
        //<<upgrade
        DateFilter: Text;
        StoreFilter: Text;
        DocNoFilter: Text;
        StocktakeNameFilter: Text;
        OldDateFilter: Text;
        OldStoreFilter: Text;
        OldDocNoFilter: Text;
        OldStocktakeNameFilter: Text;
        RefreshText: Text;
        [InDataSet]
        SearchIsEnabled: Boolean;
        [InDataSet]
        StoreFilterEditable: Boolean;
        EntryExists: Boolean;
        TotalQty: Decimal;
        TotalAmount: Decimal;
        TotalStandardCost: Decimal;

    trigger OnOpenPage()
    begin
        if not RetailUser.Get(UserId) then
            Clear(RetailUser);
        LimitUserAccess();
    end;

    local procedure LimitUserAccess()
    begin
        StoreFilterEditable := true;
        if RetailUser."Store No." <> '' then begin
            Rec.SetFilter("Store No.", RetailUser."Store No.");
            StoreFilter := Rec.GetFilter("Store No.");
            StoreFilterEditable := false;
        end;
    end;

    local procedure SetRefresh()
    begin
        RefreshText := 'Search is required';
    end;

    local procedure FiltersAreActive(): Boolean
    begin
        exit((DocNoFilter <> '') or (DateFilter <> '') or (StocktakeNameFilter <> ''));
    end;

    local procedure SetStore(StoreText: Text)
    begin
        Rec.SetFilter("Store No.", StoreText);
        StoreFilter := Rec.GetFilter("Store No.");
        if (UpperCase(OldStoreFilter) <> UpperCase(StoreFilter)) and FiltersAreActive() then begin
            SearchIsEnabled := true;
            SetRefresh();
        end;
        OldStoreFilter := StoreFilter;
    end;

    local procedure SetPostingDate(PostingDate: Text)
    begin
        TextManagement.MakeDateFilter(PostingDate);
        Rec.SetFilter("Posting Date", PostingDate);
        DateFilter := Rec.GetFilter("Posting Date");
        if OldDateFilter <> DateFilter then begin
            SearchIsEnabled := true;
            SetRefresh();
        end;
        OldDateFilter := DateFilter;
    end;

    local procedure SetDocNo(DocNo: Text)
    begin
        Rec.SetFilter("Document No.", DocNo);
        DocNoFilter := Rec.GetFilter("Document No.");
        if UpperCase(OldDocNoFilter) <> UpperCase(DocNoFilter) then begin
            SearchIsEnabled := true;
            SetRefresh();
        end;
        OldDateFilter := DocNoFilter;
    end;

    local procedure SetStocktakeName(StocktakeName: Text)
    begin
        Rec.SetFilter("Stocktake Name", '@' + StocktakeName);
        StocktakeNameFilter := StocktakeName;
        if UpperCase(OldStocktakeNameFilter) <> UpperCase(StocktakeNameFilter) then begin
            SearchIsEnabled := true;
            SetRefresh();
        end;
        OldStocktakeNameFilter := StocktakeNameFilter;
    end;

    local procedure FindRecords()
    var
        StocktakeSummaryQry: Query "GXL Stocktake Summary";
    begin
        TotalQty := 0;
        TotalAmount := 0;
        TotalStandardCost := 0;

        Rec.Reset();
        Rec.DeleteAll();
        Rec."Entry No." := 0;

        if DocNoFilter <> '' then
            StocktakeSummaryQry.SetFilter(DocumentNoFilter, UpperCase(DocNoFilter));
        if DateFilter <> '' then
            StocktakeSummaryQry.SetFilter(PostingDateFilter, DateFilter);
        if StoreFilter <> '' then
            StocktakeSummaryQry.SetFilter(LocationFilter, UpperCase(StoreFilter));
        if StocktakeNameFilter <> '' then begin
            if CopyStr(StocktakeNameFilter, 1, 1) = '@' then
                StocktakeSummaryQry.SetFilter(StocktakeNameFilter, StocktakeNameFilter)
            else
                StocktakeSummaryQry.SetFilter(StocktakeNameFilter, '@' + StocktakeNameFilter);
        end;
        StocktakeSummaryQry.Open();
        while StocktakeSummaryQry.Read() do begin
            Rec.Init();
            Rec."Entry No." := Rec."Entry No." + 1;
            Rec."Document No." := StocktakeSummaryQry.DocumentNo;
            Rec."Posting Date" := StocktakeSummaryQry.PostingDate;
            Rec."Store No." := StocktakeSummaryQry.LocationCode;
            Rec."Stocktake Name" := StocktakeSummaryQry.StocktakeName;
            Rec.Quantity := StocktakeSummaryQry.ItemLedgerQuantity;
            Rec.Amount := StocktakeSummaryQry.ItemLedgerAmount;
            Rec."Standard Cost Amount" := StocktakeSummaryQry.StandardCostAmount;
            Rec.Insert();

            TotalQty += StocktakeSummaryQry.ItemLedgerQuantity;
            TotalAmount += StocktakeSummaryQry.ItemLedgerAmount;
            TotalStandardCost += StocktakeSummaryQry.StandardCostAmount;
        end;
        StocktakeSummaryQry.Close();

        UpdatePageAfterFindRecords();
    end;

    local procedure UpdatePageAfterFindRecords()
    begin
        RefreshText := '';
        SearchIsEnabled := false;

        CurrPage.Update(false);
        EntryExists := Rec.FindFirst();
    end;

    local procedure OnDrilldownPhysInvtLedgerEntry(Method: Option "Record","Total")
    var
        PhysInvtLedgEntry: Record "Phys. Inventory Ledger Entry";
    begin
        case Method of
            Method::Record:
                begin
                    PhysInvtLedgEntry.SetCurrentKey("Document No.", "Posting Date");
                    PhysInvtLedgEntry.SetRange("Document No.", Rec."Document No.");
                    PhysInvtLedgEntry.SetRange("Posting Date", Rec."Posting Date");
                    PhysInvtLedgEntry.SetRange("GXL Stocktake Name", Rec."Stocktake Name");
                    if RetailUser."Store No." <> '' then begin
                        PhysInvtLedgEntry.FilterGroup(2);
                        PhysInvtLedgEntry.SetRange("Location Code", RetailUser."Store No.");
                        PhysInvtLedgEntry.FilterGroup(0);
                    end else
                        PhysInvtLedgEntry.SetRange("Location Code", Rec."Store No.");
                end;
            Method::Total:
                begin
                    if (DocNoFilter <> '') or (DateFilter <> '') then
                        PhysInvtLedgEntry.SetCurrentKey("Document No.", "Posting Date")
                    else
                        if (StocktakeNameFilter <> '') then
                            PhysInvtLedgEntry.SetCurrentKey("GXL Stocktake Name")
                        else
                            PhysInvtLedgEntry.SetCurrentKey("Location Code");

                    PhysInvtLedgEntry.SetFilter("Document No.", DocNoFilter);
                    PhysInvtLedgEntry.SetFilter("Posting Date", DateFilter);
                    PhysInvtLedgEntry.SetFilter("GXL Stocktake Name", '@' + StocktakeNameFilter);
                    if RetailUser."Store No." <> '' then begin
                        PhysInvtLedgEntry.FilterGroup(2);
                        PhysInvtLedgEntry.SetRange("Location Code", RetailUser."Store No.");
                        PhysInvtLedgEntry.FilterGroup(0);
                    end else
                        PhysInvtLedgEntry.SetFilter("Location Code", StoreFilter);
                end;
        end;
        Page.RunModal(0, PhysInvtLedgEntry);
    end;

}