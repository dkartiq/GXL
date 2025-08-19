page 50021 "GXL Toplist Card"
{
    /* Change Log
        PS-1951 2020-09-22 LP
            Include Discount infocode and subcode
    */

    ApplicationArea = All;
    Caption = 'Toplist Card';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "LSC Toplist Work Table";
    UsageCategory = ReportsAndAnalysis;
    RefreshOnActivate = true;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Date Filter';

                    trigger OnValidate()
                    begin
                        // >> Upgrade
                        //if ApplicationManagement.MakeDateFilter(DateFilter) = 0 then;
                        ApplicationManagement.MakeDateFilter(DateFilter);
                        // << Upgrade
                        Rec.SetFilter("Date Filter", DateFilter);
                        DateFilter := Rec.GetFilter("Date Filter");
                        DateFilterOnAfterValidate();
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
                        StoreFilterOnAfterValidate();
                    end;
                }
                field(ShowDiscountOnly; ShowDiscountOnly)
                {
                    ApplicationArea = All;
                    Caption = 'Show Discount Only';

                    trigger OnValidate()
                    begin
                        ShowDiscountOnlyOnValidate();
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
                field(TotalTrans; TotalTrans)
                {
                    Caption = 'No. of Transactions';
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        //PS-2155+
                        TransactionHeaderDrillDown(Rec.FieldNo("No. of Transactions"));
                        //PS-2155-
                    end;
                }
                field(TotalSales; TotalSales)
                {
                    Caption = 'Total Sales';
                    ApplicationArea = All;
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        //PS-2155+
                        TransactionHeaderDrillDown(Rec.FieldNo("Total Sales"));
                        //PS-2155-
                    end;
                }
            }
            repeater(Control1200070000)
            {
                Editable = false;
                ShowCaption = false;
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Qty."; Rec."Qty.")
                {
                    ApplicationArea = All;
                    DecimalPlaces = 0 : 5;

                    trigger OnDrillDown()
                    begin
                        DoDrillDown();
                    end;
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DoDrillDown();
                    end;
                }
                field(Profit; Rec.Profit)
                {
                    ApplicationArea = All;

                    trigger OnDrillDown()
                    begin
                        DoDrillDown();
                    end;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
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
            group(Control1902923501)
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
            action(SortCode)
            {
                ApplicationArea = All;
                Caption = 'Sort by No.';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    TopList.SetCurrentKey(Type, "No.");
                    Sort();
                end;
            }
            action(SortQty)
            {
                ApplicationArea = All;
                Caption = 'Sort by Qty.';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    TopList.SetCurrentKey("Qty.");
                    Sort();
                end;
            }
            action(SortAmount)
            {
                ApplicationArea = All;
                Caption = 'Sort by Amount';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    TopList.SetCurrentKey(Amount);
                    Sort();
                end;
            }
            action(SortProfit)
            {
                ApplicationArea = All;
                Caption = 'Sort by Profit';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    TopList.SetCurrentKey(Profit);
                    Sort();
                end;
            }
            action(SortDiscount)
            {
                ApplicationArea = All;
                Caption = 'Sort by Disc. Amount';
                Image = CreateInteraction;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    TopList.SetCurrentKey("Discount Amount");
                    Sort();
                end;
            }
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
            action("Trans.")
            {
                ApplicationArea = All;
                Caption = '&Trans.';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CalcTransOrCust(ViewType::Trans);
                end;
            }
            action(CustomerAct)
            {
                ApplicationArea = All;
                Caption = '&Customer';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CalcTransOrCust(ViewType::Cust);
                end;
            }
            action(ItemAct)
            {
                ApplicationArea = All;
                Caption = '&Item';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CalcItem();
                end;
            }
            action(CatAct)
            {
                ApplicationArea = All;
                Caption = 'C&ategory';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CalcCat();
                end;
            }
            action(ProdAct)
            {
                ApplicationArea = All;
                Caption = '&ProdGrp';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    calcProd();
                end;
            }
            action(StaffAct)
            {
                ApplicationArea = All;
                Caption = '&Staff';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CalcStaff();
                end;
            }
            //PS-1951+
            action(DiscountAct)
            {
                ApplicationArea = All;
                Caption = 'Discount';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CalcDiscount();
                end;
            }
            action(ReturnAct)
            {
                ApplicationArea = All;
                Caption = 'Return/Refund';
                Image = ShowMatrix;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    CalcRefund();
                end;
            }
            //PS-1951-
            action(PushPrint)
            {
                ApplicationArea = All;
                Caption = '&Print ..';
                Image = Print;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                begin
                    Clear(TopListReport);
                    TopListReport.SetData(TopList, TopListCurrentKey, SortOrder); //LS-TICKET: LSTS-27116
                    TopListReport.Run();
                end;
            }
            action(Chart)
            {
                ApplicationArea = All;
                Caption = 'Chart';
                Image = BarChart;
                Promoted = true;
                PromotedCategory = Process;

                trigger OnAction()
                var
                    TopListChart: Page "LSC Toplist Pie Chart";
                begin
                    Clear(TopListChart);
                    //TopListChart.LoadData(TopList, DateFilter);
                    TopListChart.LoadData(TopList, DateFilter, ''); //LS-TICKET: LSTS-27116
                    TopListChart.RunModal();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LimitUserAccess();
        //PS-1951+
        //CalcFields("No. of Transactions", "Total Sales");
        //PS-1951-
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        DateFilter := Rec.GetFilter("Date Filter");
        StoreFilter := Rec.GetFilter("Store Filter");
        TopList := Rec;
        if not TopList.Find(Which) then
            exit(false);
        Rec := TopList;
        exit(true);
    end;

    trigger OnInit()
    begin
        TopList.Type := TopList.Type::Transaction;
        TopList.Insert();
        SortOrder := true;
    end;

    trigger OnNextRecord(Steps: Integer): Integer
    var
        CurrentSteps: Integer;
    begin
        TopList := Rec;
        CurrentSteps := TopList.Next(Steps);
        if CurrentSteps <> 0 then
            Rec := TopList;
        exit(CurrentSteps);
    end;

    trigger OnOpenPage()
    begin
        if not RetailUser.Get(UserId()) then
            Clear(RetailUser);
        LimitUserAccess();

        Rec.CalcFields("No. of Transactions", "Total Sales");
        FilterChange := true;
        RefreshText := RefreshTxt;
        //PS-1951+
        DiscountInfocode := 'DISCOUNT';
        ReturnInfocode := 'RETURN';
        ShowDiscountOnly := false;
        TotalTrans := Rec."No. of Transactions";
        TotalSales := Rec."Total Sales";
        //PS-1951-
    end;

    var
        TopList: Record "LSC Toplist Work Table" temporary;
        Transaction: Record "LSC Transaction Header";
        SalesEntry: Record "LSC Trans. Sales Entry";
        Item: Record Item;
        Customer: Record Customer;
        Calendar: Record Date;
        RetailUser: Record "LSC Retail User";
        TopListReport: Report "LSC Toplist";
        ApplicationManagement: Codeunit "Filter Tokens";
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        AmountType: Option "Net Change","Balance at Date";
        ViewType: Option Trans,Cust;
        SortOrder: Boolean;
        TopListCurrentKey: Text[205];
        FilterChange: Boolean;
        Window: Dialog;
        TransCounter: Integer;
        CustCounter: Integer;
        ItemCounter: Integer;
        TransNo: Integer;
        catcounter: Integer;
        prodcounter: Integer;
        StaffCounter: Integer;
        DateFilter: Text[30];
        StoreFilter: Text[30];
        RefreshText: Text[30];
        RefreshTxt: Label 'Refresh Needed';
        TotalRecTxt: Label 'Number of Records';
        CounterTxt: Label 'Counter';
        RcptTxt: Label 'Receipt ';
        NoDataErr: Label 'There is no data within the selected period';
        StoreFilterEditable: Boolean;
        ShowDiscountOnly: Boolean;
        DiscountInfocode: Code[10];
        DiscountCounter: Integer;
        ReturnInfocode: Code[10];
        ReturnCounter: Integer;
        TotalTrans: Integer;
        TotalSales: Decimal;
        TotalTransInfocode: array[8] of Integer;
        TotalSalesInfocode: array[8] of Decimal;

    [Scope('OnPrem')]
    procedure CalcTransOrCust(Type: Option Trans,Cust)
    var
        Counter: Integer;
    begin
        if FilterChange then begin
            TopList.Reset();
            TopList.DeleteAll();
            TransCounter := 0;
            CustCounter := 0;
            ItemCounter := 0;

            catcounter := 0;
            prodcounter := 0;
            StaffCounter := 0;

            //PS-1951+
            DiscountCounter := 0;
            ReturnCounter := 0;
            TotalTrans := 0;
            TotalSales := 0;
            //PS-1951-
        end else begin
            if Type = Type::Trans then begin
                if TransCounter <> 0 then begin
                    TopList.SetRange(Type, TopList.Type::Transaction);
                    TopList.Find('-');
                    Rec := TopList;
                    TotalTrans := TotalTransInfocode[1];
                    TotalSales := TotalSalesInfocode[1];
                    exit;
                end;
            end;
            if Type = Type::Cust then begin
                if CustCounter <> 0 then begin
                    TopList.SetRange(Type, TopList.Type::Customer);
                    TopList.Find('-');
                    Rec := TopList;
                    TotalTrans := TotalTransInfocode[3];
                    TotalSales := TotalSalesInfocode[3];
                    exit;
                end
            end;
            TotalTrans := 0;
            TotalSales := 0;
        end;

        Window.Open(
          CounterTxt + '          ' + ' #1########\' +
          TotalRecTxt + ' #2########');
        Window.Update(2, Rec."No. of Transactions");

        Transaction.Reset();
        Transaction.SetCurrentKey("Entry Status", Date);
        Transaction.SetFilter("Entry Status", '%1|%2', Transaction."Entry Status"::" ", Transaction."Entry Status"::Posted);
        Transaction.SetFilter(Date, Rec.GetFilter("Date Filter"));
        Transaction.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
        //PS-1951+
        if ShowDiscountOnly then begin
            Transaction.SetFilter("GXL Infocode Filter", DiscountInfocode);
            Transaction.SetAutoCalcFields("GXL Infocode Exists");
            Transaction.SetRange("GXL Infocode Exists", true);
        end;
        //PS-1951-

        if Transaction.Find('-') then
            repeat
                if Transaction."Transaction Type" = Transaction."Transaction Type"::Sales then begin
                    Counter += 1;
                    if (Counter mod 100) = 0 then
                        Window.Update(1, Counter);
                    if Type = Type::Trans then begin
                        if not TopList.Get(TopList.Type::Transaction, Transaction."Store No.", Transaction."POS Terminal No.", Format(Transaction."Transaction No.")) then begin
                            TopList.Init();
                            TopList.Type := TopList.Type::Transaction;
                            TopList."Store No." := Transaction."Store No.";
                            TopList."POS Terminal No." := Transaction."POS Terminal No.";
                            TopList."No." := Format(Transaction."Transaction No.");
                            TopList.Insert();
                        end;
                    end;
                    if Type = Type::Cust then begin
                        if not TopList.Get(
                          TopList.Type::Customer, '', '', Format(Transaction."Customer No."))
                        then begin
                            TopList.Init();
                            TopList.Type := TopList.Type::Customer;
                            TopList."Store No." := '';
                            TopList."POS Terminal No." := '';
                            TopList."No." := Transaction."Customer No.";
                            TopList.Insert();
                        end;
                    end;

                    if Type = Type::Trans then
                        TopList.Description := RcptTxt + Format(Transaction."Receipt No.");
                    if Type = Type::Cust then begin
                        if Customer.Get(TopList."No.") then
                            TopList.Description := Customer.Name
                        else
                            Clear(TopList.Description);
                    end;

                    TopList."Qty." := TopList."Qty." + Transaction."No. of Items";
                    TopList.Amount := TopList.Amount - Transaction."Net Amount";
                    TopList."Discount Amount" := TopList."Discount Amount" + Transaction."Discount Amount";
                    TopList."Cost Amount" := TopList."Cost Amount" + Transaction."Cost Amount";
                    TopList.Profit := TopList.Amount + TopList."Cost Amount";
                    TopList.Modify();
                    //PS-1951+
                    TotalTrans += 1;
                    TotalSales += -Transaction."Net Amount";
                    //PS-1951-
                end;
            until Transaction.Next() = 0;

        Window.Close();
        FilterChange := false;
        RefreshText := '';

        if TopList.Type = TopList.Type::Transaction then begin
            TransCounter := Counter;
            TopList.SetRange(Type, TopList.Type::Transaction);
            TotalTransInfocode[1] := TotalTrans;
            TotalSalesInfocode[1] := TotalSales;
        end else begin
            CustCounter := Counter;
            TopList.SetRange(Type, TopList.Type::Customer);
            TotalTransInfocode[3] := TotalTrans;
            TotalSalesInfocode[3] := TotalSales;
        end;

        if not TopList.Find('-') then
            Error(NoDataErr)
        else
            Rec := TopList;
    end;

    [Scope('OnPrem')]
    procedure CalcItem()
    var
        Counter: Integer;
    begin
        if FilterChange then begin
            TopList.Reset();
            TopList.DeleteAll();
            TransCounter := 0;
            CustCounter := 0;
            ItemCounter := 0;

            catcounter := 0;
            prodcounter := 0;
            StaffCounter := 0;

            //PS-1951+
            DiscountCounter := 0;
            ReturnCounter := 0;
            TotalTrans := 0;
            TotalSales := 0;
            //PS-1951-
        end else begin
            if ItemCounter <> 0 then begin
                TopList.SetRange(Type, TopList.Type::Items);
                TopList.Find('-');
                Rec := TopList;
                TotalTrans := TotalTransInfocode[2];
                TotalSales := TotalSalesInfocode[2];
                exit;
            end;
            TotalTrans := 0;
            TotalSales := 0;
        end;

        Window.Open(
          CounterTxt + '          ' + ' #1########\' +
          TotalRecTxt + ' #2########');

        SalesEntry.Reset();
        SalesEntry.SetCurrentKey(Date);
        SalesEntry.SetFilter(Date, Rec.GetFilter("Date Filter"));
        SalesEntry.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
        //PS-1951+
        if ShowDiscountOnly then begin
            SalesEntry.SetFilter("GXL Infocode Filter", DiscountInfocode);
            SalesEntry.SetAutoCalcFields("GXL Infocode Exists");
            SalesEntry.SetRange("GXL Infocode Exists", true);
        end;
        //PS-1951-
        Window.Update(2, SalesEntry.Count);

        if SalesEntry.Find('-') then
            repeat
                Counter += 1;
                if (Counter mod 100) = 0 then
                    Window.Update(1, Counter);

                if not TopList.Get(TopList.Type::Items, '', '', Format(SalesEntry."Item No.")) then begin
                    TopList.Init();
                    TopList."Store No." := '';
                    TopList."POS Terminal No." := '';
                    TopList.Type := TopList.Type::Items;
                    TopList."No." := SalesEntry."Item No.";
                    TopList.Insert();
                end;
                if Item.Get(SalesEntry."Item No.") then
                    TopList.Description := Item.Description;
                TopList."Qty." := TopList."Qty." - SalesEntry.Quantity;
                TopList.Amount := TopList.Amount - SalesEntry."Net Amount";
                TopList."Discount Amount" := TopList."Discount Amount" + SalesEntry."Discount Amount";
                TopList."Cost Amount" := TopList."Cost Amount" + SalesEntry."Cost Amount";
                TopList.Profit := TopList.Amount + TopList."Cost Amount";
                TopList.Modify();

                TotalSales += -SalesEntry."Net Amount"; //PS-1951
            until SalesEntry.Next() = 0;


        Window.Close();
        FilterChange := false;
        RefreshText := '';

        ItemCounter := Counter;
        TopList.SetRange(Type, TopList.Type::Items);

        if not TopList.Find('-') then
            Error(NoDataErr)
        else
            Rec := TopList;

        //PS-1951+
        if ShowDiscountOnly then
            TotalTrans := CountTotalTrans(DiscountInfocode)
        else begin
            Rec.CalcFields("No. of Transactions", "Total Sales");
            TotalTrans := Rec."No. of Transactions";
            TotalSales := Rec."Total Sales";
        end;
        TotalTransInfocode[2] := TotalTrans;
        TotalSalesInfocode[2] := TotalSales;
        //PS-1951-
    end;

    local procedure FindPeriod(SearchText: Code[10])
    var
        PeriodFormManagement: Codeunit PeriodPageManagement;
    begin
        //FindPeriod

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
        RefreshText := RefreshTxt;
    end;

    [Scope('OnPrem')]
    procedure Sort()
    begin
        SortOrder := not TopList.Ascending;
        TopListCurrentKey := TopList.CurrentKey();
        TopList.Ascending(SortOrder);
        TopList.Find('-');
        Rec := TopList;
        CurrPage.Update(false);
    end;

    [Scope('OnPrem')]
    procedure OpenWindow()
    begin
    end;

    [Scope('OnPrem')]
    procedure DoDrillDown()
    var
        ProductGroup: Record "LSC Retail Product Group";
        Staff: Record "LSC Staff";
        InfocodeEntry: Record "LSC Trans. Infocode Entry";
    begin
        case Rec.Type of
            Rec.Type::Transaction:
                begin
                    Transaction.Reset();
                    Evaluate(TransNo, Rec."No.");
                    Transaction.FilterGroup(2); //PS-2155
                    Transaction.SetRange("Store No.", Rec."Store No.");
                    Transaction.FilterGroup(0); //PS-2155
                    Transaction.SetRange("POS Terminal No.", Rec."POS Terminal No.");
                    Transaction.SetRange("Transaction No.", TransNo);
                    //PS-1951+
                    if ShowDiscountOnly then begin
                        Transaction.SetFilter("GXL Infocode Filter", DiscountInfocode);
                        Transaction.SetAutoCalcFields("GXL Infocode Exists");
                        Transaction.SetRange("GXL Infocode Exists", true);
                    end;
                    //PS-1951-
                    PAGE.Run(0, Transaction);
                    Transaction.Reset();
                end;
            Rec.Type::Customer:
                begin
                    Transaction.Reset();
                    Transaction.SetCurrentKey("Customer No.", Date);
                    Transaction.SetFilter("Entry Status", '%1|%2', Transaction."Entry Status"::Posted, Transaction."Entry Status"::" ");
                    Transaction.SetFilter(Date, Rec.GetFilter("Date Filter"));
                    Transaction.SetRange("Customer No.", Rec."No.");
                    Transaction.FilterGroup(2); //PS-2155
                    Transaction.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
                    Transaction.FilterGroup(0); //PS-2155
                    //PS-1951+
                    if ShowDiscountOnly then begin
                        Transaction.SetFilter("GXL Infocode Filter", DiscountInfocode);
                        Transaction.SetAutoCalcFields("GXL Infocode Exists");
                        Transaction.SetRange("GXL Infocode Exists", true);
                    end;
                    //PS-1951-
                    PAGE.Run(0, Transaction);
                    Transaction.Reset();
                end;
            Rec.Type::Items:
                begin
                    SalesEntry.Reset();
                    SalesEntry.SetCurrentKey("Item No.", "Variant Code", Date);
                    SalesEntry.SetRange("Item No.", Rec."No.");
                    SalesEntry.SetFilter(Date, Rec.GetFilter("Date Filter"));
                    SalesEntry.FilterGroup(2); //PS-2155
                    SalesEntry.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
                    SalesEntry.FilterGroup(0); //PS-2155
                    //PS-1951+
                    if ShowDiscountOnly then begin
                        SalesEntry.SetRange("GXL Infocode Filter", DiscountInfocode);
                        SalesEntry.SetAutoCalcFields("GXL Infocode Exists");
                        SalesEntry.SetRange("GXL Infocode Exists", true);
                    end;
                    //PS-1951-
                    PAGE.Run(0, SalesEntry);
                    SalesEntry.Reset();
                end;
            Rec.Type::Category:
                begin
                    SalesEntry.Reset();
                    SalesEntry.SetCurrentKey("Item Category Code", "Retail Product Code", Date);
                    SalesEntry.SetRange("Item Category Code", Rec."No.");
                    SalesEntry.SetFilter(Date, Rec.GetFilter("Date Filter"));
                    //PS-2155+
                    if RetailUser."Store No." <> '' then begin
                        SalesEntry.FilterGroup(2);
                        SalesEntry.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
                        SalesEntry.FilterGroup(0);
                    end;
                    //PS-2155-
                    //PS-1951+
                    if ShowDiscountOnly then begin
                        SalesEntry.SetRange("GXL Infocode Filter", DiscountInfocode);
                        SalesEntry.SetAutoCalcFields("GXL Infocode Exists");
                        SalesEntry.SetRange("GXL Infocode Exists", true);
                    end;
                    //PS-1951-
                    PAGE.Run(0, SalesEntry);
                    SalesEntry.Reset();
                end;
            Rec.Type::"Product Group":
                begin
                    SalesEntry.Reset();
                    SalesEntry.SetCurrentKey("Item Category Code", "Retail Product Code", Date);
                    ProductGroup.SetRange(Code, Rec."No.");
                    if ProductGroup.FindFirst() then
                        SalesEntry.SetRange("Item Category Code", ProductGroup."Item Category Code");
                    SalesEntry.SetRange("Retail Product Code", Rec."No.");
                    SalesEntry.SetFilter(Date, Rec.GetFilter("Date Filter"));
                    //PS-2155+
                    if RetailUser."Store No." <> '' then begin
                        SalesEntry.FilterGroup(2);
                        SalesEntry.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
                        SalesEntry.FilterGroup(0);
                    end;
                    //PS-2155-
                    //PS-1951+
                    if ShowDiscountOnly then begin
                        SalesEntry.SetRange("GXL Infocode Filter", DiscountInfocode);
                        SalesEntry.SetAutoCalcFields("GXL Infocode Exists");
                        SalesEntry.SetRange("GXL Infocode Exists", true);
                    end;
                    //PS-1951-
                    PAGE.Run(0, SalesEntry);
                    SalesEntry.Reset();
                end;
            Rec.Type::Staff:
                begin
                    Transaction.Reset();
                    Transaction.SetCurrentKey("Store No.", "Staff ID", "Transaction Type", Date, "Entry Status");
                    //PS-2155+
                    if RetailUser."Store No." <> '' then begin
                        Transaction.FilterGroup(2);
                        Transaction.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
                        Transaction.FilterGroup(0);
                    end;
                    //PS-2155-
                    if Staff.Get(Rec."No.") then
                        if Staff."Store No." <> '' then
                            Transaction.SetRange("Store No.", Staff."Store No.");
                    Transaction.SetRange("Staff ID", Rec."No.");
                    Transaction.SetFilter(Date, Rec.GetFilter("Date Filter"));
                    Transaction.SetFilter("Entry Status", '%1|%2', Transaction."Entry Status"::Posted, Transaction."Entry Status"::" ");
                    //PS-1951+
                    if ShowDiscountOnly then begin
                        Transaction.SetFilter("GXL Infocode Filter", DiscountInfocode);
                        Transaction.SetAutoCalcFields("GXL Infocode Exists");
                        Transaction.SetRange("GXL Infocode Exists", true);
                    end;
                    //PS-1951-
                    PAGE.Run(0, Transaction);
                    Transaction.Reset();
                end;
                //PS-1951+
            Rec.Type::Discount:
                begin
                    InfocodeEntry.Reset();
                    InfocodeEntry.SetCurrentKey(Infocode, Subcode, Date);
                    InfocodeEntry.SetRange(Infocode, DiscountInfocode);
                    InfocodeEntry.SetRange(Subcode, Rec."No.");
                    InfocodeEntry.SetFilter(Date, Rec.GetFilter("Date Filter"));
                    InfocodeEntry.FilterGroup(2);
                    InfocodeEntry.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
                    InfocodeEntry.FilterGroup(0);
                    Page.Run(0, InfocodeEntry);
                end;
            Rec.Type::Return:
                begin
                    InfocodeEntry.Reset();
                    InfocodeEntry.SetCurrentKey(Infocode, Subcode, Date);
                    InfocodeEntry.SetRange(Infocode, ReturnInfocode);
                    InfocodeEntry.SetRange(Subcode, Rec."No.");
                    InfocodeEntry.SetFilter(Date, Rec.GetFilter("Date Filter"));
                    InfocodeEntry.FilterGroup(2);
                    InfocodeEntry.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
                    InfocodeEntry.FilterGroup(0);
                    Page.Run(0, InfocodeEntry);
                end;
        //PS-1951-
        end;
    end;

    [Scope('OnPrem')]
    procedure CalcCat()
    var
        cat: Record "Item Category";
        Counter: Integer;
    begin

        if FilterChange then begin
            TopList.Reset();
            TopList.DeleteAll();
            TransCounter := 0;
            CustCounter := 0;
            ItemCounter := 0;
            catcounter := 0;
            prodcounter := 0;
            StaffCounter := 0;
            //PS-1951+
            DiscountCounter := 0;
            ReturnCounter := 0;
            TotalTrans := 0;
            TotalSales := 0;
            //PS-1951-
        end else begin
            if catcounter <> 0 then begin
                TopList.SetRange(Type, TopList.Type::Category);
                TopList.Find('-');
                Rec := TopList;
                TotalTrans := TotalTransInfocode[4];
                TotalSales := TotalSalesInfocode[4];
                exit;
            end;
            TotalTrans := 0;
            TotalSales := 0;
        end;

        Window.Open(
          CounterTxt + '          ' + ' #1########\' +
          TotalRecTxt + ' #2########');

        SalesEntry.Reset();
        SalesEntry.SetCurrentKey(Date);
        SalesEntry.SetFilter(Date, Rec.GetFilter("Date Filter"));
        SalesEntry.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
        //PS-1951+
        if ShowDiscountOnly then begin
            SalesEntry.SetFilter("GXL Infocode Filter", DiscountInfocode);
            SalesEntry.SetAutoCalcFields("GXL Infocode Exists");
            SalesEntry.SetRange("GXL Infocode Exists", true);
        end;
        //PS-1951-
        Window.Update(2, SalesEntry.Count);

        if SalesEntry.Find('-') then
            repeat
                Counter += 1;
                if (Counter mod 100) = 0 then
                    Window.Update(1, Counter);

                if not TopList.Get(TopList.Type::Category, '', '', Format(SalesEntry."Item Category Code")) then begin
                    TopList.Init();
                    TopList."Store No." := '';
                    TopList."POS Terminal No." := '';
                    TopList.Type := TopList.Type::Category;
                    TopList."No." := SalesEntry."Item Category Code";
                    TopList.Insert();
                end;
                if cat.Get(SalesEntry."Item Category Code") then
                    TopList.Description := cat.Description;
                TopList."Qty." := TopList."Qty." - SalesEntry.Quantity;
                TopList.Amount := TopList.Amount - SalesEntry."Net Amount";
                TopList."Discount Amount" := TopList."Discount Amount" + SalesEntry."Discount Amount";
                TopList."Cost Amount" := TopList."Cost Amount" + SalesEntry."Cost Amount";
                TopList.Profit := TopList.Amount + TopList."Cost Amount";
                TopList.Modify();
                TotalSales += -SalesEntry."Net Amount";//PS-1951
            until SalesEntry.Next() = 0;


        Window.Close();
        FilterChange := false;
        RefreshText := '';

        catcounter := Counter;
        TopList.SetRange(Type, TopList.Type::Category);

        if not TopList.Find('-') then
            Error(NoDataErr)
        else
            Rec := TopList;

        //PS-1951+
        if ShowDiscountOnly then
            TotalTrans := CountTotalTrans(DiscountInfocode)
        else begin
            Rec.CalcFields("No. of Transactions", "Total Sales");
            TotalTrans := Rec."No. of Transactions";
            TotalSales := Rec."Total Sales";
        end;
        TotalTransInfocode[4] := TotalTrans;
        TotalSalesInfocode[4] := TotalSales;
        //PS-1951-
    end;

    [Scope('OnPrem')]
    procedure calcProd()
    var
        prod: Record "LSC Retail Product Group";
        Counter: Integer;
    begin
        if FilterChange then begin
            TopList.Reset();
            TopList.DeleteAll();
            TransCounter := 0;
            CustCounter := 0;
            ItemCounter := 0;
            catcounter := 0;
            prodcounter := 0;
            StaffCounter := 0;
            //PS-1951+
            DiscountCounter := 0;
            ReturnCounter := 0;
            TotalTrans := 0;
            TotalSales := 0;
            //PS-1951-
        end else begin
            if prodcounter <> 0 then begin
                TopList.SetRange(Type, TopList.Type::"Product Group");
                TopList.Find('-');
                Rec := TopList;
                TotalTrans := TotalTransInfocode[5];
                TotalSales := TotalSalesInfocode[5];
                exit;
            end;
            TotalTrans := 0;
            TotalSales := 0;
        end;

        Window.Open(
          CounterTxt + '          ' + ' #1########\' +
          TotalRecTxt + ' #2########');

        SalesEntry.Reset();
        SalesEntry.SetCurrentKey(Date);
        SalesEntry.SetFilter(Date, Rec.GetFilter("Date Filter"));
        SalesEntry.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
        //PS-1951+
        if ShowDiscountOnly then begin
            SalesEntry.SetFilter("GXL Infocode Filter", DiscountInfocode);
            SalesEntry.SetAutoCalcFields("GXL Infocode Exists");
            SalesEntry.SetRange("GXL Infocode Exists", true);
        end;
        //PS-1951-
        Window.Update(2, SalesEntry.Count);

        if SalesEntry.Find('-') then
            repeat
                Counter += 1;
                if (Counter mod 100) = 0 then
                    Window.Update(1, Counter);

                if not TopList.Get(TopList.Type::"Product Group", '', '', Format(SalesEntry."Retail Product Code")) then begin
                    TopList.Init();
                    TopList."Store No." := '';
                    TopList."POS Terminal No." := '';
                    TopList.Type := TopList.Type::"Product Group";
                    TopList."No." := SalesEntry."Retail Product Code";
                    TopList.Insert();
                end;
                if prod.Get(SalesEntry."Item Category Code", SalesEntry."Retail Product Code") then
                    TopList.Description := prod.Description;
                TopList."Qty." := TopList."Qty." - SalesEntry.Quantity;
                TopList.Amount := TopList.Amount - SalesEntry."Net Amount";
                TopList."Discount Amount" := TopList."Discount Amount" + SalesEntry."Discount Amount";
                TopList."Cost Amount" := TopList."Cost Amount" + SalesEntry."Cost Amount";
                TopList.Profit := TopList.Amount + TopList."Cost Amount";
                TopList.Modify();
                TotalSales += -SalesEntry."Net Amount";//PS-1951
            until SalesEntry.Next() = 0;


        Window.Close();
        FilterChange := false;
        RefreshText := '';

        prodcounter := Counter;
        TopList.SetRange(Type, TopList.Type::"Product Group");

        if not TopList.Find('-') then
            Error(NoDataErr)
        else
            Rec := TopList;

        //PS-1951+
        if ShowDiscountOnly then
            TotalTrans := CountTotalTrans(DiscountInfocode)
        else begin
            Rec.CalcFields("No. of Transactions", "Total Sales");
            TotalTrans := Rec."No. of Transactions";
            TotalSales := Rec."Total Sales";
        end;
        TotalTransInfocode[5] := TotalTrans;
        TotalSalesInfocode[5] := TotalSales;
        //PS-1951-
    end;

    [Scope('OnPrem')]
    procedure CalcStaff()
    var
        Staff: Record "LSC Staff";
        Counter: Integer;
    begin
        if FilterChange then begin
            TopList.Reset();
            TopList.DeleteAll();
            TransCounter := 0;
            CustCounter := 0;
            ItemCounter := 0;
            catcounter := 0;
            prodcounter := 0;
            StaffCounter := 0;
            //PS-1951+
            DiscountCounter := 0;
            ReturnCounter := 0;
            TotalTrans := 0;
            TotalSales := 0;
            //PS-1951-
        end else begin
            if StaffCounter <> 0 then begin
                TopList.SetRange(Type, TopList.Type::Staff);
                TopList.Find('-');
                TotalTrans := TotalTransInfocode[6];
                TotalSales := TotalSalesInfocode[6];
                Rec := TopList;
                exit;
            end;
            TotalTrans := 0;
            TotalSales := 0;
        end;

        Window.Open(
          CounterTxt + '          ' + ' #1########\' +
          TotalRecTxt + ' #2########');

        SalesEntry.Reset();
        SalesEntry.SetCurrentKey(Date);
        SalesEntry.SetFilter(Date, Rec.GetFilter("Date Filter"));
        SalesEntry.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
        //PS-1951+
        if ShowDiscountOnly then begin
            SalesEntry.SetFilter("GXL Infocode Filter", DiscountInfocode);
            SalesEntry.SetAutoCalcFields("GXL Infocode Exists");
            SalesEntry.SetRange("GXL Infocode Exists", true);
        end;
        //PS-1951-
        Window.Update(2, SalesEntry.Count);

        if SalesEntry.Find('-') then
            repeat
                Counter += 1;
                if (Counter mod 100) = 0 then
                    Window.Update(1, Counter);

                if not TopList.Get(TopList.Type::Staff, '', '', Format(SalesEntry."Staff ID")) then begin
                    TopList.Init();
                    TopList."Store No." := '';
                    TopList."POS Terminal No." := '';
                    TopList.Type := TopList.Type::Staff;
                    TopList."No." := SalesEntry."Staff ID";
                    TopList.Insert();
                end;
                if Staff.Get(SalesEntry."Staff ID") then
                    TopList.Description := Staff."Name on Receipt";
                TopList."Qty." := TopList."Qty." - SalesEntry.Quantity;
                TopList.Amount := TopList.Amount - SalesEntry."Net Amount";
                TopList."Discount Amount" := TopList."Discount Amount" + SalesEntry."Discount Amount";
                TopList."Cost Amount" := TopList."Cost Amount" + SalesEntry."Cost Amount";
                TopList.Profit := TopList.Amount + TopList."Cost Amount";
                TopList.Modify();
                TotalSales += -SalesEntry."Net Amount";//PS-1951
            until SalesEntry.Next() = 0;

        Window.Close();
        FilterChange := false;
        RefreshText := '';

        StaffCounter := Counter;
        TopList.SetRange(Type, TopList.Type::Staff);

        if not TopList.Find('-') then
            Error(NoDataErr)
        else
            Rec := TopList;

        //PS-1951+
        if ShowDiscountOnly then
            TotalTrans := CountTotalTrans(DiscountInfocode)
        else begin
            Rec.CalcFields("No. of Transactions", "Total Sales");
            TotalTrans := Rec."No. of Transactions";
            TotalSales := Rec."Total Sales";
        end;
        TotalTransInfocode[6] := TotalTrans;
        TotalSalesInfocode[6] := TotalSales;
        //PS-1951-
    end;

    local procedure StoreFilterOnAfterValidate()
    begin
        FilterChange := true;
        RefreshText := RefreshTxt;
    end;

    local procedure DateFilterOnAfterValidate()
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

    //PS-2155+
    local procedure TransactionHeaderDrillDown(SelectedFldNo: Integer)
    var
        TransactionHeader: Record "LSC Transaction Header";
    begin
        TransactionHeader.SetCurrentKey("Store No.", "Staff ID", "Transaction Type", Date, "Entry Status");
        if Rec.GetFilter("Store Filter") <> '' then begin
            TransactionHeader.FilterGroup(2);
            TransactionHeader.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
            TransactionHeader.FilterGroup(0);
        end;
        TransactionHeader.SetRange("Transaction Type", TransactionHeader."Transaction Type"::Sales);
        TransactionHeader.SetFilter(Date, Rec.GetFilter("Date Filter"));
        TransactionHeader.SetFilter("Entry Status", '%1|%2', TransactionHeader."Entry Status"::" ", TransactionHeader."Entry Status"::Posted);
        //PS-1951+
        if ShowDiscountOnly then begin
            TransactionHeader.SetFilter("GXL Infocode Filter", DiscountInfocode);
            TransactionHeader.SetAutoCalcFields("GXL Infocode Exists");
            TransactionHeader.SetRange("GXL Infocode Exists", true);
        end;
        //PS-1951-        
        if SelectedFldNo = Rec.FieldNo("Total Sales") then
            Page.RunModal(0, TransactionHeader, TransactionHeader."Gross Amount")
        else
            Page.RunModal(0, TransactionHeader);
    end;
    //PS-2155-

    //PS-1951+
    local procedure ShowDiscountOnlyOnValidate()
    begin
        FilterChange := true;
        RefreshText := RefreshTxt;
    end;

    local procedure CalcDiscount()
    var
        InfocodeEntry: Record "LSC Trans. Infocode Entry";
        TransHead: Record "LSC Transaction Header";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        InfoSubcode: Record "LSC Information Subcode";
        Counter: Integer;
    begin
        if FilterChange then begin
            TopList.Reset();
            TopList.DeleteAll();
            TransCounter := 0;
            CustCounter := 0;
            ItemCounter := 0;
            catcounter := 0;
            prodcounter := 0;
            StaffCounter := 0;

            DiscountCounter := 0;
            ReturnCounter := 0;
            TotalTrans := 0;
            TotalSales := 0;
        end else begin
            if DiscountCounter <> 0 then begin
                TopList.SetRange(Type, TopList.Type::Discount);
                TopList.Find('-');
                Rec := TopList;
                TotalTrans := TotalTransInfocode[7];
                TotalSales := TotalSalesInfocode[7];
                exit;
            end;
            TotalSales := 0;
            TotalTrans := 0;
        end;

        Window.Open(
          CounterTxt + '          ' + ' #1########\' +
          TotalRecTxt + ' #2########');


        InfocodeEntry.SetCurrentKey(Infocode, Subcode, Date);
        InfocodeEntry.SetRange(Infocode, DiscountInfocode);
        InfocodeEntry.SetFilter(Date, Rec.GetFilter("Date Filter"));
        InfocodeEntry.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
        Window.Update(2, InfocodeEntry.Count);

        if InfocodeEntry.Find('-') then
            repeat
                Counter += 1;
                if (Counter mod 100) = 0 then
                    Window.Update(1, Counter);

                if not TopList.Get(TopList.Type::Discount, '', '', Format(InfocodeEntry.Subcode)) then begin
                    TopList.Init();
                    TopList."Store No." := '';
                    TopList."POS Terminal No." := '';
                    TopList.Type := TopList.Type::Discount;
                    TopList."No." := Format(InfocodeEntry.Subcode);

                    if InfoSubcode.Get(DiscountInfocode, TopList."No.") then
                        TopList.Description := InfoSubcode.Description;

                    TopList.Insert();
                end;
                case InfocodeEntry."Transaction Type" of
                    InfocodeEntry."Transaction Type"::Header:
                        if TransHead.Get(InfocodeEntry."Store No.", InfocodeEntry."POS Terminal No.", InfocodeEntry."Transaction No.") then begin
                            TopList."Qty." := TopList."Qty." - TransHead."No. of Items";
                            TopList.Amount := TopList.Amount - TransHead."Net Amount";
                            TopList."Discount Amount" := TopList."Discount Amount" + TransHead."Discount Amount";
                            TopList."Cost Amount" := TopList."Cost Amount" + TransHead."Cost Amount";
                            TotalSales += -TransHead."Net Amount";
                        end;
                    InfocodeEntry."Transaction Type"::"Sales Entry":
                        if TransSalesEntry.Get(
                            InfocodeEntry."Store No.", InfocodeEntry."POS Terminal No.", InfocodeEntry."Transaction No.", InfocodeEntry."Line No.")
                        then begin
                            TopList."Qty." := TopList."Qty." - TransSalesEntry.Quantity;
                            TopList.Amount := TopList.Amount - TransSalesEntry."Net Amount";
                            TopList."Discount Amount" := TopList."Discount Amount" + TransSalesEntry."Discount Amount";
                            TopList."Cost Amount" := TopList."Cost Amount" + TransSalesEntry."Cost Amount";
                            TotalSales += -TransSalesEntry."Net Amount";
                        end;
                end;
                TopList.Profit := TopList.Amount + TopList."Cost Amount";
                TopList.Modify();
            until InfocodeEntry.Next() = 0;

        Window.Close();
        FilterChange := false;
        RefreshText := '';

        DiscountCounter := Counter;
        TopList.SetRange(Type, TopList.Type::Discount);

        if not TopList.Find('-') then
            Error(NoDataErr)
        else
            Rec := TopList;

        TotalTrans := CountTotalTrans(DiscountInfocode);
        TotalTransInfocode[7] := TotalTrans;
        TotalSalesInfocode[7] := TotalSales;
    end;

    local procedure CalcRefund()
    var
        InfocodeEntry: Record "LSC Trans. Infocode Entry";
        TransHead: Record "LSC Transaction Header";
        TransSalesEntry: Record "LSC Trans. Sales Entry";
        InfoSubcode: Record "LSC Information Subcode";
        Counter: Integer;
    begin
        if FilterChange then begin
            TopList.Reset();
            TopList.DeleteAll();
            TransCounter := 0;
            CustCounter := 0;
            ItemCounter := 0;
            catcounter := 0;
            prodcounter := 0;
            StaffCounter := 0;

            DiscountCounter := 0;
            ReturnCounter := 0;
            TotalSales := 0;
            TotalTrans := 0;
        end else begin
            if ReturnCounter <> 0 then begin
                TopList.SetRange(Type, TopList.Type::Return);
                TopList.Find('-');
                Rec := TopList;
                TotalTrans := TotalTransInfocode[8];
                TotalSales := TotalSalesInfocode[8];
                exit;
            end;
            TotalSales := 0;
            TotalTrans := 0;
        end;

        Window.Open(
          CounterTxt + '          ' + ' #1########\' +
          TotalRecTxt + ' #2########');


        InfocodeEntry.SetCurrentKey(Infocode, Subcode, Date);
        InfocodeEntry.SetRange(Infocode, ReturnInfocode);
        InfocodeEntry.SetFilter(Date, Rec.GetFilter("Date Filter"));
        InfocodeEntry.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
        Window.Update(2, InfocodeEntry.Count);

        if InfocodeEntry.Find('-') then
            repeat
                Counter += 1;
                if (Counter mod 100) = 0 then
                    Window.Update(1, Counter);

                if not TopList.Get(TopList.Type::Return, '', '', Format(InfocodeEntry.Subcode)) then begin
                    TopList.Init();
                    TopList."Store No." := '';
                    TopList."POS Terminal No." := '';
                    TopList.Type := TopList.Type::Return;
                    TopList."No." := Format(InfocodeEntry.Subcode);

                    if InfoSubcode.Get(ReturnInfocode, TopList."No.") then
                        TopList.Description := InfoSubcode.Description;

                    TopList.Insert();
                end;
                case InfocodeEntry."Transaction Type" of
                    InfocodeEntry."Transaction Type"::Header:
                        if TransHead.Get(InfocodeEntry."Store No.", InfocodeEntry."POS Terminal No.", InfocodeEntry."Transaction No.") then begin
                            TopList."Qty." := TopList."Qty." - TransHead."No. of Items";
                            TopList.Amount := TopList.Amount - TransHead."Net Amount";
                            TopList."Discount Amount" := TopList."Discount Amount" + TransHead."Discount Amount";
                            TopList."Cost Amount" := TopList."Cost Amount" + TransHead."Cost Amount";
                            TotalSales += -TransHead."Net Amount";
                        end;
                    InfocodeEntry."Transaction Type"::"Sales Entry":
                        if TransSalesEntry.Get(
                            InfocodeEntry."Store No.", InfocodeEntry."POS Terminal No.", InfocodeEntry."Transaction No.", InfocodeEntry."Line No.")
                        then begin
                            TopList."Qty." := TopList."Qty." - TransSalesEntry.Quantity;
                            TopList.Amount := TopList.Amount - TransSalesEntry."Net Amount";
                            TopList."Discount Amount" := TopList."Discount Amount" + TransSalesEntry."Discount Amount";
                            TopList."Cost Amount" := TopList."Cost Amount" + TransSalesEntry."Cost Amount";
                            TotalSales += -TransSalesEntry."Net Amount";
                        end;
                end;
                TopList.Profit := TopList.Amount + TopList."Cost Amount";
                TopList.Modify();
            until InfocodeEntry.Next() = 0;

        Window.Close();
        FilterChange := false;
        RefreshText := '';

        ReturnCounter := Counter;
        TopList.SetRange(Type, TopList.Type::Return);

        if not TopList.Find('-') then
            Error(NoDataErr)
        else
            Rec := TopList;

        TotalTrans := CountTotalTrans(ReturnInfocode);
        TotalTransInfocode[8] := TotalTrans;
        TotalSalesInfocode[8] := TotalSales;
    end;

    local procedure CountTotalTrans(InfocodeFilter: Text): Integer
    var
        CountTransHeaderQry: Query "GXL Count Transaction Header";
        NoOfTrans: Integer;
    begin
        CountTransHeaderQry.SetFilter(Store_No_, Rec.GetFilter("Store Filter"));
        CountTransHeaderQry.SetFilter(Date, Rec.GetFilter("Date Filter"));
        CountTransHeaderQry.SetFilter(Infocode, InfocodeFilter);
        CountTransHeaderQry.Open();
        if CountTransHeaderQry.Read() then
            NoOfTrans := CountTransHeaderQry.NoOfTransactions;
        CountTransHeaderQry.Close();
        exit(NoOfTrans);
    end;

    //PS-1951-
}

