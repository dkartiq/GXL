// 001 21-04-25  BY  LCB-799 
report 50020 "GXL Petbarn Detailed FA"
{
    //ERP-255 2021-08-03: New FA report

    Caption = 'Petbarn Detailed Fixed Asset';
    DefaultLayout = RDLC;
    RDLCLayout = './src/Report/PetbarnDetailedFixedAsset.rdlc';
    ApplicationArea = All;
    UsageCategory = ReportsAndAnalysis;


    dataset
    {
        dataitem("Fixed Asset"; "Fixed Asset")
        {
            RequestFilterFields = "No.", "FA Class Code", "FA Subclass Code", "Budgeted Asset";
            column(MainHeadLineText_FA; MainHeadLineText)
            {
            }
            column(CompanyName; CompanyName())
            {
            }
            column(TodayFormatted; Format(Today, 0, 4))
            {
            }
            column(DeprBookText_FA; DeprBookText)
            {
            }
            column(TableFilter_FA; TableCaption + ': ' + FAFilter)
            {
            }
            column(Filter_FA; FAFilter)
            {
            }
            column(PrintDetails; PrintDetails)
            {
            }
            column(GroupTotals; SelectStr(GroupTotals + 1, GroupTotalsTxt))
            {
            }
            column(GroupCodeName; GroupCodeName)
            {
            }
            column(HeadLineText1; HeadLineText[1])
            {
            }
            column(HeadLineText2; HeadLineText[2])
            {
            }
            column(HeadLineText3; HeadLineText[3])
            {
            }
            column(HeadLineText4; HeadLineText[4])
            {
            }
            column(HeadLineText5; HeadLineText[5])
            {
            }
            column(HeadLineText6; HeadLineText[6])
            {
            }
            column(HeadLineText7; HeadLineText[7])
            {
            }
            column(HeadLineText8; HeadLineText[8])
            {
            }
            column(HeadLineText9; HeadLineText[9])
            {
            }
            column(HeadLineText10; HeadLineText[10])
            {
            }
            column(HeadLineText11; HeadLineText[11])
            {
            }
            column(HeadLineText12; HeadLineText[12])
            {
            }
            column(FANo; FANo)
            {
            }
            column(Desc_FA; FADescription)
            {
            }
            column(GroupHeadLine; GroupHeadLine)
            {
            }
            column(No_FA; "No.")
            {
            }
            column(Description_FA; Description)
            {
            }
            // >> 001
            column(GXLFATaxType_FixedAsset; "GXL FA Tax Type")
            {
            }
            column(GXLTaxOnly_FixedAsset; "GXL Tax Only")
            {
            }
            // << 001
            column(StartAmounts1; StartAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(NetChangeAmounts1; NetChangeAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(DisposalAmounts1; DisposalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts1; TotalEndingAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(StartAmounts2; StartAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(NetChangeAmounts2; NetChangeAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(DisposalAmounts2; DisposalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(TotalEndingAmounts2; TotalEndingAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(BookValueAtStartingDate; BookValueAtStartingDate)
            {
                AutoFormatType = 1;
            }
            column(BookValueAtEndingDate; BookValueAtEndingDate)
            {
                AutoFormatType = 1;
            }
            column(FormatGrpTotGroupHeadLine; Format(Text002 + ': ' + GroupHeadLine))
            {
            }
            column(GroupStartAmounts1; GroupStartAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(GroupNetChangeAmounts1; GroupNetChangeAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(GroupDisposalAmounts1; GroupDisposalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(GroupStartAmounts2; GroupStartAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(GroupNetChangeAmounts2; GroupNetChangeAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(GroupDisposalAmounts2; GroupDisposalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(TotalStartAmounts1; TotalStartAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(TotalNetChangeAmounts1; TotalNetChangeAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(TotalDisposalAmounts1; TotalDisposalAmounts[1])
            {
                AutoFormatType = 1;
            }
            column(TotalStartAmounts2; TotalStartAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(TotalNetChangeAmounts2; TotalNetChangeAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(TotalDisposalAmounts2; TotalDisposalAmounts[2])
            {
                AutoFormatType = 1;
            }
            column(PageCaption; PageCaptionLbl)
            {
            }
            column(TotalCaption; TotalCaptionLbl)
            {
            }
            column(GainLossAmounts1; GainLossOnDisposal[1])
            {
                AutoFormatType = 1;
            }
            column(GainLossAmounts2; GainLossOnDisposal[2])
            {
                AutoFormatType = 1;
            }
            column(GroupGainLossOnDisposal1; GroupGainLossOnDisposal[1])
            {
                AutoFormatType = 1;
            }
            column(GroupGainLossOnDisposal2; GroupGainLossOnDisposal[2])
            {
                AutoFormatType = 1;
            }
            column(TotalGainLossOnDisposal1; TotalGainLossOnDisposal[1])
            {
                AutoFormatType = 1;
            }
            column(TotalGainLossOnDisposal2; TotalGainLossOnDisposal[2])
            {
                AutoFormatType = 1;
            }

            trigger OnAfterGetRecord()
            begin
                if not FADeprBook.Get("No.", DeprBookCode) then
                    CurrReport.Skip();
                if SkipRecord then
                    CurrReport.Skip();

                if GroupTotals = GroupTotals::"FA Posting Group" then
                    if "FA Posting Group" <> FADeprBook."FA Posting Group" then
                        Error(Text007, FieldCaption("FA Posting Group"), "No.");

                BeforeAmount := 0;
                EndingAmount := 0;
                if BudgetReport then
                    BudgetDepreciation.Calculate(
                      "No.", GetStartingDate(StartingDate), EndingDate, DeprBookCode, BeforeAmount, EndingAmount);

                i := 0;
                while i < NumberOfTypes do begin
                    i := i + 1;
                    case i of
                        1:
                            PostingType := FADeprBook.FieldNo("Acquisition Cost");
                        2:
                            PostingType := FADeprBook.FieldNo(Depreciation);
                        3:
                            PostingType := FADeprBook.FieldNo("Write-Down");
                        4:
                            PostingType := FADeprBook.FieldNo(Appreciation);
                        5:
                            PostingType := FADeprBook.FieldNo("Custom 1");
                        6:
                            PostingType := FADeprBook.FieldNo("Custom 2");
                    end;
                    if StartingDate <= 00000101D then
                        StartAmounts[i] := 0
                    else
                        StartAmounts[i] := FAGenReport.CalcFAPostedAmount("No.", PostingType, Period1, StartingDate,
                            EndingDate, DeprBookCode, BeforeAmount, EndingAmount, false, true);
                    NetChangeAmounts[i] :=
                      FAGenReport.CalcFAPostedAmount(
                        "No.", PostingType, Period2, StartingDate, EndingDate,
                        DeprBookCode, BeforeAmount, EndingAmount, false, true);
                    if GetPeriodDisposal then
                        DisposalAmounts[i] := -(StartAmounts[i] + NetChangeAmounts[i])
                    else
                        DisposalAmounts[i] := 0;
                    if i >= 3 then
                        AddPostingType(i - 3);
                end;
                for j := 1 to NumberOfTypes do
                    TotalEndingAmounts[j] := StartAmounts[j] + NetChangeAmounts[j] + DisposalAmounts[j];
                BookValueAtEndingDate := 0;
                BookValueAtStartingDate := 0;
                for j := 1 to NumberOfTypes do begin
                    BookValueAtEndingDate := BookValueAtEndingDate + TotalEndingAmounts[j];
                    BookValueAtStartingDate := BookValueAtStartingDate + StartAmounts[j];
                end;

                //Gain/Loss
                PostingType := FADeprBook.FieldNo("Gain/Loss");
                GainLossPeriod1 := GainLossPeriod1::"Net Change";
                GainLossPeriod2 := GainLossPeriod2::"at Ending Date";
                if StartingDate <= 00000101D then
                    GainLossOnDisposal[1] := 0
                else
                    GainLossOnDisposal[1] := FAGenReport.CalcFAPostedAmount("No.", PostingType, GainLossPeriod1, StartingDate,
                        EndingDate, DeprBookCode, BeforeAmount, EndingAmount, false, false);
                GainLossOnDisposal[2] :=
                  FAGenReport.CalcFAPostedAmount(
                    "No.", PostingType, GainLossPeriod2, StartingDate, EndingDate,
                    DeprBookCode, BeforeAmount, EndingAmount, false, false);

                MakeGroupHeadLine();
                UpdateTotals();
                CreateGroupTotals();

                // Write to Excel
                if blnExcel then begin

                    if ExcelInitiated = false then begin
                        InitiateExcel;  // creates excel & writes header information
                        ExcelInitiated := true;
                        ShowGroupFooter := false;
                    end;

                    if IsNewGroup(GroupHeadLine) then begin

                        // can't write footer for previous group if this is the first group
                        if ShowGroupFooter then begin
                            WriteExcelGroupFooter();  // for previous group
                        end;

                        WriteExcelGroupHeader();

                        ShowGroupFooter := true;

                    end;

                    WriteExcelLine();

                end;
            end;

            trigger OnPostDataItem()
            begin
                CreateTotals();

                if blnExcel and ExcelInitiated then begin
                    // If no detail, and only one group, do not double up on the group footer
                    WriteExcelGroupFooter();  // total for final group
                    WriteExcelTotal();
                end;
            end;

            trigger OnPreDataItem()
            begin
                case GroupTotals of
                    GroupTotals::"FA Class":
                        SetCurrentKey("FA Class Code");
                    GroupTotals::"FA Subclass":
                        SetCurrentKey("FA Subclass Code");
                    GroupTotals::"FA Location":
                        SetCurrentKey("FA Location Code");
                    GroupTotals::"Main Asset":
                        SetCurrentKey("Component of Main Asset");
                    GroupTotals::"Global Dimension 1":
                        SetCurrentKey("Global Dimension 1 Code");
                    GroupTotals::"Global Dimension 2":
                        SetCurrentKey("Global Dimension 2 Code");
                    GroupTotals::"FA Posting Group":
                        SetCurrentKey("FA Posting Group");
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(DeprBookCode; DeprBookCode)
                    {
                        Caption = 'Depreciation Book';
                        TableRelation = "Depreciation Book";
                    }
                    field(StartingDate; StartingDate)
                    {
                        Caption = 'Starting Date';
                    }
                    field(EndingDate; EndingDate)
                    {
                        Caption = 'Ending Date';
                    }
                    field(GroupTotals; GroupTotals)
                    {
                        Caption = 'Group Totals';
                        OptionCaption = ' ,FA Class,FA Subclass,FA Location,Main Asset,Global Dimension 1,Global Dimension 2,FA Posting Group';
                    }
                    field(PrintDetails; PrintDetails)
                    {
                        Caption = 'Print per Fixed Asset';
                    }
                    field(BudgetReport; BudgetReport)
                    {
                        Caption = 'Budget Report';
                    }
                    field(ShowDim1; ShowDim1)
                    {
                        Caption = 'Show Dim 1 Code';
                        CaptionClass = '1,2,1,' + 'Show ';
                    }
                    field(blnExcel; blnExcel)
                    {
                        Caption = 'Excel (Additional Output)';
                    }
                }
            }
        }

        actions
        {
        }

        trigger OnOpenPage()
        begin
            GetDepreciationBookCode();
        end;
    }

    labels
    {
    }

    trigger OnInitReport()
    begin
        blnExcel := true;
    end;

    trigger OnPostReport()
    begin
        if blnExcel then begin
            TempExcelBuffer.CreateBook('', 'Fixed Asset');
            TempExcelBuffer.WriteSheet('Fixed Asset', CompanyName, UserId);
            TempExcelBuffer.CloseBook();
            TempExcelBuffer.OpenExcel();

            //TempExcelBuffer.GiveUserControl;
        end;

    end;

    trigger OnPreReport()
    begin
        NumberOfTypes := 6;
        DeprBook.Get(DeprBookCode);
        if GroupTotals = GroupTotals::"FA Posting Group" then
            FAGenReport.SetFAPostingGroup("Fixed Asset", DeprBook.Code);
        FAGenReport.AppendFAPostingFilter("Fixed Asset", StartingDate, EndingDate);
        FAFilter := "Fixed Asset".GetFilters;
        MainHeadLineText := Text000;
        if BudgetReport then
            MainHeadLineText := StrSubstNo('%1 %2', MainHeadLineText, Text001);
        DeprBookText := StrSubstNo('%1%2 %3', DeprBook.TableCaption, ':', DeprBookCode);
        MakeGroupTotalText();
        FAGenReport.ValidateDates(StartingDate, EndingDate);
        MakeDateText();
        MakeHeadLine();
        if PrintDetails then begin
            FANo := "Fixed Asset".FieldCaption("No.");
            FADescription := "Fixed Asset".FieldCaption(Description);
        end;
        Period1 := Period1::"Before Starting Date";
        Period2 := Period2::"Net Change";
    end;

    var
        DefDim: Record "Default Dimension";
        FALedgEntry: Record "FA Ledger Entry";
        recDepBook: Record "FA Depreciation Book";
        recFALocation: Record "FA Location";
        TempExcelBuffer: Record "Excel Buffer" temporary;
        FASetup: Record "FA Setup";
        DeprBook: Record "Depreciation Book";
        FADeprBook: Record "FA Depreciation Book";
        FA: Record "Fixed Asset";
        FAPostingTypeSetup: Record "FA Posting Type Setup";
        FAGenReport: Codeunit "FA General Report";
        BudgetDepreciation: Codeunit "Budget Depreciation";
        DeprBookCode: Code[10];
        FAFilter: Text;
        MainHeadLineText: Text[100];
        DeprBookText: Text[50];
        GroupCodeName: Text[50];
        GroupHeadLine: Text[50];
        FANo: Text[50];
        FADescription: Text[50];
        GroupTotals: Option " ","FA Class","FA Subclass","FA Location","Main Asset","Global Dimension 1","Global Dimension 2","FA Posting Group";
        HeadLineText: array[12] of Text[100];
        StartAmounts: array[6] of Decimal;
        NetChangeAmounts: array[6] of Decimal;
        DisposalAmounts: array[6] of Decimal;
        GroupStartAmounts: array[6] of Decimal;
        GroupNetChangeAmounts: array[6] of Decimal;
        GroupDisposalAmounts: array[6] of Decimal;
        TotalStartAmounts: array[6] of Decimal;
        TotalNetChangeAmounts: array[6] of Decimal;
        TotalDisposalAmounts: array[6] of Decimal;
        TotalEndingAmounts: array[6] of Decimal;
        GainLossOnDisposal: array[6] of Decimal;
        GroupGainLossOnDisposal: array[6] of Decimal;
        TotalGainLossOnDisposal: array[6] of Decimal;
        BookValueAtStartingDate: Decimal;
        BookValueAtEndingDate: Decimal;
        i: Integer;
        j: Integer;
        NumberOfTypes: Integer;
        PostingType: Integer;
        Period1: Option "Before Starting Date","Net Change","at Ending Date";
        Period2: Option "Before Starting Date","Net Change","at Ending Date";
        GainLossPeriod1: Option "Before Starting Date","Net Change","at Ending Date";
        GainLossPeriod2: Option "Before Starting Date","Net Change","at Ending Date";
        StartingDate: Date;
        EndingDate: Date;
        PrintDetails: Boolean;
        BudgetReport: Boolean;
        BeforeAmount: Decimal;
        EndingAmount: Decimal;
        AcquisitionDate: Date;
        DisposalDate: Date;
        StartText: Text[30];
        EndText: Text[30];
        blnExcel: Boolean;
        intCol: Integer;
        intCol2: Integer;
        intRow: Integer;
        intTotalCol: Integer;
        ExcelInitiated: Boolean;
        ShowGroupFooter: Boolean;
        LastGroupHeadLine: Text;
        ExcelGroupTotals: array[12] of Decimal;
        ShowDim1: Boolean;
        Text000: Label 'Fixed Asset - Book Value 01';
        Text001: Label '(Budget Report)';
        Text002: Label 'Group Total';
        Text003: Label 'Group Totals';
        Text004: Label 'in Period';
        Text005: Label 'Disposal';
        Text006: Label 'Addition';
        Text007: Label '%1 has been modified in fixed asset %2';
        GainLossTxt: Label 'Gain/Loss on Disposal';
        PageCaptionLbl: Label 'Page';
        TotalCaptionLbl: Label 'Total';
        GroupTotalsTxt: Label ' ,FA Class,FA Subclass,FA Location,Main Asset,Global Dimension 1,Global Dimension 2,FA Posting Group';

    local procedure AddPostingType(PostingType: Option "Write-Down",Appreciation,"Custom 1","Custom 2")
    var
        i: Integer;
        j: Integer;
    begin
        i := PostingType + 3;
        case PostingType of
            PostingType::"Write-Down":
                FAPostingTypeSetup.Get(DeprBookCode, FAPostingTypeSetup."FA Posting Type"::"Write-Down");
            PostingType::Appreciation:
                FAPostingTypeSetup.Get(DeprBookCode, FAPostingTypeSetup."FA Posting Type"::Appreciation);
            PostingType::"Custom 1":
                FAPostingTypeSetup.Get(DeprBookCode, FAPostingTypeSetup."FA Posting Type"::"Custom 1");
            PostingType::"Custom 2":
                FAPostingTypeSetup.Get(DeprBookCode, FAPostingTypeSetup."FA Posting Type"::"Custom 2");
        end;
        if FAPostingTypeSetup."Depreciation Type" then
            j := 2
        else
            if FAPostingTypeSetup."Acquisition Type" then
                j := 1;

        if j > 0 then begin
            StartAmounts[j] := StartAmounts[j] + StartAmounts[i];
            StartAmounts[i] := 0;
            NetChangeAmounts[j] := NetChangeAmounts[j] + NetChangeAmounts[i];
            NetChangeAmounts[i] := 0;
            DisposalAmounts[j] := DisposalAmounts[j] + DisposalAmounts[i];
            DisposalAmounts[i] := 0;
        end;
    end;

    local procedure SkipRecord(): Boolean
    begin
        AcquisitionDate := FADeprBook."Acquisition Date";
        DisposalDate := FADeprBook."Disposal Date";
        exit(
          "Fixed Asset".Inactive or
          (AcquisitionDate = 0D) or
          (AcquisitionDate > EndingDate) and (EndingDate > 0D) or
          (DisposalDate > 0D) and (DisposalDate < StartingDate))
    end;

    local procedure GetPeriodDisposal(): Boolean
    begin
        if DisposalDate > 0D then
            if (EndingDate = 0D) or (DisposalDate <= EndingDate) then
                exit(true);
        exit(false);
    end;

    local procedure MakeGroupTotalText()
    begin
        case GroupTotals of
            GroupTotals::"FA Class":
                GroupCodeName := Format("Fixed Asset".FieldCaption("FA Class Code"));
            GroupTotals::"FA Subclass":
                GroupCodeName := Format("Fixed Asset".FieldCaption("FA Subclass Code"));
            GroupTotals::"FA Location":
                GroupCodeName := Format("Fixed Asset".FieldCaption("FA Location Code"));
            GroupTotals::"Main Asset":
                GroupCodeName := Format("Fixed Asset".FieldCaption("Main Asset/Component"));
            GroupTotals::"Global Dimension 1":
                GroupCodeName := Format("Fixed Asset".FieldCaption("Global Dimension 1 Code"));
            GroupTotals::"Global Dimension 2":
                GroupCodeName := Format("Fixed Asset".FieldCaption("Global Dimension 2 Code"));
            GroupTotals::"FA Posting Group":
                GroupCodeName := Format("Fixed Asset".FieldCaption("FA Posting Group"));
        end;
        if GroupCodeName <> '' then
            GroupCodeName := Format(StrSubstNo('%1%2 %3', Text003, ':', GroupCodeName));
    end;

    local procedure MakeDateText()
    begin
        StartText := StrSubstNo('%1', StartingDate - 1);
        EndText := StrSubstNo('%1', EndingDate);
    end;

    local procedure MakeHeadLine()
    var
        InPeriodText: Text[30];
        DisposalText: Text[30];
    begin
        InPeriodText := Text004;
        DisposalText := Text005;
        HeadLineText[1] := StrSubstNo('%1 %2', FADeprBook.FieldCaption("Acquisition Cost"), StartText);
        HeadLineText[2] := StrSubstNo('%1 %2', Text006, InPeriodText);
        HeadLineText[3] := StrSubstNo('%1 %2', DisposalText, InPeriodText);
        HeadLineText[4] := StrSubstNo('%1 %2', FADeprBook.FieldCaption("Acquisition Cost"), EndText);
        HeadLineText[5] := StrSubstNo('%1 %2', FADeprBook.FieldCaption(Depreciation), StartText);
        HeadLineText[6] := StrSubstNo('%1 %2', FADeprBook.FieldCaption(Depreciation), InPeriodText);
        HeadLineText[7] := StrSubstNo('%1 %2 %3', DisposalText, FADeprBook.FieldCaption(Depreciation), InPeriodText);
        HeadLineText[8] := StrSubstNo('%1 %2', FADeprBook.FieldCaption(Depreciation), EndText);
        HeadLineText[9] := StrSubstNo('%1 %2', FADeprBook.FieldCaption("Book Value"), StartText);
        HeadLineText[10] := StrSubstNo('%1 %2', FADeprBook.FieldCaption("Book Value"), EndText);

        //Gain/Loss
        HeadLineText[11] := StrSubstNo('%1 %2', GainLossTxt, InPeriodText);
        HeadLineText[12] := StrSubstNo('%1 %2', GainLossTxt, EndText);
    end;

    local procedure MakeGroupHeadLine()
    begin
        for j := 1 to NumberOfTypes do begin
            GroupStartAmounts[j] := 0;
            GroupNetChangeAmounts[j] := 0;
            GroupDisposalAmounts[j] := 0;
        end;
        for j := 1 to 2 do begin
            GroupGainLossOnDisposal[j] := 0;
        end;
        case GroupTotals of
            GroupTotals::"FA Class":
                GroupHeadLine := Format("Fixed Asset"."FA Class Code");
            GroupTotals::"FA Subclass":
                GroupHeadLine := Format("Fixed Asset"."FA Subclass Code");
            GroupTotals::"FA Location":
                GroupHeadLine := Format("Fixed Asset"."FA Location Code");
            GroupTotals::"Main Asset":
                begin
                    FA."Main Asset/Component" := FA."Main Asset/Component"::"Main Asset";
                    GroupHeadLine :=
                      Format(StrSubstNo('%1 %2', Format(FA."Main Asset/Component"), "Fixed Asset"."Component of Main Asset"));
                    if "Fixed Asset"."Component of Main Asset" = '' then
                        GroupHeadLine := Format(StrSubstNo('%1 %2', GroupHeadLine, '*****'));
                end;
            GroupTotals::"Global Dimension 1":
                GroupHeadLine := Format("Fixed Asset"."Global Dimension 1 Code");
            GroupTotals::"Global Dimension 2":
                GroupHeadLine := Format("Fixed Asset"."Global Dimension 2 Code");
            GroupTotals::"FA Posting Group":
                GroupHeadLine := Format("Fixed Asset"."FA Posting Group");
        end;
        if GroupHeadLine = '' then
            GroupHeadLine := Format('*****');
    end;

    local procedure UpdateTotals()
    begin
        for j := 1 to NumberOfTypes do begin
            GroupStartAmounts[j] := GroupStartAmounts[j] + StartAmounts[j];
            GroupNetChangeAmounts[j] := GroupNetChangeAmounts[j] + NetChangeAmounts[j];
            GroupDisposalAmounts[j] := GroupDisposalAmounts[j] + DisposalAmounts[j];
            TotalStartAmounts[j] := TotalStartAmounts[j] + StartAmounts[j];
            TotalNetChangeAmounts[j] := TotalNetChangeAmounts[j] + NetChangeAmounts[j];
            TotalDisposalAmounts[j] := TotalDisposalAmounts[j] + DisposalAmounts[j];
        end;
        for j := 1 to 2 do begin
            GroupGainLossOnDisposal[j] := GroupGainLossOnDisposal[j] + GainLossOnDisposal[j];
            TotalGainLossOnDisposal[j] := TotalGainLossOnDisposal[j] + GainLossOnDisposal[j];
        end;
    end;

    local procedure CreateGroupTotals()
    begin
        for j := 1 to NumberOfTypes do
            TotalEndingAmounts[j] :=
              GroupStartAmounts[j] + GroupNetChangeAmounts[j] + GroupDisposalAmounts[j];
        BookValueAtEndingDate := 0;
        BookValueAtStartingDate := 0;
        for j := 1 to NumberOfTypes do begin
            BookValueAtEndingDate := BookValueAtEndingDate + TotalEndingAmounts[j];
            BookValueAtStartingDate := BookValueAtStartingDate + GroupStartAmounts[j];
        end;
    end;

    local procedure CreateTotals()
    begin
        for j := 1 to NumberOfTypes do
            TotalEndingAmounts[j] :=
              TotalStartAmounts[j] + TotalNetChangeAmounts[j] + TotalDisposalAmounts[j];
        BookValueAtEndingDate := 0;
        BookValueAtStartingDate := 0;
        for j := 1 to NumberOfTypes do begin
            BookValueAtEndingDate := BookValueAtEndingDate + TotalEndingAmounts[j];
            BookValueAtStartingDate := BookValueAtStartingDate + TotalStartAmounts[j];
        end;
    end;

    local procedure GetStartingDate(StartingDate: Date): Date
    begin
        if StartingDate <= 00000101D then
            exit(0D);

        exit(StartingDate - 1);
    end;

    procedure SetMandatoryFields(DepreciationBookCodeFrom: Code[10]; StartingDateFrom: Date; EndingDateFrom: Date)
    begin
        DeprBookCode := DepreciationBookCodeFrom;
        StartingDate := StartingDateFrom;
        EndingDate := EndingDateFrom;
    end;

    local procedure SetTotalFields(GroupTotalsFrom: Option; PrintDetailsFrom: Boolean; BudgetReportFrom: Boolean)
    begin
        GroupTotals := GroupTotalsFrom;
        PrintDetails := PrintDetailsFrom;
        BudgetReport := BudgetReportFrom;
    end;

    local procedure GetDepreciationBookCode()
    begin
        if DeprBookCode = '' then begin
            FASetup.Get;
            DeprBookCode := FASetup."Default Depr. Book";
        end;
    end;

    local procedure InitiateExcel()
    var
        col: Integer;
    begin
        if ShowDim1 then
            intTotalCol := 28
        else
            intTotalCol := 27;

        EnterCell(
          1, 1,
          MainHeadLineText,
          true, false, false,
          '',
          TempExcelBuffer."Cell Type"::Text);

        EnterCell(
          2, 1,
          DeprBookText,
          false, false, false,
          '',
          TempExcelBuffer."Cell Type"::Text);

        EnterCell(
          3, 1,
          CompanyName,
          false, false, false,
          '',
          TempExcelBuffer."Cell Type"::Text);

        EnterCell(
          4, 1,
          "Fixed Asset".TableCaption + ': ' + FAFilter,
          false, false, false,
          '',
          TempExcelBuffer."Cell Type"::Text);

        intRow := 6;

        EnterCell(
          intRow, 1,
          GroupCodeName,
          true, false, false,
          '',
          TempExcelBuffer."Cell Type"::Text);

        intRow += 2;

        if PrintDetails then begin
            col := 1;
            EnterCell(intRow, col, 'No.', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'Description', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            // >> 001
            col +=1;
            EnterCell(intRow, col, 'FA Tax Type', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, 4, 'Tax Only', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            // << 001
            EnterCell(intRow, col, 'FA Class Code', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'FA Sub Class', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'Location Code', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'Location Name', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            if ShowDim1 then begin
                col += 1;
                EnterCell(intRow, col, 'Entity Code', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            end;
            col += 1;
            EnterCell(intRow, col, 'Site Code', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'Project Code', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'Document No.', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'Vendor No.', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'Depreciation Start Date', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'Depreciation Method', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'Straight-Line %', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'Declining-Balance %', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, 'No. of Depreciation Months', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, HeadLineText[1], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, HeadLineText[2], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, HeadLineText[3], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, HeadLineText[4], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, HeadLineText[5], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, HeadLineText[6], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, HeadLineText[7], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, HeadLineText[8], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, HeadLineText[9], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1;
            EnterCell(intRow, col, HeadLineText[10], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //11 = gain/loss in period
            EnterCell(intRow, col, HeadLineText[11], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //12 = gain/loss ending period
            EnterCell(intRow, col, HeadLineText[12], true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        end else begin

            EnterCell(intRow, 1, 'No.', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            EnterCell(intRow, 2, 'Description', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            // >> 001
            EnterCell(intRow,3,'FA Tax Type', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            EnterCell(intRow, 4, 'Tax Only', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            //col := 3; //1 = accquisition start
            col := 5; //1 = accquisition start
            // << 001
            EnterCell(intRow, col, HeadLineText[1], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //2 = addition in period
            EnterCell(intRow, col, HeadLineText[2], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //3 = disposal in period
            EnterCell(intRow, col, HeadLineText[3], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //4 = accquistion ending period
            EnterCell(intRow, col, HeadLineText[4], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //5 = depreciation start
            EnterCell(intRow, col, HeadLineText[5], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //6 = depreciation in period
            EnterCell(intRow, col, HeadLineText[6], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //7 = disposal depreciation in period
            EnterCell(intRow, col, HeadLineText[7], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //8 = depreciation ending
            EnterCell(intRow, col, HeadLineText[8], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //9 = book value start
            EnterCell(intRow, col, HeadLineText[9], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //10 = book value ending period
            EnterCell(intRow, col, HeadLineText[10], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //11 = gain/loss in period
            EnterCell(intRow, col, HeadLineText[11], true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col += 1; //12 = gain/loss ending period
            EnterCell(intRow, col, HeadLineText[12], true, false, false, '', TempExcelBuffer."Cell Type"::Text);

        end;

        intRow += 2;

    end;

    local procedure IsNewGroup(CurrentGroup: Text) NewGroup: Boolean
    begin
        NewGroup := CurrentGroup <> LastGroupHeadLine;
    end;

    local procedure WriteExcelGroupHeader()
    begin
        if PrintDetails then begin

            EnterCell(intRow, 1, GroupHeadLine, true, false, false, '', TempExcelBuffer."Cell Type"::Text);

            intRow += 1;
        end;

        LastGroupHeadLine := GroupHeadLine;

    end;

    local procedure WriteExcelGroupFooter()
    var
        col: Integer;
    begin
        if LastGroupHeadLine = '' then
            LastGroupHeadLine := GroupHeadLine;

        if PrintDetails then begin


            EnterCell(intRow, 1, Format(Text002 + ': ' + LastGroupHeadLine), true, false, false, '', TempExcelBuffer."Cell Type"::Text);

            if ShowDim1 then
                col := 17
            else
                col := 16;
            EnterCell(intRow, col, Format(ExcelGroupTotals[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(ExcelGroupTotals[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(ExcelGroupTotals[3]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(ExcelGroupTotals[4]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(ExcelGroupTotals[5]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(ExcelGroupTotals[6]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(ExcelGroupTotals[7]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(ExcelGroupTotals[8]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(ExcelGroupTotals[9]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(ExcelGroupTotals[10]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1; // 11 = gain/loss in period
            EnterCell(intRow, col, Format(ExcelGroupTotals[11]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1; // 12 = gain/loss ending period
            EnterCell(intRow, col, Format(ExcelGroupTotals[12]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);

        end else begin

            EnterCell(intRow, 1, Format(Text002 + ': ' + LastGroupHeadLine), true, false, false, '', TempExcelBuffer."Cell Type"::Text);

            col := 3;
            EnterCell(intRow, 3, Format(ExcelGroupTotals[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, 4, Format(ExcelGroupTotals[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, 5, Format(ExcelGroupTotals[3]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, 6, Format(ExcelGroupTotals[4]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, 7, Format(ExcelGroupTotals[5]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, 8, Format(ExcelGroupTotals[6]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, 9, Format(ExcelGroupTotals[7]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, 10, Format(ExcelGroupTotals[8]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, 11, Format(ExcelGroupTotals[9]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, 12, Format(ExcelGroupTotals[10]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1; // 11 = gain/loss in period
            EnterCell(intRow, col, Format(ExcelGroupTotals[11]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1; // 12 = gain/loss ending period
            EnterCell(intRow, col, Format(ExcelGroupTotals[12]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);

        end;

        intRow += 2;

        ExcelGroupTotals[1] := 0;
        ExcelGroupTotals[2] := 0;
        ExcelGroupTotals[3] := 0;
        ExcelGroupTotals[4] := 0;
        ExcelGroupTotals[5] := 0;
        ExcelGroupTotals[6] := 0;
        ExcelGroupTotals[7] := 0;
        ExcelGroupTotals[8] := 0;
        ExcelGroupTotals[9] := 0;
        ExcelGroupTotals[10] := 0;
        ExcelGroupTotals[11] := 0;
        ExcelGroupTotals[12] := 0;

    end;

    local procedure WriteExcelLine()
    var
        DecimalValue: Decimal;
        col: Integer;
    begin
        if PrintDetails then begin
            col := 1; //1
            EnterCell(
              intRow, col,
              "Fixed Asset"."No.",
              false, false, false,
              '',
              TempExcelBuffer."Cell Type"::Text);

            col += 1; //2
            EnterCell(
              intRow, col,
              "Fixed Asset".Description,
              false, false, false,
              '',
              TempExcelBuffer."Cell Type"::Text);

            // >> 001
            col +=1;
            EnterCell(
              intRow, col,
              "Fixed Asset"."GXL FA Tax Type",
              false, false, false,
              '',
              TempExcelBuffer."Cell Type"::Text);
            
            col += 1;
            EnterCell(
              intRow, col,
              Format("Fixed Asset"."GXL Tax Only"),
              false, false, false,
              '',
              TempExcelBuffer."Cell Type"::Text);
            // << 001

            col += 1; //3
            EnterCell(
              intRow, col,
              "Fixed Asset"."FA Class Code",
              false, false, false,
              '',
              TempExcelBuffer."Cell Type"::Text);

            col += 1; //4
            EnterCell(
              intRow, col,
              "Fixed Asset"."FA Subclass Code",
              false, false, false,
              '',
              TempExcelBuffer."Cell Type"::Text);

            col += 1; //5
            EnterCell(
              intRow, col,
              "Fixed Asset"."FA Location Code",
              false, false, false,
              '',
              TempExcelBuffer."Cell Type"::Text);

            col += 1; //6
            if "Fixed Asset"."FA Location Code" <> '' then begin
                recFALocation.Get("Fixed Asset"."FA Location Code");
                EnterCell(
                  intRow, col,
                  recFALocation.Name,
                  false, false, false,
                  '',
                  TempExcelBuffer."Cell Type"::Text);
            end;

            if ShowDim1 then begin
                col += 1;
                EnterCell(
                  intRow, col,
                  "Fixed Asset"."Global Dimension 1 Code",
                  false, false, false,
                  '',
                  TempExcelBuffer."Cell Type"::Text);
            end;

            col += 1; //7
            EnterCell(
              intRow, col,
              "Fixed Asset"."Global Dimension 2 Code",
              false, false, false,
              '',
              TempExcelBuffer."Cell Type"::Text);

            col += 1; //8
            DefDim.Reset;
            DefDim.SetRange("Table ID", Database::"Fixed Asset");
            DefDim.SetRange(DefDim."No.", "Fixed Asset"."No.");
            DefDim.SetRange(DefDim."Dimension Code", 'PROJECT');
            if DefDim.FindFirst then
                EnterCell(
                  intRow, col,
                  DefDim."Dimension Value Code",
                  false, false, false,
                  '',
                  TempExcelBuffer."Cell Type"::Text);

            col += 1; //9
            FALedgEntry.Reset;
            FALedgEntry.SetCurrentKey("FA No.", "Depreciation Book Code");
            FALedgEntry.SetRange(FALedgEntry."FA No.", "Fixed Asset"."No.");
            if DeprBookCode <> '' then
                FALedgEntry.SetRange("Depreciation Book Code", DeprBookCode);
            FALedgEntry.SetRange(FALedgEntry."FA Posting Type", FALedgEntry."FA Posting Type"::"Acquisition Cost");
            if FALedgEntry.FindFirst then
                EnterCell(
                  intRow, col,
                  FALedgEntry."Document No.",
                  false, false, false,
                  '',
                  TempExcelBuffer."Cell Type"::Text);

            col += 1; //10
            EnterCell(
              intRow, col,
              "Fixed Asset"."Vendor No.",
              false, false, false,
              '',
              TempExcelBuffer."Cell Type"::Text);

            recDepBook.Reset;
            recDepBook.SetRange(recDepBook."FA No.", "Fixed Asset"."No.");
            recDepBook.SetRange(recDepBook."Depreciation Book Code", DeprBookCode);
            if recDepBook.FindFirst then begin

                col += 1; //11
                EnterCell(
                  intRow, col,
                  Format(recDepBook."Depreciation Starting Date"),
                  false, false, false,
                  '',
                  TempExcelBuffer."Cell Type"::Date);

                col += 1; //12
                EnterCell(
                  intRow, col,
                  Format(recDepBook."Depreciation Method"),
                  false, false, false,
                  '',
                  TempExcelBuffer."Cell Type"::Text);

                col += 1; //13
                EnterCell(
                  intRow, col,
                  Format(recDepBook."Straight-Line %"),
                  false, false, false,
                  '#,##0.00',
                  TempExcelBuffer."Cell Type"::Number);

                col += 1; //14
                EnterCell(
                  intRow, col,
                  Format(recDepBook."Declining-Balance %"),
                  false, false, false,
                  '#,##0.00',
                  TempExcelBuffer."Cell Type"::Number);

                col += 1; //15
                EnterCell(
                  intRow, col,
                  Format(recDepBook."No. of Depreciation Months"),
                  false, false, false,
                  '#,##0.00',
                  TempExcelBuffer."Cell Type"::Number);

            end else
                col := col + 5; //15

            col += 1; //16
            EnterCell(
              intRow, col,
              Format(StartAmounts[1]),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            col += 1; //17
            EnterCell(
              intRow, col,
              Format(NetChangeAmounts[1]),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            col += 1; //18
            EnterCell(
              intRow, col,
              Format(DisposalAmounts[1]),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            col += 1; //19
            EnterCell(
              intRow, col,
              Format(TotalEndingAmounts[1]),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            col += 1; //20
            EnterCell(
              intRow, col,
              Format(StartAmounts[2]),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            col += 1; //21
            EnterCell(
              intRow, col,
              Format(NetChangeAmounts[2]),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            col += 1; //22
            EnterCell(
              intRow, col,
              Format(DisposalAmounts[2]),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            col += 1; //23
            EnterCell(
              intRow, col,
              Format(TotalEndingAmounts[2]),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            col += 1; //24
            EnterCell(
              intRow, col,
              Format(BookValueAtStartingDate),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            col += 1; //25
            EnterCell(
              intRow, col,
              Format(BookValueAtEndingDate),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            col += 1; //gain/loss in period
            EnterCell(
              intRow, col,
              Format(GainLossOnDisposal[1]),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            col += 1; //gain/loss ending period
            EnterCell(
              intRow, col,
              Format(GainLossOnDisposal[2]),
              false, false, false,
              '#,##0.00',
              TempExcelBuffer."Cell Type"::Number);

            intRow += 1;

        end;

        ExcelGroupTotals[1] += StartAmounts[1];
        ExcelGroupTotals[2] += NetChangeAmounts[1];
        ExcelGroupTotals[3] += DisposalAmounts[1];
        ExcelGroupTotals[4] += TotalEndingAmounts[1];
        ExcelGroupTotals[5] += StartAmounts[2];
        ExcelGroupTotals[6] += NetChangeAmounts[2];
        ExcelGroupTotals[7] += DisposalAmounts[2];
        ExcelGroupTotals[8] += TotalEndingAmounts[2];
        ExcelGroupTotals[9] += BookValueAtStartingDate;
        ExcelGroupTotals[10] += BookValueAtEndingDate;
        ExcelGroupTotals[11] += GainLossOnDisposal[1];
        ExcelGroupTotals[12] += GainLossOnDisposal[2];

    end;

    local procedure WriteExcelTotal()
    var
        col: Integer;
    begin
        intRow += 1;

        if PrintDetails then begin

            EnterCell(intRow, 1, 'Total', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            if ShowDim1 then
                col := 17
            else
                col := 16;
            EnterCell(intRow, col, Format(TotalStartAmounts[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalNetChangeAmounts[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalDisposalAmounts[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalEndingAmounts[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalStartAmounts[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalNetChangeAmounts[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalDisposalAmounts[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalEndingAmounts[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(BookValueAtStartingDate), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(BookValueAtEndingDate), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1; //gain/loss in period
            EnterCell(intRow, col, Format(TotalGainLossOnDisposal[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1; //gain/loss ending period
            EnterCell(intRow, col, Format(TotalGainLossOnDisposal[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
        end else begin

            EnterCell(intRow, 1, 'Total', true, false, false, '', TempExcelBuffer."Cell Type"::Text);
            col := 3;
            EnterCell(intRow, col, Format(TotalStartAmounts[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalNetChangeAmounts[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalDisposalAmounts[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalEndingAmounts[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalStartAmounts[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalNetChangeAmounts[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalDisposalAmounts[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(TotalEndingAmounts[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(BookValueAtStartingDate), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1;
            EnterCell(intRow, col, Format(BookValueAtEndingDate), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1; //gain/loss in period
            EnterCell(intRow, col, Format(TotalGainLossOnDisposal[1]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
            col += 1; //gain/loss ending period
            EnterCell(intRow, col, Format(TotalGainLossOnDisposal[2]), true, false, false, '#,##0.00', TempExcelBuffer."Cell Type"::Number);
        end;

        intRow += 1;

    end;

    local procedure EnterCell(RowNo: Integer; ColumnNo: Integer; CellValue: Text[250]; Bold: Boolean; Italic: Boolean; UnderLine: Boolean; Format: Text[30]; CellType: Option)
    begin
        TempExcelBuffer.Init;
        TempExcelBuffer.Validate("Row No.", RowNo);
        TempExcelBuffer.Validate("Column No.", ColumnNo);
        TempExcelBuffer."Cell Value as Text" := CellValue;
        TempExcelBuffer.Formula := '';
        TempExcelBuffer.Bold := Bold;
        TempExcelBuffer.Italic := Italic;
        TempExcelBuffer.Underline := UnderLine;
        TempExcelBuffer.NumberFormat := Format;
        TempExcelBuffer."Cell Type" := CellType;
        TempExcelBuffer.Insert;
    end;
}

