report 50000 "GXL Update MPL Factor"
{
    Caption = 'Update MPL Factor';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    ApplicationArea = All;

    dataset
    {
        dataitem(Category; "LSC Retail Product Group")
        {
            RequestFilterFields = "Code";
            dataitem(CatSetupCatItem; Item)
            {
                DataItemLink = "LSC Retail Product Code" = field(Code);
                DataItemTableView = SORTING("LSC Retail Product Code") ORDER(Ascending);

                trigger OnAfterGetRecord()
                begin
                    if BoolKeep = TRUE then
                        if ("GXL MPL Factor" = g_OldFactor) then
                            CurrReport.Skip();

                    if GuiAllowed() then begin
                        Counter += 1;
                        Window.UPDATE(1, "No.");
                        Window.UPDATE(2, ROUND(Counter / TotalRecords * 10000, 1));
                    end;
                    VALIDATE("GXL MPL Factor", g_NewFactor);
                    MODifY(TRUE);
                end;

                trigger OnPreDataItem()
                begin
                    SETFILTER("GXL MPL Factor", '<>%1|%2', g_NewFactor, 0);
                    TotalRecords := Count();
                end;
            }
            trigger OnPreDataItem()
            begin
                if g_CallFromTable <> g_CallFromTable::Category then
                    CurrReport.BREAK();
                SETRANGE(Code, g_Code);
            end;
        }
        dataitem("Sub-Category 3"; "GXL Sub-Category 3")
        {
            dataitem(CatSetupSubCat3Item; Item)
            {
                DataItemLink = "GXL Sub Category3 Code" = FIELD(Code);
                DataItemTableView = SORTING("GXL Sub Category3 Code") ORDER(Ascending);

                trigger OnAfterGetRecord()
                begin
                    if BoolKeep = TRUE then
                        if "GXL MPL Factor" <> 0 then
                            if ("GXL MPL Factor" <> g_OldFactor) then
                                CurrReport.Skip();


                    if GuiAllowed() then begin
                        Counter += 1;
                        Window.UPDATE(1, "No.");
                        Window.UPDATE(2, ROUND(Counter / TotalRecords * 10000, 1));
                    end;
                    VALIDATE("GXL MPL Factor", g_NewFactor);
                    MODifY(TRUE);
                end;

                trigger OnPreDataItem()
                begin
                    if BoolKeep = TRUE then
                        SETFILTER("GXL MPL Factor", '%1|%2', 0, g_OldFactor);

                    TotalRecords := Count();
                end;
            }


            trigger OnPreDataItem()
            begin
                if g_CallFromTable <> g_CallFromTable::SubCategory3 then
                    CurrReport.BREAK();
                SETRANGE(Code, g_Code);
            end;
        }
        dataitem("Sub-Category 4"; "GXL Sub-Category 4")
        {
            dataitem(CatSetupSubCat4Item; Item)
            {
                DataItemLink = "GXL Sub Category4 Code" = FIELD(Code);
                DataItemTableView = SORTING("GXL Sub Category4 Code") ORDER(Ascending);

                trigger OnAfterGetRecord()
                begin
                    Counter += 1;
                    if BoolKeep = TRUE then
                        if "GXL MPL Factor" <> 0 then
                            if NOT (("GXL MPL Factor" = g_OldFactor)) then
                                CurrReport.Skip();


                    if GuiAllowed() then begin
                        Window.UPDATE(1, "No.");
                        Window.UPDATE(2, ROUND(Counter / TotalRecords * 10000, 1));
                    end;

                    VALIDATE("GXL MPL Factor", g_NewFactor);
                    MODifY(TRUE);
                end;

                trigger OnPreDataItem()
                begin
                    SETFILTER("GXL MPL Factor", '<>%1|=%2', g_NewFactor, 0);

                    TotalRecords := Count();
                end;
            }


            trigger OnPreDataItem()
            begin
                if g_CallFromTable <> g_CallFromTable::SubCategory4 then
                    CurrReport.Break();
                SETRANGE(Code, g_Code);
            end;
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPostReport()
    begin
        if GuiAllowed() then begin
            Window.CLOSE();
        end;
    end;

    trigger OnPreReport()
    begin
        if g_NewFactor = 0 then
            ERROR('Please setup MPL Factor at level ' + FORMAT(g_CallFromTable));

        if CONFIRM(Text001Msg, FALSE) = TRUE then
            BoolKeep := FALSE
        ELSE
            BoolKeep := TRUE;

        if GuiAllowed() then
            Window.OPEN(Text002Msg + Text004Msg + Text003Msg);
    end;

    var
        g_CallFromTable: Option Department,Category,SubCategory1,SubCategory2,SubCategory3,SubCategory4;
        Window: Dialog;
        Counter: Integer;
        TotalRecords: Integer;
        BoolKeep: Boolean;
        g_OldFactor: Integer;
        g_Code: Code[40];
        g_NewFactor: Integer;
        Text001Msg: Label 'Do you want to override the Lower level MPL factors ? ';
        Text002Msg: Label 'Update MPL Factor for Item ';
        Text003Msg: Label '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        Text004Msg: Label '#1###########\\';

    procedure SetCallFrom(CallFromTable: Option Division,Category,SubCategory1,SubCategory2,SubCategory3,SubCategory4; OldFactor: Integer; NewFactor: Integer; CallFromCode: Code[40])
    begin
        g_CallFromTable := CallFromTable;
        g_OldFactor := OldFactor;
        g_NewFactor := NewFactor;
        g_Code := CallFromCode;
    end;

    local procedure ResetMPLFactor(CatOption: Option Cat,SubCat1,SubCat2,SubCat3,SubCat4; CatCode: Code[50])
    var
        Cat: Record "LSC Retail Product Group";
        SubCat3: Record "GXL Sub-Category 3";
        SubCat4: Record "GXL Sub-Category 4";
    begin
        if CatCode <> '' then begin
            CASE CatOption OF

                CatOption::Cat:
                    BEGIN
                        Cat.RESET();
                        Cat.SETRANGE(Code, CatCode);
                        if not Cat.IsEmpty() then
                            Cat.MODifYALL("GXL MPL Factor", 0);
                    end;

                CatOption::SubCat3:
                    BEGIN
                        SubCat3.RESET();
                        SubCat3.SETRANGE(Code, CatCode);
                        if SubCat3.ISEMPTY() = FALSE then
                            SubCat3.MODifYALL("MPL Factor", 0);

                    end;

                CatOption::SubCat4:
                    BEGIN
                        SubCat4.RESET();
                        SubCat4.SETRANGE(Code, CatCode);
                        if SubCat4.ISEMPTY() = FALSE then
                            SubCat4.MODifYALL("MPL Factor", 0);
                    end;
            end;
        end;
    end;
}

