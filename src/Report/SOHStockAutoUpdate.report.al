//UAT
//PS-1392 19-05-2020 LP:
//  SOH Data log not created when running via job queue
//  SOH data log not created if inventory is negative
//Re-design the SOH Integration
report 50110 "GXL SOH Stock Auto Update"
{
    Caption = 'SOH Stock Auto Update';
    UsageCategory = Administration;
    ApplicationArea = All;
    ProcessingOnly = true;

    /*
    dataset
    {
        dataitem(Item; Item)
        {
            dataitem("Item Unit of Measure"; "Item Unit of Measure")
            {
                DataItemLink = "Item No." = field ("No.");
                DataItemLinkReference = Item;
                dataitem(Location; Location)
                {
                    trigger OnAfterGetRecord()
                    var
                        SKUL: Record "Stockkeeping Unit";
                    begin
                        Item.SetFilter("Location Filter", Location.Code);
                        Item.CalcFields(Inventory);
                        IF OnlyInventoryChangedItemsL AND (Item.Inventory >= 0) then Begin
                            SKUL.Reset();
                            SKUL.SetRange("Item No.", Item."No.");
                            SKUL.SetRange("Location Code", Location.Code);
                            SKUL.SetRange("GXL Inventory Changed", true);
                            if SKUL.FindSet() then begin
                                repeat
                                    CreateLog(Item, "Item Unit of Measure", SKUL);
                                until SKUL.Next() = 0;
                            end;
                        end;

                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    if "GXL Legacy Item No." = '' then
                        CurrReport.Skip();
                end;

            }
            trigger OnPreDataItem()
            var
            begin
                if OnlyInventoryChangedItemsL then
                    SetRange("GXL Inventory Changed", true);
            end;


            trigger OnPostDataItem()
            var
                SKUL: Record "Stockkeeping Unit";
            begin
                ModifyAll("GXL Inventory Changed", false);
                SKUL.ModifyAll("GXL Inventory Changed", false);
            end;
        }
    }
    */

    dataset
    {
        dataitem("GXL SOH SKU Log"; "GXL SOH SKU Log")
        {
            DataItemTableView = sorting("Item No.", "Location Code");

            trigger OnPreDataItem()
            begin
                DeleteOldEntries();
                //if SendAllSKUs then //PS-2448
                if UpdateMode <> UpdateMode::"Delta Update" then //PS-2248
                    CurrReport.Break()
                else begin
                    if not IsEmpty() then
                        GetNewBatchID();
                end;
            end;

            trigger OnAfterGetRecord()
            begin
                Commit();
                Clear(SOHSKULogProcess);
                SOHSKULogProcess.SetBatchID(CurrBatchID);
                if SOHSKULogProcess.Run("GXL SOH SKU Log") then;
            end;
        }
        //PS-2448+
        dataitem("Stockkeeping Unit"; "Stockkeeping Unit")
        {
            RequestFilterFields = "Item No.", "Location Code";

            trigger OnPreDataItem()
            begin
                if UpdateMode <> UpdateMode::"By Item/Location" then
                    CurrReport.Break();

                if "Stockkeeping Unit".GetFilters() = '' then
                    Error('Please enter filter(s) for the Stockkeeping Unit.');

                GetNewBatchID();
                i := 0;
                OpenDialog();
            end;

            trigger OnAfterGetRecord()
            begin
                if (i mod 100) = 0 then begin
                    if OldLocCode <> "Location Code" then
                        UpdateDialog(1, "Location Code");
                    UpdateDialog(2, "Item No.");
                    OldLocCode := "Location Code";
                end;
                i += 1;
                ProcessBySKU("Stockkeeping Unit");
            end;

            trigger OnPostDataItem()
            begin
                CloseDialog();
            end;
        }
        //PS-2448-
        dataitem(Integer; Integer)
        {
            DataItemTableView = sorting(Number) where(Number = const(1));

            trigger OnPreDataItem()
            begin
                //PS-2448+
                //if not SendAllSKUs then
                if UpdateMode <> UpdateMode::"All SKUs" then
                    //PS-2448-
                    CurrReport.Break();
                ProcessAllSKUs();
            end;

            trigger OnAfterGetRecord()
            begin
            end;
        }
    }


    requestpage
    {
        layout
        {
            area(Content)
            {
                group(GroupName)
                {
                    //PS-2448+
                    /*
                    field(SendAllSKUsCtrl; SendAllSKUs)
                    {
                        Caption = 'Send All SKUs';
                        ApplicationArea = All;

                    }
                    */
                    field(UpdateModeCtrl; UpdateMode)
                    {
                        ApplicationArea = All;
                        Caption = 'Update Mode';
                        OptionCaption = 'Delta Update,By Item/Location,All SKUs';
                        ToolTip = 'Select the Update Mode to create SOH entry for Bloyal; Delta Update: only process SKUs that have inventory movement since the last update; By Item/Location: send SOH for selected SKUs from the Stockkeeping Unit filter tab; All SKUs: send SOH for all SKUs';
                    }
                    //PS-2448-
                }
            }
        }

        trigger OnOpenPage()
        var
        begin
        end;
    }

    trigger OnPreReport()
    begin
        GetSetup();
        DlgOpened := false;
    end;

    trigger OnPostReport()
    var
    begin
    end;



    var
        IntegrationSetup: Record "GXL Integration Setup";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SOHSKULogProcess: Codeunit "GXL SOH SKU Log-Process";
        //ProcessWasSuccess: Boolean;
        CurrBatchID: Code[20];
        //OnlyInventoryChangedItemsL;
        //SendAllSKUs: Boolean;
        SetupRead: Boolean;
        UpdateMode: Option "Delta Update","By Item/Location","All SKUs";
        Window: Dialog;
        DlgOpened: Boolean;
        i: Integer;
        OldLocCode: Code[10];

    /*
    local procedure CreateLog(var ItemRecP: Record Item; ItemUOMP: Record "Item Unit of Measure"; var SKU: Record "Stockkeeping Unit")
    var
        SOHStaggingTable: Record "GXL SOH Staging Data";
        LegacyItemHelpers: Codeunit "GXL Legacy Item Helpers";
        PDAItemIntegration: Codeunit "GXL PDA-Item Integration";
        CommitQty: Decimal;
    begin
        SOHStaggingTable.Reset();
        SOHStaggingTable.Init();
        SOHStaggingTable."Batch ID" := CurrBatchIDG;
        SOHStaggingTable."Auto ID" := 0;
        SOHStaggingTable."Item No." := ItemRecP."No.";
        SOHStaggingTable."Log Date" := Today();
        SOHStaggingTable."Log Time" := Time();
        SOHStaggingTable."Legacy Item No." := ItemUOMP."GXL Legacy Item No.";
        SOHStaggingTable."New Qty." := LegacyItemHelpers.CalculateLegacyItemQty("Item Unit of Measure", ItemRecP.Inventory);
        SOHStaggingTable."Location Code" := SKU."Location Code";
        SOHStaggingTable."Store Code" := SKU."Location Code";
        SOHStaggingTable.UOM := ItemUOMP.Code;
        IF Item."Base Unit of Measure" = ItemUOMP.Code then
            SOHStaggingTable."Base SOH" := ItemRecP.Inventory;

        CommitQty := PDAItemIntegration.GetCommittedQty(SKU);
        CommitQty := LegacyItemHelpers.CalculateLegacyItemQty(ItemUOMP, CommitQty, '>');

        SOHStaggingTable."Commited Qty." := CommitQty;
        SOHStaggingTable.Insert(true);
    end;
    */


    local procedure DeleteOldEntries()
    var
        SOHStagingLog: Record "GXL SOH Staging Data";
        DateExp1: Text;
    begin
        GetSetup();
        if format(IntegrationSetup."SOH Clear Data After") <> '' then begin
            SOHStagingLog.Reset();
            SOHStagingLog.SetCurrentKey("Log Date");
            DateExp1 := '<-' + Format(IntegrationSetup."SOH Clear Data After") + '>';
            SOHStagingLog.SetFilter("Log Date", '..%1', CalcDate(DateExp1, Today()));
            SOHStagingLog.DeleteAll();
            Commit();
        end;

    end;

    local procedure GetNewBatchID()
    begin
        GetSetup();
        if CurrBatchID = '' then begin
            IntegrationSetup.TestField("SOH Batch No. Series");
            NoSeriesMgt.InitSeries(IntegrationSetup."SOH Batch No. Series", IntegrationSetup."SOH Batch No. Series", Today(), CurrBatchID, IntegrationSetup."SOH Batch No. Series");
            Commit();
        end;
    end;

    local procedure GetSetup()
    begin
        if not SetupRead then begin
            IntegrationSetup.Get();
            SetupRead := true;
        end;
    end;

    local procedure ProcessAllSKUs()
    var
        SKU: Record "Stockkeeping Unit";
        SOHSKULog: Record "GXL SOH SKU Log";
    begin
        SKU.Reset();
        if SKU.FindSet() then begin
            i := 0;
            OpenDialog();

            GetNewBatchID();
            repeat
                if SKU."Item No." <> '' then begin //just incase item renaming to blank or data upload issue

                    if (i mod 1000) = 0 then begin
                        if OldLocCode <> SKU."Location Code" then
                            UpdateDialog(1, SKU."Location Code");
                        UpdateDialog(2, SKU."Item No.");
                        OldLocCode := SKU."Location Code";
                    end;
                    i += 1;

                    Clear(SOHSKULogProcess);
                    SOHSKULogProcess.SetBatchID(CurrBatchID);
                    SOHSKULogProcess.ProcessSKU(SKU);
                    Commit();
                end;
            until SKU.Next() = 0;
            SOHSKULog.DeleteAll();
            CloseDialog();
        end;
    end;

    local procedure OpenDialog()
    begin
        if GuiAllowed then begin
            Window.Open(
                'Updating Bloyal SOH  \\' +
                'Location   #1########\' +
                'Item No.   #2########');
            DlgOpened := true;
        end;

    end;

    local procedure UpdateDialog(UpdateNo: Integer; UpdateValue: Variant)
    begin
        if DlgOpened then
            Window.Update(UpdateNo, UpdateValue);
    end;

    local procedure CloseDialog()
    begin
        if DlgOpened then
            Window.Close();
    end;

    /// <summary>
    /// PS-2448
    /// Send to Bloyal SOH for a SKU
    /// </summary>
    /// <param name="SKU"></param>
    local procedure ProcessBySKU(var SKU: Record "Stockkeeping Unit")
    begin
        if SKU."Item No." <> '' then begin //just incase item renaming to blank or data upload issue
            Clear(SOHSKULogProcess);
            SOHSKULogProcess.SetBatchID(CurrBatchID);
            SOHSKULogProcess.ProcessSKU(SKU);
            Commit();
        end;
    end;
}