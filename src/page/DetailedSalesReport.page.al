/* Change Log
    PS-2400 New Reports
*/
page 50032 "GXL Detailed Sales Report"
{

    ApplicationArea = All;
    Caption = 'Detailed Sales Report';
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
                    OptionCaption = ',Transaction,Division,Category,Item,Staff,Subcode';

                    trigger OnValidate()
                    begin
                        if ReportType = ReportType::" " then
                            ReportType := ReportType::Transaction;
                        if ReportType <> OldReportType then
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
                        // >> Upgrade
                        //if ApplicationManagement.MakeDateFilter(DateFilter) = 0 then;
                        ApplicationManagement.MakeDateFilter(DateFilter);
                        // << Upgrade
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
                field(ItemFilter; ItemFilter)
                {
                    ApplicationArea = All;
                    Caption = 'Item No. Filter';

                    trigger OnValidate()
                    begin
                        Rec.SetFilter("Item Filter", ItemFilter);
                        FilterOnAfterValidate();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ItemList: Page "Item List";
                    begin
                        ItemList.LookupMode := true;
                        if ItemList.RunModal() = Action::LookupOK then
                            Text := ItemList.GetSelectionFilter()
                        else
                            exit(false);
                        exit(true);
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
                field("Total Net Amount"; TotalNet)
                {
                    ApplicationArea = All;
                    AutoFormatType = 1;
                    Editable = false;
                }
                field("Total Discount Amount"; TotalDiscount)
                {
                    ApplicationArea = All;
                    AutoFormatType = 1;
                    Editable = false;
                }
                field("Total GST Amount"; TotalGST)
                {
                    ApplicationArea = All;
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
                }
                field(Price; Rec.Price)
                {
                    ApplicationArea = All;
                }
                field("Net Amount"; Rec."Net Amount")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                }
                field("GST Amount"; Rec."GST Amount")
                {
                    ApplicationArea = All;
                }
                field("Staff Name"; Rec."Staff Name")
                {
                    ApplicationArea = All;
                    Visible = ReportType = ReportType::Transaction;
                }
                field(Infocode; Rec.Infocode)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Reason Code"; Rec."Reason Code")
                {
                    ApplicationArea = All;
                    Caption = 'Subcode';
                    Visible = false;
                }
                field("Subcode Description"; Rec."Subcode Description")
                {
                    ApplicationArea = All;
                    Visible = ReportType = ReportType::Transaction;
                }
                field("Transaction No."; Rec."Transaction No.")
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
                    Rec.SetRange("Item Category Filter");
                    CalcItem(Rec);
                end;
            }
            group(FilterByCat)
            {
                Caption = 'Item Category';
                action(Grooming)
                {
                    ApplicationArea = All;
                    Caption = 'Grooming';
                    Image = ShowMatrix;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        SupplyChainSetup.TestField("Item Category - Grooming");
                        Rec.SetFilter("Item Category Filter", SupplyChainSetup."Item Category - Grooming");
                        FilterOnAfterValidate();
                        CalcItem(Rec);
                    end;
                }
                action(DIY)
                {
                    ApplicationArea = All;
                    Caption = 'DIY';
                    Image = ShowMatrix;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        SupplyChainSetup.TestField("Item Category - DIY");
                        Rec.SetFilter("Item Category Filter", SupplyChainSetup."Item Category - DIY");
                        FilterOnAfterValidate();
                        CalcItem(Rec);
                    end;
                }
                action(Charity)
                {
                    ApplicationArea = All;
                    Caption = 'Charity';
                    Image = ShowMatrix;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        SupplyChainSetup.TestField("Item Category - Charity");
                        Rec.SetFilter("Item Category Filter", SupplyChainSetup."Item Category - Charity");
                        FilterOnAfterValidate();
                        CalcItem(Rec);
                    end;
                }
                action(CharityGroupByStaff)
                {
                    ApplicationArea = All;
                    Caption = 'Charity - By Staff';
                    Image = ShowMatrix;
                    Promoted = true;
                    PromotedCategory = Process;

                    trigger OnAction()
                    begin
                        SupplyChainSetup.TestField("Item Category - Charity");
                        Rec.SetFilter("Item Category Filter", SupplyChainSetup."Item Category - Charity");
                        ReportType := ReportType::Staff;
                        FilterOnAfterValidate();
                        CalcItem(Rec);
                    end;
                }
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
        if SupplyChainSetup.Get() then;

        FilterChange := true;
        RefreshText := RefreshTxt;

        ReportType := ReportType::Transaction;
        OldReportType := OldReportType::" ";
        TotalNet := 0;
        TotalDiscount := 0;
        TotalGST := 0;
        ItemCounter := 0;

        TempDivision.Reset();
        TempDivision.DeleteAll();
        TempItemCat.Reset();
        TempItemCat.DeleteAll();
        TempItem.Reset();
        TempItem.DeleteAll();
        TempStaff.Reset();
        TempStaff.DeleteAll();
        TempInfoSubcode.Reset();
        TempInfoSubcode.DeleteAll();
    end;

    var
        SupplyChainSetup: Record "GXL Supply Chain Setup";
        Calendar: Record Date;
        RetailUser: Record "LSC Retail User";
        TempItem: Record Item temporary;
        TempStaff: Record "LSC Staff" temporary;
        TempDivision: Record "LSC Division" temporary;
        TempItemCat: Record "Item Category" temporary;
        TempInfoSubcode: Record "LSC Information Subcode" temporary;
        // >> Upgrade
        //ApplicationManagement: Codeunit TextManagement;
        ApplicationManagement: Codeunit "Filter Tokens";
        // << Upgrade
        PeriodType: Option Day,Week,Month,Quarter,Year,"Accounting Period";
        AmountType: Option "Net Change","Balance at Date";
        SortOrder: Boolean;
        FilterChange: Boolean;
        Window: Dialog;
        ItemCounter: Integer;
        DateFilter: Text[30];
        StoreFilter: Text[250];
        ItemCatFilter: Text[250];
        ItemFilter: Text[250];
        StaffIDFilter: Text[250];
        RefreshText: Text[30];
        SalesInvtReportBuffCurrentKey: Text;
        StoreFilterEditable: Boolean;
        TotalNet: Decimal;
        TotalDiscount: Decimal;
        TotalGST: Decimal;
        ReportType: Option " ",Transaction,Division,Category,Item,Staff,"Reason Code";
        OldReportType: Option " ",Transaction,Division,Category,Item,Staff,"Reason Code";
        RefreshTxt: Label 'Refresh Needed';
        TotalRecTxt: Label 'Number of Records';
        CounterTxt: Label 'Counter';
        RcptTxt: Label 'Receipt ';
        NoDataErr: Label 'There is no data within the selected period';


    local procedure CalcItem(var SalesInvtReportBuff: Record "GXL Sales/Invt Report Buffer" temporary)
    var
        SalesEntry: Record "LSC Trans. Sales Entry";
        Item: Record Item;
        TransInfocodeEntry: Record "LSC Trans. Infocode Entry";
        Staff: Record "LSC Staff";
        Division: Record "LSC Division";
        ItemCat: Record "Item Category";
        InfoSubcode: Record "LSC Information Subcode";
        OldSalesInvtReportBuff: Record "GXL Sales/Invt Report Buffer";
        Counter: Integer;
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

        SalesInvtReportBuff.Reset();
        SalesInvtReportBuff.SetFilter("Date Filter", OldSalesInvtReportBuff.GetFilter("Date Filter"));
        SalesInvtReportBuff.SetFilter("Store Filter", OldSalesInvtReportBuff.GetFilter("Store Filter"));
        SalesInvtReportBuff.SetFilter("Item Filter", OldSalesInvtReportBuff.GetFilter("Item Filter"));
        SalesInvtReportBuff.SetFilter("Item Category Filter", OldSalesInvtReportBuff.GetFilter("Item Category Filter"));
        OldSalesInvtReportBuff.Reset();
        OldSalesInvtReportBuff.Copy(SalesInvtReportBuff);

        Window.Open(
          CounterTxt + '          ' + ' #1########\' +
          TotalRecTxt + ' #2########');

        SalesEntry.Reset();
        SalesEntry.SetCurrentKey(Date);
        SalesEntry.SetFilter(Date, SalesInvtReportBuff.GetFilter("Date Filter"));
        SalesEntry.SetFilter("Store No.", SalesInvtReportBuff.GetFilter("Store Filter"));
        SalesEntry.SetFilter("Item Category Code", SalesInvtReportBuff.GetFilter("Item Category Filter"));
        SalesEntry.SetFilter("Item No.", SalesInvtReportBuff.GetFilter("Item Filter"));
        Window.Update(2, SalesEntry.Count);

        TotalNet := 0;
        TotalDiscount := 0;
        TotalGST := 0;
        if SalesEntry.Find('-') then
            repeat
                Counter += 1;
                if (Counter mod 100) = 0 then
                    Window.Update(1, Counter);

                if not TempItem.Get(SalesEntry."Item No.") then begin
                    if Item.Get(SalesEntry."Item No.") then
                        TempItem := Item
                    else begin
                        TempItem.Init();
                        TempItem."No." := SalesEntry."Item No.";
                    end;
                    if TempItem.Description = '' then
                        TempItem.Description := TempItem."No.";
                    TempItem.Insert();
                end;
                if SalesEntry."Staff ID" <> '' then
                    if not TempStaff.Get(SalesEntry."Staff ID") then begin
                        if Staff.Get(SalesEntry."Staff ID") then
                            TempStaff := Staff
                        else begin
                            TempStaff.Init();
                            TempStaff.ID := SalesEntry."Staff ID";
                        end;
                        if TempStaff."Name on Receipt" = '' then
                            TempStaff."Name on Receipt" := TempStaff.ID;
                        TempStaff.Insert();
                    end;
                if TempItem."LSC Division Code" <> '' then
                    if not TempDivision.Get(TempItem."LSC Division Code") then begin
                        if Division.Get(TempItem."LSC Division Code") then
                            TempDivision := Division
                        else begin
                            TempDivision.Init();
                            TempDivision.Code := TempItem."LSC Division Code";
                        end;
                        if TempDivision.Description = '' then
                            TempDivision.Description := TempDivision.Code;
                        TempDivision.Insert();
                    end;
                if SalesEntry."Item Category Code" <> '' then
                    if not TempItemCat.Get(SalesEntry."Item Category Code") then begin
                        if ItemCat.Get(SalesEntry."Item Category Code") then
                            TempItemCat := ItemCat
                        else begin
                            TempItemCat.Init();
                            TempItemCat.Code := SalesEntry."Item Category Code";
                        end;
                        if TempItemCat.Description = '' then
                            TempItemCat.Description := TempItemCat.Code;
                        TempItemCat.Insert();
                    end;

                Clear(TransInfocodeEntry);
                GetTransInfocodeEntry(TransInfocodeEntry, SalesEntry);
                if TransInfocodeEntry.Subcode <> '' then
                    if not TempInfoSubcode.Get(TransInfocodeEntry.Infocode, TransInfocodeEntry.Subcode) then begin
                        if InfoSubcode.Get(TransInfocodeEntry.Infocode, TransInfocodeEntry.Subcode) then
                            TempInfoSubcode := InfoSubcode
                        else begin
                            TempInfoSubcode.Init();
                            TempInfoSubcode.Code := TransInfocodeEntry.Infocode;
                            TempInfoSubcode.Subcode := TransInfocodeEntry.Subcode;
                            TempInfoSubcode.Description := TransInfocodeEntry.Subcode;
                        end;
                        TempInfoSubcode.Insert();
                    end;

                CodeDesc := '';
                case ReportType of
                    ReportType::Division:
                        begin
                            ReportCode := TempItem."LSC Division Code";
                            if ReportCode <> '' then
                                CodeDesc := TempDivision.Description;
                        end;
                    ReportType::Category:
                        begin
                            ReportCode := SalesEntry."Item Category Code";
                            if ReportCode <> '' then
                                CodeDesc := TempItemCat.Description;
                        end;
                    ReportType::Item:
                        begin
                            ReportCode := SalesEntry."Item No.";
                            if ReportCode <> '' then
                                CodeDesc := TempItem.Description;
                        end;
                    ReportType::Staff:
                        begin
                            ReportCode := SalesEntry."Staff ID";
                            if ReportCode <> '' then
                                CodeDesc := TempStaff."Name on Receipt";
                        end;
                    ReportType::"Reason Code":
                        begin
                            ReportCode := TransInfocodeEntry.Subcode;
                            if ReportCode <> '' then
                                CodeDesc := TempInfoSubcode.Description;
                        end;
                end;

                if ReportType <> ReportType::Transaction then begin
                    SalesInvtReportBuff.SetCurrentKey(Type, Code);
                    SalesInvtReportBuff.SetRange(Type, ReportType);
                    SalesInvtReportBuff.SetRange(Code, ReportCode);
                    if not SalesInvtReportBuff.Find('-') then begin
                        SalesInvtReportBuff.Init();
                        SalesInvtReportBuff."Entry No." := Counter;
                        SalesInvtReportBuff.Type := ReportType;
                        SalesInvtReportBuff.Code := ReportCode;
                        SalesInvtReportBuff.Description := CodeDesc;
                        SalesInvtReportBuff.Quantity := -SalesEntry.Quantity;
                        SalesInvtReportBuff."Net Amount" := -SalesEntry."Net Amount";
                        SalesInvtReportBuff."Discount Amount" := -SalesEntry."Discount Amount";
                        SalesInvtReportBuff."GST Amount" := -SalesEntry."VAT Amount";
                        SalesInvtReportBuff.Insert();
                    end else begin
                        SalesInvtReportBuff.Quantity += -SalesEntry.Quantity;
                        SalesInvtReportBuff."Net Amount" += -SalesEntry."Net Amount";
                        SalesInvtReportBuff."Discount Amount" += -SalesEntry."Discount Amount";
                        SalesInvtReportBuff."GST Amount" += -SalesEntry."VAT Amount";
                        SalesInvtReportBuff.Modify();
                    end;
                end else begin
                    SalesInvtReportBuff.Init();
                    SalesInvtReportBuff."Entry No." := Counter;
                    SalesInvtReportBuff.Type := SalesInvtReportBuff.Type::Transaction;
                    SalesInvtReportBuff."Transaction No." := SalesEntry."Transaction No.";
                    SalesInvtReportBuff."Store No." := SalesEntry."Store No.";
                    SalesInvtReportBuff."POS Terminal No." := SalesEntry."POS Terminal No.";
                    SalesInvtReportBuff.Date := SalesEntry."Trans. Date";
                    SalesInvtReportBuff."Staff ID" := SalesEntry."Staff ID";
                    if SalesEntry."Staff ID" <> '' then
                        SalesInvtReportBuff."Staff Name" := TempStaff."Name on Receipt";
                    SalesInvtReportBuff."Division Code" := TempItem."LSC Division Code";
                    if SalesInvtReportBuff."Division Code" <> '' then
                        SalesInvtReportBuff."Division" := TempDivision.Description;
                    SalesInvtReportBuff."Item Category Code" := SalesEntry."Item Category Code";
                    if SalesEntry."Item Category Code" <> '' then
                        SalesInvtReportBuff."Item Category" := TempItemCat.Description;
                    SalesInvtReportBuff.Infocode := TransInfocodeEntry.Infocode;
                    SalesInvtReportBuff."Reason Code" := TransInfocodeEntry.Subcode;
                    if SalesInvtReportBuff."Reason Code" <> '' then
                        SalesInvtReportBuff."Subcode Description" := TempInfoSubcode.Description;
                    SalesInvtReportBuff."Item No." := SalesEntry."Item No.";
                    SalesInvtReportBuff."Item Description" := TempItem.Description;

                    SalesInvtReportBuff.Quantity := -SalesEntry.Quantity;
                    SalesInvtReportBuff.Price := SalesEntry.Price;
                    SalesInvtReportBuff."Net Amount" := -SalesEntry."Net Amount";
                    SalesInvtReportBuff."Discount Amount" := -SalesEntry."Discount Amount";
                    SalesInvtReportBuff."GST Amount" := -SalesEntry."VAT Amount";
                    SalesInvtReportBuff.Insert();
                end;
                TotalNet += -SalesEntry."Net Amount";
                TotalDiscount += -SalesEntry."Discount Amount";
                TotalGST += -SalesEntry."VAT Amount";
            until SalesEntry.Next() = 0;

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


    local procedure GetTransInfocodeEntry(var TransInfocodeEntry: Record "LSC Trans. Infocode Entry"; TransSalesEntry: Record "LSC Trans. Sales Entry")
    var
    begin
        Clear(TransInfocodeEntry);
        TransInfocodeEntry.SetRange("Transaction No.", TransSalesEntry."Transaction No.");
        TransInfocodeEntry.SetRange("Store No.", TransSalesEntry."Store No.");
        TransInfocodeEntry.SetRange("POS Terminal No.", TransSalesEntry."POS Terminal No.");
        TransInfocodeEntry.SetRange("Line No.", TransSalesEntry."Line No.");
        TransInfocodeEntry.SetRange("Transaction Type", TransInfocodeEntry."Transaction Type"::"Sales Entry");
        if not TransInfocodeEntry.FindFirst() then begin
            TransInfocodeEntry.SetRange("Line No.");
            TransInfocodeEntry.SetRange("Transaction Type", TransInfocodeEntry."Transaction Type"::Header);
            if TransInfocodeEntry.FindFirst() then;
        end;
    end;

}

