report 50006 "GXL Delta Prod Store Ranging"
{
    Caption = 'Delta Product Store Ranging';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    dataset
    {
        //Item - Range process
        dataitem(Item; Item)
        {
            DataItemTableView = sorting("GXL Delta Ranging Required") where("GXL Delta Ranging Required" = filter(true));
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
            begin
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

                ItemRec.Get("No.");
                ItemRec."GXL Delta Ranging Required" := false;
                ItemRec.Modify();

                if ("GXL Effective Date" <> 0D) and (ProdRangingMgt.ProductStatusCanBeRanged("GXL Product Status")) then begin
                    ProdRangingMgt.SetItem(ItemRec);
                    ProdRangingMgt.CreateItemRangingLine("No.");
                    ProdRangingMgt.CheckRangeException("No.");
                end else
                    CurrReport.Skip();
            end;

        }

        dataitem(Store; "LSC Store")
        {
            DataItemTableView = where("GXL Delta Ranging Required" = filter(true));
            RequestFilterFields = "No.";

            trigger OnPreDataItem()
            begin

            end;

            trigger OnAfterGetRecord()
            begin
                Clear(ProdRangingMgt);
                ProdRangingMgt.CreateItemRangingLineFromLocation("No.");

                StoreRec.Get("No.");
                StoreRec."GXL Delta Ranging Required" := false;
                StoreRec.Modify();
                Commit();
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
        ItemRec: Record Item;
        Loc: Record Location;
        StoreRec: Record "LSC Store";
        ProdStoreRanging: Record "GXL Product-Store Ranging";
        ProdRangingMgt: Codeunit "GXL Product Ranging Management";
        IllegalProdRangingNotif: Codeunit "GXL Illegal Prod Range Notif.";
        TotalRecords: Integer;
        Counter: Integer;
        Windows: Dialog;
        Text001Txt: Label 'Create Ranging ...\\';
        Text002Txt: Label 'Processing %1';
        Text003Txt: Label '@2@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@';
        Text004Txt: Label '#1###########\\';



}