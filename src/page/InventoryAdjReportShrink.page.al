/* Change Log
    PS-2400 New reports
*/
page 50033 "GXL InventoryAdj Report/Shrink"
{
    ApplicationArea = All;
    Caption = 'Inventory Adjustment Report/Shrink';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "GXL Sales/Invt Report Buffer";
    UsageCategory = ReportsAndAnalysis;
    RefreshOnActivate = true;
    SourceTableTemporary = true;
    ShowFilter = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ReportType; ReportType)
                {
                    ApplicationArea = All;
                    Caption = 'Group by';
                    OptionCaption = ',Transaction,Division,Category,Item,Staff,Reason Code';

                    trigger OnValidate()
                    begin
                        if ReportType = ReportType::" " then
                            ReportType := ReportType::Transaction;
                        if OldReportType <> ReportType then
                            FilterOnAfterValidate();
                        OldReportType := ReportType;
                    end;
                }
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Date Filter';

                    trigger OnValidate()
                    begin
                        // >>upgrade
                        //if ApplicationManagement.MakeDateFilter(DateFilter) = 0 then;
                        ApplicationManagement.MakeDateFilter(DateFilter);
                        //<<upgrade
                        Rec.SetFilter("Date Filter", DateFilter);
                        DateFilter := Rec.GetFilter("Date Filter");
                        FilterOnAfterValidate();
                    end;
                }
                field(StoreFilter; StoreFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Store Filter';
                    TableRelation = "LSC Store";
                    Editable = StoreFilterEditable;

                    trigger OnValidate()
                    begin
                        Rec.SetFilter("Store Filter", StoreFilter);
                        FilterOnAfterValidate();
                    end;
                }
                field(Refreshbox; RefreshText)
                {
                    ApplicationArea = All;
                    Caption = 'Refresh Status';
                    Editable = false;
                    Style = Attention;
                    StyleExpr = TRUE;
                }
                field(TotalQty; TotalQty)
                {
                    ApplicationArea = All;
                    Caption = 'Total Quantity';
                    DecimalPlaces = 0 : 5;
                    Editable = false;
                }
                field(TotalCost; TotalCost)
                {
                    ApplicationArea = All;
                    Caption = 'Total Cost';
                    AutoFormatType = 1;
                    Editable = false;
                }
            }
            repeater(Control1)
            {
                Editable = false;
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Visible = ReportType <> ReportType::Transaction;
                }
                field(Division; Rec.Division)
                {
                    ApplicationArea = All;
                    Visible = ReportType = ReportType::Transaction;
                }
                field("Item Category"; Rec."Item Category")
                {
                    ApplicationArea = All;
                    Visible = ReportType = ReportType::Transaction;
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    Visible = ReportType = ReportType::Transaction;
                }
                field("Item Description"; Rec."Item Description")
                {
                    ApplicationArea = All;
                    Visible = ReportType = ReportType::Transaction;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        OnDrilldownItemLedgerEntry();
                    end;
                }
                field("Cost Amount"; Rec."Cost Amount")
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        OnDrilldownItemLedgerEntry();
                    end;
                }
                field("Staff ID"; Rec."Staff ID")
                {
                    ApplicationArea = All;
                    Visible = ReportType = ReportType::Transaction;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    Visible = ReportType = ReportType::Transaction;
                }
                field("Date"; Rec.Date)
                {
                    ApplicationArea = All;
                    Visible = ReportType = ReportType::Transaction;
                }
            }
            field(PeriodType; PeriodType)
            {
                ApplicationArea = All;
                OptionCaption = 'Day,Week,Month,Quarter,Year';
                ShowCaption = false;
                ToolTip = 'Day';

                trigger OnValidate()
                begin
                    if PeriodType = PeriodType::Year then
                        YearPeriodTypeOnValidate();
                    if PeriodType = PeriodType::Quarter then
                        QuarterPeriodTypeOnValidate();
                    if PeriodType = PeriodType::Month then
                        MonthPeriodTypeOnValidate();
                    if PeriodType = PeriodType::Week then
                        WeekPeriodTypeOnValidate();
                    if PeriodType = PeriodType::Day then
                        DayPeriodTypeOnValidate();
                end;
            }
            group(AmountTypeGrp)
            {
                ShowCaption = false;

                field(AmountType; AmountType)
                {
                    ApplicationArea = All;
                    Caption = 'View as';
                    OptionCaption = 'Net Change,Balance at Date';
                    ToolTip = 'Net Change';

                    trigger OnValidate()
                    begin
                        if AmountType = AmountType::"Balance at Date" then
                            BalanceatDateAmountTypeOnValid();
                        if AmountType = AmountType::"Net Change" then
                            NetChangeAmountTypeOnValidate();
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Previous Period")
            {
                ApplicationArea = All;
                Caption = 'Previous Period';
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Previous Period';

                trigger OnAction()
                begin
                    FindPeriod('<=');
                end;
            }
            action("Next Period")
            {
                ApplicationArea = All;
                Caption = 'Next Period';
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Next Period';

                trigger OnAction()
                begin
                    FindPeriod('>=');
                end;
            }
            action(ItemAct)
            {
                ApplicationArea = All;
                Caption = 'Transactions/Summary';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CalcItem(Rec);
                end;
            }
            action(GroupByReasonAct)
            {
                ApplicationArea = All;
                Caption = 'By Reason Code';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    if OldReportType <> OldReportType::"Reason Code" then
                        FilterOnAfterValidate();
                    ReportType := ReportType::"Reason Code";
                    CalcItem(Rec);
                    OldReportType := ReportType;
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LimitUserAccess();
        DateFilter := Rec.GetFilter("Date Filter");
        StoreFilter := Rec.GetFilter("Store Filter");
        ItemCatFilter := Rec.GetFilter("Item Category Filter");
        ItemFilter := Rec.GetFilter("Item Filter");
    end;

    trigger OnInit()
    begin
        Rec."Entry No." := 0;
        Rec.Insert();
        SortOrder := true;
    end;


    trigger OnOpenPage()
    begin
        if not RetailUser.Get(UserId()) then
            Clear(RetailUser);
        LimitUserAccess();
        RetailSetup.Get();
        SourceCodeSetup.Get();

        FilterChange := true;
        RefreshText := RefreshTxt;

        ReportType := ReportType::Transaction;
        OldReportType := OldReportType::" ";
        TotalCost := 0;
        TotalQty := 0;
        ItemCounter := 0;

        TempDivision.Reset();
        TempDivision.DeleteAll();
        TempItemCat.Reset();
        TempItemCat.DeleteAll();
        TempItem.Reset();
        TempItem.DeleteAll();
        TempReason.Reset();
        TempReason.DeleteAll();

    end;

    var
        SourceCodeSetup: Record "Source Code Setup";
        RetailSetup: Record "LSC Retail Setup";
        Calendar: Record Date;
        RetailUser: Record "LSC Retail User";
        TempDivision: Record "LSC Division" temporary;
        TempItemCat: Record "Item Category" temporary;
        TempItem: Record Item temporary;
        TempReason: Record "Reason Code" temporary;
        //>>upgrades
        //ApplicationManagement: Codeunit TextManagement;
        ApplicationManagement: Codeunit "filter tokens";
        //<<upgrade
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        AmountType: Option "Net Change","Balance at Date";
        SortOrder: Boolean;
        FilterChange: Boolean;
        Window: Dialog;
        ItemCounter: Integer;
        TotalQty: Decimal;
        TotalCost: Decimal;
        DateFilter: Text[30];
        StoreFilter: Text[250];
        ItemCatFilter: Text[250];
        ItemFilter: Text;
        RefreshText: Text[30];
        SalesInvtReportBuffCurrentKey: Text;
        StoreFilterEditable: Boolean;
        ReportType: Option " ",Transaction,Division,Category,Item,Staff,"Reason Code";
        OldReportType: Option " ",Transaction,Division,Category,Item,Staff,"Reason Code";
        RefreshTxt: Label 'Refresh Needed';
        TotalRecTxt: Label 'Number of Records';
        CounterTxt: Label 'Counter';
        RcptTxt: Label 'Receipt ';
        NoDataErr: Label 'There is no data within the selected period';


    local procedure CalcItem(var SalesInvtReportBuff: Record "GXL Sales/Invt Report Buffer" temporary)
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        ValueEntry: Record "Value Entry";
        Item: Record Item;
        Division: Record "LSC Division";
        ItemCat: Record "Item Category";
        ReasonCode: Record "Reason Code";
        OldSalesInvtReportBuff: Record "GXL Sales/Invt Report Buffer";
        Counter: Integer;
        ToInclude: Boolean;
        ReportCode: Code[50];
        CodeDesc: text[100];
    begin
        OldSalesInvtReportBuff.Copy(SalesInvtReportBuff);
        if FilterChange then begin
            SalesInvtReportBuff.Reset();
            SalesInvtReportBuff.DeleteAll();
            ItemCounter := 0;
        end else begin
            if ItemCounter <> 0 then begin
                SalesInvtReportBuff.Reset();
                SalesInvtReportBuff.Find('-');
                exit;
            end;
        end;

        Window.Open(
          CounterTxt + '          ' + ' #1########\' +
          TotalRecTxt + ' #2########');

        SalesInvtReportBuff.Reset();
        SalesInvtReportBuff.SetFilter("Date Filter", OldSalesInvtReportBuff.GetFilter("Date Filter"));
        SalesInvtReportBuff.SetFilter("Store Filter", OldSalesInvtReportBuff.GetFilter("Store Filter"));
        SalesInvtReportBuff.SetFilter("Item Filter", OldSalesInvtReportBuff.GetFilter("Item Filter"));
        SalesInvtReportBuff.SetFilter("Item Category Filter", OldSalesInvtReportBuff.GetFilter("Item Category Filter"));
        OldSalesInvtReportBuff.Reset();
        OldSalesInvtReportBuff.Copy(SalesInvtReportBuff);

        ItemLedgEntry.Reset();
        if SalesInvtReportBuff.GetFilter("Store Filter") <> '' then
            ItemLedgEntry.SetCurrentKey("Location Code", "Item No.", "Posting Date")
        else
            ItemLedgEntry.SetCurrentKey("Item No.", "Location Code", "Posting Date");
        ItemLedgEntry.SetFilter("Location Code", SalesInvtReportBuff.GetFilter("Store Filter"));
        ItemLedgEntry.SetFilter("Item No.", SalesInvtReportBuff.GetFilter("Item Filter"));
        ItemLedgEntry.SetFilter("Posting Date", SalesInvtReportBuff.GetFilter("Date Filter"));
        ItemLedgEntry.SetFilter("Item Category Code", SalesInvtReportBuff.GetFilter("Item Category Filter"));
        ItemLedgEntry.SetFilter("Entry Type", '%1|%2', ItemLedgEntry."Entry Type"::"Positive Adjmt.", ItemLedgEntry."Entry Type"::"Negative Adjmt.");
        //exclude entries created as of no-stock avail for transfer shipment from WH
        ItemLedgEntry.SetFilter("Document No.", '<>*_INCREASE&<>*_DECREASE');
        ItemLedgEntry.SetAutoCalcFields("Cost Amount (Actual)");

        Window.Update(2, ItemLedgEntry.Count);

        TotalQty := 0;
        TotalCost := 0;
        if ItemLedgEntry.Find('-') then
            repeat
                Counter += 1;
                if (Counter mod 100) = 0 then
                    Window.Update(1, Counter);

                ToInclude := true;

                Clear(ValueEntry);
                ValueEntry.SetCurrentKey("Item Ledger Entry No.");
                ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgEntry."Entry No.");
                if ValueEntry.FindFirst() then;

                //Exclude stocktake or non-returnable stock from retail
                if ValueEntry."Source Code" = RetailSetup."Source Code" then
                    ToInclude := false;

                //Exclude stocktake from BC 
                if ValueEntry."Source Code" = SourceCodeSetup."Phys. Inventory Journal" then
                    ToInclude := false;

                //Exclude openning balance and external stocktake    
                if (ValueEntry."Source Code" = SourceCodeSetup."Item Journal") and (ValueEntry."Journal Batch Name" = '') then
                    ToInclude := false;

                if ToInclude then begin
                    if not TempItem.Get(ItemLedgEntry."Item No.") then begin
                        If Item.Get(ItemLedgEntry."Item No.") then
                            TempItem := Item
                        else begin
                            TempItem.Init();
                            TempItem."No." := ItemLedgEntry."Item No.";
                        end;
                        if TempItem.Description = '' then
                            TempItem.Description := TempItem."No.";
                        TempItem.Insert();
                    end;
                    if ValueEntry."LSC Division" <> '' then
                        if not TempDivision.Get(ValueEntry."LSC Division") then begin
                            if Division.Get(ValueEntry."LSC Division") then
                                TempDivision := Division
                            else begin
                                TempDivision.Init();
                                TempDivision.Code := ValueEntry."LSC Division";
                            end;
                            if TempDivision.Description = '' then
                                TempDivision.Description := TempDivision.Code;
                            TempDivision.Insert();
                        end;
                    if ItemLedgEntry."Item Category Code" <> '' then
                        if not TempItemCat.Get(ItemLedgEntry."Item Category Code") then begin
                            if ItemCat.Get(ItemLedgEntry."Item Category Code") then
                                TempItemCat := ItemCat
                            else begin
                                TempItemCat.Init();
                                TempItemCat.Code := ItemLedgEntry."Item Category Code";
                            end;
                            if TempItemCat.Description = '' then
                                TempItemCat.Description := TempItemCat.Code;
                            TempItemCat.Insert();
                        end;
                    if ValueEntry."Reason Code" <> '' then
                        if not TempReason.Get(ValueEntry."Reason Code") then begin
                            if ReasonCode.Get(ValueEntry."Reason Code") then
                                TempReason := ReasonCode
                            else begin
                                TempReason.Init();
                                TempReason.Code := ValueEntry."Reason Code";
                            end;
                            if TempReason.Description = '' then
                                TempReason.Description := TempReason.Code;
                            TempReason.Insert();
                        end;

                    CodeDesc := '';
                    case ReportType of
                        ReportType::Division:
                            begin
                                ReportCode := ValueEntry."LSC Division";
                                if ReportCode <> '' then
                                    CodeDesc := TempDivision.Description;
                            end;
                        ReportType::Category:
                            begin
                                ReportCode := ItemLedgEntry."Item Category Code";
                                if ReportCode <> '' then
                                    CodeDesc := TempItemCat.Description;
                            end;
                        ReportType::Item:
                            begin
                                ReportCode := ItemLedgEntry."Item No.";
                                if ReportCode <> '' then
                                    CodeDesc := TempItem.Description;
                            end;
                        ReportType::Staff:
                            begin
                                ReportCode := ItemLedgEntry."GXL MIM User ID";
                                CodeDesc := ReportCode;
                            end;
                        ReportType::"Reason Code":
                            begin
                                ReportCode := ValueEntry."Reason Code";
                                if ReportCode <> '' then
                                    CodeDesc := TempReason.Description;
                            end;
                    end;

                    if ReportType = ReportType::Transaction then begin
                        SalesInvtReportBuff.Init();
                        SalesInvtReportBuff."Entry No." := Counter;
                        SalesInvtReportBuff.Type := ReportType;
                        SalesInvtReportBuff."Store No." := ItemLedgEntry."Location Code";
                        SalesInvtReportBuff.Date := ItemLedgEntry."Posting Date";
                        SalesInvtReportBuff."Staff ID" := ItemLedgEntry."GXL MIM User ID";
                        SalesInvtReportBuff."Division Code" := ValueEntry."LSC Division";
                        if ValueEntry."LSC Division" <> '' then
                            SalesInvtReportBuff.Division := TempDivision.Description;
                        SalesInvtReportBuff."Item Category Code" := ItemLedgEntry."Item Category Code";
                        if ItemLedgEntry."Item Category Code" <> '' then
                            SalesInvtReportBuff."Item Category" := TempItemCat.Description;
                        SalesInvtReportBuff."Reason Code" := ValueEntry."Reason Code";
                        SalesInvtReportBuff."Item No." := ItemLedgEntry."Item No.";
                        SalesInvtReportBuff."Item Description" := TempItem.Description;
                        SalesInvtReportBuff.Quantity := ItemLedgEntry.Quantity;
                        SalesInvtReportBuff."Cost Amount" := ItemLedgEntry."Cost Amount (Actual)";
                        SalesInvtReportBuff.Insert();
                    end else begin
                        SalesInvtReportBuff.SetCurrentKey(Type, Code);
                        SalesInvtReportBuff.SetRange(Type, ReportType);
                        SalesInvtReportBuff.SetRange(Code, ReportCode);
                        if not SalesInvtReportBuff.Find('-') then begin
                            SalesInvtReportBuff.Init();
                            SalesInvtReportBuff."Entry No." := Counter;
                            SalesInvtReportBuff.Type := ReportType;
                            SalesInvtReportBuff.Code := ReportCode;
                            SalesInvtReportBuff.Description := CodeDesc;
                            SalesInvtReportBuff."Staff ID" := ItemLedgEntry."GXL MIM User ID";
                            SalesInvtReportBuff."Reason Code" := ValueEntry."Reason Code";
                            SalesInvtReportBuff.Quantity := ItemLedgEntry.Quantity;
                            SalesInvtReportBuff."Cost Amount" := ItemLedgEntry."Cost Amount (Actual)";
                            SalesInvtReportBuff.Insert();
                        end else begin
                            SalesInvtReportBuff.Quantity += ItemLedgEntry.Quantity;
                            SalesInvtReportBuff."Cost Amount" += ItemLedgEntry."Cost Amount (Actual)";
                            SalesInvtReportBuff.Modify();
                        end;
                    end;
                    TotalQty += ItemLedgEntry.Quantity;
                    TotalCost += ItemLedgEntry."Cost Amount (Actual)";
                end;
            until ItemLedgEntry.Next() = 0;

        Window.Close();
        FilterChange := false;
        RefreshText := '';

        ItemCounter := Counter;

        SalesInvtReportBuff.Reset();
        SalesInvtReportBuff.Copy(OldSalesInvtReportBuff);
        if not SalesInvtReportBuff.Find('-') then
            Error(NoDataErr);

    end;

    local procedure FindPeriod(SearchText: Code[10])
    var
        // >> Upgrade
        //PeriodFormManagement: Codeunit PeriodFormManagement;
        PeriodFormManagement: Codeunit PeriodPageManagement;
    // << Upgrade
    begin
        FilterChange := true;
        if Rec.GetFilter("Date Filter") <> '' then begin
            Calendar.SetFilter("Period Start", Rec.GetFilter("Date Filter"));
            if not PeriodFormManagement.FindDate('+', Calendar, PeriodType) then
                PeriodFormManagement.FindDate('+', Calendar, PeriodType::Day);
            Calendar.SetRange("Period Start");
        end;
        PeriodFormManagement.FindDate(SearchText, Calendar, PeriodType);
        if AmountType = AmountType::"Net Change" then begin
            Rec.SetRange("Date Filter", Calendar."Period Start", Calendar."Period End");
            if Rec.GetRangeMin("Date Filter") = Rec.GetRangeMax("Date Filter") then
                Rec.SetRange("Date Filter", Rec.GetRangeMin("Date Filter"));
        end else
            Rec.SetRange("Date Filter", 0D, Calendar."Period End");
        DateFilter := Rec.GetFilter("Date Filter");
        RefreshText := RefreshTxt;
    end;

    local procedure Sort()
    begin
        SortOrder := not Rec.Ascending;
        SalesInvtReportBuffCurrentKey := Rec.CurrentKey();
        Rec.Ascending(SortOrder);
        Rec.Find('-');
        CurrPage.Update(false);
    end;

    local procedure FilterOnAfterValidate()
    begin
        FilterChange := true;
        RefreshText := RefreshTxt;
    end;

    local procedure YearPeriodTypeOnPush()
    begin
        FindPeriod('');
    end;

    local procedure QuarterPeriodTypeOnPush()
    begin
        FindPeriod('');
    end;

    local procedure MonthPeriodTypeOnPush()
    begin
        FindPeriod('');
    end;

    local procedure WeekPeriodTypeOnPush()
    begin
        FindPeriod('');
    end;

    local procedure DayPeriodTypeOnPush()
    begin
        FindPeriod('');
    end;

    local procedure BalanceatDateAmountTypeOnPush()
    begin
        FindPeriod('');
    end;

    local procedure NetChangeAmountTypeOnPush()
    begin
        FindPeriod('');
    end;

    local procedure DayPeriodTypeOnValidate()
    begin
        DayPeriodTypeOnPush();
    end;

    local procedure WeekPeriodTypeOnValidate()
    begin
        WeekPeriodTypeOnPush();
    end;

    local procedure MonthPeriodTypeOnValidate()
    begin
        MonthPeriodTypeOnPush();
    end;

    local procedure QuarterPeriodTypeOnValidate()
    begin
        QuarterPeriodTypeOnPush();
    end;

    local procedure YearPeriodTypeOnValidate()
    begin
        YearPeriodTypeOnPush();
    end;

    local procedure NetChangeAmountTypeOnValidate()
    begin
        NetChangeAmountTypeOnPush();
    end;

    local procedure BalanceatDateAmountTypeOnValid()
    begin
        BalanceatDateAmountTypeOnPush();
    end;

    local procedure LimitUserAccess()
    begin
        StoreFilterEditable := true;
        if RetailUser."Store No." <> '' then begin
            Rec.SetFilter("Store Filter", RetailUser."Store No.");
            StoreFilter := Rec.GetFilter("Store Filter");
            StoreFilterEditable := false;
        end;
    end;

    local procedure OnDrilldownItemLedgerEntry()
    var
        ItemLedgEntry: Record "Item Ledger Entry";
        TempEntry: Record "Item Ledger Entry" temporary;
        ValueEntry: Record "Value Entry";
        GXLItemLedgEntries: Page "GXL ItemLedgerEntries-Shrink";
        ToInclude: Boolean;
    begin
        if Rec.Type = Rec.Type::Transaction then
            exit;

        TempEntry.Reset();
        TempEntry.DeleteAll();

        ItemLedgEntry.Reset();
        ItemLedgEntry.SetCurrentKey("Item No.", "Entry Type", "Variant Code", "Drop Shipment", "Location Code", "Posting Date");
        ItemLedgEntry.SetFilter("Item No.", Rec.GetFilter("Item Filter"));
        ItemLedgEntry.SetFilter("Location Code", Rec.GetFilter("Store Filter"));
        ItemLedgEntry.SetFilter("Posting Date", Rec.GetFilter("Date Filter"));
        ItemLedgEntry.SetFilter("Item Category Code", Rec.GetFilter("Item Category Filter"));
        ItemLedgEntry.SetFilter("Entry Type", '%1|%2', ItemLedgEntry."Entry Type"::"Positive Adjmt.", ItemLedgEntry."Entry Type"::"Negative Adjmt.");
        //exclude entries created as of no-stock avail for transfer shipment from WH
        ItemLedgEntry.SetFilter("Document No.", '<>*_INCREASE&<>*_DECREASE');
        case Rec.Type of
            Rec.Type::Category:
                ItemLedgEntry.SetRange("Item Category Code", Rec.Code);
            Rec.Type::Item:
                ItemLedgEntry.SetRange("Item No.", Rec.Code);
            Rec.Type::Staff:
                ItemLedgEntry.SetRange("GXL MIM User ID", Rec.Code);
        end;
        if ItemLedgEntry.find('-') then
            repeat
                ToInclude := true;

                Clear(ValueEntry);
                ValueEntry.SetCurrentKey("Item Ledger Entry No.");
                ValueEntry.SetRange("Item Ledger Entry No.", ItemLedgEntry."Entry No.");
                if ValueEntry.FindFirst() then;

                //Exclude stocktake or non-returnable stock from retail
                if ValueEntry."Source Code" = RetailSetup."Source Code" then
                    ToInclude := false;

                //Exclude stocktake from BC 
                if ValueEntry."Source Code" = SourceCodeSetup."Phys. Inventory Journal" then
                    ToInclude := false;

                //Exclude openning balance and external stocktake    
                if (ValueEntry."Source Code" = SourceCodeSetup."Item Journal") and (ValueEntry."Journal Batch Name" = '') then
                    ToInclude := false;

                case Rec.Type of
                    Rec.Type::Division:
                        if ValueEntry."LSC Division" <> Rec.Code then
                            ToInclude := false;
                    Rec.Type::"Reason Code":
                        if ValueEntry."Reason Code" <> Rec.Code then
                            ToInclude := false;
                end;
                if ToInclude then begin
                    TempEntry := ItemLedgEntry;
                    TempEntry.Insert();
                end;
            until ItemLedgEntry.Next() = 0;
        GXLItemLedgEntries.SetItemLedgerEntry(TempEntry);
        GXLItemLedgEntries.RunModal();
    end;
}

