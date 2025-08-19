//<Summary>
//Update the product-store ranging
//Range/de-range product process from either item or location
//If it is run manually, can be used for specific item or location code
//It is is run via batch, then only update for items that have been been updated within the last 7 days 
//</Summary>
report 50007 "GXL Create Prod Store Ranging"
{
    Caption = 'Create Product Store Ranging';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        //Item - Range process
        //Using Item Processed Log to be certain that the Update Item batch job has been completed for the item
        dataitem(Item; Item)
        {
            RequestFilterFields = "No.";

            //Store - de-range process
            dataitem(StorePSR; "GXL Product-Store Ranging")
            {
                DataItemTableView = sorting("Item No.", "Store Code") where(Ranged = filter(true));
                DataItemLink = "Item No." = field("No.");

                trigger OnAfterGetRecord()
                begin
                    Loc.Code := "Store Code";
                    if Loc.GetAssociatedStore(StoreRec, true) then
                        if StoreRec."GXL Location Type" <> StoreRec."GXL Location Type"::"6" then
                            CurrReport.Skip();

                    Clear(ProdRangingMgt);
                    ProdStoreRanging.Reset();
                    ProdStoreRanging.Get("Item No.", "Store Code");
                    if not ProdRangingMgt.GetRangingFlag(ProdStoreRanging) then begin
                        ProdStoreRanging.Ranged := false;
                        ProdStoreRanging.Modify(true);
                        ProdRangingMgt.QuitSKU(ProdStoreRanging);
                        if ProdRangingMgt.GetIllegalSKURangeFlag() then
                            ProdRangingMgt.LogIllegalProductRange("Item No.", "Store Code");
                    end;

                end;
            }

            //Warehouse - de-range process
            dataitem(WhsePSR; "GXL Product-Store Ranging")
            {
                DataItemTableView = sorting("Item No.", "Store Code") where(Ranged = filter(true));
                DataItemLink = "Item No." = field("No.");

                trigger OnAfterGetRecord()
                begin
                    Loc.Code := "Store Code";
                    if Loc.GetAssociatedStore(StoreRec, true) then
                        if StoreRec."GXL Location Type" <> StoreRec."GXL Location Type"::"3" then
                            CurrReport.Skip();

                    Clear(ProdRangingMgt);
                    ProdStoreRanging.Reset();
                    ProdStoreRanging.Get("Item No.", "Store Code");
                    if not ProdRangingMgt.GetRangingFlag(ProdStoreRanging) then begin
                        ProdStoreRanging.Ranged := false;
                        ProdStoreRanging.Modify(true);
                        ProdRangingMgt.QuitSKU(ProdStoreRanging);
                    end;

                end;

                trigger OnPostDataItem()
                begin
                    Commit();
                end;
            }

            trigger OnPreDataItem()
            var
                LastDateModifiedFilter: Date;
            begin
                if TableNo = Database::Location then
                    CurrReport.Break();

                if ItemNo <> '' then
                    SetRange("No.", ItemNo)
                else begin
                    LastDateModifiedFilter := CalcDate('<-7D>', Today());
                    SetFilter("Last Date Modified", '>=%1', LastDateModifiedFilter);
                end;

                SetFilter("GXL Product Status", '<>%1&<>%2', "GXL Product Status"::Quit, "GXL Product Status"::Inactive);
                SetFilter("GXL Effective Date", '<>%1', 0D);

                if GuiAllowed() then
                    TotalRecords := Count();
            end;

            trigger OnAfterGetRecord()
            begin
                Clear(ProdRangingMgt);
                if GuiAllowed() then begin
                    Counter += 1;
                    Windows.Update(1, Item."No.");
                    Windows.Update(2, Round(Counter / TotalRecords * 10000, 1));
                end;

                if (ProdRangingMgt.ProductStatusCanBeRanged("GXL Product Status")) then begin
                    ProdRangingMgt.CreateItemRangingLine("No.");
                    ProdRangingMgt.CheckRangeException("No.");
                end else
                    CurrReport.Skip();
            end;

            trigger OnPostDataItem()
            begin
            end;
        }
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            trigger OnPreDataItem()
            begin
                if TableNo <> Database::Location then
                    CurrReport.Break();
                if LocCode = '' then
                    CurrReport.Break();

                Clear(ProdRangingMgt);
                ProdRangingMgt.CreateItemRangingLineFromLocation(LocCode);
            end;
        }

    }

    requestpage
    {
        layout
        {
            area(Content)
            {
            }
        }

    }

    trigger OnInitReport()
    begin
        SelectLatestVersion();
    end;

    trigger OnPreReport()
    begin
        if GuiAllowed() then
            Windows.Open(Text001Txt + StrSubstNo(Text002Txt, '') + Text003Txt + Text004Txt);

    end;

    trigger OnPostReport()
    begin
        if GuiAllowed() then
            Windows.Close();

        Commit();
        Clear(IllegalProdRangingNotif);
        if IllegalProdRangingNotif.Run() then;
    end;


    var
        Loc: Record Location;
        StoreRec: Record "LSC Store";
        ProdStoreRanging: Record "GXL Product-Store Ranging";
        ProdRangingMgt: Codeunit "GXL Product Ranging Management";
        IllegalProdRangingNotif: Codeunit "GXL Illegal Prod Range Notif.";
        TotalRecords: Integer;
        Counter: Integer;
        Windows: Dialog;
        TableNo: Integer;
        ItemNo: Code[20];
        LocCode: Code[10];
        Text001Txt: Label 'Create Ranging ...\\';
        Text002Txt: Label 'Processing %1';
        Text003Txt: Label '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        Text004Txt: Label '#1###########\\';


    procedure SetValues(NewTableNo: Integer; NewItemNo: Code[20]; NewLocCode: Code[10])
    begin
        TableNo := NewTableNo;
        ItemNo := NewItemNo;
        LocCode := NewLocCode;
    end;

}