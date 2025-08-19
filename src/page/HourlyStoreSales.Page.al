page 50022 "GXL Hourly Store Sales"
{
    ApplicationArea = All;
    Caption = 'Hourly Store Sales';
    PageType = Worksheet;
    SaveValues = false;
    SourceTable = "LSC Statistics Time Setup";
    SourceTableTemporary = true;
    UsageCategory = ReportsAndAnalysis;

    layout
    {
        area(content)
        {
            group(Options)
            {
                Caption = 'Options';
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Date Filter';

                    trigger OnValidate()
                    begin
                        //>>upgrades
                        //ApplicationManagement.MakeDateFilter(DateFilter) = 0 then;
                        ApplicationManagement.MakeDateFilter(DateFilter);
                        //<<upgrades
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
                field(DisplayOption; DisplayOption)
                {
                    ApplicationArea = All;
                    Caption = 'Display';
                    OptionCaption = 'Gross Sales,No. of Items,No. of Transactions,Average No. of Items,Average Amount';

                    trigger OnValidate()
                    begin
                        DisplayOptionOnAfterValidate();
                    end;
                }
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = All;
                    Caption = 'View by';
                    OptionCaption = 'Day,Week,Month,Quarter,Year,Accounting Period';
                    ToolTip = 'Day';

                    trigger OnValidate()
                    begin
                        if PeriodType = PeriodType::"Accounting Period" then
                            AccountingPerioPeriodTypeOnVal();
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
            group(General)
            {
                Caption = 'General';
                repeater(Control1100409005)
                {
                    ShowCaption = false;
                    field(TimePeriod; TimePeriod)
                    {
                        ApplicationArea = All;
                        Caption = 'Time Period';
                    }
                    field("Start Time"; Rec."Start Time")
                    {
                        ApplicationArea = All;
                        Visible = false;
                    }
                    field("End Time"; Rec."End Time")
                    {
                        ApplicationArea = All;
                        Visible = false;
                    }
                    field(Col1; CellValue[1])
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        CaptionClass = LoadCaption(1);
                        Editable = Col1Editable;
                    }
                    field(Col2; CellValue[2])
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        CaptionClass = LoadCaption(2);
                        Editable = Col2Editable;
                    }
                    field(Col3; CellValue[3])
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        CaptionClass = LoadCaption(3);
                        Editable = Col3Editable;
                    }
                    field(Col4; CellValue[4])
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        CaptionClass = LoadCaption(4);
                        Editable = Col4Editable;
                    }
                    field(Col5; CellValue[5])
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        CaptionClass = LoadCaption(5);
                        Editable = Col5Editable;
                    }
                    field(Col6; CellValue[6])
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        CaptionClass = LoadCaption(6);
                        Editable = Col6Editable;
                    }
                    field(Col7; CellValue[7])
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        CaptionClass = LoadCaption(7);
                        Editable = Col7Editable;
                    }
                    field(Col8; CellValue[8])
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        CaptionClass = LoadCaption(8);
                        Editable = Col8Editable;
                    }
                    field(Col9; CellValue[9])
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        CaptionClass = LoadCaption(9);
                        Editable = Col9Editable;
                    }
                    field(Col10; CellValue[10])
                    {
                        ApplicationArea = All;
                        BlankZero = true;
                        CaptionClass = LoadCaption(10);
                        Editable = Col10Editable;
                    }
                }
            }
            group("Single Store")
            {
                Caption = 'Single Store';
                field(SelectedStore; SelectedStore)
                {
                    ApplicationArea = All;
                    Caption = 'Selected Store:';
                    TableRelation = "LSC Store";
                    Editable = StoreFilterEditable;

                    trigger OnValidate()
                    begin
                        if Store.Get(SelectedStore) then
                            SelectedStoreName := Store.Name
                        else
                            SelectedStoreName := '';

                        CurrPage.StoreHourlyDistributionForm.PAGE.SetFilters(SelectedStore, HourlySales);
                        SelectedStoreOnAfterValidate();
                    end;
                }
                field(SelectedStoreName; SelectedStoreName)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            part(StoreHourlyDistributionForm; "LSC Store Hourly Distribution")
            {
                ApplicationArea = All;
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
            action("Previous Set")
            {
                ApplicationArea = All;
                Caption = 'Previous Set';
                Image = PreviousSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Previous Set';

                trigger OnAction()
                begin
                    if MatrixUtility.PrevCol(MaxMatrixBuffer, MatrixBufferCol) then begin
                        CurrPage.Update(false);
                    end;
                end;
            }
            action("Next Set")
            {
                ApplicationArea = All;
                Caption = 'Next Set';
                Image = NextSet;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ToolTip = 'Next Set';

                trigger OnAction()
                begin
                    if MatrixUtility.NextCol(MaxMatrixBuffer, MatrixBufferCol) then begin
                        CurrPage.Update(false);
                    end;
                end;
            }
            action("&Update")
            {
                ApplicationArea = All;
                Caption = '&Update';
                Image = RefreshLines;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                begin
                    FillBuffer();
                end;
            }
            action(Chart)
            {
                ApplicationArea = All;
                Caption = 'Chart';
                Image = BarChart;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    StoreRecTmp: Record "LSC Store" temporary;
                    Codevalue: Code[20];
                begin
                    HourlySales.Reset();
                    if HourlySales.IsEmpty() then
                        exit;

                    //Find which stores shall be included in the chart
                    MatrixBufferCol.Reset();
                    if MatrixBufferCol.FindSet() then begin
                        RecRefCol.Open(MatrixBufferCol."Column Table No.");
                        repeat
                            RecRefCol.SetPosition(MatrixBufferCol."Column RecordID");
                            FieldRefCol := RecRefCol.Field(MatrixBufferCol."Column Field No.");
                            Codevalue := FieldRefCol.Value;
                            StoreRecTmp.Init();
                            StoreRecTmp."No." := Codevalue;
                            StoreRecTmp.Insert();
                        until MatrixBufferCol.Next() = 0;
                        RecRefCol.Close();
                    end;

                    //Display chart
                    Clear(HourlySalesChart);
                    HourlySalesChart.LoadData(HourlySales, DisplayOption, DateFilter, StoreRecTmp); //LS-TICKET:LSTS-27115
                    HourlySalesChart.RunModal();
                end;
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        LimitUserAccess();
        if Rec."Start Time" > 235959T then
            TimePeriod := Text001Txt
        else
            TimePeriod := StrSubstNo('%1 - %2', Rec."Start Time", Rec."End Time");

        LoadMatrix();
        CellValue1OnFormat(Format(CellValue[1]));
        CellValue2OnFormat(Format(CellValue[2]));
        CellValue3OnFormat(Format(CellValue[3]));
        CellValue4OnFormat(Format(CellValue[4]));
        CellValue5OnFormat(Format(CellValue[5]));
        CellValue6OnFormat(Format(CellValue[6]));
        CellValue7OnFormat(Format(CellValue[7]));
        CellValue8OnFormat(Format(CellValue[8]));
        CellValue9OnFormat(Format(CellValue[9]));
        CellValue10OnFormat(Format(CellValue[10]));
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        LimitUserAccess();
        DateFilter := Rec.GetFilter("Date Filter");
        StoreFilter := Rec.GetFilter("Store Filter");

        SkipLoad := true;
        LoadColVisible();
        SkipLoad := false;
        exit(Rec.Find(Which));
    end;

    trigger OnInit()
    begin
        CurrPage.LookupMode := false;
        Col10Editable := true;
        Col9Editable := true;
        Col8Editable := true;
        Col7Editable := true;
        Col6Editable := true;
        Col5Editable := true;
        Col4Editable := true;
        Col3Editable := true;
        Col2Editable := true;
        Col1Editable := true;
    end;

    trigger OnOpenPage()
    begin
        if not RetailUser.Get(UserId()) then
            Clear(RetailUser);
        LimitUserAccess();

        StatisticsTimeSetup.Reset();
        if StatisticsTimeSetup.Find('-') then
            repeat
                Rec.Init();
                Rec := StatisticsTimeSetup;
                Rec.Insert();
            until StatisticsTimeSetup.Next() = 0;

        StatisticsTimeSetup."Start Time" := 235959T + 999;
        if not Rec.Get(StatisticsTimeSetup."Start Time") then begin
            Rec.Init();
            Rec."Start Time" := StatisticsTimeSetup."Start Time";
            Rec.Insert();
        end;

        if Rec.Find('-') then;

        StoreType := 'All';
        ValidateStoreFilter();
        if Rec.GetFilter("Store Filter") <> '' then
            Store.SetFilter("No.", Rec.GetFilter("Store Filter"));
        if Store.Find('-') then begin
            SelectedStore := Store."No.";
            SelectedStoreName := Store.Name;
            CurrPage.StoreHourlyDistributionForm.PAGE.SetFilters(SelectedStore, HourlySales);
            SelectedStoreOnAfterValidate();
        end;
    end;

    var
        RetailUser: Record "LSC Retail User";
        HourlySales: Record "LSC Hourly Distr Work Table" temporary;
        Calendar: Record Date;
        Store: Record "LSC Store";
        StatisticsTimeSetup: Record "LSC Statistics Time Setup";
        MatrixBufferCol: Record "LSC Matrix Column Buffer" temporary;
        MatrixUtility: Codeunit "LSC Matrix Utility"; //LS-TICKET:LSTS-27115
        //>>upgrade
        //ApplicationManagement: Codeunit TextManagement;
        ApplicationManagement: Codeunit "filter tokens";
        //<<upgrade
        HourlySalesChart: Page "LSC Hourly Store Sales Chart";
        RecRef: RecordRef;
        RecRefCol: RecordRef;
        FieldRefCol: FieldRef;
        RoundingFactor: Option "None","1","1000","1000000";
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        AmountType: Option "Net Change","Balance at Date";
        DisplayOption: Option "Gross Sales","No. of Items","No. of Transactions","Average No. of Items","Average Amount";
        StoreType: Code[10];
        StoreFilter: Text[30];
        Amount: Decimal;
        SelectedStore: Code[10];
        SelectedStoreName: Text[100];
        GlobalAmt: Decimal;
        MaxMatrixBuffer: Integer;
        CellValue: array[32] of Decimal;
        SkipLoad: Boolean;
        Text001Txt: Label '*Total';
        Text020Txt: Label 'Column %1 is out of range';
        DateFilter: Text[30];
        [InDataSet]
        Col1Editable: Boolean;
        [InDataSet]
        Col2Editable: Boolean;
        [InDataSet]
        Col3Editable: Boolean;
        [InDataSet]
        Col4Editable: Boolean;
        [InDataSet]
        Col5Editable: Boolean;
        [InDataSet]
        Col6Editable: Boolean;
        [InDataSet]
        Col7Editable: Boolean;
        [InDataSet]
        Col8Editable: Boolean;
        [InDataSet]
        Col9Editable: Boolean;
        [InDataSet]
        Col10Editable: Boolean;
        TimePeriod: Text;
        StoreFilterEditable: Boolean;

    [Scope('OnPrem')]
    procedure FillBuffer()
    var
        TransHeader: Record "LSC Transaction Header";
        Window: Dialog;
        TotalTrans: Integer;
        Counter: Integer;
    begin
        Clear(HourlySales);
        HourlySales.DeleteAll();
        Counter := 0;

        Window.Open(
          'Number of Transactions #1###########\' +
          'Processed              #2###########');

        TransHeader.Reset();
        TransHeader.SetCurrentKey("Transaction Type", "Entry Status", Date);
        TransHeader.SetRange("Transaction Type", TransHeader."Transaction Type"::Sales);
        TransHeader.SetFilter("Entry Status", '%1|%2', TransHeader."Entry Status"::" ", TransHeader."Entry Status"::Posted);
        TransHeader.SetFilter(Date, Rec.GetFilter("Date Filter"));
        TransHeader.SetFilter("Store No.", Rec.GetFilter("Store Filter"));
        TotalTrans := TransHeader.Count();
        Window.Update(1, TotalTrans);

        if TransHeader.Find('-') then
            repeat

                Counter += 1;
                if (Counter mod 100) = 0 then
                    Window.Update(2, Counter);

                /*
                dtime := TransHeader.Time - 000000T;
                dtime := dtime / (60 * 60000);
                dtime := ROUND(dtime,1.0,'<');
                dtime := dtime * 60 * 60000;
                ttime := 000000T + dtime;

                HourlySales.Init();
                HourlySales.Type := HourlySales.Type::Store;
                HourlySales."No." := TransHeader."Store No.";
                HourlySales.Time := ttime;
                IF NOT HourlySales.FIND('=') THEN
                  HourlySales.INSERT;
                */
                HourlySales.Init();
                HourlySales.Type := HourlySales.Type::Store;
                HourlySales."No." := TransHeader."Store No.";
                StatisticsTimeSetup.SetFilter("Start Time", '<=%1', TransHeader.Time);
                if StatisticsTimeSetup.FindLast() then
                    HourlySales.Time := StatisticsTimeSetup."Start Time"
                else
                    HourlySales.Time := 235959T;
                if not HourlySales.Get(HourlySales.Type, HourlySales."No.", HourlySales.Time) then
                    HourlySales.Insert();

                HourlySales."Gross Amount" := HourlySales."Gross Amount" - TransHeader."Gross Amount";
                HourlySales."No. of Items" := HourlySales."No. of Items" + TransHeader."No. of Items";
                HourlySales."Sales Transactions" := HourlySales."Sales Transactions" + 1;
                HourlySales.Modify();

            until TransHeader.Next() = 0;
        CurrPage.StoreHourlyDistributionForm.PAGE.SetFilters(SelectedStore, HourlySales);
        CurrPage.Update(true);

    end;

    local procedure FormatAmount(var Text: Text[250])
    var
        AmountL: Decimal;
    begin
        /*
        IF (DisplayOption IN [DisplayOption::"No. of Items",DisplayOption::"No. of Transactions"]) AND
           (Text <> '') THEN BEGIN
          {
          EVALUATE(Amount,Text);
          Text := FORMAT(Amount);
          }
          CASE DisplayOption OF
            DisplayOption::"No. of Items" :
              Text := FORMAT(ROUND(GlobalAmt,0.00001),0,'<Integer Thousand><Decimals>');
            DisplayOption::"No. of Transactions" :
              Text := FORMAT(GlobalAmt);
          END;
          EXIT;
        END;
        */

        if (Text = '') or (RoundingFactor = RoundingFactor::None) then
            exit;
        Evaluate(AmountL, Text);
        case RoundingFactor of
            RoundingFactor::"1":
                AmountL := Round(AmountL, 1);
            RoundingFactor::"1000":
                AmountL := Round(AmountL / 1000, 0.1);
            RoundingFactor::"1000000":
                AmountL := Round(AmountL / 1000000, 0.1);
        end;
        if AmountL = 0 then
            Text := ''
        else
            case RoundingFactor of
                RoundingFactor::"1":
                    Text := Format(AmountL);
                RoundingFactor::"1000", RoundingFactor::"1000000":
                    Text := Format(AmountL, 0, '<Sign><Integer Thousand><Decimals,2>');
            end;

    end;

    local procedure FindPeriod(SearchText: Code[10])
    var
        // >> Upgrade
        //PeriodFormManagement: Codeunit PeriodFormManagement;
        PeriodFormManagement: Codeunit PeriodPageManagement;
    // << Upgrade
    begin
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
    end;

    [Scope('OnPrem')]
    procedure ValidateStoreFilter()
    var
        MatrixStore: Record "LSC Store";
    begin
        if Rec.GetFilter("Store Filter") <> '' then
            MatrixStore.SetFilter("No.", Rec.GetFilter("Store Filter"))
        else
            MatrixStore.SetRange("No.");
        MaxMatrixBuffer := 10;
        RecRef.GetTable(MatrixStore);
        MatrixUtility.InitCol(RecRef, MatrixStore.FieldNo("No."), MaxMatrixBuffer, MatrixBufferCol);
        Refresh();
    end;

    [Scope('OnPrem')]
    procedure CalculateView(pStoreNo: Code[20])
    var
        //>>upgrade
        //HourlySalesTotal: Record " Hourly Distribution Work Table";
        HourlySalesTotal: Record "LSC Hourly Distr Work Table";
    //<<upgrade
    begin
        if Rec."Start Time" > 235959T then begin
            Clear(HourlySalesTotal);
            HourlySales.SetRange(Type, HourlySales.Type::Store);
            HourlySales.SetRange("No.", pStoreNo);
            HourlySales.SetRange(Time);
            if HourlySales.FindSet() then
                repeat
                    HourlySalesTotal."Gross Amount" := HourlySalesTotal."Gross Amount" +
                      HourlySales."Gross Amount";
                    HourlySalesTotal."No. of Items" := HourlySalesTotal."No. of Items" +
                      HourlySales."No. of Items";
                    HourlySalesTotal."Sales Transactions" := HourlySalesTotal."Sales Transactions" +
                      HourlySales."Sales Transactions";
                until HourlySales.Next() = 0;
            case DisplayOption of
                DisplayOption::"Gross Sales":
                    Amount := HourlySalesTotal."Gross Amount";
                DisplayOption::"No. of Items":
                    Amount := HourlySalesTotal."No. of Items";
                DisplayOption::"No. of Transactions":
                    Amount := HourlySalesTotal."Sales Transactions";
                DisplayOption::"Average No. of Items":
                    begin
                        if HourlySalesTotal."Sales Transactions" <> 0 then
                            Amount := HourlySalesTotal."No. of Items" / HourlySalesTotal."Sales Transactions"
                        else
                            Amount := 0;
                    end;
                DisplayOption::"Average Amount":
                    begin
                        if HourlySalesTotal."Sales Transactions" <> 0 then
                            Amount := HourlySalesTotal."Gross Amount" / HourlySalesTotal."Sales Transactions"
                        else
                            Amount := 0;
                    end;
            end;
        end
        else
            if HourlySales.Get(HourlySales.Type::Store, pStoreNo, Rec."Start Time") then begin
                case DisplayOption of
                    DisplayOption::"Gross Sales":
                        Amount := HourlySales."Gross Amount";
                    DisplayOption::"No. of Items":
                        Amount := HourlySales."No. of Items";
                    DisplayOption::"No. of Transactions":
                        Amount := HourlySales."Sales Transactions";
                    DisplayOption::"Average No. of Items":
                        begin
                            if HourlySales."Sales Transactions" <> 0 then
                                Amount := HourlySales."No. of Items" / HourlySales."Sales Transactions"
                            else
                                Amount := 0;
                        end;
                    DisplayOption::"Average Amount":
                        begin
                            if HourlySales."Sales Transactions" <> 0 then
                                Amount := HourlySales."Gross Amount" / HourlySales."Sales Transactions"
                            else
                                Amount := 0;
                        end;
                end;
            end else
                Amount := 0;

        GlobalAmt := Amount;
    end;

    [Scope('OnPrem')]
    procedure Refresh()
    begin
        CurrPage.Update(false);
    end;

    [Scope('OnPrem')]
    procedure LoadCaption(pFieldNo: Integer): Text[80]
    begin
        if MatrixBufferCol.Get(pFieldNo) then
            exit('3,' + MatrixBufferCol."Column Caption")
        else
            exit('3, ');
    end;

    [Scope('OnPrem')]
    procedure LoadColVisible()
    begin
        Col1Editable := false;
        Col2Editable := false;
        Col3Editable := false;
        Col4Editable := false;
        Col5Editable := false;
        Col6Editable := false;
        Col7Editable := false;
        Col8Editable := false;
        Col9Editable := false;
        Col10Editable := false;
    end;

    [Scope('OnPrem')]
    procedure LoadMatrix()
    var
        CodeValue: Code[20];
    begin
        Clear(CellValue);

        if SkipLoad then
            exit;

        MatrixBufferCol.Reset();
        if MatrixBufferCol.FindSet() then begin
            RecRefCol.Open(MatrixBufferCol."Column Table No.");
            repeat
                RecRefCol.SetPosition(MatrixBufferCol."Column RecordID");
                FieldRefCol := RecRefCol.Field(MatrixBufferCol."Column Field No.");
                CodeValue := FieldRefCol.Value;

                CalculateView(CodeValue);
                CellValue[MatrixBufferCol."Column No."] := GlobalAmt;

            until MatrixBufferCol.Next() = 0;
            RecRefCol.Close();
        end;
    end;

    [Scope('OnPrem')]
    procedure ValidateCell(pColumnNo: Integer)
    var
        CodeValue: Code[20];
    begin
        if not MatrixBufferCol.Get(pColumnNo) then begin
            Error(Text020Txt, pColumnNo);
        end else begin
            RecRefCol.Open(MatrixBufferCol."Column Table No.");
            RecRefCol.SetPosition(MatrixBufferCol."Column RecordID");
            FieldRefCol := RecRefCol.Field(MatrixBufferCol."Column Field No.");
            CodeValue := FieldRefCol.Value;
            RecRefCol.Close();

        end;
    end;

    local procedure DateFilterOnAfterValidate()
    begin
        Refresh();
    end;

    local procedure StoreFilterOnAfterValidate()
    begin
        ValidateStoreFilter();
    end;

    local procedure RoundingFactorOnAfterValidate()
    begin
        Refresh();
    end;

    local procedure DisplayOptionOnAfterValidate()
    begin
        Refresh();
    end;

    local procedure BalanceatDateAmountTypeOnAfter()
    begin
        Refresh();
    end;

    local procedure NetChangeAmountTypeOnAfterVali()
    begin
        Refresh();
    end;

    local procedure AccountingPerioPeriodTypeOnAft()
    begin
        Refresh();
    end;

    local procedure YearPeriodTypeOnAfterValidate()
    begin
        Refresh();
    end;

    local procedure QuarterPeriodTypeOnAfterValida()
    begin
        Refresh();
    end;

    local procedure MonthPeriodTypeOnAfterValidate()
    begin
        Refresh();
    end;

    local procedure WeekPeriodTypeOnAfterValidate()
    begin
        Refresh();
    end;

    local procedure DayPeriodTypeOnAfterValidate()
    begin
        Refresh();
    end;

    local procedure SelectedStoreOnAfterValidate()
    begin
        CurrPage.Update(false);
    end;

    local procedure YearPeriodTypeOnPush()
    begin
        FindPeriod('>=');
    end;

    local procedure QuarterPeriodTypeOnPush()
    begin
        FindPeriod('>=');
    end;

    local procedure MonthPeriodTypeOnPush()
    begin
        FindPeriod('>=');
    end;

    local procedure WeekPeriodTypeOnPush()
    begin
        FindPeriod('>=');
    end;

    local procedure DayPeriodTypeOnPush()
    begin
        FindPeriod('>=');
    end;

    local procedure CellValue1OnFormat(Text: Text[1024])
    begin
        FormatAmount(Text);
    end;

    local procedure CellValue2OnFormat(Text: Text[1024])
    begin
        FormatAmount(Text);
    end;

    local procedure CellValue3OnFormat(Text: Text[1024])
    begin
        FormatAmount(Text);
    end;

    local procedure CellValue4OnFormat(Text: Text[1024])
    begin
        FormatAmount(Text);
    end;

    local procedure CellValue5OnFormat(Text: Text[1024])
    begin
        FormatAmount(Text);
    end;

    local procedure CellValue6OnFormat(Text: Text[1024])
    begin
        FormatAmount(Text);
    end;

    local procedure CellValue7OnFormat(Text: Text[1024])
    begin
        FormatAmount(Text);
    end;

    local procedure CellValue8OnFormat(Text: Text[1024])
    begin
        FormatAmount(Text);
    end;

    local procedure CellValue9OnFormat(Text: Text[1024])
    begin
        FormatAmount(Text);
    end;

    local procedure CellValue10OnFormat(Text: Text[1024])
    begin
        FormatAmount(Text);
    end;

    local procedure DayPeriodTypeOnValidate()
    begin
        DayPeriodTypeOnPush();
        DayPeriodTypeOnAfterValidate();
    end;

    local procedure WeekPeriodTypeOnValidate()
    begin
        WeekPeriodTypeOnPush();
        WeekPeriodTypeOnAfterValidate();
    end;

    local procedure MonthPeriodTypeOnValidate()
    begin
        MonthPeriodTypeOnPush();
        MonthPeriodTypeOnAfterValidate();
    end;

    local procedure QuarterPeriodTypeOnValidate()
    begin
        QuarterPeriodTypeOnPush();
        QuarterPeriodTypeOnAfterValida();
    end;

    local procedure YearPeriodTypeOnValidate()
    begin
        YearPeriodTypeOnPush();
        YearPeriodTypeOnAfterValidate();
    end;

    local procedure AccountingPerioPeriodTypeOnVal()
    begin
        AccountingPerioPeriodTypeOnAft();
    end;

    local procedure NetChangeAmountTypeOnValidate()
    begin
        NetChangeAmountTypeOnAfterVali();
    end;

    local procedure BalanceatDateAmountTypeOnValid()
    begin
        BalanceatDateAmountTypeOnAfter();
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
}

